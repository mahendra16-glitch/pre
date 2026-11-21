// import 'dart:async';
// import 'dart:io';
// import 'package:mygenie_restaurant/helper/logo_helper.dart';
// import 'package:mygenie_restaurant/helper/printer_config.dart';
// import 'package:mygenie_restaurant/util/app_constants.dart';
// import 'package:image/image.dart' as prefix;
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
// import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:intl/intl.dart';

// class RoomBillDetailPage extends StatefulWidget {
//   final String orderId;
//   final String name;
//   final String phone;

//   const RoomBillDetailPage({Key key, this.orderId, this.name, this.phone})
//       : super(key: key);

//   @override
//   State<RoomBillDetailPage> createState() => _RoomBillDetailPageState();
// }

// class _RoomBillDetailPageState extends State<RoomBillDetailPage> {
//   bool isPrint = true;

//   PrinterManager printerManager = PrinterManager.instance;
//   StreamSubscription<BTStatus> _subscriptionBtStatus;
//   List<int> pendingTask;
//   BTStatus currentStatus = BTStatus.none;
//   @override
//   void initState() {
//     super.initState();
//     initData();
//     _subscriptionBtStatus =
//         PrinterManager.instance.stateBluetooth.listen((status) {
//       currentStatus = status;
//       if (status == BTStatus.connected && pendingTask != null) {
//         if (Platform.isAndroid) {
//           Future.delayed(const Duration(milliseconds: 1000), () async {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask);
//             Future.delayed(Duration(seconds: 10), () async {
//               await PrinterManager.instance
//                   .disconnect(type: PrinterType.bluetooth);
//             });
//             pendingTask = null;
//           });
//         } else if (Platform.isIOS) {
//           PrinterManager.instance
//               .send(type: PrinterType.bluetooth, bytes: pendingTask);
//           pendingTask = null;
//         }
//       }
//     });
//   }

//   initData() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Get.find<KdsController>().getPaidOrderDetail('${widget.orderId}');
//     });
//   }

