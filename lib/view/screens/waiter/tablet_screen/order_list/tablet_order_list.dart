// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/cart_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/controller/loader_contoller.dart';
// import 'package:mygenie_restaurant/controller/pos_controller.dart';
// import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
// import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart'
//     as profile;
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart'
//     as profile_model;
// import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart'
//     as bill_model;
// import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';
// import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
// import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
// import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
// import 'package:mygenie_restaurant/data/model/response/table_response_model.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/helper/printer_config.dart';
// import 'package:mygenie_restaurant/helper/route_helper.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
// import 'package:mygenie_restaurant/view/base/custom_button.dart';
// import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
// import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
// import 'package:mygenie_restaurant/view/base/theme_color_button.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/order_list/tablet_order_food_item.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/order_list/tablet_split_food_item.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/walkIn/widget/walk_in_add_product.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get/get.dart';
// import 'package:map_launcher/map_launcher.dart';

// import '../../../../../controller/delivery_man_controller.dart';
// import '../../../../../data/model/response/get_delivery_man_list_response.dart';
// import '../../home/widget/cancel_order_dialog.dart';

// class TabletWaiterOrderList extends StatelessWidget {
//   final OrderList? order;
//   final FlutterTts? flutterTit;
//   final bool isWaiter;
//   TextEditingController? searchTable;
//   TextEditingController? searchOrder;

//   int? splitCurrentPrintIndex;
//   PrinterManager? printerManager;
//   List<bool>? isSplitSelectPrinterList;
//   List<bool>? isSplitPrinterProccessingList;
//   List<bool>? isSplitPrintedList;
//   StreamSubscription<BTStatus>? subscriptionBtStatus;
//   Function? printSplitBill;

//   TabletWaiterOrderList(
//     this.subscriptionBtStatus, {
//     Key? key,
//     this.order,
//     this.flutterTit,
//     this.isWaiter = false,
//     this.searchTable,
//     required this.searchOrder,
//     this.splitCurrentPrintIndex,
//     this.printerManager,
//     this.isSplitSelectPrinterList,
//     this.isSplitPrinterProccessingList,
//     this.isSplitPrintedList,
//     this.printSplitBill,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     int cookingFoodItemLenght = 0;
//     double roomOrderAmount = 0;
//     if ((Get.find<AuthController>()
//                     .profileModel!
//                     .restaurants!
//                     .first
//                     .showOrderStatus ==
//                 2
//             ? order!.fOrderStatus! <= 2
//             : order!.fOrderStatus! < 2) ||
//         order!.orderType == 'delivery' ||
//         order!.orderType == 'take_away' ||
//         (order!.restaurantTable != null &&
//             order!.restaurantTable!.rtype == 'RM')) {
//       double orderSubTotal = 0;
//       double discountedOrderSubTotal = 0;
//       double gstAmount = 0;
//       double vatAmount = 0;
//       double gstTypeFood = 0;
//       double vatTypeFood = 0;

//       double serviceChargePercentage = Get.find<AuthController>()
//           .profileModel!
//           .restaurants!
//           .first
//           .serviceChargePercentage!;
//       for (var element in order!.orderDetails!) {
//         DateTime foodTime = DateTime.parse(element.updatedAt!);
//         var diffTime = DateTime.now().difference(foodTime);
//         if ((Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .showOrderStatus ==
//                     2 ||
//                 order!.orderType == 'delivery' ||
//                 order!.orderType == 'take_away')
//             ? ((element.foodStatus! <= 2 ||
//                     order!.orderType == 'delivery' ||
//                     order!.orderType == 'take_away') &&
//                 diffTime.inMinutes <=
//                     Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .cancelOrderTime!)
//             : element.foodStatus! < 2) {
//           cookingFoodItemLenght = cookingFoodItemLenght + 1;
//         }

//         // if (order.restaurantTable != null &&
//         //     order.restaurantTable.rtype == 'RM' &&
//         //     element.foodStatus != 3) {
//         //   // for (var i = 0; i < order.orderDetails.length; i++) {
//         //   OrderDetails food = element;

//         //   double variationTotal = 0;
//         //   double addonsTotal = 0;
//         //   double foodAmount = 0;
//         //   if (food.variation != null && food.variation.isNotEmpty) {
//         //     for (int j = 0; j < food.variation.length; j++) {
//         //       if (food.variation[j].values != null) {
//         //         for (var element in food.variation[j].values) {
//         //           variationTotal = variationTotal +
//         //               (double.parse(element.optionPrice) * food.quantity);
//         //         }
//         //       }
//         //     }
//         //   }

//         //   for (var i = 0; i < food.addOns.length; i++) {
//         //     addonsTotal = addonsTotal +
//         //         ((food.addOns[i].price * food.addOns[i].qty) * food.quantity);
//         //   }
//         //   orderSubTotal = orderSubTotal +
//         //       food.unitPrice * food.quantity +
//         //       variationTotal +
//         //       addonsTotal;
//         //   foodAmount =
//         //       food.unitPrice * food.quantity + variationTotal + addonsTotal;
//         //   discountedOrderSubTotal = discountedOrderSubTotal + foodAmount;

//         //   if (Get.find<AuthController>()
//         //               .profileModel
//         //               .restaurants
//         //               .first
//         //               .gstStatus ==
//         //           'true' &&
//         //       food.foodDetails.taxType.toString() == 'GST') {
//         //     if (Get.find<AuthController>()
//         //                 .profileModel
//         //                 .restaurants
//         //                 .first
//         //                 .discountType ==
//         //             'Percent' ||
//         //         Get.find<AuthController>()
//         //                 .profileModel
//         //                 .restaurants
//         //                 .first
//         //                 .discountType ==
//         //             'No')
//         //       gstAmount = gstAmount +
//         //           ((foodAmount *
//         //                   double.parse(food.foodDetails.tax.toString())) /
//         //               100);
//         //     gstTypeFood = gstTypeFood + foodAmount;
//         //   } else if (Get.find<AuthController>()
//         //           .profileModel
//         //           .restaurants
//         //           .first
//         //           .gstStatus !=
//         //       'true') {
//         //     gstTypeFood = gstTypeFood + foodAmount;
//         //   }
//         //   if (Get.find<AuthController>().profileModel.vatInfo.status ==
//         //           'true' &&
//         //       food.foodDetails.taxType.toString() == 'VAT') {
//         //     if (Get.find<AuthController>()
//         //                 .profileModel
//         //                 .restaurants
//         //                 .first
//         //                 .discountType ==
//         //             'Percent' ||
//         //         Get.find<AuthController>()
//         //                 .profileModel
//         //                 .restaurants
//         //                 .first
//         //                 .discountType ==
//         //             'No')
//         //       vatAmount = vatAmount +
//         //           ((foodAmount *
//         //                   double.parse(food.foodDetails.tax.toString())) /
//         //               100);
//         //     vatTypeFood = vatTypeFood + foodAmount;
//         //   } else if (Get.find<AuthController>().profileModel.vatInfo.status !=
//         //       'true') {
//         //     vatTypeFood = vatTypeFood + foodAmount;
//         //   }
//         //   // }
//         //   if (Get.find<AuthController>()
//         //           .profileModel
//         //           .restaurants
//         //           .first
//         //           .discountType ==
//         //       'Fixed') {
//         //     if (Get.find<AuthController>()
//         //             .profileModel
//         //             .restaurants
//         //             .first
//         //             .gstStatus ==
//         //         'true') {
//         //       vatAmount = ((vatTypeFood *
//         //               Get.find<AuthController>()
//         //                   .profileModel
//         //                   .restaurants
//         //                   .first
//         //                   .gstTax) /
//         //           100);
//         //       gstAmount = ((gstTypeFood *
//         //               Get.find<AuthController>()
//         //                   .profileModel
//         //                   .restaurants
//         //                   .first
//         //                   .gstTax) /
//         //           100);
//         //     }
//         //   }
//         //   ////final
//         //   if (Get.find<AuthController>()
//         //               .profileModel
//         //               .restaurants
//         //               .first
//         //               .serviceCharge ==
//         //           'Yes' &&
//         //       Get.find<AuthController>()
//         //               .profileModel
//         //               .restaurants
//         //               .first
//         //               .autoServiceCharge ==
//         //           'Yes') {
//         //     roomOrderAmount = discountedOrderSubTotal +
//         //         (discountedOrderSubTotal * serviceChargePercentage / 100) +
//         //         gstAmount +
//         //         vatAmount;
//         //   } else {
//         //     roomOrderAmount = discountedOrderSubTotal + gstAmount + vatAmount;
//         //   }
//         // }
//       }
//     }

//     if (order!.restaurantTable != null &&
//         order!.restaurantTable!.rtype == 'RM') {
//       if (order!.roomAssociateOrder != null) {
//         for (var room in order!.roomAssociateOrder!) {
//           roomOrderAmount = roomOrderAmount + room.amount!;
//         }
//       }
//       roomOrderAmount = roomOrderAmount +
//           double.parse(order!.orderAmount!) +
//           (order!.roomInfo?.remainingPay ?? 0);
//     }

//     return Container(
//       // margin: EdgeInsets.only(left: 10),
//       height: Get.find<AuthController>()
//                   .profileModel!
//                   .restaurants!
//                   .first
//                   .listServeItem ==
//               'Fixed'
//           ? MediaQuery.of(context).orientation == Orientation.landscape
//               ? Get.height * 0.55
//               : Get.height * 0.4
//           : null,
//       // width: MediaQuery.of(context).size.width >= 1500
//       //     ? Get.width * 0.22
//       //     : MediaQuery.of(context).orientation == Orientation.landscape
//       //         ? Get.width * 0.31
//       //         : Get.width * 0.45,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
//           color: order!.orderType == 'delivery'
//               ? Color.fromRGBO(253, 237, 237, 1)
//               : order!.orderType == 'take_away'
//                   ? Color.fromRGBO(220, 244, 192, 1)
//                   : order!.restaurantTable != null &&
//                           order!.restaurantTable!.rtype == 'RM'
//                       ? ColorTheme.roomCardBgColor
//                       : Color.fromRGBO(254, 245, 208, 1)),
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 17),
//             child: Row(
//               // crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   // flex: 1,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         order!.restaurantTable == null ||
//                                 order!.restaurantTable!.tableNo == ''
//                             ? order!.orderType == 'delivery'
//                                 ? 'Delivery'
//                                 : order?.orderType == 'take_away'
//                                     ? 'Take Away'
//                                     : order?.userName != 'Mygenie' &&
//                                             order?.userName != ''
//                                         ? order!.userName
//                                         : 'WC'
//                             : order!.restaurantTable!.title == ''
//                                 ? '#${order!.restaurantTable!.tableNo}'
//                                 : '#${order!.restaurantTable!.title}-${order!.restaurantTable!.tableNo}',
//                         style: poppinsSemiBold.copyWith(
//                             fontSize: 15, color: Colors.black),
//                         maxLines: 2,
//                       ),
//                       if (Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('Manager'))
//                         Text(
//                           order!.orderType == 'delivery' &&
//                                   Get.find<AuthController>()
//                                           .profileModel!
//                                           .restaurants!
//                                           .first
//                                           .isDeliveryAssign ==
//                                       'Yes' &&
//                                   order!.deliveryMan != ''
//                               ? '${order!.deliveryMan ?? ''}'
//                               : '${order!.vendorEmployee?.waiterName ?? ''}',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 11, color: Colors.black),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   // flex: 2,
//                   child: Row(
//                     children: [
//                       if (order!.paymentType == 'prepaid')
//                         Padding(
//                           padding: const EdgeInsets.only(right: 5),
//                           child: Icon(
//                             Icons.account_balance_wallet,
//                             color: ColorTheme.appColor,
//                             size: 20,
//                           ),
//                         ),
//                       Flexible(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${order!.restaurantOrderId}',
//                               style: poppinsBold.copyWith(
//                                   fontSize: Dimensions.FONT_SIZE_DEFAULT,
//                                   color: Colors.black),
//                             ),
//                             if (order!.userName != 'Mygenie' &&
//                                 order!.userName != '')
//                               Text(
//                                 '${order!.userName ?? ''}',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 11, color: Colors.black),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 if (order!.orderType != 'delivery' &&
//                     order!.orderType != 'take_away' &&
//                     ((order!.restaurantTable != null &&
//                             order!.restaurantTable!.tableNo != '' &&
//                             order!.restaurantTable!.rtype != 'RM') ||
//                         order!.tableId == 0))
//                   Padding(
//                     padding: const EdgeInsets.only(left: 5),
//                     child: InkWell(
//                       onTap: () {
//                         if (order!.orderType != 'delivery' &&
//                             order!.orderType != 'take_away' &&
//                             ((order!.restaurantTable != null &&
//                                     order!.restaurantTable!.tableNo != '' &&
//                                     order!.restaurantTable!.rtype != 'RM') ||
//                                 order!.tableId == 0))
//                           Get.bottomSheet(mergeTable(context, order!),
//                               backgroundColor: Colors.transparent,
//                               isScrollControlled: true,
//                               ignoreSafeArea: false);
//                       },
//                       child: SvgPicture.asset(
//                         Images.ic_show_table,
//                       ),
//                     ),
//                   ),
//                 SizedBox(width: 15),
//                 if (Get.find<KdsController>().splitOrderList.isEmpty)
//                   order!.orderType != 'delivery' &&
//                           order!.orderType != 'take_away'
//                       ? order!.fOrderStatus == 7
//                           ? SizedBox.shrink()
//                           : Column(
//                               children: [
//                                 InkWell(
//                                     onTap: () async {
//                                       searchOrder?.clear();
//                                       FocusManager.instance.primaryFocus
//                                           ?.unfocus();

