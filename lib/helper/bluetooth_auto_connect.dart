import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// Keeps the iOS Bluetooth printer connected automatically in the background.
/// When iPad Bluetooth is turned on, or the app is opened/resumed, it automatically
/// connects to the configured printer so printing can happen immediately
/// without manual reconnection.
class BluetoothAutoConnect with WidgetsBindingObserver {
  BluetoothAutoConnect._();
  static final BluetoothAutoConnect instance = BluetoothAutoConnect._();

  static const Duration _checkInterval = Duration(seconds: 12);
  Timer? _checkTimer;
  bool _running = false;
  bool _connecting = false;
  bool isPaused = false;
  bool _lifecycleObserved = false;

  static final RegExp _uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  bool _isValidUUID(String s) => _uuidPattern.hasMatch(s.trim());

  dynamic get _profile {
    try {
      return Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
    } catch (_) {
      return null;
    }
  }

  /// Get the primary configured iOS Bluetooth printer UUID.
  String? get primaryPrinterUUID {
    final profile = _profile;
    if (profile == null) return null;

    // Check Bill printer UUID
    final billMac = (profile.macBillPrinterIp ?? '').toString().trim();
    if (_isValidUUID(billMac)) return billMac;

    // Check KOT printer UUIDs
    final printers = profile.restaurantPrinterNew;
    if (printers != null) {
      for (final printer in printers) {
        final mac = (printer.macPrinterIp ?? '').toString().trim();
        if (_isValidUUID(mac)) return mac;
      }
    }
    return null;
  }

  /// Start auto-connect background loop.
  void start() {
    if (!Platform.isIOS) return;
    if (!_lifecycleObserved) {
      WidgetsBinding.instance.addObserver(this);
      _lifecycleObserved = true;
    }
    if (_running) {
      _checkAndConnect();
      return;
    }
    _running = true;
    log('[BT-AutoConnect] started');
    _checkAndConnect();
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(_checkInterval, (_) => _checkAndConnect());
  }

  /// Stop auto-connect.
  void stop() {
    _running = false;
    _checkTimer?.cancel();
    _checkTimer = null;
    log('[BT-AutoConnect] stopped');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _running) {
      log('[BT-AutoConnect] app resumed, checking connection...');
      _checkAndConnect();
    }
  }

  Future<void> _checkAndConnect() async {
    if (!Platform.isIOS || !_running || isPaused || _connecting) return;
    _connecting = true;
    try {
      final btEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!btEnabled) {
        return;
      }

      final isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) {
        return; // Already connected!
      }

      final uuid = primaryPrinterUUID;
      if (uuid == null || uuid.isEmpty) {
        return;
      }

      log('[BT-AutoConnect] Bluetooth is ON but printer is disconnected. Auto-connecting to $uuid...');
      final ok = await PrintBluetoothThermal.connect(macPrinterAddress: uuid);
      if (ok) {
        log('[BT-AutoConnect] ✅ Auto-connected to printer $uuid');
      } else {
        log('[BT-AutoConnect] ❌ Auto-connect failed, will retry in ${_checkInterval.inSeconds}s');
      }
    } catch (e) {
      log('[BT-AutoConnect] exception: $e');
    } finally {
      _connecting = false;
    }
  }
}