//   @override
//   void dispose() {
//     _subscriptionBtStatus?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           leading: IconButton(
//               icon: Image.asset(Images.ic_arrow_back, height: 20),
//               color: ColorTheme.appColor,
//               onPressed: () {
//                 Get.back();
//               }),
//           titleSpacing: 0,
//           elevation: 0,
//           centerTitle: true,
//           title: Column(
//             children: [
//               Image.asset(logoHelper.appLogo, width: Get.width * 0.5),
//             ],
//           ),
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: Scrollbar(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
//                     physics: BouncingScrollPhysics(),
//                     child: Center(
//                       child: SizedBox(
//                         child:
//                             GetBuilder<KdsController>(builder: (kdsController) {
//                           return kdsController.isLoading
//                               ? Center(
//                                   child: CircularProgressIndicator(),
//                                 )
//                               : kdsController.paidOrderDetailResponse == null
//                                   ? SizedBox.shrink()
//                                   : Column(children: [
//                                       // SizedBox(
//                                       //     height: Dimensions.PADDING_SIZE_SMALL),
//                                       // Text(
//                                       //   'Collect Payment',
//                                       //   style: poppinsMedium.copyWith(
//                                       //       fontSize:
//                                       //           Dimensions.FONT_SIZE_OVER_LARGE),
//                                       // ),
//                                       SizedBox(height: Get.height * 0.04),
//                                       Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: Padding(
//                                           padding: EdgeInsets.only(
//                                               left: Get.width * 0.15),
//                                           child: Text(
//                                             'Name: ${widget.name}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: 14),
//                                           ),
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: Padding(
//                                           padding: EdgeInsets.only(
//                                               top: 10, left: Get.width * 0.15),
//                                           child: Text(
//                                             'Phone: ${widget.phone}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: 14),
//                                           ),
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: Padding(
//                                           padding: EdgeInsets.only(
//                                               top: 30, left: Get.width * 0.15),
//                                           child: Text(
//                                             'Order Id: ${kdsController?.paidOrderDetailResponse?.orders?.orderDetailsOrder?.id ?? ''}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: 15,
//                                                 color: ColorTheme.appColor),
//                                           ),
//                                         ),
//                                       ),

//                                       SizedBox(height: 10),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.15,
//                                             right: Get.width * 0.15),
//                                         child: ListView.builder(
//                                             itemCount: kdsController
//                                                     ?.paidOrderDetailResponse
//                                                     ?.orders
//                                                     ?.orderDetailsFood
//                                                     ?.length ??
//                                                 0,
//                                             shrinkWrap: true,
//                                             physics: BouncingScrollPhysics(),
//                                             itemBuilder:
//                                                 (BuildContext context, int i) {
//                                               OrderDetailsFood
//                                                   orderDetailsFood =
//                                                   kdsController
//                                                       ?.paidOrderDetailResponse
//                                                       ?.orders
//                                                       ?.orderDetailsFood[i];
//                                               String variationText = '';
//                                               int variationTotal = 0;
//                                               int addonsTotal = 0;
//                                               if (orderDetailsFood.variation !=
//                                                       null &&
//                                                   orderDetailsFood
//                                                       .variation.isNotEmpty) {
//                                                 for (int j = 0;
//                                                     j <
//                                                         orderDetailsFood
//                                                             .variation.length;
//                                                     j++) {
//                                                   variationText +=
//                                                       '${variationText.isNotEmpty ? ', ' : ''}${orderDetailsFood.variation[j].name} (';

//                                                   if (orderDetailsFood
//                                                           .variation[j]
//                                                           .values !=
//                                                       null) {
//                                                     List<String> labelList = [];
//                                                     for (var element
//                                                         in orderDetailsFood
//                                                             .variation[j]
//                                                             .values) {
//                                                       labelList
//                                                           .add(element.label);
//                                                       variationTotal +=
//                                                           (int.parse(element
//                                                                   .optionPrice) *
//                                                               orderDetailsFood
//                                                                   .quantity);
//                                                     }
//                                                     variationText +=
//                                                         '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//                                                   }

//                                                   variationText += ')';
//                                                 }
//                                               }

//                                               String addons = '';
//                                               for (var i = 0;
//                                                   i <
//                                                       orderDetailsFood
//                                                           .addOns.length;
//                                                   i++) {
//                                                 addonsTotal = addonsTotal +
//                                                     (orderDetailsFood
//                                                             .addOns[i].price *
//                                                         orderDetailsFood
//                                                             .addOns[i]
//                                                             .quantity);
//                                                 addons +=
//                                                     '${orderDetailsFood.addOns[i].name} (${orderDetailsFood.addOns[i].quantity})';
//                                               }
//                                               return orderDetailsFood
//                                                           .foodStatus ==
//                                                       3
//                                                   ? SizedBox.shrink()
//                                                   : Padding(
//                                                       padding: EdgeInsets.only(
//                                                           top: i == 0 ? 0 : 8),
//                                                       child: Row(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           SizedBox(
//                                                             width: Get.width *
//                                                                 0.42,
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Text(
//                                                                   '${orderDetailsFood.foodDetails.name ?? ''} (${orderDetailsFood.quantity ?? ''})',
//                                                                   style: poppinsMedium
//                                                                       .copyWith(
//                                                                           fontSize:
//                                                                               Dimensions.FONT_SIZE_SMALL),
//                                                                   maxLines: 2,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                                 addons == ''
//                                                                     ? SizedBox
//                                                                         .shrink()
//                                                                     : Text.rich(
//                                                                         TextSpan(
//                                                                           children: [
//                                                                             TextSpan(
//                                                                               text: 'Add-Ons :',
//                                                                               style: poppinsMedium.copyWith(fontSize: 11, color: ColorTheme.kdsLeftMenuBlue),
//                                                                             ),
//                                                                             TextSpan(
//                                                                               text: ' $addons',
//                                                                               style: poppinsMedium.copyWith(
//                                                                                 overflow: TextOverflow.ellipsis,
//                                                                                 fontSize: 10,
//                                                                                 color: ColorTheme.green,
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                 variationText ==
//                                                                         ''
//                                                                     ? SizedBox
//                                                                         .shrink()
//                                                                     : Text.rich(
//                                                                         TextSpan(
//                                                                           children: [
//                                                                             TextSpan(
//                                                                               text: 'Variants  :',
//                                                                               style: poppinsMedium.copyWith(fontSize: 11, color: ColorTheme.kdsLeftMenuBlue),
//                                                                             ),
//                                                                             TextSpan(
//                                                                               text: ' $variationText',
//                                                                               style: poppinsMedium.copyWith(fontSize: 10, color: ColorTheme.green),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           Spacer(),
//                                                           Text(
//                                                               '${(orderDetailsFood.price + variationTotal + addonsTotal) ?? ''}',
//                                                               style: poppinsMedium.copyWith(
//                                                                   color: Color
//                                                                       .fromRGBO(
//                                                                           128,
//                                                                           76,
//                                                                           25,
//                                                                           1.0),
//                                                                   fontSize:
//                                                                       Dimensions
//                                                                           .FONT_SIZE_DEFAULT)),
//                                                         ],
//                                                       ),
//                                                     );
//                                             }),
//                                       ),

//                                       SizedBox(
//                                           height:
//                                               Dimensions.PADDING_SIZE_SMALL),

//                                       // Padding(
//                                       //   padding: EdgeInsets.only(
//                                       //       left: Get.width * 0.4,
//                                       //       right:
//                                       //           Dimensions.PADDING_SIZE_LARGE),
//                                       //   child: Divider(color: Colors.grey),
//                                       // ),
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('Sub Total'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                   fontSize: Dimensions
//                                                       .FONT_SIZE_SMALL)),
//                                         ),
//                                         Text(
//                                             ' :   ' +
//                                                 PriceConverter.convertPrice(
//                                                     (kdsController
//                                                             .paidOrderDetailResponse
//                                                             .orders
//                                                             .orderTotalAmount +
//                                                         kdsController
//                                                             .paidOrderDetailResponse
//                                                             .orders
//                                                             .orderTotalAddonAmt +
//                                                         kdsController
//                                                             .paidOrderDetailResponse
//                                                             .orders
//                                                             .orderTotalVariantAmt),
//                                                     isHideCurrency: true,
//                                                     asFixed: 2),
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),
//                                       // Padding(
//                                       //   padding: EdgeInsets.only(
//                                       //       left: Get.width * 0.4,
//                                       //       right:
//                                       //           Dimensions.PADDING_SIZE_LARGE),
//                                       //   child: Divider(color: Colors.grey),
//                                       // ),
//                                       // Row(children: [
//                                       //   SizedBox(
//                                       //     width: Get.width * 0.65,
//                                       //     child: Text('Community Discount'.tr,
//                                       //         textAlign: TextAlign.right,
//                                       //         style: poppinsMedium.copyWith(
//                                       //             fontSize: Dimensions
//                                       //                 .FONT_SIZE_SMALL)),
//                                       //   ),
//                                       //   Text(
//                                       //       ' :   ' +
//                                       //           PriceConverter.convertPrice(
//                                       //               coummunityDiscount,
//                                       //               isHideCurrency: true,
//                                       //               asFixed: 2),
//                                       //       style: poppinsMedium.copyWith(
//                                       //           fontSize: Dimensions
//                                       //               .FONT_SIZE_SMALL)),
//                                       // ]),
//                                       // SizedBox(height: 10),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.4,
//                                             right:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('Discount'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                   fontSize: Dimensions
//                                                       .FONT_SIZE_SMALL)),
//                                         ),
//                                         Text(
//                                             ' :   ' +
//                                                 PriceConverter.convertPrice(
//                                                     Get.find<KdsController>()
//                                                         .paidOrderDetailResponse
//                                                         .orders
//                                                         .orderDetailsOrder
//                                                         .restaurantDiscountAmount,
//                                                     isHideCurrency: true,
//                                                     asFixed: 2),
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.4,
//                                             right:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('Service Charge'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                   fontSize: Dimensions
//                                                       .FONT_SIZE_SMALL)),
//                                         ),
//                                         Text(
//                                             ' :   ' +
//                                                 PriceConverter.convertPrice(
//                                                     double.parse(Get.find<
//                                                             KdsController>()
//                                                         .paidOrderDetailResponse
//                                                         .orders
//                                                         .serviceTax),
//                                                     isHideCurrency: true,
//                                                     asFixed: 2),
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),

//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.4,
//                                             right:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('CGST'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                 fontSize:
//                                                     Dimensions.FONT_SIZE_SMALL,
//                                               )),
//                                         ),
//                                         Text(
//                                             ' :   ${double.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.gstTax) / 2}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),
//                                       SizedBox(
//                                           height:
//                                               Dimensions.PADDING_SIZE_SMALL),

//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('SGST'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                 fontSize:
//                                                     Dimensions.FONT_SIZE_SMALL,
//                                               )),
//                                         ),
//                                         Text(
//                                             ' :   ${double.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.gstTax) / 2}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),
//                                       SizedBox(
//                                           height:
//                                               Dimensions.PADDING_SIZE_SMALL),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('VAT'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                 fontSize:
//                                                     Dimensions.FONT_SIZE_SMALL,
//                                               )),
//                                         ),
//                                         Text(
//                                             ' :   ${Get.find<KdsController>().paidOrderDetailResponse.orders.vatTax}',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_SMALL)),
//                                       ]),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.4,
//                                             right:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Row(children: [
//                                         SizedBox(
//                                           width: Get.width * 0.65,
//                                           child: Text('Total'.tr,
//                                               textAlign: TextAlign.right,
//                                               style: poppinsMedium.copyWith(
//                                                 fontSize:
//                                                     Dimensions.FONT_SIZE_LARGE,
//                                               )),
//                                         ),
//                                         Text(
//                                             ' :  ' +
//                                                 PriceConverter.convertPrice(
//                                                     (kdsController
//                                                         .paidOrderDetailResponse
//                                                         .orders
//                                                         .orderDetailsOrder
//                                                         .orderAmount),
//                                                     isHideCurrency: true,
//                                                     asFixed: 2),
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_LARGE)),
//                                       ]),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             left: Get.width * 0.4,
//                                             right:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal:
//                                                 Dimensions.PADDING_SIZE_LARGE),
//                                         child: Divider(color: Colors.grey),
//                                       ),

//                                       InkWell(
//                                         onTap: () {
//                                           if (isPrint) {
//                                             isPrint = false;
//                                             kdsController.update();
//                                             kdsBytesConvert();
//                                             Future.delayed(Duration(seconds: 8),
//                                                 () {
//                                               isPrint = true;
//                                               kdsController.update();
//                                             });
//                                           }
//                                         },
//                                         child: Container(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: Dimensions
//                                                   .PADDING_SIZE_DEFAULT,
//                                               vertical: Dimensions
//                                                   .PADDING_SIZE_SMALL),
//                                           decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color: ColorTheme.appColor),
//                                               color: isPrint
//                                                   ? ColorTheme.appColor
//                                                   : Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       Dimensions
//                                                           .RADIUS_DEFAULT)),
//                                           child: Text(
//                                             'Print Bill',
//                                             style: poppinsMedium.copyWith(
//                                                 fontSize:
//                                                     Dimensions.FONT_SIZE_LARGE,
//                                                 color: isPrint
//                                                     ? Colors.white
//                                                     : ColorTheme.appColor),
//                                           ),
//                                         ),
//                                       ),
//                                     ]);
//                         }),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future kdsBytesConvert() async {
//     List<OrderDetailsFood> foodOrderList = [];

//     foodOrderList.addAll(Get.find<KdsController>()
//         .paidOrderDetailResponse
//         .orders
//         .orderDetailsFood);

//     final profile = await CapabilityProfile.load(name: 'XP-N160I');
//     final generator = Generator(
//         Get.find<AuthController>().profileModel.billPrinterPaperRoll == 58
//             ? PaperSize.mm58
//             : PaperSize.mm80,
//         profile);
//     pendingTask = [];
//     List<int> bytes = [];
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel.restaurants[0].name,
//         styles: PrinterConfig().titleStyle());
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel.restaurants[0].address,
//         styles: PrinterConfig().addressStyle());

//     if (Get.find<AuthController>().profileModel.restaurants[0].gstCode != '')
//       bytes += generator.text(
//           'GST no. ${Get.find<AuthController>().profileModel.restaurants[0].gstCode}',
//           styles: PrinterConfig().gstStyle());
//     if (Get.find<AuthController>().profileModel.restaurants[0].fssai != '')
//       bytes += generator.text(
//           'FSI no. ${Get.find<AuthController>().profileModel.restaurants[0].fssai}',
//           styles: PrinterConfig().gstStyle());
//     bool isShowDate = Get.find<AuthController>()
//                 .profileModel
//                 .restaurants
//                 .first
//                 .showFoodDate ==
//             'Yes'
//         ? true
//         : false;
//     bytes += generator.row([
//       PosColumn(
//           text: 'order_id'.tr +
//               ':' +
//               ' ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId == '0' ? Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id : Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId}',
//           width: 6,
//           styles: PrinterConfig().orderIdStyle()),
//       PosColumn(
//           text:
//               '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.createdAt))}',
//           // DateConverter.dateTimeStringToMonthAndTime(
//           //     DateTime.now().toString()),
//           width: 6,
//           styles: PrinterConfig().orderCreateDateStyle()),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//           text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
//       PosColumn(
//         text: '',
//         width: 1,
//         styles: PosStyles(align: PosAlign.center),
//       ),
//       PosColumn(
//           text:
//               '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantWaiterName}',
//           // text:
//           //     '${Get.find<AuthController>().profileModel.empFname} ${Get.find<AuthController>().profileModel.empLname}',
//           width: 6,
//           styles: PrinterConfig().waiterNameStyle()),
//     ]);

//     bytes += generator.row([
//       PosColumn(
//         text: '${widget.name ?? ''}',
//         width: 5,
//         styles: PosStyles(
//           height: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')
//                   .first),
//           width: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')[1]),
//           bold: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? false
//               : Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')
//                           .last ==
//                       'true'
//                   ? true
//                   : false,
//           align: PosAlign.left,
//           // fontType: PosFontType.fontB,
//         ),
//       ),
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text: '${widget.phone ?? ''}',
//         width: 5,
//         styles: PosStyles(
//           height: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')
//                   .first),
//           width: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')[1]),
//           bold: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? false
//               : Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')
//                           .last ==
//                       'true'
//                   ? true
//                   : false,
//           align: PosAlign.right,
//           fontType: PosFontType.fontB,
//         ),
//       ),
//     ]);

//     bytes += generator.hr(ch: '--');

//     bytes += generator.row([
//       PosColumn(
//           text: 'SL',
//           width: isShowDate ? 1 : 2,
//           styles: PrinterConfig().foodStyle()),
//       PosColumn(
//         text: 'item_info'.tr,
//         width: isShowDate ? 4 : 5,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'qty'.tr,
//         width: isShowDate ? 3 : 2,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'Price',
//         width: isShowDate ? 2 : 3,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       if (isShowDate)
//         PosColumn(
//           text: 'Date',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//     ]);
//     bytes += generator.hr(ch: '--');
//     for (var i = 0; i < foodOrderList.length; i++) {
//       OrderDetailsFood food = foodOrderList[i];
//       String variationText = '';
//       String addons = '';

//       int variationTotal = 0;
//       int addonsTotal = 0;

//       if (food.variation != null && food.variation.isNotEmpty) {
//         for (int j = 0; j < food.variation.length; j++) {
//           variationText +=
//               '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

//           if (food.variation[j].values != null) {
//             List<String> labelList = [];
//             for (var element in food.variation[j].values) {
//               labelList.add(element.label);
//               variationTotal +=
//                   (int.parse(element.optionPrice) * food.quantity);
//             }
//             variationText +=
//                 '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//           }

//           variationText += ')';
//         }
//       }

//       for (var i = 0; i < food.addOns.length; i++) {
//         addons += '${food.addOns[i].name} (${food.addOns[i].quantity})';
//         addonsTotal =
//             addonsTotal + (food.addOns[i].price * food.addOns[i].quantity);
//       }

//       bytes += generator.row([
//         PosColumn(
//             text: '${i + 1}.',
//             width: isShowDate ? 1 : 2,
//             styles: PrinterConfig().foodStyle()),
//         PosColumn(
//             text: '${food.foodDetails.name}',
//             width: 5,
//             styles: PrinterConfig().foodStyle()),
//         PosColumn(
//             text: '${food.quantity}',
//             width: isShowDate ? 1 : 2,
//             styles: PrinterConfig().foodStyle()),
//         PosColumn(
//             text: '${(food.price) + (variationTotal) + (addonsTotal)}',
//             width: 3,
//             styles: PrinterConfig().foodStyle()),
//         if (isShowDate)
//           PosColumn(
//               text:
//                   '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
//               width: 2,
//               styles: PrinterConfig().foodStyle()),
//       ]);
//       if (addons != '') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//               text: 'Add-Ons :$addons',
//               width: 5,
//               styles: PrinterConfig().foodStyle()),
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           PosColumn(
//             text: '',
//             width: 3,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           if (isShowDate)
//             PosColumn(
//               text: '',
//               width: 2,
//               styles: PosStyles(align: PosAlign.center),
//             ),
//         ]);
//       }
//       if (variationText != '') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Variants  :$variationText',
//             width: 5,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           PosColumn(
//             text: '',
//             width: 3,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           if (isShowDate)
//             PosColumn(
//               text: '',
//               width: 2,
//               styles: PosStyles(align: PosAlign.center),
//             ),
//         ]);
//       }

//       bytes += generator.hr(ch: '....');
//     }

//     bytes += generator.hr(ch: '....');

//     bytes += generator.row([
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         ),
//       ),
//       PosColumn(
//         text: 'Sub Total ',
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
//                 .orderTotalAmount,
//             isHideCurrency: true,
//             asFixed: 2),
//         width: 3,
//         styles: PrinterConfig().subtotalStyle(),
//       ),
//     ]);
//     if (Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .restaurantDiscountAmount !=
//         0)
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'Add Discount ',
//             width: 5,
//             styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(
//                 Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderDetailsOrder
//                     .restaurantDiscountAmount,
//                 isHideCurrency: true,
//                 asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalServiceTaxAmount) !=
//         0)
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'Service Charge',
//             width: 5,
//             styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(
//                 double.parse(Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderDetailsOrder
//                     .totalServiceTaxAmount),
//                 isHideCurrency: true,
//                 asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalGstTaxAmount) !=
//         0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'GST ', width: 5, styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(
//                 double.parse(Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderDetailsOrder
//                     .totalGstTaxAmount),
//                 isHideCurrency: true,
//                 asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     }
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalVatTaxAmount) !=
//         0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'VAT ', width: 5, styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(
//                 double.parse(Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderDetailsOrder
//                     .totalVatTaxAmount),
//                 isHideCurrency: true,
//                 asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     }