//                                       Get.find<CartController>()
//                                           .clearTableList();
//                                       searchTable?.clear();

//                                       order!.restaurantTable != null &&
//                                               order!.restaurantTable!.rtype ==
//                                                   'RM'
//                                           ? await Get.find<CartController>()
//                                               .getRoomList(isShowLoader: false)
//                                           : await Get.find<CartController>()
//                                               .getTableList(
//                                                   isShowLoader: false);

//                                       Get.bottomSheet(
//                                           openTableList(context, order!),
//                                           backgroundColor: Colors.transparent,
//                                           isScrollControlled: true,
//                                           ignoreSafeArea: false);
//                                     },
//                                     child: SvgPicture.asset(
//                                       Images.ic_switch_table,
//                                     )),
//                                 if (roomOrderAmount != 0)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 7),
//                                     child: Text(
//                                       'Rs. ${roomOrderAmount.toStringAsFixed(2)}',
//                                       style: poppinsMedium.copyWith(
//                                           fontSize: 11, color: Colors.black),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   )
//                               ],
//                             )
//                       : order!.orderType == 'delivery'
//                           ? Padding(
//                               padding: const EdgeInsets.only(left: 5),
//                               child: InkWell(
//                                   onTap: () async {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();

//                                     showAddressDialog(order!);
//                                   },
//                                   child: Icon(CupertinoIcons.location_solid,
//                                       color: ColorTheme.appColor)),
//                             )
//                           : SizedBox(width: 30),
//                 if (order!.orderType == 'take_away')
//                   Text(
//                     'Rs. ${double.parse(order!.orderAmount!).toStringAsFixed(2)}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: 11, color: Colors.black),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 // Expanded(
//                 //   flex: 1,
//                 //   child: Align(
//                 //     alignment: Alignment.centerRight,
//                 //     child: Text(
//                 //       '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(tempDate)}',
//                 //       style: poppinsMedium.copyWith(
//                 //           fontSize: 9, color: Color.fromRGBO(193, 30, 30, 1)),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           if (order!.orderType != 'take_away' &&
//               ((order!.restaurantTable == null) ||
//                   (order!.restaurantTable != null &&
//                       order!.restaurantTable!.rtype != 'RM')))
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 7, right: 15),
//                 child: Text(
//                   'Rs. ${double.parse(order!.orderAmount!).toStringAsFixed(2)}',
//                   style:
//                       poppinsMedium.copyWith(fontSize: 11, color: Colors.black),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           SizedBox(height: 9),
//           Divider(color: ColorTheme.hintText, height: 1),
//           // MediaQuery.of(context).size.shortestSide > 600
//           //     ? KdsTabletOrderItemList(
//           //         orderItemList: order.orderDetailsFood, order: order)
//           //     :
//           order!.isShowCheckbox || order!.isSplitTable
//               ? TabletWaiterSelectOrdeItem(
//                   orderItemList: order!.orderDetails, order: order)
//               : TabletWaiterOrderFoodItem(
//                   searchOrder: searchOrder!,
//                   flutterTts: flutterTit!,
//                   isWaiter: isWaiter,
//                   orderItemList: order!.orderDetails!,
//                   order: order!,
//                   isPending: order!.orderType == 'delivery'
//                       ? false
//                       : order!.orderType == 'take_away'
//                           ? false
//                           : order!.restaurantTable != null &&
//                                   order!.restaurantTable!.rtype == 'RM'
//                               ? false
//                               : true,
//                 ),
//           SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//           // Align(
//           //   alignment: Alignment.centerLeft,
//           //   child: Text(
//           //     '${order.orderNote ?? ''}',
//           //     style: poppinsMedium.copyWith(fontSize: 10, color: Colors.black),
//           //   ),
//           // ),
//           order!.orderNote == null || order!.orderNote!.trim() == ''
//               ? SizedBox.shrink()
//               : Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Notes  :',
//                           style: poppinsMedium.copyWith(
//                               fontSize: MediaQuery.of(context).size.width > 1600
//                                   ? 17
//                                   : 12,
//                               color: ColorTheme.kdsLeftMenuBlue),
//                         ),
//                         TextSpan(
//                           text: ' ${order!.orderNote}',
//                           style: poppinsMedium.copyWith(
//                               fontSize: MediaQuery.of(context).size.width > 1600
//                                   ? 17
//                                   : 11,
//                               color: ColorTheme.green),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           order!.orderNote == null || order!.orderNote!.trim() == ''
//               ? const SizedBox.shrink()
//               : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           order!.isSplitTable &&
//                   Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('printer')
//               ? GetBuilder<KdsController>(builder: (kdsController) {
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 20),
//                     child: InkWell(
//                         onTap: () async {
//                           searchOrder!.clear();
//                           FocusManager.instance.primaryFocus?.unfocus();
//                           splitCurrentPrintIndex = 0;
//                           // if (!Get.find<KdsController>().isProcessing) {
//                           splitCurrentPrintIndex = Get.find<KdsController>()
//                               .splitOrderList
//                               .indexOf(order!);
//                           isSplitSelectPrinterList!.clear();
//                           isSplitPrintedList!.clear();
//                           isSplitPrinterProccessingList!.clear();
//                           for (var i = 0;
//                               i <
//                                   Get.find<KdsController>()
//                                       .splitOrderList
//                                       .length;
//                               i++) {
//                             isSplitSelectPrinterList!.add(false);

//                             isSplitPrintedList!.add(false);
//                             isSplitPrinterProccessingList!.add(false);
//                             // if (widget.cartProductList[i].isNotEmpty) {
//                             //   printedTotal = printedTotal + 1;
//                             // }
//                           }
//                           isSplitSelectPrinterList![splitCurrentPrintIndex!] =
//                               true;
//                           // kdsController.setProcessing(true);
//                           printSplitBill!('1');
//                           // Future.delayed(Duration(seconds: 8), () {
//                           //   kdsController.setProcessing(false);
//                           // });
//                           // }
//                         },
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: SvgPicture.asset(
//                             Images.ic_print_kot,
//                             height: 26,
//                           ),
//                         )
//                         // Image.asset(
//                         //   Images.printKot,
//                         //   alignment: Alignment.centerLeft,
//                         //   height: 30,
//                         //   color: ColorTheme.appColor,
//                         // ),
//                         ),
//                   );
//                 })
//               : (Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('order')) &&
//                       order!.fOrderStatus == 7
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             searchOrder!.clear();
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             // Get.bottomSheet(
//                             //   ConfirmationDialog(
//                             //       icon: Images.support,
//                             //       description:
//                             //           'Are you sure you want to cancel the complete order?',
//                             //       isLogOut: true,
//                             //       onYesPressed: () async {
//                             //         Map<String, dynamic> jsonBody = {
//                             //           'order_id': order.id.toString(),
//                             //           'order_status': 'cancelled',
//                             //           'role_name': Get.find<AuthController>()
//                             //               .profileModel
//                             //               .role
//                             //               .first,
//                             //         };
//                             //         Get.back();
//                             //         Get.find<KdsController>()
//                             //             .changeOrderStatus(jsonBody, callback);
//                             //       }),
//                             // );
//                             Get.bottomSheet(
//                                 CancelOrderDialog(
//                                   cancelType: 'order',
//                                   orderId: order!.id.toString(),
//                                 ),
//                                 backgroundColor: Colors.transparent,
//                                 isScrollControlled: true,
//                                 ignoreSafeArea: false);
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 17),
//                             child: Icon(Icons.close,
//                                 size: 35, color: ColorTheme.appColor),
//                           ),
//                         ),
//                         Spacer(),
//                         ThemeColorButton(
//                           onTap: () {
//                             searchOrder!.clear();
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         WalkInAddProduct(editOrder: order!)));
//                           },
//                           varticalPadding: 8,
//                           horizontalPadding: order!.fOrderStatus == 2 ? 10 : 12,
//                           title: 'Edit',
//                         ),
//                         SizedBox(width: 5),
//                         ThemeColorButton(
//                           onTap: () async {
//                             searchOrder!.clear();
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             Map<String, dynamic> jsonBody = {
//                               'order_id': order!.id.toString(),
//                               'order_status': Get.find<AuthController>()
//                                           .profileModel!
//                                           .restaurants!
//                                           .first
//                                           .defOrdStatus ==
//                                       0
//                                   ? 'new'
//                                   : Get.find<AuthController>()
//                                               .profileModel!
//                                               .restaurants!
//                                               .first
//                                               .defOrdStatus ==
//                                           1
//                                       ? 'cooking'
//                                       : 'ready',
//                               'role_name': Get.find<AuthController>()
//                                   .profileModel!
//                                   .role!
//                                   .first,
//                             };
//                             await Get.find<KdsController>()
//                                 .acceptOrderStatus(jsonBody,
//                                     (bool isSuccess, String message) async {
//                               if (isSuccess) {
//                                 // showToast(message);
//                               } else {
//                                 // showCustomSnackBar(message);
//                               }
//                             });
//                           },
//                           varticalPadding: 5,
//                           horizontalPadding: 12,
//                           title: 'Confirm',
//                         ),
//                         SizedBox(width: 17),
//                       ],
//                     )
//                   : (Get.find<AuthController>()
//                                   .profileModel!
//                                   .restaurants!
//                                   .first
//                                   .isDeliveryAssign ==
//                               'Yes' &&
//                           order!.orderType == 'delivery' &&
//                           Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('delivery_man') &&
//                           Get.find<AuthController>().profileModel!.empId ==
//                               order!.deliveryManId &&
//                           order!.deliveryMan != '')
//                       ? Padding(
//                           padding: const EdgeInsets.only(right: 15),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               if (order!.deliveryManStatus == 'No')
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 10),
//                                   child: ThemeColorButton(
//                                       onTap: () {
//                                         searchOrder!.clear();
//                                         FocusManager.instance.primaryFocus
//                                             ?.unfocus();
//                                         Map<String, dynamic> jsonData = {
//                                           'order_id': order!.id,
//                                           'delivery_man_id':
//                                               Get.find<AuthController>()
//                                                   .profileModel!
//                                                   .empId,
//                                         };
//                                         Get.find<DeliveryManController>()
//                                             .rejectDeliveryMan(jsonData,
//                                                 (bool isSucces) {
//                                           if (isSucces) {
//                                             // order.deliveryMan = selectedTableName ?? '';
//                                             //   order.tableId = tableIdSelect.id;
//                                             //   order.restaurantTable = RestaurantTable(
//                                             //       id: tableIdSelect.id,
//                                             //       rtype: tableIdSelect.type,
//                                             //       tableNo: tableIdSelect.tableNo,
//                                             //       title: tableIdSelect.title);
//                                             // Get.find<KdsController>().update();
//                                             // if (Get.isBottomSheetOpen ?? false) Get.back();

