import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
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

class RoomOrderContent extends StatefulWidget {
  final TextEditingController paidSearch;
  RoomOrderContent({required this.paidSearch});

  @override
  State<RoomOrderContent> createState() => _RoomOrderContentState();
}

class _RoomOrderContentState extends State<RoomOrderContent> {
  PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
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
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              Future.delayed(Duration(seconds: 11), () async {
                await PrinterManager.instance
                    .disconnect(type: PrinterType.bluetooth);
              });
              pendingTask = [];
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
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
                      .getPaidRoomOrdersResponse
                      ?.orders
                      .length ??
                  0,
              itemBuilder: (BuildContext context, int i) {
                var order = Get.find<KdsController>()
                    .getPaidRoomOrdersResponse!
                    .orders[i]
                    .primaryOrder;

                bool isSearchTextMatched = widget.paidSearch.text.isEmpty ||
                    (order!.restaurantOrderId
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase())) ||
                    (order.phone
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch.text.toUpperCase())) ||
                    (order.userName
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
    var order = Get.find<KdsController>()
        .getPaidRoomOrdersResponse!
        .orders[i]
        .primaryOrder;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: ColorTheme.roomCardBgColor),
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Id',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order!.restaurantOrderId}',
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
                      'Room Number',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.roomNumber}',
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
                      'Waiter Name',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.waiterName}',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
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
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                            ),
                            Text(
                              '${order.fName} ${order.lName}',
                              style: poppinsSemiBold.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
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
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                            ),
                            Text(
                              '${order.phone}',
                              style: poppinsSemiBold.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                            )
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.PADDING_SIZE_DEFAULT),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Room Price',
                              style: poppinsSemiBold.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                            ),
                            Text(
                              '${convertRoundOff(order.roomAmount ?? 0)} ₹',
                              style: poppinsSemiBold.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Amount',
                            style: poppinsSemiBold.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                          Text(
                            '${convertRoundOff(order.orderAmount!)} ₹',
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
                            'Grand Total',
                            style: poppinsSemiBold.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                          Text(
                            '${convertRoundOff(Get.find<KdsController>().getPaidRoomOrdersResponse!.orders[i].roomGrandTotal + (order.roomAmount ?? 0))} ₹',
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
                            'Payment Method',
                            style: poppinsSemiBold.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                          Text(
                            '${order.paymentMethod}',
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
                            'Time',
                            style: poppinsSemiBold.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.parse(order.collectBillDate!)),
                            style: poppinsSemiBold.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (Get.find<KdsController>()
              .getPaidRoomOrdersResponse!
              .orders[i]
              .associatedOrders
              .isNotEmpty)
            SizedBox(height: 20),
          if (Get.find<KdsController>()
              .getPaidRoomOrdersResponse!
              .orders[i]
              .associatedOrders
              .isNotEmpty)
            ExpansionTile(
              backgroundColor: Color.fromRGBO(254, 245, 208, 1),
              collapsedBackgroundColor: Color.fromRGBO(254, 245, 208, 1),
              tilePadding: EdgeInsets.symmetric(horizontal: 20),
              childrenPadding: EdgeInsets.symmetric(horizontal: 20),
              title: Row(
                children: [
                  Text(
                    'Associated Orders (${Get.find<KdsController>().getPaidRoomOrdersResponse?.orders[i].associatedOrders.length ?? 0})',
                    style: poppinsSemiBold.copyWith(
                      fontSize: 15,
                      color: ColorTheme.disableButtonText,
                    ),
                  ),
                ],
              ),
              children: Get.find<KdsController>()
                  .getPaidRoomOrdersResponse!
                  .orders[i]
                  .associatedOrders
                  .map((e) {
                return Column(
                  children: [
                    // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Id',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          '${e.restaurantOrderId}',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          '${convertRoundOff(e.orderAmount ?? 0)}',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(e.transferOrderDate!)),
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                  ],
                );
              }).toList(),
            ),

          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('printer')
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
                                  '${Get.find<KdsController>().getPaidRoomOrdersResponse!.orders[i].primaryOrder!.id}',
                                  isShowLoader: false);
                              // kdsBytesConvert();
                              Orders? order = Get.find<KdsController>()
                                  .paidOrderDetailResponse
                                  ?.orders;
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
                                            (orderDetailsFood
                                                    .variation?.length ??
                                                0);
                                        j++) {
                                      if (orderDetailsFood
                                              .variation?[j].values !=
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
                                          if ((orderDetailsFood
                                                      .variation?[j].name
                                                      ?.toUpperCase() ??
                                                  '') ==
                                              'HALFNHALF') {
                                            if (halfVariationPrice <
                                                (double.tryParse(element
                                                                .optionPrice ??
                                                            '0') ??
                                                        0) *
                                                    (orderDetailsFood
                                                            .quantity ??
                                                        0)) {
                                              halfVariationPrice = (double
                                                          .tryParse(element
                                                                  .optionPrice ??
                                                              '0') ??
                                                      0) *
                                                  (orderDetailsFood.quantity ??
                                                      0);
                                            }
                                          } else {
                                            variationTotal = variationTotal +
                                                ((double.tryParse(element
                                                                .optionPrice ??
                                                            '0') ??
                                                        0) *
                                                    (orderDetailsFood
                                                            .quantity ??
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
                                                printType: 'paid_bill',
                                                paymentType: order!
                                                        .orderDetailsOrder
                                                        ?.paymentMethod ??
                                                    '',
                                                paperRoll: Get.find<AuthController>()
                                                            .profileModel!
                                                            .billPrinterPaperRoll ==
                                                        58
                                                    ? 58
                                                    : 80,
                                                orderId: order!
                                                    .orderDetailsOrder!
                                                    .restaurantOrderId,
                                                date:
                                                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(order.orderDetailsOrder!.createdAt!))}',
                                                waiterName:
                                                    '${order.restaurantDetails!.restaurantWaiterName}',
                                                tablename: order
                                                            .restaurantDetails!
                                                            .restaurantTableNo ==
                                                        ''
                                                    ? order.orderDetailsOrder
                                                                ?.orderType ==
                                                            'delivery'
                                                        ? 'Delivery'
                                                        : order.orderDetailsOrder?.orderType == 'take_away'
                                                            ? 'Take Away'
                                                            : 'WC'
                                                    : order.restaurantDetails!.restaurantTableArea == ''
                                                        ? '${order.restaurantDetails!.restaurantTableNo}'
                                                        : '${order.restaurantDetails!.restaurantTableArea}:${order.restaurantDetails!.restaurantTableNo}',
                                                custName: order.orderDetailsOrder?.username ?? '',
                                                custPhone: '${order.orderUser?.phone ?? ''}',
                                                paidFoodList: order.orderDetailsFood ?? [],
                                                orderNote: order.orderDetailsOrder?.orderNote ?? '',
                                                orderSubTotal: subTotal,
                                                discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                                serviceChargeAmount: double.parse(order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                                deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
                                                gstAmount: double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                                vatAmount: double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                                grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
                                                tips: order.orderDetailsOrder?.tipAmount ?? 0,
                                                orderType: order.orderDetailsOrder?.orderType),
                                      );
                                      await Future.delayed(
                                          Duration(seconds: 2));
                                    }
                                    break;
                                  }
                                }
                                Get.find<LoadingController>()
                                    .startLoading(false);

                                await Get.find<LoadingController>()
                                    .changeText(data: 'Successfully printed!!');
                                await Get.find<LoadingController>()
                                    .changeStatus(data: true);
                              } else {
                                if (Platform.isIOS) {
                                  await _iosPrintEscPos(await PrintByteConvert()
                                      .byteConvert(
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
                                          orderType: order?.orderDetailsOrder?.orderType ?? ''));
                                } else {
                                  await _kdsPrintEscPos(await PrintByteConvert()
                                      .byteConvert(
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
                    // if (Get.find<AuthController>()
                    //     .profileModel!
                    //     .role!
                    //     .contains('order_unpaid'))
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
                              type: 'room');
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
                                  .getPaidRoomOrdersResponse!
                                  .orders[i]
                                  .primaryOrder!
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
                                    MediaQuery.of(context).size.shortestSide >
                                            570
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
          .getPaidRoomOrderList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }

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

  // Future _iosPrintEscPos(List<int> bytes) async {
  //   // bytes += generator.feed(2);
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
}
