import 'dart:developer' as dev;
import 'dart:io';

import 'package:ios_ble_printer/ios_ble_printer.dart';
import 'package:mygenie_restaurant/helper/print_debug_logger.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/wifi_printer_service.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

enum IosPrintRoute { existingBluetooth, nativeBle, wifiLan }

/// Drop-in replacement for the `PrintBluetoothThermal` calls used by the
/// iOS / iPadOS print functions. It only changes HOW the already-generated
/// ESC/POS bytes reach the printer; it never builds or alters print data.
///
/// Routes:
/// * Wi-Fi/LAN: `wifiPrinter != null` (resolved from the existing profile by
///   [NetworkPrinterResolver]) → raw TCP via [WifiPrinterService].
/// * Bluetooth (default): `PrintBluetoothThermal`, exactly as before.
/// * Bluetooth (native module): only when [useNativeBle] is true → the
///   CoreBluetooth module in `packages/ios_ble_printer`. Same printer
///   identifier (`mac_printer_ip`), so no configuration change is needed.
///
/// Like `PrintBluetoothThermal`, it has one current connection. To print to
/// several network printers at the same time use
/// [WifiPrinterService.printBytes].
class IosPrintTransport {
  IosPrintTransport._();

  /// Opt-in switch for the new native BLE module. Off by default so the
  /// existing, working Bluetooth path stays exactly as it is. Turn on only
  /// after testing the target printers on real iPhone/iPad devices.
  static bool useNativeBle = false;

  static IosPrintRoute _route = IosPrintRoute.existingBluetooth;
  static WifiPrinterSession? _session;
  static String? _bleId;
  static Object? lastError;
  static DateTime? _lastHintShown;

  static IosPrintRoute get currentRoute => _route;
  static bool get isWifiActive => _session != null;

  static bool get _nativeBleEnabled => useNativeBle && Platform.isIOS;

  static Future<bool> connect({
    required String macPrinterAddress,
    NetworkPrinterTarget? wifiPrinter,
  }) async {
    lastError = null;
    await _closeWifiSession();
    await _closeNativeBle();

    if (wifiPrinter != null) {
      _route = IosPrintRoute.wifiLan;
      WifiPrinterService.onLog ??= _forwardWifiLog;
      try {
        _session = await WifiPrinterService.instance.openSession(wifiPrinter);
        return true;
      } on WifiPrintException catch (e) {
        _report(e, e.message);
        return false;
      } catch (e) {
        _report(e,
            'Could not connect to ${wifiPrinter.label} (${wifiPrinter.key})');
        return false;
      }
    }

    if (_nativeBleEnabled) {
      _route = IosPrintRoute.nativeBle;
      try {
        await IosBlePrinter.connect(macPrinterAddress);
        _bleId = macPrinterAddress;
        _log('BLE connected $macPrinterAddress');
        return true;
      } on BlePrinterException catch (e) {
        _report(e, e.message);
        return false;
      } catch (e) {
        _report(e, 'Could not connect to Bluetooth printer');
        return false;
      }
    }

    _route = IosPrintRoute.existingBluetooth;
    return PrintBluetoothThermal.connect(macPrinterAddress: macPrinterAddress);
  }

  static Future<bool> writeBytes(List<int> bytes) async {
    final session = _session;
    if (session != null) {
      try {
        await session.write(bytes);
        return true;
      } on WifiPrintException catch (e) {
        _report(e, e.message);
        return false;
      } catch (e) {
        _report(e, 'Send failed to ${session.target.key}');
        return false;
      }
    }
    final bleId = _bleId;
    if (bleId != null) {
      try {
        await IosBlePrinter.write(bleId, bytes);
        return true;
      } on BlePrinterException catch (e) {
        _report(
            e,
            e.mayHavePrinted
                ? '${e.message}. Part of the job may have printed; check before reprinting.'
                : e.message);
        return false;
      } catch (e) {
        _report(e, 'Bluetooth send failed');
        return false;
      }
    }
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  /// Same shape as `PrintBluetoothThermal.disconnect` (a getter).
  static Future<bool> get disconnect async {
    if (_session != null) {
      await _closeWifiSession();
      return true;
    }
    if (_bleId != null) {
      await _closeNativeBle();
      return true;
    }
    return PrintBluetoothThermal.disconnect;
  }

  /// Same shape as `PrintBluetoothThermal.connectionStatus` (a getter).
  static Future<bool> get connectionStatus async {
    final session = _session;
    if (session != null) return session.isOpen;
    final bleId = _bleId;
    if (bleId != null) {
      try {
        return await IosBlePrinter.isConnected(bleId);
      } catch (_) {
        return false;
      }
    }
    return PrintBluetoothThermal.connectionStatus;
  }

  static Future<void> _closeWifiSession() async {
    final s = _session;
    _session = null;
    if (s != null) await s.close();
  }

  static Future<void> _closeNativeBle() async {
    final id = _bleId;
    _bleId = null;
    if (id != null) {
      try {
        await IosBlePrinter.disconnect(id);
      } catch (_) {}
    }
  }

  /// Sends Wi-Fi/LAN diagnostics to the app's existing print debug log.
  static void _forwardWifiLog(String traceId, String event, bool success,
      String message, Map<String, dynamic> details) {
    switch (event) {
      case 'CONNECT':
        PrintDebugLogger.printerConnect(
            traceId: traceId,
            success: success,
            printerMode: 'wifi-ios',
            printerIp: '${details['printer'] ?? ''}',
            printerName: '${details['label'] ?? ''}',
            details: details);
        break;
      case 'SEND':
        PrintDebugLogger.printerSend(
            traceId: traceId,
            success: success,
            bytesLength: details['bytes'] as int?,
            printerMode: 'wifi-ios',
            details: details);
        break;
      case 'DISCONNECT':
        PrintDebugLogger.printerDisconnect(
            traceId: traceId, success: success, details: details);
        break;
      default:
        PrintDebugLogger.info(
            traceId: traceId,
            message: message,
            event: 'WIFI_PRINTER',
            details: details);
    }
  }

  static void _log(String msg) {
    dev.log('[IosPrintTransport] $msg');
    try {
      PrintDebugLogger.info(
          traceId: 'ios-transport', message: msg, event: 'IOS_TRANSPORT');
    } catch (_) {}
  }

  static void _report(Object error, String userMessage) {
    lastError = error;
    _log('route=${_route.name} error=$error');
    // The calling screen already shows its own "print failed" message.
    // Add the reason, at most once every 30 seconds so a batch of KOTs does
    // not flood the screen.
    final now = DateTime.now();
    if (_lastHintShown == null ||
        now.difference(_lastHintShown!) > const Duration(seconds: 30)) {
      _lastHintShown = now;
      try {
        showErrorToast(userMessage);
      } catch (_) {}
    }
  }
}