//                                             // } else {
//                                           }
//                                         });
//                                       },
//                                       varticalPadding: 8,
//                                       horizontalPadding: 12,
//                                       editPadding:
//                                           order!.fOrderStatus == 2 ? 25 : 10,
//                                       title: 'Reject'),
//                                 ),
//                               ThemeColorButton(
//                                   onTap: () {
//                                     searchOrder!.clear();
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     if (order!.deliveryManStatus == 'No') {
//                                       Map<String, dynamic> jsonBody = {
//                                         'order_id': order!.id.toString(),
//                                         'order_status': 'serve',
//                                         'delivery_man_status': 'Yes',
//                                         'role_name': 'Manager',
//                                       };
//                                       Get.find<DeliveryManController>()
//                                           .changeOrderStatus(
//                                               jsonBody, callback);
//                                     } else {
//                                       if (order!.paymentType == 'prepaid') {
//                                         Map<String, dynamic> jsonBodyPrepaid = {
//                                           'order_id': order!.id.toString(),
//                                           'payment_status': 'sucess',
//                                         };
//                                         Get.find<KdsController>()
//                                             .changePrepaidOrderStatus(
//                                                 jsonBodyPrepaid, callback);
//                                       } else {
//                                         Get.toNamed(
//                                           RouteHelper
//                                               .getWaiterCollectPaymentRoute(
//                                                   order!.id.toString()),
//                                         );
//                                       }
//                                     }
//                                   },
//                                   varticalPadding: 8,
//                                   horizontalPadding: 12,
//                                   editPadding:
//                                       order!.fOrderStatus == 2 ? 25 : 10,
//                                   title: order!.deliveryManStatus == 'No'
//                                       ? 'Accept'
//                                       : 'Deliver'),
//                               // SizedBox(width: 15),
//                             ],
//                           ),
//                         )
//                       : Row(
//                           children: [
//                             (Get.find<AuthController>()
//                                     .profileModel!
//                                     .role!
//                                     .contains('order'))
//                                 ? Row(
//                                     children: [
//                                       Get.find<KdsController>()
//                                                       .selectedSubMenu ==
//                                                   2 &&
//                                               Get.find<KdsController>()
//                                                   .splitOrderList
//                                                   .isNotEmpty &&
//                                               Get.find<KdsController>()
//                                                       .splitOrderList
//                                                       .first
//                                                       .id ==
//                                                   order!.id
//                                           ? Get.find<KdsController>()
//                                                   .splitOrderList
//                                                   .first
//                                                   .isShowCheckbox
//                                               ? SizedBox.shrink()
//                                               : Get.find<AuthController>()
//                                                       .profileModel!
//                                                       .role!
//                                                       .contains('printer')
//                                                   ? Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               left: 20),
//                                                       child: InkWell(
//                                                           onTap: () async {
//                                                             searchOrder!
//                                                                 .clear();
//                                                             FocusManager
//                                                                 .instance
//                                                                 .primaryFocus
//                                                                 ?.unfocus();

//                                                             splitCurrentPrintIndex =
//                                                                 0;
//                                                             isSplitSelectPrinterList!
//                                                                 .clear();
//                                                             isSplitPrintedList!
//                                                                 .clear();
//                                                             isSplitPrinterProccessingList!
//                                                                 .clear();
//                                                             for (var i = 0;
//                                                                 i <
//                                                                     Get.find<
//                                                                             KdsController>()
//                                                                         .splitOrderList
//                                                                         .length;
//                                                                 i++) {
//                                                               isSplitSelectPrinterList!
//                                                                   .add(i == 0
//                                                                       ? true
//                                                                       : false);
//                                                               isSplitPrintedList!
//                                                                   .add(false);
//                                                               isSplitPrinterProccessingList!
//                                                                   .add(false);
//                                                             }
//                                                             printSplitBill!(
//                                                                 '2');
//                                                           },
//                                                           child: Align(
//                                                             alignment: Alignment
//                                                                 .centerLeft,
//                                                             child: SvgPicture
//                                                                 .asset(
//                                                               Images
//                                                                   .ic_print_kot,
//                                                               height: 26,
//                                                             ),
//                                                           )),
//                                                     )
//                                                   : SizedBox.shrink()
//                                           : Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 20),
//                                               child: Row(
//                                                 children: [
//                                                   InkWell(
//                                                       onTap: () async {
//                                                         searchOrder!.clear();
//                                                         FocusManager.instance
//                                                             .primaryFocus
//                                                             ?.unfocus();

//                                                         List<List<OrderDetails>>
//                                                             cartProductList =
//                                                             [];
//                                                         cartProductList = [];
//                                                         for (var i = 0;
//                                                             i <
//                                                                 Get.find<
//                                                                         AuthController>()
//                                                                     .profileModel!
//                                                                     .restaurantPrinterNew!
//                                                                     .length;
//                                                             i++) {
//                                                           RestaurantPrinterNew
//                                                               printer =
//                                                               Get.find<
//                                                                       AuthController>()
//                                                                   .profileModel!
//                                                                   .restaurantPrinterNew![i];
//                                                           List<OrderDetails>
//                                                               tempCartList = [];
//                                                           for (var e in order!
//                                                               .orderDetails!) {
//                                                             if (e.station ==
//                                                                     printer
//                                                                         .areaName &&
//                                                                 (e.foodStatus !=
//                                                                     3)) {
//                                                               tempCartList
//                                                                   .add(e);
//                                                             }
//                                                           }
//                                                           cartProductList.add(
//                                                               tempCartList);
//                                                         }
//                                                         // if (cartProductList
//                                                         //     .isNotEmpty) {
//                                                         await subscriptionBtStatus
//                                                             ?.cancel();
//                                                         if (order!.restaurantTable !=
//                                                                 null &&
//                                                             order!.restaurantTable!
//                                                                     .rtype ==
//                                                                 'RM') {
//                                                         } else {
//                                                           showToast(
//                                                               'Please wait..');
//                                                           Get.find<
//                                                                   LoadingController>()
//                                                               .startLoading(
//                                                                   true);
//                                                           await Get.find<
//                                                                   PosController>()
//                                                               .getCollectBillDetail({
//                                                             'order_id':
//                                                                 '${order!.id}'
//                                                           });
//                                                           Get.find<
//                                                                   LoadingController>()
//                                                               .startLoading(
//                                                                   false);
//                                                           if (Get.isBottomSheetOpen ??
//                                                               false) Get.back();
//                                                         }
//                                                         await Get.bottomSheet(
//                                                             PrintDialog(
//                                                               isBillPrint: order!
//                                                                               .restaurantTable !=
//                                                                           null &&
//                                                                       order!.restaurantTable!
//                                                                               .rtype ==
//                                                                           'RM'
//                                                                   ? false
//                                                                   : true,
//                                                               collectBillResponse:
//                                                                   Get.find<
//                                                                           PosController>()
//                                                                       .getCollectBillDetailResponse,
//                                                               cartProductList:
//                                                                   cartProductList,
//                                                               index: Get.find<
//                                                                       KdsController>()
//                                                                   .getWaiterOrderListResponse!
//                                                                   .orders!
//                                                                   .indexOf(
//                                                                       order!),
//                                                             ),
//                                                             backgroundColor:
//                                                                 Colors
//                                                                     .transparent,
//                                                             isScrollControlled:
//                                                                 true,
//                                                             ignoreSafeArea:
//                                                                 false);
//                                                         // }
//                                                       },
//                                                       child: Align(
//                                                         alignment: Alignment
//                                                             .centerLeft,
//                                                         child: SvgPicture.asset(
//                                                           Images.ic_print_kot,
//                                                           height: 26,
//                                                         ),
//                                                       )
//                                                       // Image.asset(
//                                                       //   Images.printKot,
//                                                       //   alignment: Alignment.centerLeft,
//                                                       //   height: 30,
//                                                       //   color: ColorTheme.appColor,
//                                                       // ),
//                                                       ),
//                                                   (order!.restaurantTable !=
//                                                               null &&
//                                                           order!.restaurantTable!
//                                                                   .rtype ==
//                                                               'RM')
//                                                       ? SizedBox.shrink()
//                                                       : SizedBox(
//                                                           width: 10,
//                                                         ),
//                                                   (order!.restaurantTable !=
//                                                               null &&
//                                                           order!.restaurantTable!
//                                                                   .rtype ==
//                                                               'RM')
//                                                       ? SizedBox.shrink()
//                                                       : InkWell(
//                                                           onTap: () {
//                                                             Get.bottomSheet(
//                                                                 whatsAppBottomSheet(
//                                                                     context,
//                                                                     order:
//                                                                         order!),
//                                                                 backgroundColor:
//                                                                     Colors
//                                                                         .transparent,
//                                                                 isScrollControlled:
//                                                                     true,
//                                                                 ignoreSafeArea:
//                                                                     false);
//                                                           },
//                                                           child: Icon(
//                                                               FontAwesomeIcons
//                                                                   .whatsapp,
//                                                               color:
//                                                                   Colors.green,
//                                                               size: 30),
//                                                         )
//                                                 ],
//                                               ),
//                                             ),
//                                       if (order!.isShowCheckbox)
//                                         InkWell(
//                                           onTap: () {
//                                             searchOrder!.clear();
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();

//                                             Get.find<KdsController>()
//                                                 .clearSelectedFoodItem();
//                                           },
//                                           child: Padding(
//                                             padding:
//                                                 const EdgeInsets.only(left: 10),
//                                             child: Icon(Icons.close,
//                                                 size: 35,
//                                                 color: ColorTheme.appColor),
//                                           ),
//                                         ),
//                                       if (Get.find<AuthController>()
//                                               .profileModel!
//                                               .role!
//                                               .contains('order_cancel') &&
//                                           order!.paymentType != 'prepaid' &&
//                                           (((Get.find<AuthController>()
//                                                                   .profileModel!
//                                                                   .restaurants!
//                                                                   .first
//                                                                   .showOrderStatus ==
//                                                               2
//                                                           ? order!.fOrderStatus! <=
//                                                               2
//                                                           : order!.fOrderStatus! <
//                                                               2) ||
//                                                       order!.orderType ==
//                                                           'delivery' ||
//                                                       order!.orderType ==
//                                                           'take_away') &&
//                                                   (cookingFoodItemLenght ==
//                                                       order!.orderDetails!
//                                                           .length) ||
//                                               Get.find<AuthController>()
//                                                       .profileModel!
//                                                       .restaurants!
//                                                       .first
//                                                       .showOrderStatus ==
//                                                   5))
//                                         InkWell(
//                                           onTap: () {
//                                             searchOrder?.clear();
//                                             // FocusManager.instance.primaryFocus
//                                             //     ?.unfocus();

//                                             // Get.bottomSheet(
//                                             //   ConfirmationDialog(
//                                             //       icon: Images.support,
//                                             //       description:
//                                             //           'Are you sure you want to cancel the complete order?',
//                                             //       isLogOut: true,
//                                             //       onYesPressed: () async {
//                                             //         Map<String, dynamic> jsonBody =
//                                             //             {
//                                             //           'order_id':
//                                             //               order.id.toString(),
//                                             //           'order_status': 'cancelled',
//                                             //           'role_name':
//                                             //               Get.find<AuthController>()
//                                             //                   .profileModel
//                                             //                   .role
//                                             //                   .first,
//                                             //         };
//                                             //         Get.back();
//                                             //         Get.find<KdsController>()
//                                             //             .changeOrderStatus(
//                                             //                 jsonBody, callback);
//                                             //       }),
//                                             // );
//                                             Get.bottomSheet(
//                                                 CancelOrderDialog(
//                                                   cancelType: 'order',
//                                                   orderId: order!.id.toString(),
//                                                 ),
//                                                 backgroundColor:
//                                                     Colors.transparent,
//                                                 isScrollControlled: true,
//                                                 ignoreSafeArea: false);
//                                           },
//                                           child: Padding(
//                                             padding:
//                                                 const EdgeInsets.only(left: 10),
//                                             child: Icon(Icons.close,
//                                                 size: 35,
//                                                 color: ColorTheme.appColor),
//                                           ),
//                                         ),
//                                     ],
//                                   )
//                                 : SizedBox.shrink(),
//                             Spacer(),
//                             Row(
//                               children: [
//                                 order!.paymentType != 'prepaid' &&
//                                         order!.fOrderStatus == 2 &&
//                                         (Get.find<AuthController>()
//                                             .profileModel!
//                                             .role!
//                                             .contains('order')) &&
//                                         Get.find<KdsController>()
//                                                 .selectedSubMenu ==
//                                             1
//                                     ? Padding(
//                                         padding:
//                                             const EdgeInsets.only(right: 5),
//                                         child: ThemeColorButton(
//                                           varticalPadding: 8,
//                                           horizontalPadding:
//                                               order!.fOrderStatus == 2
//                                                   ? 16
//                                                   : 35,
//                                           onTap: () {
//                                             searchOrder!.clear();
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();

//                                             Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         TabletPosScreen(
//                                                             editOrder:
//                                                                 order!)));
//                                           },
//                                           title: 'edit'.tr,
//                                         ),
//                                       )
//                                     : SizedBox.shrink(),
//                                 order!.isShowCheckbox
//                                     ? SizedBox.shrink()
//                                     : order!.fOrderStatus != 2 &&
//                                             (Get.find<KdsController>()
//                                                         .selectedSubMenu ==
//                                                     1 ||
//                                                 Get.find<KdsController>()
//                                                         .selectedSubMenu ==
//                                                     2) &&
//                                             order!.paymentType == 'prepaid'
//                                         ? SizedBox.shrink()
//                                         : (Get.find<AuthController>()
//                                                     .profileModel!
//                                                     .role!
//                                                     .contains('order') &&
//                                                 (Get.find<AuthController>()
//                                                                 .profileModel!
//                                                                 .restaurants!
//                                                                 .first
//                                                                 .isDeliveryAssign ==
//                                                             'Yes' &&
//                                                         order!.orderType ==
//                                                             'delivery'
//                                                     ? (Get.find<
//                                                             AuthController>()
//                                                         .profileModel!
//                                                         .role!
//                                                         .contains(
//                                                             'assign_online_order'))
//                                                     : true))
//                                             ? ThemeColorButton(
//                                                 onTap: () async {
//                                                   searchOrder!.clear();
//                                                   FocusManager
//                                                       .instance.primaryFocus
//                                                       ?.unfocus();

//                                                   if (order!.fOrderStatus ==
//                                                       2) {
//                                                     Map<String, dynamic>
//                                                         jsonBody = {
//                                                       'order_id':
//                                                           order!.id.toString(),
//                                                       'order_status': 'serve',
//                                                       'role_name': Get.find<
//                                                               AuthController>()
//                                                           .profileModel!
//                                                           .role!
//                                                           .first,
//                                                     };
//                                                     if (order!.orderType ==
//                                                             'delivery' ||
//                                                         order!.orderType ==
//                                                             'take_away') {
//                                                       subscriptionBtStatus!
//                                                           .cancel();
//                                                       Get.find<KdsController>()
//                                                           .resetSplitBill();
//                                                       if (Get.find<AuthController>()
//                                                                   .profileModel!
//                                                                   .restaurants!
//                                                                   .first
//                                                                   .isDeliveryAssign ==
//                                                               'Yes' &&
//                                                           order!.orderType ==
//                                                               'delivery') {
//                                                         await Get.find<
//                                                                 DeliveryManController>()
//                                                             .getDeliveryManList();

//                                                         Get.bottomSheet(
//                                                             assignDeliveryBoy(
//                                                                 context,
//                                                                 order!),
//                                                             backgroundColor:
//                                                                 Colors
//                                                                     .transparent,
//                                                             isScrollControlled:
//                                                                 true,
//                                                             ignoreSafeArea:
//                                                                 false);
//                                                       } else {
//                                                         if (order!
//                                                                 .paymentType ==
//                                                             'prepaid') {
//                                                           Map<String, dynamic>
//                                                               jsonBodyPrepaid =
//                                                               {
//                                                             'order_id': order!
//                                                                 .id
//                                                                 .toString(),
//                                                             'payment_status':
//                                                                 'sucess',
//                                                           };
//                                                           Get.find<
//                                                                   KdsController>()
//                                                               .changePrepaidOrderStatus(
//                                                                   jsonBodyPrepaid,
//                                                                   callback);
//                                                         } else {
//                                                           if (order!
//                                                                   .orderType ==
//                                                               'delivery') {
//                                                             jsonBody[
//                                                                     'order_dispatch_status'] =
//                                                                 'Yes';
//                                                             Get.find<
//                                                                     KdsController>()
//                                                                 .changeOrderStatus(
//                                                                     jsonBody,
//                                                                     callback);
//                                                           } else {
//                                                             Get.toNamed(RouteHelper
//                                                                 .getWaiterCollectPaymentRoute(
//                                                                     order!.id
//                                                                         .toString()));
//                                                           }
//                                                         }
//                                                       }
//                                                     } else {
//                                                       if (Get.find<
//                                                                   AuthController>()
//                                                               .profileModel!
//                                                               .restaurants!
//                                                               .first
//                                                               .isComplementry ==
//                                                           'Yes') {
//                                                         showToast(
//                                                             'Please wait..');
//                                                         Get.find<
//                                                                 LoadingController>()
//                                                             .startLoading(true);
//                                                         Map<String, dynamic>
//                                                             jsonData = {
//                                                           'waiter_id': Get.find<
//                                                                   AuthController>()
//                                                               .profileModel!
//                                                               .empId
//                                                               .toString(),
//                                                           'payment_mode':
//                                                               'cash',
//                                                           'paid_room': '',
//                                                           'payment_status':
//                                                               'sucess',
//                                                           'email': '',
//                                                           'payment_amount': 0,
//                                                           'grant_amount': 0,
//                                                           'vat_tax': 0,
//                                                           'gst_tax': 0,
//                                                           'self_discount': 0,
//                                                           'comm_discount': 0,
//                                                           'tip_amount': '0',
//                                                           'order_discount': 0,
//                                                           'mobile': '',
//                                                           'name': '',
//                                                           'restaurant_name': Get
//                                                                   .find<
//                                                                       AuthController>()
//                                                               .profileModel!
//                                                               .restaurants![0]
//                                                               .name,
//                                                           'service_tax': 0,
//                                                           'transaction_id': '',
//                                                           'order_id': order!.id
//                                                         };
//                                                         Get.find<
//                                                                 PosController>()
//                                                             .collectPayment((bool
//                                                                     isSuccess,
//                                                                 String
//                                                                     msg) async {
//                                                           Get.find<
//                                                                   LoadingController>()
//                                                               .startLoading(
//                                                                   false);
//                                                           await Get.find<
//                                                                   LoadingController>()
//                                                               .changeText(
//                                                                   data: msg);
//                                                           await Get.find<
//                                                                   LoadingController>()
//                                                               .changeStatus(
//                                                                   data: true);
//                                                         }, jsonData: jsonData);
//                                                       } else {
//                                                         Get.find<
//                                                                 KdsController>()
//                                                             .changeOrderStatus(
//                                                                 jsonBody,
//                                                                 callback);
//                                                       }
//                                                     }
//                                                   } else if (Get.find<
//                                                                   KdsController>()
//                                                               .selectedSubMenu ==
//                                                           1 ||
//                                                       Get.find<KdsController>()
//                                                               .selectedSubMenu ==
//                                                           2) {
//                                                     Get.find<KdsController>()
//                                                         .resetSplitBill();
//                                                     Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) =>
//                                                                 TabletPosScreen(
//                                                                     editOrder:
//                                                                         order!)));
//                                                   }
//                                                 },
//                                                 varticalPadding: 8,
//                                                 horizontalPadding:
//                                                     order!.fOrderStatus == 2
//                                                         ? order!.orderType ==
//                                                                 'delivery'
//                                                             ? 14
//                                                             : 18
//                                                         : 12,
//                                                 editPadding:
//                                                     order!.fOrderStatus == 2
//                                                         ? 25
//                                                         : 10,
//                                                 title: order!.fOrderStatus == 2
//                                                     ? order!.orderType ==
//                                                             'delivery'
//                                                         ? Get.find<AuthController>()
//                                                                     .profileModel!
//                                                                     .restaurants!
//                                                                     .first
//                                                                     .isDeliveryAssign ==
//                                                                 'Yes'
//                                                             ? order!.deliveryMan ==
//                                                                     ''
//                                                                 ? 'Assign'
//                                                                 : 'Re-Assign'
//                                                             : order!.paymentType ==
//                                                                     'prepaid'
//                                                                 ? 'Settle'
//                                                                 : order!.deliveryDispatchStatus ==
//                                                                         'No'
//                                                                     ? 'Dispatch'
//                                                                     : 'Deliver'
//                                                         : 'Serve'.tr
//                                                     : 'edit'.tr,
//                                                 color: order!.fOrderStatus ==
//                                                             2 &&
//                                                         order!.orderType ==
//                                                             'delivery' &&
//                                                         Get.find<AuthController>()
//                                                                 .profileModel!
//                                                                 .restaurants!
//                                                                 .first
//                                                                 .isDeliveryAssign ==
//                                                             'Yes' &&
//                                                         order!.deliveryManStatus ==
//                                                             'Yes'
//                                                     ? ColorTheme.green
//                                                     : null,
//                                               )
//                                             : SizedBox.shrink(),
//                                 // SizedBox(width: 10),
//                                 // if (Get.find<AuthController>()
//                                 //         .profileModel
//                                 //         .role
//                                 //         .contains('Manager') &&
//                                 //     Get.find<AuthController>()
//                                 //         .profileModel
//                                 //         .role
//                                 //         .contains('order') &&
//                                 //     (Get.find<AuthController>()
//                                 //                 .profileModel
//                                 //                 .restaurants
//                                 //                 .first
//                                 //                 .showOrderStatus ==
//                                 //             2
//                                 //         ? order.fOrderStatus <= 2
//                                 //         : order.fOrderStatus < 2) &&
//                                 //     (cookingFoodItemLenght ==
//                                 //         order.orderDetails.length))
//                                 // InkWell(
//                                 //   splashColor: Colors.transparent,
//                                 //   hoverColor: Colors.transparent,
//                                 //   highlightColor: Colors.transparent,
//                                 //   onTap: () {
//                                 //     searchOrder.clear();
//                                 //     Map<String, dynamic> jsonBody = {
//                                 //       'order_id': order.id.toString(),
//                                 //       'order_status': 'cancelled',
//                                 //       'role_name': Get.find<AuthController>()
//                                 //           .profileModel
//                                 //           .role
//                                 //           .first,
//                                 //     };
//                                 //     Get.find<KdsController>()
//                                 //         .changeOrderStatus(jsonBody, callback);
//                                 //   },
//                                 //   child: Container(
//                                 //     padding: EdgeInsets.symmetric(
//                                 //         vertical: 8, horizontal: 10),
//                                 //     decoration: BoxDecoration(
//                                 //         border:
//                                 //             Border.all(color: Colors.transparent),
//                                 //         color: ColorTheme.appColor,
//                                 //         // border:
//                                 //         //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                                 //         borderRadius: BorderRadius.circular(
//                                 //             Dimensions.RADIUS_DEFAULT)),
//                                 //     child: Center(
//                                 //       child: Text(
//                                 //         'Cancel',
//                                 //         style: poppinsMedium.copyWith(
//                                 //             fontSize:
//                                 //                 Dimensions.FONT_SIZE_DEFAULT,
//                                 //             color: Colors.white),
//                                 //       ),
//                                 //     ),
//                                 //   ),

//                                 // SizedBox(width: 5),

//                                 Get.find<KdsController>().selectedSubMenu == 2
//                                     ? Padding(
//                                         padding:
//                                             const EdgeInsets.only(right: 18),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             // SizedBox(width: 5),
//                                             if ((Get.find<AuthController>()
//                                                         .profileModel!
//                                                         .role!
//                                                         .contains('bill') ||
//                                                     Get.find<AuthController>()
//                                                         .profileModel!
//                                                         .role!
//                                                         .contains(
//                                                             'clear_payment')) &&
//                                                 !order!.isShowCheckbox &&
//                                                 (Get.find<AuthController>()
//                                                                 .profileModel!
//                                                                 .restaurants!
//                                                                 .first
//                                                                 .isDeliveryAssign ==
//                                                             'Yes' &&
//                                                         order!.orderType ==
//                                                             'delivery'
//                                                     ? (Get.find<
//                                                             AuthController>()
//                                                         .profileModel!
//                                                         .role!
//                                                         .contains(
//                                                             'assign_online_order'))
//                                                     : true))
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 5),
//                                                 child: ThemeColorButton(
//                                                   varticalPadding: 8,
//                                                   horizontalPadding: 8,
//                                                   onTap: () async {
//                                                     searchOrder!.clear();
//                                                     FocusManager
//                                                         .instance.primaryFocus
//                                                         ?.unfocus();

