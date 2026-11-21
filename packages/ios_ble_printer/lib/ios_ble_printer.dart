import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class BlePrinterDevice {
  /// CoreBluetooth peripheral identifier. This is the same value the app
  /// already stores in `mac_printer_ip` on iOS.
  final String id;
  final String name;
  final int rssi;
  const BlePrinterDevice(this.id, this.name, this.rssi);
}

class BlePrinterException implements Exception {
  /// BT_OFF, BT_UNAUTHORIZED, BT_UNSUPPORTED, NOT_FOUND, TIMEOUT,
  /// NO_WRITABLE_CHARACTERISTIC, NOT_CONNECTED, DISCONNECTED, WRITE_FAILED,
  /// BUSY, UNSUPPORTED_PLATFORM.
  final String code;
  final String message;

  /// Bytes of the failed job that reached the printer. If greater than 0,
  /// part of the job may have printed, so it must not be resent automatically.
  final int bytesSent;

  BlePrinterException(this.code, this.message, {this.bytesSent = 0});

  bool get mayHavePrinted => bytesSent > 0;

  @override
  String toString() => 'BlePrinterException($code, sent=$bytesSent): $message';
}

/// Native CoreBluetooth transport (iOS / iPadOS only).
class IosBlePrinter {
  IosBlePrinter._();

  static const MethodChannel _ch = MethodChannel('mygenie/ios_ble_printer');

  static bool get isSupported => Platform.isIOS;

  static Future<T> _call<T>(String method, [Map<String, dynamic>? args]) async {
    if (!isSupported) {
      throw BlePrinterException(
          'UNSUPPORTED_PLATFORM', 'Native BLE printing is iOS only');
    }
    try {
      return await _ch.invokeMethod(method, args) as T;
    } on PlatformException catch (e) {
      final details = e.details;
      final sent = details is Map ? (details['bytesSent'] as int? ?? 0) : 0;
      throw BlePrinterException(e.code, e.message ?? e.code, bytesSent: sent);
    }
  }

  /// poweredOn, poweredOff, unauthorized, unsupported, resetting, unknown.
  static Future<String> state() => _call<String>('state');

  static Future<List<BlePrinterDevice>> scan(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final list = await _call<List<dynamic>>(
        'scan', {'timeoutMs': timeout.inMilliseconds});
    return list
        .cast<Map>()
        .map((m) => BlePrinterDevice(
            '${m['id']}', '${m['name']}', (m['rssi'] as num?)?.toInt() ?? 0))
        .toList();
  }

  /// Returns the negotiated packet size and write mode.
  static Future<Map<String, dynamic>> connect(String id,
      {Duration timeout = const Duration(seconds: 8)}) async {
    final res = await _call<Map<dynamic, dynamic>>(
        'connect', {'id': id, 'timeoutMs': timeout.inMilliseconds});
    return res.cast<String, dynamic>();
  }

  /// Sends [bytes]; the native side splits them into packets that fit the
  /// printer's MTU and handles flow control.
  static Future<int> write(String id, List<int> bytes) async {
    final res = await _call<Map<dynamic, dynamic>>(
        'write', {'id': id, 'bytes': Uint8List.fromList(bytes)});
    return (res['bytesSent'] as int?) ?? bytes.length;
  }

  static Future<void> disconnect(String id) =>
      _call<bool>('disconnect', {'id': id});

  static Future<bool> isConnected(String id) =>
      _call<bool>('isConnected', {'id': id});
}
