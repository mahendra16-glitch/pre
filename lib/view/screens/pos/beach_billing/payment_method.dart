import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_respone.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
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
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
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

class BeachBillingPaymentMethod extends StatelessWidget {
  final TextEditingController? transactionNoController;
  final TextEditingController? noteController;
  final TextEditingController? phoneController;
  final TextEditingController? nameController;
  final TextEditingController? discountController;
  final TextEditingController? paidController;
  final TextEditingController? changeController;
  final TextEditingController? tipsController;
  final Function? placeOrderEvent;
  final double orderTotal;
  final double serviceChargeValue;
  final String orderId;
  final double orderSubTotal;
  final double gstAmount;
  final double vatAmount;
  final double orderDiscount;
  final bool isPrintKot;

  final PrinterManager? printerManager;
  final PosController? posController;
  final bool isPrint;
  List<int>? pendingTask;

  BeachBillingPaymentMethod({
    this.noteController,
    this.transactionNoController,
    this.phoneController,
    this.nameController,
    this.discountController,
    this.paidController,
    this.changeController,
    this.tipsController,
    this.placeOrderEvent,
    this.orderTotal = 0.0,
    this.serviceChargeValue = 0.0,
    this.orderId = '',
    this.orderSubTotal = 0.0,
    this.gstAmount = 0.0,
    this.vatAmount = 0.0,
    this.orderDiscount = 0.0,
    this.printerManager,
    this.isPrint = false,
    this.pendingTask,
    this.posController,
    this.isPrintKot = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        posController!.selectedPaymentTab == 5
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
                            children: [
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payCash ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.14,
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
                                  width: Get.width * 0.14,
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
                                  width: Get.width * 0.14,
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
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payTab ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.14,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      posController.setPaymentTabIndex(3);
                                    },
                                    child: Container(
                                      width: Get.width,
                                      margin: EdgeInsets.only(right: 5),
                                      padding: EdgeInsets.symmetric(
                                          // horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      3
                                                  ? Colors.transparent
                                                  : ColorTheme.borderGrey),
                                          color: posController
                                                      .selectedPaymentTab ==
                                                  3
                                              ? ColorTheme.appColor
                                              : Colors.transparent,

                                          // border:
                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: Text(
                                          'Credit',
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      3
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
                                      .showRoom ==
                                  'Yes')
                                SizedBox(
                                  width: Get.width * 0.14,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      posController.setPaymentTabIndex(4);
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
                                                      4
                                                  ? Colors.transparent
                                                  : ColorTheme.borderGrey),
                                          color: posController
                                                      .selectedPaymentTab ==
                                                  4
                                              ? ColorTheme.appColor
                                              : Colors.transparent,

                                          // border:
                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: Text(
                                          'Room'.tr,
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController
                                                          .selectedPaymentTab ==
                                                      4
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
                                                    color:
                                                        ColorTheme.borderGrey),
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
                                                        color:
                                                            value.table!.id == 0
                                                                ? Colors.grey
                                                                : Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (GetRoomListResponse?
                                                    value) {
                                                  posController
                                                      .setRoomIndex(value);

                                                  if (value!.user != null) {
                                                    nameController!.clear();
                                                    phoneController!.clear();
                                                    if (value.user!.fName !=
                                                        '') {
                                                      nameController!.text =
                                                          value.user!.fName;
                                                    }
                                                  }
                                                  if (value.user != null) {
                                                    if (value.user!.phone !=
                                                        '') {
                                                      phoneController!.text =
                                                          value.user!.phone;
                                                    }
                                                  }
                                                },
                                                underline: SizedBox(),
                                              ),
                                            ),
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
                                                      if (paidController!
                                                          .text.isEmpty) {
                                                        changeController!.text =
                                                            '';
                                                      } else {
                                                        if (double.parse(
                                                                paidController!
                                                                    .text) >
                                                            (posController
                                                                .collectItemPrice)) {
                                                          changeController!
                                                                  .text =
                                                              '${(double.parse(paidController!.text) - posController.collectItemPrice).toStringAsFixed(2)}';
                                                        } else {
                                                          changeController!
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
                                                  'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<PosController>().collectItemPrice}&tn=',
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
                                                // if (isPrint) {
                                                showToast('Please wait..');
                                                Get.find<LoadingController>()
                                                    .startLoading(true);

                                                kdsBytesConvert('', false);
                                                // }
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

                                            if (posController
                                                    .selectedPaymentTab ==
                                                3) {
                                              if (phoneController!
                                                  .text.isEmpty) {
                                                showErrorToast(
                                                    'Please enter phone number ');
                                              } else if (phoneController!
                                                      .text.isNotEmpty &&
                                                  phoneController!.text.length <
                                                      10) {
                                                showErrorToast(
                                                    'Minimum required 10 digit phone number');
                                              } else {
                                                if (orderTotal >= 0) {
                                                  // payTabBills();
                                                  payNormalBill();
                                                } else {
                                                  showErrorToast(
                                                      'Please enter valid discount');
                                                }
                                              }
                                            } else {
                                              if (phoneController!
                                                      .text.isNotEmpty &&
                                                  phoneController!.text.length <
                                                      10) {
                                                showErrorToast(
                                                    'Minimum required 10 digit phone number');
                                              } else {
                                                if (orderTotal >= 0) {
                                                  if (posController
                                                          .selectedPaymentTab ==
                                                      4) {
                                                    if (posController
                                                            .selectedRoom!
                                                            .table!
                                                            .id ==
                                                        0) {
                                                      showErrorToast(
                                                          'Please select room');
                                                    } else {
                                                      // payRoomBills();
                                                      payNormalBill();
                                                    }
                                                  } else {
                                                    payNormalBill();
                                                  }
                                                } else {
                                                  showErrorToast(
                                                      'Please enter valid discount');
                                                }
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

  payNormalBill() {
    Map<String, dynamic> jsonData = {
      'waiter_id': Get.find<AuthController>().profileModel!.empId.toString(),
      'payment_mode': Get.find<PosController>().selectedPaymentTab == 0
          ? 'cash'
          : Get.find<PosController>().selectedPaymentTab == 1
              ? 'card'
              : Get.find<PosController>().selectedPaymentTab == 2
                  ? 'upi'
                  : posController!.selectedPaymentTab == 4
                      ? 'ROOM'
                      : 'TAB',
      'paid_room': posController!.selectedPaymentTab == 4 ? 'Yes' : '',
      'payment_status': 'sucess',
      'cust_email': '',
      "order_note": noteController?.text ?? '',
      "order_amount": orderSubTotal,
      'payment_amount': Get.find<PosController>().collectItemPrice,
      'vat_tax': vatAmount,
      'gst_tax': gstAmount,
      'self_discount': orderDiscount,
      'tip_amount': tipsController!.text.isEmpty ? '0' : tipsController!.text,
      'order_discount': orderDiscount,
      'cust_mobile': phoneController!.text.isEmpty ? '' : phoneController!.text,
      'cust_name': nameController!.text.isEmpty ? '' : nameController!.text,
      'restaurant_name':
          Get.find<AuthController>().profileModel!.restaurants![0].name,
      'service_tax':
          Get.find<PosController>().isAddServiceCharge ? serviceChargeValue : 0,
      'transaction_id': transactionNoController!.text.isEmpty
          ? ''
          : transactionNoController!.text,
      'room_id': posController!.selectedPaymentTab == 4
          ? '${Get.find<PosController>().selectedRoom!.table!.id}'
          : ''
    };
    if (Get.find<PosController>().selectedPaymentTab == 0) {
      if (paidController!.text.isEmpty) {
        showErrorToast('Please enter paid amount');
      } else if (double.parse(paidController!.text) <
          Get.find<PosController>().collectItemPrice) {
        showErrorToast('Paid amount cannot be less than bill amount');
      } else {
        Get.find<CartController>()
            .placeAndPayOrder(callback, jsonBody: jsonData);
      }
    } else if (Get.find<PosController>().selectedPaymentTab == 1 ||
        Get.find<PosController>().selectedPaymentTab == 2 ||
        Get.find<PosController>().selectedPaymentTab == 3 ||
        Get.find<PosController>().selectedPaymentTab == 4) {
      if (transactionNoController!.text.isEmpty &&
          Get.find<PosController>().selectedPaymentTab == 1) {
        showErrorToast('Please enter transaction number');
      } else {
        Get.find<CartController>()
            .placeAndPayOrder(callback, jsonBody: jsonData);
      }
    }
  }

  void callback(bool isSuccess, String message, String orderID) async {
    if (isSuccess) {
      // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
      if (isPrintKot) {
        showToast('Please wait..');
        Get.find<LoadingController>().startLoading(true);

        await kdsBytesConvert(orderID, true);
      } else {
        Get.back();
        Get.find<CartController>().clearCartList();
      }
    } else {
      showErrorToast(message);
    }
  }

  Future kdsBytesConvert(String orderIDD, bool isPlace) async {
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
        bytes += generator.image(logoHelper.logoUrlPrint!);
      } catch (e) {
        print(e);
      }
    }
    bytes += generator.text(profileModel.restaurants![0].name!,
        styles: PrinterConfig().titleStyle());
    bytes += generator.text(profileModel.restaurants![0].address!,
        styles: PrinterConfig().addressStyle());
    if (profileModel.restaurants![0].gstCode != '')
      bytes += generator.text('GST no. ${profileModel.restaurants![0].gstCode}',
          styles: PrinterConfig().gstStyle());
    if (profileModel.restaurants![0].fssai != '')
      bytes += generator.text('FSI no. ${profileModel.restaurants![0].fssai}',
          styles: PrinterConfig().gstStyle());

    bytes += generator.row([
      PosColumn(
          text: 'Bill No.' + ':' + ' $orderIDD',
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
        text: '${nameController?.text ?? ''}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel!.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig!
                              .restaurantFoodList ==
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
                          .printConfig!
                          .restaurantFoodList ==
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
                          .printConfig!
                          .restaurantFoodList ==
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
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: '${phoneController?.text ?? ''}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel?.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig!
                              .restaurantFoodList ==
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
                      .printConfig
                      ?.restaurantFoodList
                      ?.split(',')[1] ??
                  ''),
          bold: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList ==
                      null
              ? false
              : (Get.find<AuthController>()
                          .profileModel!
                          .printConfig
                          ?.restaurantFoodList
                          ?.split(',')
                          .last ==
                      'true'
                  ? true
                  : false),
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
            // text: '${food.quantity}',
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
    if (tipsController!.text.isNotEmpty && tipsController!.text != '0')
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
            text: PriceConverter.convertPrice(
                double.parse(tipsController!.text),
                isHideCurrency: true,
                asFixed: 2),
            width: 3,
            styles: PrinterConfig().subtotalStyle()),
      ]);
    if (Get.find<PosController>().isAddServiceCharge &&
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .serviceCharge ==
            'Yes')
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
              'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<PosController>().collectItemPrice}&tn=',
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
      await _kdsPrintEscPos(bytes, generator, isPlacedOrder: isPlace); //kitchen
    } else {
      await _iosPrintEscPos(bytes, generator, isPlacedOrder: isPlace); //kitchen
    }
  }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes, Generator generator,
      {bool isPlacedOrder = false}) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          address: Get.find<AuthController>().profileModel!.billPrinterIp,
          deviceName: Get.find<AuthController>()
              .profileModel!
              .billPrinterName); // ip was mandadory
    }

    var data;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      data = await printerManager!.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
        ),
      );
    } else {
      data = await printerManager!.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
        ),
      );
    }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
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
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        await printerManager!.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }

    try {
      await printerManager!
          .send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      pendingTask = null;
      Future.delayed(Duration(seconds: 5), () async {
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance.disconnect(
            type: Get.find<AuthController>().profileModel!.billPrinterType ==
                    'usb'
                ? PrinterType.usb
                : PrinterType.bluetooth);
        if (isPlacedOrder) {
          Get.back();
          Get.back();
          Get.find<CartController>().clearCartList();
        }
      });
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    if (data != null && !data) {
      await Get.find<LoadingController>().changeText(
          data:
              Get.find<AuthController>().profileModel!.billPrinterType == 'usb'
                  ? 'Failed to usb connect!!'
                  : 'Failed to bluetooth connect!!',
          error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  Future _iosPrintEscPos(List<int> bytes, Generator generator,
      {bool isPlacedOrder = false}) async {
    print('########## bytes length ${bytes.length}');
    bytes += generator.feed(2);
    bytes += generator.cut();
    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
        macPrinterAddress:
            Get.find<AuthController>().profileModel!.macBillPrinterIp!);

    Future.delayed(Duration(seconds: 1), () async {
      if (result) {
        // List<int> ticket = await testTicket();
        await IosPrintTransport.writeBytes(bytes);

        Future.delayed(Duration(seconds: 7), () async {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Successfully printed!!');
          await Get.find<LoadingController>().changeStatus(data: true);
          var isDisconnect =
          print('is disconnect $isDisconnect');
          if (isPlacedOrder) {
            Get.back();
            Get.find<CartController>().clearCartList();
          }
        });
        print("print test result:  $result");
      } else {
        //no conectado, reconecte
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Failed to bluetooth connect!!', error: true);
        await Get.find<LoadingController>().changeStatus(data: true);
        // showErrorToast('Failed to bluetooth connect');
      }
      // });
    });
  }
}
