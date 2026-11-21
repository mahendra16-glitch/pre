import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as prefix;
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/widget/swiggy_order_view.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/category_wise_orderlist.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../helper/colors.dart';

class OrderViewScreen extends StatefulWidget {
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  StreamSubscription<BTStatus>? singleSplitBleStatus;
  TextEditingController? searchController;
  OrderViewScreen({
    super.key,
    this.subscriptionBtStatus,
    this.singleSplitBleStatus,
    TextEditingController? searchController,
  }) : searchController = searchController ?? TextEditingController();

  @override
  State<OrderViewScreen> createState() => _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {
  // TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int splitCurrentPrintIndex = 0;
  List<int>? pendingTask;
  FlutterTts flutterTts = FlutterTts();
  List<bool> isSplitSelectPrinterList = [];
  List<bool> isSplitPrinterProccessingList = [];
  List<bool> isSplitPrintedList = [];
  PrinterManager _printerManager = PrinterManager.instance;
  bool isSkipFirstTimeOrder = false;
  bool isConnect = true;
  bool isFailedPrint = false;
  List<List<OrderDetails>> cartProductList = [];
  List<List<OrderDetails>> failedCartProductList = [];
  int currentPrintIndex = 0;
  List<bool> skipFailedList = [];
  PackageInfo? packageInfo;

  // final int pageSize = 20;
  // int currentCount = 20;

  // List<OrderList> filteredOrders = [];
  Future<void> initData() async {
    // print('bill ip ${Get.find<AuthController>().profileModel.macBillPrinterIp}');
    // _showNotification(RemoteMessage(
    //     notification: RemoteNotification(title: 'my genie', body: 'test')));
    Get.find<KdsController>().resetSplitBill();
    await Get.find<TableController>().getTableListFromLocally();

    await Get.find<KdsController>().getWaiterPOSOrderList();
    // if (Get.find<AuthController>()
    //         .profileModel!
    //         .restaurants!
    //         .first
    //         .defOrdStatus ==
    //     5) {
    Get.find<KdsController>().setSubMenuIndex(4);
    // }
    if (Get.find<AuthController>().profileModel!.restaurants!.first.logoPath !=
        '') {
      final response = await http.get(Uri.parse(Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .logoPath!));
      if (response.statusCode == 200) {
        // Decode the image data
        final image = prefix.decodeImage(response.bodyBytes);
        if (image != null) {
          // Resize the image to fit the 58mm printer's width (around 240px)
          logoHelper.logoUrlPrint =
              prefix.copyResize(image, width: 240); // Adjusted for 58mm
        }
      }
    }
    packageInfo = await PackageInfo.fromPlatform();

    if (mounted) setState(() {});
  }

  initCallApi() async {
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .isShowPopularCategory ==
        'Yes') await Get.find<ProductController>().getPopularFoodList();
    await initData();
  }

  // @override
  // void initState() {
  //   super.initState();

  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels >=
  //         _scrollController.position.maxScrollExtent - 200) {
  //       _loadMore();
  //     }
  //   });
  // }

  // void _loadMore() {
  //   if (currentCount >= filteredOrders.length) return;

  //   setState(() {
  //     currentCount =
  //         (currentCount + pageSize).clamp(0, filteredOrders.length);
  //   });
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Get.find<TableController>().getTableListFromLocally();

