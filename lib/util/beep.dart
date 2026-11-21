import 'dart:typed_data';

import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';

void beepWindows() async {
  // Uint8List beepCmd = Uint8List.fromList([0x1B, 0x42, 0x03, 0x03]);

  // await PrinterManager.instance.send(
  //   type: Get.find<AuthController>().profileModel!.isLANPrint == 'Yes'
  //       ? PrinterType.network
  //       : PrinterType.usb, // Or PrinterType.network if LAN printer
  //   bytes: beepCmd,
  // );
  // await PrinterManager.instance.disconnect(
  //     type: Get.find<AuthController>().profileModel!.isLANPrint == 'Yes'
  //         ? PrinterType.network
  //         : PrinterType.usb);
}