//                                                     subscriptionBtStatus
//                                                         ?.cancel();
//                                                     Get.find<KdsController>()
//                                                         .resetSplitBill();
//                                                     if (Get.find<AuthController>()
//                                                                 .profileModel!
//                                                                 .restaurants!
//                                                                 .first
//                                                                 .isDeliveryAssign ==
//                                                             'Yes' &&
//                                                         order!.orderType ==
//                                                             'delivery') {
//                                                       await Get.find<
//                                                               DeliveryManController>()
//                                                           .getDeliveryManList();

//                                                       Get.bottomSheet(
//                                                           assignDeliveryBoy(
//                                                               context, order!),
//                                                           backgroundColor:
//                                                               Colors
//                                                                   .transparent,
//                                                           isScrollControlled:
//                                                               true,
//                                                           ignoreSafeArea:
//                                                               false);
//                                                     } else {
//                                                       if (order!.orderType ==
//                                                               'delivery' &&
//                                                           order!.deliveryDispatchStatus ==
//                                                               'No') {
//                                                         Map<String, dynamic>
//                                                             jsonBody = {
//                                                           'order_id': order!.id
//                                                               .toString(),
//                                                           'order_status':
//                                                               'serve',
//                                                           'role_name': Get.find<
//                                                                   AuthController>()
//                                                               .profileModel!
//                                                               .role!
//                                                               .first,
//                                                         };
//                                                         jsonBody[
//                                                                 'order_dispatch_status'] =
//                                                             'Yes';
//                                                         Get.find<
//                                                                 KdsController>()
//                                                             .changeOrderStatus(
//                                                                 jsonBody,
//                                                                 callback);
//                                                       } else {
//                                                         if (order!
//                                                                 .paymentType ==
//                                                             'prepaid') {
//                                                           Map<String, dynamic>
//                                                               jsonBodyPrepaid =
//                                                               {
//                                                             'order_id': order!
//                                                                 .id
//                                                                 .toString(),
//                                                             'payment_status':
//                                                                 'sucess',
//                                                           };
//                                                           Get.find<
//                                                                   KdsController>()
//                                                               .changePrepaidOrderStatus(
//                                                                   jsonBodyPrepaid,
//                                                                   callback);
//                                                         } else {
//                                                           Get.toNamed(RouteHelper
//                                                               .getWaiterCollectPaymentRoute(
//                                                                   order!.id
//                                                                       .toString()));
//                                                         }
//                                                       }
//                                                     }
//                                                   },
//                                                   color: order!.orderType ==
//                                                               'delivery' &&
//                                                           Get.find<AuthController>()
//                                                                   .profileModel!
//                                                                   .restaurants!
//                                                                   .first
//                                                                   .isDeliveryAssign ==
//                                                               'Yes'
//                                                       ? ColorTheme.green
//                                                       : null,
//                                                   title: order!.orderType ==
//                                                           'delivery'
//                                                       ? Get.find<AuthController>()
//                                                                   .profileModel!
//                                                                   .restaurants!
//                                                                   .first
//                                                                   .isDeliveryAssign ==
//                                                               'Yes'
//                                                           ? order!.deliveryMan ==
//                                                                   ''
//                                                               ? 'Assign'
//                                                               : 'Re-Assign'
//                                                           : order!.paymentType ==
//                                                                   'prepaid'
//                                                               ? 'Settle'
//                                                               : order!.deliveryDispatchStatus ==
//                                                                       'No'
//                                                                   ? 'Dispatch'
//                                                                   : 'Deliver'
//                                                       : order!.restaurantTable !=
//                                                                   null &&
//                                                               order!.restaurantTable!
//                                                                       .rtype ==
//                                                                   'RM'
//                                                           ? 'Check-out'
//                                                           : order!.paymentType ==
//                                                                   'prepaid'
//                                                               ? 'Settle'
//                                                               : 'Collect Bill',
//                                                 ),
//                                               ),