                return await initData();
              },
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 0),
                  child: cookingTabBar(),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(
                    height: 1,
                    color: Color(0xFFE6E6E6),
                  ),
                ),
                // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    controller: _scrollController,
                    child: GetBuilder<KdsController>(
                        // id: 'order_${order.id}',
                        builder: (kdsController) {
                      return GetBuilder<SwiggyController>(
                          builder: (swiggyController) {
                        return Column(
                          children: [
                            if (kdsController.selectedMainMenu == 3 ||
                                kdsController.selectedMainMenu == 2)
                              SwiggyOrderView(),
                            kdsController.getWaiterOrderListResponse == null
                                ? const SizedBox.shrink()
                                : kdsController.isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : kdsController.splitOrderList.isNotEmpty
                                        ? ListView.builder(
                                            padding: EdgeInsets.zero,
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: kdsController
                                                .splitOrderList.length,
                                            itemBuilder:
                                                (BuildContext context, int i) {
                                              OrderList order = kdsController
                                                  .splitOrderList[i];

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: WaiterOrderList(
                                                    widget.subscriptionBtStatus,
                                                    isSplitPrintedList:
                                                        isSplitPrintedList,
                                                    printSplitBill:
                                                        (String data) async {},
                                                    isSplitPrinterProccessingList:
                                                        isSplitPrinterProccessingList,
                                                    isSplitSelectPrinterList:
                                                        isSplitSelectPrinterList,
                                                    printerManager:
                                                        _printerManager,
                                                    splitCurrentPrintIndex:
                                                        splitCurrentPrintIndex,
                                                    searchOrder: widget
                                                        .searchController!,
                                                    flutterTit: flutterTts,
                                                    order: order,
                                                    isWaiter: true),
                                              );
                                            })
                                        : orderListContent(kdsController),
                          ],
                        );
                      });
                      // WaiterOrderList(
                      // orderList: kdsController.getOrderListResponse.orders
                      // );
                    }),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget orderListContent(KdsController kdsController) {
    final auth = Get.find<AuthController>();
    final restaurant = auth.profileModel!.restaurants!.first;
    final roles = auth.profileModel!.role ?? [];
    final empId = auth.profileModel!.empId;
    final searchText = widget.searchController!.text.trim().toUpperCase();

    bool matchesSearch(OrderList order) {
      if (searchText.isEmpty) return true;

      final searchBy = restaurant.searchBy ?? [];

      bool tableMatch = searchBy.contains('table no') &&
          order.restaurantTable != null &&
          (order.restaurantTable!.tableNo ?? '')
              .toUpperCase()
              .contains(searchText);

      bool orderIdMatch = searchBy.contains('order id') &&
          (order.restaurantOrderId ?? '').toUpperCase().contains(searchText);

      bool userMatch = searchBy.contains('user id') &&
          ((order.userName ?? '').toUpperCase().contains(searchText) ||
              (order.user != null &&
                  ('${order.user!.fName ?? ''} ${order.user!.lName ?? ''}')
                      .toUpperCase()
                      .contains(searchText)));

      bool phoneMatch = searchBy.contains('phone no') &&
          ((order.user?.phone ?? '').toUpperCase().contains(searchText) ||
              (order.deliveryAddress?.contactPersonNumber ?? '')
                  .toUpperCase()
                  .contains(searchText));

      bool deliveryNameMatch = order.deliveryAddress?.contactPersonName
              ?.toUpperCase()
              .contains(searchText) ??
          false;

      return tableMatch ||
          orderIdMatch ||
          userMatch ||
          phoneMatch ||
          deliveryNameMatch;
    }

    bool isDineIn(OrderList o) => ((o.orderType == 'pos' ||
            o.orderType == 'WalkIn' ||
            o.orderType == 'dinein') &&
        (o.restaurantTable != null ? o.restaurantTable!.rtype != 'RM' : true));

    bool isTakeAway(OrderList o) => o.orderType == 'take_away';

    bool isRoom(OrderList o) =>
        o.restaurantTable != null && o.restaurantTable!.rtype == 'RM';

    bool isDelivery(OrderList o) {
      if (restaurant.isDeliveryAssign == 'Yes') {
        if (roles.contains('delivery_man')) {
          return o.orderType == 'delivery' &&
              o.deliveryManId == empId &&
              o.deliveryMan != '';
        }
        return o.orderType == 'delivery' && roles.contains('show_online_order');
      }
      return o.orderType == 'delivery';
    }

    bool statusAllowed(OrderList o, List<int> allowed) {
      if (allowed.contains(o.fOrderStatus))
        return o.fOrderStatus == 7
            ? kdsController.selectedSubMenu == 7
                ? o.scheduleAt != null && o.scheduleAt != ''
                    ? true
                    : false
                : Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('confirm_order')
                    ? true
                    : false
            : true;
      if (restaurant.isShowOrderConfirmTab == 'No' &&
          o.fOrderStatus == 7 &&
          allowed.contains(7)) {
        return true;
      }
      return false;
    }

    bool filterOrder(OrderList order) {
      if (!matchesSearch(order)) return false;

      switch (kdsController.selectedMainMenu) {
        /// 🍽 DINE IN
        case 0:
          if (!isDineIn(order)) return false;
          break;

        /// 🥡 TAKE AWAY
        case 1:
          if (!isTakeAway(order)) return false;
          break;

        /// 🚚 DELIVERY
        case 2:
          if (!isDelivery(order)) return false;
          break;

        /// 📦 ALL
        case 3:
          if (!(isDineIn(order) ||
              isTakeAway(order) ||
              isDelivery(order) ||
              isRoom(order))) return false;
          break;

        /// 🏨 ROOM
        case 4:
          if (!isRoom(order)) return false;
          break;
      }

      switch (kdsController.selectedSubMenu) {
        case 1:
          return statusAllowed(order, [0, 2]);
        case 2:
          return statusAllowed(order, [5]);
        case 3:
          return statusAllowed(order, [1]);
        case 4:
          return statusAllowed(order, [0, 1, 2, 5, 7]);
        case 7:
          return statusAllowed(order, [7]);
        case 0:
          return statusAllowed(order, [7]);
        default:
          return false;
      }
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StaggeredGrid.count(
          crossAxisCount: isMobile(context)
              ? 1
              : isTablet(context)
                  ? 2
                  : 3,
          crossAxisSpacing: isMobile(context) ? 0 : 15,
          mainAxisSpacing: isMobile(context) ? 0 : 10,
          children: kdsController.getWaiterOrderListResponse!.orders!
              .where(filterOrder)
              .map((order) {
            return kdsController.selectedSubMenu == 4
                ? CategoryWiseOrderList(
                    widget.subscriptionBtStatus,
                    searchOrder: widget.searchController!,
                    flutterTit: flutterTts,
                    order: order,
                    isWaiter: true,
                  )
                : WaiterOrderList(
                    widget.subscriptionBtStatus,
                    searchOrder: widget.searchController!,
                    flutterTit: flutterTts,
                    order: order,
                    isWaiter: true,
                  );
          }).toList(),
        ));
  }
  // Widget orderListContent(KdsController kdsController) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: StaggeredGrid.count(
  //       crossAxisCount: isMobile(context)
  //           ? 1
  //           : isTablet(context)
  //               ? 2
  //               : 3,
  //       crossAxisSpacing: isMobile(context) ? 0 : 15,
  //       mainAxisSpacing: isMobile(context) ? 0 : 10,
  //       children:
  //           kdsController.getWaiterOrderListResponse!.orders!.where((order) {
  //         Restaurant restaurant =
  //             Get.find<AuthController>().profileModel!.restaurants!.first;
  //         List<String> role = Get.find<AuthController>().profileModel!.role!;
  //         // Filter with dine in
  //         if (kdsController.selectedMainMenu == 0) {
  //           if (kdsController.selectedSubMenu == 1) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 2 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein'))) {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein'))) {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 3) {
  //             if (order.fOrderStatus == 1) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein'))) {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein'))) {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 2) {
  //             if (order.fOrderStatus == 5 ||
  //                 (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .defOrdStatus ==
  //                         5
  //                     ? (restaurant.isShowOrderConfirmTab == 'No' &&
  //                         order.fOrderStatus == 7)
  //                     : order.fOrderStatus == 5)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if ((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein')) {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if ((order.restaurantTable != null
  //                           ? order.restaurantTable!.rtype != 'RM'
  //                           : true) &&
  //                       (order.orderType == 'pos' ||
  //                           order.orderType == 'WalkIn' ||
  //                           order.orderType == 'dinein')) {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 4) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 1 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 5 ||
  //                 order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if ((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein')) {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if ((order.restaurantTable != null
  //                           ? order.restaurantTable!.rtype != 'RM'
  //                           : true) &&
  //                       (order.orderType == 'pos' ||
  //                           order.orderType == 'WalkIn' ||
  //                           order.orderType == 'dinein')) {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 0) {
  //             if (order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if ((order.restaurantTable != null
  //                         ? order.restaurantTable!.rtype != 'RM'
  //                         : true) &&
  //                     (order.orderType == 'pos' ||
  //                         order.orderType == 'WalkIn' ||
  //                         order.orderType == 'dinein')) {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if ((order.restaurantTable != null
  //                           ? order.restaurantTable!.rtype != 'RM'
  //                           : true) &&
  //                       (order.orderType == 'pos' ||
  //                           order.orderType == 'WalkIn' ||
  //                           order.orderType == 'dinein')) {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }

  //         //////////// Filter with Take Away
  //         else if (kdsController.selectedMainMenu == 1) {
  //           if (kdsController.selectedSubMenu == 1) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 2 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 4) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 1 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 5 ||
  //                 order.fOrderStatus == 7 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 3) {
  //             if (order.fOrderStatus == 1) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 2) {
  //             if (order.fOrderStatus == 5 ||
  //                 (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .defOrdStatus ==
  //                         5
  //                     ? (restaurant.isShowOrderConfirmTab == 'No' &&
  //                         order.fOrderStatus == 7)
  //                     : order.fOrderStatus == 5)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if (order.orderType == 'take_away') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 0) {
  //             if (order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.orderType == 'take_away') {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if (order.orderType == 'take_away') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //         ///////////    Filter with delivery
  //         else if (kdsController.selectedMainMenu == 2) {
  //           if (kdsController.selectedSubMenu == 1) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 2 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!.toUpperCase().contains(widget.searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonName!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   // (
  //                   //     order.userName
  //                   //         .toUpperCase()
  //                   //         .contains(widget.searchController!.text.toUpperCase())) ||
  //                   // (order.userId != null &&
  //                   //     (order.user.fName
  //                   //             .toUpperCase()
  //                   //             .contains(widget.searchController!.text.toUpperCase()) ||
  //                   //         order.user.lName
  //                   //             .toUpperCase()
  //                   //             .contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') &&
  //                       (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 4) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 1 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 5 ||
  //                 order.fOrderStatus == 7 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!.toUpperCase().contains(widget.searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonName!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   // (
  //                   //     order.userName
  //                   //         .toUpperCase()
  //                   //         .contains(widget.searchController!.text.toUpperCase())) ||
  //                   // (order.userId != null &&
  //                   //     (order.user.fName
  //                   //             .toUpperCase()
  //                   //             .contains(searchController.text.toUpperCase()) ||
  //                   //         order.user.lName
  //                   //             .toUpperCase()
  //                   //             .contains(searchController.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') &&
  //                       (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 3) {
  //             if (order.fOrderStatus == 1) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!.toUpperCase().contains(widget.searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonName!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   // (
  //                   //     order.userName
  //                   //         .toUpperCase()
  //                   //         .contains(widget.searchController!.text.toUpperCase())) ||
  //                   // (order.userId != null &&
  //                   //     (order.user.fName
  //                   //             .toUpperCase()
  //                   //             .contains(widget.searchController!.text.toUpperCase()) ||
  //                   //         order.user.lName
  //                   //             .toUpperCase()
  //                   //             .contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text
  //                                   .toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') &&
  //                       (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 2) {
  //             if (order.fOrderStatus == 5 ||
  //                 (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .defOrdStatus ==
  //                         5
  //                     ? (restaurant.isShowOrderConfirmTab == 'No' &&
  //                         order.fOrderStatus == 7)
  //                     : order.fOrderStatus == 5)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!.toUpperCase().contains(widget.searchController!.text
  //                                     .toUpperCase())))) ||
  //                     // (
  //                     //     '${order?.userName ?? ''}'
  //                     //         .toUpperCase()
  //                     //         .contains(widget.searchController!.text.toUpperCase())) ||
  //                     // (order.userId != null &&
  //                     //     (order.user.fName
  //                     //             .toUpperCase()
  //                     //             .contains(widget.searchController!.text.toUpperCase()) ||
  //                     //         order.user.lName.toUpperCase().contains(
  //                     //             widget.searchController!.text.toUpperCase()))) ||
  //                     // (order.userId != null &&
  //                     //     order.user.phone.length > 2 &&
  //                     //     (order.user.phone
  //                     //         .toUpperCase()
  //                     //         .contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('user id') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonName!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text
  //                                     .toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonNumber!.length >
  //                                 2 &&
  //                             order.deliveryAddress!.contactPersonNumber!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text
  //                                     .toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('order id') &&
  //                         order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) {
  //                   if (Get.find<AuthController>()
  //                               .profileModel!
  //                               .restaurants!
  //                               .first!
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
  //                       : order.orderType == 'delivery') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 0) {
  //             if (order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .isDeliveryAssign ==
  //                         'Yes'
  //                     ? (order.orderType == 'delivery' &&
  //                         (role.contains('delivery_man')
  //                             ? (Get.find<AuthController>()
  //                                         .profileModel!
  //                                         .empId ==
  //                                     order.deliveryManId &&
  //                                 order.deliveryMan != '')
  //                             : (role.contains('show_online_order'))))
  //                     : order.orderType == 'delivery') {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonName!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text
  //                                     .toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonNumber!
  //                                     .length >
  //                                 2 &&
  //                             order.deliveryAddress!.contactPersonNumber!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('order id') && order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) {
  //                   if (Get.find<AuthController>()
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
  //                       : order.orderType == 'delivery') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //         ///////////    Filter with Room
  //         else if (kdsController.selectedMainMenu == 4) {
  //           if (kdsController.selectedSubMenu == 1) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 4) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 1 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 5) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 2) {
  //             if (order.fOrderStatus == 5 ||
  //                 (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .defOrdStatus ==
  //                         5
  //                     ? order.fOrderStatus == 7
  //                     : order.fOrderStatus == 5)) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('phone no') &&
  //                         (order.userId != null &&
  //                             (order.user!.phone!.length > 2 &&
  //                                 order.user!.phone!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if (order.restaurantTable != null &&
  //                       order.restaurantTable!.rtype == 'RM') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 3) {
  //             if (order.fOrderStatus == 1) {
  //               if (widget.searchController!.text.isEmpty) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.userId != null &&
  //                           (order.user!.phone!.length > 2 &&
  //                               order.user!.phone!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||

  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                 if (order.restaurantTable != null &&
  //                     order.restaurantTable!.rtype == 'RM') {
  //                   return true;
  //                 }
  //               }
  //             }
  //           }
  //         }
  //         ////////////////   Filter with All
  //         else if (kdsController.selectedMainMenu == 3) {
  //           if (kdsController.selectedSubMenu == 1) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 2 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
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
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
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
  //           if (kdsController.selectedSubMenu == 4) {
  //             if (order.fOrderStatus == 0 ||
  //                 order.fOrderStatus == 1 ||
  //                 order.fOrderStatus == 2 ||
  //                 order.fOrderStatus == 5 ||
  //                 order.fOrderStatus == 7 ||
  //                 (restaurant.isShowOrderConfirmTab == 'No' &&
  //                     order.fOrderStatus == 7)) {
  //               if (widget.searchController!.text.isEmpty) {
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
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
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
  //           } else if (kdsController.selectedSubMenu == 3) {
  //             if (order.fOrderStatus == 1) {
  //               if (widget.searchController!.text.isEmpty) {
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
  //               } else if ((restaurant.searchBy!.contains('table no') &&
  //                       (order.restaurantTable != null &&
  //                           order.restaurantTable!.tableNo != '' &&
  //                           (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.restaurantTable!.title!
  //                                   .toUpperCase()
  //                                   .contains(widget.searchController!.text
  //                                       .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                       (order.userId != null &&
  //                           (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                               order.user!.lName!.toUpperCase().contains(widget
  //                                   .searchController!.text
  //                                   .toUpperCase())))) ||
  //                   (restaurant.searchBy!.contains('phone no') &&
  //                       (order.deliveryAddress != null &&
  //                           order.deliveryAddress!.contactPersonNumber!.length >
  //                               2 &&
  //                           order.deliveryAddress!.contactPersonNumber!
  //                               .toUpperCase()
  //                               .contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) ||

  //                   // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                   (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
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
  //           } else if (kdsController.selectedSubMenu == 2) {
  //             if (order.fOrderStatus == 5 ||
  //                 (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .defOrdStatus ==
  //                         5
  //                     ? (restaurant.isShowOrderConfirmTab == 'No' &&
  //                         order.fOrderStatus == 7)
  //                     : order.fOrderStatus == 5)) {
  //               if (widget.searchController!.text.isEmpty) {
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
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(widget.searchController!.text
  //                                     .toUpperCase())))) ||
  //                     (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .searchBy!
  //                             .contains('phone no') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonNumber!.length >
  //                                 2 &&
  //                             order.deliveryAddress!.contactPersonNumber!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if ((order.restaurantTable != null &&
  //                           order.restaurantTable!.rtype == 'RM') ||
  //                       (Get.find<AuthController>()
  //                                   .profileModel!
  //                                   .restaurants!
  //                                   .first
  //                                   .isDeliveryAssign ==
  //                               'Yes'
  //                           ? (order.orderType == 'delivery' &&
  //                               (role.contains('delivery_man')
  //                                   ? (Get.find<AuthController>()
  //                                               .profileModel!
  //                                               .empId ==
  //                                           order.deliveryManId &&
  //                                       order.deliveryMan != '')
  //                                   : (role.contains('show_online_order'))))
  //                           : order.orderType == 'delivery') ||
  //                       order.orderType == 'take_away' ||
  //                       order.orderType == 'pos' ||
  //                       order.orderType == 'WalkIn' ||
  //                       order.orderType == 'dinein') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           } else if (kdsController.selectedSubMenu == 0) {
  //             if (order.fOrderStatus == 7) {
  //               if (widget.searchController!.text.isEmpty) {
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
  //               } else {
  //                 if ((restaurant.searchBy!.contains('table no') &&
  //                         (order.restaurantTable != null &&
  //                             order.restaurantTable!.tableNo != '' &&
  //                             (order.restaurantTable!.tableNo!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.restaurantTable!.title!
  //                                     .toUpperCase()
  //                                     .contains(widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.userName.toUpperCase().contains(widget.searchController!.text.toUpperCase())) ||
  //                         (order.userId != null &&
  //                             (order.user!.fName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()) ||
  //                                 order.user!.lName!.toUpperCase().contains(
  //                                     widget.searchController!.text
  //                                         .toUpperCase())))) ||
  //                     (Get.find<AuthController>()
  //                             .profileModel!
  //                             .restaurants!
  //                             .first
  //                             .searchBy!
  //                             .contains('phone no') &&
  //                         (order.deliveryAddress != null &&
  //                             order.deliveryAddress!.contactPersonNumber!
  //                                 .toUpperCase()
  //                                 .contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('user id') && (order.deliveryAddress != null && order.deliveryAddress!.contactPersonName!.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('phone no') && (order.userId != null && order.user!.phone!.length > 2 && (order.user!.phone!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) ||

  //                     // (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController!.text.toUpperCase()))) ||
  //                     (restaurant.searchBy!.contains('order id') && (order.restaurantOrderId!.toUpperCase().contains(widget.searchController!.text.toUpperCase())))) {
  //                   if ((order.restaurantTable != null &&
  //                           order.restaurantTable!.rtype == 'RM') ||
  //                       (Get.find<AuthController>()
  //                                   .profileModel!
  //                                   .restaurants!
  //                                   .first
  //                                   .isDeliveryAssign ==
  //                               'Yes'
  //                           ? (order.orderType == 'delivery' &&
  //                               (role.contains('delivery_man')
  //                                   ? (Get.find<AuthController>()
  //                                               .profileModel!
  //                                               .empId ==
  //                                           order.deliveryManId &&
  //                                       order.deliveryMan != '')
  //                                   : (role.contains('show_online_order'))))
  //                           : order.orderType == 'delivery') ||
  //                       order.orderType == 'take_away' ||
  //                       order.orderType == 'pos' ||
  //                       order.orderType == 'WalkIn' ||
  //                       order.orderType == 'dinein') {
  //                     return true;
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }

  //         return false;
  //       }).map((order) {
  //         // Now return the widget directly
  //         return kdsController.selectedSubMenu == 4
  //             ? CategoryWiseOrderList(
  //                 widget.subscriptionBtStatus,
  //                 searchOrder: widget.searchController!,
  //                 flutterTit: flutterTts,
  //                 order: order,
  //                 isWaiter: true,
  //               )
  //             : WaiterOrderList(
  //                 widget.subscriptionBtStatus,
  //                 searchOrder: widget.searchController!,
  //                 flutterTit: flutterTts,
  //                 order: order,
  //                 isWaiter: true,
  //               );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget printSummaryDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
            padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
                bottom: Dimensions.PADDING_SIZE_DEFAULT),
            child: GetBuilder<KdsController>(builder: (kdsController) {
              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select option for print',
                          textAlign: TextAlign.center,
                          style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.width > 1600
                                  ? 20
                                  : 18,
                              color: Colors.black),
                        ),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.close,
                              color: ColorTheme.appColor, size: 35),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    GetBuilder<LoadingController>(builder: (loadingController) {
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          itemCount:
                              Get.find<KdsController>().splitOrderList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  isSplitSelectPrinterList[index] =
                                      !isSplitSelectPrinterList[index];
                                  // isPrintKitchen = !isPrintKitchen;
                                  loadingController.update();
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? 70
                                              : 30,
                                          child: Checkbox(
                                            activeColor: ColorTheme.appColor,
                                            // value: true,
                                            value:
                                                isSplitSelectPrinterList[index],
                                            onChanged: (bool? isChecked) {
                                              isSplitSelectPrinterList[index] =
                                                  isChecked!;
                                              loadingController.update();
                                            },
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Bill : ${Get.find<KdsController>().splitOrderList[index].restaurantTable == null ? 'WC' : Get.find<KdsController>().splitOrderList[index].restaurantTable!.title == '' ? '#${Get.find<KdsController>().splitOrderList[index].restaurantTable!.tableNo}' : '#${Get.find<KdsController>().splitOrderList[index].restaurantTable!.title}-${Get.find<KdsController>().splitOrderList[index].restaurantTable!.tableNo}'}',
                                                    // 'Bill : ${Get.find<KdsController>().splitOrderList[index].id}',
                                                    style: poppinsRegular.copyWith(
                                                        color: Colors.black,
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                1600
                                                            ? 17
                                                            : 14)),
                                                // Spacer(),
                                                // if (index != 0) SizedBox(width: 10),
                                                // if (index != 0)
                                                //   Text('Amount: 100',
                                                //       // 'Amount: ${index == 1 ? PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice), isHideCurrency: true, asFixed: 2) : double.parse(customerData.orderAmount).toStringAsFixed(2)}',
                                                //       style: poppinsRegular.copyWith(
                                                //           fontSize:
                                                //               MediaQuery.of(context)
                                                //                           .size
                                                //                           .width >
                                                //                       1600
                                                //                   ? 17
                                                //                   : 11)),
                                              ],
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.spaceBetween,
                                            //   children: [
                                            //     if (index != 0)
                                            //       Text(
                                            //           // index == 1
                                            //           // ? 'Date: ${DateFormat('dd-MMM').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse.orders.orderDetailsOrder.createdAt))}'
                                            //           // : customerData.createdAt ==
                                            //           //         ''
                                            //           //     ? ''
                                            //           'Date: ${DateFormat('dd-MMM').format(DateTime.parse(Get.find<KdsController>().splitOrderList[index].createdAt))}',
                                            //           style: poppinsRegular.copyWith(
                                            //               fontSize:
                                            //                   MediaQuery.of(context)
                                            //                               .size
                                            //                               .width >
                                            //                           1600
                                            //                       ? 17
                                            //                       : 11)),
                                            //     // Spacer(),
                                            //     if (index != 0) SizedBox(width: 10),
                                            //   ],
                                            // ),
                                            Text(
                                                isSplitPrinterProccessingList[
                                                        index]
                                                    ? 'Status: Proccessing'
                                                    : isSplitPrintedList[index]
                                                        ? 'Status: Printed'
                                                        : 'Status: Not Printed',
                                                style: poppinsMedium.copyWith(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1600
                                                            ? 15
                                                            : 10,
                                                    color: ColorTheme.blue)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
                    SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    InkWell(
                      onTap: () async {
                        // if (!kdsController.isProcessing) {
                        splitCurrentPrintIndex = 0;
                        if (Platform.isAndroid) {
                          await widget.subscriptionBtStatus?.cancel();
                          await widget.singleSplitBleStatus?.cancel();

                          await listenBlutooth();
                        }
                        // kdsController.setProcessing(true);
                        // }
                      },
                      child: SvgPicture.asset(
                        Images.ic_print_kot,
                        height: 26,
                      ),
                      // child: Container(
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                      //       vertical: Dimensions.PADDING_SIZE_SMALL),
                      //   decoration: BoxDecoration(
                      //       color: ColorTheme.appColor,
                      //       borderRadius:
                      //           BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                      //   child: Text(
                      //     kdsController.isProcessing ? 'Processing' : 'Print',
                      //     style: poppinsMedium.copyWith(
                      //         fontSize: MediaQuery.of(context).size.width > 1600
                      //             ? 19
                      //             : Dimensions.FONT_SIZE_LARGE,
                      //         color: Colors.white),
                      //   ),
                      // ),
                    ),
                  ]),
                ),
              );
            })),
      );
    });
  }

  singleSplitBillBlutooth() {
    if (Platform.isAndroid) {
      widget.singleSplitBleStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        log(' -----------------split status bt $status ------------------ ');

        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(Duration(seconds: 11), () async {
              Get.find<LoadingController>().startLoading(false);
              await Get.find<LoadingController>()
                  .changeText(data: 'Successfully printed!!');
              await Get.find<LoadingController>().changeStatus(data: true);
              pendingTask = [];
              await PrinterManager.instance
                  .disconnect(type: PrinterType.bluetooth);
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = [];
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

  Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
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
      data = await _printerManager.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
        ),
      );
    } else {
      data = await _printerManager.connect(
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
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await _printerManager.connect(
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
        bytes += generator.feed(2);
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    print(data);

    try {
      await _printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      isSplitPrintedList[splitCurrentPrintIndex] =
          true; //It show status of start print
      isSplitPrinterProccessingList[splitCurrentPrintIndex] = false;
      splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
      Get.find<LoadingController>().update();
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    if (data != null && !data) {
      // await Get.find<LoadingController>().changeText(
      //     data: Get.find<AuthController>().profileModel.billPrinterType == 'usb'
      //         ? 'Failed to usb connect!!'
      //         : 'Failed to bluetooth connect!!',
      //     error: true);
      // await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  listenBlutooth({OrderList? order}) {
    widget.subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' -----------------home status bt $status ------------------ ');
      if (Get.find<KdsController>().splitOrderList.isNotEmpty) {
        if (status == BTStatus.connected) {
          isConnect = true;
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              // PrinterManager.instance
              //     .send(type: PrinterType.bluetooth, bytes: pendingTask);
              pendingTask = [];
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = [];
          }
        } else if (status == BTStatus.none) {
          if (!isConnect) {
            print('not connect');
            Future.delayed(Duration(seconds: 2), () async {
              // showErrorToast(
              //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
              isConnect = true;
              splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
            });
          } else {
            isConnect = false;
            print('%%%%%%%%%');
          }
        }
      }
    });
  }

  Widget cookingTabBar() {
    return GetBuilder<KdsController>(builder: (kdsController) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .isShowOrderConfirmTab ==
                'Yes')
              const SizedBox(width: 15),
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .isShowOrderConfirmTab ==
                'Yes')
              InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  widget.searchController!.clear();
                  Get.find<KdsController>().resetSplitBill();
                  kdsController.setSubMenuIndex(
                      kdsController.selectedSubMenu == 0 ? 4 : 0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 0
                          ? ColorTheme.green
                          : Colors.transparent,
                      border: Border.all(
                        color: kdsController.selectedSubMenu == 0
                            ? ColorTheme.green
                            : Color(0xFFDFDFDF),
                      ),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    'Confirm',
                    style: poppinsSemiBold.copyWith(
                        fontSize: 12,
                        color: kdsController.selectedSubMenu == 0
                            ? Colors.white
                            : Color(0xFFC6C6C6)),
                  ),
                ),
              ),
            const SizedBox(width: 15),
            InkWell(
              onTap: () {
                widget.searchController!.clear();
                Get.find<KdsController>().resetSplitBill();
                kdsController.setSubMenuIndex(
                    kdsController.selectedSubMenu == 3 ? 4 : 3);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                decoration: BoxDecoration(
                    color: kdsController.selectedSubMenu == 3
                        ? ColorTheme.green
                        : Colors.transparent,
                    border: Border.all(
                        color: kdsController.selectedSubMenu == 3
                            ? ColorTheme.green
                            : Color(0xFFDFDFDF)),
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  'Cooking',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12,
                      color: kdsController.selectedSubMenu == 3
                          ? Colors.white
                          : Color(0xFFC6C6C6)),
                ),
              ),
            ),
            // if (kdsController.selectedMainMenu != 2 &&
            //     kdsController.selectedMainMenu != 1)
            const SizedBox(width: 15),
            // if (kdsController.selectedMainMenu != 2 &&
            //     kdsController.selectedMainMenu != 1)
            InkWell(
              onTap: () {
                widget.searchController!.clear();
                Get.find<KdsController>().resetSplitBill();
                kdsController.setSubMenuIndex(
                    kdsController.selectedSubMenu == 1 ? 4 : 1);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                decoration: BoxDecoration(
                    color: kdsController.selectedSubMenu == 1
                        ? ColorTheme.green
                        : Colors.transparent,
                    border: Border.all(
                      color: kdsController.selectedSubMenu == 1
                          ? ColorTheme.green
                          : Color(0xFFDFDFDF),
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  (kdsController.selectedMainMenu == 2 ||
                          kdsController.selectedMainMenu == 1)
                      ? 'Dispatch'
                      : 'Ready',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12,
                      color: (kdsController.selectedSubMenu == 1)
                          ? Colors.white
                          : Color(0xFFC6C6C6)),
                ),
              ),
            ),
            // if (kdsController.selectedMainMenu == 2 &&
            //     kdsController.selectedMainMenu == 1)
            //   const SizedBox(width: 15),
            // if (kdsController.selectedMainMenu == 2 &&
            //     kdsController.selectedMainMenu == 1)
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
            //     decoration: BoxDecoration(
            //         border: Border.all(
            //           color: Color(0xFFDFDFDF),
            //         ),
            //         borderRadius: BorderRadius.circular(25)),
            //     child: Text(
            //       'Dispatch',
            //       style: poppinsSemiBold.copyWith(
            //           fontSize: 12, color: Color(0xFFC6C6C6)),
            //     ),
            //   ),

            if (kdsController.selectedMainMenu == 2) const SizedBox(width: 15),
            if (kdsController.selectedMainMenu == 2)
              InkWell(
                onTap: () {
                  widget.searchController!.clear();
                  Get.find<KdsController>().resetSplitBill();
                  kdsController.setSubMenuIndex(
                      kdsController.selectedSubMenu == 2 ? 4 : 2);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 2
                          ? ColorTheme.green
                          : Colors.transparent,
                      border: Border.all(
                        color: kdsController.selectedSubMenu == 2
                            ? ColorTheme.green
                            : Color(0xFFDFDFDF),
                      ),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    'On The Way',
                    style: poppinsSemiBold.copyWith(
                        fontSize: 12,
                        color: kdsController.selectedSubMenu == 2
                            ? Colors.white
                            : Color(0xFFC6C6C6)),
                  ),
                ),
              ),
            if (kdsController.selectedMainMenu == 2) const SizedBox(width: 15),
            if (kdsController.selectedMainMenu == 2)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFDFDFDF),
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  'Completed',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12, color: Color(0xFFC6C6C6)),
                ),
              ),
            if (kdsController.selectedMainMenu != 2 &&
                kdsController.selectedMainMenu != 1)
              const SizedBox(width: 15),
            if (kdsController.selectedMainMenu != 2 &&
                kdsController.selectedMainMenu != 1)
              InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  widget.searchController!.clear();
                  kdsController.setSubMenuIndex(
                      kdsController.selectedSubMenu == 2 ? 4 : 2);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 2
                          ? ColorTheme.green
                          : Colors.transparent,
                      border: Border.all(
                        color: kdsController.selectedSubMenu == 2
                            ? ColorTheme.green
                            : Color(0xFFDFDFDF),
                      ),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    'Running',
                    style: poppinsSemiBold.copyWith(
                        fontSize: 12,
                        color: kdsController.selectedSubMenu == 2
                            ? Colors.white
                            : Color(0xFFC6C6C6)),
                  ),
                ),
              ),
            const SizedBox(width: 15),
            InkWell(
              onTap: () {
                widget.searchController!.clear();
                Get.find<KdsController>().resetSplitBill();
                kdsController.setSubMenuIndex(
                    kdsController.selectedSubMenu == 7 ? 4 : 7);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                decoration: BoxDecoration(
                    color: kdsController.selectedSubMenu == 7
                        ? ColorTheme.green
                        : Colors.transparent,
                    border: Border.all(
                        color: kdsController.selectedSubMenu == 7
                            ? ColorTheme.green
                            : Color(0xFFDFDFDF)),
                    borderRadius: BorderRadius.circular(25)),
                child: Text(
                  'Schedule',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12,
                      color: kdsController.selectedSubMenu == 7
                          ? Colors.white
                          : Color(0xFFC6C6C6)),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      );
    });
  }
}
