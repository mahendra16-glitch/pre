// import 'dart:async';

// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/order_list/tablet_order_list.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get/get.dart';

// import '../../../../../../data/model/response/profile_model.dart';

// Widget showConfigOrderList(
//     BuildContext context,
//     KdsController kdsController,
//     TextEditingController searchController,
//     StreamSubscription<BTStatus>? _subscriptionBtStatus,
//     TextEditingController searchTable,
//     FlutterTts flutterTts) {
//   return StaggeredGrid.count(
//     crossAxisCount:
//         MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 2,
//     crossAxisSpacing: 15,
//     mainAxisSpacing: 15,
//     children: kdsController.getWaiterOrderListResponse!.orders!.where((order) {
//       Restaurant restaurant =
//           Get.find<AuthController>().profileModel!.restaurants!.first;
//       List<String> role = Get.find<AuthController>().profileModel!.role!;

//       // Filter with dine in
//       if (kdsController.selectedMainMenu == 0) {
//         if (kdsController.selectedSubMenu == 1) {
//           if (order.fOrderStatus == 0 ||
//               order.fOrderStatus == 1 ||
//               order.fOrderStatus == 2 ||
//               (restaurant.isShowOrderConfirmTab == 'No' &&
//                   order.fOrderStatus == 7)) {
//             if (searchController.text.isEmpty) {
//               if (((order.restaurantTable != null
//                       ? order.restaurantTable!.rtype != 'RM'
//                       : true) &&
//                   (order.orderType == 'pos' ||
//                       order.orderType == 'WalkIn' ||
//                       order.orderType == 'dinein'))) {
//                 return true;
//               }
//             } else if ((restaurant.searchBy!.contains('table no') &&
//                     (order.restaurantTable != null &&
//                         order.restaurantTable!.tableNo != '' &&
//                         (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.restaurantTable!.title!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (restaurant.searchBy!.contains('user id') &&
//                         (order.userName
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase())) ||
//                     (order.userId != null &&
//                         (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.user!.lName!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (restaurant.searchBy!.contains('phone no') &&
//                     (order.userId != null &&
//                         (order.user!.phone!.length > 2 &&
//                             order.user!.phone!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||

//                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                 (restaurant.searchBy!.contains('order id') &&
//                     (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//               if (((order.restaurantTable != null
//                       ? order.restaurantTable!.rtype != 'RM'
//                       : true) &&
//                   (order.orderType == 'pos' ||
//                       order.orderType == 'WalkIn' ||
//                       order.orderType == 'dinein'))) {
//                 return true;
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 2) {
//           if (order.fOrderStatus == 5 ||
//               (Get.find<AuthController>()
//                           .profileModel
//                           ?.restaurants
//                           ?.first
//                           .defOrdStatus ==
//                       5
//                   ? (restaurant.isShowOrderConfirmTab == 'No' &&
//                       order.fOrderStatus == 7)
//                   : order.fOrderStatus == 5)) {
//             if (searchController.text.isEmpty) {
//               if ((order.restaurantTable != null
//                       ? order.restaurantTable!.rtype != 'RM'
//                       : true) &&
//                   (order.orderType == 'pos' ||
//                       order.orderType == 'WalkIn' ||
//                       order.orderType == 'dinein')) {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if ((order.restaurantTable != null
//                         ? order.restaurantTable!.rtype != 'RM'
//                         : true) &&
//                     (order.orderType == 'pos' ||
//                         order.orderType == 'WalkIn' ||
//                         order.orderType == 'dinein')) {
//                   return true;
//                 }
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 0) {
//           if (order.fOrderStatus == 7) {
//             if (searchController.text.isEmpty) {
//               if ((order.restaurantTable != null
//                       ? order.restaurantTable!.rtype != 'RM'
//                       : true) &&
//                   (order.orderType == 'pos' ||
//                       order.orderType == 'WalkIn' ||
//                       order.orderType == 'dinein')) {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if ((order.restaurantTable != null
//                         ? order.restaurantTable!.rtype != 'RM'
//                         : true) &&
//                     (order.orderType == 'pos' ||
//                         order.orderType == 'WalkIn' ||
//                         order.orderType == 'dinein')) {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }

//       //////////// Filter with Take Away
//       else if (kdsController.selectedMainMenu == 1) {
//         if (kdsController.selectedSubMenu == 1) {
//           if (order.fOrderStatus == 0 ||
//               order.fOrderStatus == 1 ||
//               order.fOrderStatus == 2 ||
//               (restaurant.isShowOrderConfirmTab == 'No' &&
//                   order.fOrderStatus == 7)) {
//             if (searchController.text.isEmpty) {
//               if (order.orderType == 'take_away') {
//                 return true;
//               }
//             } else if ((Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('table no') &&
//                     (order.restaurantTable != null &&
//                         order.restaurantTable!.tableNo != '' &&
//                         (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.restaurantTable!.title!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                         (order.userName
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase())) ||
//                     (order.userId != null &&
//                         (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.user!.lName!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('phone no') &&
//                     (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//               if (order.orderType == 'take_away') {
//                 return true;
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 2) {
//           if (order.fOrderStatus == 5 ||
//               (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .defOrdStatus ==
//                       5
//                   ? (restaurant.isShowOrderConfirmTab == 'No' &&
//                       order.fOrderStatus == 7)
//                   : order.fOrderStatus == 5)) {
//             if (searchController.text.isEmpty) {
//               if (order.orderType == 'take_away') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if (order.orderType == 'take_away') {
//                   return true;
//                 }
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 0) {
//           if (order.fOrderStatus == 7) {
//             if (searchController.text.isEmpty) {
//               if (order.orderType == 'take_away') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if (order.orderType == 'take_away') {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }
//       ///////////    Filter with delivery
//       else if (kdsController.selectedMainMenu == 2) {
//         if (kdsController.selectedSubMenu == 1) {
//           if (order.fOrderStatus == 0 ||
//               order.fOrderStatus == 1 ||
//               order.fOrderStatus == 2 ||
//               (restaurant.isShowOrderConfirmTab == 'No' &&
//                   order.fOrderStatus == 7)) {
//             if (searchController.text.isEmpty) {
//               if (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .isDeliveryAssign ==
//                       'Yes'
//                   ? (order.orderType == 'delivery' &&
//                       (role.contains('delivery_man')
//                           ? (Get.find<AuthController>().profileModel!.empId ==
//                                   order.deliveryManId &&
//                               order.deliveryMan != '')
//                           : (role.contains('show_online_order'))))
//                   : order.orderType == 'delivery') {
//                 return true;
//               }
//             } else if ((Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('table no') &&
//                     (order.restaurantTable != null &&
//                         order.restaurantTable!.tableNo != '' &&
//                         (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.restaurantTable!.title!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                     (order.deliveryAddress != null &&
//                         order.deliveryAddress!.contactPersonName!
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase()))) ||
//                 // (
//                 //     order.userName
//                 //         .toUpperCase()
//                 //         .contains(searchController.text.toUpperCase())) ||
//                 // (order.userId != null &&
//                 //     (order.user.fName
//                 //             .toUpperCase()
//                 //             .contains(searchController.text.toUpperCase()) ||
//                 //         order.user.lName
//                 //             .toUpperCase()
//                 //             .contains(searchController.text.toUpperCase()))) ||

