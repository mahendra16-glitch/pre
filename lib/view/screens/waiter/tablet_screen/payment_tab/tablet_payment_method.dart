import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_respone.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
import 'package:mygenie_restaurant/util/beep.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/tap_managment_reesponse_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as prefix;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../helper/date_converter.dart';
import '../../../../../util/print_byte_convert.dart';

class TabletSelectPaymentMethodTab extends StatelessWidget {
  final String orderId;
  final String selectedDiscountType;
  final TextEditingController transactionNoController;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController cGstNoController;
  final TextEditingController cGstNameController;
  final TextEditingController discountController;
  final TextEditingController paidController;
  final TextEditingController emailController;
  final TextEditingController changeController;
  final TextEditingController tipsController;
  final TextEditingController couponController;

  Function printCallbak;
  final double orderTotal;
  final double orderSubTotal;
  final double roomTotalPayment;
  final double orderItemTotal;
  final double vatAmount;
  final double gstAmount;
  final double serviceValue;
  final double orderDiscount;
  final double coummunityDiscount;
  final double coummunityDiscountPercentage;
  final double tipTaxAmount;
  final double discountPercent;
  final PrinterManager printerManager;
  PosController posController;
  bool isPrint;
  bool ispayRoom;
  bool? isAutoBillPrint;
  bool? isFromPaylater;
  bool? isCouponValid;
  bool? isLoyaltyApply;
  double? loyltyDiscountAmount;
  double? crmLoyaltyPoints;
  String? crmCouponCode;
  String? crmCouponTitle;
  String? crmCouponScope;
  double? crmCouponRupee;
  double? usedWalletAmount;
  double? gstOnDeliveryCharge;
  String? couponDiscountType;
  String? couponUserId;
  String? discountType;
  List<int> pendingTask;
  final List<Map<String, dynamic>>? jsonCartList;
  final List roomBillsList;

  DiscountCategoryListModel? selectedDiscount;

  TabletSelectPaymentMethodTab({
    required this.orderId,
    required this.discountPercent,
    required this.selectedDiscountType,
    required this.transactionNoController,
    required this.phoneController,
    required this.nameController,
    required this.cGstNoController,
    required this.cGstNameController,
    required this.discountController,
    required this.paidController,
    required this.changeController,
    required this.tipsController,
    required this.couponController,
    required this.printCallbak,
    required this.orderTotal,
    required this.orderSubTotal,
    required this.roomTotalPayment,
    required this.orderItemTotal,
    required this.vatAmount,
    required this.gstAmount,
    required this.serviceValue,
    required this.orderDiscount,
    required this.coummunityDiscount,
    required this.emailController,
    required this.coummunityDiscountPercentage,
    required this.printerManager,
    required this.tipTaxAmount,
    required this.isPrint,
    required this.ispayRoom,
    required this.pendingTask,
    required this.posController,
    required this.isAutoBillPrint,
    required this.isCouponValid,
    required this.isFromPaylater,
    required this.couponUserId,
    required this.couponDiscountType,
    required this.jsonCartList,
    required this.isLoyaltyApply,
    required this.loyltyDiscountAmount,
    this.crmLoyaltyPoints = 0,
    this.crmCouponCode = '',
    this.crmCouponTitle = '',
    this.crmCouponScope = '',
    this.crmCouponRupee = 0,
    required this.usedWalletAmount,
    required this.discountType,
    this.gstOnDeliveryCharge,
    this.selectedDiscount,
    this.roomBillsList = const [],
  });

