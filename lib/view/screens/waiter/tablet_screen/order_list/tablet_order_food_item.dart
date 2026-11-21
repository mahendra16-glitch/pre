// import 'package:dotted_line/dotted_line.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
// import 'package:mygenie_restaurant/view/base/food_item_action_button.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/home/widget/cancel_order_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../../../../controller/cart_controller.dart';
// import '../../../../../controller/loader_contoller.dart';
// import '../../../../../controller/product_controller.dart';
// import '../../../../../data/model/response/cart_model.dart';
// import '../../../../../data/model/response/product_model.dart';
// import '../../../../base/custom_button.dart';
// import '../../../../base/custom_snackbar.dart';
// import '../../home/widget/edit_food_dialog.dart';

// class TabletWaiterOrderFoodItem extends StatelessWidget {
//   final List<OrderDetails>? orderItemList;
//   final OrderList? order;
//   final bool? isWaiter;
//   TextEditingController searchOrder;
//   final FlutterTts? flutterTts;
//   final bool? isPending;
//   TabletWaiterOrderFoodItem(
//       {Key? key,
//       this.orderItemList,
//       this.order,
//       this.isWaiter,
//       required this.searchOrder,
//       this.flutterTts,
//       this.isPending})
//       : super(key: key);
//   final TextEditingController cancelReason = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return buildWithOptionalExpanded(
//       useExpanded: Get.find<AuthController>()
//               .profileModel!
//               .restaurants!
//               .first
//               .listServeItem ==
//           'Fixed',
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             ListView.builder(
//                 physics: NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 padding: EdgeInsets.zero,
//                 itemCount: orderItemList!.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   String variationText = '';
//                   if (orderItemList![index].variation != null &&
//                       orderItemList![index].variation!.isNotEmpty &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .foodWithVariance ==
//                           'Yes') {
//                     variationText += '';
//                     List<String> labelList = [];

//                     for (int j = 0;
//                         j < orderItemList![index].variation!.length;
//                         j++) {
//                       if (orderItemList![index].variation![j].values != null) {
//                         for (var element
//                             in orderItemList![index].variation![j].values!) {
//                           labelList.add(element.level!);
//                         }
//                       }
//                     }
//                     variationText += '${labelList.join(',')}';
//                     variationText += '';
//                   } else if (orderItemList![index].variation != null &&
//                       orderItemList![index].variation!.isNotEmpty &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .foodWithVariance !=
//                           'Yes') {
//                     for (int j = 0;
//                         j < orderItemList![index].variation!.length;
//                         j++) {
//                       variationText +=
//                           '${variationText.isNotEmpty ? ', ' : ''}${orderItemList![index].variation![j].name} (';

//                       if (orderItemList![index].variation![j].values != null) {
//                         List<String> labelList = [];
//                         for (var element
//                             in orderItemList![index].variation![j].values!) {
//                           labelList.add(element.level!);
//                         }
//                         variationText +=
//                             '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//                       }

//                       variationText += '';
//                     }
//                   }
//                   String addons = '';
//                   for (var i = 0;
//                       i < orderItemList![index].addOns!.length;
//                       i++) {
//                     if (addons != '') {
//                       addons += ', ';
//                     }
//                     addons +=
//                         '${orderItemList![index].addOns![i].name} (${orderItemList![index].addOns![i].qty})';
//                   }
//                   return orderItemList![index].foodStatus == 5 &&
//                           Get.find<KdsController>().selectedSubMenu == 1
//                       ? SizedBox.shrink()
//                       : orderItemList![index]
//                                   .foodDetails!
//                                   .name!
//                                   .toUpperCase() ==
//                               'CHECK IN'
//                           ? SizedBox.shrink()
//                           : Stack(
//                               alignment: Alignment.centerLeft,
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Column(
//                                   children: [
//                                     SizedBox(
//                                         height: Dimensions.PADDING_SIZE_SMALL),
//                                     Padding(
//                                       padding:
//                                           EdgeInsets.only(left: 25, right: 17),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 if (Get.find<AuthController>()
//                                                         .profileModel!
//                                                         .restaurants!
//                                                         .first
//                                                         .foodWithVariance ==
//                                                     'Yes')
//                                                   Row(
//                                                     children: [
//                                                       Flexible(
//                                                         child: Text.rich(
//                                                           TextSpan(
//                                                             children: [
//                                                               TextSpan(
//                                                                 text:
//                                                                     '${orderItemList![index].foodDetails!.name ?? ''} (${orderItemList![index].quantity})',
//                                                                 style:
//                                                                     poppinsMedium
//                                                                         .copyWith(
//                                                                   fontSize: 15,
//                                                                   decoration: orderItemList![index]
//                                                                               .isSplited ||
//                                                                           orderItemList![index].foodStatus ==
//                                                                               3
//                                                                       ? TextDecoration
//                                                                           .lineThrough
//                                                                       : TextDecoration
//                                                                           .none,
//                                                                   color: orderItemList![index]
//                                                                               .isSplited ||
//                                                                           orderItemList![index].foodStatus ==
//                                                                               3
//                                                                       ? ColorTheme
//                                                                           .disableButtonText
//                                                                       : Colors
//                                                                           .black,
//                                                                 ),
//                                                               ),
//                                                               TextSpan(
//                                                                 text:
//                                                                     ' $variationText',
//                                                                 style:
//                                                                     poppinsMedium
//                                                                         .copyWith(
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   fontSize: 11,
//                                                                   decoration: orderItemList![
//                                                                               index]
//                                                                           .isSplited
//                                                                       ? TextDecoration
//                                                                           .lineThrough
//                                                                       : TextDecoration
//                                                                           .none,
//                                                                   color: orderItemList![
//                                                                               index]
//                                                                           .isSplited
//                                                                       ? Colors
//                                                                           .grey
//                                                                       : ColorTheme
//                                                                           .green,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       if (order!.paymentType !=
//                                                           'prepaid')
//                                                         InkWell(
//                                                           onTap: () async {
//                                                             await editProduct(
//                                                                 foodOrderDetail:
//                                                                     order!.orderDetails![
//                                                                         index],
//                                                                 addons: addons,
//                                                                 index: index,
//                                                                 variationText:
//                                                                     variationText);
//                                                           },
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     left: 5),
//                                                             child: Icon(
//                                                                 Icons.edit,
//                                                                 color: ColorTheme
//                                                                     .appColor,
//                                                                 size: 20),
//                                                           ),
//                                                         )
//                                                     ],
//                                                   ),

//                                                 if (Get.find<AuthController>()
//                                                         .profileModel!
//                                                         .restaurants!
//                                                         .first
//                                                         .foodWithVariance !=
//                                                     'Yes')
//                                                   Row(
//                                                     children: [
//                                                       Flexible(
//                                                         child: Text(
//                                                           '${orderItemList![index].foodDetails!.name ?? ''} (${orderItemList![index].quantity})',
//                                                           style: poppinsSemiBold
//                                                               .copyWith(
//                                                             fontSize: 15,
//                                                             decoration: orderItemList![
//                                                                             index]
//                                                                         .isSplited ||
//                                                                     orderItemList![
//                                                                                 index]
//                                                                             .foodStatus ==
//                                                                         3
//                                                                 ? TextDecoration
//                                                                     .lineThrough
//                                                                 : TextDecoration
//                                                                     .none,
//                                                             color: orderItemList![
//                                                                             index]
//                                                                         .isSplited ||
//                                                                     orderItemList![index]
//                                                                             .foodStatus ==
//                                                                         3
//                                                                 ? ColorTheme
//                                                                     .disableButtonText
//                                                                 : Colors.black,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       if (order!.paymentType !=
//                                                           'prepaid')
//                                                         InkWell(
//                                                           onTap: () async {
//                                                             await editProduct(
//                                                                 foodOrderDetail:
//                                                                     order!.orderDetails![
//                                                                         index],
//                                                                 addons: addons,
//                                                                 index: index,
//                                                                 variationText:
//                                                                     variationText);
//                                                           },
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     left: 5),
//                                                             child: Icon(
//                                                                 Icons.edit,
//                                                                 color: ColorTheme
//                                                                     .appColor,
//                                                                 size: 20),
//                                                           ),
//                                                         )
//                                                     ],
//                                                   ),
//                                                 addons == ''
//                                                     ? SizedBox.shrink()
//                                                     : Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(top: 4),
//                                                         child: Text.rich(
//                                                           TextSpan(
//                                                             children: [
//                                                               TextSpan(
//                                                                 text:
//                                                                     'Add-Ons :',
//                                                                 style: poppinsMedium.copyWith(
//                                                                     fontSize:
//                                                                         11,
//                                                                     decoration: orderItemList![
//                                                                                 index]
//                                                                             .isSplited
//                                                                         ? TextDecoration
//                                                                             .lineThrough
//                                                                         : TextDecoration
//                                                                             .none,
//                                                                     color: orderItemList![
//                                                                                 index]
//                                                                             .isSplited
//                                                                         ? Colors
//                                                                             .grey
//                                                                         : ColorTheme
//                                                                             .kdsLeftMenuBlue),
//                                                               ),
//                                                               TextSpan(
//                                                                 text:
//                                                                     ' $addons',
//                                                                 style:
//                                                                     poppinsMedium
//                                                                         .copyWith(
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   fontSize: 11,
//                                                                   decoration: orderItemList![
//                                                                               index]
//                                                                           .isSplited
//                                                                       ? TextDecoration
//                                                                           .lineThrough
//                                                                       : TextDecoration
//                                                                           .none,
//                                                                   color: orderItemList![
//                                                                               index]
//                                                                           .isSplited
//                                                                       ? Colors
//                                                                           .grey
//                                                                       : ColorTheme
//                                                                           .green,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                 if (Get.find<AuthController>()
//                                                         .profileModel!
//                                                         .restaurants!
//                                                         .first
//                                                         .foodWithVariance !=
//                                                     'Yes')
//                                                   variationText == ''
//                                                       ? SizedBox.shrink()
//                                                       : Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(top: 4),
//                                                           child: Text.rich(
//                                                             TextSpan(
//                                                               children: [
//                                                                 TextSpan(
//                                                                   text:
//                                                                       'Variants  :',
//                                                                   style: poppinsMedium.copyWith(
//                                                                       fontSize:
//                                                                           11,
//                                                                       decoration: orderItemList![index].isSplited
//                                                                           ? TextDecoration
//                                                                               .lineThrough
//                                                                           : TextDecoration
//                                                                               .none,
//                                                                       color: orderItemList![index].isSplited
//                                                                           ? Colors
//                                                                               .grey
//                                                                           : ColorTheme
//                                                                               .blue),
//                                                                 ),
//                                                                 TextSpan(
//                                                                   text:
//                                                                       ' $variationText',
//                                                                   style: poppinsMedium.copyWith(
//                                                                       fontSize:
//                                                                           11,
//                                                                       decoration: orderItemList![index].isSplited
//                                                                           ? TextDecoration
//                                                                               .lineThrough
//                                                                           : TextDecoration
//                                                                               .none,
//                                                                       color: orderItemList![index].isSplited
//                                                                           ? Colors
//                                                                               .grey
//                                                                           : ColorTheme
//                                                                               .green),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                 orderItemList![index]
//                                                             .foodLevelNotes ==
//                                                         ''
//                                                     ? SizedBox.shrink()
//                                                     : Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(top: 4),
//                                                         child: Text.rich(
//                                                           TextSpan(
//                                                             children: [
//                                                               TextSpan(
//                                                                 text:
//                                                                     'Notes  :',
//                                                                 style: poppinsMedium
//                                                                     .copyWith(
//                                                                         fontSize:
//                                                                             11,
//                                                                         color: ColorTheme
//                                                                             .blue),
//                                                               ),
//                                                               TextSpan(
//                                                                 text:
//                                                                     ' ${orderItemList![index].foodLevelNotes}',
//                                                                 style: poppinsMedium
//                                                                     .copyWith(
//                                                                         fontSize:
//                                                                             11,
//                                                                         color: ColorTheme
//                                                                             .green),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                 Row(
//                                                   children: [
//                                                     GetBuilder<KdsController>(
//                                                         builder:
//                                                             (kdsController) {
//                                                       String showTime = '';
//                                                       // Duration createTime = DateTime.now().difference(
//                                                       //     DateTime.parse(orderItemList[index].createdAt));