//                                             if (Get.find<AuthController>()
//                                                     .profileModel!
//                                                     .role!
//                                                     .contains('bill') &&
//                                                 order!.orderType !=
//                                                     'delivery' &&
//                                                 order!.orderType !=
//                                                     'take_away' &&
//                                                 (order!.restaurantTable ==
//                                                         null ||
//                                                     (order!.restaurantTable !=
//                                                             null &&
//                                                         order!.restaurantTable!
//                                                                 .rtype !=
//                                                             'RM')))
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 5),
//                                                 child: ThemeColorButton(
//                                                   varticalPadding: 8,
//                                                   horizontalPadding: 10,
//                                                   onTap: () {
//                                                     searchOrder!.clear();
//                                                     FocusManager
//                                                         .instance.primaryFocus
//                                                         ?.unfocus();

//                                                     if (order!.isShowCheckbox) {
//                                                       Get.find<KdsController>()
//                                                           .splitOrder();
//                                                     } else {
//                                                       Get.find<KdsController>()
//                                                           .selectSplitOrder(
//                                                               order!);
//                                                     }
//                                                   },
//                                                   title: 'Split Bill',
//                                                 ),
//                                               ),
//                                             if (order!.isShowCheckbox)
//                                               SizedBox(width: 10),
//                                             if (order!.isShowCheckbox)
//                                               ThemeColorButton(
//                                                 varticalPadding: 8,
//                                                 horizontalPadding: 10,
//                                                 onTap: () {
//                                                   searchOrder!.clear();
//                                                   FocusManager
//                                                       .instance.primaryFocus
//                                                       ?.unfocus();

//                                                   Get.find<KdsController>()
//                                                       .resetSplitBill();
//                                                 },
//                                                 title: 'Reset',
//                                               ),
//                                           ],
//                                         ),
//                                       )
//                                     : SizedBox(width: 18),
//                               ],
//                             ),
//                           ],
//                         ),
//         ],
//       ),
//     );
//   }

//   void callback(bool isSuccess, String message) async {
//     if (isSuccess) {
//       // showCustomSnackBar(message, isError: false);
//     } else {
//       // showCustomSnackBar(message);
//     }
//   }

