import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/change_payment_method/widget/change_payment_method_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChangePaymentOrderContent extends StatefulWidget {
  final TextEditingController paidSearch;
  const ChangePaymentOrderContent({Key? key, required this.paidSearch})
      : super(key: key);

  @override
  State<ChangePaymentOrderContent> createState() =>
      _ChangePaymentOrderContentState();
}

class _ChangePaymentOrderContentState extends State<ChangePaymentOrderContent> {
  String selectedPaymentMethod = 'All';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
  }

  @override
  void dispose() {
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
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                        color: Colors.grey,
                      ),
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
              const SizedBox(width: 10),
              Container(
                height:
                    MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                  border: Border.all(color: ColorTheme.borderGrey),
                ),
                child: DropdownButton<String>(
                  value: selectedPaymentMethod,
                  items: <String>[
                    'All',
                    'Cash',
                    'Card',
                    'UPI',
                    'Credit',
                    'Room'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
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
                  onChanged: (String? newValue) {
                    if (mounted && newValue != null) {
                      setState(() {
                        selectedPaymentMethod = newValue;
                      });
                    }
                  },
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  widget.paidSearch.clear();
                  _selectDate(context);
                },
                child: Container(
                  height:
                      MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey),
                  ),
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
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                Get.find<KdsController>().getPaidOrders?.orders.length ?? 0,
            itemBuilder: (BuildContext context, int i) {
              var order = Get.find<KdsController>().getPaidOrders?.orders[i];
              bool isPaymentMethodMatched = (Get.find<KdsController>()
                          .selectedWaiter
                          ?.name ==
                      'All')
                  ? (selectedPaymentMethod == 'All'
                      ? ((order?.paymentMethod?.toUpperCase() == 'CASH') ||
                          (order?.paymentMethod?.toUpperCase() == 'CARD') ||
                          (order?.paymentType?.toLowerCase() == 'prepaid') ||
                          (order?.paymentType?.toLowerCase() == 'tab') ||
                          (order?.paymentType?.toLowerCase() == 'room') ||
                          (order?.paymentMethod?.toUpperCase() == 'UPI'))
                      : selectedPaymentMethod == 'Pre-Paid'
                          ? (order?.paymentType?.toLowerCase() == 'prepaid')
                          : (order?.paymentMethod?.toString().toUpperCase() ==
                              selectedPaymentMethod.toUpperCase()))
                  : ((Get.find<KdsController>().selectedWaiter?.id ==
                          order?.employeeId) &&
                      (selectedPaymentMethod == 'All'
                          ? ((order?.paymentMethod?.toUpperCase() == 'CASH') ||
                              (order?.paymentMethod?.toUpperCase() == 'CARD') ||
                              (order?.paymentType?.toLowerCase() ==
                                  'prepaid') ||
                              (order?.paymentType?.toLowerCase() == 'tab') ||
                              (order?.paymentType?.toLowerCase() == 'room') ||
                              (order?.paymentMethod?.toUpperCase() == 'UPI'))
                          : selectedPaymentMethod == 'Pre-Paid'
                              ? (order?.paymentType?.toLowerCase() == 'prepaid')
                              : order?.paymentMethod.toString().toUpperCase() ==
                                  selectedPaymentMethod.toUpperCase()));

              bool isSearchTextMatched = widget.paidSearch.text.isEmpty ||
                  (order!.restaurantOrderId
                      .toString()
                      .toUpperCase()
                      .contains(widget.paidSearch.text.toUpperCase())) ||
                  (order.email
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

              return isPaymentMethodMatched && isSearchTextMatched
                  ? orderBox(i)
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget orderBox(int i) {
    var order = Get.find<KdsController>().getPaidOrders!.orders[i];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        color: const Color.fromRGBO(254, 245, 208, 1),
      ),
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
                if (order.email != '')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.email != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.email}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      )
                    ],
                  ),
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
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Get.find<AuthController>().profileModel!.role!.contains('printer')
                  ? Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            widget.paidSearch.clear();
                            Get.bottomSheet(
                              ChangePaymentMethodDialog(
                                order: order,
                                orderId: order.id.toString(),
                              ),
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              ignoreSafeArea: false,
                            );
                          },
                          child:
                              Icon(Icons.sync_alt, color: ColorTheme.appColor),
                        ),
                      ],
                    )
                  : const SizedBox(),
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  widget.paidSearch.clear();
                  Map<String, dynamic> jsonBody = {
                    'order_id': order.id.toString(),
                  };
                  Get.find<KdsController>().makeUnpaidOrder(
                      i, jsonBody, (bool isSuccess, String message) async {});
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: ColorTheme.appColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      'Un-Paid',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                        color: Colors.white,
                      ),
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
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await Get.find<KdsController>()
          .getPaidOrderList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }
}