//                                                       if (orderItemList![index]
//                                                               .createdAt !=
//                                                           null)
//                                                         showTime = Jiffy.parse(
//                                                                 orderItemList![
//                                                                         index]
//                                                                     .createdAt!)
//                                                             .fromNow();
//                                                       // Duration readyTime;
//                                                       if (orderItemList![index]
//                                                               .readyAt !=
//                                                           null) {
//                                                         // readyTime = DateTime.now().difference(
//                                                         //     DateTime.parse(orderItemList[index].readyAt));
//                                                         // showTime = '${readyTime.inMinutes}';
//                                                         showTime = Jiffy.parse(
//                                                                 orderItemList![
//                                                                         index]
//                                                                     .readyAt!)
//                                                             .fromNow();
//                                                       }
//                                                       if (orderItemList![index]
//                                                               .serveAt !=
//                                                           null) {
//                                                         // Duration serveTime;

//                                                         // serveTime = DateTime.now().difference(
//                                                         //     DateTime.parse(orderItemList[index].serveAt));
//                                                         // showTime = '${serveTime.inMinutes}';
//                                                         showTime = Jiffy.parse(
//                                                                 orderItemList![
//                                                                         index]
//                                                                     .serveAt!)
//                                                             .fromNow();
//                                                       }

//                                                       return Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(top: 5),
//                                                         child: Align(
//                                                           alignment: Alignment
//                                                               .centerLeft,
//                                                           child: Row(
//                                                             children: [
//                                                               Text(
//                                                                 '$showTime',
//                                                                 style: poppinsMedium
//                                                                     .copyWith(
//                                                                         fontSize:
//                                                                             10,
//                                                                         color: ColorTheme
//                                                                             .hintText),
//                                                               ),
//                                                               /*if (order.orderType != 'delivery' &&
//                                                                   order.orderType !=
//                                                                       'take_away' &&
//                                                                   ((order.restaurantTable != null &&
//                                                                           order.restaurantTable.tableNo !=
//                                                                               '' &&
//                                                                           order.restaurantTable.rtype !=
//                                                                               'RM') ||
//                                                                       order.tableId ==
//                                                                           0))
//                                                                 InkWell(
//                                                                   onTap: () {
//                                                                     Get.bottomSheet(
//                                                                         mergeTable(
//                                                                             context,
//                                                                             orderItemList[index]
//                                                                                 .id
//                                                                                 .toString(),),
//                                                                         backgroundColor:
//                                                                             Colors
//                                                                                 .transparent,
//                                                                         isScrollControlled:
//                                                                             true,
//                                                                         ignoreSafeArea:
//                                                                             false);
//                                                                   },
//                                                                   child:
//                                                                       Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         left:
//                                                                             5),
//                                                                     child: Icon(
//                                                                         Icons
//                                                                             .swipe_right_outlined),
//                                                                   ),
//                                                                 )*/
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }),
//                                                   ],
//                                                 ),
//                                                 // InkWell(
//                                                 //     onTap: () {
//                                                 //       speak(
//                                                 //           '${orderItemList[index].foodDetails.name ?? ''} ${orderItemList[index].quantity}, ${addons == '' ? '' : "Add-Ons' ':''$addons"},  ${variationText == '' ? '' : "Variants  :$variationText"}');
//                                                 //     },
//                                                 //     child: Icon(Icons.play_circle_outline_outlined))
//                                               ],
//                                             ),
//                                           ),
//                                           // Image.asset(Images.ic_theme_show_addOn, height: 30),
//                                           SizedBox(width: 20),
//                                           if (Get.find<AuthController>()
//                                               .profileModel!
//                                               .role!
//                                               .contains('order_cancel'))
//                                             if (order!.paymentType !=
//                                                     'prepaid' &&
//                                                 order!.fOrderStatus != 7 &&
//                                                 ((Get.find<AuthController>()
//                                                             .profileModel!
//                                                             .restaurants!
//                                                             .first
//                                                             .isPreCancel ==
//                                                         'Yes' &&
//                                                     (orderItemList![index]
//                                                                 .foodStatus ==
//                                                             0 ||
//                                                         orderItemList![index]
//                                                                 .foodStatus ==
//                                                             1 ||
//                                                         orderItemList![index]
//                                                                 .foodStatus ==
//                                                             2))))
//                                               InkWell(
//                                                 onTap: () async {
//                                                   // searchController.clear();
//                                                   FocusManager
//                                                       .instance.primaryFocus
//                                                       ?.unfocus();
//                                                   List<int> qtyList = [];
//                                                   for (var i = 0;
//                                                       i <
//                                                           order!
//                                                               .orderDetails![
//                                                                   index]
//                                                               .quantity!;
//                                                       i++) {
//                                                     qtyList.add(i + 1);
//                                                   }
//                                                   await Get.bottomSheet(
//                                                       CancelOrderDialog(
//                                                         qtyList: qtyList,
//                                                         foodStatus: order!
//                                                             .orderDetails![
//                                                                 index]
//                                                             .foodStatus,
//                                                         itemId: order!
//                                                             .orderDetails![
//                                                                 index]
//                                                             .id
//                                                             .toString(),
//                                                         controller:
//                                                             cancelReason,
//                                                         foodId: order!
//                                                             .orderDetails![
//                                                                 index]
//                                                             .foodDetails!
//                                                             .id
//                                                             .toString(),
//                                                         orderId: order!.id
//                                                             .toString(),
//                                                       ),
//                                                       backgroundColor:
//                                                           Colors.transparent,
//                                                       isScrollControlled: true,
//                                                       ignoreSafeArea: false);
//                                                 },
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           right: 15),
//                                                   child: Icon(Icons.close,
//                                                       color:
//                                                           ColorTheme.appColor),
//                                                 ),
//                                               ),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               SizedBox(height: 5),
//                                               if (orderItemList![index]
//                                                       .foodDetails!
//                                                       .name!
//                                                       .toUpperCase() !=
//                                                   'CHECK IN')
//                                                 order!.fOrderStatus == 7
//                                                     ? SizedBox.shrink()
//                                                     : !Get.find<AuthController>()
//                                                             .profileModel!
//                                                             .role!
//                                                             .contains('order')
//                                                         ? FoodButton(
//                                                             isDisable: true,
//                                                             onTap: () {},
//                                                             title: orderItemList![
//                                                                             index]
//                                                                         .foodStatus ==
//                                                                     5
//                                                                 ? 'Served'.tr
//                                                                 : orderItemList![index]
//                                                                             .foodStatus ==
//                                                                         3
//                                                                     ? 'canceled'
//                                                                         .tr
//                                                                     : orderItemList![index].foodStatus ==
//                                                                             2
//                                                                         ? 'Serve'
//                                                                             .tr
//                                                                         : orderItemList![index].foodStatus ==
//                                                                                 1
//                                                                             ? 'Cooking'
//                                                                             : 'cancel'.tr,
//                                                           )
//                                                         : Get.find<KdsController>()
//                                                                     .selectedSubMenu ==
//                                                                 1
//                                                             ? orderItemList![index].foodStatus == 0 ||
//                                                                     orderItemList![index].foodStatus ==
//                                                                         1 ||
//                                                                     orderItemList![index].foodStatus ==
//                                                                         3 ||
//                                                                     orderItemList![index]
//                                                                             .foodDetails!
//                                                                             .name!
//                                                                             .toUpperCase() ==
//                                                                         'CHECK IN'
//                                                                 ? FoodButton(
//                                                                     isDisable:
//                                                                         true,
//                                                                     onTap:
//                                                                         () {},
//                                                                     title: orderItemList![index].foodStatus ==
//                                                                             0
//                                                                         ? 'accept'
//                                                                             .tr
//                                                                         : orderItemList![index].foodStatus ==
//                                                                                 1
//                                                                             ? 'cooking'.tr
//                                                                             : orderItemList![index].foodStatus == 3
//                                                                                 ? 'Cancelled'
//                                                                                 : 'cancel'.tr,
//                                                                   )
//                                                                 : order!.orderType == 'delivery' ||
//                                                                         order!.orderType ==
//                                                                             'take_away'
//                                                                     ? SizedBox
//                                                                         .shrink()
//                                                                     : FoodButton(
//                                                                         isDisable:
//                                                                             !Get.find<AuthController>().profileModel!.role!.contains('order_cancel') &&
//                                                                                 orderItemList![index].foodStatus != 2,
//                                                                         title: orderItemList![index].foodStatus ==
//                                                                                 2
//                                                                             ? 'Serve'.tr
//                                                                             : 'cancel'.tr,
//                                                                         onTap:
//                                                                             () async {
//                                                                           FocusManager
//                                                                               .instance
//                                                                               .primaryFocus
//                                                                               ?.unfocus();

