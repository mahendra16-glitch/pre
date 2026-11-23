import 'dart:convert';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_respone.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as prefix;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

class BillingPaymentMethod extends StatelessWidget {
  final TextEditingController transactionNoController;
  final TextEditingController noteController;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController discountController;
  final TextEditingController paidController;
  final TextEditingController changeController;
  final TextEditingController tipsController;
  final Function placeOrderEvent;
  final double orderTotal;
  final double serviceChargeValue;
  final String orderId;
  final double orderSubTotal;
  final double gstAmount;
  final double orderDiscount;

  final PrinterManager printerManager;
  final PosController posController;
  final bool isPrint;
  List<int> pendingTask;

  BillingPaymentMethod({
    super.key,
    required this.noteController,
    required this.transactionNoController,
    required this.phoneController,
    required this.nameController,
    required this.discountController,
    required this.paidController,
    required this.changeController,
    required this.tipsController,
    required this.placeOrderEvent,
    required this.orderTotal,
    required this.serviceChargeValue,
    required this.orderId,
    required this.orderSubTotal,
    required this.gstAmount,
    required this.orderDiscount,
    required this.printerManager,
    required this.isPrint,
    required this.pendingTask,
    required this.posController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        posController.selectedPaymentTab == 5
            ? SizedBox.shrink()
            : Padding(
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
                      return Column(
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payCash ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.2,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      posController.setPaymentTabIndex(0);
                                    },
                                    child: Container(
                                      width: Get.width,
                                      margin: EdgeInsets.only(right: 5),
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      0
                                                  ? Colors.transparent
                                                  : ColorTheme.borderGrey),
                                          color: posController
                                                      .selectedPaymentTab ==
                                                  0
                                              ? ColorTheme.appColor
                                              : Colors.transparent,
                                          // border:
                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: Text(
                                          'Cash'.tr,
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      0
                                                  ? Colors.white
                                                  : ColorTheme.appColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payCC ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.2,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      posController.setPaymentTabIndex(1);
                                    },
                                    child: Container(
                                      width: Get.width,
                                      margin: EdgeInsets.only(right: 5),
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      1
                                                  ? Colors.transparent
                                                  : ColorTheme.borderGrey),
                                          color: posController
                                                      .selectedPaymentTab ==
                                                  1
                                              ? ColorTheme.appColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: Text(
                                          'Card'.tr,
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      1
                                                  ? Colors.white
                                                  : ColorTheme.appColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payUpi ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.2,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      posController.setPaymentTabIndex(2);
                                    },
                                    child: Container(
                                      width: Get.width,
                                      margin: EdgeInsets.only(right: 5),
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      2
                                                  ? Colors.transparent
                                                  : ColorTheme.borderGrey),
                                          color: posController
                                                      .selectedPaymentTab ==
                                                  2
                                              ? ColorTheme.appColor
                                              : Colors.transparent,

                                          // border:
                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: Text(
                                          'UPI'.tr,
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      2
                                                  ? Colors.white
                                                  : ColorTheme.appColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          DottedLine(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            lineThickness: 1.0,
                            dashLength: 2.5,
                            dashColor: ColorTheme.hintText,
                          ),

                          posController.selectedPaymentTab == 4
                              ? GetBuilder<PosController>(
                                  builder: (posController) {
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
                                                height: 30,
                                                margin: EdgeInsets.only(
                                                    top: 20, bottom: 15),
                                                // width: Get.width * 0.8,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey),
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
                                                      ? posController
                                                          .roomList.first
                                                      : posController
                                                          .selectedRoom,
                                                  items: posController.roomList
                                                      .map((GetRoomListResponse
                                                          value) {
                                                    return DropdownMenuItem<
                                                        GetRoomListResponse>(
                                                      value: value,
                                                      child: Text(
                                                        '${value.table!.title} ${value.table!.tableNo}',
                                                        maxLines: 1,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          color: value.table!
                                                                      .id ==
                                                                  0
                                                              ? Colors.grey
                                                              : Colors.black,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (GetRoomListResponse?
                                                          value) {
                                                    posController
                                                        .setRoomIndex(value!);

                                                    if (value.user != null) {
                                                      nameController.clear();
                                                      phoneController.clear();
                                                      if (value.user!.fName !=
                                                          '') {
                                                        nameController.text =
                                                            value.user!.fName;
                                                      }
                                                    }
                                                    if (value.user != null) {
                                                      if (value.user!.phone !=
                                                          '') {
                                                        phoneController.text =
                                                            value.user!.phone;
                                                      }
                                                    }
                                                  },
                                                  underline: SizedBox(),
                                                ),
                                              ),

                                            // Padding(
                                            //   padding:
                                            //       const EdgeInsets.only(
                                            //           top: 15),
                                            //   child:
                                            //       emailTextField(context),
                                            // ),
                                            SizedBox(height: 15),
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

                                      posController.selectedPaymentTab == 0
                                          ? Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: ColorTheme
                                                              .borderGrey)),
                                                  child: TextField(
                                                    controller: paidController,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            signed: true),
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide: BorderSide(
                                                            style: BorderStyle
                                                                .none,
                                                            width: 0),
                                                      ),
                                                      hintStyle: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey),
                                                      filled: true,
                                                      hintText: 'Paid',
                                                      fillColor: Colors.white,
                                                    ),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                    onChanged: (value) async {
                                                      if (paidController
                                                          .text.isEmpty) {
                                                        changeController.text =
                                                            '';
                                                      } else {
                                                        if (double.parse(
                                                                paidController
                                                                    .text) >
                                                            (posController
                                                                .collectItemPrice)) {
                                                          changeController
                                                                  .text =
                                                              '${(double.parse(paidController.text) - posController.collectItemPrice).toStringAsFixed(2)}';
                                                        } else {
                                                          changeController
                                                              .text = '0';
                                                        }
                                                      }
                                                      // posController.update();
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .RADIUS_SMALL),
                                                      border: Border.all(
                                                          color: ColorTheme
                                                              .borderGrey)),
                                                  child: TextField(
                                                    controller:
                                                        changeController,
                                                    autofocus: false,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          borderSide: BorderSide(
                                                              style: BorderStyle
                                                                  .none,
                                                              width: 0),
                                                        ),
                                                        hintStyle: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText: 'Change'),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                    onChanged: (value) async {},
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox.shrink(),
                                      posController.selectedPaymentTab == 1
                                          ? Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey)),
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
                                                        BorderRadius.circular(
                                                            5),
                                                    borderSide: BorderSide(
                                                        style: BorderStyle.none,
                                                        width: 0),
                                                  ),
                                                  hintStyle:
                                                      poppinsMedium.copyWith(
                                                          fontSize: 13,
                                                          color: Colors.grey),
                                                  hintText: 'Transaction No.',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                onChanged: (value) async {},
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      // Padding(
                                      //   padding: EdgeInsets.only(
                                      //       top: posController
                                      //                   .selectedPaymentTab ==
                                      //               2
                                      //           ? 0
                                      //           : 15),
                                      //   child: phoneTextField(context),
                                      // ),

                                      posController.selectedPaymentTab == 2 &&
                                              Get.find<AuthController>()
                                                      .profileModel!
                                                      .restaurants!
                                                      .first
                                                      .upiId !=
                                                  ''
                                          ? QrImageView(
                                              data:
                                                  'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<AuthController>().profileModel!.restaurants!.first.dynamicUpiValue == 'No' ? 0 : Get.find<PosController>().collectItemPrice}&tn=',
                                              size: 120,
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
                                        GetBuilder<KdsController>(
                                            builder: (kdsController) {
                                          return InkWell(
                                              onTap: () async {
                                                if (isPrint) {
                                                  showToast('Please wait..');
                                                  Get.find<LoadingController>()
                                                      .startLoading(true);

                                                  kdsBytesConvert();
                                                }
                                              },
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: SvgPicture.asset(
                                                  Images.ic_print_kot,
                                                  height: 26,
                                                ),
                                              ));
                                        }),
                                        InkWell(
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            double orderAmount =
                                                Get.find<CartController>()
                                                    .subTotal;

                                            double tempDiscountPercent = 0;

                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .discountType ==
                                                'Fixed') {
                                              tempDiscountPercent = orderAmount ==
                                                      0
                                                  ? 0
                                                  : ((double.parse(
                                                              discountController
                                                                  .text)) *
                                                          100) /
                                                      (orderAmount);
                                            } else {
                                              tempDiscountPercent =
                                                  double.parse(
                                                      discountController.text);
                                            }

                                            if (phoneController
                                                    .text.isNotEmpty &&
                                                phoneController.text.length <
                                                    10) {
                                              showErrorToast(
                                                  'Minimum required 10 digit phone number');
                                            } else {
                                              if (orderDiscount >= 0) {
                                                payNormalBill(context);
                                                // print('success place order...');
                                              } else {
                                                showErrorToast(
                                                    'Please enter valid discount');
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 30,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_DEFAULT,
                                            ),
                                            decoration: BoxDecoration(
                                                color: ColorTheme.appColor,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Center(
                                              child: Text(
                                                'Place Order',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.white),
                                              ),
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

  // void callback(bool isSuccess, String message) async {
  //   if (isSuccess) {
  //     Get.back();

  //     showErrorToast(message, isError: false);

  //     Get.find<PosController>().setPaymentTabIndex(0);
  //   } else {
  //     showErrorToast(message);
  //   }
  // }

  saveOrderLocally(BuildContext context) async {
    List<LocalOrderModel> orderList = [];
    orderList = await Get.find<CartController>().getOrderListFromLocally();

    LocalOrderModel orderModel = LocalOrderModel(
        cartList: Get.find<CartController>().cartList,
        employeeId: Get.find<AuthController>().selectedEmployee == null
            ? (Get.find<AuthController>().profileModel?.empId ?? 0)
            : (Get.find<AuthController>().selectedEmployee?.id ?? 0),
        createdAt: DateTime.now().toString(),
        discount: orderDiscount,
        employeeName: Get.find<AuthController>().selectedEmployee == null
            ? (Get.find<AuthController>().profileModel?.empFname ?? '')
            : (Get.find<AuthController>().selectedEmployee?.fName ?? ''),
        gstTaxAmount: gstAmount,
        serviceCharge: serviceChargeValue,
        tips:
            tipsController.text.isEmpty ? 0 : double.parse(tipsController.text),
        orderAmount: Get.find<PosController>().collectItemPrice,
        name: nameController.text.isEmpty ? '' : nameController.text,
        phoneNumber: phoneController.text.isEmpty ? '' : phoneController.text,
        orderId: orderId,
        paymentMethod: Get.find<PosController>().selectedPaymentTab == 0
            ? 'cash'
            : Get.find<PosController>().selectedPaymentTab == 1
                ? 'card'
                : 'upi',
        subTotal: orderSubTotal,
        notes: noteController.text.isEmpty ? '' : noteController.text);
    orderList.add(orderModel);
    List<String> orderListJson =
        orderList.map((order) => jsonEncode(order.toJson())).toList();

    Get.find<CartController>().saveOrderList(orderListJson);
    Get.find<CartController>().saveLastOrderId(orderId);
    // print(await Get.find<CartController>().getLastOrderIdFromLocal());
    Get.find<CartController>().clearCartList();
    placeOrderEvent(true);
    Navigator.of(context).pop();
    // show
    showErrorToast('Order has been placed successfully.', isError: false);
  }

  // Widget emailTextField(BuildContext context) {
  //   return Container(
  //     height: 30,
  //     child: TypeAheadField(
  //       getImmediateSuggestions: true,
  //       textFieldConfiguration: TextFieldConfiguration(
  //         controller: emailController,
  //         textInputAction: TextInputAction.search,
  //         autofocus: false,
  //         textCapitalization: TextCapitalization.words,
  //         keyboardType: TextInputType.name,
  //         decoration: InputDecoration(
  //           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
  //             borderSide: BorderSide(color: ColorTheme.borderGrey),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
  //             borderSide: BorderSide(color: ColorTheme.borderGrey),
  //           ),
  //           disabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
  //             borderSide: BorderSide(color: ColorTheme.borderGrey),
  //           ),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
  //             borderSide: BorderSide(color: ColorTheme.borderGrey),
  //           ),
  //           hintStyle: poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
  //           hintText: 'Email',
  //           filled: true,
  //           fillColor: Colors.white,
  //         ),
  //         style: poppinsMedium.copyWith(
  //           color: Colors.black,
  //           fontSize: 13,
  //         ),
  //       ),
  //       noItemsFoundBuilder: (context) => SizedBox.shrink(),
  //       suggestionsCallback: (pattern) async {
  //         return Get.find<PosController>()
  //             .tapManagmentCustomerListResponse
  //             .employeeTapList
  //             .where((item) => item.email
  //                 .toString()
  //                 .trim()
  //                 .toLowerCase()
  //                 .contains(pattern.toLowerCase().trim()))
  //             .toList();
  //       },
  //       itemBuilder: (context, EmployeeTapList suggestion) {
  //         return Padding(
  //           padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
  //           child: Row(children: [
  //             SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
  //             Expanded(
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('${suggestion?.email ?? ''}',
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: poppinsRegular.copyWith(
  //                           color: Theme.of(context).textTheme.bodyLarge.color,
  //                           fontSize: Dimensions.FONT_SIZE_SMALL,
  //                         )),
  //                   ]),
  //             ),
  //           ]),
  //         );
  //       },
  //       onSuggestionSelected: (EmployeeTapList suggestion) {
  //         phoneController.text = suggestion.mobile.toString();
  //         nameController.text = suggestion.name;
  //         emailController.text = suggestion.email;
  //         Get.find<PosController>().update();
  //       },
  //     ),
  //   );
  // }

  payNormalBill(BuildContext context) {
    // Map<String, dynamic> jsonData = {
    //   'waiter_id': Get.find<AuthController>().profileModel.id.toString(),
    //   'payment_mode': Get.find<PosController>().selectedPaymentTab == 0
    //       ? 'cash'
    //       : Get.find<PosController>().selectedPaymentTab == 1
    //           ? 'card'
    //           : Get.find<PosController>().selectedPaymentTab == 2
    //               ? 'upi'
    //               : 'TAB',
    //   'paid_room': Get.find<PosController>()
    //               .getCollectBillDetailResponse
    //               .orders
    //               .restaurantDetails
    //               .restaurantOrderFor ==
    //           'ROOM'
    //       ? 'yes'
    //       : '',
    //   'payment_status': 'sucess',
    //   'email': '',
    //   'payment_amount': Get.find<PosController>().collectItemPrice +
    //       posController?.getCollectBillDetailResponse?.orders?.orderDetailsOrder
    //           ?.deliveryCharge,
    //   'grant_amount': Get.find<PosController>().collectItemPrice,
    //   'vat_tax': 0,
    //   'gst_tax': gstAmount,
    //   'self_discount': 0,
    //   'comm_discount': coummunityDiscount,
    //   'tip_amount': tipsController.text.isEmpty ? '0' : tipsController.text,
    //   'order_discount': coummunityDiscount,
    //   'mobile': phoneController.text.isEmpty ? '' : phoneController.text,
    //   'name': nameController.text.isEmpty ? '' : nameController.text,
    //   'restaurant_name':
    //       Get.find<AuthController>().profileModel.restaurants[0].name,
    //   'service_tax': 0,
    //   'transaction_id': transactionNoController.text.isEmpty
    //       ? ''
    //       : transactionNoController.text,
    //   'order_id': ''
    // };
    if (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .discountType !=
            'Fixed' &&
        discountController.text.isNotEmpty &&
        double.parse(discountController.text) <= 100) {
      if (Get.find<PosController>().selectedPaymentTab == 0) {
        if (paidController.text.isEmpty) {
          showErrorToast('Please enter paid amount');
        } else if (double.parse(paidController.text) <
            Get.find<PosController>().collectItemPrice) {
          showErrorToast('Paid amount cannot be less than bill amount');
        } else {
          // Get.find<CartController>().clearCartList();
          // return Navigator.of(context).pop(true);
          saveOrderLocally(context);
          // print('success place order...');

          // Get.find<PosController>().collectPayment(callback, jsonData: jsonData);
        }
      } else if (Get.find<PosController>().selectedPaymentTab == 1 ||
          Get.find<PosController>().selectedPaymentTab == 2) {
        if (transactionNoController.text.isEmpty &&
            Get.find<PosController>().selectedPaymentTab == 1) {
          showErrorToast('Please enter transaction number');
        } else {
          saveOrderLocally(context);

          // Get.find<CartController>().clearCartList();
          // return Navigator.of(context).pop(true);

          // print('success place order...');

          // Get.find<PosController>().collectPayment(callback, jsonData: jsonData);
        }
      }
    } else {
      showErrorToast('Please enter valid discount');
    }
  }

  Future kdsBytesConvert() async {
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

    if (logoHelper.logoUrlPrint != null) {
      try {
        bytes += generator.feed(1);
        if (logoHelper.logoUrlPrint != null) {
          bytes += generator.image(logoHelper.logoUrlPrint!);
        }
      } catch (e) {
        print(e);
      }
    }
    if (profileModel.restaurants != null &&
        profileModel.restaurants!.isNotEmpty) {
      final restaurant = profileModel.restaurants!.first;
      bytes += generator.text(restaurant.name ?? '',
          styles: PrinterConfig().titleStyle());
      bytes += generator.text(restaurant.address ?? '',
          styles: PrinterConfig().addressStyle());
      if ((restaurant.gstCode ?? '').isNotEmpty) {
        bytes += generator.text('GST no. ${restaurant.gstCode!}',
            styles: PrinterConfig().gstStyle());
      }
      if ((restaurant.fssai ?? '').isNotEmpty) {
        bytes += generator.text('FSI no. ${restaurant.fssai!}',
            styles: PrinterConfig().gstStyle());
      }
    }

    bytes += generator.row([
      PosColumn(
          text: 'order_id'.tr + ':' + ' $orderId',
          width: 6,
          styles: PrinterConfig().orderIdStyle()),
      PosColumn(
          text:
              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
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
          text:
              '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
          width: 6,
          styles: PrinterConfig().waiterNameStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
        text: nameController.text,
        width: 5,
        styles: PosStyles(
          height: (Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList ==
                  null)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList
                      ?.split(',')
                      .first ??
                  ''),
          width: (Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList ==
                  null)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList
                      ?.split(',')[1] ??
                  ''),
          bold: (Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList !=
                      null) &&
                  (Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList
                          ?.split(',')
                          .last ==
                      'true')
              ? true
              : false,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 2,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: phoneController.text,
        width: 5,
        styles: PosStyles(
          height: (Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList ==
                  null)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList
                      ?.split(',')
                      .first ??
                  ''),
          width: (Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList ==
                  null)
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig
                      ?.restaurantFoodList
                      ?.split(',')[1] ??
                  ''),
          bold: (Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList !=
                      null) &&
                  (Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList
                          ?.split(',')
                          .last ==
                      'true')
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
          text: 'item_info'.tr, width: 5, styles: PrinterConfig().foodStyle()),
      PosColumn(text: 'qty'.tr, width: 2, styles: PrinterConfig().foodStyle()),
      PosColumn(text: 'Price', width: 3, styles: PrinterConfig().foodStyle()),
    ]);
    bytes += generator.hr(ch: '--');

    List<CartModel> foodOrderList = Get.find<CartController>().cartList;
    for (var i = 0; i < foodOrderList.length; i++) {
      CartModel food = foodOrderList[i];
      String addOnText = '';
      double addonsTotal = 0;
      double variationTotal = 0;
      int index0 = 0;
      List<int> ids = [];
      List<int> qtys = [];
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
        variationText += '(';
        List<String> labelList = [];
        for (int index = 0; index < food.variation.length; index++) {
          if (food.variation[index].isNotEmpty &&
              food.variation[index].contains(true)) {
            // variationText +=
            //     '${variationText.isNotEmpty ? ', ' : ''}${food.product.variations[index].name} (';

            for (int i = 0; i < food.variation[index].length; i++) {
              if (food.variation[index][i]) {
                variationTotal += double.parse(food
                        .product.variations![index].values![i].optionPrice!) *
                    food.quantity;
                labelList
                    .add(food.product.variations![index].values![i].level!);
                // print(variationTotal);
                // variationText +=
                //     '${variationText.endsWith('(') ? '' : ', '}${food.product.variations[index].values[i].level}';
              }
            }
            // variationText += ')';
          }
        }
        variationText += '${labelList.join(',')}';
        variationText += ')';
      }

      bytes += generator.row([
        PosColumn(
            text: '${i + 1}.', width: 2, styles: PrinterConfig().foodStyle()),
        PosColumn(
            text: '${food.product.name} $variationText',
            width: 5,
            styles: PrinterConfig().foodStyle()),
        PosColumn(
            text: formatQuantity(food.quantity),
            width: 2,
            styles: PrinterConfig().foodStyle()),
        PosColumn(
            text:
                '${((food.product.price! * food.quantity) + variationTotal).toStringAsFixed(2)}',
            // '${(food.unitPrice * food.quantity) + (variationTotal) + (addonsTotal)}',
            width: 3,
            styles: PrinterConfig().foodStyle()),
      ]);
      if (addOnText != '' && addonsTotal != 0) {
        bytes += generator.hr(ch: '....');
        bytes += generator.row([
          PosColumn(text: '', width: 2, styles: PrinterConfig().foodStyle()),
          PosColumn(
              text: 'Add-Ons :$addOnText',
              width: 5,
              styles: PrinterConfig().foodStyle()),
          PosColumn(text: '', width: 2, styles: PrinterConfig().foodStyle()),
          PosColumn(
              text: '${addonsTotal.toStringAsFixed(2)}',
              width: 3,
              styles: PrinterConfig().foodStyle()),
        ]);
      }
      // if (variationText != '' && variationTotal != 0) {
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
      //         text: 'Variants  :$variationText',
      //         width: 5,
      //         styles: PrinterConfig().foodStyle()),
      //     PosColumn(
      //       text: '',
      //       width: 2,
      //       styles: PosStyles(align: PosAlign.center),
      //     ),
      //     PosColumn(
      //       text: '${variationTotal * food.quantity}',
      //       width: 3,
      //       styles: PosStyles(align: PosAlign.center),
      //     ),
      //   ]);
      // }

      bytes += generator.hr(ch: '....');
    }

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
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
          text:
              '${PriceConverter.convertPrice(orderSubTotal, isHideCurrency: true, asFixed: 2)}',
          width: 3,
          styles: PrinterConfig().subtotalStyle()),
    ]);
    if (orderDiscount != 0)
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: '${profileModel.restaurants!.first.discountText} ',
          width: 5,
          styles: PrinterConfig().subtotalStyle(),
        ),
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: PriceConverter.convertPrice(orderDiscount,
              isHideCurrency: true, asFixed: 2),
          width: 3,
          styles: PrinterConfig().subtotalStyle(),
        ),
      ]);
    if (tipsController.text.isNotEmpty && tipsController.text != '0')
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
            text: PriceConverter.convertPrice(double.parse(tipsController.text),
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    if (serviceChargeValue != 0)
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
            text: PriceConverter.convertPrice(serviceChargeValue,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    // if (posController?.getCollectBillDetailResponse?.orders?.orderDetailsOrder
    //         ?.deliveryCharge !=
    //     0)
    // bytes += generator.row([
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //     ),
    //   ),
    //   PosColumn(
    //       text: 'Delivery Charge',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle()),
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //       text: PriceConverter.convertPrice(
    //           posController?.getCollectBillDetailResponse?.orders
    //               ?.orderDetailsOrder?.deliveryCharge,
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle()),
    // ]);
    if (gstAmount != 0) {
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
            text: 'CGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(align: PosAlign.center),
        ),
        PosColumn(
            text: PriceConverter.convertPrice(gstAmount / 2,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    }
    if (gstAmount != 0) {
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
            text: 'SGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
        PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(align: PosAlign.center),
        ),
        PosColumn(
            text: PriceConverter.convertPrice(gstAmount / 2,
                isHideCurrency: true, asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    }

    bytes += generator.hr(ch: '....');
    bytes += generator.text(
        'Total: ' +
            '${PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice), isHideCurrency: true, asFixed: 2)} ${profileModel.restaurants?.first.currency ?? ''}',
        styles: PrinterConfig().totalStyle());

    bytes += generator.hr(ch: '....');
    if (Get.find<AuthController>().profileModel!.restaurants!.first.upiId !=
        '') {
      const double qrSize = 170;
      try {
        final uiImg = await QrPainter(
          data:
              'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<AuthController>().profileModel!.restaurants!.first.dynamicUpiValue == 'No' ? 0 : Get.find<PosController>().collectItemPrice}&tn=',
          version: QrVersions.auto,
          gapless: false,
        ).toImageData(qrSize);
        final dir = await getTemporaryDirectory();
        final pathName = '${dir.path}/qr_tmp.png';
        final qrFile = File(pathName);
        final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
        final img = prefix.decodeImage(imgFile.readAsBytesSync());

        bytes += generator.text('Scan to pay',
            styles: const PosStyles(
                align: PosAlign.center,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
                bold: true,
                fontType: PosFontType.fontA));

        bytes += generator.feed(1);
        bytes += generator.image(img!);
        bytes += generator.feed(1);

        // bytes += generator.feed(1);
      } catch (e) {
        print(e);
      }
    }

    // if (profileModel.restaurants.first.feedback == 'Yes') {
    //   try {
    //     const double qrSize = 170;
    //     final uiImg = await QrPainter(
    //       data: '${AppConstants.FEEDBACK_BASE_URL}?orderId=$orderId',
    //       version: QrVersions.auto,
    //       gapless: false,
    //     ).toImageData(qrSize);
    //     final dir = await getTemporaryDirectory();
    //     final pathName = '${dir.path}/qr_tmp.png';
    //     final qrFile = File(pathName);
    //     final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //     final img = prefix.decodeImage(imgFile.readAsBytesSync());

    //     bytes += generator.text('Scan to provide feedback',
    //         styles: const PosStyles(
    //             align: PosAlign.center,
    //             height: PosTextSize.size1,
    //             width: PosTextSize.size1,
    //             bold: true,
    //             fontType: PosFontType.fontA));

    //     bytes += generator.feed(1);
    //     bytes += generator.image(img);
    //     bytes += generator.feed(1);
    //   } catch (e) {
    //     print(e);
    //   }
    // }
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

      var data;
      switch (bluetoothPrinter.typePrinter) {
        case PrinterType.usb:
          bytes += generator.feed(2);
          data = await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
              name: bluetoothPrinter.deviceName ?? '',
              productId: bluetoothPrinter.productId ?? '',
              vendorId: bluetoothPrinter.vendorId ?? '',
            ),
          );
          break;
        case PrinterType.bluetooth:
          data = await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
              name: bluetoothPrinter.deviceName ?? '',
              address: bluetoothPrinter.address ?? '',
              isBle: bluetoothPrinter.isBle,
            ),
          );
          pendingTask = bytes;
          break;
        case PrinterType.network:
          bytes += generator.feed(2);
          data = await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address ?? ''),
          );
          break;
      }

      try {
        await printerManager.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = [];
        Future.delayed(const Duration(seconds: 15), () async {
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
      } catch (e) {}

      if (data != null && !data) {
        if (Get.isRegistered<LoadingController>()) {
          await Get.find<LoadingController>().changeText(
              data: bluetoothPrinter.typePrinter == PrinterType.usb
                  ? 'Failed to usb connect!!'
                  : bluetoothPrinter.typePrinter == PrinterType.network
                      ? 'Failed to Wi-Fi connect!!'
                      : 'Failed to bluetooth connect!!',
              error: true);
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

  Future _iosPrintEscPos(List<int> bytes, Generator generator) async {
    try {
      bytes += generator.feed(2);
      bytes += generator.cut();

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

      Future.delayed(const Duration(seconds: 3), () async {
        if (result) {
          if (!IosPrintTransport.isWifiActive && bytes.length > 200) {
            const int chunkSize = 180;
            for (int i = 0; i < bytes.length; i += chunkSize) {
              final chunk = bytes.sublist(
                i,
                (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
              );
              await IosPrintTransport.writeBytes(chunk);
              await Future.delayed(const Duration(milliseconds: 50));
            }
          } else {
            await IosPrintTransport.writeBytes(bytes);
          }

          Future.delayed(const Duration(seconds: 11), () async {
            try {
              if (Get.isRegistered<LoadingController>()) {
                Get.find<LoadingController>().startLoading(false);
                await Get.find<LoadingController>()
                    .changeText(data: 'Successfully printed!!');
                await Get.find<LoadingController>().changeStatus(data: true);
              }
              await IosPrintTransport.disconnect;
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
}