//     bytes += generator.hr(ch: '....');
//     bytes += generator.text(
//         'Total: ' +
//             PriceConverter.convertPrice(
//                 Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderDetailsOrder
//                     .orderAmount,
//                 isHideCurrency: true,
//                 asFixed: 2) +
//             ' ${Get.find<AuthController>().profileModel?.restaurants?.first?.currency ?? ''}',
//         styles: PrinterConfig().totalStyle());
//     bytes += generator.hr(ch: '....');

//     if (Get.find<AuthController>().profileModel.restaurants.first.feedback ==
//         'Yes') {
//       try {
//         const double qrSize = 170;
//         final uiImg = await QrPainter(
//           data:
//               '${AppConstants.FEEDBACK_BASE_URL}?orderId=${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id}',
//           version: QrVersions.auto,
//           gapless: false,
//         ).toImageData(qrSize);
//         final dir = await getTemporaryDirectory();
//         final pathName = '${dir.path}/qr_tmp.png';
//         final qrFile = File(pathName);
//         final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
//         final img = prefix.decodeImage(imgFile.readAsBytesSync());
//         bytes += generator.text('Scan to provide feedback',
//             styles: const PosStyles(
//                 align: PosAlign.center,
//                 height: PosTextSize.size1,
//                 width: PosTextSize.size1,
//                 bold: true,
//                 fontType: PosFontType.fontA));