//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('phone no') &&
//                     (order.deliveryAddress != null &&
//                         order.deliveryAddress!.contactPersonNumber!.length >
//                             2 &&
//                         order.deliveryAddress!.contactPersonNumber!
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase()))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') &&
//                     (order.restaurantOrderId!
//                         .toUpperCase()
//                         .contains(searchController.text.toUpperCase())))) {
//               if (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .isDeliveryAssign ==
//                       'Yes'
//                   ? (order.orderType == 'delivery' &&
//                       (role.contains('delivery_man')
//                           ? (Get.find<AuthController>().profileModel!.empId ==
//                                   order.deliveryManId &&
//                               order.deliveryMan != '')
//                           : (role.contains('show_online_order'))))
//                   : order.orderType == 'delivery') {
//                 return true;
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 2) {
//           if (order.fOrderStatus == 5 ||
//               (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .defOrdStatus ==
//                       5
//                   ? (restaurant.isShowOrderConfirmTab == 'No' &&
//                       order.fOrderStatus == 7)
//                   : order.fOrderStatus == 5)) {
//             if (searchController.text.isEmpty) {
//               if (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .isDeliveryAssign ==
//                       'Yes'
//                   ? (order.orderType == 'delivery' &&
//                       (role.contains('delivery_man')
//                           ? (Get.find<AuthController>().profileModel!.empId ==
//                                   order.deliveryManId &&
//                               order.deliveryMan != '')
//                           : (role.contains('show_online_order'))))
//                   : order.orderType == 'delivery') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   // (
//                   //     '${order?.userName ?? ''}'
//                   //         .toUpperCase()
//                   //         .contains(searchController.text.toUpperCase())) ||
//                   // (order.userId != null &&
//                   //     (order.user.fName
//                   //             .toUpperCase()
//                   //             .contains(searchController.text.toUpperCase()) ||
//                   //         order.user.lName.toUpperCase().contains(
//                   //             searchController.text.toUpperCase()))) ||
//                   // (order.userId != null &&
//                   //     order.user.phone.length > 2 &&
//                   //     (order.user.phone
//                   //         .toUpperCase()
//                   //         .contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonName!
//                               .toUpperCase()
//                               .contains(
//                                   searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonNumber!.length >
//                               2 &&
//                           order.deliveryAddress!.contactPersonNumber!
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase()))) {
//                 if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .isDeliveryAssign ==
//                         'Yes'
//                     ? (order.orderType == 'delivery' &&
//                         (role.contains('delivery_man')
//                             ? (Get.find<AuthController>().profileModel!.empId ==
//                                     order.deliveryManId &&
//                                 order.deliveryMan != '')
//                             : (role.contains('show_online_order'))))
//                     : order.orderType == 'delivery') {
//                   return true;
//                 }
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 0) {
//           if (order.fOrderStatus == 7) {
//             if (searchController.text.isEmpty) {
//               if (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .isDeliveryAssign ==
//                       'Yes'
//                   ? (order.orderType == 'delivery' &&
//                       (role.contains('delivery_man')
//                           ? (Get.find<AuthController>().profileModel!.empId ==
//                                   order.deliveryManId &&
//                               order.deliveryMan != '')
//                           : (role.contains('show_online_order'))))
//                   : order.orderType == 'delivery') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('user id') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonName!.toUpperCase().contains(
//                               searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonNumber!.length > 2 &&
//                           order.deliveryAddress!.contactPersonNumber!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase()))) {
//                 if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .isDeliveryAssign ==
//                         'Yes'
//                     ? (order.orderType == 'delivery' &&
//                         (role.contains('delivery_man')
//                             ? (Get.find<AuthController>().profileModel!.empId ==
//                                     order.deliveryManId &&
//                                 order.deliveryMan != '')
//                             : (role.contains('show_online_order'))))
//                     : order.orderType == 'delivery') {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }
//       ///////////    Filter with Room
//       else if (kdsController.selectedMainMenu == 4) {
//         if (kdsController.selectedSubMenu == 1) {
//           if (order.fOrderStatus == 0 ||
//               order.fOrderStatus == 1 ||
//               order.fOrderStatus == 2 ||
//               order.fOrderStatus == 7) {
//             if (searchController.text.isEmpty) {
//               if (order.restaurantTable != null &&
//                   order.restaurantTable!.rtype == 'RM') {
//                 return true;
//               }
//             } else if ((Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('table no') &&
//                     (order.restaurantTable != null &&
//                         order.restaurantTable!.tableNo != '' &&
//                         (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.restaurantTable!.title!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                         (order.userName
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase())) ||
//                     (order.userId != null &&
//                         (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.user!.lName!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('phone no') &&
//                     (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//               if (order.restaurantTable != null &&
//                   order.restaurantTable!.rtype == 'RM') {
//                 return true;
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 2) {
//           if (order.fOrderStatus == 5 ||
//               (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .defOrdStatus ==
//                       5
//                   ? order.fOrderStatus == 7
//                   : order.fOrderStatus == 5)) {
//             if (searchController.text.isEmpty) {
//               if (order.restaurantTable != null &&
//                   order.restaurantTable!.rtype == 'RM') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.userId != null && (order.user!.phone!.length > 2 && order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if (order.restaurantTable != null &&
//                     order.restaurantTable!.rtype == 'RM') {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }
//       ////////////////   Filter with All
//       else if (kdsController.selectedMainMenu == 3) {
//         if (kdsController.selectedSubMenu == 1) {
//           if (order.fOrderStatus == 0 ||
//               order.fOrderStatus == 1 ||
//               order.fOrderStatus == 2 ||
//               (restaurant.isShowOrderConfirmTab == 'No' &&
//                   order.fOrderStatus == 7)) {
//             if (searchController.text.isEmpty) {
//               if ((order.restaurantTable != null &&
//                       order.restaurantTable!.rtype == 'RM') ||
//                   (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .isDeliveryAssign ==
//                           'Yes'
//                       ? (order.orderType == 'delivery' &&
//                           (role.contains('delivery_man')
//                               ? (Get.find<AuthController>()
//                                           .profileModel!
//                                           .empId ==
//                                       order.deliveryManId &&
//                                   order.deliveryMan != '')
//                               : (role.contains('show_online_order'))))
//                       : order.orderType == 'delivery') ||
//                   order.orderType == 'take_away' ||
//                   order.orderType == 'pos' ||
//                   order.orderType == 'WalkIn' ||
//                   order.orderType == 'dinein') {
//                 return true;
//               }
//             } else if ((Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .searchBy!
//                         .contains('table no') &&
//                     (order.restaurantTable != null &&
//                         order.restaurantTable!.tableNo != '' &&
//                         (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.restaurantTable!.title!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                         (order.userName
//                             .toUpperCase()
//                             .contains(searchController.text.toUpperCase())) ||
//                     (order.userId != null &&
//                         (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                             order.user!.lName!.toUpperCase().contains(
//                                 searchController.text.toUpperCase())))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('phone no') &&
//                     (order.deliveryAddress != null &&
//                         order.deliveryAddress!.contactPersonNumber!.length > 2 &&
//                         order.deliveryAddress!.contactPersonNumber!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                 (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//               if ((order.restaurantTable != null &&
//                       order.restaurantTable!.rtype == 'RM') ||
//                   (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .isDeliveryAssign ==
//                           'Yes'
//                       ? (order.orderType == 'delivery' &&
//                           (role.contains('delivery_man')
//                               ? (Get.find<AuthController>()
//                                           .profileModel!
//                                           .empId ==
//                                       order.deliveryManId &&
//                                   order.deliveryMan != '')
//                               : (role.contains('show_online_order'))))
//                       : order.orderType == 'delivery') ||
//                   order.orderType == 'take_away' ||
//                   order.orderType == 'pos' ||
//                   order.orderType == 'WalkIn' ||
//                   order.orderType == 'dinein') {
//                 return true;
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 2) {
//           if (order.fOrderStatus == 5 ||
//               (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .defOrdStatus ==
//                       5
//                   ? (restaurant.isShowOrderConfirmTab == 'No' &&
//                       order.fOrderStatus == 7)
//                   : order.fOrderStatus == 5)) {
//             if (searchController.text.isEmpty) {
//               if ((order.restaurantTable != null &&
//                       order.restaurantTable!.rtype == 'RM') ||
//                   (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .isDeliveryAssign ==
//                           'Yes'
//                       ? (order.orderType == 'delivery' &&
//                           (role.contains('delivery_man')
//                               ? (Get.find<AuthController>()
//                                           .profileModel!
//                                           .empId ==
//                                       order.deliveryManId &&
//                                   order.deliveryMan != '')
//                               : (role.contains('show_online_order'))))
//                       : order.orderType == 'delivery') ||
//                   order.orderType == 'take_away' ||
//                   order.orderType == 'pos' ||
//                   order.orderType == 'WalkIn' ||
//                   order.orderType == 'dinein') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonNumber!.length > 2 &&
//                           order.deliveryAddress!.contactPersonNumber!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if ((order.restaurantTable != null &&
//                         order.restaurantTable!.rtype == 'RM') ||
//                     (Get.find<AuthController>()
//                                 .profileModel!
//                                 .restaurants!
//                                 .first
//                                 .isDeliveryAssign ==
//                             'Yes'
//                         ? (order.orderType == 'delivery' &&
//                             (role.contains('delivery_man')
//                                 ? (Get.find<AuthController>()
//                                             .profileModel!
//                                             .empId ==
//                                         order.deliveryManId &&
//                                     order.deliveryMan != '')
//                                 : (role.contains('show_online_order'))))
//                         : order.orderType == 'delivery') ||
//                     order.orderType == 'take_away' ||
//                     order.orderType == 'pos' ||
//                     order.orderType == 'WalkIn' ||
//                     order.orderType == 'dinein') {
//                   return true;
//                 }
//               }
//             }
//           }
//         } else if (kdsController.selectedSubMenu == 0) {
//           if (order.fOrderStatus == 7) {
//             if (searchController.text.isEmpty) {
//               if ((order.restaurantTable != null &&
//                       order.restaurantTable!.rtype == 'RM') ||
//                   (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .isDeliveryAssign ==
//                           'Yes'
//                       ? (order.orderType == 'delivery' &&
//                           (role.contains('delivery_man')
//                               ? (Get.find<AuthController>()
//                                           .profileModel!
//                                           .empId ==
//                                       order.deliveryManId &&
//                                   order.deliveryMan != '')
//                               : (role.contains('show_online_order'))))
//                       : order.orderType == 'delivery') ||
//                   order.orderType == 'take_away' ||
//                   order.orderType == 'pos' ||
//                   order.orderType == 'WalkIn' ||
//                   order.orderType == 'dinein') {
//                 return true;
//               }
//             } else {
//               if ((Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('table no') &&
//                       (order.restaurantTable != null &&
//                           order.restaurantTable!.tableNo != '' &&
//                           (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.restaurantTable!.title!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
//                           (order.userName
//                               .toUpperCase()
//                               .contains(searchController.text.toUpperCase())) ||
//                       (order.userId != null &&
//                           (order.user!.fName!.toUpperCase().contains(searchController.text.toUpperCase()) ||
//                               order.user!.lName!.toUpperCase().contains(
//                                   searchController.text.toUpperCase())))) ||
//                   (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .searchBy!
//                           .contains('phone no') &&
//                       (order.deliveryAddress != null &&
//                           order.deliveryAddress!.contactPersonNumber!.length > 2 &&
//                           order.deliveryAddress!.contactPersonNumber!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(searchController.text.toUpperCase())))) ||

//                   // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//                   (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(searchController.text.toUpperCase())))) {
//                 if ((order.restaurantTable != null &&
//                         order.restaurantTable!.rtype == 'RM') ||
//                     (Get.find<AuthController>()
//                                 .profileModel!
//                                 .restaurants!
//                                 .first
//                                 .isDeliveryAssign ==
//                             'Yes'
//                         ? (order.orderType == 'delivery' &&
//                             (role.contains('delivery_man')
//                                 ? (Get.find<AuthController>()
//                                             .profileModel!
//                                             .empId ==
//                                         order.deliveryManId &&
//                                     order.deliveryMan != '')
//                                 : (role.contains('show_online_order'))))
//                         : order.orderType == 'delivery') ||
//                     order.orderType == 'take_away' ||
//                     order.orderType == 'pos' ||
//                     order.orderType == 'WalkIn' ||
//                     order.orderType == 'dinein') {
//                   return true;
//                 }
//               }
//             }
//           }
//         }
//       }

//       return false;
//     }).map((order) {
//       // Now return the widget directly
//       return TabletWaiterOrderList(
//         _subscriptionBtStatus,
//         searchOrder: searchController,
//         searchTable: searchTable,
//         flutterTit: flutterTts,
//         order: order,
//         isWaiter: true,
//       );
//     }).toList(),
//   );
// }

// //    import 'dart:async';

// // import 'package:mygenie_restaurant/controller/auth_controller.dart';
// // import 'package:mygenie_restaurant/controller/kds_controller.dart';
// // import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/order_list/tablet_order_list.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// // import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:get/get.dart';

// // Widget showConfigOrderList(
// //     BuildContext context,
// //     KdsController kdsController,
// //     TextEditingController searchController,
// //     StreamSubscription<BTStatus> _subscriptionBtStatus,
// //     TextEditingController searchTable,
// //     FlutterTts flutterTts) {
// //   return StaggeredGrid.count(
// //     crossAxisCount:
// //         MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 2,
// //     crossAxisSpacing: 15,
// //     mainAxisSpacing: 15,
// //     children: kdsController.getWaiterOrderListResponse.orders.where((order) {
// //       // Filter with dine in
// //       if (kdsController.selectedMainMenu == 0) {
// //         if (kdsController.selectedSubMenu == 1) {
// //           if (order.fOrderStatus == 0 ||
// //               order.fOrderStatus == 1 ||
// //               order.fOrderStatus == 2 ||
// //               order.fOrderStatus == 7) {
// //             if (searchController.text.isEmpty) {
// //               if (((order.restaurantTable != null
// //                       ? order.restaurantTable.rtype != 'RM'
// //                       : true) &&
// //                   (order?.orderType == 'pos' ||
// //                       order?.orderType == 'WalkIn' ||
// //                       order?.orderType == 'dinein'))) {
// //                 return true;
// //               }
// //             } else if ((order.restaurantTable != null &&
// //                         order.restaurantTable.tableNo != '' &&
// //                         (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()) ||
// //                             order.restaurantTable.title.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()))) ||
// //                     (
// //                         order.userName.length > 2 &&
// //                         order.userName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())) ||
// //                     (order.userId != null &&
// //                         order.user.fName.length > 2 &&
// //                         (order.user.fName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase()))) ||
// //                     (order.userId != null &&
// //                         (order.user.phone.length > 2 &&
// //                             order.user.phone
// //                                 .toUpperCase()
// //                                 .contains(searchController.text.toUpperCase())))
// //                 // ||
// //                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
// //                 // (order.id
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())) ||
// //                 // (order.restaurantOrderId
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())
// //                 //     )
// //                 ) {
// //               if (((order.restaurantTable != null
// //                       ? order.restaurantTable.rtype != 'RM'
// //                       : true) &&
// //                   (order?.orderType == 'pos' ||
// //                       order?.orderType == 'WalkIn' ||
// //                       order?.orderType == 'dinein'))) {
// //                 return true;
// //               }
// //             }
// //           }
// //         } else if (kdsController.selectedSubMenu == 2) {
// //           if (order.fOrderStatus == 5 ||
// //               (Get.find<AuthController>()
// //                           .profileModel
// //                           .restaurants
// //                           .first
// //                           .defOrdStatus ==
// //                       5
// //                   ? order.fOrderStatus == 7
// //                   : order.fOrderStatus == 5)) {
// //             if (searchController.text.isEmpty) {
// //               if ((order.restaurantTable != null
// //                       ? order.restaurantTable.rtype != 'RM'
// //                       : true) &&
// //                   (order?.orderType == 'pos' ||
// //                       order?.orderType == 'WalkIn' ||
// //                       order?.orderType == 'dinein')) {
// //                 return true;
// //               }
// //             } else {
// //               if ((order.restaurantTable != null &&
// //                           order.restaurantTable.tableNo != '' &&
// //                           (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                   searchController.text.toUpperCase()) ||
// //                               order.restaurantTable.title
// //                                   .toUpperCase()
// //                                   .contains(
// //                                       searchController.text.toUpperCase()))) ||
// //                       (
// //                           order.userName.length > 2 &&
// //                           order.userName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())) ||
// //                       (order.userId != null &&
// //                           order.user.fName.length > 2 &&
// //                           (order.user.fName.toUpperCase().contains(
// //                               searchController.text.toUpperCase()))) ||
// //                       (order.userId != null &&
// //                           order.user.phone.length > 2 &&
// //                           (order.user.phone
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())))
// //                   // ||
// //                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
// //                   // order.restaurantOrderId
// //                   //     .toUpperCase()
// //                   //     .contains(searchController.text.toUpperCase())
// //                   ) {
// //                 if ((order.restaurantTable != null
// //                         ? order.restaurantTable.rtype != 'RM'
// //                         : true) &&
// //                     (order?.orderType == 'pos' ||
// //                         order?.orderType == 'WalkIn' ||
// //                         order?.orderType == 'dinein')) {
// //                   return true;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }

