import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/widget/Kds_order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class KdsOrderTypeListview extends StatelessWidget {
  int? orderStatus;
  final KdsController kdsController;
  final TextEditingController searchController;
  final PrinterManager printerManager;
  List<int>? pendingTask;
  final BTStatus blutoothStatus;
  final FlutterTts flutterTts;
  final Function isPrintKot;

  KdsOrderTypeListview({
    super.key,
    this.orderStatus,
    required this.kdsController,
    required this.searchController,
    required this.printerManager,
    this.pendingTask,
    required this.blutoothStatus,
    required this.flutterTts,
    required this.isPrintKot,
  });

  @override
  Widget build(BuildContext context) {
    int defOrderStatus = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .defOrdStatus!;
    return StaggeredGrid.count(
      crossAxisCount: 1,
      // crossAxisSpacing: 15,
      // mainAxisSpacing: 15,
      children:
          kdsController.getStationOrderListResponse!.orders!.where((order) {
        orderStatus = order.orderDetailsOrder!.fOrderStatus == 3
            ? 3
            : order.orderDetailsOrder!.fOrderStatus == 6
                ? 6:order.orderDetailsOrder!.fOrderStatus == 8?8
                : order.orderDetailsOrder!.stationOrderStatus![
                    '${Get.find<AuthController>().profileModel!.roleName!.toUpperCase()}'];
        // Filter with dine in
        if (kdsController.selectedMainMenu == 0) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein'))) {
                  return true;
                }
              } else if ((Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('table no') &&
                      (order.restaurantTable != null &&
                          order.restaurantTable?.tableNo != null &&
                          order.restaurantTable?.tableNo != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                      ((order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase())) ??
                          false))) {
                if (((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein'))) {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein')) {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            order.restaurantTable?.tableNo != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                        ((order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase())) ??
                            false))) {
                  if ((order.restaurantTable != null
                          ? order.restaurantTable?.rtype != 'RM'
                          : true) &&
                      (order.orderDetailsOrder?.orderType == 'pos' ||
                          order.orderDetailsOrder?.orderType == 'WalkIn' ||
                          order.orderDetailsOrder?.orderType == 'dinein')) {
                    return true;
                  }
                }
              }
            }
          }
        }

        //////////// Filter with Take Away
        else if (kdsController.selectedMainMenu == 1) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              } else if (((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') ?? false) &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') ?? false) &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') ?? false) &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                      ((order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase())) ??
                          false))) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (orderStatus == 2 ||
                (((Get.find<AuthController>()
                                    .profileModel
                                    ?.restaurants
                                    ?.first
                                    .defOrdStatus ??
                                0) ==
                            5 ||
                        (Get.find<AuthController>()
                                    .profileModel
                                    ?.restaurants
                                    ?.first
                                    .defOrdStatus ??
                                0) ==
                            2)
                    ? (orderStatus == 7 || orderStatus == 5)
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              } else {
                if (((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') ?? false) &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') ?? false) &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') ?? false) &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                        ((order.orderDetailsOrder?.restaurantOrderId
                                ?.toUpperCase()
                                .contains(searchController.text.toUpperCase())) ??
                            false))) {
                  if (order.orderDetailsOrder?.orderType == 'take_away') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ///////////    Filter with delivery
        else if (kdsController.selectedMainMenu == 2) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty &&
                  order.orderDetailsOrder?.orderType == 'delivery') {
                return true;
              } else if ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .searchBy
                              ?.contains('table no') ==
                          true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      (order.deliveryAddress != null &&
                          (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                              false))) ||
                  // (
                  //     order.userName
                  //         .toUpperCase()
                  //         .contains(searchController.text.toUpperCase())) ||
                  // (order.userId != null &&
                  //     (order.user.fName
                  //             .toUpperCase()
                  //             .contains(searchController.text.toUpperCase()) ||
                  //         order.user.lName
                  //             .toUpperCase()
                  //             .contains(searchController.text.toUpperCase()))) ||

                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.deliveryAddress != null &&
                          ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                              (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true &&
                      (order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) {
                if (order.orderDetailsOrder?.orderType == 'delivery') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder!.orderType == 'delivery') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        (order.deliveryAddress != null &&
                            (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                false))) ||
                    // (
                    //     order.userName
                    //         .toUpperCase()
                    //         .contains(searchController.text.toUpperCase())) ||
                    // (order.userId != null &&
                    //     (order.user.fName
                    //             .toUpperCase()
                    //             .contains(searchController.text.toUpperCase()) ||
                    //         order.user.lName
                    //             .toUpperCase()
                    //             .contains(searchController.text.toUpperCase()))) ||

                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.deliveryAddress != null &&
                            ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                                (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true &&
                        (order.orderDetailsOrder?.restaurantOrderId
                                ?.toUpperCase()
                                .contains(searchController.text.toUpperCase()) ??
                            false))) {
                  if (order.orderDetailsOrder?.orderType == 'delivery') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ///////////    Filter with Room
        else if (kdsController.selectedMainMenu == 4) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              } else if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                      ((order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase())) ??
                          false))) {
                if (order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') ?? false) &&
                        ((order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase())) ??
                            false))) {
                  if (order.restaurantTable?.rtype == 'RM') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ////////////////   Filter with All
        else if (kdsController.selectedMainMenu == 3) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              } else if ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .searchBy
                              ?.contains('table no') ==
                          true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.deliveryAddress != null &&
                          ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                              (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      (order.deliveryAddress != null && (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true && (order.orderDetailsOrder?.userId != null && (order.user?.phone?.length ?? 0) > 2 && (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true && (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.deliveryAddress != null &&
                            ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                                (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        (order.deliveryAddress != null &&
                            (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true && (order.orderDetailsOrder?.userId != null && (order.user?.phone?.length ?? 0) > 2 && (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true && (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) {
                  if ((order.restaurantTable != null &&
                          order.restaurantTable?.rtype == 'RM') ||
                      order.orderDetailsOrder?.orderType == 'delivery' ||
                      order.orderDetailsOrder?.orderType == 'take_away' ||
                      order.orderDetailsOrder?.orderType == 'pos' ||
                      order.orderDetailsOrder?.orderType == 'WalkIn' ||
                      order.orderDetailsOrder?.orderType == 'dinein') {
                    return true;
                  }
                }
              }
            }
          }
        }
        return false;
      }).map((order) {
        // Now return the widget directly
        return KdsOrderList(
          flutterTts: flutterTts,
          order: order,
          orderStatus: orderStatus,
          blutoothStatus: blutoothStatus,
          pendingTask: pendingTask,
          printerManager: printerManager,
          isPrintKot: isPrintKot,
        );
      }).toList(),
    );
  }
}