//                                                                           if (orderItemList![index].foodStatus ==
//                                                                               2) {
//                                                                             Map<String, dynamic>
//                                                                                 jsonBody =
//                                                                                 {
//                                                                               'order_id': order!.id.toString(),
//                                                                               'order_food_id': order!.orderDetails![index].foodDetails!.id.toString(),
//                                                                               'item_id': order!.orderDetails![index].id.toString(),
//                                                                               'order_status': 'serve'
//                                                                             };

//                                                                             Get.find<KdsController>().changeFoodOrderStatus(jsonBody,
//                                                                                 callback);
//                                                                           } else if (orderItemList![index].foodStatus ==
//                                                                               5) {
//                                                                             // searchController
//                                                                             //     .clear();
//                                                                             if (Get.find<AuthController>().profileModel!.role!.contains('order_cancel')) {
//                                                                               List<int> qtyList = [];
//                                                                               for (var i = 0; i < order!.orderDetails![index].quantity!; i++) {
//                                                                                 qtyList.add(i + 1);
//                                                                               }
//                                                                               await Get.bottomSheet(
//                                                                                   CancelOrderDialog(
//                                                                                     qtyList: qtyList,
//                                                                                     foodStatus: order!.orderDetails![index].foodStatus,
//                                                                                     itemId: order!.orderDetails![index].id.toString(),
//                                                                                     controller: cancelReason,
//                                                                                     foodId: order!.orderDetails![index].foodDetails!.id.toString(),
//                                                                                     orderId: order!.id.toString(),
//                                                                                   ),
//                                                                                   backgroundColor: Colors.transparent,
//                                                                                   isScrollControlled: true,
//                                                                                   ignoreSafeArea: false);
//                                                                             }
//                                                                           }
//                                                                         },
//                                                                       )
//                                                             : order!.fOrderStatus == 3 ||
//                                                                     order!.paymentType ==
//                                                                         'prepaid' ||
//                                                                     orderItemList![index].foodStatus !=
//                                                                         order!
//                                                                             .fOrderStatus ||
//                                                                     orderItemList![index]
//                                                                             .foodDetails!
//                                                                             .name!
//                                                                             .toUpperCase() ==
//                                                                         'CHECK IN'
//                                                                 ? FoodButton(
//                                                                     isDisable:
//                                                                         true,
//                                                                     onTap:
//                                                                         () {},
//                                                                     title: order!.fOrderStatus ==
//                                                                                 2 &&
//                                                                             orderItemList![index].foodStatus ==
//                                                                                 5
//                                                                         ? 'Serve'
//                                                                             .tr
//                                                                         : order!.fOrderStatus == 5 &&
//                                                                                 orderItemList![index].foodStatus == 3
//                                                                             ? 'canceled'.tr
//                                                                             : orderItemList![index].foodStatus == 3
//                                                                                 ? 'canceled'.tr
//                                                                                 : 'cancel'.tr,
//                                                                   )
//                                                                 : FoodButton(
//                                                                     isDisable: !Get.find<AuthController>()
//                                                                             .profileModel!
//                                                                             .role!
//                                                                             .contains(
//                                                                                 'order_cancel') &&
//                                                                         orderItemList![index].foodStatus !=
//                                                                             2,
//                                                                     title: orderItemList![index].foodStatus ==
//                                                                             2
//                                                                         ? 'Serve'
//                                                                             .tr
//                                                                         : 'cancel'
//                                                                             .tr,
//                                                                     onTap:
//                                                                         () async {
//                                                                       FocusManager
//                                                                           .instance
//                                                                           .primaryFocus
//                                                                           ?.unfocus();

