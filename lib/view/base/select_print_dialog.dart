import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/util/beep.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import '../../data/model/response/get_collect_bill_resoonse_model.dart';

class PrintDialog extends StatefulWidget {
  final int index;
  final bool isBillPrint;
  final GetCollectBillDetailResponse? collectBillResponse;
  final List<List<OrderDetails>> cartProductList;

  const PrintDialog({
    Key? key,
    required this.index,
    required this.cartProductList,
    this.isBillPrint = false,
    this.collectBillResponse,
  }) : super(key: key);

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  int currentPrintIndex = 0;
  PrinterManager _printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int> pendingTask = [];
  // int printedTotal = 0;
  List<bool> isSelectPrinterList = [];
  List<bool> isPrinterProccessingList = [];
  List<bool> isPrintedList = [];
  List<String> selectedPrintList = [];
  List<String> kotPrinterNameList = [];

  double showServiceChargeValue = 0;
  double tipAmount = 0;
  double discountedOrderSubTotal = 0;
  double serviceChargePercentage = 0;
  double orderSubTotal = 0;
  double orderItemTotal = 0;
  double gstAmount = 0;
  double vatAmount = 0;
  double orderDiscount = 0;
  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  double gstServiceChargeTax = 0;
  bool isProcessing = false;
  // bool isBarPrinted = false;
  // bool isKitchenPrinted = false;
  bool isConnect = true;

