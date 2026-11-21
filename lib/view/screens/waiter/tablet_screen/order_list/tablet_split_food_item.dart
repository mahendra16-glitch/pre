// import 'package:dotted_line/dotted_line.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TabletWaiterSelectOrdeItem extends StatelessWidget {
//   final List<OrderDetails>? orderItemList;
//   final OrderList? order;

//   TabletWaiterSelectOrdeItem({Key? key, this.orderItemList, this.order})
//       : super(key: key);
//   final TextEditingController cancelReason = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     double foodTotal = 0;
//     return buildWithOptionalExpanded(
//       useExpanded: Get.find<AuthController>()
//               .profileModel!
//               .restaurants!
//               .first
//               .listServeItem ==
//           'Fixed',
//       child: SingleChildScrollView(
//         child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: orderItemList!.length + 1,
//             itemBuilder: (BuildContext context, int index) {
//               double itemPrice = 0;
//               // itemPrice = orderItemList[index].price.toDouble();
//               String variationText = '';
//               String addons = '';
//               double gstCharge = 0;
//               double vatCharge = 0;
//               if (orderItemList!.length != index) {
//                 itemPrice = itemPrice + orderItemList![index].price!;
//                 if (orderItemList![index].variation != null &&
//                     orderItemList![index].variation!.isNotEmpty) {
//                   for (int j = 0;
//                       j < orderItemList![index].variation!.length;
//                       j++) {
//                     variationText +=
//                         '${variationText.isNotEmpty ? ', ' : ''}${orderItemList![index].variation![j].name} (';

//                     if (orderItemList![index].variation![j].values != null) {
//                       List<String> labelList = [];
//                       for (var element
//                           in orderItemList![index].variation![j].values!) {
//                         labelList.add(element.level!);
//                         itemPrice = itemPrice +
//                             (double.parse(element.optionPrice!) *
//                                 orderItemList![index].quantity!);
//                       }
//                       variationText +=
//                           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//                     }

//                     variationText += ')';
//                   }
//                 }

//                 for (var i = 0; i < orderItemList![index].addOns!.length; i++) {
//                   itemPrice = itemPrice +
//                       (orderItemList![index].addOns![i].qty! *
//                               orderItemList![index].addOns![i].price!)
//                           .toDouble();

//                   addons +=
//                       '${orderItemList![index].addOns![i].name} (${orderItemList![index].addOns![i].qty})';
//                 }

//                 if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .gstStatus ==
//                         'true' &&
//                     orderItemList![index].foodDetails!.taxType != null &&
//                     orderItemList![index].foodDetails!.taxType != '' &&
//                     orderItemList![index].foodDetails!.taxType == 'GST' &&
//                     orderItemList![index].foodDetails!.taxCalc != null &&
//                     orderItemList![index].foodDetails!.taxCalc != '' &&
//                     orderItemList![index].foodDetails!.taxCalc == 'Exclusive') {
//                   gstCharge =
//                       (itemPrice * orderItemList![index].foodDetails!.tax!) /
//                           100;
//                 } else if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .gstStatus ==
//                         'true' &&
//                     orderItemList![index].foodDetails!.taxType != null &&
//                     orderItemList![index].foodDetails!.taxType != '' &&
//                     orderItemList![index].foodDetails!.taxType == 'VAT' &&
//                     orderItemList![index].foodDetails!.taxCalc != null &&
//                     orderItemList![index].foodDetails!.taxCalc != '' &&
//                     orderItemList![index].foodDetails!.taxCalc == 'Exclusive') {
//                   vatCharge =
//                       (itemPrice * orderItemList![index].foodDetails!.tax!) /
//                           100;
//                 }

//                 itemPrice = itemPrice +
//                     (Get.find<AuthController>()
//                                     .profileModel!
//                                     .restaurants!
//                                     .first
//                                     .serviceCharge ==
//                                 'Yes' &&
//                             Get.find<AuthController>()
//                                     .profileModel!
//                                     .restaurants!
//                                     .first
//                                     .autoServiceCharge ==
//                                 'Yes'
//                         ? ((itemPrice * 10) / 100)
//                         : 0) +
//                     gstCharge +
//                     vatCharge;
//                 foodTotal = foodTotal + itemPrice;
//               }

