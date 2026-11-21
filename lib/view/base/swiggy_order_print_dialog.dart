import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
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
import '../../data/model/response/get_swiggy_order_list_response.dart';

class SwiggyPrintDialog extends StatefulWidget {
  final int index;
  final Order order;
  final List<List<OrderFoodDetails>> cartProductList;

  const SwiggyPrintDialog({
    super.key,
    required this.order,
    required this.index,
    required this.cartProductList,
  });

  @override
  State<SwiggyPrintDialog> createState() => _SwiggyPrintDialogState();
}

class _SwiggyPrintDialogState extends State<SwiggyPrintDialog> {
  int currentPrintIndex = 0;
  final PrinterManager _printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  List<bool> isSelectPrinterList = [];
  List<bool> isPrinterProccessingList = [];
  List<bool> isPrintedList = [];
  double showServiceChargeValue = 0;
  double discountedOrderSubTotal = 0;
  double serviceChargePercentage = 0;
  double orderSubTotal = 0;
  double gstAmount = 0;
  double vatAmount = 0;
  double orderDiscount = 0;
  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  bool isProcessing = false;
  bool isConnect = true;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.cartProductList.length; i++) {
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
        if (status == BTStatus.connected && pendingTask != null) {
          isConnect = true;
          isPrinterProccessingList[currentPrintIndex] = false;
          isProcessing = false;
          if (mounted) setState(() {});
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              pendingTask = null;
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          }
        } else if (status == BTStatus.none) {
          if (!isConnect) {
            Future.delayed(const Duration(seconds: 1), () async {
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
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.only(
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
                const SizedBox(height: 10),
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.cartProductList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return index != widget.cartProductList.length &&
                              widget.cartProductList[index].isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  isSelectPrinterList[index] =
                                      !isSelectPrinterList[index];
                                  setState(() {});
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
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
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            Get.find<AuthController>()
                                                .profileModel!
                                                .restaurantPrinterNew![index]
                                                .areaName!,
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
                                                color: ColorTheme.blue)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }),
                const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                InkWell(
                  onTap: () async {
                    if (!isProcessing) {
                      currentPrintIndex = 0;
                      dataCheck();
                    }
                  },
                  child: SvgPicture.asset(
                    Images.ic_print_kot,
                    height: 26,
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }

  Future iosPrintEscPos(List<int> bytes) async {
    print('########## bytes length ${bytes.length}');
    isPrinterProccessingList[currentPrintIndex] = true;
    setState(() {});

    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
        macPrinterAddress: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .macPrinterIp!);
    Future.delayed(const Duration(seconds: 4), () async {
      if (result) {
        await IosPrintTransport.writeBytes(bytes);
        Future.delayed(
            Duration(
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
                                    : 20), () async {
          isPrinterProccessingList[currentPrintIndex] = false;
          isPrintedList[currentPrintIndex] = true;

          setState(() {});
          bytes = [];
          var isDisconnect = await IosPrintTransport.disconnect;
          print('is disconnect $isDisconnect');
          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        });
        print("print test result:  $result");
      } else {
        isPrinterProccessingList[currentPrintIndex] = false;
        setState(() {});
        showErrorToast(
            '${Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].areaName} kot failed');

        currentPrintIndex = currentPrintIndex + 1;
        dataCheck();
      }
    });
  }

  Future printEscPos(List<int> bytes) async {
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        address: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerIp,
        deviceName: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerName);
    try {
      await _printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
          isBle: bluetoothPrinter.isBle ?? false,
        ),
      );
      pendingTask = null;
      print('t44444');
    } catch (e) {
      print('%%%%%%%$e');
    }

    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try {
        await _printerManager.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        isPrintedList[currentPrintIndex] = true;
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
          await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);

          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        });
      } catch (e) {}
    }
  }

  Future<void> dataCheck() async {
    try {
      if (currentPrintIndex <= widget.cartProductList.length - 1) {
        if (widget.cartProductList[currentPrintIndex].isEmpty ||
            isSelectPrinterList[currentPrintIndex] == false) {
          for (var i = currentPrintIndex;
              i < widget.cartProductList.length;
              i++) {
            if (widget.cartProductList[i].isEmpty ||
                isSelectPrinterList[i] == false) {
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck();
              break;
            } else {
              if (Platform.isIOS) {
                await iosPrintEscPos(await PrintByteConvert().byteConvert(
                    printType: 'swiggy_kot',
                    orderType: widget.order.orderDetailsOrder.orderPlateform ==
                            'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                    stationName:
                        widget.cartProductList[currentPrintIndex].first.station,
                    paperRoll: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .printerPaperRoll ==
                            58
                        ? 58
                        : 80,
                    orderId: widget.order.orderDetailsOrder.aggregatorOrderId,
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                    waiterName: '',
                    tablename: widget.order.orderDetailsOrder.orderPlateform ==
                            'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                    custName: widget.order.customerDetails.name ?? '',
                    custPhone: widget.order.customerDetails.phone ?? '',
                    swiggyOrderList:
                        widget.cartProductList[currentPrintIndex] ?? [],
                    orderNote: widget.order.orderDetailsOrder.orderNote ?? ''));
              } else if (Platform.isWindows) {
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
                          printType: 'swiggy_kot',
                          brandName: widget.order?.brandName ?? '',
                          orderType:
                              widget.order.orderDetailsOrder.orderPlateform ==
                                      'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          stationName: widget
                              .cartProductList[currentPrintIndex].first.station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId:
                              widget.order.orderDetailsOrder.aggregatorOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName: '',
                          tablename:
                              widget.order.orderDetailsOrder.orderPlateform ==
                                      'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          custName: widget.order.customerDetails.name ?? '',
                          custPhone: widget.order.customerDetails.phone ?? '',
                          swiggyOrderList:
                              widget.cartProductList[currentPrintIndex] ?? [],
                          orderNote:
                              widget.order.orderDetailsOrder.orderNote ?? ''),
                      // generateKotPdf(order)
                    );

                    currentPrintIndex = currentPrintIndex + 1;
                    dataCheck();
                    break;
                  }
                }
                isPrinterProccessingList[currentPrintIndex] = false;
                isPrintedList[currentPrintIndex] = true;
              } else {
                await printEscPos(await PrintByteConvert().byteConvert(
                    printType: 'swiggy_kot',
                    orderType: widget.order.orderDetailsOrder.orderPlateform ==
                            'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                    stationName:
                        widget.cartProductList[currentPrintIndex].first.station,
                    paperRoll: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .printerPaperRoll ==
                            58
                        ? 58
                        : 80,
                    orderId: widget.order.orderDetailsOrder.aggregatorOrderId,
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                    waiterName: '',
                    tablename: widget.order.orderDetailsOrder.orderPlateform ==
                            'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                    custName: widget.order.customerDetails.name ?? '',
                    custPhone: widget.order.customerDetails.phone ?? '',
                    swiggyOrderList:
                        widget.cartProductList[currentPrintIndex] ?? [],
                    orderNote: widget.order.orderDetailsOrder.orderNote ?? ''));
              }
              break;
            }
          }
        } else {
          if (Platform.isIOS) {
            await iosPrintEscPos(await PrintByteConvert().byteConvert(
                printType: 'swiggy_kot',
                orderType:
                    widget.order.orderDetailsOrder.orderPlateform == 'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                stationName:
                    widget.cartProductList[currentPrintIndex].first.station,
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .restaurantPrinterNew![currentPrintIndex]
                            .printerPaperRoll ==
                        58
                    ? 58
                    : 80,
                orderId: widget.order.orderDetailsOrder.aggregatorOrderId,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                waiterName: '',
                tablename:
                    widget.order.orderDetailsOrder.orderPlateform == 'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                custName: widget.order.customerDetails.name ?? '',
                custPhone: widget.order.customerDetails.phone ?? '',
                swiggyOrderList:
                    widget.cartProductList[currentPrintIndex] ?? [],
                orderNote: widget.order.orderDetailsOrder.orderNote ?? ''));
          } else if (Platform.isWindows) {
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
                      brandName: widget.order?.brandName ?? '',
                      printType: 'swiggy_kot',
                      orderType: widget
                                  .order.orderDetailsOrder.orderPlateform ==
                              'zomato'
                          ? 'Zomato'
                          : 'Swiggy',
                      stationName: widget
                          .cartProductList[currentPrintIndex].first.station,
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: widget.order.orderDetailsOrder.aggregatorOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '',
                      tablename:
                          widget
                                      .order.orderDetailsOrder.orderPlateform ==
                                  'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      custName: widget.order.customerDetails.name ?? '',
                      custPhone: widget.order.customerDetails.phone ?? '',
                      swiggyOrderList:
                          widget.cartProductList[currentPrintIndex] ?? [],
                      orderNote:
                          widget.order.orderDetailsOrder.orderNote ?? ''),
                  // generateKotPdf(order)
                );

                currentPrintIndex = currentPrintIndex + 1;
                dataCheck();
                break;
              }
            }
            isPrinterProccessingList[currentPrintIndex] = false;
            isPrintedList[currentPrintIndex] = true;
          } else {
            await printEscPos(await PrintByteConvert().byteConvert(
                printType: 'swiggy_kot',
                orderType:
                    widget.order.orderDetailsOrder.orderPlateform == 'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                stationName:
                    widget.cartProductList[currentPrintIndex].first.station,
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .restaurantPrinterNew![currentPrintIndex]
                            .printerPaperRoll ==
                        58
                    ? 58
                    : 80,
                orderId: widget.order.orderDetailsOrder.aggregatorOrderId,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                waiterName: '',
                tablename:
                    widget.order.orderDetailsOrder.orderPlateform == 'zomato'
                        ? 'Zomato'
                        : 'Swiggy',
                custName: widget.order.customerDetails.name ?? '',
                custPhone: widget.order.customerDetails.phone ?? '',
                swiggyOrderList:
                    widget.cartProductList[currentPrintIndex] ?? [],
                orderNote: widget.order.orderDetailsOrder.orderNote ?? ''));
          }
        }
      }
    } catch (e) {}
  }
}