//   void showAddressDialog(OrderList order) {
//     Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
//       return Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
//             color: Colors.white),
//         child: Padding(
//           padding: EdgeInsets.only(
//               left: 25,
//               right: 25,
//               top: 25,
//               bottom: Dimensions.PADDING_SIZE_DEFAULT),
//           child: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // SizedBox(),
//                     Text('Address #${order.deliveryAddress?.addressType}',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 18, color: Colors.black)),
//                     InkWell(
//                         onTap: () {
//                           Get.back();
//                         },
//                         child: Icon(Icons.close, color: ColorTheme.appColor))
//                   ],
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(top: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                           'Name: ${order.deliveryAddress?.contactPersonName ?? ''}',
//                           style: poppinsMedium.copyWith(fontSize: 16)),
//                       const SizedBox(height: 5),
//                       Text(
//                           'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
//                           style: poppinsMedium.copyWith(fontSize: 16)),
//                       const SizedBox(height: 5),
//                       // Text(
//                       //     'Address type: ${order.deliveryAddress?.addressType ?? ''}',
//                       //     style: poppinsMedium.copyWith(fontSize: 14)),
//                       // const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Text(
//                                 'Address: ${order.deliveryAddress?.address ?? ''}',
//                                 style: poppinsMedium.copyWith(fontSize: 16)),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15),
//                             child: InkWell(
//                               onTap: () async {
//                                 if (await MapLauncher.isMapAvailable(
//                                         MapType.google) ==
//                                     true) {
//                                   await MapLauncher.showDirections(
//                                       mapType: MapType.google,
//                                       destination: Coords(
//                                         double.parse(
//                                             order.deliveryAddress!.latitude!),
//                                         double.parse(
//                                             order.deliveryAddress!.longitude!),
//                                       )
//                                       // coords: coords,
//                                       // title: 'My Genie',
//                                       // description: '',
//                                       );
//                                 } else if (await MapLauncher.isMapAvailable(
//                                         MapType.apple) ==
//                                     true) {
//                                   await MapLauncher.showDirections(
//                                       mapType: MapType.apple,
//                                       destination: Coords(
//                                         double.parse(
//                                             order.deliveryAddress!.latitude!),
//                                         double.parse(
//                                             order.deliveryAddress!.longitude!),
//                                       )
//                                       // coords: coords,
//                                       // title: 'My Genie',
//                                       // description: '',
//                                       );
//                                 }
//                                 // String googleUrl =
//                                 //     'https://www.google.com/maps/search/?api=1&query=15.00952529999999995879989000968635082244873046875,74.0489457999999984849637257866561412811279296875';
//                                 // try {
//                                 //   if (await canLaunchUrl(Uri.parse(googleUrl))) {
//                                 //     await launchUrl(Uri.parse(googleUrl));
//                                 //   } else {
//                                 //     throw 'Could not open the map.';
//                                 //   }
//                                 // } catch (e) {
//                                 //   print('$e ---------Error');
//                                 // }
//                               },
//                               child: Icon(
//                                 CupertinoIcons.map_pin_ellipse,
//                                 color: ColorTheme.appColor,
//                                 size: 45,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                           'House No/Flat No.: ${order.deliveryAddress?.house ?? ''}',
//                           style: poppinsMedium.copyWith(fontSize: 16)),

//                       const SizedBox(height: 5),

//                       Text('Pincode: ${order.deliveryAddress?.pincode ?? ''}',
//                           style: poppinsMedium.copyWith(fontSize: 16)),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }));
//   }

//   Widget openTableList(BuildContext context, OrderList order) {
//     // List<TableResponseModel> tableList = Get.find<CartController>()
//     //     .tableList
//     //     .where((element) => element.type == 'TB');
//     TableResponseModel? tableIdSelect;
//     List<TableResponseModel> tableList = [];
//     List<TableResponseModel> roomList = [];
//     if (order.restaurantTable != null && order.restaurantTable!.rtype == 'RM') {
//       roomList = Get.find<CartController>()
//           .roomList
//           .where((item) => item.type == 'RM')
//           .toList();
//     } else {
//       roomList = Get.find<CartController>()
//           .roomList
//           .where((item) => item.type == 'RM')
//           .toList();
//       tableList = Get.find<CartController>()
//           .tableList
//           .where((item) => item.type == 'TB')
//           .toList();
//     }
//     return SafeArea(
//       child: Container(
//         height: Get.height * 0.6,
//         padding: EdgeInsets.only(
//             left: 25,
//             right: 25,
//             top: 25,
//             bottom: Dimensions.PADDING_SIZE_DEFAULT),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(
//               top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
//         ),
//         child: GetBuilder(builder: (RestaurantController restaurantController) {
//           return Column(mainAxisSize: MainAxisSize.min, children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                       order.restaurantTable != null &&
//                               order.restaurantTable!.rtype == 'RM'
//                           ? 'Select Room'
//                           : 'Select Table',
//                       style: poppinsMedium.copyWith(
//                           color: Colors.black, fontSize: 18)),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: InkWell(
//                       onTap: () {
//                         searchOrder!.clear();
//                         FocusManager.instance.primaryFocus?.unfocus();

//                         Get.back();
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 30,
//                         color: ColorTheme.appColor,
//                       )),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Divider(color: ColorTheme.borderGrey),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Container(
//                 height: 40,
//                 child: TextField(
//                   controller: searchTable,
//                   textInputAction: TextInputAction.search,
//                   autofocus: false,
//                   textCapitalization: TextCapitalization.words,
//                   keyboardType: TextInputType.name,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(
//                         horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//                     suffixIcon: Icon(
//                       Icons.search,
//                       color: ColorTheme.appColor,
//                       size: 25,
//                     ),
//                     hintText: 'Search',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     hintStyle: poppinsMedium.copyWith(
//                         fontSize: 13, color: ColorTheme.hintText),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   style: poppinsMedium.copyWith(
//                     fontSize: 13,
//                   ),
//                   onChanged: (value) async {
//                     if (searchTable!.text.isNotEmpty) {
//                       if (order.restaurantTable != null &&
//                           order.restaurantTable!.rtype == 'RM') {
//                         roomList = Get.find<CartController>()
//                             .roomList
//                             .where((item) =>
//                                 item.type == 'RM' &&
//                                 (item.title.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase()) ||
//                                     item.tableNo.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase())))
//                             .toList();
//                       } else {
//                         roomList = Get.find<CartController>()
//                             .roomList
//                             .where((item) =>
//                                 item.type == 'RM' &&
//                                 (item.title.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase()) ||
//                                     item.tableNo.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase())))
//                             .toList();
//                         tableList = Get.find<CartController>()
//                             .tableList
//                             .where((item) =>
//                                 item.type == 'TB' &&
//                                 (item.title.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase()) ||
//                                     item.tableNo.toLowerCase().contains(
//                                         searchTable!.text.toLowerCase())))
//                             .toList();
//                       }
//                       // tableList = tableList
//                       //     .where((item) => (item.title
//                       //             .toLowerCase()
//                       //             .contains(searchTable.text.toLowerCase()) ||
//                       //         item.tableNo
//                       //             .toLowerCase()
//                       //             .contains(searchTable.text.toLowerCase())))
//                       //     .toList();
//                     } else {
//                       if (order.restaurantTable != null &&
//                           order.restaurantTable!.rtype == 'RM') {
//                         roomList = Get.find<CartController>()
//                             .roomList
//                             .where((item) => item.type == 'RM')
//                             .toList();
//                       } else {
//                         roomList = Get.find<CartController>()
//                             .roomList
//                             .where((item) => item.type == 'RM')
//                             .toList();
//                         tableList = Get.find<CartController>()
//                             .tableList
//                             .where((item) => item.type == 'TB')
//                             .toList();
//                       }
//                     }
//                     restaurantController.update();
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     if (tableList.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 15),
//                         child: GridView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: tableList.length,
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisSpacing: 7,
//                                   childAspectRatio: 2.5,
//                                   mainAxisSpacing: 7,
//                                   crossAxisCount: 3),
//                           itemBuilder: (BuildContext context, int index) {
//                             return InkWell(
//                                 onTap: () {
//                                   searchOrder!.clear();
//                                   // tableIndex = index;
//                                   FocusManager.instance.primaryFocus?.unfocus();

//                                   tableIdSelect = tableList[index];
//                                   restaurantController.update();
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: 8, horizontal: 10),
//                                   decoration: BoxDecoration(
//                                       color: tableIdSelect == tableList[index]
//                                           ? ColorTheme.appColor
//                                           : ColorTheme.tableBoxGrey,
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                           color:
//                                               tableIdSelect == tableList[index]
//                                                   ? ColorTheme.appColor
//                                                   : ColorTheme.borderGrey)),
//                                   child: Center(
//                                     child: Text(
//                                         '${tableList[index].title} ${tableList[index].tableNo} ',
//                                         style: poppinsMedium.copyWith(
//                                             fontSize: 13,
//                                             color: tableIdSelect ==
//                                                     tableList[index]
//                                                 ? Colors.white
//                                                 : ColorTheme.hintText)),
//                                   ),
//                                 ));
//                           },
//                         ),
//                       ),
//                     if (tableList.isNotEmpty &&
//                         roomList.isNotEmpty &&
//                         order.restaurantTable != null &&
//                         order.restaurantTable!.rtype == 'RM')
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Divider(
//                           thickness: 1,
//                           color: ColorTheme.appColor,
//                         ),
//                       ),
//                     // if (roomList.isNotEmpty &&
//                     //   order.restaurantTable != null &&
//                     //   order.restaurantTable.rtype == 'RM')
//                     // Padding(
//                     //   padding: const EdgeInsets.only(bottom: 10, top: 8),
//                     //   child: Align(
//                     //     alignment: Alignment.centerLeft,
//                     //     child: Text('Room List ',
//                     //         style: poppinsMedium.copyWith(
//                     //             fontSize: 15, color: ColorTheme.appColor)),
//                     //   ),
//                     // ),
//                     if (roomList.isNotEmpty &&
//                         order.restaurantTable != null &&
//                         order.restaurantTable!.rtype == 'RM')
//                       Padding(
//                         padding: const EdgeInsets.only(top: 15),
//                         child: GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: roomList.length,
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisSpacing: 7,
//                                   mainAxisSpacing: 7,
//                                   childAspectRatio: 2.5,
//                                   crossAxisCount: 3),
//                           itemBuilder: (BuildContext context, int index) {
//                             return InkWell(
//                                 onTap: () {
//                                   searchOrder!.clear();
//                                   // tableIndex = index;
//                                   FocusManager.instance.primaryFocus?.unfocus();

//                                   tableIdSelect = roomList[index];
//                                   restaurantController.update();
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: 8, horizontal: 10),
//                                   decoration: BoxDecoration(
//                                       color: tableIdSelect == roomList[index]
//                                           ? ColorTheme.appColor
//                                           : Color(0xFFECECEC),
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                           color:
//                                               tableIdSelect == roomList[index]
//                                                   ? ColorTheme.appColor
//                                                   : Color(0xFFC6C6C6))),
//                                   child: Text(
//                                       '${roomList[index].title} ${roomList[index].tableNo} ',
//                                       style: poppinsMedium.copyWith(
//                                           fontSize: 13,
//                                           color:
//                                               tableIdSelect == roomList[index]
//                                                   ? Colors.white
//                                                   : ColorTheme.hintText)),
//                                 ));
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             CustomButton(
//               width: Get.width / 2.0,
//               buttonText: 'Done',
//               onPressed: () async {
//                 Map<String, dynamic> jsonData = {
//                   'order_id': order.id,
//                   'old_table_id':
//                       order.tableId == null ? '0' : '${order.tableId}',
//                   'new_table_id': tableIdSelect!.id
//                 };
//                 Get.find<CartController>().changeTable(
//                     tableIdSelect!.type, jsonData, (bool isSucces) {
//                   if (isSucces) {
//                     order.tableId = tableIdSelect!.id;
//                     order.restaurantTable = RestaurantTable(
//                         id: tableIdSelect!.id,
//                         rtype: tableIdSelect!.type,
//                         tableNo: tableIdSelect?.tableNo,
//                         title: tableIdSelect?.title);
//                     if (Get.isBottomSheetOpen ?? false) Get.back();
//                     Get.find<KdsController>().update();
//                     // order.tableId = tableIdSelect.id;
//                     // order.restaurantTable.tableNo = tableIdSelect.tableNo;
//                     // order.restaurantTable.title = tableIdSelect.title;
//                     // Get.find<KdsController>().update();
//                     // showErrorToast(
//                     //     tableIdSelect.type == 'RM'
//                     //         ? 'Room change successfully'
//                     //         : 'Table change successfully',
//                     //     isError: false);
//                   } else {
//                     // showErrorToast(
//                     //     tableIdSelect.type == 'RM'
//                     //         ? 'Failed room changed'
//                     //         : 'Failed table changed',
//                     //     isError: false);
//                   }
//                 });
//                 // Get.back();
//               },
//             ),
//           ]);
//         }),
//       ),
//     );
//   }

//   Widget mergeTable(BuildContext context, OrderList orderDetail) {
//     String? selectedOrderId;
//     String? selectedTableName;
//     List<OrderList> orderList = [];
//     bool isSwitchNote = false;

//     orderList = Get.find<KdsController>()
//         .getWaiterOrderListResponse!
//         .orders!
//         .where((element) =>
//             element.orderType != 'delivery' &&
//             element.orderType != 'take_away' &&
//             element.fOrderStatus != 6 &&
//             element.fOrderStatus != 3 &&
//             element.id != order!.id &&
//             ((element.restaurantTable != null &&
//                     element.restaurantTable!.tableNo != '' &&
//                     element.restaurantTable!.rtype != 'RM') ||
//                 element.tableId == 0))
//         .toList();
//     return SafeArea(
//       child: Container(
//         height: Get.height * 0.6,
//         padding: EdgeInsets.only(
//             left: 25,
//             right: 25,
//             top: 25,
//             bottom: Dimensions.PADDING_SIZE_DEFAULT),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(
//               top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
//         ),
//         child: GetBuilder(builder: (RestaurantController restaurantController) {
//           return Column(mainAxisSize: MainAxisSize.min, children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       order!.restaurantTable == null ||
//                               order!.restaurantTable!.tableNo == ''
//                           ? order!.orderType == 'delivery'
//                               ? 'Delivery'
//                               : order!.orderType == 'take_away'
//                                   ? 'Take Away'
//                                   : order!.userName != 'Mygenie' &&
//                                           order!.userName != ''
//                                       ? order!.userName
//                                       : 'WC'
//                           : order!.restaurantTable!.title == ''
//                               ? '#${order!.restaurantTable!.tableNo}'
//                               : '#${order!.restaurantTable!.title}-${order!.restaurantTable!.tableNo}',
//                       style: poppinsMedium.copyWith(
//                         color: Colors.black,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Text(
//                       'Merge Table',
//                       style: poppinsMedium.copyWith(
//                           fontSize: 11, color: Colors.black),
//                       textAlign: TextAlign.start,
//                     ),
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: InkWell(
//                       onTap: () {
//                         searchOrder!.clear();
//                         FocusManager.instance.primaryFocus?.unfocus();

//                         Get.back();
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 30,
//                         color: ColorTheme.appColor,
//                       )),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Divider(color: ColorTheme.borderGrey),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Container(
//                 height: 40,
//                 child: TextField(
//                   controller: searchTable,
//                   textInputAction: TextInputAction.search,
//                   autofocus: false,
//                   textCapitalization: TextCapitalization.words,
//                   keyboardType: TextInputType.name,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(
//                         horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//                     suffixIcon: Icon(
//                       Icons.search,
//                       color: ColorTheme.appColor,
//                       size: 25,
//                     ),
//                     hintText: 'Search',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     hintStyle: poppinsMedium.copyWith(
//                         fontSize: 13, color: ColorTheme.hintText),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   style: poppinsMedium.copyWith(
//                     fontSize: 13,
//                   ),
//                   onChanged: (value) async {
//                     if (searchTable!.text.isNotEmpty) {
//                       orderList = Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders!
//                           .where((item) => (item.id != orderDetail.id &&
//                               item.fOrderStatus != 6 &&
//                               item.fOrderStatus != 3 &&
//                               item.orderType != 'delivery' &&
//                               item.orderType != 'take_away' &&
//                               (((item.restaurantTable == null ||
//                                           item.restaurantTable!.tableNo ==
//                                               '') &&
//                                       item.userName.toLowerCase().contains(
//                                           searchTable!.text.toLowerCase())) ||
//                                   (item.restaurantTable != null &&
//                                       item.restaurantTable!.tableNo != '' &&
//                                       item.restaurantTable!.rtype != 'RM' &&
//                                       item.restaurantTable!.tableNo!
//                                           .toLowerCase()
//                                           .contains(searchTable!.text
//                                               .toLowerCase())))))
//                           .toList();
//                     } else {
//                       orderList = Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders!
//                           .where((element) =>
//                               element.orderType != 'delivery' &&
//                               element.orderType != 'take_away' &&
//                               element.fOrderStatus != 6 &&
//                               element.fOrderStatus != 3 &&
//                               element.id != orderDetail.id &&
//                               ((element.restaurantTable != null &&
//                                       element.restaurantTable!.tableNo != '' &&
//                                       element.restaurantTable!.rtype != 'RM') ||
//                                   element.tableId == 0))
//                           .toList();
//                     }
//                     restaurantController.update();
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 15),
//                       child: GridView.builder(
//                         physics: NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: orderList.length ?? 0,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisSpacing: 7,
//                             childAspectRatio: 2.5,
//                             mainAxisSpacing: 7,
//                             crossAxisCount: 3),
//                         itemBuilder: (BuildContext context, int index) {
//                           OrderList order = orderList[index];
//                           return InkWell(
//                               onTap: () {
//                                 searchOrder!.clear();
//                                 // tableIndex = index;
//                                 FocusManager.instance.primaryFocus?.unfocus();

//                                 selectedOrderId = order.id!;
//                                 selectedTableName = order.restaurantTable ==
//                                             null ||
//                                         order.restaurantTable!.tableNo == ''
//                                     ? order.orderType == 'delivery'
//                                         ? 'Delivery'
//                                         : order.orderType == 'take_away'
//                                             ? 'Take Away'
//                                             : order.userName != 'Mygenie' &&
//                                                     order.userName != ''
//                                                 ? order.userName
//                                                 : 'WC'
//                                     : order.restaurantTable?.title == ''
//                                         ? '${order.restaurantTable?.tableNo}'
//                                         : '${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}';

//                                 restaurantController.update();
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 10),
//                                 decoration: BoxDecoration(
//                                     color: selectedOrderId == order.id
//                                         ? ColorTheme.appColor
//                                         : ColorTheme.tableBoxGrey,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                         color: selectedOrderId == order.id
//                                             ? ColorTheme.appColor
//                                             : ColorTheme.borderGrey)),
//                                 child: Center(
//                                   child: Text(
//                                       order.restaurantTable == null ||
//                                               order.restaurantTable!.tableNo ==
//                                                   ''
//                                           ? order.orderType == 'delivery'
//                                               ? 'Delivery'
//                                               : order.orderType == 'take_away'
//                                                   ? 'Take Away'
//                                                   : order.userName !=
//                                                               'Mygenie' &&
//                                                           order.userName != ''
//                                                       ? order.userName
//                                                       : 'WC'
//                                           : order.restaurantTable!.title == ''
//                                               ? '${order.restaurantTable!.tableNo}'
//                                               : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                                       style: poppinsMedium.copyWith(
//                                           fontSize: 10,
//                                           color: selectedOrderId == order.id
//                                               ? Colors.white
//                                               : ColorTheme.hintText)),
//                                 ),
//                               ));
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .foodLevelNotes !=
//                     'Yes')
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: isSwitchNote,
//                         onChanged: (value) {
//                           isSwitchNote = !isSwitchNote;
//                           restaurantController.update();
//                         },
//                       ),
//                       Text(
//                         'Switch Notes',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 11, color: Colors.black),
//                         textAlign: TextAlign.start,
//                       ),
//                     ],
//                   ),
//                 SizedBox(height: 10),
//                 CustomButton(
//                   width: Get.width / 2.0,
//                   buttonText: 'Transfer To Table',
//                   onPressed: () async {
//                     Map<String, dynamic> jsonData = {
//                       'source_order_id': orderDetail.id,
//                       'target_order_id': selectedOrderId,
//                       'transfer_note': isSwitchNote ? 'Yes' : 'No'
//                     };
//                     Get.find<KdsController>().mergeTable(jsonData,
//                         (bool isSucces) {
//                       if (isSucces) {
//                         //   order.tableId = tableIdSelect.id;
//                         //   order.restaurantTable = RestaurantTable(
//                         //       id: tableIdSelect.id,
//                         //       rtype: tableIdSelect.type,
//                         //       tableNo: tableIdSelect.tableNo,
//                         //       title: tableIdSelect.title);
//                         if (Get.isBottomSheetOpen ?? false) Get.back();
//                         //   Get.find<KdsController>().update();

//                         // } else {
//                       }
//                     },
//                         name:
//                             "${order!.restaurantTable == null || order!.restaurantTable!.tableNo == '' ? order!.orderType == 'delivery' ? 'Delivery' : order!.orderType == 'take_away' ? 'Take Away' : order!.userName != 'Mygenie' && order!.userName != '' ? order!.userName : 'WC' : order!.restaurantTable!.title == '' ? '#${order!.restaurantTable!.tableNo}' : '#${order!.restaurantTable!.title}-${order!.restaurantTable!.tableNo}'} is merged in $selectedTableName successfully");
//                     // Get.back();
//                   },
//                 ),
//               ],
//             ),
//           ]);
//         }),
//       ),
//     );
//   }