//                                                                       if (orderItemList![index]
//                                                                               .foodStatus ==
//                                                                           2) {
//                                                                         Map<String,
//                                                                                 dynamic>
//                                                                             jsonBody =
//                                                                             {
//                                                                           'order_id': order!
//                                                                               .id
//                                                                               .toString(),
//                                                                           'order_food_id': order!
//                                                                               .orderDetails![index]
//                                                                               .foodDetails!
//                                                                               .id
//                                                                               .toString(),
//                                                                           'order_status':
//                                                                               'serve',
//                                                                           'item_id': order!
//                                                                               .orderDetails![index]
//                                                                               .id
//                                                                               .toString(),
//                                                                         };

//                                                                         Get.find<KdsController>().changeFoodOrderStatus(
//                                                                             jsonBody,
//                                                                             callback);
//                                                                       } else if (orderItemList![index].foodStatus ==
//                                                                               5 &&
//                                                                           Get.find<AuthController>()
//                                                                               .profileModel!
//                                                                               .role!
//                                                                               .contains('order_cancel')) {
//                                                                         List<int>
//                                                                             qtyList =
//                                                                             [];
//                                                                         for (var i =
//                                                                                 0;
//                                                                             i < order!.orderDetails![index].quantity!;
//                                                                             i++) {
//                                                                           qtyList.add(i +
//                                                                               1);
//                                                                         }
//                                                                         await Get.bottomSheet(
//                                                                             CancelOrderDialog(
//                                                                               qtyList: qtyList,
//                                                                               foodStatus: order!.orderDetails![index].foodStatus,
//                                                                               itemId: order!.orderDetails![index].id.toString(),
//                                                                               controller: cancelReason,
//                                                                               foodId: order!.orderDetails![index].foodDetails!.id.toString(),
//                                                                               orderId: order!.id.toString(),
//                                                                             ),
//                                                                             backgroundColor: Colors.transparent,
//                                                                             isScrollControlled: true,
//                                                                             ignoreSafeArea: false);
//                                                                       }
//                                                                     },
//                                                                   )
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//                                     // Align(
//                                     //   alignment: Alignment.centerLeft,
//                                     //   child: Text(
//                                     //     '${DateFormat('hh:mm').format(createTime)}',
//                                     //     // '3 minutes ago',
//                                     //     // '${timeago.format(tempDate)}', //38minute =38m, about hour ago = ~1h
//                                     //     style: poppinsMedium.copyWith(
//                                     //         fontSize: 11, color: Color.fromRGBO(193, 30, 30, 1)),
//                                     //   ),
//                                     // ),
//                                     SizedBox(
//                                         height: Dimensions.PADDING_SIZE_SMALL),
//                                     DottedLine(
//                                       direction: Axis.horizontal,
//                                       alignment: WrapAlignment.center,
//                                       lineThickness: 1.0,
//                                       dashLength: 2.5,
//                                       dashColor: ColorTheme.hintText,
//                                     ),
//                                   ],
//                                 ),
//                                 if (isPending == true)
//                                   Positioned(
//                                     left: -14,
//                                     child: InkWell(
//                                       onTap: () {
//                                         Get.bottomSheet(
//                                             mergeTable(
//                                                 context,
//                                                 orderItemList![index]
//                                                     .id
//                                                     .toString(),
//                                                 '${orderItemList![index].foodDetails!.name ?? ''}'),
//                                             backgroundColor: Colors.transparent,
//                                             isScrollControlled: true,
//                                             ignoreSafeArea: false);
//                                       },
//                                       child: Container(
//                                         height: 28,
//                                         width: 28,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: ColorTheme.appColor,
//                                         ),
//                                         child: Icon(
//                                           Icons.arrow_back_ios_new,
//                                           size: 16,
//                                           color: ColorTheme.productCard,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             );
//                 }),
//             if (order!.serveOrderDetails != null &&
//                 order!.serveOrderDetails!.isNotEmpty &&
//                 Get.find<KdsController>().selectedSubMenu == 1)
//               ExpansionTile(
//                 title: Row(
//                   children: [
//                     Text(
//                       'Served Item (${order!.serveOrderDetails?.length ?? 0})',
//                       style: poppinsSemiBold.copyWith(
//                         fontSize: 15,
//                         color: ColorTheme.disableButtonText,
//                       ),
//                     ),
//                   ],
//                 ),
//                 children:
//                     // [
//                     // ListView.builder(
//                     //   shrinkWrap: true,
//                     //   physics: NeverScrollableScrollPhysics(),
//                     //   itemCount: order.serveOrderDetails.length,
//                     //   itemBuilder: (context, o) {
//                     //     OrderDetails e = order.serveOrderDetails[o];
//                     // return ListTile(
//                     //   title: Text(childrenData[index]),
//                     // );

