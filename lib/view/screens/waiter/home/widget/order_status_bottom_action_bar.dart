// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_pos_printer_platform_image_3/printer.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/controller/loader_contoller.dart';
// import 'package:mygenie_restaurant/controller/pos_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/view/base/custom_toast.dart';
// import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';

// class OrderStatusBottomActionBar {
//   Widget cookingBottomBar(
//       {KdsController? kdsController,
//       TextEditingController? searchOrder,
//       required OrderList order,
//       StreamSubscription<BTStatus>? subscriptionBtStatus,
//       required BuildContext context}) {
//     return Row(
//       children: [
//         InkWell(
//             onTap: () async {
//               searchOrder?.clear();
//               FocusManager.instance.primaryFocus?.unfocus();
//               List<List<OrderDetails>> cartProductList = [];
//               cartProductList = [];
//               for (var i = 0;
//                   i <
//                       Get.find<AuthController>()
//                           .profileModel!
//                           .restaurantPrinterNew!
//                           .length;
//                   i++) {
//                 RestaurantPrinterNew printer = Get.find<AuthController>()
//                     .profileModel!
//                     .restaurantPrinterNew![i];
//                 List<OrderDetails> tempCartList = [];
//                 for (var e in order.orderDetails!) {
//                   if (e.station == printer.areaName && (e.foodStatus != 3)) {
//                     tempCartList.add(e);
//                   }
//                 }
//                 cartProductList.add(tempCartList);
//               }
//               if (cartProductList.isNotEmpty) {
//                 await subscriptionBtStatus?.cancel();
//                 if (order.restaurantTable != null &&
//                     order.restaurantTable!.rtype == 'RM') {
//                 } else {
//                   showToast('Please wait..');
//                   Get.find<LoadingController>().startLoading(true);
//                   await Get.find<PosController>()
//                       .getCollectBillDetail({'order_id': '${order.id}'});
//                   Get.find<LoadingController>().startLoading(false);
//                   if (Get.isBottomSheetOpen ?? false) Get.back();
//                 }
//                 await Get.bottomSheet(
//                     PrintDialog(
//                       isBillPrint: order.restaurantTable != null &&
//                               order.restaurantTable!.rtype == 'RM'
//                           ? false
//                           : true,
//                       collectBillResponse: Get.find<PosController>()
//                           .getCollectBillDetailResponse,
//                       cartProductList: cartProductList,
//                       index: Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders!
//                           .indexOf(order),
//                     ),
//                     backgroundColor: Colors.transparent,
//                     isScrollControlled: true,
//                     ignoreSafeArea: false);
//               }
//             },
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: SvgPicture.asset(
//                 Images.ic_print_kot,
//                 height: 26,
//               ),
//             )),
//         SizedBox(width: 10),
//         InkWell(
//           onTap: () {
//             Get.bottomSheet(whatsAppBottomSheet(context, order: order!),
//                 backgroundColor: Colors.transparent,
//                 isScrollControlled: true,
//                 ignoreSafeArea: false);
//           },
//           child: Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),
//         )
//       ],
//     );
//   }
// }