//   Widget assignDeliveryBoy(BuildContext context, OrderList orderDetail) {
//     int? selectedOrderId;
//     String? selectedTableName;
//     List<GetDeliveryBoyList> dmList = [];
//     // bool isSwitchNote = false;
//     dmList = Get.find<DeliveryManController>().deliveryManList;
//     return SafeArea(
//       child: Container(
//         height: Get.height * 0.6,
//         padding: EdgeInsets.only(
//             left: 25,
//             right: 25,
//             top: 25,
//             bottom: Dimensions.PADDING_SIZE_DEFAULT),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(
//               top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
//         ),
//         child: GetBuilder(builder: (DeliveryManController dmController) {
//           return Column(mainAxisSize: MainAxisSize.min, children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Select Delivery Partner',
//                   style: poppinsMedium.copyWith(
//                     color: Colors.black,
//                     fontSize: 17,
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: InkWell(
//                       onTap: () {
//                         searchOrder!.clear();
//                         FocusManager.instance.primaryFocus?.unfocus();

//                         Get.back();
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 30,
//                         color: ColorTheme.appColor,
//                       )),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Divider(color: ColorTheme.borderGrey),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Container(
//                 height: 40,
//                 child: TextField(
//                   controller: searchTable,
//                   textInputAction: TextInputAction.search,
//                   autofocus: false,
//                   textCapitalization: TextCapitalization.words,
//                   keyboardType: TextInputType.name,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(
//                         horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//                     suffixIcon: Icon(
//                       Icons.search,
//                       color: ColorTheme.appColor,
//                       size: 25,
//                     ),
//                     hintText: 'Search',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(7),
//                       borderSide: BorderSide(color: ColorTheme.borderGrey),
//                     ),
//                     hintStyle: poppinsMedium.copyWith(
//                         fontSize: 13, color: ColorTheme.hintText),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   style: poppinsMedium.copyWith(
//                     fontSize: 13,
//                   ),
//                   onChanged: (value) async {
//                     if (searchTable!.text.isNotEmpty) {
//                       dmList = dmController.deliveryManList
//                           .where((item) => (item.fName
//                               .toLowerCase()
//                               .contains(searchTable!.text.toLowerCase())))
//                           .toList();
//                     } else {
//                       dmList = dmController.deliveryManList;
//                     }
//                     dmController.update();
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 15),
//                       child: GridView.builder(
//                         physics: NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: dmList.length ?? 0,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisSpacing: 7,
//                             childAspectRatio: 2.5,
//                             mainAxisSpacing: 7,
//                             crossAxisCount: 3),
//                         itemBuilder: (BuildContext context, int index) {
//                           GetDeliveryBoyList boy = dmList[index];
//                           return InkWell(
//                               onTap: () {
//                                 searchOrder!.clear();
//                                 // tableIndex = index;
//                                 FocusManager.instance.primaryFocus?.unfocus();

//                                 selectedOrderId = boy.id!;
//                                 selectedTableName = boy.fName;

//                                 // selectedTableName = order.restaurantTable ==
//                                 //             null ||
//                                 //         order.restaurantTable.tableNo == ''
//                                 //     ? order?.orderType == 'delivery'
//                                 //         ? 'Delivery'
//                                 //         : order?.orderType == 'take_away'
//                                 //             ? 'Take Away'
//                                 //             : order.userName != 'Mygenie' &&
//                                 //                     order.userName != ''
//                                 //                 ? order.userName
//                                 //                 : 'WC'
//                                 //     : order.restaurantTable.title == ''
//                                 //         ? '${order.restaurantTable.tableNo}'
//                                 //         : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}';

//                                 dmController.update();
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 10),
//                                 decoration: BoxDecoration(
//                                     color: selectedOrderId == boy.id
//                                         ? ColorTheme.appColor
//                                         : ColorTheme.tableBoxGrey,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                         color: selectedOrderId == boy.id
//                                             ? ColorTheme.appColor
//                                             : ColorTheme.borderGrey)),
//                                 child: Center(
//                                   child: Text(boy.fName ?? '',
//                                       style: poppinsMedium.copyWith(
//                                           fontSize: 10,
//                                           color: selectedOrderId == boy.id
//                                               ? Colors.white
//                                               : ColorTheme.hintText)),
//                                   // child: Text('${order.restaurantOrderId}',
//                                   //     style: poppinsMedium.copyWith(
//                                   //         fontSize: 10,
//                                   //         color: selectedOrderId == order.id
//                                   //             ? Colors.white
//                                   //             : ColorTheme.hintText)),
//                                 ),
//                               ));
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomButton(
//                   width: Get.width / 2.0,
//                   buttonText: 'Select Runner',
//                   onPressed: () async {
//                     Map<String, dynamic> jsonData = {
//                       'order_id': orderDetail.id,
//                       'delivery_man_id': selectedOrderId,
//                     };
//                     dmController.assignDeliveryMan(jsonData, (bool isSucces) {
//                       if (isSucces) {
//                         order!.deliveryMan = selectedTableName ?? '';

//                         //   order.tableId = tableIdSelect.id;
//                         //   order.restaurantTable = RestaurantTable(
//                         //       id: tableIdSelect.id,
//                         //       rtype: tableIdSelect.type,
//                         //       tableNo: tableIdSelect.tableNo,
//                         //       title: tableIdSelect.title);
//                         Get.find<KdsController>().update();
//                         if (Get.isBottomSheetOpen ?? false) Get.back();

//                         // } else {
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ]);
//         }),
//       ),
//     );
//   }
// }

// Widget whatsAppBottomSheet(BuildContext context, {required OrderList order}) {
//   Get.find<CartController>().getCustomerFromApi();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final posController = Get.find<PosController>();
//   double orderDiscount = 0;
//   double coummunityDiscount = 0;
//   double coummunityDiscountPercentage = 0;
//   double serviceChargePercentage = 10.0;
//   double orderSubTotal = 0;
//   double gstAmount = 0;
//   double vatAmount = 0;
//   String selectedDiscountType = 'Fixed';
//   List<String> discountType = ['No', 'Percent', 'Fixed'];
//   final TextEditingController _discountController = TextEditingController();
//   final TextEditingController _addTips = TextEditingController();
//   double roomTotalPaymnet = 0;
//   double showServiceChargeValue = 0;
//   double discountedOrderSubTotal = 0;

//   // Pre-fill customer details based on the order object
//   if (order.userName.isNotEmpty) {
//     _nameController.text = order.userName;
//   } else if (order.deliveryAddress?.contactPersonName != null &&
//       order.deliveryAddress!.contactPersonName!.isNotEmpty) {
//     _nameController.text = order.deliveryAddress!.contactPersonName!;
//   } else if (order.user?.fName != null && order.user!.fName!.isNotEmpty) {
//     _nameController.text = order.user!.fName!;
//   }

//   if (order.deliveryAddress?.contactPersonNumber != null &&
//       order.deliveryAddress!.contactPersonNumber!.isNotEmpty) {
//     _phoneController.text = order.deliveryAddress!.contactPersonNumber!;
//   } else if (order.user?.phone != null && order.user!.phone!.isNotEmpty) {
//     _phoneController.text = order.user!.phone!;
//   }

//   // Initialize service charge based on order type
//   if (Get.find<PosController>()
//               .getCollectBillDetailResponse
//               ?.orders
//               ?.orderDetailsOrder
//               ?.orderType ==
//           'delivery' ||
//       Get.find<PosController>()
//               .getCollectBillDetailResponse
//               ?.orders
//               ?.orderDetailsOrder
//               ?.orderType ==
//           'take_away') {
//     serviceChargePercentage = 0;
//   }

//   // Calculate room total payment
//   if (Get.find<PosController>().roomBillsList.isNotEmpty) {
//     for (var e in Get.find<PosController>().roomBillsList) {
//       roomTotalPaymnet += double.tryParse(e.orderAmount ?? '0') ?? 0.0;
//     }
//   }

//   Future<void> amountCalculation() async {
//     orderSubTotal = 0;
//     discountedOrderSubTotal = 0;
//     orderDiscount = 0;
//     gstAmount = 0;
//     vatAmount = 0;
//     showServiceChargeValue = 0;
//     double gstTypeFood = 0;
//     double vatTypeFood = 0;

//     // Use Restaurant from profile_model.dart
//     profile_model.Restaurant? restaurant =
//         Get.find<AuthController>().profileModel?.restaurants?.isNotEmpty == true
//             ? Get.find<AuthController>().profileModel!.restaurants!.first
//             : null;

//     if (restaurant == null) {
//       print('Error: No restaurant found in profileModel');
//       showErrorToast('Restaurant data unavailable');
//       if (order.orderAmount != null &&
//           double.tryParse(order.orderAmount!) != null) {
//         orderSubTotal = double.parse(order.orderAmount!);
//         discountedOrderSubTotal = orderSubTotal;
//         print(
//             'Fallback: Using order.orderAmount as orderSubTotal: $orderSubTotal');
//       }
//       return;
//     }

//     // Ensure bill details are fetched
//     await Get.find<PosController>()
//         .getCollectBillDetail({'order_id': '${order.id}'});
//     final billDetailResponse =
//         Get.find<PosController>().getCollectBillDetailResponse;
//     final orders = billDetailResponse?.orders;
//     final mergeFoodList = orders?.mergeFoodList ?? [];

//     // print('mergeFoodList length: ${mergeFoodList.length}');
//     // print('mergeFoodList: $mergeFoodList');
//     // print('Order Amount from order object: ${order.orderAmount}');

//     if (billDetailResponse == null || orders == null || mergeFoodList.isEmpty) {
//       // print('Error: Bill details or mergeFoodList is empty');
//       showErrorToast('Failed to load order details');
//       if (order.orderAmount != null &&
//           double.tryParse(order.orderAmount!) != null) {
//         orderSubTotal = double.parse(order.orderAmount!);
//         discountedOrderSubTotal = orderSubTotal;
//         // print(
//         //     'Fallback: Using order.orderAmount as orderSubTotal: $orderSubTotal');
//       }
//       return;
//     }

//     if (selectedDiscountType == 'Percent' &&
//         _discountController.text.isNotEmpty &&
//         double.parse(_discountController.text) > 100) {
//       showErrorToast('Please enter valid discount');
//       return;
//     }

//     for (var i = 0; i < mergeFoodList.length; i++) {
//       bill_model.OrderDetailsBar food = mergeFoodList[i];
//       double variationTotal = 0;
//       double addonsTotal = 0;
//       double foodAmount = 0;
//       double halfVariationPrice = 0;

//       // print('Food $i: unitPrice=${food.unitPrice}, quantity=${food.quantity}');

//       if (food.variation != null && food.variation!.isNotEmpty) {
//         for (int j = 0; j < food.variation!.length; j++) {
//           final variation = food.variation![j];
//           if (variation.values != null) {
//             for (var element in variation.values!) {
//               if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
//                 if (halfVariationPrice <
//                     double.parse(element.optionPrice ?? '0') *
//                         (food.quantity ?? 0)) {
//                   halfVariationPrice =
//                       double.parse(element.optionPrice ?? '0') *
//                           (food.quantity ?? 0);
//                 }
//               } else {
//                 variationTotal += double.parse(element.optionPrice ?? '0') *
//                     (food.quantity ?? 0);
//               }
//             }
//           }
//           variationTotal += halfVariationPrice;
//         }
//       }

//       if (food.addOns != null) {
//         for (var addOn in food.addOns!) {
//           addonsTotal += ((addOn.price ?? 0) * (addOn.quantity ?? 0)) *
//               (food.quantity ?? 0);
//         }
//       }

//       foodAmount = (food.unitPrice ?? 0) * (food.quantity ?? 0) +
//           variationTotal +
//           addonsTotal;
//       orderSubTotal += foodAmount;
//       // print(
//       //     'Food $i Amount: $foodAmount, Running orderSubTotal: $orderSubTotal');

//       if (selectedDiscountType == 'Percent') {
//         double tempDiscountPercent = _discountController.text.isEmpty
//             ? 0
//             : double.parse(_discountController.text);
//         double tempAmount = 0;
//         if ((food.foodDetails?['give_discount']?.toString() ?? '') == 'Yes') {
//           tempAmount = foodAmount -
//               (foodAmount *
//                   (coummunityDiscountPercentage + tempDiscountPercent) /
//                   100);
//           orderDiscount += (foodAmount *
//               (coummunityDiscountPercentage + tempDiscountPercent) /
//               100);
//         } else {
//           tempAmount = foodAmount;
//         }
//         if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST' &&
//             restaurant.gstStatus == 'true') {
//           gstAmount += (tempAmount *
//                   double.parse(food.foodDetails?['tax']?.toString() ?? '0')) /
//               100;
//         } else if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'VAT' &&
//             Get.find<AuthController>().profileModel?.vatInfo?.status ==
//                 'true') {
//           vatAmount += (tempAmount *
//                   double.parse(food.foodDetails?['tax']?.toString() ?? '0')) /
//               100;
//         }
//         discountedOrderSubTotal += tempAmount;
//       } else {
//         if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST') {
//           gstTypeFood += foodAmount;
//         } else if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'VAT') {
//           vatTypeFood += foodAmount;
//         }
//       }
//     }

//     if (selectedDiscountType == 'No' || selectedDiscountType == 'Fixed') {
//       double tempDiscountPercent = _discountController.text.isEmpty
//           ? 0
//           : ((double.parse(_discountController.text) /
//                   (gstTypeFood + vatTypeFood)) *
//               100);
//       double tempBarAmount =
//           vatTypeFood - ((vatTypeFood * tempDiscountPercent) / 100);
//       double tempFoodAmount =
//           gstTypeFood - ((gstTypeFood * tempDiscountPercent) / 100);
//       orderDiscount = ((gstTypeFood * tempDiscountPercent) / 100) +
//           ((vatTypeFood * tempDiscountPercent) / 100);
//       discountedOrderSubTotal = tempBarAmount + tempFoodAmount;

//       if (restaurant.gstStatus == 'true') {
//         gstAmount += (tempFoodAmount *
//                 (double.tryParse(restaurant.gstTax.toString()) ?? 0)) /
//             100;
//       }
//       if (Get.find<AuthController>().profileModel?.vatInfo?.status == 'true') {
//         vatAmount += (tempBarAmount * (restaurant.tax ?? 0)) / 100;
//       }
//     }

