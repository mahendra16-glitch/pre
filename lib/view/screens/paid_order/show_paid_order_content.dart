import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/beep.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/pay_later_collect_bill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as prefix;
import 'package:intl/intl.dart';

import '../../../util/print_byte_convert.dart';
import '../change_payment_method/widget/change_payment_method_dialog.dart';

class PaidOrdersContent extends StatefulWidget {
  final TextEditingController? paidSearch;
  PaidOrdersContent({this.paidSearch});

  @override
  State<PaidOrdersContent> createState() => _PaidOrdersContentState();
}

class _PaidOrdersContentState extends State<PaidOrdersContent> {
  PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  BTStatus currentStatus = BTStatus.none;
  PaymentModes? selectedPaymentMethod;
  List<PaymentModes> paymentList = [];
  @override
  void initState() {
    super.initState();

    paymentList.add(PaymentModes(displayName: 'All', name: 'All'));
    selectedPaymentMethod = paymentList.first;
    paymentList.add(PaymentModes(displayName: 'Pre-Paid', name: 'Pre-Paid'));
    paymentList.addAll(Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .paymentModes!);
    paymentList.removeWhere((item) => item.name!.toLowerCase() == 'tab');
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
              Container(
                height:
                    MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: DropdownButton<PaymentModes>(
                  value: selectedPaymentMethod,
                  items: paymentList.map<DropdownMenuItem<PaymentModes>>(
                      (PaymentModes value) {
                    return DropdownMenuItem<PaymentModes>(
                      value: value,
                      child: Text(
                        value.displayName ?? '',
                        style: poppinsMedium.copyWith(
                          color: Colors.grey,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (PaymentModes? newValue) {
                    if (mounted)
                      setState(() {
                        selectedPaymentMethod = newValue!;
                      });
                  },
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  widget.paidSearch!.clear();
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
              itemCount:
                  Get.find<KdsController>().getPaidOrders?.orders.length ?? 0,
              itemBuilder: (BuildContext context, int i) {
                var order = Get.find<KdsController>().getPaidOrders?.orders[i];
                bool isPaymentMethodMatched = (Get.find<KdsController>()
                                .selectedWaiter
                                ?.name ??
                            '') ==
                        'All'
                    ? (selectedPaymentMethod!.name == 'All'
                        ? true
                        : selectedPaymentMethod!.name == 'Pre-Paid'
                            ? (order?.paymentType?.toLowerCase() == 'prepaid')
                            : (order?.paymentMethod?.toString().toUpperCase() ==
                                selectedPaymentMethod!.name!.toUpperCase()))
                    : (Get.find<KdsController>().selectedWaiter?.id ==
                            order?.employeeId &&
                        (selectedPaymentMethod!.name == 'All'
                            ? true
                            : selectedPaymentMethod!.name == 'Pre-Paid'
                                ? (order?.paymentType?.toLowerCase() ==
                                    'prepaid')
                                : (order?.paymentMethod
                                        ?.toString()
                                        .toUpperCase() ==
                                    selectedPaymentMethod!.name!
                                        .toUpperCase())));
                final auth = Get.find<AuthController>();
                final restaurant = auth.profileModel!.restaurants!.first;

                final searchBy = restaurant.searchBy ?? [];

                bool tableMatch =
                    //  searchBy.contains('table no') &&
                    (order!.tableNo!
                        .toUpperCase()
                        .contains(widget.paidSearch!.text.toUpperCase()));

                bool orderIdMatch =
                    //  searchBy.contains('order id') &&
                    (order.restaurantOrderId
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch!.text.toUpperCase()));

                bool userMatch =
                    // searchBy.contains('user id') &&
                    ((order.username
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch!.text.toUpperCase())));

                bool phoneMatch =
                    // searchBy.contains('phone no') &&
                    ((order.phone
                        .toString()
                        .toUpperCase()
                        .contains(widget.paidSearch!.text.toUpperCase())));
                bool isSearchTextMatched = widget.paidSearch!.text.isEmpty ||
                    orderIdMatch ||
                    phoneMatch ||
                    userMatch ||
                    tableMatch;

                // Check if both conditions are matched
                return isPaymentMethodMatched && isSearchTextMatched
                    ? orderBox(i)
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget orderBox(int i) {
    var order = Get.find<KdsController>().getPaidOrders!.orders[i];
    final customerName = ('${order.fName} ${order.lName}').trim().isNotEmpty
        ? '${order.fName} ${order.lName}'.trim()
        : (order.username ?? '').trim();

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
             Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .settings!
                                              .useDisplayToken ==
                                          'Yes'
                                      ? '${order.restaurantOrderId} (${order.tokenNo})'
                                      : '${order.restaurantOrderId}',
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
          if (order.tableNo != '')
            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          if (order.tableNo != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table No',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                ),
                Text(
                  '${order.tableNo}',
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
                if (customerName.isNotEmpty)
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (customerName.isNotEmpty)
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
                        customerName,
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
                // if (order.email != '')
                //   SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                // if (order.email != '')
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'Email',
                //         style: poppinsSemiBold.copyWith(
                //           fontSize:
                //               MediaQuery.of(context).size.shortestSide > 570
                //                   ? 15
                //                   : 13,
                //         ),
                //       ),
                //       Text(
                //         '${order.email}',
                //         style: poppinsSemiBold.copyWith(
                //           fontSize:
                //               MediaQuery.of(context).size.shortestSide > 570
                //                   ? 15
                //                   : 13,
                //         ),
                //       )
                //     ],
                //   ),
                // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Order Amount',
                //       style: poppinsSemiBold.copyWith(
                //         fontSize: MediaQuery.of(context).size.shortestSide > 570
                //             ? 15
                //             : 13,
                //       ),
                //     ),
                //     Text(
                //       '${order.orderAmount} ₹',
                //       style: poppinsSemiBold.copyWith(
                //         fontSize: MediaQuery.of(context).size.shortestSide > 570
                //             ? 15
                //             : 13,
                //       ),
                //     )
                //   ],
                // ),
                if (order.paymentMethod!.toLowerCase() == 'card')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.paymentMethod!.toLowerCase() == 'card')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction No',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.transactionNo}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
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
                            .isShowTips ==
                        'Yes' &&
                    double.parse(order.tipAmount) != 0)
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .isShowTips ==
                        'Yes' &&
                    double.parse(order.tipAmount) != 0)
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
                        '${order.orderAmount - double.parse(order.tipAmount)} ₹',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
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
                            .isShowTips ==
                        'Yes' &&
                    double.parse(order.tipAmount) != 0)
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .isShowTips ==
                        'Yes' &&
                    double.parse(order.tipAmount) != 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tip Amount',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.tipAmount} ₹',
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
                      'Total Amount',
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
                if (order.paymentMethod!.toLowerCase() == 'partial')
                  ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var partialPayment = order.partialPayments![index];
                      return partialPayment.amount == '' ||
                              partialPayment.amount == '0'
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                SizedBox(
                                    height: Dimensions.PADDING_SIZE_DEFAULT),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Partial Payment (${partialPayment.paymentMode})',
                                      style: poppinsSemiBold.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 13,
                                      ),
                                    ),
                                    Text(
                                      '₹ ${partialPayment.amount}',
                                      style: poppinsSemiBold.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 13,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            );
                    },
                    itemCount: order.partialPayments?.length ?? 0,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                if (order.paymentType!.toLowerCase() == 'prepaid')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.paymentType!.toLowerCase() == 'prepaid')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Type',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.paymentType}',
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
              Row(
                children: [
                  Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('printer')
                      ? InkWell(
                          onTap: () async {
                            widget.paidSearch!.clear();
                            double subTotal = 0;
                            await Get.find<KdsController>()
                                .clearPaidOrderDetail();
                            double couponDiscount = 0;
                            double loyaltyPoint = 0;
                            double usedWallet = 0;
                            String couponCode = '';

                            // await kdsBytesConvert(order.orderDetailsFood,
                            //     order.orderDetailsOrder.id.toString());
                            await Get.find<KdsController>().getPaidOrderDetail(
                                '${Get.find<KdsController>().getPaidOrders!.orders[i].id}',
                                isShowLoader: false);
                            // kdsBytesConvert();
                            Orders order = Get.find<KdsController>()
                                .paidOrderDetailResponse!
                                .orders!;
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
                                        ?.mergeFoodListWithDate !=
                                    null) {
                              for (var orderDetailsFood
                                  in Get.find<KdsController>()
                                          .paidOrderDetailResponse
                                          ?.orders
                                          ?.mergeFoodListWithDate ??
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
                                    (orderDetailsFood.isComplementary == 1
                                        ? 0
                                        : (orderDetailsFood.price +
                                            variationTotal +
                                            (addonsTotal *
                                                orderDetailsFood.quantity!)));
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
                                              paymentType: order
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
                                              orderId: order.orderDetailsOrder!
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
                                              custName: order.orderDetailsOrder?.username ?? '',
                                              custPhone: '${order.orderUser?.phone ?? ''}',
                                              paidFoodList: order.mergeFoodListWithDate ?? [],
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
                                    await Future.delayed(Duration(seconds: 2));
                                  }
                                  beepWindows();

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
                                        paymentType: order.orderDetailsOrder
                                                ?.paymentMethod ??
                                            '',
                                        paperRoll: Get.find<AuthController>()
                                                    .profileModel!
                                                    .billPrinterPaperRoll ==
                                                58
                                            ? 58
                                            : 80,
                                        orderId: order.orderDetailsOrder
                                                ?.restaurantOrderId ??
                                            '',
                                        date:
                                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                        waiterName:
                                            '${order.restaurantDetails?.restaurantWaiterName ?? ''}',
                                        tablename: (order.restaurantDetails
                                                        ?.restaurantTableNo ??
                                                    '') ==
                                                ''
                                            ? (order.orderDetailsOrder?.orderType ==
                                                    'delivery'
                                                ? 'Delivery'
                                                : order.orderDetailsOrder
                                                            ?.orderType ==
                                                        'take_away'
                                                    ? 'Take Away'
                                                    : 'WC')
                                            : (order.restaurantDetails
                                                            ?.restaurantTableArea ??
                                                        '') ==
                                                    ''
                                                ? '${order.restaurantDetails?.restaurantTableNo ?? ''}'
                                                : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
                                        custName:
                                            order.orderDetailsOrder?.username ?? '',
                                        custPhone: '${order.orderUser?.phone ?? ''}',
                                        paidFoodList: order.mergeFoodListWithDate ?? [],
                                        orderNote: order.orderDetailsOrder?.orderNote ?? '',
                                        orderSubTotal: subTotal,
                                        discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                        serviceChargeAmount: double.parse(order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                        deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
                                        gstAmount: double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                        vatAmount: double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                        grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
                                        tips: order.orderDetailsOrder?.tipAmount ?? 0,
                                        orderType: order.orderDetailsOrder?.orderType ?? ''));
                              } else {
                                await _kdsPrintEscPos(await PrintByteConvert()
                                    .byteConvert(
                                        couponCode: couponCode,
                                        couponDiscount: couponDiscount,
                                        loyaltyUsed: loyaltyPoint,
                                        walletUsed: usedWallet,
                                        printType: 'paid_bill',
                                        paymentType: order.orderDetailsOrder
                                                ?.paymentMethod ??
                                            '',
                                        paperRoll: Get.find<AuthController>()
                                                    .profileModel!
                                                    .billPrinterPaperRoll ==
                                                58
                                            ? 58
                                            : 80,
                                        orderId: order.orderDetailsOrder
                                                ?.restaurantOrderId ??
                                            '',
                                        date:
                                            '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                        waiterName:
                                            '${order.restaurantDetails?.restaurantWaiterName ?? ''}',
                                        tablename: (order.restaurantDetails
                                                        ?.restaurantTableNo ??
                                                    '') ==
                                                ''
                                            ? (order.orderDetailsOrder?.orderType ==
                                                    'delivery'
                                                ? 'Delivery'
                                                : order.orderDetailsOrder
                                                            ?.orderType ==
                                                        'take_away'
                                                    ? 'Take Away'
                                                    : 'WC')
                                            : (order.restaurantDetails
                                                            ?.restaurantTableArea ??
                                                        '') ==
                                                    ''
                                                ? '${order.restaurantDetails?.restaurantTableNo ?? ''}'
                                                : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
                                        custName:
                                            order.orderDetailsOrder?.username ?? '',
                                        custPhone: '${order.orderUser?.phone ?? ''}',
                                        paidFoodList: order.mergeFoodListWithDate ?? [],
                                        orderNote: order.orderDetailsOrder?.orderNote ?? '',
                                        orderSubTotal: subTotal,
                                        discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                                        serviceChargeAmount: double.parse(order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                                        deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
                                        gstAmount: double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                                        vatAmount: double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                                        grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
                                        tips: order.orderDetailsOrder?.tipAmount ?? 0,
                                        orderType: order.orderDetailsOrder?.orderType ?? ''));
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
                        )
                      : SizedBox.shrink(),
                  if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('update_payment') &&
                      order.paymentMethod!.toLowerCase() != 'paylater')
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: InkWell(
                          onTap: () async {
                            widget.paidSearch!.clear();
                            Get.bottomSheet(
                                ChangePaymentMethodDialog(
                                  order: order,
                                  orderId: order.id.toString(),
                                ),
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                ignoreSafeArea: false);
                          },
                          child:
                              Icon(Icons.sync_alt, color: ColorTheme.appColor)),
                    ),
                ],
              ),
              Row(
                children: [
                  if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('order_unpaid') &&
                      order.paymentMethod!.toLowerCase() != 'paylater')
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          widget.paidSearch!.clear();
                          if (order.paymentType == 'prepaid' &&
                              order.onlinePay != null &&
                              order.onlinePay!.isNotEmpty &&
                              order.onlinePay!.first.referenceId != '' &&
                              order.onlinePay!.first.status == 'paid') {
                            var data = {
                              "order_id": order.id.toString(),
                              "cancellation_reason": "Customer Cancelled",
                              "cancellation_note": "User requested cancel"
                            };
                            Get.find<KdsController>().makeUnpaidOrder(
                                i,
                                data,
                                type: 'razorpay',
                                (bool isSuccess, String message) async {});
                          } else {
                            Map<String, dynamic> jsonBody = {
                              'order_id': order.id.toString(),
                            };

                            Get.find<KdsController>().makeUnpaidOrder(
                                i,
                                jsonBody,
                                (bool isSuccess, String message) async {});
                          }
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
                      widget.paidSearch!.clear();

                      await Get.find<KdsController>().clearPaidOrderDetail();
                      if (order.paymentMethod!.toLowerCase() == 'paylater') {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => PayLaterCollectBill(
                                    orderId: order.id.toString())));
                        await Get.find<KdsController>().getPaidOrderList(
                            DateFormat('yyyy-MM-dd')
                                .format(selectedDate ?? DateTime.now()));
                      } else {
                        Get.toNamed(
                          RouteHelper.gePaidOrderDetailtRoute(
                              Get.find<KdsController>()
                                  .getPaidOrders!
                                  .orders[i]
                                  .id
                                  .toString()),
                        );
                      }
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
                          order.paymentMethod!.toLowerCase() == 'paylater'
                              ? 'Pay Bill'
                              : 'Details',
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
    if (picked != selectedDate) {
      selectedDate = picked;

      await Get.find<KdsController>()
          .getPaidOrderList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes) async {
    BluetoothPrinter bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = BluetoothPrinter(
        productId: Get.find<AuthController>().profileModel!.billProductId,
        vendorId: Get.find<AuthController>().profileModel!.billVendorId,
        typePrinter: PrinterType.usb,
      );
    } else {
      bluetoothPrinter = BluetoothPrinter(
        port: '9100',
        address: Get.find<AuthController>().profileModel!.billWifiIp != ''
            ? Get.find<AuthController>().profileModel!.billWifiIp
            : Get.find<AuthController>().profileModel!.billPrinterIp,
        deviceName: Get.find<AuthController>().profileModel!.billPrinterName,
        typePrinter: Get.find<AuthController>().profileModel!.billWifiIp != ''
            ? PrinterType.network
            : PrinterType.bluetooth,
      );
    }

