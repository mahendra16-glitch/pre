import 'dart:async';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class UsbGetPrinterIp extends StatefulWidget {
  const UsbGetPrinterIp({Key? key}) : super(key: key);

  @override
  State<UsbGetPrinterIp> createState() => _UsbGetPrinterIpState();
}

class _UsbGetPrinterIpState extends State<UsbGetPrinterIp> {
  String _info = "";
  String _msj = '';
  BluetoothPrinter? selectedDevice;
  bool connected = false;
  List<BluetoothPrinter> devices = [];
  final PrinterManager printerManager = PrinterManager.instance;

  final List<String> _options = [
    "permission bluetooth granted",
    "bluetooth enabled",
    "connection status",
    "update info"
  ];

  String _selectSize = "2";
  final TextEditingController _txtText =
      TextEditingController(text: "Hello developer");
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  final List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: Get.height / 10.72,
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
            icon: Image.asset(Images.ic_arrow_back, height: 20),
            color: ColorTheme.appColor,
            onPressed: () async {
              if (connected) {
                await PrintBluetoothThermal.disconnect;
                Get.back();
              } else {
                Get.back();
              }
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            SizedBox(
              height: 60,
              child: Image.asset(logoHelper.appLogo!,
                  height: ResponsiveHelper.isMobile(context)
                      ? Get.width * 0.5
                      : 50),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Type print"),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: optionprinttype,
                    items: options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          optionprinttype = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getBluetoots();
                    },
                    child: Row(
                      children: const [
                        SizedBox(width: 5),
                        Text("Search"),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: ListView.builder(
                  itemCount: devices.isNotEmpty ? devices.length : 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                    'Name: ${devices[index].deviceName}',
                                    style: poppinsMedium.copyWith()),
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: SelectableText(
                                      'Product Id: ${devices[index].productId}',
                                      style:
                                          poppinsMedium.copyWith(fontSize: 12)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: SelectableText(
                                      'Vendor Id: ${devices[index].vendorId}',
                                      style:
                                          poppinsMedium.copyWith(fontSize: 12)),
                                ),
                                InkWell(
                                  onTap: () async {
                                    selectedDevice = null;
                                    await printerManager.disconnect(
                                        type: PrinterType.usb);

                                    selectedDevice = devices[index];
                                    await printTest(devices[index]);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: ColorTheme.appColor,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Print',
                                      style: poppinsMedium.copyWith(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "Product Id: ${devices[index].productId}, Vendor Id: ${devices[index].vendorId}"));
                              showErrorToast('Id coppied', isError: false);
                            },
                            child: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    await getBluetoots();
  }

  Future<void> getBluetoots() async {
    setState(() {
      _msjprogress = "Wait";
      devices = [];
    });

    printerManager
        .discovery(type: PrinterType.usb)
        .listen((PrinterDevice device) {
      devices.add(
        BluetoothPrinter(
          deviceName: device.name,
          vendorId: device.vendorId,
          productId: device.productId,
        ),
      );
      if (mounted) setState(() {});
    });

    _msj = "Touch an item in the list to connect";
  }

  Future<void> connect(BluetoothPrinter mac) async {
    setState(() {
      _msjprogress = "Connecting...";
      connected = false;
    });

    await printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        vendorId: mac.vendorId,
        productId: mac.productId,
      ),
    );
  }

  Future<void> printTest(BluetoothPrinter device) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.reset();

    bytes += generator.text('MyGenie',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    bytes += generator.feed(2);
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Name : ${selectedDevice?.deviceName ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Product Id : ${selectedDevice?.productId ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Vendor Id : ${selectedDevice?.vendorId ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.cut();

    var result = await printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        vendorId: device.vendorId,
        productId: device.productId,
      ),
    );

    if (result == true) {
      var sendResult = await printerManager.send(
        type: PrinterType.usb,
        bytes: bytes,
      );

      if (sendResult == true) {
        print('Data sent successfully to printer');
      } else {
        print('Failed to send data to printer: $sendResult');
      }
    } else {
      print('Failed to connect to printer: $result');
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.reset();

    bytes += generator.text('MyGenie',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    bytes += generator.feed(2);
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Name : ${selectedDevice?.deviceName ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Product Id : ${selectedDevice?.productId ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Printer Vendor Id : ${selectedDevice?.vendorId ?? ""}',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.cut();
    return bytes;
  }
}
