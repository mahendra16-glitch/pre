import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class BluetoothPrinter {
  final int? id;
  final String? deviceName;
  final String? address;
  final String? port;
  final String? vendorId;
  final String? productId;
  final bool isBle;
  final PrinterType typePrinter;
  final bool? state;

  const BluetoothPrinter({
    this.id,
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });
}
