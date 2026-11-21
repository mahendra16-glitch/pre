import CoreBluetooth
import Flutter
import UIKit

/// CoreBluetooth ESC/POS transport for iOS / iPadOS.
///
/// Method channel: "mygenie/ios_ble_printer"
///   state                         -> String (poweredOn, poweredOff, unauthorized, unsupported, resetting, unknown)
///   scan {timeoutMs}              -> [{id, name, rssi}]
///   connect {id, timeoutMs}       -> {maxWrite, withResponse, characteristic}
///   write {id, bytes}             -> {bytesSent}
///   disconnect {id}               -> true
///   isConnected {id}              -> Bool
///
/// Errors use FlutterError codes:
///   BT_OFF, BT_UNAUTHORIZED, BT_UNSUPPORTED, NOT_FOUND, TIMEOUT,
///   NO_WRITABLE_CHARACTERISTIC, NOT_CONNECTED, DISCONNECTED, WRITE_FAILED, BUSY.
/// For DISCONNECTED / WRITE_FAILED, `details["bytesSent"]` tells how much of the
/// job reached the printer, so the app never resends blindly.
public class IosBlePrinterPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate {

  // Known ESC/POS printer service / characteristic UUIDs (common Chinese BLE
  // thermal modules, Microchip ISSC, and the 18F0/FF00 families).
  private static let preferredCharacteristics: [CBUUID] = [
    CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3"),
    CBUUID(string: "A76EB9E2-F3AC-4990-84CF-3A94D2426B2B"),
    CBUUID(string: "2AF1"),
    CBUUID(string: "FF02"),
    CBUUID(string: "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"),
  ]

  private var central: CBCentralManager!
  private var stateWaiters: [(CBManagerState) -> Void] = []

  // Scan
  private var discovered: [UUID: (peripheral: CBPeripheral, rssi: Int)] = [:]
  private var scanResult: FlutterResult?