  @override
  void initState() {
    for (var i = 0; i < widget.cartProductList.length; i++) {
      isSelectPrinterList.add(false);
      isPrintedList.add(false);
      isPrinterProccessingList.add(false);
      // if (widget.cartProductList[i].isNotEmpty) {
      //   printedTotal = printedTotal + 1;
      // }
    }
    if (widget.isBillPrint) {
      isSelectPrinterList.add(false);
      isPrintedList.add(false);
      isPrinterProccessingList.add(false);
    }

    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) {
        log(' ----------------- DIALOG status bt $status ------------------ ');
        if (status == BTStatus.connecting) {
          isProcessing = true;
          isPrinterProccessingList[currentPrintIndex] = true;
          if (mounted) setState(() {});
        }
        if (status == BTStatus.connected) {
          isConnect = true;
          isPrinterProccessingList[currentPrintIndex] = false;
          isProcessing = false;
          if (mounted) setState(() {});
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              // PrinterManager.instance
              //     .send(type: PrinterType.bluetooth, bytes: pendingTask);
              pendingTask = [];
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask);
            pendingTask = [];
          }
        } else if (status == BTStatus.none) {
          if (!isConnect) {
            Future.delayed(Duration(seconds: 1), () async {
              isConnect = true;
              isPrinterProccessingList[currentPrintIndex] = false;

              print('************');
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck();
            });
          } else {
            isConnect = false;
            isProcessing = false;
            isPrinterProccessingList[currentPrintIndex] = false;
            if (mounted) setState(() {});
            print('%%%%%%%%%');
          }
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _subscriptionBtStatus?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select option for print',
                      textAlign: TextAlign.center,
                      style: poppinsMedium.copyWith(
                          fontSize: MediaQuery.of(context).size.width > 1600
                              ? 20
                              : 18,
                          color: Colors.black),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(Icons.close,
                          color: ColorTheme.appColor, size: 35),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // CheckboxListTile(
                //   contentPadding: EdgeInsets.symmetric(vertical: 0),

                //   title: Text('Kitchen', style: poppinsRegular.copyWith()),
                //   value: isPrintKitchen,
                //   onChanged: (newValue) {
                //     isPrintKitchen = newValue;
                //     setState(() {});
                //   },
                //   controlAffinity: ListTileControlAffinity
                //       .leading, //  <-- leading Checkbox
                // ),
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.isBillPrint
                        ? (widget.cartProductList.length + 1)
                        : widget.cartProductList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return index != widget.cartProductList.length &&
                              widget.cartProductList[index].isEmpty
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  isSelectPrinterList[index] =
                                      !isSelectPrinterList[index];
                                  if (widget.isBillPrint &&
                                      index == widget.cartProductList.length) {
                                    if (isSelectPrinterList[index]) {
                                      selectedPrintList.add('bill');
                                    } else {
                                      selectedPrintList.remove('bill');
                                    }
                                  } else {
                                    if (isSelectPrinterList[index]) {
                                      selectedPrintList.add('kot');
                                      kotPrinterNameList.add((Get.find<
                                                      AuthController>()
                                                  .profileModel!
                                                  .restaurantPrinterNew![index]
                                                  .areaName ??
                                              '')
                                          .toUpperCase());
                                    } else {
                                      selectedPrintList.remove('kot');
                                      kotPrinterNameList.remove((Get.find<
                                                      AuthController>()
                                                  .profileModel!
                                                  .restaurantPrinterNew![index]
                                                  .areaName ??
                                              '')
                                          .toUpperCase());
                                    }
                                  }
                                  // isPrintKitchen = !isPrintKitchen;
                                  setState(() {});
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.width >
                                                  1600
                                              ? 70
                                              : 30,
                                      child: Checkbox(
                                        activeColor: ColorTheme.appColor,
                                        value: isSelectPrinterList[index],
                                        onChanged: (bool? isChecked) {
                                          isSelectPrinterList[index] =
                                              isChecked ?? false;
                                          if (widget.isBillPrint &&
                                              index ==
                                                  widget
                                                      .cartProductList.length) {
                                            if (isSelectPrinterList[index]) {
                                              selectedPrintList.add('bill');
                                            } else {
                                              selectedPrintList.remove('bill');
                                            }
                                          } else {
                                            if (isSelectPrinterList[index]) {
                                              selectedPrintList.add('kot');
                                              kotPrinterNameList.add((Get.find<
                                                              AuthController>()
                                                          .profileModel!
                                                          .restaurantPrinterNew![
                                                              index]
                                                          .areaName ??
                                                      '')
                                                  .toUpperCase());
                                            } else {
                                              selectedPrintList.remove('kot');
                                              kotPrinterNameList.remove((Get.find<
                                                              AuthController>()
                                                          .profileModel!
                                                          .restaurantPrinterNew![
                                                              index]
                                                          .areaName ??
                                                      '')
                                                  .toUpperCase());
                                            }
                                          }
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            widget.isBillPrint &&
                                                    index ==
                                                        widget.cartProductList
                                                            .length
                                                ? 'Bill'
                                                : (Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurantPrinterNew![
                                                            index]
                                                        .areaName ??
                                                    ''),
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 17
                                                    : 14)),
                                        Text(
                                            isPrinterProccessingList[index]
                                                ? 'Status: Proccessing'
                                                : isPrintedList[index]
                                                    ? 'Status: Printed'
                                                    : 'Status: Not Printed',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 15
                                                    : 10,
                                                color: ColorTheme.blue
                                                // color: isPrintedList[index]
                                                //     ? ColorTheme.green
                                                //     : Colors.red

                                                )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }),

                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                InkWell(
                  onTap: () async {
                    if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .printingOption ==
                            'Fixed' &&
                        Get.find<AuthController>().profileModel?.defaultUser !=
                            'Yes') {
                      callApiFixedStation(Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![widget.index]
                          .id!);
                    } else {
                      if (GetPlatform.isWindows) {
                        currentPrintIndex = 0;
                        windowsDataCheck();
                      } else {
                        if (!isProcessing) {
                          currentPrintIndex = 0;
                          dataCheck();
                        }
                      }
                    }
                  },
                  child: SvgPicture.asset(
                    Images.ic_print_kot,
                    height: 26,
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                  //       vertical: Dimensions.PADDING_SIZE_SMALL),
                  //   decoration: BoxDecoration(
                  //       color: ColorTheme.appColor,
                  //       borderRadius:
                  //           BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                  //   child: Text(
                  //     isProcessing ? 'Processing' : 'Print',
                  //     style: poppinsMedium.copyWith(
                  //         fontSize: MediaQuery.of(context).size.width > 1600
                  //             ? 19
                  //             : Dimensions.FONT_SIZE_LARGE,
                  //         color: Colors.white),
                  //   ),
                  // ),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }

  // Future iosPrintEscPos(List<int> bytes) async {
  //   print('########## bytes length ${bytes.length}');
  //   // bytes += generator.feed(2);
  //   // bytes += generator.cut();

  //   // await PrintBluetoothThermal.pairedBluetooths;

  //   // Future.delayed(Duration(seconds: 5), () async {
  //   isPrinterProccessingList[currentPrintIndex] = true;
  //   setState(() {});

  //   final bool result = await PrintBluetoothThermal.connect(
  //       macPrinterAddress: widget.isBillPrint &&
  //               isSelectPrinterList[currentPrintIndex] &&
  //               currentPrintIndex == widget.cartProductList.length
  //           ? (Get.find<AuthController>().profileModel?.macBillPrinterIp ?? '')
  //           : (Get.find<AuthController>().profileModel?.restaurantPrinterNew !=
  //                       null &&
  //                   Get.find<AuthController>()
  //                           .profileModel!
  //                           .restaurantPrinterNew!
  //                           .length >
  //                       currentPrintIndex
  //               ? (Get.find<AuthController>()
  //                       .profileModel!
  //                       .restaurantPrinterNew![currentPrintIndex]
  //                       .macPrinterIp ??
  //                   '')
  //               : ''));
  //   Future.delayed(Duration(seconds: 4), () async {
  //     if (result) {
  //       await PrintBluetoothThermal.writeBytes(bytes);
  //       Future.delayed(
  //           Duration(
  //               seconds: bytes.length <= 5850
  //                   ? 2
  //                   : bytes.length <= 7890
  //                       ? 3
  //                       : bytes.length <= 10195
  //                           ? 6
  //                           : bytes.length <= 13100
  //                               ? 10
  //                               : bytes.length <= 21150
  //                                   ? 15
  //                                   : 20), () async {
  //         isPrinterProccessingList[currentPrintIndex] = false;
  //         isPrintedList[currentPrintIndex] = true;

  //         setState(() {});
  //         bytes = [];
  //         var isDisconnect = await PrintBluetoothThermal.disconnect;
  //         print('is disconnect $isDisconnect');
  //         currentPrintIndex = currentPrintIndex + 1;
  //         dataCheck();
  //       });
  //       print("print test result:  $result");
  //     } else {
  //       isPrinterProccessingList[currentPrintIndex] = false;
  //       setState(() {});

  //       //no conectado, reconecte
  //       // showCustomSnackBar('Failed to bluetooth connect');
  //       showErrorToast(
  //           '${Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].areaName} kot failed');

  //       currentPrintIndex = currentPrintIndex + 1;
  //       dataCheck();
  //     }
  //   });
  //   // });
  // }

  Future iosPrintEscPos(List<int> bytes, int paperSize) async {
    print('########## bytes length ${bytes.length}');
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');
    bool isBill = widget.isBillPrint &&
        currentPrintIndex == widget.cartProductList.length &&
        isSelectPrinterList[currentPrintIndex];
    isPrinterProccessingList[currentPrintIndex] = true;
    setState(() {});

    final String macAddress = widget.isBillPrint &&
            isSelectPrinterList[currentPrintIndex] &&
            currentPrintIndex == widget.cartProductList.length
        ? (Get.find<AuthController>().profileModel?.macBillPrinterIp ?? '')
        : (Get.find<AuthController>().profileModel?.restaurantPrinterNew !=
                    null &&
                Get.find<AuthController>()
                        .profileModel!
                        .restaurantPrinterNew!
                        .length >
                    currentPrintIndex
            ? (Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew![currentPrintIndex]
                    .macPrinterIp ??
                '')
            : '');

    final bool result = await IosPrintTransport.connect(wifiPrinter: (widget.isBillPrint && isSelectPrinterList[currentPrintIndex] && currentPrintIndex == widget.cartProductList.length) ? NetworkPrinterResolver.billPrinter() : NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
      macPrinterAddress: macAddress,
    );

    // Important delay after connect (iPad)
    await Future.delayed(const Duration(seconds: 4));

    if (!result) {
      isPrinterProccessingList[currentPrintIndex] = false;
      setState(() {});

      showErrorToast(
        '${Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].areaName} kot failed',
      );

      currentPrintIndex++;
      dataCheck();
      return;
    }

    try {
      // Send bytes — chunked for 80mm iPad, direct for 58mm / phone
      if (paperSize == 58 || MediaQuery.of(context).size.shortestSide < 570) {
        await IosPrintTransport.writeBytes(bytes);
      } else {
        await _writeBytesForIPad(bytes);
      }

      // Multiple copies
      if (numberOfPrint > 1) {
        for (int i = 1; i < numberOfPrint; i++) {
          await Future.delayed(Duration(
              seconds: bytes.length <= 5850
                  ? 2
                  : bytes.length <= 7890
                      ? 3
                      : bytes.length <= 10195
                          ? 6
                          : bytes.length <= 13100
                              ? 10
                              : bytes.length <= 21150
                                  ? 15
                                  : 20));
          Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
              ? await IosPrintTransport.writeBytes(bytes)
              : await _writeBytesForIPad(bytes);
        }
      }

      // ✅ FIX 1: properly AWAIT the buffer flush delay so we don't
      // disconnect while the printer is still processing bytes.
      await Future.delayed(Duration(
          seconds: bytes.length <= 5850
              ? 2
              : bytes.length <= 7890
                  ? 3
                  : bytes.length <= 10195
                      ? 6
                      : bytes.length <= 13100
                          ? 10
                          : bytes.length <= 21150
                              ? 15
                              : 20));

      isPrinterProccessingList[currentPrintIndex] = false;
      isPrintedList[currentPrintIndex] = true;
      setState(() {});
    } catch (e) {
      print('Print error: $e');
      isPrinterProccessingList[currentPrintIndex] = false;
      setState(() {});
      showErrorToast(
        '${Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].areaName} kot failed',
      );
    } finally {
      // ✅ FIX 2: disconnect FIRST, then clear bytes.
      // Previously bytes.clear() ran before disconnect, leaving the printer
      // mid-stream on large bills. Also previously disconnect ran immediately
      // without waiting for the flush delay above, cutting the connection early.
      await IosPrintTransport.disconnect;
      bytes.clear();

      currentPrintIndex++;
      dataCheck();
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 180; // iPad safe
    const int delayMs = 60;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }

  Future printEscPos(List<int> bytes) async {
    // bytes += generator.cut();
    // print(Get.find<AuthController>().profileModel!.billPrinterType);
    bool isBill = widget.isBillPrint &&
        currentPrintIndex == widget.cartProductList.length &&
        isSelectPrinterList[currentPrintIndex];
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        productId: isBill
            ? Get.find<AuthController>().profileModel!.billProductId
            : Get.find<AuthController>()
                .profileModel!
                .restaurantPrinterNew![currentPrintIndex]
                .productId,
        vendorId: isBill
            ? Get.find<AuthController>().profileModel!.billVendorId
            : Get.find<AuthController>()
                .profileModel!
                .restaurantPrinterNew![currentPrintIndex]
                .vendorId,
        port: '9100',
        typePrinter: !isBill &&
                Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerName!.toLowerCase() ==
                    'usb'
            ? PrinterType.usb
            : isBill &&
                    ((Get.find<AuthController>().profileModel!.billPrinterType ?? '').toLowerCase() ==
                        'usb')
                ? PrinterType.usb
                : isBill &&
                        ((Get.find<AuthController>().profileModel!.billPrinterType ?? '').toLowerCase() ==
                            'wifi')
                    ? PrinterType.network
                    : isBill &&
                            ((Get.find<AuthController>().profileModel!.billPrinterType ?? '').toLowerCase() ==
                                'bluetooth')
                        ? PrinterType.bluetooth
                        : Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerName!.toLowerCase() ==
                                'wifi'
                            ? PrinterType.network
                            : PrinterType.bluetooth,
        address: widget.isBillPrint &&
                isSelectPrinterList[currentPrintIndex] &&
                currentPrintIndex == widget.cartProductList.length
            ? (Get.find<AuthController>().profileModel!.billPrinterType ?? '').toLowerCase() ==
                    'wifi'
                ? Get.find<AuthController>().profileModel!.billWifiIp
                : Get.find<AuthController>().profileModel!.billPrinterIp
            : Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerName!.toLowerCase() ==
                    'wifi'
                ? Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew![currentPrintIndex]
                    .wifiPrinterIp
                : Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew![currentPrintIndex]
                    .printerIp,
        deviceName:
            widget.isBillPrint && isSelectPrinterList[currentPrintIndex] && currentPrintIndex == widget.cartProductList.length
                ? Get.find<AuthController>().profileModel!.billPrinterName
                : Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerName); //device name or ip was mandadory

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address ?? '',
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = [];
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address ?? ''),
        );
        break;
      default:
    }
    try {
      await _printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      if (isBill && numberOfPrint > 1) {
        for (int i = 1; i < numberOfPrint; i++) {
          await Future.delayed(Duration(
              seconds: bytes.length <= 5850
                  ? 1
                  : bytes.length <= 7890
                      ? 2
                      : bytes.length <= 10195
                          ? 5
                          : bytes.length <= 13100
                              ? 10
                              : bytes.length <= 21150
                                  ? 15
                                  : 20));
          await _printerManager.send(
              type: bluetoothPrinter.typePrinter, bytes: bytes);
        }
      }
      isPrintedList[currentPrintIndex] = true; //It show status of start print
      isPrinterProccessingList[currentPrintIndex] = false;
      isProcessing = false;
      if (mounted) setState(() {});
      Future.delayed(
          Duration(
              seconds: bytes.length <= 5850
                  ? 1
                  : bytes.length <= 7890
                      ? 2
                      : bytes.length <= 10195
                          ? 5
                          : bytes.length <= 13100
                              ? 10
                              : bytes.length <= 21150
                                  ? 15
                                  : 20), () async {
        bytes = [];
        await PrinterManager.instance
            .disconnect(type: bluetoothPrinter.typePrinter);

        currentPrintIndex = currentPrintIndex + 1;
        dataCheck();
      });
    } catch (e) {}
  }

  dataCheck() async {
    try {
      if (widget.isBillPrint &&
          currentPrintIndex == widget.cartProductList.length &&
          isSelectPrinterList[currentPrintIndex]) {
        prepaidOrderCalculate();

        // await billByteConvert();
        if (Platform.isIOS) {
          await iosPrintEscPos(
              await PrintByteConvert().byteConvert(
                printType: 'bill',
                couponCode:
                    '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponCode ?? ''}',
                couponDiscount: double.tryParse(
                        '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponDiscountAmount ?? 0}') ??
                    0,
                loyaltyUsed: widget.collectBillResponse?.orders
                        ?.orderDetailsOrder?.loyaltyPoints ??
                    0,
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
                // subTotalWithoutTax: (orderSubTotal +
                //     (widget.collectBillResponse?.orders?.orderDetailsOrder
                //             ?.deliveryCharge ??
                //         0)),
                subTotalWithoutTax: (orderSubTotal),
                orderId: widget.collectBillResponse!.orders!.orderDetailsOrder!
                    .restaurantOrderId!,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(widget.collectBillResponse?.orders?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                waiterName:
                    '${widget.collectBillResponse?.orders?.restaurantDetails?.waiterName ?? ''}',
                tablename: (widget.collectBillResponse?.orders
                                ?.restaurantDetails?.tableNo ??
                            '') ==
                        ''
                    ? (widget.collectBillResponse?.orders?.orderDetailsOrder
                                    ?.orderType ??
                                '') ==
                            'delivery'
                        ? 'Delivery'
                        : (widget.collectBillResponse?.orders?.orderDetailsOrder
                                        ?.orderType ??
                                    '') ==
                                'take_away'
                            ? 'Take Away'
                            : 'WC'
                    : (widget.collectBillResponse?.orders?.restaurantDetails
                                    ?.tableArea ??
                                '') ==
                            ''
                        ? '${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}'
                        : '${widget.collectBillResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                custName: widget.collectBillResponse?.orders?.orderDetailsOrder
                        ?.username ??
                    '',
                custPhone:
                    '${widget.collectBillResponse?.orders?.orderUser?.phone ?? ''}',
                billFoodList:
                    widget.collectBillResponse?.orders?.mergeFoodListWithDate ??
                        [],
                orderNote: widget.collectBillResponse?.orders?.orderDetailsOrder
                        ?.orderNote ??
                    '',
                orderSubTotal: orderItemTotal,
                discount: orderDiscount,
                serviceChargeAmount: showServiceChargeValue,
                deliveryCharge: widget.collectBillResponse?.orders
                        ?.orderDetailsOrder?.deliveryCharge ??
                    0,
                gstAmount: gstAmount + gstServiceChargeTax,
                vatAmount: vatAmount,
                grandTotal: Get.find<PosController>().collectItemPrice,
                deliveryCustName:
                    widget.collectBillResponse?.orders?.deliveryAddress?.name ??
                        '',
                deliveryCustPhone: widget
                        .collectBillResponse?.orders?.deliveryAddress?.phone ??
                    '',
                deliveryAddressType: widget.collectBillResponse?.orders
                        ?.deliveryAddress?.addressType ??
                    '',
                deliveryCustAddress: widget.collectBillResponse?.orders
                        ?.deliveryAddress?.address ??
                    '',
                deliveryCustPincode: widget.collectBillResponse?.orders
                        ?.deliveryAddress?.pincode ??
                    '',
                tips: tipAmount,
                orderType: widget.collectBillResponse?.orders?.orderDetailsOrder
                        ?.orderType ??
                    '',
              ),
              Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80);
        } else {
          await printEscPos(await PrintByteConvert().byteConvert(
              printType: 'bill',
              couponCode:
                  '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponCode ?? ''}',
              couponDiscount: double.tryParse(
                      '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponDiscountAmount ?? 0}') ??
                  0,
              loyaltyUsed: widget.collectBillResponse?.orders
                      ?.orderDetailsOrder?.loyaltyPoints ??
                  0,
              // subTotalWithoutTax: (orderSubTotal +
              //     (widget.collectBillResponse?.orders?.orderDetailsOrder
              //             ?.deliveryCharge ??
              //         0)),
              subTotalWithoutTax: (orderSubTotal),
              paperRoll: (Get.find<AuthController>().profileModel?.billPrinterPaperRoll ?? 58) == 58
                  ? 58
                  : 80,
              orderId: widget.collectBillResponse?.orders?.orderDetailsOrder
                      ?.restaurantOrderId ??
                  '',
              date:
                  '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(widget.collectBillResponse?.orders?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
              waiterName:
                  '${widget.collectBillResponse?.orders?.restaurantDetails?.waiterName ?? ''}',
              tablename: (widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? '') ==
                      ''
                  ? (widget.collectBillResponse?.orders?.orderDetailsOrder?.orderType ?? '') ==
                          'delivery'
                      ? 'Delivery'
                      : (widget.collectBillResponse?.orders?.orderDetailsOrder
                                      ?.orderType ??
                                  '') ==
                              'take_away'
                          ? 'Take Away'
                          : 'WC'
                  : (widget.collectBillResponse?.orders?.restaurantDetails?.tableArea ?? '') ==
                          ''
                      ? '${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}'
                      : '${widget.collectBillResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
              custName: widget.collectBillResponse?.orders?.orderDetailsOrder
                      ?.username ??
                  '',
              custPhone:
                  '${widget.collectBillResponse?.orders?.orderUser?.phone ?? ''}',
              billFoodList:
                  widget.collectBillResponse?.orders?.mergeFoodListWithDate ??
                      [],
              orderNote: widget.collectBillResponse?.orders?.orderDetailsOrder
                      ?.orderNote ??
                  '',
              orderSubTotal: orderItemTotal,
              discount: orderDiscount,
              serviceChargeAmount: showServiceChargeValue,
              deliveryCharge: widget.collectBillResponse?.orders
                      ?.orderDetailsOrder?.deliveryCharge ??
                  0,
              gstAmount: gstAmount + gstServiceChargeTax,
              vatAmount: vatAmount,
              grandTotal: Get.find<PosController>().collectItemPrice,
              deliveryCustName:
                  widget.collectBillResponse?.orders?.deliveryAddress?.name ?? '',
              deliveryCustPhone: widget.collectBillResponse?.orders?.deliveryAddress?.phone ?? '',
              deliveryAddressType: widget.collectBillResponse?.orders?.deliveryAddress?.addressType ?? '',
              deliveryCustAddress: widget.collectBillResponse?.orders?.deliveryAddress?.address ?? '',
              deliveryCustPincode: widget.collectBillResponse?.orders?.deliveryAddress?.pincode ?? "",
              tips: tipAmount,
              orderType: widget.collectBillResponse?.orders?.orderDetailsOrder?.orderType ?? ''));
        }
      } else if (currentPrintIndex <= widget.cartProductList.length - 1) {
        if (widget.cartProductList[currentPrintIndex].isEmpty ||
            isSelectPrinterList[currentPrintIndex] == false) {
          for (var i = currentPrintIndex;
              i < widget.cartProductList.length;
              i++) {
            if (widget.cartProductList[i].isEmpty ||
                isSelectPrinterList[currentPrintIndex] == false) {
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck();
              break;
            } else {
              // bytesConvert();
              if (Platform.isIOS) {
                await iosPrintEscPos(
                    await PrintByteConvert().byteConvert(
                        printType: 'kot',
                        printTitle: Get.find<AuthController>()
                                    .profileModel!
                                    .restaurantPrinterNew![currentPrintIndex]
                                    .areaName!
                                    .toUpperCase() ==
                                'MASTER_KOT'
                            ? 'Master Duplicate KOT'
                            : 'Duplicate KOT',
                        orderType: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].orderType ??
                            '',
                        stationName:
                            widget.cartProductList[currentPrintIndex].first.station ??
                                '',
                        paperRoll: Get.find<AuthController>()
                                    .profileModel
                                    ?.restaurantPrinterNew?[currentPrintIndex]
                                    .printerPaperRoll ==
                                58
                            ? 58
                            : 80,
                        orderId: Get.find<KdsController>()
                                .getWaiterOrderListResponse
                                ?.orders?[widget.index]
                                .restaurantOrderId ??
                            '',
                        date:
                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.now())}',
                        waiterName:
                            '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].vendorEmployee?.waiterName ?? ''}',
                        tablename: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable == null ||
                                Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo == ''
                            ? Get.find<KdsController>().getWaiterOrderListResponse?.orders![widget.index].orderType == 'delivery'
                                ? 'Delivery'
                                : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType == 'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.title == ''
                                ? '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo ?? ''}'
                                : '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.title ?? ''}-${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo ?? ''}',
                        custName: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].userName ?? '',
                        custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].user?.phone ?? ''}',
                        kotOrderList: widget.cartProductList[currentPrintIndex],
                        orderNote: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].orderNote ?? ''),
                    Get.find<AuthController>().profileModel?.restaurantPrinterNew?[currentPrintIndex].printerPaperRoll == 58 ? 58 : 80);
              } else {
                await printEscPos(await PrintByteConvert().byteConvert(
                    printType: 'kot',
                    printTitle: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .areaName!
                                .toUpperCase() ==
                            'MASTER_KOT'
                        ? 'Master Duplicate KOT'
                        : 'Duplicate KOT',
                    orderType: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].orderType ??
                        '',
                    stationName: widget.cartProductList[currentPrintIndex].first.station ??
                        '',
                    paperRoll: Get.find<AuthController>()
                                .profileModel
                                ?.restaurantPrinterNew?[currentPrintIndex]
                                .printerPaperRoll ==
                            58
                        ? 58
                        : 80,
                    orderId: Get.find<KdsController>()
                            .getWaiterOrderListResponse
                            ?.orders?[widget.index]
                            .restaurantOrderId ??
                        '',
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.now())}',
                    waiterName:
                        '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].vendorEmployee?.waiterName ?? ''}',
                    tablename: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable == null ||
                            Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo == ''
                        ? Get.find<KdsController>().getWaiterOrderListResponse?.orders![widget.index].orderType == 'delivery'
                            ? 'Delivery'
                            : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.title == ''
                            ? '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo ?? ''}'
                            : '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.title ?? ''}-${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].restaurantTable?.tableNo ?? ''}',
                    custName: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].userName ?? '',
                    custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].user?.phone ?? ''}',
                    kotOrderList: widget.cartProductList[currentPrintIndex],
                    orderNote: Get.find<KdsController>().getWaiterOrderListResponse?.orders?[widget.index].orderNote ?? ''));
              }
              break;
            }
          }
        } else {
          // bytesConvert();
          if (Platform.isIOS) {
            await iosPrintEscPos(
                await PrintByteConvert().byteConvert(
                    printType: 'kot',
                    printTitle: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .areaName!
                                .toUpperCase() ==
                            'MASTER_KOT'
                        ? 'Master Duplicate KOT'
                        : 'Duplicate KOT',
                    orderType: Get.find<KdsController>()
                        .getWaiterOrderListResponse!
                        .orders![widget.index]
                        .orderType!,
                    paperRoll: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .printerPaperRoll ==
                            58
                        ? 58
                        : 80,
                    stationName: widget
                        .cartProductList[currentPrintIndex].first.station!,
                    orderId: Get.find<KdsController>()
                        .getWaiterOrderListResponse!
                        .orders![widget.index]
                        .restaurantOrderId!,
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                    waiterName:
                        '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].vendorEmployee!.waiterName}',
                    tablename: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable == null ||
                            Get.find<KdsController>()
                                    .getWaiterOrderListResponse!
                                    .orders![widget.index]
                                    .restaurantTable!
                                    .tableNo ==
                                ''
                        ? Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType ==
                                'delivery'
                            ? 'Delivery'
                            : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title == ''
                            ? '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}'
                            : '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title}-${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}',
                    custName: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].userName ?? '',
                    custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].user?.phone ?? ''}',
                    kotOrderList: widget.cartProductList[currentPrintIndex] ?? [],
                    orderNote: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderNote ?? ''),
                Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerPaperRoll == 58 ? 58 : 80);
          } else {
            await printEscPos(await PrintByteConvert().byteConvert(
                printType: 'kot',
                printTitle: Get.find<AuthController>()
                            .profileModel!
                            .restaurantPrinterNew![currentPrintIndex]
                            .areaName!
                            .toUpperCase() ==
                        'MASTER_KOT'
                    ? 'Master Duplicate KOT'
                    : 'Duplicate KOT',
                orderType: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![widget.index]
                    .orderType!,
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .restaurantPrinterNew![currentPrintIndex]
                            .printerPaperRoll ==
                        58
                    ? 58
                    : 80,
                stationName:
                    widget.cartProductList[currentPrintIndex].first.station!,
                orderId: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![widget.index]
                    .restaurantOrderId!,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                waiterName:
                    '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].vendorEmployee!.waiterName}',
                tablename: Get.find<KdsController>()
                                .getWaiterOrderListResponse!
                                .orders![widget.index]
                                .restaurantTable ==
                            null ||
                        Get.find<KdsController>()
                                .getWaiterOrderListResponse!
                                .orders![widget.index]
                                .restaurantTable!
                                .tableNo ==
                            ''
                    ? Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType == 'delivery'
                        ? 'Delivery'
                        : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderType == 'take_away'
                            ? 'Take Away'
                            : 'WC'
                    : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title == ''
                        ? '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}'
                        : '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title}-${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}',
                custName: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].userName ?? '',
                custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].user?.phone ?? ''}',
                kotOrderList: widget.cartProductList[currentPrintIndex] ?? [],
                orderNote: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderNote ?? ''));
          }
        }
      }
    } catch (e) {}
  }

  // amountCalculation() {
  //   serviceChargePercentage = Get.find<AuthController>()
  //           .profileModel
  //           ?.restaurants
  //           ?.first
  //           .serviceChargePercentage ??
  //       0;
  //   if (Get.find<PosController>()
  //               .getCollectBillDetailResponse!
  //               .orders
  //               ?.orderDetailsOrder
  //               ?.orderType ==
  //           'delivery' ||
  //       Get.find<PosController>()
  //               .getCollectBillDetailResponse!
  //               .orders
  //               ?.orderDetailsOrder
  //               ?.orderType ==
  //           'take_away') serviceChargePercentage = 0;

  //   bool isAddServiceCharge = (Get.find<PosController>()
  //                   .getCollectBillDetailResponse!
  //                   .orders
  //                   ?.orderDetailsOrder
  //                   ?.orderType !=
  //               'delivery' &&
  //           Get.find<PosController>()
  //                   .getCollectBillDetailResponse!
  //                   .orders
  //                   ?.orderDetailsOrder
  //                   ?.orderType !=
  //               'take_away' &&
  //           Get.find<AuthController>()
  //                   .profileModel
  //                   ?.restaurants
  //                   ?.first
  //                   .serviceCharge ==
  //               'Yes' &&
  //           Get.find<AuthController>()
  //                   .profileModel
  //                   ?.restaurants
  //                   ?.first
  //                   .autoServiceCharge ==
  //               'Yes')
  //       ? true
  //       : false;
  //   orderItemTotal = 0;
  //   orderSubTotal = 0;

  //   discountedOrderSubTotal = 0;
  //   orderDiscount = 0;
  //   gstAmount = 0;
  //   vatAmount = 0;
  //   showServiceChargeValue = 0;
  //   gstServiceChargeTax = 0;
  //   profile.Restaurant restaurant =
  //       Get.find<AuthController>().profileModel?.restaurants?.first ??
  //           profile.Restaurant();

  //   final billDetailResponse =
  //       Get.find<PosController>().getSimpleCollectBillDetail;
  //   final orders = billDetailResponse?.orders;
  //   List<OrderDetailsBar> mergeFoodList = [];
  //   mergeFoodList.addAll(orders?.orderDetailsFood ?? []);
  //   mergeFoodList.addAll(orders?.orderDetailsBar ?? []);
  //   for (var i = 0; i < mergeFoodList.length; i++) {
  //     if (mergeFoodList[i].foodStatus != 3) {
  //       OrderDetailsBar food = mergeFoodList[i];

  //       double variationTotal = 0;
  //       double addonsTotal = 0;
  //       double foodAmount = 0;
  //       double halfVariationPrice = 0;

  //       if (food.variation != null && food.variation!.isNotEmpty) {
  //         for (int j = 0; j < food.variation!.length; j++) {
  //           final variation = food.variation![j];
  //           if (variation.values != null) {
  //             for (var element in variation.values!) {
  //               if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
  //                 if (halfVariationPrice <
  //                     double.parse(element.optionPrice ?? '0') *
  //                         (food.quantity ?? 0)) {
  //                   halfVariationPrice =
  //                       double.parse(element.optionPrice ?? '0') *
  //                           (food.quantity ?? 0);
  //                 }
  //               } else {
  //                 variationTotal = variationTotal +
  //                     double.parse(element.optionPrice ?? '0') *
  //                         (food.quantity ?? 0);
  //               }
  //             }
  //           }
  //           variationTotal = variationTotal + halfVariationPrice;
  //         }
  //       }

  //       if (food.addOns != null) {
  //         for (var i = 0; i < food.addOns!.length; i++) {
  //           final addOn = food.addOns![i];
  //           addonsTotal = addonsTotal +
  //               (((addOn.price ?? 0) * (addOn.quantity ?? 0)) *
  //                   (food.quantity ?? 0));
  //         }
  //       }
  //       if (food.foodDetails!['name'].toString().toLowerCase() != 'check in') {
  //         orderItemTotal = twoDecimal(orderItemTotal +
  //             (food.unitPrice ?? 0) * (food.quantity ?? 0) +
  //             variationTotal +
  //             addonsTotal);
  //         foodAmount = twoDecimal((food.unitPrice ?? 0) * (food.quantity ?? 0) +
  //             variationTotal +
  //             addonsTotal);
  //       }

  //       double tempDiscountPercent = 0;
  //       double tempAmount = 0;
  //       if ((food.foodDetails?['give_discount']?.toString() ?? '') == 'Yes') {
  //         tempAmount = twoDecimal(foodAmount -
  //             (foodAmount *
  //                 (coummunityDiscountPercentage + tempDiscountPercent) /
  //                 100));
  //         orderSubTotal = twoDecimal(tempAmount + orderSubTotal);
  //         orderDiscount = twoDecimal(orderDiscount +
  //             (foodAmount *
  //                 (coummunityDiscountPercentage + tempDiscountPercent) /
  //                 100));
  //       } else {
  //         tempAmount = twoDecimal(foodAmount);
  //         orderSubTotal = twoDecimal(foodAmount + orderSubTotal);
  //       }
  //       if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST') {
  //         if (restaurant.gstStatus == 'true') {
  //           if (isAddServiceCharge) {
  //             gstAmount = twoDecimal(gstAmount +
  //                 (((tempAmount) *
  //                         double.parse(
  //                             food.foodDetails?['tax']?.toString() ?? '0')) /
  //                     100));

  //             showServiceChargeValue = twoDecimal(showServiceChargeValue +
  //                 ((tempAmount * serviceChargePercentage) / 100));
  //           } else {
  //             gstAmount = twoDecimal(gstAmount +
  //                 ((tempAmount *
  //                         double.parse(
  //                             food.foodDetails?['tax']?.toString() ?? '0')) /
  //                     100));
  //           }
  //         } else {
  //           if (isAddServiceCharge) {
  //             showServiceChargeValue = twoDecimal(showServiceChargeValue +
  //                 ((tempAmount * serviceChargePercentage) / 100));
  //           }
  //         }
  //         discountedOrderSubTotal =
  //             twoDecimal(discountedOrderSubTotal + tempAmount);
  //       } else if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'VAT') {
  //         if (Get.find<AuthController>().profileModel?.vatInfo?.status ==
  //             'true') {
  //           if (isAddServiceCharge) {
  //             vatAmount = twoDecimal(vatAmount +
  //                 (((tempAmount) *
  //                         double.parse(
  //                             food.foodDetails?['tax']?.toString() ?? '0')) /
  //                     100));

  //             showServiceChargeValue = twoDecimal(showServiceChargeValue +
  //                 ((tempAmount * serviceChargePercentage) / 100));
  //           } else {
  //             vatAmount = twoDecimal(vatAmount +
  //                 ((tempAmount *
  //                         double.parse(
  //                             food.foodDetails?['tax']?.toString() ?? '0')) /
  //                     100));
  //           }
  //         } else {
  //           if (isAddServiceCharge) {
  //             showServiceChargeValue = twoDecimal(showServiceChargeValue +
  //                 ((tempAmount * serviceChargePercentage) / 100));
  //           }
  //         }
  //         discountedOrderSubTotal =
  //             twoDecimal(discountedOrderSubTotal + tempAmount);
  //       }
  //     }
  //   }

  //   if (discountedOrderSubTotal >= 0) {
  //     if (isAddServiceCharge) {
  //       gstServiceChargeTax = twoDecimal(
  //           ((showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
  //               100));
  //     }
  //     if (Get.find<PosController>()
  //                 .getCollectBillDetailResponse!
  //                 .orders!
  //                 .orderDetailsOrder!
  //                 .deliveryCharge !=
  //             0 &&
  //         restaurant.settings!.gstDeliveryCharge != 0)
  //       gstAmount = twoDecimal(gstAmount +
  //           ((Get.find<PosController>()
  //                       .getCollectBillDetailResponse!
  //                       .orders!
  //                       .orderDetailsOrder!
  //                       .deliveryCharge! *
  //                   restaurant.settings!.gstDeliveryCharge!) /
  //               100));
  //     Get.find<PosController>().setcollectItemPrice(twoDecimal(
  //         ((Get.find<PosController>()
  //                     .getCollectBillDetailResponse
  //                     ?.orders
  //                     ?.roomInfo
  //                     ?.gstTaxAmount) ??
  //                 0) +
  //             gstServiceChargeTax +
  //             discountedOrderSubTotal +
  //             showServiceChargeValue +
  //             gstAmount +
  //             (widget.collectBillResponse?.orders?.orderDetailsOrder
  //                     ?.deliveryCharge ??
  //                 0) +
  //             vatAmount));
  //     // }
  //   } else {
  //     showErrorToast('Please enter valid discount');
  //   }

  //   if (mounted) setState(() {});
  // }

  windowsDataCheck() async {
    try {
      print('Out side bill print on windows');
      if (widget.isBillPrint &&
          currentPrintIndex == widget.cartProductList.length &&
          isSelectPrinterList[currentPrintIndex]) {
        prepaidOrderCalculate();
        int numberOfPrint = int.parse(Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .settings!
                .noOfBillPrint ??
            '1');
        // await billByteConvert();
        final printers = await Printing.listPrinters();

        for (var element in printers) {
          if (element.isAvailable &&
              (element.name.toLowerCase() ==
                  Get.find<AuthController>()
                      .profileModel!
                      .wifiBillPrinterName!
                      .toLowerCase())) {
            for (int i = 0; i < numberOfPrint; i++) {
              await Printing.directPrintPdf(
                  printer: element,
                  onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                        tokenNo: Get.find<KdsController>()
                                .getWaiterOrderListResponse
                                ?.orders?[widget.index]
                                .tokenNo ??
                            '',
                        printType: 'bill',
                        couponCode:
                            '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponCode ?? ''}',
                        couponDiscount: double.tryParse(
                                '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponDiscountAmount ?? 0}') ??
                            0,
                        loyaltyUsed: widget.collectBillResponse?.orders
                                ?.orderDetailsOrder?.loyaltyPoints ??
                            0,
                        // subTotalWithoutTax: (orderSubTotal +
                        //     (widget.collectBillResponse?.orders
                        //             ?.orderDetailsOrder?.deliveryCharge ??
                        //         0)),
                        subTotalWithoutTax: (orderSubTotal),
                        paperRoll: Get.find<AuthController>()
                                    .profileModel
                                    ?.billPrinterPaperRoll ==
                                58
                            ? 58
                            : 80,
                        orderId: widget.collectBillResponse!.orders!
                            .orderDetailsOrder!.restaurantOrderId,
                        date:
                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat}').format(DateTime.parse(widget.collectBillResponse!.orders!.orderDetailsOrder!.createdAt!))}',
                        waiterName:
                            '${widget.collectBillResponse!.orders!.restaurantDetails!.waiterName}',
                        tablename: widget.collectBillResponse!.orders!
                                    .restaurantDetails!.tableNo ==
                                ''
                            ? widget.collectBillResponse?.orders
                                        ?.orderDetailsOrder?.orderType ==
                                    'delivery'
                                ? 'Delivery'
                                : widget.collectBillResponse?.orders
                                            ?.orderDetailsOrder?.orderType ==
                                        'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : widget.collectBillResponse!.orders!
                                        .restaurantDetails!.tableArea ==
                                    ''
                                ? '${widget.collectBillResponse!.orders!.restaurantDetails!.tableNo}'
                                : '${widget.collectBillResponse!.orders!.restaurantDetails!.tableArea}:${widget.collectBillResponse!.orders!.restaurantDetails!.tableNo}',
                        custName: widget.collectBillResponse?.orders
                                ?.orderDetailsOrder?.username ??
                            '',
                        custPhone:
                            '${widget.collectBillResponse?.orders?.orderUser?.phone ?? ''}',
                        billFoodList: widget.collectBillResponse?.orders
                                ?.mergeFoodListWithDate ??
                            [],
                        orderNote: widget.collectBillResponse?.orders
                                ?.orderDetailsOrder?.orderNote ??
                            '',
                        orderSubTotal: orderItemTotal,
                        discount: orderDiscount,
                        serviceChargeAmount: showServiceChargeValue,
                        deliveryCharge: widget.collectBillResponse?.orders
                                ?.orderDetailsOrder?.deliveryCharge ??
                            0,
                        gstAmount: gstAmount + gstServiceChargeTax,
                        vatAmount: vatAmount,
                        grandTotal: Get.find<PosController>().collectItemPrice,
                        deliveryCustName: widget.collectBillResponse?.orders
                                ?.deliveryAddress?.name ??
                            '',
                        deliveryCustPhone: widget.collectBillResponse?.orders
                                ?.deliveryAddress?.phone ??
                            '',
                        deliveryAddressType: widget.collectBillResponse?.orders
                                ?.deliveryAddress?.addressType ??
                            '',
                        deliveryCustAddress: widget.collectBillResponse?.orders
                                ?.deliveryAddress?.address ??
                            '',
                        deliveryCustPincode: widget.collectBillResponse?.orders
                                ?.deliveryAddress?.pincode ??
                            '',
                        tips: double.tryParse(widget.collectBillResponse?.orders
                                    ?.orderDetailsOrder?.tipAmount
                                    .toString() ??
                                '0') ??
                            0,
                        orderType: widget.collectBillResponse?.orders
                            ?.orderDetailsOrder?.orderType,
                      ));
              await Future.delayed(Duration(seconds: 2));
            }
            break;
          }
          currentPrintIndex = currentPrintIndex + 1;
          windowsDataCheck();
        }
      } else if (currentPrintIndex <= widget.cartProductList.length - 1) {
        if (widget.cartProductList[currentPrintIndex].isEmpty ||
            isSelectPrinterList[currentPrintIndex] == false) {
          for (var i = currentPrintIndex;
              i < widget.cartProductList.length;
              i++) {
            if (widget.cartProductList[i].isEmpty ||
                isSelectPrinterList[currentPrintIndex] == false) {
              currentPrintIndex = currentPrintIndex + 1;
              windowsDataCheck();
              break;
            } else {
              if (GetPlatform.isWindows) {
                final printers = await Printing.listPrinters();
                for (var element in printers) {
                  if (element.isAvailable &&
                      (element.name.toLowerCase() ==
                          Get.find<AuthController>()
                              .profileModel!
                              .restaurantPrinterNew![currentPrintIndex]
                              .wifiPrinterName!
                              .toLowerCase())) {
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          tokenNo: Get.find<KdsController>()
                                  .getWaiterOrderListResponse
                                  ?.orders?[widget.index]
                                  .tokenNo ??
                              '',
                          printType: 'kot',
                          printTitle: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .areaName!
                                      .toUpperCase() ==
                                  'MASTER_KOT'
                              ? 'Master Duplicate KOT'
                              : 'Duplicate KOT',
                          orderType: Get.find<KdsController>()
                              .getWaiterOrderListResponse
                              ?.orders?[widget.index]
                              ?.orderType,
                          stationName: widget
                              .cartProductList[currentPrintIndex].first.station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel
                                      ?.restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: Get.find<KdsController>()
                              .getWaiterOrderListResponse!
                              .orders![widget.index]
                              .restaurantOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName:
                              '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].vendorEmployee!.waiterName}',
                          tablename: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable == null ||
                                  Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo == ''
                              ? Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index]?.orderType == 'delivery'
                                  ? 'Delivery'
                                  : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index]?.orderType == 'take_away'
                                      ? 'Take Away'
                                      : 'WC'
                              : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title == ''
                                  ? '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}'
                                  : '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title}-${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}',
                          custName: Get.find<KdsController>().getWaiterOrderListResponse?.orders![widget.index]?.userName ?? '',
                          custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].user?.phone ?? ''}',
                          kotOrderList: widget.cartProductList[currentPrintIndex] ?? [],
                          orderNote: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderNote ?? ''),
                    );
                    beepWindows();

                    break;
                  }
                }
                // await Printing.directPrintPdf(
                //   onLayout: (_) => generateKotPdf(order),
                // );
                currentPrintIndex = currentPrintIndex + 1;
                windowsDataCheck();
              }
              // break;
            }
          }
        } else {
          if (GetPlatform.isWindows) {
            final printers = await Printing.listPrinters();
            for (var element in printers) {
              if (element.isAvailable &&
                  (element.name.toLowerCase() ==
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurantPrinterNew![currentPrintIndex]
                          .wifiPrinterName!
                          .toLowerCase())) {
                await Printing.directPrintPdf(
                  printer: element,
                  onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                      tokenNo: Get.find<KdsController>()
                              .getWaiterOrderListResponse
                              ?.orders?[widget.index]
                              .tokenNo ??
                          '',
                      printType: 'kot',
                      printTitle: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .areaName!
                                  .toUpperCase() ==
                              'MASTER_KOT'
                          ? 'Master Duplicate KOT'
                          : 'Duplicate KOT',
                      orderType: Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![widget.index]
                          ?.orderType,
                      stationName: widget
                          .cartProductList[currentPrintIndex].first.station,
                      paperRoll:
                          Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].printerPaperRoll == 58
                              ? 58
                              : 80,
                      orderId: Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![widget.index]
                          .restaurantOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName:
                          '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].vendorEmployee!.waiterName}',
                      tablename: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable == null ||
                              Get.find<KdsController>()
                                      .getWaiterOrderListResponse!
                                      .orders![widget.index]
                                      .restaurantTable!
                                      .tableNo ==
                                  ''
                          ? Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index]?.orderType == 'delivery'
                              ? 'Delivery'
                              : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index]?.orderType == 'take_away'
                                  ? 'Take Away'
                                  : 'WC'
                          : Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title == ''
                              ? '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}'
                              : '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.title}-${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].restaurantTable!.tableNo}',
                      custName: Get.find<KdsController>().getWaiterOrderListResponse?.orders![widget.index]?.userName ?? '',
                      custPhone: '${Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].user?.phone ?? ''}',
                      kotOrderList: widget.cartProductList[currentPrintIndex] ?? [],
                      orderNote: Get.find<KdsController>().getWaiterOrderListResponse!.orders![widget.index].orderNote ?? ''),
                );
                beepWindows();

                break;
              }
            }
            currentPrintIndex = currentPrintIndex + 1;
            windowsDataCheck();

            // await Printing.directPrintPdf(
            //   printer: printers.first,
            //   onLayout: (_) => generateKotPdf(order),
            // );
            // currentPrintIndex = currentPrintIndex + 1;
            // dataCheck();
          }
        }
      }
    } catch (e) {}
  }

  callApiFixedStation(String orderId) async {
    if (widget.isBillPrint) {
      prepaidOrderCalculate();
    }
    Map<String, dynamic> manualPrintJson = {
      "order_id": orderId,
      "print_type": selectedPrintList.contains('kot') &&
              selectedPrintList.contains('bill')
          ? 'both'
          : selectedPrintList.contains('bill')
              ? 'bill'
              : "kot",
      "payment_amount":
          widget.isBillPrint ? Get.find<PosController>().collectItemPrice : 0,
      "grant_amount":
          widget.isBillPrint ? Get.find<PosController>().collectItemPrice : 0,
      "order_subtotal": orderSubTotal,
      "order_item_total": orderItemTotal,
      "discount_amount": orderDiscount,
      "coupon_code":
          '${widget.collectBillResponse?.orders?.orderDetailsOrder?.couponCode ?? ''}',
      "coupon_discount":
          widget.collectBillResponse?.orders?.orderDetailsOrder?.couponDiscountAmount ??
              0,
      "loyalty_dicount_amount":
          '${widget.collectBillResponse?.orders?.orderDetailsOrder?.loyaltyPoints ?? 0}',
      "wallet_used_amount": '0',
      'restaurant_order_id': Get.find<KdsController>()
          .getWaiterOrderListResponse!
          .orders![widget.index]
          .restaurantOrderId,
      'station_kot':
          kotPrinterNameList.isEmpty ? '' : kotPrinterNameList.join(','),
      "Date":
          '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(widget.collectBillResponse?.orders?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
      "waiterName":
          '${widget.collectBillResponse?.orders?.restaurantDetails?.waiterName ?? ''}',
      "tablename": (widget.collectBillResponse?.orders?.restaurantDetails
                      ?.tableNo ??
                  '') ==
              ''
          ? (widget.collectBillResponse?.orders?.orderDetailsOrder?.orderType ??
                      '') ==
                  'delivery'
              ? 'Delivery'
              : (widget.collectBillResponse?.orders?.orderDetailsOrder
                              ?.orderType ??
                          '') ==
                      'take_away'
                  ? 'Take Away'
                  : 'WC'
          : (widget.collectBillResponse?.orders?.restaurantDetails?.tableArea ??
                      '') ==
                  ''
              ? '${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}'
              : '${widget.collectBillResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${widget.collectBillResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
      "custName":
          widget.collectBillResponse?.orders?.orderDetailsOrder?.username ?? '',
      "custPhone":
          '${widget.collectBillResponse?.orders?.orderUser?.phone ?? ''}',
      "custGSTName": "",
      "custGST": "",
      "billFoodList":
          (widget.collectBillResponse?.orders?.mergeFoodListWithDate ?? [])
              .map((e) => e.toJson())
              .toList(),
      "orderNote":
          widget.collectBillResponse?.orders?.orderDetailsOrder?.orderNote ??
              '',
      "serviceChargeAmount": showServiceChargeValue,
      "roomRemainingPay": 0,
      "roomAdvancePay": 0,
      "roomGst": 0,
      "deliveryCustName":
          widget.collectBillResponse?.orders?.deliveryAddress?.name ?? '',
      "deliveryAddressType":
          widget.collectBillResponse?.orders?.deliveryAddress?.addressType ??
              '',
      "deliveryCustAddress":
          widget.collectBillResponse?.orders?.deliveryAddress?.address ?? '',
      "deliveryCustPincode":
          widget.collectBillResponse?.orders?.deliveryAddress?.pincode ?? '',
      "deliveryCustPhone":
          widget.collectBillResponse?.orders?.deliveryAddress?.phone ?? '',
      "deliveryCustHouse":
          widget.collectBillResponse?.orders?.deliveryAddress?.house ?? '',
      "deliveryCustFloor":
          widget.collectBillResponse?.orders?.deliveryAddress?.floor ?? '',
      "Tip":
          widget.collectBillResponse?.orders?.orderDetailsOrder?.tipAmount ?? 0,
      "order_type":
          widget.collectBillResponse?.orders?.orderDetailsOrder?.orderType ??
              '',
      "gst_tax": gstAmount + gstServiceChargeTax,
      "vat_tax": vatAmount,
      "delivery_charge": widget
              .collectBillResponse?.orders?.orderDetailsOrder?.deliveryCharge ??
          0
    };
    Get.find<KdsController>().sendPrintDataFixedUserApi(manualPrintJson);
  }

  prepaidOrderCalculate() {
    OrderDetailsOrder? orderd =
        widget.collectBillResponse?.orders?.orderDetailsOrder;

    orderSubTotal = orderd?.orderSubTotalWithoutTax ?? 0;
    orderItemTotal = orderd?.orderSubTotal ?? 0;
    orderDiscount = orderd?.orderDiscount ?? 0;
    showServiceChargeValue = double.parse(orderd!.serviceChargeAmount!);
    gstAmount = double.parse(orderd.totalGstTaxAmount!);
    vatAmount = double.parse(orderd.totalVatTaxAmount!);
    Get.find<PosController>()
        .setcollectItemPrice(twoDecimal(orderd.orderAmount ?? 0));
    tipAmount = double.parse(orderd.tipAmount!);
  }
}