  TextEditingController pCash = TextEditingController(text: '0');
  TextEditingController pCard = TextEditingController(text: '0');
  TextEditingController pUpi = TextEditingController(text: '0');
  TextEditingController pTXN = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (paidController.text.isNotEmpty) {
      if (double.parse(paidController.text) >
          (posController.collectItemPrice +
              roomTotalPayment +
              (posController.getCollectBillDetailResponse?.orders?.roomInfo
                      ?.remainingPay ??
                  0))) {
        changeController.text = (double.parse(paidController.text) -
                roomTotalPayment -
                posController.collectItemPrice -
                (posController.getCollectBillDetailResponse?.orders?.roomInfo
                        ?.remainingPay ??
                    0))
            .toStringAsFixed(2);
      } else {
        changeController.text = '0';
      }
    } else {
      changeController.text = '';
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 15, right: 15,
            top: Dimensions.PADDING_SIZE_DEFAULT,
            bottom: Dimensions.PADDING_SIZE_SMALL,
            // left: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorTheme.bgSettleCardGreyColor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: GetBuilder<PosController>(builder: (posController) {
                // Update changeController based on paidController value

                return Column(
                  children: [
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('clear_payment'))
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            Get.find<AuthController>()
                                    .profileModel
                                    ?.restaurants
                                    ?.first
                                    .paymentModes
                                    ?.length ??
                                0,
                            (index) {
                              PaymentModes? item = Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .paymentModes![index];

                              // ROOM condition (same as your existing logic)
                              if (item!.name!.toLowerCase() == 'room') {
                                final pos = Get.find<PosController>();

                                final isRoomAllowed = pos
                                            .getCollectBillDetailResponse!
                                            .orders
                                            ?.restaurantDetails
                                            ?.restaurantOrderFor !=
                                        'ROOM' &&
                                    pos.getCollectBillDetailResponse!.orders
                                            ?.orderDetailsOrder?.orderType !=
                                        'delivery' &&
                                    pos.getCollectBillDetailResponse!.orders
                                            ?.orderDetailsOrder?.orderType !=
                                        'take_away';

                                if (!isRoomAllowed)
                                  return const SizedBox.shrink();
                              }
                              if ((item.name!.toLowerCase() == 'paylater' &&
                                      isFromPaylater!) ||
                                  item.isPostpaid == 0) {
                                return const SizedBox.shrink();
                              }
                              return InkWell(
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  // Reset only when needed
                                  pCash.text = '0';
                                  pCard.text = '0';
                                  pUpi.text = '0';

                                  posController.setPaymentTabName(item.name!);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                      horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          posController.paymentTab == item.name
                                              ? Colors.transparent
                                              : ColorTheme.borderGrey,
                                    ),
                                    color: posController.paymentTab == item.name
                                        ? ColorTheme.appColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.displayName ?? '',
                                      style: poppinsMedium.copyWith(
                                        fontSize: 15,
                                        color: posController.paymentTab ==
                                                item.name
                                            ? Colors.white
                                            : ColorTheme.appColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('clear_payment'))
                      SizedBox(height: 15),
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('clear_payment'))
                      DottedLine(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        lineThickness: 1.0,
                        dashLength: 2.5,
                        dashColor: ColorTheme.hintText,
                      ),

                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('clear_payment'))
                      posController.paymentTab.toLowerCase() == 'room'
                          ? GetBuilder<PosController>(builder: (posController) {
                              return posController.roomList.isNotEmpty
                                  ? Column(
                                      children: [
                                        if (Get.find<PosController>()
                                                .getCollectBillDetailResponse!
                                                .orders!
                                                .restaurantDetails!
                                                .restaurantOrderFor !=
                                            'ROOM')
                                          Container(
                                            height: 50,
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 15),
                                            // width: Get.width * 0.8,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorTheme.borderGrey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: DropdownButton<
                                                GetRoomListResponse>(
                                              isExpanded: true,
                                              icon: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorTheme.appColor,
                                              ),
                                              value: posController
                                                          .selectedRoom ==
                                                      null
                                                  ? posController.roomList.first
                                                  : posController.selectedRoom,
                                              items: posController.roomList.map(
                                                  (GetRoomListResponse value) {
                                                return DropdownMenuItem<
                                                    GetRoomListResponse>(
                                                  value: value,
                                                  child: Text(
                                                    '${value.table!.title} ${value.table!.tableNo}',
                                                    maxLines: 1,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color:
                                                          value.table!.id == 0
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged:
                                                  (GetRoomListResponse? value) {
                                                posController
                                                    .setRoomIndex(value);

                                                if (value!.user != null) {
                                                  nameController.clear();
                                                  phoneController.clear();
                                                  if (value.user!.fName != '') {
                                                    nameController.text =
                                                        value.user!.fName;
                                                  }
                                                }
                                                if (value.user != null) {
                                                  if (value.user!.phone != '') {
                                                    phoneController.text =
                                                        value.user!.phone;
                                                  }
                                                }
                                              },
                                              underline: SizedBox(),
                                            ),
                                          ),
                                        Row(
                                          children: [
                                            nameTextField(context),
                                            SizedBox(width: 15),
                                            phoneTextField(context),
                                          ],
                                        ),
                                        // Padding(
                                        //   padding:
                                        //       const EdgeInsets.only(
                                        //           top: 15),
                                        //   child:
                                        //       emailTextField(context),
                                        // ),
                                      ],
                                    )
                                  : SizedBox.shrink();
                            })
                          : Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.PADDING_SIZE_LARGE,
                              ),
                              child: Column(
                                children: [
                                  // SizedBox(
                                  //     height: Dimensions
                                  //         .PADDING_SIZE_DEFAULT),

                                  if (posController.paymentTab.toLowerCase() ==
                                      'tab')
                                    Row(
                                      children: [
                                        nameTextField(context),
                                        SizedBox(width: 15),
                                        phoneTextField(context),
                                      ],
                                    ),

                                  if (posController.paymentTab.toLowerCase() ==
                                      'cash')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            child: TextField(
                                              controller: paidController,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly, // Allow only digits
                                              ],
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                      style: BorderStyle.none,
                                                      width: 0),
                                                ),
                                                hintStyle:
                                                    poppinsMedium.copyWith(
                                                        fontSize: 15,
                                                        color: Colors.grey),
                                                filled: true,
                                                hintText: 'Paid',
                                                fillColor: Colors.white,
                                              ),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                              onChanged: (value) async {
                                                if (paidController
                                                    .text.isEmpty) {
                                                  changeController.text = '';
                                                } else {
                                                  if (double.parse(
                                                          paidController.text) >
                                                      (posController
                                                              .collectItemPrice +
                                                          roomTotalPayment +
                                                          (posController
                                                                  .getCollectBillDetailResponse
                                                                  ?.orders
                                                                  ?.roomInfo
                                                                  ?.remainingPay ??
                                                              0))) {
                                                    changeController.text =
                                                        '${(double.parse(paidController.text) - roomTotalPayment - posController.collectItemPrice - (posController.getCollectBillDetailResponse?.orders?.roomInfo?.remainingPay ?? 0)).toStringAsFixed(2)}';
                                                  } else {
                                                    changeController.text = '0';
                                                  }
                                                }
                                                // posController.update();
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .RADIUS_SMALL),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            child: TextField(
                                              controller: changeController,
                                              autofocus: false,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    borderSide: BorderSide(
                                                        style: BorderStyle.none,
                                                        width: 0),
                                                  ),
                                                  hintStyle:
                                                      poppinsMedium.copyWith(
                                                          fontSize: 15,
                                                          color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  hintText: 'Change'),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                              onChanged: (value) async {},
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        phoneTextField(context)
                                      ],
                                    ),
                                  if (posController.paymentTab.toLowerCase() ==
                                      'card')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            child: TextField(
                                              controller:
                                                  transactionNoController,
                                              autofocus: false,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                      style: BorderStyle.none,
                                                      width: 0),
                                                ),
                                                hintStyle:
                                                    poppinsMedium.copyWith(
                                                        fontSize: 15,
                                                        color: Colors.grey),
                                                hintText: 'Transaction No.',
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                              onChanged: (value) async {},
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        phoneTextField(context)
                                      ],
                                    ),
                                  if (posController.paymentTab.toLowerCase() ==
                                      'upi')
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: posController.paymentTab
                                                      .toLowerCase() ==
                                                  'upi'
                                              ? 0
                                              : 15),
                                      child: Row(
                                        children: [
                                          phoneTextField(context),
                                        ],
                                      ),
                                    ),
                                  if (posController.paymentTab.toLowerCase() ==
                                      'partial')
                                    partialPayment(),
                                  posController.paymentTab.toLowerCase() ==
                                          'upi'
                                      ? posController
                                                  .getCollectBillDetailResponse!
                                                  .orders!
                                                  .paymentUrl ==
                                              ''
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: CachedNetworkImage(
                                                  // height: 40,
                                                  // width: 40,

                                                  imageUrl: posController
                                                      .getCollectBillDetailResponse!
                                                      .orders!
                                                      .paymentUrl
                                                      .replaceAll(
                                                          'amount=${posController.getCollectBillDetailResponse!.orders!.orderTotalFood}',
                                                          'amount=${Get.find<AuthController>().profileModel!.restaurants!.first.dynamicUpiValue == 'No' ? 0 : convertRoundOff(roomTotalPayment + posController.collectItemPrice + (Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.remainingPay ?? 0))}')),
                                            )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ), // : SizedBox.shrink(),
                    posController.isLoading
                        ? CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('printer') &&
                                      !posController.isEDCLoading)
                                    GetBuilder<KdsController>(
                                        builder: (kdsController) {
                                      return InkWell(
                                          onTap: () async {
                                            int numberOfPrint = int.parse(
                                                Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurants!
                                                        .first
                                                        .settings!
                                                        .noOfBillPrint ??
                                                    '1');
                                            if (Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurants!
                                                        .first
                                                        .printingOption ==
                                                    'Fixed' &&
                                                Get.find<AuthController>()
                                                        .profileModel
                                                        ?.defaultUser !=
                                                    'Yes') {
                                              print(
                                                  'ye rha fixed user ke liye print');
                                              final collectivetotalprice =
                                                  Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isTotalRound ==
                                                          'Yes'
                                                      ? getRoundUpValue(
                                                          value: Get.find<
                                                                  PosController>()
                                                              .collectItemPrice)
                                                      : Get.find<
                                                              PosController>()
                                                          .collectItemPrice;
                                                           double serviceGstTax = Get.find<
                                                            PosController>()
                                                        .isAddServiceCharge
                                                    ? ((((serviceValue ?? 0.0) *
                                                            Get.find<
                                                                    AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .serviceChargeTaxPercent!) /
                                                        100))
                                                    : 0;
                                              Map<String, dynamic>
                                                  manualPrintJson = {
                                                "order_id": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.orderDetailsOrder
                                                        ?.id ??
                                                    '',
                                                'restaurant_order_id': posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.orderDetailsOrder
                                                        ?.restaurantOrderId ??
                                                    '',
                                                "print_type": "bill",
                                                "payment_amount": (Get.find<
                                                                    PosController>()
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.restaurantDetails
                                                                ?.restaurantOrderFor ==
                                                            'ROOM' &&
                                                        roomBillsList
                                                            .isNotEmpty)
                                                    ? (collectivetotalprice -
                                                            (posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.roomInfo
                                                                    ?.remainingPay ??
                                                                0.0))
                                                        .toStringAsFixed(2)
                                                    :  Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isTotalRound ==
                                                          'Yes' ?  getRoundUpValue(
                                                          value:(Get.find<PosController>()
                                                            .collectItemPrice +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0.0))) : Get.find<PosController>()
                                                            .collectItemPrice +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0.0),
                                                "grant_amount": (Get.find<
                                                                    PosController>()
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.restaurantDetails
                                                                ?.restaurantOrderFor ==
                                                            'ROOM' &&
                                                        roomBillsList
                                                            .isNotEmpty)
                                                    ? collectivetotalprice +
                                                        roomTotalPayment
                                                    : Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isTotalRound ==
                                                          'Yes' ?  getRoundUpValue(
                                                          value:(Get.find<PosController>()
                                                            .collectItemPrice +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0.0))) :Get.find<PosController>()
                                                            .collectItemPrice +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0.0) ,
                                                "order_item_total":
                                                    orderItemTotal,
                                                'order_subtotal': orderSubTotal,
                                                "discount_amount":
                                                    orderDiscount,
                                                "coupon_code": isCouponValid!
                                                    ? (couponController.text ??
                                                        '')
                                                    : '',
                                                "loyalty_dicount_amount":
                                                    loyltyDiscountAmount,
                                                "wallet_used_amount":
                                                    usedWalletAmount,
                                                "Date": (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.createdAt !=
                                                            null &&
                                                        Get.find<AuthController>()
                                                                .profileModel
                                                                ?.restaurants !=
                                                            null &&
                                                        Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .isNotEmpty)
                                                    ? DateFormat(Get.find<AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .billDateFormat ??
                                                            'yyyy-MM-dd')
                                                        .format(DateTime.parse(
                                                            posController
                                                                .getCollectBillDetailResponse!
                                                                .orders!
                                                                .orderDetailsOrder!
                                                                .createdAt!))
                                                    : '',
                                                "waiterName": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.restaurantDetails
                                                        ?.waiterName ??
                                                    '',
                                                "tablename": (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.restaurantDetails
                                                                ?.tableNo ??
                                                            '') ==
                                                        ''
                                                    ? (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.orderType ==
                                                            'delivery'
                                                        ? 'Delivery'
                                                        : (posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.orderDetailsOrder
                                                                    ?.orderType ==
                                                                'take_away'
                                                            ? 'Take Away'
                                                            : 'WC'))
                                                    : (posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.restaurantDetails
                                                                    ?.tableArea ??
                                                                '') ==
                                                            ''
                                                        ? (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.restaurantDetails
                                                                ?.tableNo ??
                                                            '')
                                                        : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                                                "custName":
                                                    nameController.text ?? '',
                                                "custPhone":
                                                    phoneController.text ?? '',
                                                "custGSTName": "",
                                                "custGST": "",
                                                "billFoodList": (posController
                                                            .getCollectBillDetailResponse
                                                            ?.orders
                                                            ?.mergeFoodListWithDate ??
                                                        [])
                                                    .map((e) => e.toJson())
                                                    .toList(),
                                                "orderNote": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.orderDetailsOrder
                                                        ?.orderNote ??
                                                    '',
                                                "serviceChargeAmount":
                                                    serviceValue,
                                                "roomRemainingPay": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.roomInfo
                                                        ?.remainingPay ??
                                                    0,
                                                "roomAdvancePay": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.roomInfo
                                                        ?.advancePay ??
                                                    0,
                                                "roomGst": 0,
                                                "deliveryCustName": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.name ??
                                                    '',
                                                "deliveryAddressType": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.addressType ??
                                                    '',
                                                "deliveryCustAddress": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.address ??
                                                    '',
                                                "deliveryCustPincode": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.pincode ??
                                                    '',
                                                "deliveryCustPhone": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.phone ??
                                                    '',
                                                "deliveryCustHouse": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.house ??
                                                    '',
                                                "deliveryCustFloor": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.deliveryAddress
                                                        ?.floor ??
                                                    '',
                                                "Tip": double.tryParse(
                                                        tipsController.text ??
                                                            '0') ??
                                                    0.0,
                                                'station_kot': '',
                                                "order_type": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.orderDetailsOrder
                                                        ?.orderType ??
                                                    '',
                                                "gst_tax": (gstAmount ?? 0) + serviceGstTax + (tipTaxAmount ?? 0) + (gstOnDeliveryCharge ?? 0),
                                                "vat_tax": vatAmount,
                                                "delivery_charge": posController
                                                        .getCollectBillDetailResponse
                                                        ?.orders
                                                        ?.orderDetailsOrder
                                                        ?.deliveryCharge ??
                                                    0,
                                                'associated_orders':
                                                    roomBillsList,
                                                'rtype': Get.find<
                                                                PosController>()
                                                            .getCollectBillDetailResponse
                                                            ?.orders
                                                            ?.restaurantDetails
                                                            ?.restaurantOrderFor ==
                                                        'ROOM'
                                                    ? 'RM'
                                                    : ''
                                              };
                                              Get.find<KdsController>()
                                                  .sendPrintDataFixedUserApi(
                                                      manualPrintJson);
                                            } else {
                                              if (isPrint) {
                                                printCallbak((Get.find<
                                                                    PosController>()
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.restaurantDetails
                                                                ?.restaurantOrderFor ==
                                                            'ROOM') &&
                                                        Get.find<
                                                                PosController>()
                                                            .roomBillsList
                                                            .isNotEmpty
                                                    ? true
                                                    : false);
                                                double serviceGstTax = Get.find<
                                                            PosController>()
                                                        .isAddServiceCharge
                                                    ? ((((serviceValue ?? 0.0) *
                                                            Get.find<
                                                                    AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .serviceChargeTaxPercent!) /
                                                        100))
                                                    : 0;
                                                if (Get.find<PosController>()
                                                    .roomBillsList
                                                    .isEmpty) {
                                                  if (GetPlatform.isWindows) {
                                                    print(
                                                        'Normal Bill print from inside collect bill page ............');
                                                    final printers =
                                                        await Printing
                                                            .listPrinters();
                                                    for (var element
                                                        in printers) {
                                                      if (element.isAvailable &&
                                                          // element.isDefault
                                                          (element.name
                                                                  .toLowerCase() ==
                                                              Get.find<
                                                                      AuthController>()
                                                                  .profileModel!
                                                                  .wifiBillPrinterName!
                                                                  .toLowerCase())) {
                                                        for (int i = 0;
                                                            i < numberOfPrint;
                                                            i++) {
                                                          print(
                                                              'ye rha ha gst amount - ${((gstAmount ?? 0) + serviceGstTax + (tipTaxAmount ?? 0) + (gstOnDeliveryCharge ?? 0))}');
                                                          await Printing
                                                              .directPrintPdf(
                                                            printer: element,
                                                            onLayout: (_) =>
                                                                WindowsPrintByteConvert()
                                                                    .byteConvert(
                                                              tokenNo: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.tokenNo ??
                                                                  '',
                                                              paymentType:
                                                                  posController
                                                                      .paymentTab,
                                                              printType: 'bill',
                                                              subTotalWithoutTax:
                                                                  orderSubTotal ??
                                                                      0,
                                                              loyaltyUsed:
                                                                  loyltyDiscountAmount ??
                                                                      0,
                                                              walletUsed:
                                                                  usedWalletAmount ??
                                                                      0,
                                                              couponCode: isCouponValid!
                                                                  ? (couponController
                                                                          .text ??
                                                                      '')
                                                                  : '',
                                                              couponDiscount: (isCouponValid! &&
                                                                      (crmCouponRupee ?? 0) > 0)
                                                                  ? crmCouponRupee!
                                                                  : 0,
                                                              paperRoll: Get.find<
                                                                              AuthController>()
                                                                          .profileModel
                                                                          ?.billPrinterPaperRoll ==
                                                                      58
                                                                  ? 58
                                                                  : 80,
                                                              orderId: posController
                                                                  .getCollectBillDetailResponse
                                                                  ?.orders
                                                                  ?.orderDetailsOrder
                                                                  ?.restaurantOrderId,
                                                              date:
                                                                  '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat}').format(DateTime.parse(posController.getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}',
                                                              waiterName:
                                                                  '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName}',
                                                              tablename: posController
                                                                          .getCollectBillDetailResponse
                                                                          ?.orders
                                                                          ?.restaurantDetails
                                                                          ?.tableNo ==
                                                                      ''
                                                                  ? posController
                                                                              .getCollectBillDetailResponse
                                                                              ?.orders
                                                                              ?.orderDetailsOrder
                                                                              ?.orderType ==
                                                                          'delivery'
                                                                      ? 'Delivery'
                                                                      : posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ==
                                                                              'take_away'
                                                                          ? 'Take Away'
                                                                          : 'WC'
                                                                  : posController
                                                                              .getCollectBillDetailResponse
                                                                              ?.orders
                                                                              ?.restaurantDetails
                                                                              ?.tableArea ==
                                                                          ''
                                                                      ? '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}'
                                                                      : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}',
                                                              custName:
                                                                  '${nameController.text ?? ''}',
                                                              custPhone:
                                                                  '${phoneController.text ?? ''}',
                                                              custGST: Get.find<
                                                                              AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .showUserGst ==
                                                                      'Yes'
                                                                  ? '${cGstNoController.text ?? ''}'
                                                                  : '',
                                                              custGSTName: Get.find<
                                                                              AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .showUserGst ==
                                                                      'Yes'
                                                                  ? '${cGstNameController.text ?? ''}'
                                                                  : '',
                                                              billFoodList: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.mergeFoodListWithDate ??
                                                                  [],
                                                              orderNote: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.orderNote ??
                                                                  '',
                                                              orderSubTotal: orderItemTotal ,
                                                                  // (posController
                                                                  //         .getCollectBillDetailResponse
                                                                  //         ?.orders
                                                                  //         ?.roomInfo
                                                                  //         ?.roomPrice ??
                                                                  //     0),
                                                              discount:
                                                                  orderDiscount,
                                                              serviceChargeAmount:
                                                                  serviceValue,
                                                              roomRemainingPay: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.remainingPay ??
                                                                  0),
                                                              roomAdvancePay: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.advancePay ??
                                                                  0),
                                                              roomGst: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstTaxAmount ??
                                                                  0),
                                                              deliveryCharge: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.deliveryCharge ??
                                                                  0,
                                                              gstAmount: ((gstAmount ?? 0) +
                                                                  serviceGstTax +
                                                                  (tipTaxAmount ??
                                                                      0) +
                                                                  (gstOnDeliveryCharge ??
                                                                      0)),
                                                              vatAmount:
                                                                  vatAmount,
                                                              grandTotal: Get.find<
                                                                      PosController>()
                                                                  .collectItemPrice,
                                                              deliveryCustName: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.name ??
                                                                  '',
                                                              deliveryCustPhone: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.phone ??
                                                                  '',
                                                              deliveryAddressType: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.addressType ??
                                                                  '',
                                                              deliveryCustAddress: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.address ??
                                                                  '',
                                                              deliveryCustPincode: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.pincode ??
                                                                  '',
                                                              tips: double.parse(
                                                                  tipsController
                                                                          .text ??
                                                                      '0'),
                                                              orderType: posController
                                                                  .getCollectBillDetailResponse
                                                                  ?.orders
                                                                  ?.orderDetailsOrder
                                                                  ?.orderType,
                                                              gstName: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstName ??
                                                                  '',
                                                              gstNo: double.tryParse(posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstNo ??
                                                                  ''),
                                                            ),
                                                          );
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: 2));
                                                        }

                                                        break;
                                                      }
                                                    }
                                                  } else {
                                                    showToast('Please wait..');
                                                    Get.find<
                                                            LoadingController>()
                                                        .startLoading(true);

                                                    // kdsBytesConvert();

                                                    if (Platform.isIOS) {
                                                      await _iosPrintEscPos(await PrintByteConvert()
                                                          .byteConvert(
                                                              // paymentType: posController
                                                              //     .paymentTab,
                                                              subTotalWithoutTax:
                                                                  orderSubTotal ??
                                                                      0,
                                                              roomAdvancePay: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.advancePay ??
                                                                  0,
                                                              roomRemainingPay: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.remainingPay ??
                                                                  0,
                                                              printType: 'bill',
                                                              couponCode: isCouponValid!
                                                                  ? (couponController.text ??
                                                                      '')
                                                                  : '',
                                                              couponDiscount: (isCouponValid! &&
                                                                      (crmCouponRupee ?? 0) > 0)
                                                                  ? crmCouponRupee!
                                                                  : 0,
                                                              paperRoll: Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                                                                  ? 58
                                                                  : 80,
                                                              orderId: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.restaurantOrderId ??
                                                                  '',
                                                              date: (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.createdAt != null &&
                                                                      Get.find<AuthController>().profileModel?.restaurants != null &&
                                                                      Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty)
                                                                  ? DateFormat(Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat ?? 'yyyy-MM-dd').format(DateTime.parse(posController.getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))
                                                                  : '',
                                                              waiterName: posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? '',
                                                              tablename: (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? '') == ''
                                                                  ? (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'delivery' ? 'Delivery' : (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'take_away' ? 'Take Away' : 'WC'))
                                                                  : (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? '') == ''
                                                                      ? (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? '')
                                                                      : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                                                              custName: nameController.text ?? '',
                                                              custPhone: phoneController.text ?? '',
                                                              billFoodList: posController.getCollectBillDetailResponse?.orders?.mergeFoodListWithDate ?? [],
                                                              orderNote: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderNote ?? '',
                                                              orderSubTotal: orderItemTotal ?? 0.0,
                                                              discount: orderDiscount ?? 0.0,
                                                              serviceChargeAmount: serviceValue ?? 0.0,
                                                              deliveryCharge: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0.0,
                                                              gstAmount: ((gstAmount ?? 0) + serviceGstTax + (tipTaxAmount ?? 0) + (gstOnDeliveryCharge ?? 0)),
                                                              vatAmount: vatAmount ?? 0.0,
                                                              loyaltyUsed: loyltyDiscountAmount ?? 0,
                                                              walletUsed: usedWalletAmount ?? 0,
                                                              grandTotal: Get.find<PosController>().collectItemPrice,
                                                              deliveryCustName: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
                                                              deliveryCustPhone: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
                                                              deliveryAddressType: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
                                                              deliveryCustAddress: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
                                                              deliveryCustPincode: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
                                                              tips: double.tryParse(tipsController.text ?? '0') ?? 0.0,
                                                              orderType: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ?? ''));
                                                    } else {
                                                      await _kdsPrintEscPos(await PrintByteConvert()
                                                          .byteConvert(
                                                              subTotalWithoutTax:
                                                                  orderSubTotal ??
                                                                      0,
                                                              // paymentType: posController
                                                              //     .paymentTab,
                                                              roomAdvancePay: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.advancePay ??
                                                                  0,
                                                              roomRemainingPay: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.remainingPay ??
                                                                  0,
                                                              printType: 'bill',
                                                              couponCode: isCouponValid!
                                                                  ? (couponController.text ??
                                                                      '')
                                                                  : '',
                                                              couponDiscount: (isCouponValid! &&
                                                                      (crmCouponRupee ?? 0) > 0)
                                                                  ? crmCouponRupee!
                                                                  : 0,
                                                              paperRoll: Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                                                                  ? 58
                                                                  : 80,
                                                              orderId: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.restaurantOrderId ??
                                                                  '',
                                                              date: (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.createdAt != null &&
                                                                      Get.find<AuthController>().profileModel?.restaurants != null &&
                                                                      Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty)
                                                                  ? DateFormat(Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat ?? 'yyyy-MM-dd').format(DateTime.parse(posController.getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))
                                                                  : '',
                                                              waiterName: posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? '',
                                                              tablename: (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? '') == ''
                                                                  ? (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'delivery' ? 'Delivery' : (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'take_away' ? 'Take Away' : 'WC'))
                                                                  : (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? '') == ''
                                                                      ? (posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? '')
                                                                      : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                                                              custName: nameController.text ?? '',
                                                              custPhone: phoneController.text ?? '',
                                                              billFoodList: posController.getCollectBillDetailResponse?.orders?.mergeFoodListWithDate ?? [],
                                                              orderNote: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderNote ?? '',
                                                              orderSubTotal: orderItemTotal ?? 0.0,
                                                              discount: orderDiscount ?? 0.0,
                                                              loyaltyUsed: loyltyDiscountAmount ?? 0,
                                                              walletUsed: usedWalletAmount ?? 0,
                                                              serviceChargeAmount: serviceValue ?? 0.0,
                                                              deliveryCharge: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0.0,
                                                              gstAmount: ((gstAmount ?? 0) + serviceGstTax + (tipTaxAmount ?? 0) + (gstOnDeliveryCharge ?? 0)),
                                                              vatAmount: vatAmount ?? 0.0,
                                                              grandTotal: Get.find<PosController>().collectItemPrice,
                                                              deliveryCustName: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
                                                              deliveryCustPhone: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
                                                              deliveryAddressType: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
                                                              deliveryCustAddress: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
                                                              deliveryCustPincode: posController.getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
                                                              tips: double.tryParse(tipsController.text ?? '0') ?? 0.0,
                                                              orderType: posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ?? ''));
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: SvgPicture.asset(
                                              Images.ic_print_kot,
                                              height: 56,
                                            ),
                                          )
                                          //  Container(
                                          //   padding: EdgeInsets.symmetric(
                                          //       horizontal: Dimensions
                                          //           .PADDING_SIZE_DEFAULT,
                                          //       vertical: Dimensions
                                          //           .PADDING_SIZE_SMALL),
                                          //   decoration: BoxDecoration(
                                          //       border: Border.all(
                                          //           color: ColorTheme
                                          //               .appColor),
                                          //       color: isPrint
                                          //           ? ColorTheme.appColor
                                          //           : Colors.white,
                                          //       borderRadius: BorderRadius
                                          //           .circular(Dimensions
                                          //               .RADIUS_DEFAULT)),
                                          //   child: Text(
                                          //     'Print Bill',
                                          //     style: poppinsMedium.copyWith(
                                          //         fontSize: Dimensions
                                          //             .FONT_SIZE_LARGE,
                                          //         color: isPrint
                                          //             ? Colors.white
                                          //             : ColorTheme
                                          //                 .appColor),
                                          //   ),
                                          // ),
                                          );
                                    }),
                                  // if (posController
                                  //             .getCollectBillDetailResponse
                                  //             .orders
                                  //             .restaurantDetails
                                  //             .restaurantOrderFor ==
                                  //         'ROOM' &&
                                  //     posController.roomBillsList.isNotEmpty)
                                  //   GetBuilder<KdsController>(
                                  //       builder: (kdsController) {
                                  //     return InkWell(
                                  //       onTap: () {
                                  //         if (isPrint) {
                                  //           isPrint = false;
                                  //           kdsController.update();
                                  //           kdsBytesConvert();
                                  //           Future.delayed(Duration(seconds: 8), () {
                                  //             isPrint = true;
                                  //             kdsController.update();
                                  //           });
                                  //         }
                                  //       },
                                  //       child: Container(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal:
                                  //                 Dimensions.PADDING_SIZE_DEFAULT,
                                  //             vertical:
                                  //                 Dimensions.PADDING_SIZE_SMALL),
                                  //         decoration: BoxDecoration(
                                  //             border: Border.all(
                                  //                 color: ColorTheme.appColor),
                                  //             color: isPrint
                                  //                 ? ColorTheme.appColor
                                  //                 : Colors.white,
                                  //             borderRadius: BorderRadius.circular(
                                  //                 Dimensions.RADIUS_DEFAULT)),
                                  //         child: Text(
                                  //           'All Bill Print',
                                  //           style: poppinsMedium.copyWith(
                                  //               fontSize: Dimensions.FONT_SIZE_LARGE,
                                  //               color: isPrint
                                  //                   ? Colors.white
                                  //                   : ColorTheme.appColor),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   }),
                                  if (posController.isEDCLoading &&
                                      !posController.isEDCCancelLoading)
                                    InkWell(
                                        onTap: () async {
                                          Restaurant restaurant =
                                              Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first;
                                          double orderPay =
                                              (Get.find<PosController>()
                                                  .collectItemPrice);

                                          Map<String, dynamic> jsonData = {
                                            "merchant_id": restaurant.edcDetail!
                                                .pineLabDetail!.merchantId,
                                            "security_token": restaurant
                                                .edcDetail!
                                                .pineLabDetail!
                                                .securityToken,
                                            "store_id": restaurant.edcDetail!
                                                .pineLabDetail!.storeId,
                                            "client_id": restaurant.edcDetail!
                                                .pineLabDetail!.clientId,
                                            'order_id': orderId,
                                            'amount': Get.find<AuthController>()
                                                        .profileModel
                                                        ?.restaurants
                                                        ?.first
                                                        .isTotalRound ==
                                                    'Yes'
                                                ? ((getRoundUpValue(
                                                            value: orderPay)) *
                                                        100)
                                                    .toString()
                                                : (orderPay * 100)
                                                    .toStringAsFixed(2),
                                          };
                                          await Get.find<PosController>()
                                              .cancelEdcReq(jsonData: jsonData);
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Icon(
                                            Icons.close,
                                            color: ColorTheme.appColor,
                                            size: 30,
                                          ),
                                        )),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('printer') &&
                                      !posController.isEDCLoading)
                                    posController.isEDCLoading
                                        ? CircularProgressIndicator()
                                        : InkWell(
                                            onTap: () async {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              if (isPrint) {
                                                // printCallbak(Get.find<PosController>()
                                                //                 .getCollectBillDetailResponse!
                                                //                 .orders!
                                                //                 .restaurantDetails!
                                                //                 .restaurantOrderFor ==
                                                //             'ROOM' &&
                                                //         Get.find<PosController>()
                                                //             .roomBillsList
                                                //             .isNotEmpty
                                                //     ? true
                                                //     : false);
                                                if (Get.find<PosController>()
                                                        .roomBillsList
                                                        .isEmpty &&
                                                    isAutoBillPrint!) {
                                                  double serviceGstTax = Get.find<
                                                              PosController>()
                                                          .isAddServiceCharge
                                                      ? ((((serviceValue ??
                                                                  0.0) *
                                                              Get.find<
                                                                      AuthController>()
                                                                  .profileModel!
                                                                  .restaurants!
                                                                  .first
                                                                  .serviceChargeTaxPercent!) /
                                                          100))
                                                      : 0;
                                                  // isPrint = false;
                                                  // kdsController
                                                  //     .update();
                                                  if (GetPlatform.isWindows) {
                                                    print(
                                                        'ye kiya local print clear payment pr - ${((gstAmount ?? 0) + serviceGstTax + (tipTaxAmount ?? 0))}');
                                                    int numberOfPrint = int.parse(
                                                        Get.find<AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .settings!
                                                                .noOfBillPrint ??
                                                            '1');
                                                    final printers =
                                                        await Printing
                                                            .listPrinters();
                                                    for (var element
                                                        in printers) {
                                                      if (element.isAvailable &&
                                                          (element.name
                                                                  .toLowerCase() ==
                                                              Get.find<
                                                                      AuthController>()
                                                                  .profileModel!
                                                                  .wifiBillPrinterName!
                                                                  .toLowerCase())) {
                                                        for (int i = 0;
                                                            i < numberOfPrint;
                                                            i++) {
                                                          await Printing
                                                              .directPrintPdf(
                                                            printer: element,
                                                            onLayout: (_) =>
                                                                WindowsPrintByteConvert()
                                                                    .byteConvert(
                                                              tokenNo: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.tokenNo ??
                                                                  '',
                                                              subTotalWithoutTax:
                                                                  orderSubTotal ??
                                                                      0,
                                                              loyaltyUsed:
                                                                  loyltyDiscountAmount ??
                                                                      0,
                                                              walletUsed:
                                                                  usedWalletAmount ??
                                                                      0,
                                                              couponCode: isCouponValid!
                                                                  ? (couponController
                                                                          .text ??
                                                                      '')
                                                                  : '',
                                                              couponDiscount: (isCouponValid! &&
                                                                      (crmCouponRupee ?? 0) > 0)
                                                                  ? crmCouponRupee!
                                                                  : 0,
                                                              paymentType:
                                                                  posController
                                                                      .paymentTab,
                                                              printType: 'bill',
                                                              paperRoll: Get.find<
                                                                              AuthController>()
                                                                          .profileModel
                                                                          ?.billPrinterPaperRoll ==
                                                                      58
                                                                  ? 58
                                                                  : 80,
                                                              orderId: posController
                                                                  .getCollectBillDetailResponse
                                                                  ?.orders
                                                                  ?.orderDetailsOrder
                                                                  ?.restaurantOrderId,
                                                              date:
                                                                  '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat}').format(DateTime.parse(posController.getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}',
                                                              waiterName:
                                                                  '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName}',
                                                              tablename: posController
                                                                          .getCollectBillDetailResponse
                                                                          ?.orders
                                                                          ?.restaurantDetails
                                                                          ?.tableNo ==
                                                                      ''
                                                                  ? posController
                                                                              .getCollectBillDetailResponse
                                                                              ?.orders
                                                                              ?.orderDetailsOrder
                                                                              ?.orderType ==
                                                                          'delivery'
                                                                      ? 'Delivery'
                                                                      : posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ==
                                                                              'take_away'
                                                                          ? 'Take Away'
                                                                          : 'WC'
                                                                  : posController
                                                                              .getCollectBillDetailResponse
                                                                              ?.orders
                                                                              ?.restaurantDetails
                                                                              ?.tableArea ==
                                                                          ''
                                                                      ? '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}'
                                                                      : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}',
                                                              custName:
                                                                  '${nameController.text ?? ''}',
                                                              custPhone:
                                                                  '${phoneController.text ?? ''}',
                                                              custGST: Get.find<
                                                                              AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .showUserGst ==
                                                                      'Yes'
                                                                  ? '${cGstNoController.text ?? ''}'
                                                                  : '',
                                                              custGSTName: Get.find<
                                                                              AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .showUserGst ==
                                                                      'Yes'
                                                                  ? '${cGstNameController.text ?? ''}'
                                                                  : '',
                                                              billFoodList: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.mergeFoodListWithDate ??
                                                                  [],
                                                              orderNote: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.orderNote ??
                                                                  '',
                                                              orderSubTotal: orderItemTotal ,
                                                                  // (posController
                                                                  //         .getCollectBillDetailResponse
                                                                  //         ?.orders
                                                                  //         ?.roomInfo
                                                                  //         ?.roomPrice ??
                                                                  //     0),
                                                              discount:
                                                                  orderDiscount,
                                                              serviceChargeAmount:
                                                                  serviceValue,
                                                              roomRemainingPay: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.remainingPay ??
                                                                  0),
                                                              roomAdvancePay: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.advancePay ??
                                                                  0),
                                                              roomGst: (posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstTaxAmount ??
                                                                  0),
                                                              deliveryCharge: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.orderDetailsOrder
                                                                      ?.deliveryCharge ??
                                                                  0,
                                                              gstAmount: ((gstAmount ??
                                                                      0) +
                                                                  serviceGstTax +
                                                                  (tipTaxAmount ??
                                                                      0) +
                                                                  (gstOnDeliveryCharge ??
                                                                      0)),
                                                              vatAmount:
                                                                  vatAmount,
                                                              grandTotal: Get.find<
                                                                      PosController>()
                                                                  .collectItemPrice,
                                                              deliveryCustName: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.name ??
                                                                  '',
                                                              deliveryCustPhone: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.phone ??
                                                                  '',
                                                              deliveryAddressType: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.addressType ??
                                                                  '',
                                                              deliveryCustAddress: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.address ??
                                                                  '',
                                                              deliveryCustPincode: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.deliveryAddress
                                                                      ?.pincode ??
                                                                  '',
                                                              tips: double.tryParse(
                                                                  tipsController
                                                                          .text.trim() ??
                                                                      '0') ?? 0,
                                                              orderType: posController
                                                                  .getCollectBillDetailResponse
                                                                  ?.orders
                                                                  ?.orderDetailsOrder
                                                                  ?.orderType,
                                                              gstName: posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstName ??
                                                                  '',
                                                              gstNo: double.tryParse(posController
                                                                      .getCollectBillDetailResponse
                                                                      ?.orders
                                                                      ?.roomInfo
                                                                      ?.gstNo ??
                                                                  ''),
                                                            ),
                                                          );
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: 2));
                                                        }

                                                        break;
                                                      }
                                                    }
                                                  } else {
                                                    showToast('Please wait..');
                                                    Get.find<
                                                            LoadingController>()
                                                        .startLoading(true);

                                                    // kdsBytesConvert();
                                                    if (Platform.isIOS) {
                                                      await _iosPrintEscPos(
                                                          await PrintByteConvert()
                                                              .byteConvert(
                                                        subTotalWithoutTax:
                                                            orderSubTotal ?? 0,
                                                        loyaltyUsed:
                                                            loyltyDiscountAmount ??
                                                                0,
                                                        walletUsed:
                                                            usedWalletAmount ??
                                                                0,
                                                        roomAdvancePay: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.advancePay ??
                                                            0,
                                                        couponCode: isCouponValid!
                                                            ? (couponController
                                                                    .text ??
                                                                '')
                                                            : '',
                                                        couponDiscount: (isCouponValid! &&
                                                                (crmCouponRupee ?? 0) > 0)
                                                            ? crmCouponRupee!
                                                            : 0,
                                                        paymentType:
                                                            posController
                                                                .paymentTab,
                                                        roomRemainingPay: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0,
                                                        printType: 'bill',
                                                        paperRoll: Get.find<
                                                                        AuthController>()
                                                                    .profileModel!
                                                                    .billPrinterPaperRoll ==
                                                                58
                                                            ? 58
                                                            : 80,
                                                        orderId: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.restaurantOrderId ??
                                                            '',
                                                        date:
                                                            '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat ?? ''}').format(DateTime.parse(posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.createdAt ?? ''))}',
                                                        waiterName:
                                                            '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? ''}',
                                                        tablename: posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.restaurantDetails
                                                                    ?.tableNo ==
                                                                ''
                                                            ? posController
                                                                        .getCollectBillDetailResponse
                                                                        ?.orders
                                                                        ?.orderDetailsOrder
                                                                        ?.orderType ==
                                                                    'delivery'
                                                                ? 'Delivery'
                                                                : posController
                                                                            .getCollectBillDetailResponse
                                                                            ?.orders
                                                                            ?.orderDetailsOrder
                                                                            ?.orderType ==
                                                                        'take_away'
                                                                    ? 'Take Away'
                                                                    : 'WC'
                                                            : posController
                                                                        .getCollectBillDetailResponse
                                                                        ?.orders
                                                                        ?.restaurantDetails
                                                                        ?.tableArea ==
                                                                    ''
                                                                ? '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}'
                                                                : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                                                        custName:
                                                            nameController.text,
                                                        custPhone:
                                                            phoneController
                                                                .text,
                                                        billFoodList: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.mergeFoodListWithDate ??
                                                            [],
                                                        orderNote: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.orderNote ??
                                                            '',
                                                        orderSubTotal:
                                                            orderItemTotal,
                                                        discount: orderDiscount,
                                                        serviceChargeAmount:
                                                            serviceValue,
                                                        deliveryCharge: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.deliveryCharge ??
                                                            0,
                                                        gstAmount: ((gstAmount ??
                                                                0) +
                                                            serviceGstTax +
                                                            (tipTaxAmount ??
                                                                0) +
                                                            (gstOnDeliveryCharge ??
                                                                0)),
                                                        vatAmount: vatAmount,
                                                        grandTotal: Get.find<
                                                                PosController>()
                                                            .collectItemPrice,
                                                        deliveryCustName: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.name ??
                                                            '',
                                                        deliveryCustPhone: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.phone ??
                                                            '',
                                                        deliveryAddressType: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.addressType ??
                                                            '',
                                                        deliveryCustAddress:
                                                            posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.deliveryAddress
                                                                    ?.address ??
                                                                '',
                                                        deliveryCustPincode:
                                                            posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.deliveryAddress
                                                                    ?.pincode ??
                                                                '',
                                                        tips: double.parse(
                                                            tipsController.text
                                                                    .isNotEmpty
                                                                ? tipsController
                                                                    .text
                                                                : '0'),
                                                        orderType: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.orderType ??
                                                            '',
                                                      ));
                                                    } else {
                                                      await _kdsPrintEscPos(
                                                          await PrintByteConvert()
                                                              .byteConvert(
                                                        subTotalWithoutTax:
                                                            orderSubTotal ?? 0,
                                                        loyaltyUsed:
                                                            loyltyDiscountAmount ??
                                                                0,
                                                        walletUsed:
                                                            usedWalletAmount ??
                                                                0,
                                                        couponCode: isCouponValid!
                                                            ? (couponController
                                                                    .text ??
                                                                '')
                                                            : '',
                                                        couponDiscount: (isCouponValid! &&
                                                                (crmCouponRupee ?? 0) > 0)
                                                            ? crmCouponRupee!
                                                            : 0,
                                                        paymentType:
                                                            posController
                                                                .paymentTab,
                                                        roomAdvancePay: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.advancePay ??
                                                            0,
                                                        roomRemainingPay: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.remainingPay ??
                                                            0,
                                                        printType: 'bill',
                                                        paperRoll: Get.find<
                                                                        AuthController>()
                                                                    .profileModel!
                                                                    .billPrinterPaperRoll ==
                                                                58
                                                            ? 58
                                                            : 80,
                                                        orderId: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.restaurantOrderId ??
                                                            '',
                                                        date:
                                                            '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat ?? ''}').format(DateTime.parse(posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.createdAt ?? ''))}',
                                                        waiterName:
                                                            '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? ''}',
                                                        tablename: posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.restaurantDetails
                                                                    ?.tableNo ==
                                                                ''
                                                            ? posController
                                                                        .getCollectBillDetailResponse
                                                                        ?.orders
                                                                        ?.orderDetailsOrder
                                                                        ?.orderType ==
                                                                    'delivery'
                                                                ? 'Delivery'
                                                                : posController
                                                                            .getCollectBillDetailResponse
                                                                            ?.orders
                                                                            ?.orderDetailsOrder
                                                                            ?.orderType ==
                                                                        'take_away'
                                                                    ? 'Take Away'
                                                                    : 'WC'
                                                            : posController
                                                                        .getCollectBillDetailResponse
                                                                        ?.orders
                                                                        ?.restaurantDetails
                                                                        ?.tableArea ==
                                                                    ''
                                                                ? '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}'
                                                                : '${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${posController.getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}',
                                                        custName:
                                                            nameController.text,
                                                        custPhone:
                                                            phoneController
                                                                .text,
                                                        billFoodList: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.mergeFoodListWithDate ??
                                                            [],
                                                        orderNote: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.orderNote ??
                                                            '',
                                                        orderSubTotal:
                                                            orderItemTotal,
                                                        discount: orderDiscount,
                                                        serviceChargeAmount:
                                                            serviceValue,
                                                        deliveryCharge: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.deliveryCharge ??
                                                            0,
                                                        gstAmount: ((gstAmount ??
                                                                0) +
                                                            serviceGstTax +
                                                            (tipTaxAmount ??
                                                                0) +
                                                            (gstOnDeliveryCharge ??
                                                                0)),
                                                        vatAmount: vatAmount,
                                                        grandTotal: Get.find<
                                                                PosController>()
                                                            .collectItemPrice,
                                                        deliveryCustName: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.name ??
                                                            '',
                                                        deliveryCustPhone: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.phone ??
                                                            '',
                                                        deliveryAddressType: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.deliveryAddress
                                                                ?.addressType ??
                                                            '',
                                                        deliveryCustAddress:
                                                            posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.deliveryAddress
                                                                    ?.address ??
                                                                '',
                                                        deliveryCustPincode:
                                                            posController
                                                                    .getCollectBillDetailResponse
                                                                    ?.orders
                                                                    ?.deliveryAddress
                                                                    ?.pincode ??
                                                                '',
                                                        tips: double.parse(
                                                            tipsController.text
                                                                    .isNotEmpty
                                                                ? tipsController
                                                                    .text
                                                                : '0'),
                                                        orderType: posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.orderType ??
                                                            '',
                                                      ));
                                                    }
                                                  }
                                                }
                                              }
                                              if (posController.paymentTab ==
                                                  '') {
                                                showErrorToast(
                                                    'Please select any payment method');
                                              } else {
                                                checkRestaurantIsOpen();
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .PADDING_SIZE_DEFAULT,
                                                  vertical: 12),
                                              decoration: BoxDecoration(
                                                  color: ColorTheme.appColor,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Text(
                                                posController.paymentTab
                                                            .toLowerCase() ==
                                                        'tab'
                                                    ? 'Add to credit'
                                                    : posController.paymentTab
                                                                .toLowerCase() ==
                                                            'room'
                                                        ? 'Transfer in room'
                                                        : Get.find<PosController>()
                                                                    .getCollectBillDetailResponse!
                                                                    .orders!
                                                                    .restaurantDetails!
                                                                    .restaurantOrderFor ==
                                                                'ROOM'
                                                            ? 'Check-out'
                                                            : 'Clear Payment',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                ]),
                          ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Get.back();
      if (isAutoBillPrint!) Get.back();
      // Map<String, dynamic> jsonBody = {
      //   'order_id': orderId,
      //   'role_name': Get.find<AuthController>().profileModel.role.first,
      //   'order_status': 'paid'
      // };

      // await Get.find<KdsController>()
      //     .changeOrderStatus(jsonBody, (bool isSuccess, String message) {});
      // await Get.find<KdsController>().getWaiterPOSOrderList();
      // showErrorToast(message, isError: false);
      showErrorToast(message, isError: false);

      Get.find<PosController>().setPaymentTabName('');
    } else {
      showErrorToast(message);
    }
  }

  Widget partialPayment() {
    bool isCardOption = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .paymentModes
            ?.any((e) => (e.name ?? '').toLowerCase() == 'card') ??
        false;
    bool isUPIOption = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .paymentModes
            ?.any((e) => (e.name ?? '').toLowerCase() == 'upi') ??
        false;
    // Helper to compute remaining live
    double getRemaining() {
      final pos = Get.find<PosController>();
      final auth = Get.find<AuthController>();
      final isRound =
          auth.profileModel?.restaurants?.first.isTotalRound == 'Yes';
      double total = pos.collectItemPrice +
          (roomTotalPayment ?? 0) +
          (pos.getCollectBillDetailResponse?.orders?.roomInfo?.remainingPay ??
              0.0);
      num finalTotal = isRound ? getRoundUpValue(value: total) : total;
      double cash = double.tryParse(pCash.text) ?? 0.0;
      double card = double.tryParse(pCard.text) ?? 0.0;
      double upi = double.tryParse(pUpi.text) ?? 0.0;
      return finalTotal - cash - card - upi;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        double remaining = getRemaining();
        Color remainingColor = remaining == 0
            ? Colors.green
            : remaining < 0
                ? Colors.red
                : Colors.orange;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'Cash : ',
                      style: poppinsMedium.copyWith(fontSize: 13),
                    )),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 30,
                    child: TextField(
                      controller: pCash,
                      textInputAction: TextInputAction.search,
                      autofocus: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        hintStyle: poppinsMedium.copyWith(
                            fontSize: 13, color: Colors.grey),
                        filled: true,
                        hintText: 'Cash Amount',
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setState(() {}),
                      // onChanged: (value) {
                      //   final auth = Get.find<AuthController>();
                      //   final pos = Get.find<PosController>();

                      //   final isRound =
                      //       auth.profileModel?.restaurants?.first.isTotalRound ==
                      //           'Yes';

                      //   double cash = double.tryParse(value) ?? 0.0;

                      //   double totalPay = pos.collectItemPrice +
                      //       (roomTotalPayment ?? 0) +
                      //       (pos.getCollectBillDetailResponse?.orders?.roomInfo
                      //               ?.remainingPay ??
                      //           0.0);

                      //   var finalTotal =
                      //       isRound ? getRoundUpValue(value: totalPay) : totalPay;

                      //   // ✅ STEP 1: Reset first (IMPORTANT)
                      //   pUpi.text = '0';
                      //   pCard.text = '0';

                      //   // ✅ STEP 2: If empty input → stop
                      //   if (value.trim().isEmpty) return;

                      //   // ✅ STEP 3: If cash >= total → nothing else needed
                      //   if (cash >= finalTotal) return;

                      //   // ✅ STEP 4: Calculate remaining
                      //   double remain = finalTotal - cash;

                      //   // ✅ STEP 5: Assign based on selected option
                      //   if (isUPIOption && !isCardOption) {
                      //     pUpi.text = remain.toStringAsFixed(2);
                      //   } else if (!isUPIOption && isCardOption) {
                      //     pCard.text = remain.toStringAsFixed(2);
                      //   } else if (isUPIOption && isCardOption) {
                      //     // Split safely
                      //     double upiAmt =
                      //         double.parse((remain / 2).toStringAsFixed(2));
                      //     double cardAmt =
                      //         double.parse((remain - upiAmt).toStringAsFixed(2));

                      //     pUpi.text = upiAmt.toString();
                      //     pCard.text = cardAmt.toString();
                      //   }
                      // },

                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isUPIOption)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          'UPI  : ',
                          style: poppinsMedium.copyWith(fontSize: 13),
                        )),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 30,
                        child: TextField(
                          controller: pUpi,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: Colors.grey),
                            filled: true,
                            hintText: 'UPI Amount',
                            fillColor: Colors.white,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isCardOption)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Card : ',
                          style: poppinsMedium.copyWith(fontSize: 13),
                        )),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 30,
                        child: TextField(
                          controller: pCard,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: Colors.grey),
                            filled: true,
                            hintText: 'Card Amount',
                            fillColor: Colors.white,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isCardOption)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Transaction No : ',
                          style: poppinsMedium.copyWith(fontSize: 13),
                        )),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 30,
                        child: TextField(
                          controller: pTXN,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: Colors.grey),
                            filled: true,
                            hintText: 'Transacation No',
                            fillColor: Colors.white,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // ── REMAINING LABEL ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    remaining == 0
                        ? ''
                        : remaining > 0
                            ? 'Remaining: ₹${remaining.toStringAsFixed(2)}'
                            : 'Excess: ₹${(-remaining).toStringAsFixed(2)}',
                    style: poppinsMedium.copyWith(
                      fontSize: 13,
                      color: remainingColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget nameTextField(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50,
        child: posController.paymentTab.toLowerCase() == 'tab'
            ? TypeAheadField<CrmCustomerItem>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: nameController,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 15, color: Colors.grey),
                    hintText: 'Name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
                noItemsFoundBuilder: (context) => SizedBox.shrink(),
                suggestionsCallback: (pattern) async {
                  final trimmed = pattern.trim();
                  if (trimmed.length < 2) return <CrmCustomerItem>[];
                  await Get.find<CartController>()
                      .getCustomerFromApiCrm(search: trimmed, limit: 10);
                  return Get.find<CartController>()
                          .crmCustomerList
                          ?.customerList ??
                      [];
                },
                itemBuilder: (context, CrmCustomerItem suggestion) {
                  return Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: Row(children: [
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  suggestion.name?.trim().isNotEmpty == true
                                      ? suggestion.name!.trim()
                                      : 'No Name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: poppinsRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                    fontSize: 15,
                                  )),
                              Text(suggestion.phone ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: poppinsRegular.copyWith(
                                    color: ColorTheme.hintText,
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                  )),
                            ]),
                      ),
                    ]),
                  );
                },
                onSuggestionSelected: (CrmCustomerItem suggestion) {
                  nameController.text = suggestion.name?.trim() ?? '';
                  phoneController.text = suggestion.phone ?? '';
                  Get.find<PosController>().tabCrmCustomerId =
                      suggestion.id ?? '';
                },
              )
            : TextField(
                controller: nameController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle: poppinsSemiBold.copyWith(
                      fontSize: 15, color: Colors.grey),
                  filled: true,
                  hintText: 'Name',
                  fillColor: Theme.of(context).cardColor,
                ),
                style: poppinsSemiBold.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  Widget phoneTextField(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50,
        child: posController.paymentTab.toLowerCase() == 'tab'
            ? TypeAheadField<CrmCustomerItem>(
                getImmediateSuggestions: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: phoneController,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9,+]")),
                  ],
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: Colors.grey),
                    hintText: 'Phone No.',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                noItemsFoundBuilder: (context) => SizedBox.shrink(),
                suggestionsCallback: (pattern) async {
                  final trimmed = pattern.trim();
                  if (trimmed.length < 3) return <CrmCustomerItem>[];
                  await Get.find<CartController>()
                      .getCustomerFromApiCrm(search: trimmed, limit: 10);
                  return Get.find<CartController>()
                          .crmCustomerList
                          ?.customerList ??
                      [];
                },
                itemBuilder: (context, CrmCustomerItem suggestion) {
                  return Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: Row(children: [
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  suggestion.name?.trim().isNotEmpty == true
                                      ? suggestion.name!.trim()
                                      : 'No Name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: poppinsRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                    fontSize: 15,
                                  )),
                              Text(suggestion.phone ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: poppinsRegular.copyWith(
                                    color: ColorTheme.hintText,
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                  )),
                            ]),
                      ),
                    ]),
                  );
                },
                onSuggestionSelected: (CrmCustomerItem suggestion) {
                  nameController.text = suggestion.name?.trim() ?? '';
                  phoneController.text = suggestion.phone ?? '';
                  Get.find<PosController>().tabCrmCustomerId =
                      suggestion.id ?? '';
                },
              )
            : TextField(
                controller: phoneController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                keyboardType: TextInputType.numberWithOptions(signed: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("[0-9,+]")),
                ],
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle:
                      poppinsMedium.copyWith(fontSize: 15, color: Colors.grey),
                  filled: true,
                  hintText: 'Phone No.',
                  fillColor: Colors.white,
                ),
                onChanged: (String d) async {
                  if (phoneController.text.isNotEmpty &&
                      phoneController.text.length > 9) {
                    List<SearchCustomerResponseModel> searchData =
                        await Get.find<CartController>()
                            .searchWaiterPOSCustomer(phoneController.text);
                    if (searchData.isNotEmpty &&
                        searchData.first.id != 'false') {
                      if (searchData.first.name != '')
                        nameController.text = searchData.first.name;
                    }
                  }
                },
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),

        //  TypeAheadField(
        //   getImmediateSuggestions: true,
        //   textFieldConfiguration:
        //   noItemsFoundBuilder: (context) => SizedBox.shrink(),
        //   suggestionsCallback: (pattern) async {
        //     return Get.find<PosController>()
        //         .tapManagmentCustomerListResponse
        //         .employeeTapList
        //         .where((item) => item.mobile
        //             .toString()
        //             .trim()
        //             .toLowerCase()
        //             .contains(pattern.toLowerCase().trim()))
        //         .toList();
        //   },
        //   itemBuilder: (context, EmployeeTapList suggestion) {
        //     return Padding(
        //       padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        //       child: Row(children: [
        //         SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
        //         Expanded(
        //           child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text('${suggestion.mobile}',
        //                     maxLines: 1,
        //                     overflow: TextOverflow.ellipsis,
        //                     style: poppinsRegular.copyWith(
        //                       color: Theme.of(context).textTheme.bodyLarge.color,
        //                       fontSize: Dimensions.FONT_SIZE_SMALL,
        //                     )),
        //               ]),
        //         ),
        //       ]),
        //     );
        //   },
        //   onSuggestionSelected: (EmployeeTapList suggestion) {
        //     phoneController.text = suggestion.mobile.toString();
        //     nameController.text = suggestion.name;
        //     emailController.text = suggestion.email;
        //     Get.find<PosController>().update();
        //   },
        // ),
      ),
    );
  }

  Widget emailTextField(BuildContext context) {
    return Container(
      height: 30,
      child: TypeAheadField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          controller: emailController,
          textInputAction: TextInputAction.search,
          autofocus: false,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              borderSide: BorderSide(color: ColorTheme.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              borderSide: BorderSide(color: ColorTheme.borderGrey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              borderSide: BorderSide(color: ColorTheme.borderGrey),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              borderSide: BorderSide(color: ColorTheme.borderGrey),
            ),
            hintStyle: poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
            hintText: 'Email',
            filled: true,
            fillColor: Colors.white,
          ),
          style: poppinsMedium.copyWith(
            color: Colors.black,
            fontSize: 13,
          ),
        ),
        noItemsFoundBuilder: (context) => SizedBox.shrink(),
        suggestionsCallback: (pattern) async {
          return Get.find<PosController>()
              .tapManagmentCustomerListResponse!
              .employeeTapList
              .where((item) => item.email
                  .toString()
                  .trim()
                  .toLowerCase()
                  .contains(pattern.toLowerCase().trim()))
              .toList();
        },
        itemBuilder: (context, EmployeeTapList suggestion) {
          return Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: Row(children: [
              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${suggestion.email ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                          )),
                    ]),
              ),
            ]),
          );
        },
        onSuggestionSelected: (EmployeeTapList suggestion) {
          phoneController.text = suggestion.mobile.toString();
          nameController.text = suggestion.name;
          emailController.text = suggestion.email;
          Get.find<PosController>().update();
        },
      ),
    );
  }

  payNormalBill() {
    print('Normal Bill print after collect bill ............');
    double orderPay = (Get.find<PosController>().collectItemPrice);
    double serviceGstTax = Get.find<PosController>().isAddServiceCharge
        ? ((((serviceValue ?? 0.0) *
                Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .serviceChargeTaxPercent!) /
            100))
        : 0;

    Map<String, dynamic> jsonData = {
      'food_detail': jsonCartList,
      'waiter_id': Get.find<AuthController>().profileModel!.empId.toString(),
      'tip_tax_amount': tipTaxAmount,
      'service_gst_tax_amount': Get.find<PosController>().isAddServiceCharge
          ? ((((serviceValue ?? 0.0) *
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .serviceChargeTaxPercent!) /
                  100)
              .toStringAsFixed(2))
          : 0.0,
      'delivery_charge_gst': gstOnDeliveryCharge ?? 0,
      'payment_mode': posController.paymentTab,
      'paid_room': Get.find<PosController>()
                  .getCollectBillDetailResponse
                  ?.orders
                  ?.restaurantDetails
                  ?.restaurantOrderFor ==
              'ROOM'
          ? 'yes'
          : '',
      'payment_status': 'sucess',
      'email': '',
      'payment_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: orderPay)
          : orderPay.toStringAsFixed(2),
      'order_sub_total_amount': orderItemTotal,
      'order_sub_total_without_tax': orderSubTotal,
      'discount_member_category_id':
          selectedDiscount == null ? 0 : selectedDiscount!.id,
      'discount_member_category_name':
          selectedDiscount == null ? '' : selectedDiscount!.discountType,
      'discount_value': discountPercent,
      'discount_type': isLoyaltyApply == true ? 'Loyality' : '',
      'order_discount_type': discountType,
      'grant_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: (orderPay + (roomTotalPayment ?? 0.0)))
          : (orderPay + (roomTotalPayment ?? 0.0)).toStringAsFixed(2),
      'vat_tax': vatAmount ?? 0.0,
      'round_up': getRoundUpAmount(orderPay),
      'gst_tax': (gstAmount ?? 0) +
          (tipTaxAmount ?? 0) +
          serviceGstTax +
          (gstOnDeliveryCharge ?? 0),
      // 'self_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? 0
      //     : orderDiscount,
      // 'coupon_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? orderDiscount
      //     : 0,
      // 'coupon_title': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponController.text
      //     : '',
      // 'coupon_type': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponDiscountType
      //     : '',
      'self_discount': orderDiscount,
      'coupon_code': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? crmCouponCode
          : '',
      'coupon_discount': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponRupee ?? 0)
          : 0,
      'coupon_title': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponTitle ?? '')
          : '',
      'coupon_type': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponScope ?? '')
          : '',
       // 'comm_discount': coummunityDiscount ?? 0.0,
      'comm_discount': selectedDiscount == null ? 0 : orderDiscount,
      'use_wallet_balance': usedWalletAmount,
      'tip_amount':
          tipsController.text.isEmpty ?? true ? '0' : tipsController.text,
      'order_discount': (orderDiscount ?? 0.0) + (coummunityDiscount ?? 0.0),
      // 'used_loyalty_point': (loyltyDiscountAmount ?? 0),
      'used_loyalty_point':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_points_used':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_discount': (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0)
          ? (loyltyDiscountAmount ?? 0)
          : 0,
      'loyalty_redemption_id': null,
      'mobile':
          phoneController.text.isEmpty ?? true ? '' : phoneController.text,
      'name': nameController.text.isEmpty ?? true ? '' : nameController.text,
      'restaurant_name':
          Get.find<AuthController>().profileModel?.restaurants?[0].name ?? '',
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? (serviceValue ?? 0.0)
          : 0.0,
      'transaction_id': transactionNoController.text.isEmpty ?? true
          ? ''
          : transactionNoController.text,
      if (posController.paymentTab.toLowerCase() == 'partial')
        'partial_payments': [
          {
            "payment_mode": "cash",
            "payment_amount": pCash.text,
            "grant_amount": pCash.text,
            "transaction_id": ""
          },
          {
            "payment_mode": "card",
            "payment_amount": pCard.text,
            "grant_amount": pCard.text,
            "transaction_id": pTXN.text
          },
          {
            "payment_mode": "upi",
            "payment_amount": pUpi.text,
            "grant_amount": pUpi.text,
            "transaction_id": ""
          }
        ],
      'order_id': orderId
    };
    var checkAmount = (((roomTotalPayment == 0
        ? Get.find<PosController>().collectItemPrice
        : Get.find<PosController>().collectItemPrice +
            (roomTotalPayment ?? 0.0))));

    if (posController.paymentTab.toLowerCase() == 'cash') {
      if (paidController.text.isEmpty ?? true) {
        showErrorToast('Please enter paid amount');
      } else if (double.parse(paidController.text) <
          (Get.find<AuthController>()
                      .profileModel
                      ?.restaurants
                      ?.first
                      .isTotalRound ==
                  'Yes'
              ? getRoundUpValue(value: checkAmount)
              : checkAmount)) {
        showErrorToast('Paid amount cannot be less than bill amount');
      } else {
        callCollectBillApi(jsonData);
      }
    } else if (posController.paymentTab.toLowerCase() == 'partial') {
      double totalPay = (((roomTotalPayment == 0
              ? Get.find<PosController>().collectItemPrice
              : Get.find<PosController>().collectItemPrice +
                  (roomTotalPayment ?? 0.0))) +
          (posController.getCollectBillDetailResponse?.orders?.roomInfo
                  ?.remainingPay ??
              0.0));
      if (pCash.text.isEmpty) {
        showErrorToast('Please enter cash amount');
      } else if (pCard.text.isEmpty) {
        showErrorToast('Please enter card amount');
      } else if (pUpi.text.isEmpty) {
        showErrorToast('Please enter UPI amount');
      } else if (pCard.text.isNotEmpty &&
          pCard.text != '0' &&
          pTXN.text.isEmpty) {
        showErrorToast('Please enter transaction number for card payment');
      } else if (pCard.text.isNotEmpty &&
          pCard.text != '0' &&
          pTXN.text.isNotEmpty &&
          pTXN.text.trim().length < 4) {
        showErrorToast('Enter valid transaction number for card payment');
      } else {
        double totalPartialAmt = double.parse(pCash.text) +
            double.parse(pCard.text) +
            double.parse(pUpi.text);
        if (totalPartialAmt <
            (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .isTotalRound ==
                    'Yes'
                ? getRoundUpValue(value: totalPay)
                : totalPay)) {
          showErrorToast(
              'Total partial amount cannot be less than bill amount');
        } else if (totalPartialAmt >
            (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .isTotalRound ==
                    'Yes'
                ? getRoundUpValue(value: totalPay)
                : totalPay)) {
          showErrorToast(
              'Total partial amount cannot be greater than bill amount');
        } else {
          callCollectBillApi(jsonData);
        }
      }
    } else if (Get.find<PosController>().paymentTab.toLowerCase() == 'card') {
      if ((((transactionNoController.text.isEmpty ?? true) ||
              transactionNoController.text.trim().length < 4)) &&
          Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .edcDetail!
                  .pinelab !=
              'Yes') {
        showErrorToast('Please enter transaction number');
      } else {
        callCollectBillApi(jsonData);
      }
    } else {
      callCollectBillApi(jsonData);
    }
  }

  payTabBills() {
    print('tab Bill print after collect bill ............');
    double orderPay = (Get.find<PosController>().collectItemPrice);
    double serviceGstTax = Get.find<PosController>().isAddServiceCharge
        ? ((((serviceValue ?? 0.0) *
                Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .serviceChargeTaxPercent!) /
            100))
        : 0;

    Map<String, dynamic> jsonData = {
      'food_detail': jsonCartList,
      'waiter_id':
          Get.find<AuthController>().profileModel?.empId?.toString() ?? '',
      'tip_tax_amount': tipTaxAmount,
      'service_gst_tax_amount': Get.find<PosController>().isAddServiceCharge
          ? ((((serviceValue ?? 0.0) *
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .serviceChargeTaxPercent!) /
                  100)
              .toStringAsFixed(2))
          : 0.0,
      'delivery_charge_gst': gstOnDeliveryCharge ?? 0,
      'payment_mode': 'TAB',
      'payment_status': 'sucess',
      'email': emailController.text.isEmpty ?? true ? '' : emailController.text,
      'payment_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: orderPay)
          : orderPay.toStringAsFixed(2),
      'order_sub_total_amount': orderItemTotal,
      'order_sub_total_without_tax': orderSubTotal,
      'discount_member_category_id':
          selectedDiscount == null ? 0 : selectedDiscount!.id,
      'discount_member_category_name':
          selectedDiscount == null ? '' : selectedDiscount!.discountType,
      'discount_value': discountPercent,
      'discount_type': isLoyaltyApply == true ? 'Loyality' : '',
      'order_discount_type': discountType,
      'vat_tax': vatAmount ?? 0.0,
      'grant_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: (orderPay + (roomTotalPayment ?? 0.0)))
          : (orderPay + (roomTotalPayment ?? 0.0)).toStringAsFixed(2),
      'round_up': getRoundUpAmount(orderPay),
      'gst_tax': (gstAmount ?? 0) + (tipTaxAmount ?? 0) + serviceGstTax,
      // 'self_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? 0
      //     : orderDiscount,
      // 'coupon_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? orderDiscount
      //     : 0,
      // 'coupon_title': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponController.text
      //     : '',
      // 'coupon_type': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponDiscountType
      //     : '',
      'self_discount': orderDiscount,
      'coupon_code': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? crmCouponCode
          : '',
      'coupon_discount': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponRupee ?? 0)
          : 0,
      'coupon_title': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponTitle ?? '')
          : '',
      'coupon_type': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponScope ?? '')
          : '',
       // 'comm_discount': coummunityDiscount ?? 0.0,
      'comm_discount': selectedDiscount == null ? 0 : orderDiscount,
      'use_wallet_balance': usedWalletAmount,
      'tip_amount':
          tipsController.text.isEmpty ?? true ? '0' : tipsController.text,
      'order_discount': (orderDiscount ?? 0.0) + (coummunityDiscount ?? 0.0),
      // 'used_loyalty_point': (loyltyDiscountAmount ?? 0),
      'used_loyalty_point':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_points_used':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_discount': (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0)
          ? (loyltyDiscountAmount ?? 0)
          : 0,
      'loyalty_redemption_id': null,
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? (serviceValue ?? 0.0)
          : 0.0,
      'mobile':
          phoneController.text.isEmpty ?? true ? '' : phoneController.text,
      'name': nameController.text.isEmpty ?? true ? '' : nameController.text,
      'cust_membership_id':
          Get.find<PosController>().tabCrmCustomerId,
      'restaurant_name':
          Get.find<AuthController>().profileModel?.restaurants?[0].name ?? '',
      'transaction_id': transactionNoController.text.isEmpty ?? true
          ? ''
          : transactionNoController.text,
      'paid_room': Get.find<PosController>()
                  .getCollectBillDetailResponse
                  ?.orders
                  ?.restaurantDetails
                  ?.restaurantOrderFor ==
              'ROOM'
          ? 'yes'
          : '',
      'order_id': orderId
    };
    callCollectBillApi(jsonData);
  }

  payRoomBills() {
    print('Room Bill print after collect bill ............');
    double orderPay = (Get.find<PosController>().collectItemPrice);
    double serviceGstTax = Get.find<PosController>().isAddServiceCharge
        ? ((((serviceValue ?? 0.0) *
                Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .serviceChargeTaxPercent!) /
            100))
        : 0;
    print('====>$gstAmount ');
    print('====>$tipTaxAmount ');
    print('====>$serviceGstTax ');

    Map<String, dynamic> jsonData = {
      'food_detail': jsonCartList,
      'waiter_id':
          Get.find<AuthController>().profileModel?.empId?.toString() ?? '',
      'payment_mode': 'ROOM',
      'payment_status': 'sucess',
      'tip_tax_amount': tipTaxAmount,
      'service_gst_tax_amount': Get.find<PosController>().isAddServiceCharge
          ? ((((serviceValue ?? 0.0) *
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .serviceChargeTaxPercent!) /
                  100)
              .toStringAsFixed(2))
          : 0.0,
      'delivery_charge_gst': gstOnDeliveryCharge ?? 0,
      'email': emailController.text.isEmpty ?? true ? '' : emailController.text,
      'order_sub_total_amount': orderItemTotal,
      'order_sub_total_without_tax': orderSubTotal,
      'discount_member_category_id':
          selectedDiscount == null ? 0 : selectedDiscount!.id,
      'discount_member_category_name':
          selectedDiscount == null ? '' : selectedDiscount!.discountType,
      'discount_value': discountPercent,
      'discount_type': isLoyaltyApply == true ? 'Loyality' : '',
      'order_discount_type': discountType,
      'payment_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: orderPay)
          : orderPay.toStringAsFixed(2),
      'vat_tax': vatAmount ?? 0.0,
      'round_up': getRoundUpAmount(orderPay),
      'gst_tax': (gstAmount ?? 0) + (tipTaxAmount ?? 0) + serviceGstTax,
      // 'self_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? 0
      //     : orderDiscount,
      // 'coupon_discount': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? orderDiscount
      //     : 0,
      // 'coupon_title': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponController.text
      //     : '',
      // 'coupon_type': (isCouponValid! && couponController.text.isNotEmpty)
      //     ? couponDiscountType
      //     : '',
      'self_discount': orderDiscount,
      'coupon_code': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? crmCouponCode
          : '',
      'coupon_discount': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponRupee ?? 0)
          : 0,
      'coupon_title': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponTitle ?? '')
          : '',
      'coupon_type': (isCouponValid! && (crmCouponCode ?? '').isNotEmpty)
          ? (crmCouponScope ?? '')
          : '',
       // 'comm_discount': coummunityDiscount ?? 0.0,
      'comm_discount': selectedDiscount == null ? 0 : orderDiscount,
      'use_wallet_balance': usedWalletAmount,
      'tip_amount':
          tipsController.text.isEmpty ?? true ? '0' : tipsController.text,
      'order_discount': (orderDiscount ?? 0.0) + (coummunityDiscount ?? 0.0),
      // 'used_loyalty_point': (loyltyDiscountAmount ?? 0),
      'used_loyalty_point':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_points_used':
          (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0) ? crmLoyaltyPoints : 0,
      'loyalty_discount': (isLoyaltyApply! && (crmLoyaltyPoints ?? 0) > 0)
          ? (loyltyDiscountAmount ?? 0)
          : 0,
      'loyalty_redemption_id': null,
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? (serviceValue ?? 0.0)
          : 0.0,
      'mobile':
          phoneController.text.isEmpty ?? true ? '' : phoneController.text,
      'name': nameController.text.isEmpty ?? true ? '' : nameController.text,
      'restaurant_name':
          Get.find<AuthController>().profileModel?.restaurants?[0].name ?? '',
      'transaction_id': transactionNoController.text.isEmpty ?? true
          ? ''
          : transactionNoController.text,
      'order_id': orderId,
      'room_id': '${Get.find<PosController>().selectedRoom?.table?.id ?? ''}'
    };
    Get.find<PosController>().addBillsInRoom(callback, jsonData: jsonData);
  }

  /// print ticket

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
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
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
        await printerManager.connect(
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

  printCustomerCopyIos(List<int> bytes) async {
    Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
        ? await IosPrintTransport.writeBytes(bytes)
        : await _writeBytesForIPad(bytes);
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
      Get.find<LoadingController>().startLoading(false);

      await Get.find<LoadingController>()
          .changeText(data: 'Successfully printed!!');
      await Get.find<LoadingController>().changeStatus(data: true);
      var isDisconnect = await IosPrintTransport.disconnect;
      print('is disconnect $isDisconnect');
    });
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

  checkRestaurantIsOpen() async {
    List<Schedules> schedules =
        Get.find<AuthController>().profileModel!.restaurants!.first.schedules!;
    schedules.sort((a, b) => a.day!.compareTo(b.day!));
    DateTime currentDate = DateTime.now();
    String todayName = DateFormat('EEEE').format(currentDate);
    int? currentDay;
    if (todayName == 'Sunday') {
      currentDay = 0;
    } else if (todayName == 'Monday') {
      currentDay = 1;
    } else if (todayName == 'Tuesday') {
      currentDay = 2;
    } else if (todayName == 'Wednesday') {
      currentDay = 3;
    } else if (todayName == 'Thursday') {
      currentDay = 4;
    } else if (todayName == 'Friday') {
      currentDay = 5;
    } else if (todayName == 'Saturday') {
      currentDay = 6;
    }
    Schedules? todaySchedule;
    Schedules? previousDaySchedule;
    for (var i = 0; i < schedules.length; i++) {
      if (currentDay == schedules[i].day) {
        todaySchedule = schedules[i];
        break;
      }
    }

    for (var i = 0; i < schedules.length; i++) {
      if (currentDay! - 1 == schedules[i].day) {
        previousDaySchedule = schedules[i];
        break;
      }
    }
    if (todaySchedule == null && previousDaySchedule == null) {
      showErrorToast('Restaurant is closed');
    } else if (DateConverter.isAvailable(
        todaySchedule!.openingTime!, todaySchedule.closingTime!)) {
      // showCustomSnackBar('Restaurant is open', isError: false);
      clearPayment();
      // var data = await Get.toNamed(RouteHelper.getWaiterPosRoute(null));
    } else {
      var subtractDate = currentDate.subtract(Duration(days: 1));
      int closeHour =
          int.parse(previousDaySchedule!.closingTime!.split(':').first);
      int closeMinute =
          int.parse(previousDaySchedule.closingTime!.split(':')[1]);
      int openHour =
          int.parse(previousDaySchedule.openingTime!.split(':').first);
      int openMinute =
          int.parse(previousDaySchedule.openingTime!.split(':')[1]);

      if (closeHour <= 9) {
        bool isbefore = currentDate.isBefore(DateTime(currentDate.year,
            currentDate.month, currentDate.day, closeHour, closeMinute));
        bool isAfter = currentDate.isAfter(DateTime(subtractDate.year,
            subtractDate.month, subtractDate.day, openHour, openMinute));
        // print(isAfter);
        if (isbefore && isAfter) {
          // showCustomSnackBar('Restaurant is open previous day');
          clearPayment();
        } else {
          showErrorToast('Restaurant is closed');
        }
      } else {
        showErrorToast('Restaurant is closed');
      }
    }
  }

  clearPayment() {
    if (selectedDiscountType == 'Percent' &&
        discountController.text.isNotEmpty &&
        double.parse(discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      if (posController.paymentTab.toLowerCase() == 'tab') {
        if (phoneController.text.isEmpty) {
          showErrorToast('Please enter phone number ');
        } else if (phoneController.text.isNotEmpty &&
            phoneController.text.length < 10) {
          showErrorToast('Minimum required 10 digit phone number');
        } else {
          if (orderTotal >= 0) {
            payTabBills();
          } else {
            showErrorToast('Please enter valid discount');
          }
        }
      } else {
        if (phoneController.text.isNotEmpty &&
            phoneController.text.length < 10) {
          showErrorToast('Minimum required 10 digit phone number');
        } else {
          if (orderTotal >= 0) {
            if (posController.paymentTab.toLowerCase() == 'room') {
              if (posController.selectedRoom!.table!.id == 0) {
                showErrorToast('Please select room');
              } else
                payRoomBills();
            } else {
              payNormalBill();
            }
          } else {
            showErrorToast('Please enter valid discount');
          }
        }
      }
    }
  }

  callCollectBillApi(Map<String, dynamic> jsonData) async {
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    // CRM records coupon usage when the paid order is committed.
    // if ((isCouponValid! && couponController.text.isNotEmpty)) {
    if (false && (isCouponValid! && couponController.text.isNotEmpty)) {
      var data = await Get.find<LoyaltyController>()
          .redeemCoupon(couponController.text ?? '', couponUserId!);
      if (data.containsKey('message') &&
          data['message'] == 'Coupon redeemed successfully') {
        jsonData['usage_id'] = data['usage_id'];
        if (restaurant.edcDetail != null &&
            restaurant.edcDetail!.pinelab == 'Yes' &&
            restaurant.edcDetail!.pineLabDetail != null &&
            (jsonData['payment_mode'] == 'card' ||
                jsonData['payment_mode'] == 'upi')) {
          jsonData.addAll({
            "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
            "security_token":
                restaurant.edcDetail!.pineLabDetail!.securityToken,
            "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
            "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
          });
          await Get.find<PosController>()
              .edcCollectPayment(callback, jsonData: jsonData);
        } else {
          await Get.find<PosController>()
              .collectPayment(callback, jsonData: jsonData);
        }
      }
    } else {
      jsonData['usage_id'] = '';
      if (restaurant.edcDetail != null &&
          restaurant.edcDetail!.pinelab == 'Yes' &&
          restaurant.edcDetail!.pineLabDetail != null &&
          (jsonData['payment_mode'] == 'card' ||
              jsonData['payment_mode'] == 'upi')) {
        jsonData.addAll({
          "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
          "security_token": restaurant.edcDetail!.pineLabDetail!.securityToken,
          "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
          "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
        });
        await Get.find<PosController>()
            .edcCollectPayment(callback, jsonData: jsonData);
      } else {
        await Get.find<PosController>()
            .collectPayment(callback, jsonData: jsonData);
      }
      // await Get.find<PosController>()
      //     .collectPayment(callback, jsonData: jsonData);
    }
  }
}