//         bytes += generator.feed(1);
//         bytes += generator.image(img);
//         bytes += generator.feed(1);
//       } catch (e) {
//         print(e);
//       }
//     }
//     bytes += generator.text('Powered by MyGenie',
//         styles: const PosStyles(
//             align: PosAlign.center,
//             height: PosTextSize.size1,
//             width: PosTextSize.size1,
//             // bold: true,
//             fontType: PosFontType.fontB));

//     await _kdsPrintEscPos(bytes, generator); //kitchen
//   }

//   /// print ticket
//   Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
//     // await printerManager.disconnect(type: PrinterType.bluetooth);
//     BluetoothPrinter bluetoothPrinter = await BluetoothPrinter(
//         // address: 'DC:0D:30:20:3C:D5');
//         address: Get.find<AuthController>().profileModel.billPrinterIp,
//         deviceName: Get.find<AuthController>()
//             .profileModel
//             .billPrinterName); // ip was mandadory
//     await printerManager.connect(
//       type: bluetoothPrinter.typePrinter,
//       model: BluetoothPrinterInput(
//         name: bluetoothPrinter.deviceName,
//         address: bluetoothPrinter.address,
//       ),
//     );
//     switch (bluetoothPrinter.typePrinter) {
//       case PrinterType.usb:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: UsbPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             productId: bluetoothPrinter.productId,
//             vendorId: bluetoothPrinter.vendorId,
//           ),
//         );
//         break;
//       case PrinterType.bluetooth:
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: BluetoothPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             address: bluetoothPrinter.address,
//             isBle: bluetoothPrinter.isBle ?? false,
//           ),
//         );
//         pendingTask = null;
//         if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
//         break;
//       case PrinterType.network:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: TcpPrinterInput(ipAddress: bluetoothPrinter.address),
//         );
//         break;
//       default:
//     }
//     if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//       try {
//         await printerManager.send(
//             type: bluetoothPrinter.typePrinter, bytes: bytes);
//         pendingTask = null;
//         Future.delayed(Duration(seconds: 15), () async {
//           await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//         });
//       } catch (e) {}
//     } else {
//       printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//     }
//   }
// }