  // Connections (one entry per printer, so several printers can be used).
  private final class Link {
    let peripheral: CBPeripheral
    var characteristic: CBCharacteristic?
    var connectResult: FlutterResult?
    var connectTimer: DispatchWorkItem?
    var pendingServices = 0
    // Current write job
    var job: Data?
    var offset = 0
    var chunk = 20
    var withResponse = false
    var writeResult: FlutterResult?
    var writeTimer: DispatchWorkItem?
    init(_ p: CBPeripheral) { peripheral = p }
  }
  private var links: [UUID: Link] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mygenie/ios_ble_printer", binaryMessenger: registrar.messenger())
    let instance = IosBlePrinterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // Created lazily so the Bluetooth permission prompt appears only when the
  // app actually uses BLE printing, not at launch.
  private func ensureCentral() {
    if central == nil {
      central = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
  }

  private func whenReady(_ result: @escaping FlutterResult, _ action: @escaping () -> Void) {
    ensureCentral()
    let proceed: (CBManagerState) -> Void = { state in
      switch state {
      case .poweredOn: action()
      case .poweredOff: result(FlutterError(code: "BT_OFF", message: "Bluetooth is switched off", details: nil))
      case .unauthorized: result(FlutterError(code: "BT_UNAUTHORIZED", message: "Bluetooth permission denied. Allow it in Settings.", details: nil))
      case .unsupported: result(FlutterError(code: "BT_UNSUPPORTED", message: "This device does not support Bluetooth LE", details: nil))
      default: result(FlutterError(code: "BT_OFF", message: "Bluetooth is not ready", details: nil))
      }
    }
    if central.state == .unknown || central.state == .resetting {
      stateWaiters.append(proceed)
      // Do not wait forever for the permission dialog.
      DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
        guard let self = self, !self.stateWaiters.isEmpty else { return }
        let waiters = self.stateWaiters
        self.stateWaiters.removeAll()
        waiters.forEach { $0(self.central.state) }
      }
    } else {
      proceed(central.state)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "state":
      ensureCentral()
      result(Self.name(central.state))
    case "scan":
      let ms = args["timeoutMs"] as? Int ?? 5000
      whenReady(result) { self.scan(ms, result) }
    case "connect":
      guard let id = (args["id"] as? String).flatMap(UUID.init(uuidString:)) else {
        result(FlutterError(code: "NOT_FOUND", message: "Invalid printer identifier", details: nil)); return
      }
      let ms = args["timeoutMs"] as? Int ?? 8000
      whenReady(result) { self.connect(id, ms, result) }
    case "write":
      guard let id = (args["id"] as? String).flatMap(UUID.init(uuidString:)),
            let bytes = args["bytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "NOT_CONNECTED", message: "Invalid write arguments", details: nil)); return
      }
      write(id, bytes.data, result)
    case "disconnect":
      if let id = (args["id"] as? String).flatMap(UUID.init(uuidString:)), let link = links[id] {
        central?.cancelPeripheralConnection(link.peripheral)
      }
      result(true)
    case "isConnected":
      if let id = (args["id"] as? String).flatMap(UUID.init(uuidString:)), let link = links[id] {
        result(link.peripheral.state == .connected && link.characteristic != nil)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Scan

  private func scan(_ ms: Int, _ result: @escaping FlutterResult) {
    if scanResult != nil {
      result(FlutterError(code: "BUSY", message: "A scan is already running", details: nil)); return
    }
    discovered.removeAll()
    scanResult = result
    // Already-connected printers do not advertise; include them too.
    for p in central.retrieveConnectedPeripherals(withServices: [CBUUID(string: "18F0"), CBUUID(string: "FF00"), CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455"), CBUUID(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")]) {
      discovered[p.identifier] = (p, 0)
    }
    central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms)) { [weak self] in
      guard let self = self, let r = self.scanResult else { return }
      self.central.stopScan()
      self.scanResult = nil
      let list = self.discovered.values
        .filter { ($0.peripheral.name ?? "").isEmpty == false }
        .sorted { $0.rssi > $1.rssi }
        .map { ["id": $0.peripheral.identifier.uuidString, "name": $0.peripheral.name ?? "", "rssi": $0.rssi] as [String: Any] }
      r(list)
    }
  }

  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
    discovered[peripheral.identifier] = (peripheral, RSSI.intValue)
  }

  // MARK: Connect

  private func connect(_ id: UUID, _ ms: Int, _ result: @escaping FlutterResult) {
    if let link = links[id], link.peripheral.state == .connected, let c = link.characteristic {
      result(info(link, c)); return
    }
    guard let peripheral = central.retrievePeripherals(withIdentifiers: [id]).first else {
      result(FlutterError(code: "NOT_FOUND", message: "Printer not found. Scan and select it again.", details: nil)); return
    }
    let link = links[id] ?? Link(peripheral)
    if link.connectResult != nil {
      result(FlutterError(code: "BUSY", message: "Already connecting to this printer", details: nil)); return
    }
    links[id] = link
    link.characteristic = nil
    link.connectResult = result
    peripheral.delegate = self
    let timer = DispatchWorkItem { [weak self] in
      guard let self = self, let r = link.connectResult else { return }
      link.connectResult = nil
      self.central.cancelPeripheralConnection(peripheral)
      r(FlutterError(code: "TIMEOUT", message: "Printer did not respond. Check it is on and in range.", details: nil))
    }
    link.connectTimer = timer
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms), execute: timer)
    central.connect(peripheral, options: nil)
  }

  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.discoverServices(nil)
  }

  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    guard let link = links[peripheral.identifier] else { return }
    finishConnect(link, FlutterError(code: "NOT_FOUND", message: "Could not connect: \(error?.localizedDescription ?? "unknown error")", details: nil))
  }

  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let link = links[peripheral.identifier] else { return }
    let services = peripheral.services ?? []
    if error != nil || services.isEmpty {
      finishConnect(link, FlutterError(code: "NO_WRITABLE_CHARACTERISTIC", message: "Printer exposes no services", details: nil)); return
    }
    link.pendingServices = services.count
    services.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
  }

  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let link = links[peripheral.identifier], link.connectResult != nil else { return }
    link.pendingServices -= 1
    if link.pendingServices > 0 { return }

    let all = (peripheral.services ?? []).flatMap { $0.characteristics ?? [] }
    let writable = all.filter { $0.properties.contains(.write) || $0.properties.contains(.writeWithoutResponse) }
    let chosen = writable.first { Self.preferredCharacteristics.contains($0.uuid) } ?? writable.first
    guard let c = chosen else {
      finishConnect(link, FlutterError(code: "NO_WRITABLE_CHARACTERISTIC", message: "This Bluetooth device is not a supported BLE printer", details: nil)); return
    }
    link.characteristic = c
    // Prefer write-with-response when the printer supports it: it gives
    // per-packet confirmation and avoids overrunning small printer buffers.
    link.withResponse = c.properties.contains(.write)
    let type: CBCharacteristicWriteType = link.withResponse ? .withResponse : .withoutResponse
    link.chunk = max(20, min(peripheral.maximumWriteValueLength(for: type), 512))
    finishConnect(link, info(link, c))
  }

  private func info(_ link: Link, _ c: CBCharacteristic) -> [String: Any] {
    return ["maxWrite": link.chunk, "withResponse": link.withResponse, "characteristic": c.uuid.uuidString]
  }

  private func finishConnect(_ link: Link, _ value: Any) {
    link.connectTimer?.cancel()
    link.connectTimer = nil
    let r = link.connectResult
    link.connectResult = nil
    r?(value)
  }

  public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    guard let link = links[peripheral.identifier] else { return }
    link.characteristic = nil
    if link.connectResult != nil {
      finishConnect(link, FlutterError(code: "DISCONNECTED", message: "Printer disconnected while connecting", details: nil))
    }
    if link.writeResult != nil {
      // Out of range / printer switched off / Bluetooth turned off mid-job.
      finishWrite(link, FlutterError(code: "DISCONNECTED", message: "Printer disconnected during printing", details: ["bytesSent": link.offset]))
    }
  }

  // MARK: Write

  private func write(_ id: UUID, _ data: Data, _ result: @escaping FlutterResult) {
    guard let link = links[id], link.peripheral.state == .connected, link.characteristic != nil else {
      result(FlutterError(code: "NOT_CONNECTED", message: "Printer is not connected", details: ["bytesSent": 0])); return
    }
    if link.writeResult != nil {
      result(FlutterError(code: "BUSY", message: "Printer is busy with another job", details: ["bytesSent": 0])); return
    }
    if data.isEmpty { result(["bytesSent": 0]); return }
    link.job = data
    link.offset = 0
    link.writeResult = result
    armWriteTimer(link)
    pump(link)
  }

  private func armWriteTimer(_ link: Link) {
    link.writeTimer?.cancel()
    let t = DispatchWorkItem { [weak self] in
      self?.finishWrite(link, FlutterError(code: "TIMEOUT", message: "Printer stopped accepting data", details: ["bytesSent": link.offset]))
    }
    link.writeTimer = t
    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: t)
  }

  private func pump(_ link: Link) {
    guard let data = link.job, let c = link.characteristic, link.writeResult != nil else { return }
    if link.withResponse {
      if link.offset >= data.count { finishWrite(link, ["bytesSent": link.offset]); return }
      let end = min(link.offset + link.chunk, data.count)
      link.peripheral.writeValue(data.subdata(in: link.offset..<end), for: c, type: .withResponse)
      // offset advances in didWriteValueFor
    } else {
      while link.offset < data.count {
        if #available(iOS 11.0, *), !link.peripheral.canSendWriteWithoutResponse {
          return // resumes in peripheralIsReady(toSendWriteWithoutResponse:)
        }
        let end = min(link.offset + link.chunk, data.count)
        link.peripheral.writeValue(data.subdata(in: link.offset..<end), for: c, type: .withoutResponse)
        link.offset = end
        armWriteTimer(link)
      }
      finishWrite(link, ["bytesSent": link.offset])
    }
  }

  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    guard let link = links[peripheral.identifier], link.withResponse, let data = link.job, link.writeResult != nil else { return }
    if let error = error {
      finishWrite(link, FlutterError(code: "WRITE_FAILED", message: error.localizedDescription, details: ["bytesSent": link.offset])); return
    }
    link.offset = min(link.offset + link.chunk, data.count)
    armWriteTimer(link)
    pump(link)
  }

  public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    guard let link = links[peripheral.identifier], !link.withResponse else { return }
    pump(link)
  }

  private func finishWrite(_ link: Link, _ value: Any) {
    link.writeTimer?.cancel()
    link.writeTimer = nil
    link.job = nil
    let r = link.writeResult
    link.writeResult = nil
    r?(value)
  }

  // MARK: State

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state != .unknown && central.state != .resetting && !stateWaiters.isEmpty {
      let waiters = stateWaiters
      stateWaiters.removeAll()
      waiters.forEach { $0(central.state) }
    }
    if central.state != .poweredOn {
      // Bluetooth switched off / permission revoked: fail any running job
      // with the exact progress so the app can tell the user.
      for link in links.values {
        link.characteristic = nil
        if link.connectResult != nil {
          finishConnect(link, FlutterError(code: "BT_OFF", message: "Bluetooth turned off", details: nil))
        }
        if link.writeResult != nil {
          finishWrite(link, FlutterError(code: "DISCONNECTED", message: "Bluetooth turned off during printing", details: ["bytesSent": link.offset]))
        }
      }
      if let r = scanResult { scanResult = nil; r([]) }
    }
  }

  private static func name(_ s: CBManagerState) -> String {
    switch s {
    case .poweredOn: return "poweredOn"
    case .poweredOff: return "poweredOff"
    case .unauthorized: return "unauthorized"
    case .unsupported: return "unsupported"
    case .resetting: return "resetting"
    default: return "unknown"
    }
  }
}
