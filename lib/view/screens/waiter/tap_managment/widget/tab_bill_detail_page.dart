import 'dart:async';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_room_order_detail_respose_model.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../../util/print_byte_convert.dart';

class TabBillDetailPage extends StatefulWidget {
  final String? orderId;
  final String? name;
  final String? phone;

  const TabBillDetailPage({this.orderId, this.name, this.phone});

  @override
  State<TabBillDetailPage> createState() => _TabBillDetailPageState();
}

class _TabBillDetailPageState extends State<TabBillDetailPage> {
  bool isPrint = true;
  double roomOrders = 0;
  double roomCheckInPrice = 0;

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
        currentStatus = status;
        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              Future.delayed(Duration(seconds: 10), () async {
                await PrinterManager.instance
                    .disconnect(type: PrinterType.bluetooth);
                Get.find<LoadingController>().startLoading(false);
                await Get.find<LoadingController>()
                    .changeText(data: 'Successfully printed!!');
                await Get.find<LoadingController>().changeStatus(data: true);
              });
              pendingTask = [];
            });
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

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<KdsController>().getPaidOrderDetail('${widget.orderId}');
      await Get.find<KdsController>().getPaidRoomOrder('${widget.orderId}');
      for (var element in Get.find<KdsController>().getRoomPaidOrderList) {
        roomOrders = roomOrders + double.parse(element.orderAmount);
      }
    });
  }

  @override
  void dispose() {
    _subscriptionBtStatus?.cancel();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       FocusManager.instance.primaryFocus?.unfocus();
  //     },
  //     child: Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         backgroundColor: Colors.white,
  //         leading: IconButton(
  //             icon: Icon(Icons.chevron_left, size: 36, color: ColorTheme.green),
  //             color: ColorTheme.appColor,
  //             onPressed: () {
  //               Get.back();
  //             }),
  //         titleSpacing: 0,
  //         elevation: 0,
  //         centerTitle: false,
  //         title: Image.asset(logoHelper.appLogo, width: Get.width * 0.3),
  //       ),
  //       body: SafeArea(
  //         child: SingleChildScrollView(
  //           padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
  //           physics: BouncingScrollPhysics(),
  //           child: Center(
  //             child: SizedBox(
  //               child: GetBuilder<KdsController>(builder: (kdsController) {
  //                 return kdsController.isLoading
  //                     ? Center(
  //                         child: CircularProgressIndicator(),
  //                       )
  //                     : kdsController.paidOrderDetailResponse == null
  //                         ? SizedBox.shrink()
  //                         : Column(children: [
  //                             // SizedBox(
  //                             //     height: Dimensions.PADDING_SIZE_SMALL),
  //                             // Text(
  //                             //   'Collect Payment',
  //                             //   style: poppinsMedium.copyWith(
  //                             //       fontSize:
  //                             //           Dimensions.FONT_SIZE_OVER_LARGE),
  //                             // ),
  //                             SizedBox(height: Get.height * 0.04),
  //                             widget.name == null || widget.name == ''
  //                                 ? SizedBox.shrink()
  //                                 : Align(
  //                                     alignment: Alignment.centerLeft,
  //                                     child: Padding(
  //                                       padding: EdgeInsets.only(left: 15),
  //                                       child: Text(
  //                                         'Name: ${widget.name}',
  //                                         style: poppinsMedium.copyWith(
  //                                             fontSize: 14),
  //                                       ),
  //                                     ),
  //                                   ),
  //                             widget.phone == null || widget.phone == ''
  //                                 ? SizedBox.shrink()
  //                                 : Align(
  //                                     alignment: Alignment.centerLeft,
  //                                     child: Padding(
  //                                       padding:
  //                                           EdgeInsets.only(top: 10, left: 15),
  //                                       child: Text(
  //                                         'Phone: ${widget.phone}',
  //                                         style: poppinsMedium.copyWith(
  //                                             fontSize: 14),
  //                                       ),
  //                                     ),
  //                                   ),
  //                             if (Get.find<KdsController>()
  //                                 .getRoomPaidOrderList
  //                                 .isNotEmpty)
  //                               previousBill(),
  //                             Align(
  //                               alignment: Alignment.centerLeft,
  //                               child: Padding(
  //                                 padding: EdgeInsets.only(top: 30, left: 15),
  //                                 child: Text(
  //                                   'Order Id: ${kdsController.paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId == '0' ? kdsController.paidOrderDetailResponse.orders.orderDetailsOrder.id : kdsController.paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId}',
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: 15,
  //                                       color: ColorTheme.appColor),
  //                                 ),
  //                               ),
  //                             ),

  //                             SizedBox(height: 10),
  //                             Padding(
  //                               padding: EdgeInsets.only(left: 15, right: 20),
  //                               child: ListView.builder(
  //                                   itemCount: kdsController
  //                                           ?.paidOrderDetailResponse
  //                                           ?.orders
  //                                           ?.orderDetailsFood
  //                                           ?.length ??
  //                                       0,
  //                                   shrinkWrap: true,
  //                                   physics: BouncingScrollPhysics(),
  //                                   itemBuilder: (BuildContext context, int i) {
  //                                     OrderDetailsFood orderDetailsFood =
  //                                         kdsController?.paidOrderDetailResponse
  //                                             ?.orders?.orderDetailsFood[i];
  //                                     String variationText = '';
  //                                     int variationTotal = 0;
  //                                     int addonsTotal = 0;
  //                                     if (orderDetailsFood.variation != null &&
  //                                         orderDetailsFood
  //                                             .variation.isNotEmpty) {
  //                                       for (int j = 0;
  //                                           j <
  //                                               orderDetailsFood
  //                                                   .variation.length;
  //                                           j++) {
  //                                         variationText +=
  //                                             '${variationText.isNotEmpty ? ', ' : ''}${orderDetailsFood.variation[j].name} (';

  //                                         if (orderDetailsFood
  //                                                 .variation[j].values !=
  //                                             null) {
  //                                           List<String> labelList = [];
  //                                           for (var element in orderDetailsFood
  //                                               .variation[j].values) {
  //                                             labelList.add(element.label);
  //                                             variationTotal += (int.parse(
  //                                                     element.optionPrice) *
  //                                                 orderDetailsFood.quantity);
  //                                           }
  //                                           variationText +=
  //                                               '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
  //                                         }

  //                                         variationText += ')';
  //                                       }
  //                                     }

  //                                     String addons = '';
  //                                     for (var i = 0;
  //                                         i < orderDetailsFood.addOns.length;
  //                                         i++) {
  //                                       addonsTotal = addonsTotal +
  //                                           (orderDetailsFood.addOns[i].price *
  //                                               orderDetailsFood
  //                                                   .addOns[i].quantity);
  //                                       addons +=
  //                                           '${orderDetailsFood.addOns[i].name} (${orderDetailsFood.addOns[i].quantity})';
  //                                     }
  //                                     return orderDetailsFood.foodStatus == 3
  //                                         ? SizedBox.shrink()
  //                                         : Padding(
  //                                             padding: EdgeInsets.only(
  //                                                 top: i == 0 ? 0 : 8),
  //                                             child: Row(
  //                                               crossAxisAlignment:
  //                                                   CrossAxisAlignment.start,
  //                                               children: [
  //                                                 SizedBox(
  //                                                   width: Get.width * 0.42,
  //                                                   child: Column(
  //                                                     crossAxisAlignment:
  //                                                         CrossAxisAlignment
  //                                                             .start,
  //                                                     children: [
  //                                                       Text(
  //                                                         '${orderDetailsFood.foodDetails.name ?? ''} (${orderDetailsFood.quantity ?? ''})',
  //                                                         style: poppinsMedium
  //                                                             .copyWith(
  //                                                                 fontSize:
  //                                                                     Dimensions
  //                                                                         .FONT_SIZE_SMALL),
  //                                                         maxLines: 2,
  //                                                         overflow: TextOverflow
  //                                                             .ellipsis,
  //                                                       ),
  //                                                       addons == ''
  //                                                           ? SizedBox.shrink()
  //                                                           : Text.rich(
  //                                                               TextSpan(
  //                                                                 children: [
  //                                                                   TextSpan(
  //                                                                     text:
  //                                                                         'Add-Ons :',
  //                                                                     style: poppinsMedium.copyWith(
  //                                                                         fontSize:
  //                                                                             11,
  //                                                                         color:
  //                                                                             ColorTheme.kdsLeftMenuBlue),
  //                                                                   ),
  //                                                                   TextSpan(
  //                                                                     text:
  //                                                                         ' $addons',
  //                                                                     style: poppinsMedium
  //                                                                         .copyWith(
  //                                                                       overflow:
  //                                                                           TextOverflow.ellipsis,
  //                                                                       fontSize:
  //                                                                           10,
  //                                                                       color: ColorTheme
  //                                                                           .green,
  //                                                                     ),
  //                                                                   ),
  //                                                                 ],
  //                                                               ),
  //                                                             ),
  //                                                       variationText == ''
  //                                                           ? SizedBox.shrink()
  //                                                           : Text.rich(
  //                                                               TextSpan(
  //                                                                 children: [
  //                                                                   TextSpan(
  //                                                                     text:
  //                                                                         'Variants  :',
  //                                                                     style: poppinsMedium.copyWith(
  //                                                                         fontSize:
  //                                                                             11,
  //                                                                         color:
  //                                                                             ColorTheme.kdsLeftMenuBlue),
  //                                                                   ),
  //                                                                   TextSpan(
  //                                                                     text:
  //                                                                         ' $variationText',
  //                                                                     style: poppinsMedium.copyWith(
  //                                                                         fontSize:
  //                                                                             10,
  //                                                                         color:
  //                                                                             ColorTheme.green),
  //                                                                   ),
  //                                                                 ],
  //                                                               ),
  //                                                             ),
  //                                                     ],
  //                                                   ),
  //                                                 ),
  //                                                 Spacer(),
  //                                                 Text(
  //                                                     '${(orderDetailsFood.price + variationTotal + addonsTotal) ?? ''}',
  //                                                     style: poppinsMedium.copyWith(
  //                                                         color: Color.fromRGBO(
  //                                                             128, 76, 25, 1.0),
  //                                                         fontSize: Dimensions
  //                                                             .FONT_SIZE_DEFAULT)),
  //                                               ],
  //                                             ),
  //                                           );
  //                                   }),
  //                             ),

  //                             SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

  //                             // Padding(
  //                             //   padding: EdgeInsets.only(
  //                             //       left: Get.width * 0.4,
  //                             //       right:
  //                             //           Dimensions.PADDING_SIZE_LARGE),
  //                             //   child: Divider(color: Colors.grey),
  //                             // ),
  //                             Padding(
  //                               padding: EdgeInsets.symmetric(
  //                                   horizontal: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('Sub Total'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                         fontSize:
  //                                             Dimensions.FONT_SIZE_SMALL)),
  //                               ),
  //                               Text(
  //                                   ' :   ' +
  //                                       PriceConverter
  //                                           .convertPrice(
  //                                               (kdsController
  //                                                       .paidOrderDetailResponse
  //                                                       .orders
  //                                                       .orderTotalAmount +
  //                                                   kdsController
  //                                                       .paidOrderDetailResponse
  //                                                       .orders
  //                                                       .orderTotalAddonAmt +
  //                                                   kdsController
  //                                                       .paidOrderDetailResponse
  //                                                       .orders
  //                                                       .orderTotalVariantAmt),
  //                                               isHideCurrency: true,
  //                                               asFixed: 2),
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),
  //                             // Padding(
  //                             //   padding: EdgeInsets.only(
  //                             //       left: Get.width * 0.4,
  //                             //       right:
  //                             //           Dimensions.PADDING_SIZE_LARGE),
  //                             //   child: Divider(color: Colors.grey),
  //                             // ),
  //                             // Row(children: [
  //                             //   SizedBox(
  //                             //     width: Get.width * 0.65,
  //                             //     child: Text('Community Discount'.tr,
  //                             //         textAlign: TextAlign.right,
  //                             //         style: poppinsMedium.copyWith(
  //                             //             fontSize: Dimensions
  //                             //                 .FONT_SIZE_SMALL)),
  //                             //   ),
  //                             //   Text(
  //                             //       ' :   ' +
  //                             //           PriceConverter.convertPrice(
  //                             //               coummunityDiscount,
  //                             //               isHideCurrency: true,
  //                             //               asFixed: 2),
  //                             //       style: poppinsMedium.copyWith(
  //                             //           fontSize: Dimensions
  //                             //               .FONT_SIZE_SMALL)),
  //                             // ]),
  //                             // SizedBox(height: 10),
  //                             Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: Get.width * 0.4,
  //                                   right: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('Discount'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                         fontSize:
  //                                             Dimensions.FONT_SIZE_SMALL)),
  //                               ),
  //                               Text(
  //                                   ' :   ' +
  //                                       PriceConverter.convertPrice(
  //                                           Get.find<KdsController>()
  //                                               .paidOrderDetailResponse
  //                                               .orders
  //                                               .orderDetailsOrder
  //                                               .restaurantDiscountAmount,
  //                                           isHideCurrency: true,
  //                                           asFixed: 2),
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),
  //                             Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: Get.width * 0.4,
  //                                   right: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('Service Charge'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                         fontSize:
  //                                             Dimensions.FONT_SIZE_SMALL)),
  //                               ),
  //                               Text(
  //                                   ' :   ' +
  //                                       PriceConverter.convertPrice(
  //                                           double.parse(
  //                                               Get.find<KdsController>()
  //                                                   .paidOrderDetailResponse
  //                                                   .orders
  //                                                   .serviceTax),
  //                                           isHideCurrency: true,
  //                                           asFixed: 2),
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),

  //                             Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: Get.width * 0.4,
  //                                   right: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('CGST'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL,
  //                                     )),
  //                               ),
  //                               Text(
  //                                   ' :   ${double.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.gstTax) / 2}',
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),
  //                             SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('SGST'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL,
  //                                     )),
  //                               ),
  //                               Text(
  //                                   ' :   ${double.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.gstTax) / 2}',
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),
  //                             SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('VAT'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL,
  //                                     )),
  //                               ),
  //                               Text(
  //                                   ' :   ${Get.find<KdsController>().paidOrderDetailResponse.orders.vatTax}',
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_SMALL)),
  //                             ]),
  //                             Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: Get.width * 0.4,
  //                                   right: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             Row(children: [
  //                               SizedBox(
  //                                 width: Get.width * 0.65,
  //                                 child: Text('Total'.tr,
  //                                     textAlign: TextAlign.right,
  //                                     style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_LARGE,
  //                                     )),
  //                               ),
  //                               Text(
  //                                   ' :  ' +
  //                                       PriceConverter.convertPrice(
  //                                           (kdsController
  //                                               .paidOrderDetailResponse
  //                                               .orders
  //                                               .orderDetailsOrder
  //                                               .orderAmount),
  //                                           isHideCurrency: true,
  //                                           asFixed: 2),
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_LARGE)),
  //                             ]),
  //                             Padding(
  //                               padding: EdgeInsets.only(
  //                                   left: Get.width * 0.4,
  //                                   right: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),
  //                             if (grandTotal != 0)
  //                               Row(children: [
  //                                 SizedBox(
  //                                   width: Get.width * 0.65,
  //                                   child: Text('Grand Total'.tr,
  //                                       textAlign: TextAlign.right,
  //                                       style: poppinsMedium.copyWith(
  //                                         fontSize: Dimensions.FONT_SIZE_LARGE,
  //                                       )),
  //                                 ),
  //                                 Text(
  //                                     ' :  ' +
  //                                         PriceConverter.convertPrice(
  //                                             (kdsController
  //                                                     .paidOrderDetailResponse
  //                                                     .orders
  //                                                     .orderDetailsOrder
  //                                                     .orderAmount +
  //                                                 grandTotal),
  //                                             isHideCurrency: true,
  //                                             asFixed: 2),
  //                                     style: poppinsMedium.copyWith(
  //                                         fontSize:
  //                                             Dimensions.FONT_SIZE_LARGE)),
  //                               ]),
  //                             if (grandTotal != 0)
  //                               Padding(
  //                                 padding: EdgeInsets.only(
  //                                     left: Get.width * 0.4,
  //                                     right: Dimensions.PADDING_SIZE_LARGE),
  //                                 child: Divider(color: Colors.grey),
  //                               ),
  //                             Padding(
  //                               padding: EdgeInsets.symmetric(
  //                                   horizontal: Dimensions.PADDING_SIZE_LARGE),
  //                               child: Divider(color: Colors.grey),
  //                             ),

  //                             InkWell(
  //                               onTap: () {
  //                                 if (isPrint) {
  //                                   isPrint = false;
  //                                   kdsController.update();
  //                                   kdsBytesConvert();
  //                                   Future.delayed(Duration(seconds: 8), () {
  //                                     isPrint = true;
  //                                     kdsController.update();
  //                                   });
  //                                 }
  //                               },
  //                               child: Container(
  //                                 padding: EdgeInsets.symmetric(
  //                                     horizontal:
  //                                         Dimensions.PADDING_SIZE_DEFAULT,
  //                                     vertical: Dimensions.PADDING_SIZE_SMALL),
  //                                 decoration: BoxDecoration(
  //                                     border: Border.all(
  //                                         color: ColorTheme.appColor),
  //                                     color: isPrint
  //                                         ? ColorTheme.appColor
  //                                         : Colors.white,
  //                                     borderRadius: BorderRadius.circular(
  //                                         Dimensions.RADIUS_DEFAULT)),
  //                                 child: Text(
  //                                   'Print Bill',
  //                                   style: poppinsMedium.copyWith(
  //                                       fontSize: Dimensions.FONT_SIZE_LARGE,
  //                                       color: isPrint
  //                                           ? Colors.white
  //                                           : ColorTheme.appColor),
  //                                 ),
  //                               ),
  //                             ),
  //                           ]);
  //               }),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget previousBill() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 5, left: 15),
            child: Text(
              'Previous Bills',
              style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 17 : 15,
                  color: ColorTheme.appColor),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15, bottom: 20, right: 15, top: 10),
          child: ListView.builder(
              itemCount:
                  Get.find<KdsController>().getRoomPaidOrderList?.length ?? 0,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int i) {
                GetRoomPaidOrderDetailResponse customerData =
                    Get.find<KdsController>().getRoomPaidOrderList[i];
                return Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${i + 1}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${customerData.restaurantOrderId}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${convertRoundOff(double.parse(customerData.orderAmount))}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          customerData.createdAt == ''
                              ? ''
                              : '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt))}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Get.toNamed(RouteHelper.getTabBillDetail(
                                '${customerData.orderId}', '', ''));
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: 13),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                color: ColorTheme.appColor,
                                // border:
                                //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_DEFAULT)),
                            child: Center(
                              child: Text(
                                'Detail',
                                style: poppinsRegular.copyWith(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MediaQuery.of(context).size.shortestSide > 570
            ? AppBar(
                toolbarHeight: Get.height / 10.72,
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: ColorTheme.appColor,
                    onPressed: () {
                      Get.back();
                    }),
                titleSpacing: 0,
                elevation: 0,
                centerTitle: true,
                title: Column(
                  children: [
                    Image.asset(
                      logoHelper.appLogo!,
                      height: Get.height / 10.72,
                    ),
                  ],
                ))
            : AppBar(
                // toolbarHeight: Get.height / 10.72,
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.chevron_left),
                    iconSize: 40,
                    color: ColorTheme.green,
                    onPressed: () {
                      Get.back();
                    }),
                titleSpacing: 0,
                elevation: 0,
                centerTitle: false,

                title: Column(
                  children: [
                    // SizedBox(height: 15),
                    Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
                  ],
                ),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Center(
              child: GetBuilder<KdsController>(builder: (kdsController) {
                return kdsController.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : kdsController.paidOrderDetailResponse == null
                        ? SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser !=
                                      null &&
                                  kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser!.fName !=
                                      '')
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    'Name: ${kdsController.paidOrderDetailResponse?.orders?.orderUser?.fName ?? ''}',
                                    style:
                                        poppinsSemiBold.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (kdsController.paidOrderDetailResponse?.orders
                                          ?.orderUser !=
                                      null &&
                                  (kdsController.paidOrderDetailResponse?.orders
                                              ?.orderUser?.phone ??
                                          '') !=
                                      '')
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 15),
                                  child: Text(
                                    'Phone: ${kdsController.paidOrderDetailResponse!.orders?.orderUser?.phone ?? ''}',
                                    style:
                                        poppinsSemiBold.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (kdsController.paidOrderDetailResponse?.orders
                                      ?.orderUser !=
                                  null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Divider(
                                      height: 1, color: Color(0xFFE6E6E6)),
                                ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFF9F9F9)),
                                child: Column(children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 20),
                                  //   child: Align(
                                  //     alignment: Alignment.centerLeft,
                                  //     child: Text(
                                  //       'Order Id: ${kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId == '0' ? kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.id : kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId}',
                                  //       style: poppinsSemiBold.copyWith(
                                  //           fontSize: MediaQuery.of(context)
                                  //                       .size
                                  //                       .shortestSide >
                                  //                   570
                                  //               ? 17
                                  //               : 15,
                                  //           color: ColorTheme.appColor),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(height: 10),
                                  if (Get.find<KdsController>()
                                      .getRoomPaidOrderList
                                      .isNotEmpty)
                                    previousBill(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 20, left: 15),
                                      child: Text(
                                        'Order Id: ${kdsController.paidOrderDetailResponse!.orders!.orderDetailsOrder!.restaurantOrderId}',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 17
                                                : 15,
                                            color: ColorTheme.appColor),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ListView.builder(
                                        itemCount: kdsController
                                                .paidOrderDetailResponse
                                                ?.orders
                                                ?.orderDetailsFood
                                                ?.length ??
                                            0,
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          OrderDetailsFood orderDetailsFood =
                                              kdsController
                                                  .paidOrderDetailResponse!
                                                  .orders!
                                                  .orderDetailsFood![i];
                                          String variationText = '';
                                          int variationTotal = 0;
                                          double addonsTotal = 0;
                                          if (orderDetailsFood.variation !=
                                                  null &&
                                              orderDetailsFood
                                                  .variation!.isNotEmpty) {
                                            for (int j = 0;
                                                j <
                                                    orderDetailsFood
                                                        .variation!.length;
                                                j++) {
                                              variationText +=
                                                  '${variationText.isNotEmpty ? ', ' : ''}${orderDetailsFood.variation![j].name} (';

                                              if (orderDetailsFood
                                                      .variation![j].values !=
                                                  null) {
                                                List<String> labelList = [];
                                                for (var element
                                                    in orderDetailsFood
                                                        .variation![j]
                                                        .values!) {
                                                  labelList.add(element.label!);
                                                  variationTotal += (int.parse(
                                                          element
                                                              .optionPrice!) *
                                                      orderDetailsFood
                                                          .quantity!);
                                                }
                                                variationText +=
                                                    '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                              }

                                              variationText += ')';
                                            }
                                          }

                                          String addons = '';
                                          for (var i = 0;
                                              i <
                                                  orderDetailsFood
                                                      .addOns!.length;
                                              i++) {
                                            addonsTotal = addonsTotal +
                                                (orderDetailsFood
                                                        .addOns![i].price! *
                                                    orderDetailsFood
                                                        .addOns![i].quantity!);
                                            addons +=
                                                '${orderDetailsFood.addOns![i].name} (${orderDetailsFood.addOns![i].quantity})';
                                          }

                                          if (roomCheckInPrice == 0 &&
                                              ((orderDetailsFood
                                                          .foodDetails?.name
                                                          ?.toLowerCase() ??
                                                      '') ==
                                                  'check in')) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              roomCheckInPrice =
                                                  orderDetailsFood.unitPrice ??
                                                      0;
                                              kdsController.update();
                                            });
                                          }
                                          return orderDetailsFood.foodStatus ==
                                                  3
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                      top: i == 0 ? 0 : 8),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              ((orderDetailsFood
                                                                              .foodDetails
                                                                              ?.name
                                                                              ?.toLowerCase() ??
                                                                          '') ==
                                                                      'check in')
                                                                  ? 'Room Check-In'
                                                                  : '${orderDetailsFood.foodDetails?.name ?? ''} (${orderDetailsFood.quantity ?? ''})',
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize:
                                                                      MediaQuery.of(context).size.shortestSide >
                                                                              570
                                                                          ? 16
                                                                          : 10),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            addons == ''
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Add-Ons :',
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                                                                              color: ColorTheme.blue),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' $addons',
                                                                          style:
                                                                              poppinsMedium.copyWith(
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            fontSize: MediaQuery.of(context).size.shortestSide > 570
                                                                                ? 14
                                                                                : 10,
                                                                            color:
                                                                                ColorTheme.green,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                            variationText == ''
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Variants  :',
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                                                                              color: ColorTheme.blue),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' $variationText',
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                                                                              color: ColorTheme.green),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                          ((orderDetailsFood
                                                                          .foodDetails
                                                                          ?.name
                                                                          ?.toLowerCase() ??
                                                                      '') ==
                                                                  'check in')
                                                              ? '${orderDetailsFood.unitPrice}'
                                                              : '${(orderDetailsFood.price + variationTotal + addonsTotal) ?? ''}',
                                                          style: poppinsSemiBold.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .shortestSide >
                                                                      570
                                                                  ? 14
                                                                  : 10)),
                                                    ],
                                                  ),
                                                );
                                        }),
                                  ),

                                  SizedBox(height: 15),
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    lineThickness: 1.0,
                                    dashLength: 2.5,
                                    dashColor: ColorTheme.hintText,
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Sub Total'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 10)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      ((kdsController
                                                                  .paidOrderDetailResponse
                                                                  ?.orders
                                                                  ?.orderTotalAmount ??
                                                              0) +
                                                          roomCheckInPrice),
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 10)),
                                        ]),
                                  ),

                                  if (kdsController
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .restaurantDiscountAmount !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Discount'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .restaurantDiscountAmount!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (kdsController
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .tipAmount !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Add tips'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .tipAmount!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),

                                  if (double.parse(kdsController
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .serviceTax!) !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt ?? 'Service Charge'} ',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        double.parse(kdsController
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .serviceTax!),
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),

                                  if (Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .deliveryCharge !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Delivery Charge'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .deliveryCharge!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),

                                  if (double.parse(Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .gstTax!) !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('CGST'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${(double.parse(Get.find<KdsController>().paidOrderDetailResponse!.orders!.gstTax!) / 2).toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (double.parse(Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .gstTax!) !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('SGST'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${(double.parse(Get.find<KdsController>().paidOrderDetailResponse!.orders!.gstTax!) / 2).toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  // Row(children: [
                                  //   SizedBox(
                                  //     width: MediaQuery.of(context)
                                  //                 .size
                                  //                 .shortestSide >
                                  //             570
                                  //         ? Get.width * 0.75
                                  //         : Get.width * 0.65,
                                  //     child: Text('SGST'.tr,
                                  //         textAlign: TextAlign.right,
                                  //         style: poppinsMedium.copyWith(
                                  //           fontSize: MediaQuery.of(context)
                                  //                       .size
                                  //                       .shortestSide >
                                  //                   570
                                  //               ? 15
                                  //               : Dimensions
                                  //                   .FONT_SIZE_SMALL,
                                  //         )),
                                  //   ),
                                  //   Text(
                                  //       ' :   ${double.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.gstTax) / 2}',
                                  //       style: poppinsMedium.copyWith(
                                  //           fontSize: MediaQuery.of(context)
                                  //                       .size
                                  //                       .shortestSide >
                                  //                   570
                                  //               ? 15
                                  //               : Dimensions
                                  //                   .FONT_SIZE_SMALL)),
                                  // ]),

                                  if (Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .vatTax !=
                                          '0' &&
                                      Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .vatTax! !=
                                          '0.00')
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('VAT'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${double.parse(kdsController.paidOrderDetailResponse!.orders!.vatTax!).toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, right: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Total'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsBold.copyWith(
                                                color: ColorTheme.green,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 17
                                                    : 14,
                                              )),
                                          Text(
                                              ' :  ${convertRoundOff(
                                                kdsController
                                                        .paidOrderDetailResponse!
                                                        .orders!
                                                        .orderDetailsOrder!
                                                        .orderAmount! +
                                                    roomCheckInPrice,
                                              )}',
                                              style: poppinsBold.copyWith(
                                                  color: ColorTheme.green,
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 17
                                                      : 14)),
                                        ]),
                                  ),
                                  if (roomOrders != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Grand Total',
                                                textAlign: TextAlign.right,
                                                style: poppinsBold.copyWith(
                                                  color: ColorTheme.green,
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 17
                                                      : 14,
                                                )),
                                            Text(
                                                ' :   ${convertRoundOff(kdsController.paidOrderDetailResponse!.orders!.orderDetailsOrder!.orderAmount! + roomCheckInPrice + roomOrders)}',
                                                style: poppinsBold.copyWith(
                                                    color: ColorTheme.green,
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 17
                                                        : 14)),
                                          ]),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('printer'))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30, bottom: 10),
                                      child: InkWell(
                                          onTap: () async {
                                            double subTotal = 0;

                                            Orders order =
                                                Get.find<KdsController>()
                                                    .paidOrderDetailResponse!
                                                    .orders!;
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
                                              for (var orderDetailsFood in Get
                                                          .find<KdsController>()
                                                      .paidOrderDetailResponse
                                                      ?.orders
                                                      ?.orderDetailsFood ??
                                                  []) {
                                                double variationTotal = 0;
                                                double halfVariationPrice = 0;
                                                double addonsTotal = 0;
                                                if (orderDetailsFood
                                                            .variation !=
                                                        null &&
                                                    (orderDetailsFood.variation
                                                            ?.isNotEmpty ??
                                                        false)) {
                                                  for (int j = 0;
                                                      j <
                                                          (orderDetailsFood
                                                                  .variation
                                                                  ?.length ??
                                                              0);
                                                      j++) {
                                                    if (orderDetailsFood
                                                            .variation?[j]
                                                            .values !=
                                                        null) {
                                                      List<String> labelList =
                                                          [];
                                                      for (var element
                                                          in orderDetailsFood
                                                                  .variation?[j]
                                                                  .values ??
                                                              []) {
                                                        labelList.add(
                                                            element.label ??
                                                                '');
                                                        // variationTotal += (int.parse(
                                                        //         element.optionPrice) *
                                                        //     orderDetailsFood
                                                        //         .quantity);
                                                        if ((orderDetailsFood
                                                                    .variation?[
                                                                        j]
                                                                    .name
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
                                                            halfVariationPrice =
                                                                (double.tryParse(element.optionPrice ??
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
                                                                  (orderDetailsFood
                                                                          .quantity ??
                                                                      0));
                                                        }
                                                      }
                                                    }

                                                    variationTotal =
                                                        variationTotal +
                                                            halfVariationPrice;
                                                  }
                                                }

                                                for (var i = 0;
                                                    i <
                                                        orderDetailsFood
                                                            .addOns!.length;
                                                    i++) {
                                                  addonsTotal = addonsTotal +
                                                      (orderDetailsFood
                                                              .addOns![i]
                                                              .price! *
                                                          orderDetailsFood
                                                              .addOns![i]
                                                              .quantity!);
                                                }

                                                subTotal = subTotal +
                                                    orderDetailsFood.price +
                                                    variationTotal +
                                                    addonsTotal;
                                                Get.find<KdsController>()
                                                    .update();
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
                                              final printers =
                                                  await Printing.listPrinters();
                                              for (var element in printers) {
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
                                                      onLayout: (_) => WindowsPrintByteConvert()
                                                          .byteConvert(
                                                              paymentType: order!
                                                                      .orderDetailsOrder
                                                                      ?.paymentMethod ??
                                                                  '',
                                                              printType:
                                                                  'paid_bill',
                                                              paperRoll:
                                                                  Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
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
                                                                  ? order.orderDetailsOrder?.orderType ==
                                                                          'delivery'
                                                                      ? 'Delivery'
                                                                      : order.orderDetailsOrder?.orderType ==
                                                                              'take_away'
                                                                          ? 'Take Away'
                                                                          : 'WC'
                                                                  : order.restaurantDetails!.restaurantTableArea ==
                                                                          ''
                                                                      ? '${order.restaurantDetails!.restaurantTableNo}'
                                                                      : '${order.restaurantDetails!.restaurantTableArea}:${order.restaurantDetails!.restaurantTableNo}',
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
                                                              orderType: order.orderDetailsOrder?.orderType),
                                                    );
                                                    await Future.delayed(
                                                        Duration(seconds: 2));
                                                  }
                                                  break;
                                                }
                                              }

                                              await Get.find<
                                                      LoadingController>()
                                                  .changeText(
                                                      data:
                                                          'Successfully printed!!');
                                            } else {
                                              if (isPrint) {
                                                // isPrint = false;
                                                showToast('Please wait..');

                                                Get.find<LoadingController>()
                                                    .startLoading(true);
                                                // kdsController.update();
                                                // kdsBytesConvert();
                                                Orders order = Get.find<
                                                        KdsController>()
                                                    .paidOrderDetailResponse!
                                                    .orders!;
                                                if (Platform.isIOS) {
                                                  await _iosPrintEscPos(await PrintByteConvert()
                                                      .byteConvert(
                                                          printType:
                                                              'paid_bill',
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
                                                          orderId: order
                                                                  ?.orderDetailsOrder
                                                                  ?.restaurantOrderId ??
                                                              '',
                                                          date:
                                                              '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                                          waiterName:
                                                              '${order?.restaurantDetails?.restaurantWaiterName ?? ''}',
                                                          tablename: (order
                                                                          ?.restaurantDetails
                                                                          ?.restaurantTableNo ??
                                                                      '') ==
                                                                  ''
                                                              ? (order?.orderDetailsOrder
                                                                          ?.orderType ==
                                                                      'delivery'
                                                                  ? 'Delivery'
                                                                  : order?.orderDetailsOrder?.orderType == 'take_away'
                                                                      ? 'Take Away'
                                                                      : 'WC')
                                                              : (order?.restaurantDetails?.restaurantTableArea ?? '') == ''
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
                                                          printType:
                                                              'paid_bill',
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
                                                          orderId: order
                                                                  ?.orderDetailsOrder
                                                                  ?.restaurantOrderId ??
                                                              '',
                                                          date:
                                                              '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order?.orderDetailsOrder?.createdAt ?? DateTime.now().toString()))}',
                                                          waiterName:
                                                              '${order?.restaurantDetails?.restaurantWaiterName ?? ''}',
                                                          tablename: (order
                                                                          ?.restaurantDetails
                                                                          ?.restaurantTableNo ??
                                                                      '') ==
                                                                  ''
                                                              ? (order?.orderDetailsOrder
                                                                          ?.orderType ==
                                                                      'delivery'
                                                                  ? 'Delivery'
                                                                  : order?.orderDetailsOrder?.orderType == 'take_away'
                                                                      ? 'Take Away'
                                                                      : 'WC')
                                                              : (order?.restaurantDetails?.restaurantTableArea ?? '') == ''
                                                                  ? '${order?.restaurantDetails?.restaurantTableNo ?? ''}'
                                                                  : '${order?.restaurantDetails?.restaurantTableArea ?? ''}:${order?.restaurantDetails?.restaurantTableNo ?? ''}',
                                                          custName: order?.orderDetailsOrder?.username ?? '',
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
                                                          orderType: order.orderDetailsOrder?.orderType ?? ''));
                                                }
                                                // Future.delayed(Duration(seconds: 8),
                                                //     () {
                                                //   isPrint = true;
                                                //   kdsController.update();
                                                // });
                                              }
                                            }
                                          },
                                          child: SvgPicture.asset(
                                            Images.ic_print_kot,
                                            height: 26,
                                          )),
                                    ),
                                ]),
                              ),
                            ],
                          );
              }),
            ),
          ),
        ),
      ),
    );
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
  //         text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
  //     PosColumn(
  //       text: '',
  //       width: 1,
  //       styles: PosStyles(align: PosAlign.center),
  //     ),
  //     PosColumn(
  //         text:
  //             '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantWaiterName}',
  //         // text:
  //         //     '${Get.find<AuthController>().profileModel.empFname} ${Get.find<AuthController>().profileModel.empLname}',
  //         width: 6,
  //         styles: PrinterConfig().waiterNameStyle()),
  //   ]);

  //   bytes += generator.row([
  //     PosColumn(
  //       text: '${widget.name ?? ''}',
  //       width: 5,
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
  //         // fontType: PosFontType.fontB,
  //       ),
  //     ),
  //     PosColumn(
  //       text: '',
  //       width: 2,
  //       styles: PosStyles(align: PosAlign.center, underline: true),
  //     ),
  //     PosColumn(
  //       text: '${widget.phone ?? ''}',
  //       width: 5,
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
  //         align: PosAlign.right,
  //         fontType: PosFontType.fontB,
  //       ),
  //     ),
  //   ]);

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
  //         styles: PosStyles(align: PosAlign.center),
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
  //           text: '${food.foodDetails.name} $variationText',
  //           width: 5,
  //           styles: PrinterConfig().foodStyle()),
  //       PosColumn(
  //           text: '${food.quantity}',
  //           width: isShowDate ? 1 : 2,
  //           styles: PrinterConfig().foodStyle()),
  //       PosColumn(
  //           text: '${(food.price + variationTotal).toStringAsFixed(2)}',
  //           // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
  //           width: 3,
  //           styles: PrinterConfig().foodStyle()),
  //       if (isShowDate)
  //         PosColumn(
  //             text:
  //                 '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
  //             width: 2,
  //             styles: PrinterConfig().foodStyle()),
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
  //             text: 'Add-Ons :$addons',
  //             width: 5,
  //             styles: PrinterConfig().foodStyle()),
  //         PosColumn(
  //           text: '',
  //           width: isShowDate ? 1 : 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //         PosColumn(
  //           text: '${addonsTotal.toStringAsFixed(2)}',
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
  //       styles: PosStyles(align: PosAlign.center),
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
  //           text: 'Add Discount ',
  //           width: 5,
  //           styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderDetailsOrder
  //                   .restaurantDiscountAmount,
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
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
  //           text: 'Add tips',
  //           width: 5,
  //           styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               double.parse(Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderDetailsOrder
  //                   .tipAmount
  //                   .toString()),
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
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
  //           text: 'Service Charge',
  //           width: 5,
  //           styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               double.parse(Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderDetailsOrder
  //                   .totalServiceTaxAmount),
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
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
  //           text: 'CGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               double.parse(Get.find<KdsController>()
  //                       .paidOrderDetailResponse
  //                       .orders
  //                       .orderDetailsOrder
  //                       .totalGstTaxAmount) /
  //                   2,
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
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
  //           text: 'SGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               double.parse(Get.find<KdsController>()
  //                       .paidOrderDetailResponse
  //                       .orders
  //                       .orderDetailsOrder
  //                       .totalGstTaxAmount) /
  //                   2,
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
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
  //           text: 'VAT ', width: 5, styles: PrinterConfig().subtotalStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: PriceConverter.convertPrice(
  //               double.parse(Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderDetailsOrder
  //                   .totalVatTaxAmount),
  //               isHideCurrency: true,
  //               asFixed: 2),
  //           width: 3,
  //           styles: PrinterConfig().subtotalStyle()),
  //     ]);
  //   }

  //   bytes += generator.hr(ch: '....');
  //   bytes += generator.text(
  //       'Total: ' +
  //           PriceConverter.convertPrice(
  //               Get.find<KdsController>()
  //                   .paidOrderDetailResponse
  //                   .orders
  //                   .orderDetailsOrder
  //                   .orderAmount,
  //               isHideCurrency: true,
  //               asFixed: 2) +
  //           ' ${Get.find<AuthController>().profileModel?.restaurants?.first?.currency ?? ''}',
  //       styles: PrinterConfig().totalStyle());
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
  //     await _kdsPrintEscPos(bytes, generator); //kitchen
  //   } else {
  //     await _iosPrintEscPos(bytes, generator); //kitchen
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

  // Future _iosPrintEscPos(List<int> bytes) async {
  //   print('########## bytes length ${bytes.length}');
  //   // bytes += generator.feed(2);

  //   if (Get.find<AuthController>().profileModel!.macBillPrinterIp == '') {
  //     showErrorToast('Failed to bluetooth connect');
  //     Get.find<KdsController>().setProcessing(false);

  //     //no conectado, reconecte
  //   } else {
  //     await PrintBluetoothThermal.pairedBluetooths;

  //     // Future.delayed(Duration(seconds: 5), () async {
  //     final bool result = await PrintBluetoothThermal.connect(
  //         macPrinterAddress:
  //             Get.find<AuthController>().profileModel!.macBillPrinterIp!);

  //     Future.delayed(Duration(seconds: 1), () async {
  //       if (result) {
  //         // List<int> ticket = await testTicket();
  //         await PrintBluetoothThermal.writeBytes(bytes);

  //         Future.delayed(
  //             Duration(
  //                 seconds: bytes.length <= 5850
  //                     ? 2
  //                     : bytes.length <= 7890
  //                         ? 3
  //                         : bytes.length <= 10195
  //                             ? 6
  //                             : bytes.length <= 13100
  //                                 ? 10
  //                                 : bytes.length <= 21150
  //                                     ? 15
  //                                     : 20), () async {
  //           Get.find<LoadingController>().startLoading(false);

  //           await Get.find<LoadingController>()
  //               .changeText(data: 'Successfully printed!!');
  //           await Get.find<LoadingController>().changeStatus(data: true);
  //           var isDisconnect = await PrintBluetoothThermal.disconnect;
  //           print('is disconnect $isDisconnect');
  //         });
  //         print("print test result:  $result");
  //       } else {
  //         //no conectado, reconecte
  //         Get.find<LoadingController>().startLoading(false);

  //         await Get.find<LoadingController>()
  //             .changeText(data: 'Failed to bluetooth connect!!', error: true);
  //         await Get.find<LoadingController>().changeStatus(data: true);
  //         // showErrorToast('Failed to bluetooth connect');
  //       }
  //       // });
  //     });
  //     // });
  //   }
  // }
}