//     if (discountedOrderSubTotal >= 0) {
//       if (Get.find<PosController>().isAddServiceCharge) {
//         double serviceChargeGST = 0;

//         showServiceChargeValue =
//             (discountedOrderSubTotal * serviceChargePercentage) / 100;
//         if (restaurant.gstStatus == 'true') {
//           serviceChargeGST =
//               (restaurant.gstTax! * showServiceChargeValue) / 100;
//           // showServiceChargeValue = serviceChargeGST;
//           showServiceChargeValue += serviceChargeGST;
//           //  print('Service Charge GST: $showServiceChargeValue');
//         }
//         Get.find<PosController>().setcollectItemPrice(
//             ((Get.find<PosController>()
//                         .getCollectBillDetailResponse
//                         ?.orders
//                         ?.roomInfo
//                         ?.gstTaxAmount) ??
//                     0) +
//                 discountedOrderSubTotal +
//                 showServiceChargeValue +
//                 gstAmount +
//                 vatAmount +
//                 (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
//       } else {
//         Get.find<PosController>().setcollectItemPrice(
//             ((Get.find<PosController>()
//                         .getCollectBillDetailResponse
//                         ?.orders
//                         ?.roomInfo
//                         ?.gstTaxAmount) ??
//                     0) +
//                 discountedOrderSubTotal +
//                 gstAmount +
//                 vatAmount +
//                 (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
//       }
//     } else {
//       showErrorToast('Please enter valid discount');
//     }

//     // print(
//     //     'Final orderSubTotal: $orderSubTotal, discountedOrderSubTotal: $discountedOrderSubTotal');
//   }

//   return GetBuilder<CartController>(
//     initState: (_) async {
//       // Ensure bill details are fetched before rendering
//       await Get.find<PosController>()
//           .getCollectBillDetail({'order_id': '${order.id}'});
//       await amountCalculation();
//       Get.find<CartController>().update();
//     },
//     builder: (cartController) {
//       return cartController.isLoading
//           ? CircularProgressIndicator()
//           : Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
//                 ),
//                 color: Colors.white,
//               ),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   left: 25,
//                   right: 25,
//                   top: 25,
//                   bottom: Dimensions.PADDING_SIZE_DEFAULT,
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               'WhatsApp Bill',
//                               style: poppinsMedium.copyWith(
//                                 color: Colors.black,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: InkWell(
//                               onTap: () {
//                                 Get.back();
//                               },
//                               child: Icon(
//                                 Icons.close,
//                                 size: 30,
//                                 color: ColorTheme.appColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Divider(color: ColorTheme.borderGrey),
//                       ),
//                       SizedBox(height: 10),
//                       cartController.customerList == null
//                           ? TextField(
//                               controller: _nameController,
//                               autofocus: false,
//                               textCapitalization: TextCapitalization.words,
//                               decoration: InputDecoration(
//                                 hintText: 'Name',
//                                 contentPadding: EdgeInsets.symmetric(
//                                     vertical: 0, horizontal: 15),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(7),
//                                   borderSide:
//                                       BorderSide(color: ColorTheme.borderGrey),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(7),
//                                   borderSide:
//                                       BorderSide(color: ColorTheme.borderGrey),
//                                 ),
//                                 disabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(7),
//                                   borderSide:
//                                       BorderSide(color: ColorTheme.borderGrey),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(7),
//                                   borderSide:
//                                       BorderSide(color: ColorTheme.borderGrey),
//                                 ),
//                                 hintStyle: poppinsMedium.copyWith(
//                                     fontSize: 13, color: ColorTheme.hintText),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                               ),
//                               style: poppinsMedium.copyWith(
//                                 color: Colors.black,
//                                 fontSize: 13,
//                               ),
//                             )
//                           : TypeAheadField(
//                               getImmediateSuggestions: true,
//                               textFieldConfiguration: TextFieldConfiguration(
//                                 controller: _nameController,
//                                 textInputAction: TextInputAction.search,
//                                 autofocus: false,
//                                 textCapitalization: TextCapitalization.words,
//                                 keyboardType: TextInputType.name,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(
//                                       vertical: 0, horizontal: 15),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         Dimensions.RADIUS_SMALL),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         Dimensions.RADIUS_SMALL),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   disabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         Dimensions.RADIUS_SMALL),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         Dimensions.RADIUS_SMALL),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   hintStyle: poppinsMedium.copyWith(
//                                       fontSize: 13, color: Colors.grey),
//                                   hintText: 'Name',
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                 ),
//                                 style: poppinsMedium.copyWith(
//                                   color: Colors.black,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               noItemsFoundBuilder: (context) =>
//                                   SizedBox.shrink(),
//                               suggestionsCallback: (pattern) async {
//                                 return cartController.customerList!.customerList
//                                     .where((item) =>
//                                         item.customerName != '' &&
//                                         item.customerName
//                                             .toString()
//                                             .trim()
//                                             .toLowerCase()
//                                             .contains(
//                                                 pattern.toLowerCase().trim()))
//                                     .toList();
//                               },
//                               itemBuilder: (context, CustomerList suggestion) {
//                                 return Padding(
//                                   padding: EdgeInsets.all(
//                                       Dimensions.PADDING_SIZE_SMALL),
//                                   child: Row(children: [
//                                     SizedBox(
//                                         width: Dimensions.PADDING_SIZE_SMALL),
//                                     Expanded(
//                                       child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                                 '${suggestion.customerName ?? ''}',
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: poppinsRegular.copyWith(
//                                                   color: Theme.of(context)
//                                                       .textTheme
//                                                       .bodyLarge!
//                                                       .color,
//                                                   fontSize: Dimensions
//                                                       .FONT_SIZE_SMALL,
//                                                 )),
//                                           ]),
//                                     ),
//                                   ]),
//                                 );
//                               },
//                               onSuggestionSelected: (CustomerList suggestion) {
//                                 _phoneController.text =
//                                     suggestion.phone.toString();
//                                 _nameController.text = suggestion.customerName;
//                               },
//                             ),
//                       SizedBox(height: 15),
//                       Container(
//                         height: 40,
//                         child: cartController.customerList == null
//                             ? TextField(
//                                 controller: _phoneController,
//                                 textInputAction: TextInputAction.search,
//                                 autofocus: false,
//                                 textCapitalization: TextCapitalization.words,
//                                 keyboardType: TextInputType.numberWithOptions(
//                                     signed: true),
//                                 inputFormatters: <TextInputFormatter>[
//                                   FilteringTextInputFormatter.allow(
//                                       RegExp("[0-9,+]")),
//                                 ],
//                                 decoration: InputDecoration(
//                                   hintText: 'Mobile Number',
//                                   contentPadding: EdgeInsets.symmetric(
//                                       vertical: 0, horizontal: 15),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(7),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(7),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   disabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(7),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(7),
//                                     borderSide: BorderSide(
//                                         color: ColorTheme.borderGrey),
//                                   ),
//                                   hintStyle: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                 ),
//                                 onChanged: (String d) async {
//                                   if (_phoneController.text.isNotEmpty &&
//                                       GetUtils.isPhoneNumber(
//                                           _phoneController.text)) {
//                                     List<SearchCustomerResponseModel>
//                                         searchData =
//                                         await Get.find<CartController>()
//                                             .searchWaiterPOSCustomer(
//                                                 _phoneController.text);
//                                     if (searchData.isNotEmpty &&
//                                         searchData.first.id != 'false') {
//                                       if (searchData.first.name != '')
//                                         _nameController.text =
//                                             searchData.first.name;
//                                     }
//                                   }
//                                 },
//                                 style: poppinsMedium.copyWith(
//                                   color: Colors.black,
//                                   fontSize: 13,
//                                 ),
//                               )
//                             : TypeAheadField(
//                                 getImmediateSuggestions: true,
//                                 textFieldConfiguration: TextFieldConfiguration(
//                                   controller: _phoneController,
//                                   textInputAction: TextInputAction.search,
//                                   autofocus: false,
//                                   textCapitalization: TextCapitalization.words,
//                                   keyboardType: TextInputType.numberWithOptions(
//                                       signed: true),
//                                   inputFormatters: <TextInputFormatter>[
//                                     FilteringTextInputFormatter.allow(
//                                         RegExp("[0-9,+]")),
//                                   ],
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.symmetric(
//                                         vertical: 0, horizontal: 15),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.RADIUS_SMALL),
//                                       borderSide: BorderSide(
//                                           color: ColorTheme.borderGrey),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.RADIUS_SMALL),
//                                       borderSide: BorderSide(
//                                           color: ColorTheme.borderGrey),
//                                     ),
//                                     disabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.RADIUS_SMALL),
//                                       borderSide: BorderSide(
//                                           color: ColorTheme.borderGrey),
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.RADIUS_SMALL),
//                                       borderSide: BorderSide(
//                                           color: ColorTheme.borderGrey),
//                                     ),
//                                     hintStyle: poppinsMedium.copyWith(
//                                         fontSize: 13, color: Colors.grey),
//                                     hintText: 'Phone Number',
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                   ),
//                                   style: poppinsMedium.copyWith(
//                                     color: Colors.black,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 noItemsFoundBuilder: (context) =>
//                                     SizedBox.shrink(),
//                                 suggestionsCallback: (pattern) async {
//                                   return cartController
//                                       .customerList!.customerList
//                                       .where((item) =>
//                                           item.phone != '' &&
//                                           item.phone
//                                               .toString()
//                                               .trim()
//                                               .toLowerCase()
//                                               .contains(
//                                                   pattern.toLowerCase().trim()))
//                                       .toList();
//                                 },
//                                 itemBuilder:
//                                     (context, CustomerList suggestion) {
//                                   return Padding(
//                                     padding: EdgeInsets.all(
//                                         Dimensions.PADDING_SIZE_SMALL),
//                                     child: Row(children: [
//                                       SizedBox(
//                                           width: Dimensions.PADDING_SIZE_SMALL),
//                                       Expanded(
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text('${suggestion.phone ?? ''}',
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style:
//                                                       poppinsRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyLarge!
//                                                         .color,
//                                                     fontSize: Dimensions
//                                                         .FONT_SIZE_SMALL,
//                                                   )),
//                                             ]),
//                                       ),
//                                     ]),
//                                   );
//                                 },
//                                 onSuggestionSelected:
//                                     (CustomerList suggestion) {
//                                   _phoneController.text =
//                                       suggestion.phone.toString();
//                                   _nameController.text =
//                                       suggestion.customerName;
//                                 },
//                               ),
//                       ),
//                       SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: InkWell(
//                           onTap: () async {
//                             if (_nameController.text.isEmpty) {
//                               showErrorToast('Please enter customer name');
//                             } else if (_phoneController.text.isEmpty ||
//                                 !GetUtils.isPhoneNumber(
//                                     _phoneController.text)) {
//                               showErrorToast('Please enter valid phone number');
//                             } else {
//                               await amountCalculation();
//                               var tempAmount = (posController.collectItemPrice +
//                                   ((Get.find<PosController>()
//                                           .getCollectBillDetailResponse
//                                           ?.orders
//                                           ?.roomInfo
//                                           ?.remainingPay ??
//                                       0)) +
//                                   posController
//                                       .getCollectBillDetailResponse!
//                                       .orders!
//                                       .orderDetailsOrder!
//                                       .deliveryCharge! +
//                                   roomTotalPaymnet);
//                               final data = {
//                                 "payment_amount": Get.find<AuthController>()
//                                             .profileModel!
//                                             .restaurants!
//                                             .first
//                                             .isTotalRound ==
//                                         'Yes'
//                                     ? tempAmount.ceil()
//                                     : tempAmount,
//                                 "grant_amount": Get.find<AuthController>()
//                                             .profileModel!
//                                             .restaurants!
//                                             .first
//                                             .isTotalRound ==
//                                         'Yes'
//                                     ? tempAmount.ceil()
//                                     : tempAmount,
//                                 "vat_tax": vatAmount,
//                                 "gst_tax": gstAmount,
//                                 "self_discount": 0.0,
//                                 "comm_discount": coummunityDiscount,
//                                 "tip_amount": _addTips.text.isEmpty
//                                     ? 0
//                                     : double.parse(_addTips.text),
//                                 "order_discount": orderDiscount,
//                                 "mobile": _phoneController.text,
//                                 "name": _nameController.text,
//                                 "restaurant_name": order.orderDetails?.first
//                                     .foodDetails?.restaurantName,
//                                 "service_tax": showServiceChargeValue,
//                                 "order_id": order.id
//                               };
//                               cartController.whatsappBill(data);
//                               Get.back();
//                             }
//                           },
//                           child: Container(
//                             height: 35,
//                             width: 110,
//                             decoration: BoxDecoration(
//                               color: ColorTheme.appColor,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Submit',
//                                 style: poppinsMedium.copyWith(
//                                   fontSize:
//                                       MediaQuery.of(context).size.width > 1600
//                                           ? 18
//                                           : 14,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//     },
//   );
// }