//                     order!.serveOrderDetails!.map((e) {
//                   String variationText = '';
//                   if (e.variation != null &&
//                       e.variation!.isNotEmpty &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .foodWithVariance ==
//                           'Yes') {
//                     variationText += '';
//                     List<String> labelList = [];

//                     for (int j = 0; j < e.variation!.length; j++) {
//                       if (e.variation![j].values != null) {
//                         for (var element in e.variation![j].values!) {
//                           labelList.add(element.level!);
//                         }
//                       }
//                     }
//                     variationText += '${labelList.join(',')}';
//                     variationText += '';
//                   } else if (e.variation != null &&
//                       e.variation!.isNotEmpty &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .foodWithVariance !=
//                           'Yes') {
//                     for (int j = 0; j < e.variation!.length; j++) {
//                       variationText +=
//                           '${variationText.isNotEmpty ? ', ' : ''}${e.variation![j].name} (';

//                       if (e.variation![j].values != null) {
//                         List<String> labelList = [];
//                         for (var element in e.variation![j].values!) {
//                           labelList.add(element.level!);
//                         }
//                         variationText +=
//                             '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//                       }

//                       variationText += ')';
//                     }
//                   }
//                   // if (e.variation != null && e.variation.isNotEmpty) {
//                   //   for (int j = 0; j < e.variation.length; j++) {
//                   //     variationText +=
//                   //         '${variationText.isNotEmpty ? ', ' : ''}${e.variation[j].name} (';