    dynamic data;
    // if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
    //   data = await printerManager.connect(
    //     type: PrinterType.usb,
    //     model: UsbPrinterInput(
    //       productId: Get.find<AuthController>().profileModel!.billProductId,
    //       vendorId: Get.find<AuthController>().profileModel!.billVendorId,
    //     ),
    //   );
    // } else {
    //   data = await printerManager.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(
    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address!,
    //     ),
    //   );
    // }

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        data = await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        data = await printerManager.connect(
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
        data = await printerManager.connect(
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
        type: bluetoothPrinter.typePrinter,
        bytes: bytes,
      );
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
        pendingTask = [];
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance
            .disconnect(type: bluetoothPrinter.typePrinter);
        // }
      });
    } catch (e) {
      // Handle error if needed
    }
    if (data != null && data is bool && !data) {
      await Get.find<LoadingController>().changeText(
        data: Get.find<AuthController>().profileModel!.billPrinterType == 'usb'
            ? 'Failed to usb connect!!'
            : 'Failed to bluetooth connect!!',
        error: true,
      );
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  // Future _iosPrintEscPos(List<int> bytes) async {
  //   // bytes += generator.feed(2);
  //   await PrintBluetoothThermal.pairedBluetooths;

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
        var isDisconnect = await IosPrintTransport.disconnect;
        print('is disconnect $isDisconnect');
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
