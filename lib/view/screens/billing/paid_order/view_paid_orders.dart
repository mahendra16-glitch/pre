import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/view/screens/billing/widget/print_order_dialog.dart';
import 'package:image/image.dart' as prefix;
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/controller/update_widget_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/billing/paid_order/paid_order_detail.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';

class ViewBillingPaidOrders extends StatefulWidget {
  const ViewBillingPaidOrders({Key? key}) : super(key: key);

  @override
  State<ViewBillingPaidOrders> createState() => _ViewBillingPaidOrdersState();
}

class _ViewBillingPaidOrdersState extends State<ViewBillingPaidOrders> {
  List<LocalOrderModel> orderList = [];
  DateTime? selectedDate;

  PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  BTStatus currentStatus = BTStatus.none;

  @override
  void initState() {
    super.initState();
    initData();
    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        log(' ----------------- billing paid status bt $status ------------------ ');

        currentStatus = status;
        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              Future.delayed(const Duration(seconds: 6), () async {
                await PrinterManager.instance
                    .disconnect(type: PrinterType.bluetooth);
              });
              pendingTask = null;
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          }
        } else if (status == BTStatus.none) {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Failed to bluetooth connect!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscriptionBtStatus?.cancel();
    super.dispose();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderList = await Get.find<CartController>().getOrderListFromLocally();
      Get.find<UpdateWidgetController>().update();
    });
  }

  TextEditingController paidController = TextEditingController();
  TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 40,
              color: ColorTheme.green,
            ),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            MediaQuery.of(context).size.shortestSide > 570
                ? Image.asset(
                    logoHelper.appLogo!,
                    width: Get.width * 0.2,
                  )
                : Image.asset(
                    logoHelper.appLogo!,
                    width: Get.width * 0.3,
                  ),
          ],
        ),
      ),
      body: GetBuilder<UpdateWidgetController>(builder: (updateController) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            const SizedBox(height: 20),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 50
                                    : 36,
                            child: TextField(
                              controller: paidController,
                              textInputAction: TextInputAction.search,
                              autofocus: false,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.PADDING_SIZE_DEFAULT),
                                suffixIcon: Icon(Icons.search,
                                    color: ColorTheme.appColor),
                                hintText: 'Order id or name or mobile',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                hintStyle: poppinsMedium.copyWith(
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 15
                                        : 13,
                                    color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              style: poppinsMedium.copyWith(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                              onChanged: (value) async {
                                // Get.find<KdsController>().update();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderList.length,
                        itemBuilder: (BuildContext context, int i) {
                          return paidController.text.isEmpty
                              ? orderBox(i)
                              : (orderList[i].orderId.toUpperCase().contains(
                                          paidController.text.toUpperCase())) ||
                                      (orderList[i]
                                          .phoneNumber
                                          .toUpperCase()
                                          .contains(paidController.text
                                              .toUpperCase())) ||
                                      (orderList[i].name.toUpperCase().contains(
                                          paidController.text.toUpperCase()))
                                  ? orderBox(i)
                                  : const SizedBox.shrink();
                        }),
                  ],
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget orderBox(int i) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: const Color.fromRGBO(254, 245, 208, 1)),
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Id',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${orderList[i].orderId}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),
          if (orderList[i].name != '')
            const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          if (orderList[i].name != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                ),
                Text(
                  '${orderList[i].name}',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                )
              ],
            ),
          if (orderList[i].phoneNumber != '')
            const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          if (orderList[i].phoneNumber != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phone',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                ),
                Text(
                  '${orderList[i].phoneNumber}',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                )
              ],
            ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Amount',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${orderList[i].orderAmount} ₹',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${orderList[i].paymentMethod}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      print(Get.find<AuthController>()
                          .profileModel!
                          .restaurantPrinterNew!
                          .length);
                      paidController.clear();
                      if (Get.find<AuthController>()
                              .profileModel!
                              .restaurantPrinterNew!
                              .length ==
                          1) {
                        kdsBytesConvert(orderList[i]);
                      } else {
                        List<List<CartModel>> cartProductList = [];

                        for (var p = 0;
                            p <
                                Get.find<AuthController>()
                                    .profileModel!
                                    .restaurantPrinterNew!
                                    .length;
                            p++) {
                          RestaurantPrinterNew printer =
                              Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![p];
                          List<CartModel> tempCartList = [];

                          for (var e in orderList[i].cartList) {
                            if (e.product.stationName!.toUpperCase() ==
                                printer.areaName!.toUpperCase()) {
                              tempCartList.add(e);
                            }
                          }
                          cartProductList.add(tempCartList);
                        }
                        if (Platform.isAndroid) {
                          await _subscriptionBtStatus?.cancel();
                        }
                        await Get.bottomSheet(PrintOrderBillingDialog(
                          order: orderList[i],
                          showWithBill: true,
                          cartProductList: cartProductList,
                        ));
                      }
                    },
                    child: SvgPicture.asset(
                      Images.ic_print_kot,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 37
                          : 26,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  paidController.clear();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              BillingPaidOrderDetailPage(order: orderList[i])));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      color: ColorTheme.appColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: Center(
                    child: Text(
                      'Details',
                      style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023, 6),
        lastDate: DateTime.now());
    if (picked != selectedDate) {
      selectedDate = picked;
      // await Get.find<KdsController>()
      //     .getPaidOrderList(DateFormat('yyyy-MM-dd').format(selectedDate));
    }
  }

  Future kdsBytesConvert(LocalOrderModel order) async {
    pendingTask = [];
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
            ? PaperSize.mm58
            : PaperSize.mm80,
        profile);
    bytes += generator.setGlobalCodeTable('CP1252');

    if (logoHelper.logoUrlPrint != null) {
      try {
        bytes += generator.feed(1);
        bytes += generator.image(logoHelper.logoUrlPrint!);
      } catch (e) {
        print(e);
      }
    }
    final profileModel = Get.find<AuthController>().profileModel;
    final restaurants = profileModel?.restaurants;
    final restaurant =
        (restaurants != null && restaurants.isNotEmpty) ? restaurants[0] : null;

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
          text: 'order_id'.tr + ':' + ' ${order.orderId}',
          width: 6,
          styles: PrinterConfig().orderIdStyle()),
      PosColumn(
          text:
              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(order.createdAt))}',
          width: 6,
          styles: PrinterConfig().orderCreateDateStyle()),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Billing', width: 5, styles: PrinterConfig().dineInStyle()),
      PosColumn(
        text: '',
        width: 1,
        styles: PrinterConfig().dineInStyle(),
      ),
      PosColumn(text: '', width: 6, styles: PrinterConfig().waiterNameStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
        text: '${order.name}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel!.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig
                              ?.restaurantFoodList ==
                          null
                  ? PosTextSize.size1
                  : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig!
                      .restaurantFoodList!
                      .split(',')
                      .first),
          width: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList ==
                      null
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                  .profileModel!
                  .printConfig!
                  .restaurantFoodList!
                  .split(',')[1]),
          bold: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList ==
                      null
              ? false
              : Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList!
                          .split(',')
                          .last ==
                      'true'
                  ? true
                  : false,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: '${order.phoneNumber}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel!.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig
                              ?.restaurantFoodList ==
                          null
                  ? PosTextSize.size1
                  : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig!
                      .restaurantFoodList!
                      .split(',')
                      .first),
          width: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList ==
                      null
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                  .profileModel!
                  .printConfig!
                  .restaurantFoodList!
                  .split(',')[1]),
          bold: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList ==
                      null
              ? false
              : Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList!
                          .split(',')
                          .last ==
                      'true'
                  ? true
                  : false,
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
        width: 5,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: 'qty'.tr,
        width: 2,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: 'Price',
        width: 3,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '--');
    for (var i = 0; i < order.cartList.length; i++) {
      CartModel cart = order.cartList[i];
      String addOnText = '';
      double addonsTotal = 0;
      double variationTotal = 0;

      int index0 = 0;
      List<int> ids = [];
      List<int> qtys = [];
      for (var addOn in cart.addOnIds) {
        ids.add(addOn.id);
        qtys.add(addOn.quantity);
      }
      for (var addOn in cart.product.addOns!) {
        if (ids.contains(addOn.id)) {
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
          addonsTotal = addonsTotal + (addOn.price! * qtys[index0]);
          index0 = index0 + 1;
        }
      }

      String variationText = '';

      if (cart.variation.isNotEmpty) {
        for (int index = 0; index < cart.variation.length; index++) {
          if (cart.variation[index].isNotEmpty &&
              cart.variation[index].contains(true)) {
            variationText +=
                '${variationText.isNotEmpty ? ', ' : ''}${cart.product.variations?[index].name ?? ''} (';

            for (int i = 0; i < (cart.variation[index].length ?? 0); i++) {
              if (cart.variation[index][i] == true) {
                variationTotal += double.parse(
                    cart.product.variations?[index].values?[i].optionPrice ??
                        '0');
                variationText +=
                    '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations?[index].values?[i].level ?? ''}';
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
          text: '${cart.product.name}',
          width: 5,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: formatQuantity(cart.quantity),
          width: 2,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: '${(cart.product.price! * cart.quantity)}',
          width: 3,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);
      if (addOnText != '' && addonsTotal != 0) {
        bytes += generator.hr(ch: '....');
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Add-Ons :$addOnText',
            width: 5,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: '$addonsTotal',
            width: 3,
            styles: PrinterConfig().foodStyle(),
          ),
        ]);
      }
      if (variationText != '' && variationTotal != 0) {
        bytes += generator.hr(ch: '....');
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Variants  :$variationText',
            width: 5,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: '${variationTotal * cart.quantity}',
            width: 3,
            styles: const PosStyles(align: PosAlign.center),
          ),
        ]);
      }

      bytes += generator.hr(ch: '....');
    }

    bytes += generator.hr(ch: '....');

    bytes += generator.row([
      PosColumn(
        text: '',
        width: 2,
        styles: const PosStyles(
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
        text: PriceConverter.convertPrice(order.subTotal,
            isHideCurrency: true, asFixed: 2),
        width: 3,
        styles: PrinterConfig().subtotalStyle(),
      ),
    ]);
    if (order.discount != 0)
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(
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
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: PriceConverter.convertPrice(order.discount,
              isHideCurrency: true, asFixed: 2),
          width: 3,
          styles: PrinterConfig().subtotalStyle(),
        ),
      ]);
    if (order.tips != 0)
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(
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
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
            text: PriceConverter.convertPrice(order.tips,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    if (order.serviceCharge != 0)
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
            text: 'Service Charge',
            width: 5,
            styles: PrinterConfig().subtotalStyle()),
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
            text: PriceConverter.convertPrice(order.serviceCharge,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    if (order.gstTaxAmount != 0) {
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(
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
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: PriceConverter.convertPrice(order.gstTaxAmount / 2,
              isHideCurrency: true, asFixed: 2),
          width: 3,
          styles: PrinterConfig().subtotalStyle(),
        ),
      ]);
    }
    if (order.gstTaxAmount != 0) {
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: const PosStyles(
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
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: PriceConverter.convertPrice(order.gstTaxAmount / 2,
              isHideCurrency: true, asFixed: 2),
          width: 3,
          styles: PrinterConfig().subtotalStyle(),
        ),
      ]);
    }

    bytes += generator.hr(ch: '....');
    bytes += generator.text(
      'Total: ' +
          PriceConverter.convertPrice(order.orderAmount,
              isHideCurrency: true, asFixed: 2),
      styles: PrinterConfig().totalStyle(),
    );
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
              fontType: PosFontType.fontB));
    }
    bytes += generator.text('Powered by MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            fontType: PosFontType.fontB));
    bytes += generator.cut();

    if (Platform.isAndroid) {
      await _kdsPrintEscPos(bytes, generator); //kitchen
    } else {
      await _iosPrintEscPos(bytes, generator); //kitchen
    }
  }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
    try {
      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      if (profile == null) return;

      final billType = (profile.billPrinterType ?? '').toLowerCase();
      final isWifi = billType == 'wifi' ||
          billType == 'network' ||
          ((profile.billWifiIp ?? '').isNotEmpty &&
              billType != 'bluetooth' &&
              billType != 'usb');
      final isUsb = billType == 'usb';

      BluetoothPrinter bluetoothPrinter;
      if (isUsb) {
        bluetoothPrinter = BluetoothPrinter(
            productId: profile.billProductId,
            vendorId: profile.billVendorId,
            typePrinter: PrinterType.usb);
      } else if (isWifi) {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.network,
            port: '9100',
            address: (profile.billWifiIp ?? '').isNotEmpty
                ? profile.billWifiIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      } else {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.bluetooth,
            address: (profile.macBillPrinterIp ?? '').isNotEmpty
                ? profile.macBillPrinterIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      }

      await printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: bluetoothPrinter.typePrinter == PrinterType.usb
            ? UsbPrinterInput(
                name: bluetoothPrinter.deviceName,
                productId: bluetoothPrinter.productId,
                vendorId: bluetoothPrinter.vendorId,
              )
            : bluetoothPrinter.typePrinter == PrinterType.network
                ? TcpPrinterInput(ipAddress: bluetoothPrinter.address ?? '')
                : BluetoothPrinterInput(
                    name: bluetoothPrinter.deviceName,
                    address: bluetoothPrinter.address ?? '',
                  ),
      );

      await printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      pendingTask = null;
      Future.delayed(const Duration(seconds: 6), () async {
        try {
          if (Get.isRegistered<LoadingController>()) {
            Get.find<LoadingController>().startLoading(false);
            await Get.find<LoadingController>()
                .changeText(data: 'Successfully printed!!');
            await Get.find<LoadingController>().changeStatus(data: true);
          }
          await PrinterManager.instance
              .disconnect(type: bluetoothPrinter.typePrinter);
        } catch (_) {}
      });
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        try {
          await Get.find<LoadingController>().changeText(
              data: 'Printing error occurred: $e', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        } catch (_) {}
      }
    }
  }

  Future<void> _iosPrintEscPos(List<int> bytes, Generator generator) async {
    try {
      print('########## bytes length ${bytes.length}');
      bytes += generator.feed(2);

      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      final macAddress = (profile?.macBillPrinterIp ?? '').isNotEmpty
          ? profile!.macBillPrinterIp!
          : (profile?.billPrinterIp ?? '');

      final bool result = await IosPrintTransport.connect(
        wifiPrinter: NetworkPrinterResolver.billPrinter(),
        macPrinterAddress: macAddress,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (result) {
        if (!IosPrintTransport.isWifiActive && bytes.length > 200) {
          const int chunkSize = 255;
          for (int i = 0; i < bytes.length; i += chunkSize) {
            final chunk = bytes.sublist(
              i,
              (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
            );
            await IosPrintTransport.writeBytes(chunk);
            await Future.delayed(const Duration(milliseconds: 35));
          }
        } else {
          await IosPrintTransport.writeBytes(bytes);
        }

        Future.delayed(const Duration(seconds: 6), () async {
          try {
            if (Get.isRegistered<LoadingController>()) {
              Get.find<LoadingController>().startLoading(false);
              await Get.find<LoadingController>()
                  .changeText(data: 'Successfully printed!!');
              await Get.find<LoadingController>().changeStatus(data: true);
            }
          } catch (_) {}
        });
      } else {
        if (Get.isRegistered<LoadingController>()) {
          Get.find<LoadingController>().startLoading(false);
          await Get.find<LoadingController>().changeText(
              data: 'Failed to connect to printer!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      }
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        try {
          await Get.find<LoadingController>().changeText(
              data: 'Printing error occurred: $e', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        } catch (_) {}
      }
    }
  }
}