// //       //////////// Filter with Take Away
// //       else if (kdsController.selectedMainMenu == 1) {
// //         if (kdsController.selectedSubMenu == 1) {
// //           if (order.fOrderStatus == 0 ||
// //               order.fOrderStatus == 1 ||
// //               order.fOrderStatus == 2 ||
// //               order.fOrderStatus == 7) {
// //             if (searchController.text.isEmpty) {
// //               if (order?.orderType == 'take_away') {
// //                 return true;
// //               }
// //             } else if ((order.restaurantTable != null &&
// //                         order.restaurantTable.tableNo != '' &&
// //                         (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()) ||
// //                             order.restaurantTable.title.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()))) ||
// //                     (
// //                         order.userName.length > 2 &&
// //                         order.userName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())) ||
// //                     (order.userId != null &&
// //                         order.user.fName.length > 2 &&
// //                         (order.user.fName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase()))) ||
// //                     (order.userId != null &&
// //                         order.user.phone.length > 2 &&
// //                         (order.user.phone
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())))
// //                 // ||
// //                 // (order.id
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())) ||
// //                 // (order.restaurantOrderId
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase()))
// //                 ) {
// //               if (order?.orderType == 'take_away') {
// //                 return true;
// //               }
// //             }
// //           }
// //         } else if (kdsController.selectedSubMenu == 2) {
// //           if (order.fOrderStatus == 5 ||
// //               (Get.find<AuthController>()
// //                           .profileModel
// //                           .restaurants
// //                           .first
// //                           .defOrdStatus ==
// //                       5
// //                   ? order.fOrderStatus == 7
// //                   : order.fOrderStatus == 5)) {
// //             if (searchController.text.isEmpty) {
// //               if (order?.orderType == 'take_away') {
// //                 return true;
// //               }
// //             } else {
// //               if ((order.restaurantTable != null &&
// //                           order.restaurantTable.tableNo != '' &&
// //                           (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                   searchController.text.toUpperCase()) ||
// //                               order.restaurantTable.title
// //                                   .toUpperCase()
// //                                   .contains(
// //                                       searchController.text.toUpperCase()))) ||
// //                       (
// //                           order.userName.length > 2 &&
// //                           order.userName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())) ||
// //                       (order.userId != null &&
// //                           order.user.fName.length > 2 &&
// //                           (order.user.fName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())))
// //                   //  ||
// //                   // (order.userId != null &&order.user.phone.length>5&&
// //                   //     (order.user.phone
// //                   //         .toUpperCase()
// //                   //         .contains(searchController.text.toUpperCase()))) ||
// //                   // // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
// //                   // order.restaurantOrderId
// //                   //     .toUpperCase()
// //                   //     .contains(searchController.text.toUpperCase())
// //                   ) {
// //                 if (order?.orderType == 'take_away') {
// //                   return true;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }
// //       ///////////    Filter with delivery
// //       else if (kdsController.selectedMainMenu == 2) {
// //         if (kdsController.selectedSubMenu == 1) {
// //           if (order.fOrderStatus == 0 ||
// //               order.fOrderStatus == 1 ||
// //               order.fOrderStatus == 2 ||
// //               order.fOrderStatus == 7) {
// //             if (searchController.text.isEmpty) {
// //               if (order?.orderType == 'delivery') {
// //                 return true;
// //               }
// //             } else if ((order.restaurantTable != null &&
// //                         order.restaurantTable.tableNo != '' &&
// //                         (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()) ||
// //                             order.restaurantTable.title.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()))) ||
// //                     (
// //                         order.userName.length > 2 &&
// //                         order.userName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())) ||
// //                     (order.userId != null &&
// //                         order.user.fName.length > 2 &&
// //                         (order.user.fName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase()))) ||
// //                     (order.userId != null &&
// //                         order.user.phone.length > 2 &&
// //                         (order.user.phone
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())))
// //                 // ||
// //                 // (order.id
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())) ||
// //                 // (order.restaurantOrderId
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase()))
// //                 ) {
// //               if (order?.orderType == 'delivery') {
// //                 return true;
// //               }
// //             }
// //           }
// //         } else if (kdsController.selectedSubMenu == 2) {
// //           if (order.fOrderStatus == 5 ||
// //               (Get.find<AuthController>()
// //                           .profileModel
// //                           .restaurants
// //                           .first
// //                           .defOrdStatus ==
// //                       5
// //                   ? order.fOrderStatus == 7
// //                   : order.fOrderStatus == 5)) {
// //             if (searchController.text.isEmpty) {
// //               if (order?.orderType == 'delivery') {
// //                 return true;
// //               }
// //             } else {
// //               if ((order.restaurantTable != null &&
// //                           order.restaurantTable.tableNo != '' &&
// //                           (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                   searchController.text.toUpperCase()) ||
// //                               order.restaurantTable.title
// //                                   .toUpperCase()
// //                                   .contains(
// //                                       searchController.text.toUpperCase()))) ||
// //                       (
// //                           order.userName.length > 2 &&
// //                           order.userName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())) ||
// //                       (order.userId != null &&
// //                           order.user.fName.length > 2 &&
// //                           (order.user.fName.toUpperCase().contains(
// //                               searchController.text.toUpperCase()))) ||
// //                       (order.userId != null &&
// //                           order.user.phone.length > 2 &&
// //                           (order.user.phone
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())))
// //                   //  ||
// //                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
// //                   // order.restaurantOrderId
// //                   //     .toUpperCase()
// //                   //     .contains(searchController.text.toUpperCase())
// //                   ) {
// //                 if (order?.orderType == 'delivery') {
// //                   return true;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }
// //       ///////////    Filter with Room
// //       else if (kdsController.selectedMainMenu == 4) {
// //         if (kdsController.selectedSubMenu == 1) {
// //           if (order.fOrderStatus == 0 ||
// //               order.fOrderStatus == 1 ||
// //               order.fOrderStatus == 2 ||
// //               order.fOrderStatus == 7) {
// //             if (searchController.text.isEmpty) {
// //               if (order.restaurantTable != null &&
// //                   order.restaurantTable.rtype == 'RM') {
// //                 return true;
// //               }
// //             } else if ((order.restaurantTable != null &&
// //                         order.restaurantTable.tableNo != '' &&
// //                         (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()) ||
// //                             order.restaurantTable.title.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()))) ||
// //                     (
// //                         order.userName.length > 2 &&
// //                         order.userName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())) ||
// //                     (order.userId != null &&
// //                         order.user.fName.length > 2 &&
// //                         (order.user.fName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase()))) ||
// //                     (order.userId != null &&
// //                         order.user.phone.length > 2 &&
// //                         (order.user.phone
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())))
// //                 // ||

