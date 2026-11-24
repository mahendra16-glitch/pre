import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
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

class PrintOrderBillingDialog extends StatefulWidget {
  final bool showWithBill;
  final LocalOrderModel order;
  final List<List<CartModel>> cartProductList;

  const PrintOrderBillingDialog({
    super.key,
    this.showWithBill = false,
    required this.order,
    required this.cartProductList,
  });

  @override
  State<PrintOrderBillingDialog> createState() =>
      _PrintOrderBillingDialogState();
}

class _PrintOrderBillingDialogState extends State<PrintOrderBillingDialog> {
  int currentPrintIndex = 0;
  final PrinterManager _printerManager = PrinterManager.instance;
  late final StreamSubscription<BTStatus> _subscriptionBtStatus;
  List<int>? pendingTask;
  List<bool> isSelectPrinterList = [];
  List<bool> isPrinterProccessingList = [];
  List<bool> isPrintedList = [];

  bool isProcessing = false;
  bool isConnect = true;

  @override
  void initState() {
    if (widget.showWithBill) {
      isSelectPrinterList.add(false);
      isPrintedList.add(false);
      isPrinterProccessingList.add(false);
    }
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
        if (status == BTStatus.connected) {
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

    super.initState();
  }

  @override
  void dispose() {
    _subscriptionBtStatus.cancel();
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
                    itemCount: widget.showWithBill
                        ? widget.cartProductList.length + 1
                        : widget.cartProductList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widget.showWithBill && index == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  isSelectPrinterList[0] =
                                      !isSelectPrinterList[0];
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
                                        value: isSelectPrinterList[0],
                                        onChanged: (bool? isChecked) {
                                          isSelectPrinterList[0] = isChecked!;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('BILL',
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
                                                : isPrintedList[0]
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
                            )
                          : widget
                                  .cartProductList[
                                      widget.showWithBill ? index - 1 : index]
                                  .isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: InkWell(
                                    onTap: () {
                                      isSelectPrinterList[widget.showWithBill
                                          ? index - 1
                                          : index] = !isSelectPrinterList[widget
                                              .showWithBill
                                          ? index - 1
                                          : index];
                                      // isPrintKitchen = !isPrintKitchen;
                                      setState(() {});
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? 70
                                              : 30,
                                          child: Checkbox(
                                            activeColor: ColorTheme.appColor,
                                            value: isSelectPrinterList[
                                                widget.showWithBill
                                                    ? index - 1
                                                    : index],
                                            onChanged: (bool? isChecked) {
                                              isSelectPrinterList[
                                                  widget.showWithBill
                                                      ? index - 1
                                                      : index] = isChecked!;
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
                                                    .restaurantPrinterNew![
                                                        widget.showWithBill
                                                            ? index - 1
                                                            : index]
                                                    .areaName!,
                                                style: poppinsMedium.copyWith(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1600
                                                            ? 17
                                                            : 14)),
                                            Text(
                                                isPrinterProccessingList[
                                                        widget.showWithBill
                                                            ? index - 1
                                                            : index]
                                                    ? 'Status: Proccessing'
                                                    : isPrintedList[
                                                            widget.showWithBill
                                                                ? index - 1
                                                                : index]
                                                        ? 'Status: Printed'
                                                        : 'Status: Not Printed',
                                                style: poppinsMedium.copyWith(
                                                    fontSize:
                                                        MediaQuery.of(context)
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

  Future bytesConvert() async {
    pendingTask = [];
    List<int> bytes = [];
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        profileModel.billPrinterPaperRoll == 58
            ? PaperSize.mm58
            : PaperSize.mm80,
        profile);

    bytes += generator.setGlobalCodeTable('CP1252');

    // Add null checks and default values for restaurants list and its fields
    final restaurant = (profileModel.restaurants != null &&
            profileModel.restaurants!.isNotEmpty)
        ? profileModel.restaurants!.first
        : null;

    bytes += generator.text(restaurant?.name ?? '',
        styles: PrinterConfig().titleStyle());
    bytes += generator.text(restaurant?.address ?? '',
        styles: PrinterConfig().addressStyle());
    if ((restaurant?.gstCode ?? '').isNotEmpty)
      bytes += generator.text('GST no. ${restaurant?.gstCode ?? ''}',
          styles: PrinterConfig().gstStyle());
    if ((restaurant?.fssai ?? '').isNotEmpty)
      bytes += generator.text('FSI no. ${restaurant?.fssai ?? ''}',
          styles: PrinterConfig().gstStyle());

    bytes += generator.row([
      PosColumn(
          text: 'order_id'.tr + ':' + ' ${widget.order.orderId}',
          width: 6,
          styles: PrinterConfig().orderIdStyle()),
      PosColumn(
          text: restaurant?.billDateFormat != null
              ? '${DateFormat('${restaurant!.billDateFormat}').format(DateTime.parse(widget.order.createdAt))}'
              : '',
          width: 6,
          styles: PrinterConfig().orderCreateDateStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Billing', width: 5, styles: PrinterConfig().dineInStyle()),
      PosColumn(
        text: '',
        width: 1,
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
          text: widget.order.employeeName ?? '',
          width: 6,
          styles: PrinterConfig().waiterNameStyle()),
    ]);

    // Extract printConfig and restaurantFoodList safely
    final printConfig = Get.find<AuthController>().profileModel?.printConfig;
    final restaurantFoodList = printConfig?.restaurantFoodList;
    final foodListParts = restaurantFoodList?.split(',') ?? [];

    bytes += generator.row([
      PosColumn(
        text: widget.order.name ?? '',
        width: 5,
        styles: PosStyles(
          height: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.isEmpty)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(foodListParts.first),
          width: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.length < 2)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(foodListParts[1]),
          bold: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.length < 3)
              ? false
              : (foodListParts[2] == 'true'),
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 2,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: widget.order.phoneNumber ?? '',
        width: 5,
        styles: PosStyles(
          height: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.isEmpty)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(foodListParts.first),
          width: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.length < 2)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(foodListParts[1]),
          bold: (printConfig == null ||
                  restaurantFoodList == null ||
                  foodListParts.length < 3)
              ? false
              : (foodListParts[2] == 'true'),
          align: PosAlign.right,
          fontType: PosFontType.fontB,
        ),
      ),
    ]);

    bytes += generator.hr(ch: '--');
    bytes += generator.row([
      PosColumn(text: 'SL', width: 2, styles: PrinterConfig().foodStyle()),
      PosColumn(
          text: 'item_info'.tr,
          width: widget.showWithBill && currentPrintIndex == 0 ? 5 : 8,
          styles: PrinterConfig().foodStyle()),
      PosColumn(text: 'qty'.tr, width: 2, styles: PrinterConfig().foodStyle()),
      if (widget.showWithBill && currentPrintIndex == 0)
        PosColumn(text: 'Price', width: 3, styles: PrinterConfig().foodStyle()),
    ]);
    bytes += generator.hr(ch: '--');
    List<CartModel> foodOrderList = [];
    if (widget.showWithBill && currentPrintIndex == 0) {
      foodOrderList.addAll(widget.order.cartList);
    } else {
      foodOrderList.addAll(widget.cartProductList[currentPrintIndex]);
    }
    for (var i = 0; i < foodOrderList.length; i++) {
      CartModel food = foodOrderList[i];
      String addOnText = '';
      int index0 = 0;
      List<int> ids = [];
      List<int> qtys = [];
      double addonsTotal = 0;
      double variationTotal = 0;

      for (var addOn in food.addOnIds) {
        ids.add(addOn.id);
        qtys.add(addOn.quantity);
      }
      for (var addOn in food.product.addOns!) {
        if (ids.contains(addOn.id)) {
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
          addonsTotal = addonsTotal + (addOn.price! * qtys[index0]);

          index0 = index0 + 1;
        }
      }

      String variationText = '';

      if (food.variation.isNotEmpty) {
        for (int index = 0; index < food.variation.length; index++) {
          if (food.variation[index].isNotEmpty &&
              food.variation[index].contains(true)) {
            variationText +=
                '${variationText.isNotEmpty ? ', ' : ''}${food.product.variations![index].name} (';

            for (int i = 0; i < food.variation[index].length; i++) {
              if (food.variation[index][i]) {
                variationTotal += double.parse(
                    food.product.variations![index].values![i].optionPrice!);

                variationText +=
                    '${variationText.endsWith('(') ? '' : ', '}${food.product.variations![index].values![i].level}';
              }
            }
            variationText += ')';
          }
        }
      }

      bytes += generator.row([
        PosColumn(
            text: '${i + 1}.', width: 2, styles: PrinterConfig().foodStyle()),
        PosColumn(
          text: '${food.product.name}',
          width: widget.showWithBill && currentPrintIndex == 0 ? 5 : 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: formatQuantity(food.quantity),
          width: 2,
          styles: PrinterConfig().foodStyle(),
        ),
        if (widget.showWithBill && currentPrintIndex == 0)
          PosColumn(
            text: '${(food.product.price! * food.quantity)}',
            // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
            width: 3,
            styles: PrinterConfig().foodStyle(),
          ),
      ]);

      if (addOnText != '' &&
          (widget.showWithBill && currentPrintIndex == 0
              ? addonsTotal != 0
              : true)) {
        if (widget.showWithBill && currentPrintIndex == 0)
          bytes += generator.hr(ch: '....');
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Add-Ons :$addOnText',
            width: widget.showWithBill && currentPrintIndex == 0 ? 5 : 8,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          if (widget.showWithBill && currentPrintIndex == 0)
            PosColumn(
              text: '$addonsTotal',
              width: 3,
              styles: PrinterConfig().foodStyle(),
            ),
        ]);
      }
      if (variationText != '' &&
          (widget.showWithBill && currentPrintIndex == 0
              ? addonsTotal != 0
              : true)) {
        if (widget.showWithBill && currentPrintIndex == 0)
          bytes += generator.hr(ch: '....');

        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Variants  :$variationText',
            width: widget.showWithBill && currentPrintIndex == 0 ? 5 : 8,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          if (widget.showWithBill && currentPrintIndex == 0)
            PosColumn(
              text: '${variationTotal * food.quantity}',
              width: 3,
              styles: PosStyles(align: PosAlign.center),
            ),
        ]);
      }

      bytes += generator.hr(ch: '....');
    }

    if (widget.showWithBill && currentPrintIndex == 0) {
      bytes += generator.hr(ch: '....');

      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: 'Sub Total ',
          width: 5,
          styles: PrinterConfig().subtotalStyle(),
        ),
        PosColumn(
          text: '',
          width: 2,
          styles: PrinterConfig().subtotalStyle(),
        ),
        PosColumn(
          text: PriceConverter.convertPrice(widget.order.subTotal,
              isHideCurrency: true, asFixed: 2),
          width: 3,
          styles: PrinterConfig().subtotalStyle(),
        ),
      ]);
      if (widget.order.discount != 0)
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Add Discount ',
            width: 5,
            styles: PrinterConfig().subtotalStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: PriceConverter.convertPrice(widget.order.discount,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle(),
          ),
        ]);
      if (widget.order.tips != 0)
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
              text: 'Add Tips ',
              width: 5,
              styles: PrinterConfig().subtotalStyle()),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
              text: PriceConverter.convertPrice(widget.order.tips,
                  isHideCurrency: true, asFixed: 2),
              width: 3,
              styles: PrinterConfig().subtotalStyle()),
        ]);
      if (widget.order.serviceCharge != 0)
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
              text:
                  '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt ?? 'Service Charge'} ',
              width: 5,
              styles: PrinterConfig().subtotalStyle()),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
              text: PriceConverter.convertPrice(widget.order.serviceCharge,
                  isHideCurrency: true, asFixed: 2),
              width: 3,
              styles: PrinterConfig().subtotalStyle()),
        ]);

      if (widget.order.gstTaxAmount != 0) {
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'CGST ',
            width: 5,
            styles: PrinterConfig().subtotalStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: PriceConverter.convertPrice(widget.order.gstTaxAmount / 2,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle(),
          ),
        ]);
      }
      if (widget.order.gstTaxAmount != 0) {
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'SGST ',
            width: 5,
            styles: PrinterConfig().subtotalStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: PriceConverter.convertPrice(widget.order.gstTaxAmount / 2,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle(),
          ),
        ]);
      }

      bytes += generator.hr(ch: '....');
      bytes += generator.text(
        'Total: ' +
            PriceConverter.convertPrice(widget.order.orderAmount,
                isHideCurrency: true, asFixed: 2),
        styles: PrinterConfig().totalStyle(),
      );
    }

    bytes += generator.hr(ch: '....');
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .footerTextBill !=
        '') {
      bytes += generator.text(
          Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .footerTextBill!,
          styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              // bold: true,
              fontType: PosFontType.fontB));
    }
    bytes += generator.text('Powered by MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            // bold: true,
            fontType: PosFontType.fontB));
    bytes += generator.cut();

    if (Platform.isAndroid) {
      await printEscPos(bytes, generator); //kitchen
    } else {
      await iosPrintEscPos(bytes, generator); //kitchen
    }
  }

  Future iosPrintEscPos(List<int> bytes, Generator generator) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    isPrinterProccessingList[currentPrintIndex] = true;
    setState(() {});

    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
        macPrinterAddress: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .macPrinterIp!);
    Future.delayed(Duration(seconds: 2), () async {
      if (result) {
        await IosPrintTransport.writeBytes(bytes);
        Future.delayed(Duration(seconds: 10), () async {
          isPrinterProccessingList[currentPrintIndex] = false;
          isPrintedList[currentPrintIndex] = true;

          setState(() {});
          bytes = [];
          var isDisconnect =
          print('is disconnect $isDisconnect');
          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        });
        print("print test result:  $result");
      } else {
        isPrinterProccessingList[currentPrintIndex] = false;
        setState(() {});

        //no conectado, reconecte
        // showCustomSnackBar('Failed to bluetooth connect');
        showErrorToast(
            '${Get.find<AuthController>().profileModel!.restaurantPrinterNew![currentPrintIndex].areaName} kot failed');

        currentPrintIndex = currentPrintIndex + 1;
        dataCheck();
      }
    });
    // });
  }

  Future printEscPos(List<int> bytes, Generator generator) async {
    // bytes += generator.cut();
    // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        address: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerIp,
        deviceName: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerName); //device name or ip was mandadory
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
        isPrintedList[currentPrintIndex] = true; //It show status of start print
        isPrinterProccessingList[currentPrintIndex] = false;
        isProcessing = false;
        if (mounted) setState(() {});
        Future.delayed(Duration(seconds: 2), () async {
          bytes = [];
          await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);

          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        });
      } catch (e) {}
    }
  }

  dataCheck() {
    try {
      if (widget.showWithBill &&
          currentPrintIndex == 0 &&
          isSelectPrinterList[0]) {
        bytesConvert();
      } else {
        if (currentPrintIndex <= widget.cartProductList.length - 1) {
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
                bytesConvert();
                break;
              }
            }
          } else {
            bytesConvert();
          }
        }
      }
    } catch (e) {}
  }
}
