import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/pay_later_collect_bill.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/show_paid_order_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/styles.dart';

class PayLaterOrderScreen extends StatefulWidget {
  const PayLaterOrderScreen({Key? key}) : super(key: key);

  @override
  State<PayLaterOrderScreen> createState() => _PayLaterOrderScreenState();
}

class _PayLaterOrderScreenState extends State<PayLaterOrderScreen> {
  DateTime? selectedDate;
  Map<String, bool> _fetchingPaymentLink = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await Get.find<KdsController>().getPayLaterOrderList('');
  }

  final TextEditingController paidController = TextEditingController();

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
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.13,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          const SizedBox(height: 20),
          GetBuilder<KdsController>(builder: (kdsController) {
            return kdsController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_LARGE),
                    child: orderList());
          }),
        ]),
      ),
    );
  }

  Widget orderList() {
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
                    controller: paidController,
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
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  paidController.clear();
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

                final auth = Get.find<AuthController>();
                final restaurant = auth.profileModel!.restaurants!.first;

                final searchBy = restaurant.searchBy ?? [];

                bool tableMatch =
                    //  searchBy.contains('table no') &&
                    (order!.tableNo!
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase()));

                bool orderIdMatch =
                    //  searchBy.contains('order id') &&
                    (order!.restaurantOrderId
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase()));

                bool userMatch =
                    // searchBy.contains('user id') &&
                    ((order!.username
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase())));

                bool phoneMatch =
                    // searchBy.contains('phone no') &&
                    ((order.phone
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase())));
                bool isSearchTextMatched = paidController.text.isEmpty ||
                    orderIdMatch ||
                    phoneMatch ||
                    userMatch ||
                    tableMatch;

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
    var order = Get.find<KdsController>().getPaidOrders!.orders[i];

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
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      paidController.clear();

                      await Get.find<KdsController>().clearPaidOrderDetail();
                      if (order.paymentMethod!.toLowerCase() == 'paylater') {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => PayLaterCollectBill(
                                    orderId: order.id.toString())));
                        await Get.find<KdsController>().getPayLaterOrderList(
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

                  // Only show icon buttin if razorpay is configured
                  if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .razorPayDetail !=
                              null &&
                          Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .razorPayDetail!
                                  .key !=
                              null &&
                          Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .razorPayDetail!
                                  .key !=
                              ''
                      //      &&
                      // order.isPaymentLinkSent != 'Yes'
                      ) ...[
                    SizedBox(width: 10),
                    _fetchingPaymentLink[order.id.toString()] == true
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorTheme.appColor,
                            ),
                          )
                        : InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              final auth = Get.find<AuthController>();

                              final billData = {
                                "payment_amount": auth.profileModel!
                                            .restaurants!.first.isTotalRound ==
                                        'Yes'
                                    ? getRoundUpValue(value: order.orderAmount)
                                    : order.orderAmount,
                                "customer_name": '${order.fName}'.trim(),
                                "customer_phone": order.phone,
                                "restaurant_name":
                                    auth.profileModel!.restaurants!.first.name,
                                "order_id": order.id,
                              };

    
                              setState(() {
                                _fetchingPaymentLink[order.id.toString()] =
                                    true;
                              });

                              final String? paymentLink =
                                  await Get.find<CartController>()
                                      .sendWhatsappPaymentLink(billData);
                              setState(() {
                                _fetchingPaymentLink[order.id.toString()] =
                                    false;
                              });

                              if (paymentLink != null) {
                                await Clipboard.setData(
                                    ClipboardData(text: paymentLink));
                                showToastSuccess('Payment link copied');
                              } else {
                                showErrorToast('Failed to fetch payment link');
                              }
                            },
                            child: Icon(
                              Icons.copy,
                              size: 18,
                              color: ColorTheme.appColor,
                            ),
                          ),
                  ]
                ],
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

      await Get.find<KdsController>()
          .getPayLaterOrderList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }
}