//                   //     if (e.variation[j].values != null) {
//                   //       List<String> labelList = [];
//                   //       for (var element in e.variation[j].values) {
//                   //         labelList.add(element.level);
//                   //       }
//                   //       variationText +=
//                   //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//                   //     }

//                   //     variationText += ')';
//                   //   }
//                   // }

//                   String addons = '';
//                   for (var i = 0; i < e.addOns!.length; i++) {
//                     if (addons != '') {
//                       addons += ', ';
//                     }
//                     addons += '${e.addOns![i].name} (${e.addOns![i].qty})';
//                   }
//                   return Column(
//                     children: [
//                       SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 17),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Text(
//                                   //   '${e.foodDetails.name ?? ''} (${e.quantity})',
//                                   //   style: poppinsSemiBold.copyWith(
//                                   //     fontSize: 15,
//                                   //     color: Colors.black,
//                                   //   ),
//                                   // ),
//                                   if (Get.find<AuthController>()
//                                           .profileModel!
//                                           .restaurants!
//                                           .first
//                                           .foodWithVariance ==
//                                       'Yes')
//                                     Text.rich(
//                                       TextSpan(
//                                         children: [
//                                           TextSpan(
//                                             text:
//                                                 '${e.foodDetails!.name ?? ''} (${e.quantity})',
//                                             style: poppinsMedium.copyWith(
//                                               fontSize: 15,
//                                               decoration: e.isSplited ||
//                                                       e.foodStatus == 3
//                                                   ? TextDecoration.lineThrough
//                                                   : TextDecoration.none,
//                                               color: e.isSplited ||
//                                                       e.foodStatus == 3
//                                                   ? ColorTheme.disableButtonText
//                                                   : Colors.black,
//                                             ),
//                                           ),
//                                           TextSpan(
//                                             text: ' $variationText',
//                                             style: poppinsMedium.copyWith(
//                                               overflow: TextOverflow.ellipsis,
//                                               fontSize: 11,
//                                               decoration: e.isSplited
//                                                   ? TextDecoration.lineThrough
//                                                   : TextDecoration.none,
//                                               color: e.isSplited
//                                                   ? Colors.grey
//                                                   : ColorTheme.green,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),

//                                   if (Get.find<AuthController>()
//                                           .profileModel!
//                                           .restaurants!
//                                           .first
//                                           .foodWithVariance !=
//                                       'Yes')
//                                     Text(
//                                       '${e.foodDetails!.name ?? ''} (${e.quantity})',
//                                       style: poppinsSemiBold.copyWith(
//                                         fontSize: 15,
//                                         decoration:
//                                             e.isSplited || e.foodStatus == 3
//                                                 ? TextDecoration.lineThrough
//                                                 : TextDecoration.none,
//                                         color: e.isSplited || e.foodStatus == 3
//                                             ? ColorTheme.disableButtonText
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                   addons == ''
//                                       ? SizedBox.shrink()
//                                       : Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 4),
//                                           child: Text.rich(
//                                             TextSpan(
//                                               children: [
//                                                 TextSpan(
//                                                   text: 'Add-Ons :',
//                                                   style: poppinsMedium.copyWith(
//                                                       fontSize: 11,
//                                                       color: ColorTheme
//                                                           .kdsLeftMenuBlue),
//                                                 ),
//                                                 TextSpan(
//                                                   text: ' $addons',
//                                                   style: poppinsMedium.copyWith(
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     fontSize: 11,
//                                                     color: ColorTheme.green,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                   if (Get.find<AuthController>()
//                                           .profileModel!
//                                           .restaurants!
//                                           .first
//                                           .foodWithVariance !=
//                                       'Yes')
//                                     variationText == ''
//                                         ? SizedBox.shrink()
//                                         : Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 4),
//                                             child: Text.rich(
//                                               TextSpan(
//                                                 children: [
//                                                   TextSpan(
//                                                     text: 'Variants  :',
//                                                     style:
//                                                         poppinsMedium.copyWith(
//                                                             fontSize: 11,
//                                                             color: ColorTheme
//                                                                 .blue),
//                                                   ),
//                                                   TextSpan(
//                                                     text: ' $variationText',
//                                                     style:
//                                                         poppinsMedium.copyWith(
//                                                             fontSize: 11,
//                                                             color: ColorTheme
//                                                                 .green),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                   e.foodLevelNotes == ''
//                                       ? SizedBox.shrink()
//                                       : Padding(
//                                           padding:
//                                               const EdgeInsets.only(top: 4),
//                                           child: Text.rich(
//                                             TextSpan(
//                                               children: [
//                                                 TextSpan(
//                                                   text: 'Notes  :',
//                                                   style: poppinsMedium.copyWith(
//                                                       fontSize: 11,
//                                                       color: ColorTheme.blue),
//                                                 ),
//                                                 TextSpan(
//                                                   text: ' ${e.foodLevelNotes}',
//                                                   style: poppinsMedium.copyWith(
//                                                       fontSize: 11,
//                                                       color: ColorTheme.green),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                   GetBuilder<KdsController>(
//                                       builder: (kdsController) {
//                                     String showTime = '';
//                                     showTime =
//                                         Jiffy.parse(e.createdAt!).fromNow();
//                                     if (e.readyAt != null) {
//                                       showTime =
//                                           Jiffy.parse(e.readyAt!).fromNow();
//                                     }
//                                     if (e.serveAt != null) {
//                                       showTime =
//                                           Jiffy.parse(e.serveAt!).fromNow();
//                                     }

