import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../util/print_byte_convert.dart';

class TabOrderContent extends StatefulWidget {
  final TextEditingController paidSearch;
  const TabOrderContent({Key? key, required this.paidSearch}) : super(key: key);

  @override
  State<TabOrderContent> createState() => _TabOrderContentState();
}

class _TabOrderContentState extends State<TabOrderContent> {
  PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  late List<int> pendingTask;
  BTStatus currentStatus = BTStatus.none;
  @override
  void initState() {
    super.initState();
    // PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        log(' -----------------paid status bt $status ------------------ ');

        currentStatus = status;
        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask);
              Future.delayed(Duration(seconds: 11), () async {
                await PrinterManager.instance
                    .disconnect(type: PrinterType.bluetooth);
              });
              pendingTask = <int>[];
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask);
            pendingTask = [];
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height:
                      MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                  child: TextField(
                    controller: widget.paidSearch,
                    textInputAction: TextInputAction.search,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                      suffixIcon:
                          Icon(Icons.search, color: ColorTheme.appColor),
                      hintText: 'Order id or name or mobile',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                      ),
                      hintStyle: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                          color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: poppinsMedium.copyWith(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13,
                    ),
                    onChanged: (value) async {
                      Get.find<KdsController>().update();
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  widget.paidSearch.clear();
                  _selectDate(context);
                },
                child: Container(
                  height:
                      MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white,
                      border: Border.all(color: ColorTheme.borderGrey)),
                  child: Center(
                    child: Text(
                      selectedDate == null
                          ? 'Filter by date'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: poppinsMedium.copyWith(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              // itemCount: 10,
              itemCount: Get.find<KdsController>()
                      .getTabOrdersResponse
                      ?.orders
                      .length ??
                  0,
              itemBuilder: (BuildContext context, int i) {
                var order =
                    Get.find<KdsController>().getTabOrdersResponse!.orders[i];

                bool isSearchTextMatched = widget.paidSearch.text.isEmpty ||
                    (order.restaurantOrderId
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase())) ||
                    (order.phone
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase())) ||
                    (order.username
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase())) ||
                    (order.fName
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase()));

                // Check if both conditions are matched
                return isSearchTextMatched
                    ? orderBox(i)
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget orderBox(int i) {
    var order = Get.find<KdsController>().getTabOrdersResponse!.orders[i];
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: Color.fromRGBO(254, 245, 208, 1)),
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
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
                '${order.restaurantOrderId == '0' ? order.id : order.restaurantOrderId}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),

          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waiter Name',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${order.waiterName}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),
          if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .isComplementry !=
              'Yes')
            Column(
              children: [
                if (order.fName != '' || order.lName != '')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.fName != '' || order.lName != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Name',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.fName} ${order.lName}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      )
                    ],
                  ),
                if (order.phone != '')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.phone != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phone',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.phone}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      )
                    ],
                  ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Amount',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.orderAmount} ₹',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    )
                  ],
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.paymentMethod}',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    )
                  ],
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(DateTime.parse(order.collectBillDate!)),
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    )
                  ],
                ),
              ],
            ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Get.find<AuthController>().profileModel!.role!.contains('printer')
                  ? Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            widget.paidSearch.clear();
                            double subTotal = 0;
                            await Get.find<KdsController>()
                                .clearPaidOrderDetail();
                            // await kdsBytesConvert(order.orderDetailsFood,
                            //     order.orderDetailsOrder.id.toString());
                            await Get.find<KdsController>().getPaidOrderDetail(
                                '${Get.find<KdsController>().getTabOrdersResponse!.orders[i].id}',
                                isShowLoader: false);
                            // kdsBytesConvert();
                            Orders order = Get.find<KdsController>()
                                .paidOrderDetailResponse!
                                .orders!;
                            double couponDiscount = 0;
                            double loyaltyPoint = 0;
                            double usedWallet = 0;
                            String couponCode = '';

                            if (order.orderDetailsOrder!.couponInfo != null &&
                                order.orderDetailsOrder!.couponInfo!.applied!) {
                              couponDiscount = order.orderDetailsOrder
                                      ?.couponInfo?.couponAmount ??
                                  0;
                              couponCode = order.orderDetailsOrder?.couponInfo
                                      ?.couponTitle ??
                                  '';
                            }
                            if (order.orderDetailsOrder!.loyaltyInfo != null &&
                                order.orderDetailsOrder!.loyaltyInfo!
                                    .redeemed!) {
                              loyaltyPoint = order.orderDetailsOrder
                                      ?.loyaltyInfo?.redeemedAmount ??
                                  0;
                            }
                            if (order.orderDetailsOrder!.walletInfo != null &&
                                order.orderDetailsOrder!.walletInfo!.applied!) {
                              usedWallet =
                                  order.orderDetailsOrder?.walletInfo?.amount ??
                                      0;
                            }
                            if (Get.find<KdsController>()
                                        .paidOrderDetailResponse !=
                                    null &&
                                Get.find<KdsController>()
                                        .paidOrderDetailResponse
                                        ?.orders !=
                                    null &&
                                Get.find<KdsController>()
                                        .paidOrderDetailResponse
                                        ?.orders
                                        ?.orderDetailsFood !=
                                    null) {
                              for (var orderDetailsFood
                                  in Get.find<KdsController>()
                                          .paidOrderDetailResponse
                                          ?.orders
                                          ?.orderDetailsFood ??
                                      []) {
                                double variationTotal = 0;
                                double halfVariationPrice = 0;
                                double addonsTotal = 0;
                                if (orderDetailsFood.variation != null &&
                                    (orderDetailsFood.variation?.isNotEmpty ??
                                        false)) {
                                  for (int j = 0;
                                      j <
                                          (orderDetailsFood.variation?.length ??
                                              0);
                                      j++) {
                                    if (orderDetailsFood.variation?[j].values !=
                                        null) {
                                      List<String> labelList = [];
                                      for (var element in orderDetailsFood
                                              .variation?[j].values ??
                                          []) {
                                        labelList.add(element.label ?? '');
                                        // variationTotal += (int.parse(
                                        //         element.optionPrice) *
                                        //     orderDetailsFood
                                        //         .quantity);
                                        if ((orderDetailsFood.variation?[j].name
                                                    ?.toUpperCase() ??
                                                '') ==
                                            'HALFNHALF') {
                                          if (halfVariationPrice <
                                              (double.tryParse(
                                                          element.optionPrice ??
                                                              '0') ??
                                                      0) *
                                                  (orderDetailsFood.quantity ??
                                                      0)) {
                                            halfVariationPrice =
                                                (double.tryParse(element
                                                                .optionPrice ??
                                                            '0') ??
                                                        0) *
                                                    (orderDetailsFood
                                                            .quantity ??
                                                        0);
                                          }
                                        } else {
                                          variationTotal = variationTotal +
                                              ((double.tryParse(
                                                          element.optionPrice ??
                                                              '0') ??
                                                      0) *
                                                  (orderDetailsFood.quantity ??
                                                      0));
                                        }
                                      }
                                    }

                                    variationTotal =
                                        variationTotal + halfVariationPrice;
                                  }
                                }

                                for (var i = 0;
                                    i < orderDetailsFood.addOns!.length;
                                    i++) {
                                  addonsTotal = addonsTotal +
                                      (orderDetailsFood.addOns![i].price! *
                                          orderDetailsFood
                                              .addOns![i].quantity!);
                                }

                                subTotal = subTotal +
                                    orderDetailsFood.price +
                                    variationTotal +
                                    addonsTotal;
                                Get.find<KdsController>().update();
                              }
                            }
                            if (GetPlatform.isWindows) {
                              int numberOfPrint = int.parse(
                                  Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .settings!
                                          .noOfBillPrint ??
                                      '1');
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
                                      onLayout: (_) => WindowsPrintByteConvert()
                                          .byteConvert(
                                              couponCode: couponCode,
                                              couponDiscount: couponDiscount,
                                              loyaltyUsed: loyaltyPoint,
                                              walletUsed: usedWallet,
                                              paymentType: order!
                                                      .orderDetailsOrder
                                                      ?.paymentMethod ??
                                                  '',
                                              printType: 'paid_bill',
                                              paperRoll: Get.find<AuthController>()
                                                          .profileModel!
                                                          .billPrinterPaperRoll ==
                                                      58
                                                  ? 58
                                                  : 80,
                                              orderId: order!.orderDetailsOrder!
                                                  .restaurantOrderId,
                                              date:
                                                  '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(order.orderDetailsOrder!.createdAt!))}',
                                              waiterName:
                                                  '${order.restaurantDetails!.restaurantWaiterName}',
                                              tablename: order
                                                          .restaurantDetails!
                                                          .restaurantTableNo ==
                                                      ''
                                                  ? order.orderDetailsOrder?.orderType ==
                                                          'delivery'
                                                      ? 'Delivery'
                                                      : order.orderDetailsOrder?.orderType ==
                                                              'take_away'
                                                          ? 'Take Away'
                                                          : 'WC'
                                                  : order.restaurantDetails!.restaurantTableArea == ''
                                                      ? '${order.restaurantDetails!.restaurantTableNo}'
                                                      : '${order.restaurantDetails!.restaurantTableArea}:${order.restaurantDetails!.restaurantTableNo}',
                                              custName: order?.orderDetailsOrder?.username ?? '',
                                              custPhone: '${order?.orderUser?.phone ?? ''}',
                                              paidFoodList: order?.orderDetailsFood ?? [],
                                              orderNote: order?.orderDetailsOrder?.orderNote ?? '',
                                              orderSubTotal: subTotal,
                                              discount: order?.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                              serviceChargeAmount: double.parse(order?.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                              deliveryCharge: order?.orderDetailsOrder?.deliveryCharge ?? 0,
                                              gstAmount: double.parse(order?.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                              vatAmount: double.parse(order?.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                              grandTotal: order?.orderDetailsOrder?.orderAmount ?? 0,
                                              tips: order?.orderDetailsOrder?.tipAmount ?? 0,
                                              orderType: order.orderDetailsOrder?.orderType),
                                    );
                                    await Future.delayed(Duration(seconds: 2));
                                  }
                                  break;
                                }
                              }
                              Get.find<LoadingController>().startLoading(false);

                              await Get.find<LoadingController>()
                                  .changeText(data: 'Successfully printed!!');
                              await Get.find<LoadingController>()
                                  .changeStatus(data: true);
                            } else {
                              if (Platform.isIOS) {
                                await _iosPrintEscPos(await PrintByteConvert()
                                    .byteConvert(
                                        couponCode: couponCode,
                                        couponDiscount: couponDiscount,
                                        loyaltyUsed: loyaltyPoint,
                                        walletUsed: usedWallet,
                                        printType: 'paid_bill',
                                        paymentType: order!.orderDetailsOrder
                                                ?.paymentMethod ??
                                            '',
                                        paperRoll: Get.find<AuthController>()
                                                    .profileModel!
                                                    .billPrinterPaperRoll ==
                                                58
                                            ? 58
                                            : 80,
                                        orderId: order?.orderDetailsOrder
                                                ?.restaurantOrderId ??
                                            '',
                                        date:
                                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                        waiterName:
                                            '${order?.restaurantDetails?.restaurantWaiterName ?? ''}',
                                        tablename: (order?.restaurantDetails
                                                        ?.restaurantTableNo ??
                                                    '') ==
                                                ''
                                            ? (order?.orderDetailsOrder?.orderType ==
                                                    'delivery'
                                                ? 'Delivery'
                                                : order?.orderDetailsOrder
                                                            ?.orderType ==
                                                        'take_away'
                                                    ? 'Take Away'
                                                    : 'WC')
                                            : (order?.restaurantDetails
                                                            ?.restaurantTableArea ??
                                                        '') ==
                                                    ''
                                                ? '${order?.restaurantDetails?.restaurantTableNo ?? ''}'
                                                : '${order?.restaurantDetails?.restaurantTableArea ?? ''}:${order?.restaurantDetails?.restaurantTableNo ?? ''}',
                                        custName:
                                            order?.orderDetailsOrder?.username ?? '',
                                        custPhone: '${order?.orderUser?.phone ?? ''}',
                                        paidFoodList: order?.orderDetailsFood ?? [],
                                        orderNote: order?.orderDetailsOrder?.orderNote ?? '',
                                        orderSubTotal: subTotal,
                                        discount: order?.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                        serviceChargeAmount: double.parse(order?.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                        deliveryCharge: order?.orderDetailsOrder?.deliveryCharge ?? 0,
                                        gstAmount: double.parse(order?.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                        vatAmount: double.parse(order?.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                        grandTotal: order?.orderDetailsOrder?.orderAmount ?? 0,
                                        tips: order?.orderDetailsOrder?.tipAmount ?? 0,
                                        orderType: order?.orderDetailsOrder?.orderType ?? ''));
                              } else {
                                await _kdsPrintEscPos(await PrintByteConvert()
                                    .byteConvert(
                                        couponCode: couponCode,
                                        couponDiscount: couponDiscount,
                                        loyaltyUsed: loyaltyPoint,
                                        walletUsed: usedWallet,
                                        printType: 'paid_bill',
                                        paymentType: order!.orderDetailsOrder
                                                ?.paymentMethod ??
                                            '',
                                        paperRoll: Get.find<AuthController>()
                                                    .profileModel!
                                                    .billPrinterPaperRoll ==
                                                58
                                            ? 58
                                            : 80,
                                        orderId: order?.orderDetailsOrder
                                                ?.restaurantOrderId ??
                                            '',
                                        date:
                                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                        waiterName:
                                            '${order?.restaurantDetails?.restaurantWaiterName ?? ''}',
                                        tablename: (order?.restaurantDetails
                                                        ?.restaurantTableNo ??
                                                    '') ==
                                                ''
                                            ? (order?.orderDetailsOrder?.orderType ==
                                                    'delivery'
                                                ? 'Delivery'
                                                : order?.orderDetailsOrder
                                                            ?.orderType ==
                                                        'take_away'
                                                    ? 'Take Away'
                                                    : 'WC')
                                            : (order?.restaurantDetails
                                                            ?.restaurantTableArea ??
                                                        '') ==
                                                    ''
                                                ? '${order?.restaurantDetails?.restaurantTableNo ?? ''}'
                                                : '${order?.restaurantDetails?.restaurantTableArea ?? ''}:${order?.restaurantDetails?.restaurantTableNo ?? ''}',
                                        custName:
                                            order?.orderDetailsOrder?.username ?? '',
                                        custPhone: '${order?.orderUser?.phone ?? ''}',
                                        paidFoodList: order?.orderDetailsFood ?? [],
                                        orderNote: order?.orderDetailsOrder?.orderNote ?? '',
                                        orderSubTotal: subTotal,
                                        discount: order?.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                        serviceChargeAmount: double.parse(order?.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                        deliveryCharge: order?.orderDetailsOrder?.deliveryCharge ?? 0,
                                        gstAmount: double.parse(order?.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                        vatAmount: double.parse(order?.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                        grandTotal: order?.orderDetailsOrder?.orderAmount ?? 0,
                                        tips: order?.orderDetailsOrder?.tipAmount ?? 0,
                                        orderType: order?.orderDetailsOrder?.orderType ?? ''));
                              }
                            }
                          },
                          child: SvgPicture.asset(
                            Images.ic_print_kot,
                            height:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 37
                                    : 26,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              Row(
                children: [
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('order_unpaid'))
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          widget.paidSearch.clear();

                          Map<String, dynamic> jsonBody = {
                            'order_id': order.id.toString(),
                          };
                          Get.find<KdsController>().makeUnpaidOrder(i, jsonBody,
                              (bool isSuccess, String message) async {},
                              type: 'tab');
                        },
                        child: Container(
                          // width: 110,
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                              color: ColorTheme.appColor,
                              // border:
                              //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(
                            child: Text(
                              'Unpaid',
                              style: poppinsSemiBold.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 15
                                          : 13,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      widget.paidSearch.clear();

                      await Get.find<KdsController>().clearPaidOrderDetail();
                      Get.toNamed(
                        RouteHelper.gePaidOrderDetailtRoute(
                            Get.find<KdsController>()
                                .getTabOrdersResponse!
                                .orders[i]
                                .id
                                .toString()),
                      );
                      // await Get.find<KdsController>().getPaidOrderDetail(
                      //     '${Get.find<KdsController>().getPaidOrders?.orders[i].id}');
                    },
                    child: Container(
                      // width: 110,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: ColorTheme.appColor,
                          // border:
                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
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
        ],
      ),
    );
  }

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023, 6),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;

      await Get.find<KdsController>()
          .getTabOrderList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }

  // Future kdsBytesConvert() async {
  //   List<OrderDetailsFood> foodOrderList = [];
  //   pendingTask = [];
  //   List<int> bytes = [];

  //   foodOrderList.addAll(Get.find<KdsController>()
  //       .paidOrderDetailResponse
  //       .orders
  //       .orderDetailsFood);

  //   final profile = await CapabilityProfile.load(name: 'XP-N160I');
  //   final generator = Generator(
  //       Get.find<AuthController>().profileModel.billPrinterPaperRoll == 58
  //           ? PaperSize.mm58
  //           : PaperSize.mm80,
  //       profile);
  //   bytes += generator.setGlobalCodeTable('CP1252');

  //   if (logoHelper.logoUrlPrint != null) {
  //     try {
  //       bytes += generator.feed(1);
  //       bytes += generator.image(logoHelper.logoUrlPrint);
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  //   bytes += generator.text(
  //       Get.find<AuthController>().profileModel.restaurants[0].name,
  //       styles: PrinterConfig().titleStyle());
  //   bytes += generator.text(
  //       Get.find<AuthController>().profileModel.restaurants[0].address,
  //       styles: PrinterConfig().addressStyle());

  //   if (Get.find<AuthController>().profileModel.restaurants[0].gstCode != '')
  //     bytes += generator.text(
  //         'GST no. ${Get.find<AuthController>().profileModel.restaurants[0].gstCode}',
  //         styles: PrinterConfig().gstStyle());
  //   if (Get.find<AuthController>().profileModel.restaurants[0].fssai != '')
  //     bytes += generator.text(
  //         'FSI no. ${Get.find<AuthController>().profileModel.restaurants[0].fssai}',
  //         styles: PrinterConfig().gstStyle());
  //   bool isShowDate = Get.find<AuthController>()
  //               .profileModel
  //               .restaurants
  //               .first
  //               .showFoodDate ==
  //           'Yes'
  //       ? true
  //       : false;
  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'order_id'.tr +
  //             ':' +
  //             ' ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId == '0' ? Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id : Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId}',
  //         width: 6,
  //         styles: PrinterConfig().orderIdStyle()),
  //     PosColumn(
  //         text:
  //             '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.createdAt))}',
  //         // DateConverter.dateTimeStringToMonthAndTime(
  //         //     DateTime.now().toString()),
  //         width: 6,
  //         styles: PrinterConfig().orderCreateDateStyle()),
  //   ]);
  //   bytes += generator.row([
  //     PosColumn(
  //         text: Get.find<KdsController>()
  //                     .paidOrderDetailResponse
  //                     .orders
  //                     .orderDetailsOrder
  //                     .orderType ==
  //                 'billing'
  //             ? 'Billing'
  //             : 'Dine In',
  //         width: 5,
  //         styles: PrinterConfig().dineInStyle()),
  //     PosColumn(
  //       text: '',
  //       width: 1,
  //       styles: PrinterConfig().dineInStyle(),
  //     ),
  //     PosColumn(
  //         text:
  //             '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantWaiterName}',
  //         // text:
  //         //     '${Get.find<AuthController>().profileModel.empFname} ${Get.find<AuthController>().profileModel.empLname}',
  //         width: 6,
  //         styles: PrinterConfig().waiterNameStyle()),
  //   ]);
  //   // bytes += generator.text(
  //   //     Get.find<KdsController>()
  //   //                 .paidOrderDetailResponse
  //   //                 .orders
  //   //                 .restaurantDetails
  //   //                 .restaurantTableNo ==
  //   //             ''
  //   //         ? 'WC'
  //   //         : '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantTableArea}:${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantTableNo}',
  //   //     styles: const PosStyles(
  //   //         align: PosAlign.center,
  //   //         height: PosTextSize.size3,
  //   //         width: PosTextSize.size2,
  //   //         bold: true,
  //   //         fontType: PosFontType.fontA));
  //   if (Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser !=
  //       null) {
  //     String name =
  //         '${Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser.fName} ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser.lName}';
  //     String phone = Get.find<KdsController>()
  //         .paidOrderDetailResponse
  //         .orders
  //         .orderUser
  //         .phone;
  //     phone == ''
  //         ? bytes += generator.text(
  //             '${name ?? ''}',
  //             styles: PosStyles(
  //               align: PosAlign.left,
  //             ),
  //           )
  //         : bytes += generator.row([
  //             PosColumn(
  //               text: '${name ?? ''}',
  //               width: 5,
  //               styles: PosStyles(
  //                 height: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? PosTextSize.size1
  //                     : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList
  //                         .split(',')
  //                         .first),
  //                 width: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? PosTextSize.size1
  //                     : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList
  //                         .split(',')[1]),
  //                 bold: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? false
  //                     : Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList
  //                                 .split(',')
  //                                 .last ==
  //                             'true'
  //                         ? true
  //                         : false,
  //                 align: PosAlign.left,
  //                 // fontType: PosFontType.fontB,
  //               ),
  //             ),
  //             PosColumn(
  //               text: '',
  //               width: 2,
  //               styles: PosStyles(align: PosAlign.center, underline: true),
  //             ),
  //             PosColumn(
  //               text: '${phone ?? ''}',
  //               width: 5,
  //               styles: PosStyles(
  //                 height: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? PosTextSize.size1
  //                     : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList
  //                         .split(',')
  //                         .first),
  //                 width: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? PosTextSize.size1
  //                     : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList
  //                         .split(',')[1]),
  //                 bold: Get.find<AuthController>().profileModel.printConfig ==
  //                             null ||
  //                         Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList ==
  //                             null
  //                     ? false
  //                     : Get.find<AuthController>()
  //                                 .profileModel
  //                                 .printConfig
  //                                 .restaurantFoodList
  //                                 .split(',')
  //                                 .last ==
  //                             'true'
  //                         ? true
  //                         : false,
  //                 align: PosAlign.right,
  //                 fontType: PosFontType.fontB,
  //               ),
  //             ),
  //           ]);
  //   } else if (Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .username !=
  //       '') {
  //     bytes += generator.text(
  //       Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .username,
  //       styles: PosStyles(
  //         height: Get.find<AuthController>().profileModel.printConfig == null ||
  //                 Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList ==
  //                     null
  //             ? PosTextSize.size1
  //             : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                 .profileModel
  //                 .printConfig
  //                 .restaurantFoodList
  //                 .split(',')
  //                 .first),
  //         width: Get.find<AuthController>().profileModel.printConfig == null ||
  //                 Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList ==
  //                     null
  //             ? PosTextSize.size1
  //             : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                 .profileModel
  //                 .printConfig
  //                 .restaurantFoodList
  //                 .split(',')[1]),
  //         bold: Get.find<AuthController>().profileModel.printConfig == null ||
  //                 Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList ==
  //                     null
  //             ? false
  //             : Get.find<AuthController>()
  //                         .profileModel
  //                         .printConfig
  //                         .restaurantFoodList
  //                         .split(',')
  //                         .last ==
  //                     'true'
  //                 ? true
  //                 : false,
  //         align: PosAlign.left,
  //         fontType: PosFontType.fontB,
  //       ),
  //     );
  //   }
  //   bytes += generator.hr(ch: '--');

  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'SL',
  //         width: isShowDate ? 1 : 2,
  //         styles: PrinterConfig().foodStyle()),
  //     PosColumn(
  //       text: 'item_info'.tr,
  //       width: isShowDate ? 4 : 5,
  //       styles: PrinterConfig().foodStyle(),
  //     ),
  //     PosColumn(
  //       text: 'qty'.tr,
  //       width: isShowDate ? 3 : 2,
  //       styles: PrinterConfig().foodStyle(),
  //     ),
  //     PosColumn(
  //       text: 'Price',
  //       width: isShowDate ? 2 : 3,
  //       styles: PrinterConfig().foodStyle(),
  //     ),
  //     if (isShowDate)
  //       PosColumn(
  //         text: 'Date',
  //         width: 2,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //   ]);
  //   bytes += generator.hr(ch: '--');
  //   for (var i = 0; i < foodOrderList.length; i++) {
  //     OrderDetailsFood food = foodOrderList[i];
  //     String variationText = '';
  //     String addons = '';

  //     int variationTotal = 0;
  //     double addonsTotal = 0;

  //     if (food.variation != null && food.variation.isNotEmpty) {
  //       variationText += '(';
  //       List<String> labelList = [];
  //       for (int j = 0; j < food.variation.length; j++) {
  //         // variationText +=
  //         //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

  //         if (food.variation[j].values != null) {
  //           for (var element in food.variation[j].values) {
  //             labelList.add(element.label);
  //             variationTotal +=
  //                 (int.parse(element.optionPrice) * food.quantity);
  //           }
  //           // variationText +=
  //           //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
  //         }

  //         // variationText += ')';
  //       }
  //       variationText += '${labelList.join(',')}';
  //       variationText += ')';
  //     }

  //     for (var i = 0; i < food.addOns.length; i++) {
  //       addons += '${food.addOns[i].name} (${food.addOns[i].quantity})';
  //       addonsTotal =
  //           addonsTotal + (food.addOns[i].price * food.addOns[i].quantity);
  //     }

  //     bytes += generator.row([
  //       PosColumn(
  //           text: '${i + 1}.',
  //           width: isShowDate ? 1 : 2,
  //           styles: PrinterConfig().foodStyle()),
  //       PosColumn(
  //         text: '${food.foodDetails.name} $variationText',
  //         width: 5,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //       PosColumn(
  //         text: '${food.quantity}',
  //         width: isShowDate ? 1 : 2,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //       PosColumn(
  //         text: '${(food.price + variationTotal).toStringAsFixed(2)}',
  //         // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
  //         width: 3,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //       if (isShowDate)
  //         PosColumn(
  //           text:
  //               '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
  //           width: 2,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //     ]);
  //     if (addons != '' && addonsTotal != 0) {
  //       bytes += generator.hr(ch: '....');
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: isShowDate ? 1 : 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //           text: 'Add-Ons :$addons',
  //           width: 5,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: isShowDate ? 1 : 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //         PosColumn(
  //           text: '${addonsTotal.toStringAsFixed(2)}',
  //           width: 3,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         if (isShowDate)
  //           PosColumn(
  //             text: '',
  //             width: 2,
  //             styles: PosStyles(align: PosAlign.center),
  //           ),
  //       ]);
  //     }
  //     if (food.foodStatus != 3 &&
  //         Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .orderNote !=
  //             '' &&
  //         food.foodDetails.name.toString().toLowerCase().contains('out of')) {
  //       bytes += generator.hr(ch: '....');
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: isShowDate ? 1 : 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //             text:
  //                 'Notes  :${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.orderNote}',
  //             width: 5,
  //             styles: PrinterConfig().foodStyle()),
  //         PosColumn(
  //           text: '',
  //           width: isShowDate ? 1 : 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: 3,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //         if (isShowDate)
  //           PosColumn(
  //             text: '',
  //             width: 2,
  //             styles: PosStyles(align: PosAlign.center),
  //           ),
  //       ]);
  //     }
  //     // if (variationText != '' && variationTotal != 0) {
  //     //   bytes += generator.hr(ch: '....');
  //     //   bytes += generator.row([
  //     //     PosColumn(
  //     //       text: '',
  //     //       width: isShowDate ? 1 : 2,
  //     //       styles: PosStyles(
  //     //         align: PosAlign.center,
  //     //       ),
  //     //     ),
  //     //     PosColumn(
  //     //       text: 'Variants  :$variationText',
  //     //       width: 5,
  //     //       styles: PrinterConfig().foodStyle(),
  //     //     ),
  //     //     PosColumn(
  //     //       text: '',
  //     //       width: isShowDate ? 1 : 2,
  //     //       styles: PosStyles(align: PosAlign.center),
  //     //     ),
  //     //     PosColumn(
  //     //       text: '$variationTotal',
  //     //       width: 3,
  //     //       styles: PosStyles(align: PosAlign.center),
  //     //     ),
  //     //     if (isShowDate)
  //     //       PosColumn(
  //     //         text: '',
  //     //         width: 2,
  //     //         styles: PosStyles(align: PosAlign.center),
  //     //       ),
  //     //   ]);
  //     // }

  //     bytes += generator.hr(ch: '....');
  //   }

  //   bytes += generator.hr(ch: '....');

  //   bytes += generator.row([
  //     PosColumn(
  //       text: '',
  //       width: 2,
  //       styles: PosStyles(
  //         align: PosAlign.center,
  //       ),
  //     ),
  //     PosColumn(
  //       text: 'Sub Total ',
  //       width: 5,
  //       styles: PrinterConfig().subtotalStyle(),
  //     ),
  //     PosColumn(
  //       text: '',
  //       width: 2,
  //       styles: PrinterConfig().subtotalStyle(),
  //     ),
  //     PosColumn(
  //       text: PriceConverter.convertPrice(
  //           Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderTotalAmount +
  //               Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderTotalAddonAmt +
  //               Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderTotalVariantAmt,
  //           isHideCurrency: true,
  //           asFixed: 2),
  //       width: 3,
  //       styles: PrinterConfig().subtotalStyle(),
  //     ),
  //   ]);
  //   if (Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .restaurantDiscountAmount !=
  //       0)
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'Add Discount ',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .restaurantDiscountAmount,
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   if (Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .tipAmount !=
  //       0)
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'Add Tips ',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .tipAmount,
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);

  //   if (double.parse(Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .totalServiceTaxAmount) !=
  //       0)
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'Service Charge',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             double.parse(Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .totalServiceTaxAmount),
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   if (Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .deliveryCharge !=
  //       0)
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'Delivery Charge',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .deliveryCharge,
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   if (double.parse(Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .totalGstTaxAmount) !=
  //       0) {
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'CGST ',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             double.parse(Get.find<KdsController>()
  //                     .paidOrderDetailResponse
  //                     .orders
  //                     .orderDetailsOrder
  //                     .totalGstTaxAmount) /
  //                 2,
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   }
  //   if (double.parse(Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .totalGstTaxAmount) !=
  //       0) {
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'SGST ',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             double.parse(Get.find<KdsController>()
  //                     .paidOrderDetailResponse
  //                     .orders
  //                     .orderDetailsOrder
  //                     .totalGstTaxAmount) /
  //                 2,
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   }
  //   if (double.parse(Get.find<KdsController>()
  //           .paidOrderDetailResponse
  //           .orders
  //           .orderDetailsOrder
  //           .totalVatTaxAmount) !=
  //       0) {
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(
  //           align: PosAlign.center,
  //         ),
  //       ),
  //       PosColumn(
  //         text: 'VAT ',
  //         width: 5,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //         text: PriceConverter.convertPrice(
  //             double.parse(Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .totalVatTaxAmount),
  //             isHideCurrency: true,
  //             asFixed: 2),
  //         width: 3,
  //         styles: PrinterConfig().subtotalStyle(),
  //       ),
  //     ]);
  //   }

  //   bytes += generator.hr(ch: '....');
  //   bytes += generator.text(
  //     'Total: ' +
  //         PriceConverter.convertPrice(
  //             Get.find<KdsController>()
  //                 .paidOrderDetailResponse
  //                 .orders
  //                 .orderDetailsOrder
  //                 .orderAmount,
  //             isHideCurrency: true,
  //             asFixed: 2) +
  //         ' ${Get.find<AuthController>().profileModel?.restaurants?.first?.currency ?? ''}',
  //     styles: PrinterConfig().totalStyle(),
  //   );
  //   bytes += generator.hr(ch: '....');

  //   if (Get.find<AuthController>().profileModel.restaurants.first.feedback ==
  //       'Yes') {
  //     try {
  //       const double qrSize = 170;
  //       final uiImg = await QrPainter(
  //         data:
  //             '${AppConstants.FEEDBACK_BASE_URL}?orderId=${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id}',
  //         version: QrVersions.auto,
  //         gapless: false,
  //       ).toImageData(qrSize);
  //       final dir = await getTemporaryDirectory();
  //       final pathName = '${dir.path}/qr_tmp.png';
  //       final qrFile = File(pathName);
  //       final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
  //       final img = prefix.decodeImage(imgFile.readAsBytesSync());
  //       bytes += generator.text('Scan to provide feedback',
  //           styles: const PosStyles(
  //               align: PosAlign.center,
  //               height: PosTextSize.size1,
  //               width: PosTextSize.size1,
  //               bold: true,
  //               fontType: PosFontType.fontA));

  //       bytes += generator.feed(1);
  //       bytes += generator.image(img);
  //       bytes += generator.feed(1);
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  //   if (Get.find<AuthController>()
  //           .profileModel
  //           .restaurants
  //           .first
  //           .footerTextBill !=
  //       '') {
  //     bytes += generator.text(
  //         Get.find<AuthController>()
  //             .profileModel
  //             .restaurants
  //             .first
  //             .footerTextBill,
  //         styles: const PosStyles(
  //             align: PosAlign.center,
  //             height: PosTextSize.size1,
  //             width: PosTextSize.size1,
  //             // bold: true,
  //             fontType: PosFontType.fontB));
  //   }
  //   bytes += generator.text('Powered by MyGenie',
  //       styles: const PosStyles(
  //           align: PosAlign.center,
  //           height: PosTextSize.size1,
  //           width: PosTextSize.size1,
  //           // bold: true,
  //           fontType: PosFontType.fontB));
  //   bytes += generator.cut();

  //   if (Platform.isAndroid) {
  //     await _kdsPrintEscPos(bytes); //kitchen
  //   } else {
  //     await _iosPrintEscPos(bytes); //kitchen
  //   }
  // }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          port: '9100',
          typePrinter:
              (Get.find<AuthController>().profileModel!.billPrinterType ?? '')
                          .toLowerCase() ==
                      'wifi'
                  ? PrinterType.network
                  : PrinterType.bluetooth,
          address:
              (Get.find<AuthController>().profileModel!.billPrinterType ?? '')
                          .toLowerCase() ==
                      'wifi'
                  ? Get.find<AuthController>().profileModel!.billWifiIp
                  : Get.find<AuthController>().profileModel!.billPrinterIp,
          deviceName: Get.find<AuthController>()
              .profileModel!
              .billPrinterName); // ip was mandadory
    }

    // var data;
    // if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
    //   data = await printerManager!.connect(
    //     type: PrinterType.usb,
    //     model: UsbPrinterInput(
    //       productId: Get.find<AuthController>().profileModel!.billProductId,
    //       vendorId: Get.find<AuthController>().profileModel!.billVendorId,
    //     ),
    //   );
    // } else {
    //   data = await printerManager!.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(

    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address!,
    //     ),
    //   );
    // }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
        await printerManager!.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await printerManager!.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = [];
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        await printerManager!.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');

    try {
      await printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      if (numberOfPrint > 1) {
        for (int i = 1; i < numberOfPrint; i++) {
          Future.delayed(Duration(
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
          await printerManager.send(
              type: bluetoothPrinter.typePrinter, bytes: bytes);
        }
      }
      // await printerManager!
      //     .send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      await Future.delayed(
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
        // if (Get.find<AuthController>()
        //         .profileModel!
        //         .restaurants!
        //         .first
        //         .settings!
        //         .printBillCustomerCopy ==
        //     'Yes') {
        //   await printCustomerCopy(bytes, bluetoothPrinter);
        // } else {
        pendingTask = [];
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance
            .disconnect(type: bluetoothPrinter.typePrinter);
        // }
      });
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    // if (data != null && !data) {
  }

  Future<void> _iosPrintEscPos(List<int> bytes) async {
    print('########## bytes length ${bytes.length}');
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');

    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
      macPrinterAddress:
          Get.find<AuthController>().profileModel!.macBillPrinterIp!,
    );

    // Small delay after connect (important on iPad)
    await Future.delayed(const Duration(seconds: 2));

    if (!result) {
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Failed to bluetooth connect!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
      return;
    }

    try {
      // 🔥 iPad-safe chunked write (MOST IMPORTANT PART)
      Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
          ? await IosPrintTransport.writeBytes(bytes)
          : await _writeBytesForIPad(bytes);
      if (numberOfPrint > 1) {
        for (int i = 1; i < numberOfPrint; i++) {
          Future.delayed(Duration(
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
      // Wait a bit to ensure printer finishes printing
      await Future.delayed(
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
        pendingTask = [];
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
      });
    } catch (e) {
      print('Print error: $e');
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Printing failed!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 255; // 🔥 SAFE for all iPads
    const int delayMs = 60; // Required for 80mm stability

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }
  // Future _iosPrintEscPos(List<int> bytes) async {
  //   await PrintBluetoothThermal.pairedBluetooths;

  //   // Future.delayed(Duration(seconds: 5), () async {
  //   final bool result = await PrintBluetoothThermal.connect(
  //       macPrinterAddress:
  //           Get.find<AuthController>().profileModel!.macBillPrinterIp!);

  //   Future.delayed(Duration(seconds: 1), () async {
  //     if (result) {
  //       // List<int> ticket = await testTicket();
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
  //         Get.find<LoadingController>().startLoading(false);

  //         await Get.find<LoadingController>()
  //             .changeText(data: 'Successfully printed!!');
  //         await Get.find<LoadingController>().changeStatus(data: true);
  //         var isDisconnect = await PrintBluetoothThermal.disconnect;
  //         print('is disconnect $isDisconnect');
  //       });
  //       print("print test result:  $result");
  //     } else {
  //       //no conectado, reconecte
  //       Get.find<LoadingController>().startLoading(false);

  //       await Get.find<LoadingController>()
  //           .changeText(data: 'Failed to bluetooth connect!!', error: true);
  //       await Get.find<LoadingController>().changeStatus(data: true);
  //       // showErrorToast('Failed to bluetooth connect');
  //     }
  //     // });
  //   });
  //   // });
  // }
}