//               return orderItemList!.length == index
//                   ? order!.isShowCheckbox
//                       ? SizedBox.shrink()
//                       : Padding(
//                           padding: const EdgeInsets.only(left: 18, right: 18),
//                           child: Column(
//                             children: [
//                               SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Total Amount',
//                                     style: poppinsSemiBold.copyWith(
//                                         fontSize: 15, color: Colors.black),
//                                   ),
//                                   Text(
//                                     '${foodTotal.toStringAsFixed(2)}',
//                                     style: poppinsSemiBold.copyWith(
//                                         fontSize: 15, color: Colors.black),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )
//                   : orderItemList![index].foodStatus == 3
//                       ? SizedBox.shrink()
//                       : orderItemList![index].isSplited &&
//                               order!.isSplitTable == false
//                           ? SizedBox.shrink()
//                           : Column(
//                               children: [
//                                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 17),
//                                   child: InkWell(
//                                     onTap: () {
//                                       Get.find<KdsController>()
//                                           .selectFoodItem(foodIndex: index);
//                                     },
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 '${orderItemList![index].foodDetails!.name ?? ''} (${orderItemList![index].quantity})',
//                                                 style: poppinsSemiBold.copyWith(
//                                                     fontSize: 15,
//                                                     color: Colors.black),
//                                               ),
//                                               addons == ''
//                                                   ? SizedBox.shrink()
//                                                   : Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               top: 4),
//                                                       child: Text.rich(
//                                                         TextSpan(
//                                                           children: [
//                                                             TextSpan(
//                                                               text: 'Add-Ons :',
//                                                               style: poppinsMedium
//                                                                   .copyWith(
//                                                                       fontSize:
//                                                                           11,
//                                                                       color: ColorTheme
//                                                                           .blue),
//                                                             ),
//                                                             TextSpan(
//                                                               text: ' $addons',
//                                                               style:
//                                                                   poppinsMedium
//                                                                       .copyWith(
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 fontSize: 11,
//                                                                 color:
//                                                                     ColorTheme
//                                                                         .green,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                               variationText == ''
//                                                   ? SizedBox.shrink()
//                                                   : Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               top: 4),
//                                                       child: Text.rich(
//                                                         TextSpan(
//                                                           children: [
//                                                             TextSpan(
//                                                               text:
//                                                                   'Variants  :',
//                                                               style: poppinsMedium
//                                                                   .copyWith(
//                                                                       fontSize:
//                                                                           11,
//                                                                       color: ColorTheme
//                                                                           .blue),
//                                                             ),
//                                                             TextSpan(
//                                                               text:
//                                                                   ' $variationText',
//                                                               style: poppinsMedium
//                                                                   .copyWith(
//                                                                       fontSize:
//                                                                           11,
//                                                                       color: ColorTheme
//                                                                           .green),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                             ],
//                                           ),
//                                         ),
//                                         // Image.asset(Images.ic_theme_show_addOn, height: 30),
//                                         SizedBox(width: 20),
//                                         order!.isSplitTable
//                                             ? Text(
//                                                 '${itemPrice.toStringAsFixed(2)}',
//                                                 style: poppinsSemiBold.copyWith(
//                                                     fontSize: 15,
//                                                     color: Colors.black),
//                                               )
//                                             : SizedBox(
//                                                 height: 10,
//                                                 child: Checkbox(
//                                                     value: orderItemList![index]
//                                                         .isSelected,
//                                                     onChanged: (v) {
//                                                       Get.find<KdsController>()
//                                                           .selectFoodItem(
//                                                               foodIndex: index);
//                                                     }),
//                                               ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//                                 DottedLine(
//                                   direction: Axis.horizontal,
//                                   alignment: WrapAlignment.center,
//                                   lineThickness: 1.0,
//                                   dashLength: 2.5,
//                                   dashColor: ColorTheme.hintText,
//                                 ),
//                               ],
//                             );
//             }),
//       ),
//     );
//   }

//   Widget buildWithOptionalExpanded(
//       {required bool useExpanded, required Widget child}) {
//     return useExpanded ? Expanded(child: child) : child;
//   }
// }
