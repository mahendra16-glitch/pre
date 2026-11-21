import 'dart:io';

import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_address.dart';

export 'package:mygenie_restaurant/helper/wifi_printer/network_printer_address.dart';

/// Decides, from the existing printer profile, whether an iOS / iPadOS print
/// job should go to a Wi-Fi/LAN printer instead of Bluetooth.
///
/// To keep existing installations exactly as they are, Wi-Fi is used only when:
///   * the app runs on iOS / iPadOS,
///   * the printer is configured with type `wifi` (profile `printer_name`),
///   * a valid `wifi_printer_ip` is set, and
///   * no Bluetooth MAC (`mac_printer_ip`) is configured for that printer.
/// A printer that already has a Bluetooth MAC keeps printing over Bluetooth.
class NetworkPrinterResolver {
  NetworkPrinterResolver._();

  static bool get _isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static ProfileModel? get _profile {
    try {
      return Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
    } catch (_) {
      return null;
    }
  }

  static NetworkPrinterTarget? _resolve({
    required String? type,
    required String? wifiIp,
    required String? mac,
    required String label,
    required int? paperSize,
  }) {
    if (!_isIOS) return null;
    if ((type ?? '').trim().toLowerCase() != 'wifi') return null;
    if ((mac ?? '').trim().isNotEmpty) return null;
    return NetworkPrinterTarget.parse(
      wifiIp,
      label: label,
      paperSize: paperSize == 58 ? 58 : 80,
    );
  }

  /// Wi-Fi target for the BILL printer, or null to keep Bluetooth.
  static NetworkPrinterTarget? billPrinter() {
    final p = _profile;
    if (p == null) return null;
    return _resolve(
      type: p.billPrinterType,
      wifiIp: p.billWifiIp,
      mac: p.macBillPrinterIp,
      label: 'BILL',
      paperSize: p.billPrinterPaperRoll,
    );
  }

  /// Wi-Fi target for a KOT/station printer, or null to keep Bluetooth.
  static NetworkPrinterTarget? kotPrinter(RestaurantPrinterNew? printer) {
    if (printer == null) return null;
    return _resolve(
      type: printer.printerName,
      wifiIp: printer.wifiPrinterIp,
      mac: printer.macPrinterIp,
      label: printer.areaName ?? 'KOT',
      paperSize: printer.printerPaperRoll,
    );
  }

  /// Wi-Fi target for `profileModel.restaurantPrinterNew[index]`.
  static NetworkPrinterTarget? kotPrinterAt(int index) {
    final list = _profile?.restaurantPrinterNew;
    if (list == null || index < 0 || index >= list.length) return null;
    return kotPrinter(list[index]);
  }
}