//                                     return Padding(
//                                       padding: const EdgeInsets.only(top: 5),
//                                       child: Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: Text(
//                                           '$showTime',
//                                           style: poppinsMedium.copyWith(
//                                               fontSize: 10,
//                                               color: ColorTheme.hintText),
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(width: 20),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 if (e.foodDetails!.name!.toUpperCase() !=
//                                     'CHECK IN')
//                                   !Get.find<AuthController>()
//                                           .profileModel!
//                                           .role!
//                                           .contains('order')
//                                       ? FoodButton(
//                                           isDisable: true,
//                                           onTap: () {},
//                                           title: 'Served'.tr,
//                                         )
//                                       : FoodButton(
//                                           isDisable: !Get.find<AuthController>()
//                                                   .profileModel!
//                                                   .role!
//                                                   .contains('order_cancel') ||
//                                               order!.paymentType == 'prepaid',
//                                           title: 'cancel'.tr,
//                                           onTap: () async {
//                                             // searchController.clear();
//                                             if (Get.find<AuthController>()
//                                                     .profileModel!
//                                                     .role!
//                                                     .contains('order_cancel') &&
//                                                 order!.paymentType !=
//                                                     'prepaid') {
//                                               FocusManager.instance.primaryFocus
//                                                   ?.unfocus();
//                                               List<int> qtyList = [];
//                                               for (var i = 0;
//                                                   i < e.quantity!;
//                                                   i++) {
//                                                 qtyList.add(i + 1);
//                                               }
//                                               await Get.bottomSheet(
//                                                   CancelOrderDialog(
//                                                     qtyList: qtyList,
//                                                     foodStatus: e.foodStatus,
//                                                     itemId: e.id.toString(),
//                                                     controller: cancelReason,
//                                                     foodId: e.foodDetails!.id
//                                                         .toString(),
//                                                     orderId:
//                                                         order!.id.toString(),
//                                                   ),
//                                                   backgroundColor:
//                                                       Colors.transparent,
//                                                   isScrollControlled: true,
//                                                   ignoreSafeArea: false);
//                                             }
//                                           },
//                                         )
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//                     ],
//                   );
//                   // },
//                   //   ),
//                   // ]
//                 }).toList(),
//               ),
//             if (order!.roomAssociateOrder != null &&
//                 order!.roomAssociateOrder!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: ExpansionTile(
//                   backgroundColor: Color.fromRGBO(254, 245, 208, 1),
//                   collapsedBackgroundColor: Color.fromRGBO(254, 245, 208, 1),
//                   tilePadding: EdgeInsets.symmetric(horizontal: 20),
//                   childrenPadding: EdgeInsets.symmetric(horizontal: 20),
//                   title: Row(
//                     children: [
//                       Text(
//                         'Associated Orders (${order!.roomAssociateOrder?.length ?? 0})',
//                         style: poppinsSemiBold.copyWith(
//                           fontSize: 15,
//                           color: ColorTheme.disableButtonText,
//                         ),
//                       ),
//                     ],
//                   ),
//                   children: order!.roomAssociateOrder!.map((e) {
//                     return Column(
//                       children: [
//                         // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Order Id',
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             ),
//                             Text(
//                               '${e.restaurantOrderId}',
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             )
//                           ],
//                         ),