// //                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
// //                 // (order.id
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())) ||
// //                 // (order.restaurantOrderId
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase()))
// //                 ) {
// //               if (order.restaurantTable != null &&
// //                   order.restaurantTable.rtype == 'RM') {
// //                 return true;
// //               }
// //             }
// //           }
// //         } else if (kdsController.selectedSubMenu == 2) {
// //           if (order.fOrderStatus == 5 ||
// //               (Get.find<AuthController>()
// //                           .profileModel
// //                           .restaurants
// //                           .first
// //                           .defOrdStatus ==
// //                       5
// //                   ? order.fOrderStatus == 7
// //                   : order.fOrderStatus == 5)) {
// //             if (searchController.text.isEmpty) {
// //               if (order.restaurantTable != null &&
// //                   order.restaurantTable.rtype == 'RM') {
// //                 return true;
// //               }
// //             } else {
// //               if ((order.restaurantTable != null &&
// //                           order.restaurantTable.tableNo != '' &&
// //                           (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                   searchController.text.toUpperCase()) ||
// //                               order.restaurantTable.title
// //                                   .toUpperCase()
// //                                   .contains(
// //                                       searchController.text.toUpperCase()))) ||
// //                       (
// //                           order.userName.length > 2 &&
// //                           order.userName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())) ||
// //                       (order.userId != null &&
// //                           order.user.fName.length > 2 &&
// //                           (order.user.fName.toUpperCase().contains(
// //                               searchController.text.toUpperCase()))) ||
// //                       (order.userId != null &&
// //                           order.user.phone.length > 2 &&
// //                           (order.user.phone
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())))
// //                   // ||
// //                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
// //                   // order.restaurantOrderId
// //                   //     .toUpperCase()
// //                   //     .contains(searchController.text.toUpperCase())
// //                   ) {
// //                 if (order.restaurantTable != null &&
// //                     order.restaurantTable.rtype == 'RM') {
// //                   return true;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }
// //       ////////////////   Filter with All
// //       else if (kdsController.selectedMainMenu == 3) {
// //         if (kdsController.selectedSubMenu == 1) {
// //           if (order.fOrderStatus == 0 ||
// //               order.fOrderStatus == 1 ||
// //               order.fOrderStatus == 2 ||
// //               order.fOrderStatus == 7) {
// //             if (searchController.text.isEmpty) {
// //               if ((order.restaurantTable != null &&
// //                       order.restaurantTable.rtype == 'RM') ||
// //                   order.orderType == 'delivery' ||
// //                   order.orderType == 'take_away' ||
// //                   order?.orderType == 'pos' ||
// //                   order?.orderType == 'WalkIn' ||
// //                   order?.orderType == 'dinein') {
// //                 return true;
// //               }
// //             } else if ((order.restaurantTable != null &&
// //                         order.restaurantTable.tableNo != '' &&
// //                         (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()) ||
// //                             order.restaurantTable.title.toUpperCase().contains(
// //                                 searchController.text.toUpperCase()))) ||
// //                     (
// //                         order.userName.length > 2 &&
// //                         order.userName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())) ||
// //                     (order.userId != null &&
// //                         order.user.fName.length > 2 &&
// //                         (order.user.fName
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase()))) ||
// //                     (order.userId != null &&
// //                         order.user.phone.length > 2 &&
// //                         (order.user.phone
// //                             .toUpperCase()
// //                             .contains(searchController.text.toUpperCase())))
// //                 // ||
// //                 // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
// //                 // (order.id
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase())) ||
// //                 // (order.restaurantOrderId
// //                 //     .toUpperCase()
// //                 //     .contains(searchController.text.toUpperCase()))
// //                 ) {
// //               if ((order.restaurantTable != null &&
// //                       order.restaurantTable.rtype == 'RM') ||
// //                   order.orderType == 'delivery' ||
// //                   order.orderType == 'take_away' ||
// //                   order?.orderType == 'pos' ||
// //                   order?.orderType == 'WalkIn' ||
// //                   order?.orderType == 'dinein') {
// //                 return true;
// //               }
// //             }
// //           }
// //         } else if (kdsController.selectedSubMenu == 2) {
// //           if (order.fOrderStatus == 5 ||
// //               (Get.find<AuthController>()
// //                           .profileModel
// //                           .restaurants
// //                           .first
// //                           .defOrdStatus ==
// //                       5
// //                   ? order.fOrderStatus == 7
// //                   : order.fOrderStatus == 5)) {
// //             if (searchController.text.isEmpty) {
// //               if ((order.restaurantTable != null &&
// //                       order.restaurantTable.rtype == 'RM') ||
// //                   order.orderType == 'delivery' ||
// //                   order.orderType == 'take_away' ||
// //                   order?.orderType == 'pos' ||
// //                   order?.orderType == 'WalkIn' ||
// //                   order?.orderType == 'dinein') {
// //                 return true;
// //               }
// //             } else {
// //               if ((order.restaurantTable != null &&
// //                           order.restaurantTable.tableNo != '' &&
// //                           (order.restaurantTable.tableNo.toUpperCase().contains(
// //                                   searchController.text.toUpperCase()) ||
// //                               order.restaurantTable.title
// //                                   .toUpperCase()
// //                                   .contains(
// //                                       searchController.text.toUpperCase()))) ||
// //                       (
// //                           order.userName.length > 2 &&
// //                           order.userName
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())) ||
// //                       (order.userId != null &&
// //                           order.user.fName.length > 2 &&
// //                           (order.user.fName.toUpperCase().contains(
// //                               searchController.text.toUpperCase()))) ||
// //                       (order.userId != null &&
// //                           order.user.phone.length > 2 &&
// //                           (order.user.phone
// //                               .toUpperCase()
// //                               .contains(searchController.text.toUpperCase())))
// //                   // ||
// //                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
// //                   // order.restaurantOrderId
// //                   //     .toUpperCase()
// //                   //     .contains(searchController.text.toUpperCase())
// //                   ) {
// //                 if ((order.restaurantTable != null &&
// //                         order.restaurantTable.rtype == 'RM') ||
// //                     order.orderType == 'delivery' ||
// //                     order.orderType == 'take_away' ||
// //                     order?.orderType == 'pos' ||
// //                     order?.orderType == 'WalkIn' ||
// //                     order?.orderType == 'dinein') {
// //                   return true;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }

// //       return false;
// //     }).map((order) {
// //       // Now return the widget directly
// //       return TabletWaiterOrderList(
// //         _subscriptionBtStatus,
// //         searchOrder: searchController,
// //         searchTable: searchTable,
// //         flutterTit: flutterTts,
// //         order: order,
// //         isWaiter: true,
// //       );
// //     }).toList(),
// //   );
// // }