//                         SizedBox(height: 5),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Amount',
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             ),
//                             Text(
//                               '${e.amount!.toStringAsFixed(2)}',
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             )
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Time',
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             ),
//                             Text(
//                               DateFormat('yyyy-MM-dd HH:mm')
//                                   .format(DateTime.parse(e.collectBillDate!)),
//                               style: poppinsSemiBold.copyWith(
//                                 fontSize:
//                                     MediaQuery.of(context).size.shortestSide >
//                                             570
//                                         ? 15
//                                         : 13,
//                               ),
//                             )
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Divider(),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget mergeTable(BuildContext context, String foodId, String foodItemName) {
//     String? selectedOrderId;
//     String? selectedTableName;
//     TextEditingController? searchOrderController;
//     List<OrderList> orderList = [];
//     orderList = Get.find<KdsController>()
//         .getWaiterOrderListResponse!
//         .orders!
//         .where((element) =>
//             element.orderType != 'delivery' &&
//             element.fOrderStatus != 3 &&
//             element.fOrderStatus != 6 &&
//             element.orderType != 'take_away' &&
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
//                       'Transfer $foodItemName to',
//                       style: poppinsMedium.copyWith(
//                         color: Colors.black,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Text(
//                       'Select Table',
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
//                   controller: searchOrderController,
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
//                     if (searchOrderController!.text.isNotEmpty) {
//                       orderList = Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders!
//                           .where((item) => (item.id != order!.id &&
//                               item.orderType != 'delivery' &&
//                               item.fOrderStatus != 3 &&
//                               item.fOrderStatus != 6 &&
//                               item.orderType != 'take_away' &&
//                               (((item.restaurantTable == null ||
//                                           item.restaurantTable!.tableNo ==
//                                               '') &&
//                                       item.userName.toLowerCase().contains(
//                                           searchOrderController.text
//                                               .toLowerCase())) ||
//                                   (item.restaurantTable != null &&
//                                       item.restaurantTable!.tableNo != '' &&
//                                       item.restaurantTable!.rtype != 'RM' &&
//                                       item.restaurantTable!.tableNo!
//                                           .toLowerCase()
//                                           .contains(searchOrderController.text
//                                               .toLowerCase())))))
//                           .toList();
//                     } else {
//                       orderList = Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders!
//                           .where((element) =>
//                               element.orderType != 'delivery' &&
//                               element.fOrderStatus != 3 &&
//                               element.fOrderStatus != 6 &&
//                               element.orderType != 'take_away' &&
//                               element.id != order!.id &&
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
//                                     : order.restaurantTable!.title == ''
//                                         ? '${order.restaurantTable!.tableNo}'
//                                         : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}';
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
//                                           fontSize: 13,
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
//                 // Row(
//                 //   children: [
//                 //     Checkbox(
//                 //       value: true,
//                 //       onChanged: (value) {},
//                 //     ),
//                 //     Text(
//                 //       'Switch Notes',
//                 //       style: poppinsMedium.copyWith(
//                 //           fontSize: 11, color: Colors.black),
//                 //       textAlign: TextAlign.start,
//                 //     ),
//                 //   ],
//                 // ),
//                 SizedBox(height: 10),
//                 CustomButton(
//                   width: Get.width / 2.0,
//                   buttonText: 'Transfer To Table',
//                   onPressed: () async {
//                     Map<String, dynamic> jsonData = {
//                       'source_order_id': order!.id,
//                       'target_order_id': selectedOrderId,
//                       'food_item_id': foodId
//                     };
//                     Get.find<KdsController>().transferFood(jsonData,
//                         (bool isSuccess) {
//                       if (isSuccess) {
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
//                             "$foodItemName is successfully transferred from ${order!.restaurantTable == null || order!.restaurantTable!.tableNo == '' ? order!.orderType == 'delivery' ? 'Delivery' : order!.orderType == 'take_away' ? 'Take Away' : order!.userName != 'Mygenie' && order!.userName != '' ? order!.userName : 'WC' : order!.restaurantTable!.title == '' ? '#${order!.restaurantTable!.tableNo}' : '#${order!.restaurantTable!.title}-${order!.restaurantTable!.tableNo}'} to $selectedTableName");
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

//   editProduct(
//       {int? index,
//       String? addons,
//       String? variationText,
//       OrderDetails? foodOrderDetail}) async {
//     showToast('Please wait..');
//     Get.find<LoadingController>().startLoading(true);
//     Product apiProduct = (await Get.find<ProductController>().getSingleProduct(
//         order!.orderDetails![index!].foodDetails!.id!.toString()))!;
//     Get.find<LoadingController>().startLoading(false);
//     if (Get.isBottomSheetOpen ?? false) Get.back();

//     Get.find<CartController>().clearCartList();

//     OrderDetails orderDetail = foodOrderDetail!;
//     FoodDetails food = foodOrderDetail.foodDetails!;
//     List<AddOns> addonList = [];
//     for (var e in food.addOns!) {
//       addonList.add(AddOns(id: e.id, name: e.name, price: e.price, qty: e.qty));
//     }
//     double variationPrice = 0;
//     Product product = Product(
//        deliveryFoodPrice: food?.deliveredFoodPrice,
//         takeAwayFoodPrice: food?.takeAwayFoodPrice,
//         addOns: addonList,
//         name: food.name,
//         id: food.id,
//         restaurantDiscount: 0,
//         variations: food.variations,
//         categoryIds: food.categoryIds,
//         availableTimeStarts: food.availableTimeStarts,
//         availableTimeEnds: food.availableTimeEnds,
//         categoryId: food.categoryId,
//         description: food.description,
//         discount: 0,
//         mainCategoryId: food.mainCategoryId,
//         qty: 1,
//         price: double.parse(food.price!),
//         stationName: orderDetail.station);
//     // double _startingPrice;
//     // double _endingPrice;
//     Get.find<CartController>().initData(product, null);

//     if (product.variations != null) {
//       for (int index = 0; index < product.variations!.length; index++) {
//         for (int i = 0; i < product.variations![index].values!.length; i++) {
//           for (int j = 0; j < orderDetail.variation!.length; j++) {
//             for (int k = 0; k < orderDetail.variation![j].values!.length; k++) {
//               if (product.variations![index].name ==
//                   orderDetail.variation![j].name) {
//                 if (product.variations![index].values![i].level ==
//                     orderDetail.variation![j].values![k].level) {
//                   Get.find<CartController>().setCartVariationIndex(
//                     index,
//                     i,
//                     product,
//                     product.variations![index].type == 'multi',
//                   );
//                   variationPrice += double.parse(
//                       product.variations![index].values![i].optionPrice!);
//                 }
//               }
//             }
//           }
//         }
//       }
//     }

//     // double addonsCost = 0;
//     List<AddOn> _addOnIdList = [];
//     List<AddOns> _addOnsList = [];
//     for (var i = 0; i < product.addOns!.length; i++) {
//       for (int index = 0; index < orderDetail.addOns!.length; index++) {
//         if (orderDetail.addOns![index].id == product.addOns![i].id) {
//           _addOnIdList.add(AddOn(
//               id: product.addOns![i].id!,
//               quantity: orderDetail.addOns![index].qty!));
//           _addOnsList.add(product.addOns![i]);
//         }
//       }
//     }

//     double priceWithVariation = double.parse(food.price!) + variationPrice;

//     CartModel _cartModel = CartModel(
//         adjustPrice: 1,
//         price: priceWithVariation,
//         discountedPrice: 0,
//         discountAmount: 0,
//         // discountAmount: (price -
//         //     PriceConverter.convertWithDiscount(
//         //         price, _discount, _discountType)),
//         quantity: 1,
//         addOnIds: _addOnIdList,
//         addOns: _addOnsList,
//         isCampaign: false,
//         product: product,
//         variation: Get.find<CartController>().selectedVariations!);
//     Get.find<CartController>().addToCart(_cartModel, null);

//     Get.find<CartController>().calculationCart();
//     await Get.bottomSheet(
//         EditFoodOrderDialog(
//           addonText: addons ?? '',
//           variationText: variationText ?? '',
//           foodName: order!.orderDetails![index].foodDetails!.name!,
//           variation: order!.orderDetails![index].variation!,
//           foodId: order!.orderDetails![index].foodDetails!.id.toString(),
//           addons: order!.orderDetails![index].addOns!,
//           orderId: order!.id.toString(),
//           product: apiProduct,
//           order: order!,
//         ),
//         backgroundColor: Colors.transparent,
//         isScrollControlled: true,
//         ignoreSafeArea: false);
//   }

//   void callback(bool isSuccess, String message) async {
//     if (isSuccess) {
//       // Get.find<KdsController>().clearOrderList();
//       // Get.find<KdsController>().getWaiterPOSOrderList();
//       // showCustomSnackBar(message, isError: false);
//       // Get.find<OrderController>().stopLoader();

//       // Get.offNamed(
//       //     RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
//     } else {
//       // showCustomSnackBar(message);
//     }
//   }

//   Future<void> speak(String text) async {
//     await flutterTts!.setLanguage("en-IN");
//     await flutterTts!.setPitch(1.0);
//     await flutterTts!.speak(text);
//   }

//   Widget buildWithOptionalExpanded(
//       {required bool useExpanded, required Widget child}) {
//     return useExpanded ? Expanded(child: child) : child;
//   }
// }
