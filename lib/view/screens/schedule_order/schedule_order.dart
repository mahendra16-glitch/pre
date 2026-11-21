import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as prefix;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_delivery_man_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/base/food_item_action_button.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/base/theme_color_button.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/widget/swiggy_order_view.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/cancel_order_dialog.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/category_wise_orderlist.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/edit_food_dialog.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../helper/colors.dart';

class ScheduleOrder extends StatefulWidget {
  @override
  State<ScheduleOrder> createState() => _ScheduleOrderState();
}

class _ScheduleOrderState extends State<ScheduleOrder> {
  TextEditingController searchController = TextEditingController();
  TextEditingController cancelReason = TextEditingController();
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
    Get.find<KdsController>().resetSplitBill();

    await Get.find<KdsController>().getWaiterScheduleOrderList();

    Get.find<KdsController>().setSubMenuIndex(4);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    initCallApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule Orders',
          style:
              poppinsMedium.copyWith(fontSize: 16, color: ColorTheme.appColor),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await initData();
        },
        child: SingleChildScrollView(
          child: GetBuilder<KdsController>(builder: (kdsController) {
            return kdsController.getWaiterScheduleOrderListResponse == null
                ? const SizedBox.shrink()
                : kdsController.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : orderListContent(kdsController);
            // WaiterOrderList(
            // orderList: kdsController.getOrderListResponse.orders
            // );
          }),
        ),
      ),
    );
  }

  Widget orderListContent(KdsController kdsController) {
    final auth = Get.find<AuthController>();
    final restaurant = auth.profileModel!.restaurants!.first;
    final roles = auth.profileModel!.role ?? [];
    final empId = auth.profileModel!.empId;
    final searchText = searchController.text.trim().toUpperCase();

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
            ? Get.find<AuthController>()
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
          return statusAllowed(order, [0, 2, 7]);
        case 2:
          return statusAllowed(order, [5, 7]);
        case 3:
          return statusAllowed(order, [1]);
        case 4:
          return statusAllowed(order, [0, 1, 2, 5, 7]);
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
          children: kdsController.getWaiterScheduleOrderListResponse!.orders!
              .where(filterOrder)
              .map((order) {
            return orderListView(order);
          }).toList(),
        ));
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

  Widget orderListView(OrderList order) {
    int cookingFoodItemLenght = 0;
    double roomOrderAmount = 0;
    if ((Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .showOrderStatus ==
                2
            ? order.fOrderStatus! <= 2
            : order.fOrderStatus! < 2) ||
        order.orderType == 'delivery' ||
        order.orderType == 'take_away' ||
        (order.restaurantTable != null &&
            order.restaurantTable!.rtype == 'RM')) {
      for (var element in order.orderDetails!) {
        DateTime foodTime = DateTime.parse(element.updatedAt!);
        var diffTime = DateTime.now().difference(foodTime);
        if ((Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .showOrderStatus ==
                    2 ||
                order.orderType == 'delivery' ||
                order.orderType == 'take_away')
            ? ((element.foodStatus! <= 2 ||
                    order.orderType == 'delivery' ||
                    order.orderType == 'take_away') &&
                diffTime.inMinutes <=
                    Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .cancelOrderTime!)
            : element.foodStatus! < 2) {
          cookingFoodItemLenght = cookingFoodItemLenght + 1;
        }
      }
    }

    if (order.restaurantTable != null && order.restaurantTable!.rtype == 'RM') {
      if (order.roomAssociateOrder != null) {
        for (var room in order.roomAssociateOrder!) {
          roomOrderAmount = roomOrderAmount + room.amount!;
        }
      }
      roomOrderAmount = roomOrderAmount +
          double.parse(order.orderAmount!) +
          (order.roomInfo?.remainingPay ?? 0);
    }
    // // DateTime tempDate = DateTime.parse(order.createdAt);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: order.orderType == 'delivery'
              ? Color.fromRGBO(253, 237, 237, 1)
              : order.orderType == 'take_away'
                  ? Color.fromRGBO(220, 244, 192, 1)
                  : order.restaurantTable != null &&
                          order.restaurantTable!.rtype == 'RM'
                      ? ColorTheme.roomCardBgColor
                      : Color.fromRGBO(254, 245, 208, 1)),
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantTable == null ||
                                order.restaurantTable!.tableNo == ''
                            ? order.orderType == 'delivery'
                                ? 'Delivery'
                                : order.orderType == 'take_away'
                                    ? 'Take Away'
                                    : order.userName != 'Mygenie' &&
                                            order.userName != ''
                                        ? order.userName
                                        : 'WC'
                            : order.restaurantTable?.title == ''
                                ? '#${order.restaurantTable?.tableNo}'
                                : '#${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 15, color: Colors.black),
                        maxLines: 2,
                      ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('Manager'))
                        Text(
                          order.orderType == 'delivery' &&
                                  Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isDeliveryAssign ==
                                      'Yes' &&
                                  order.deliveryMan != ''
                              ? '${order.deliveryMan ?? ''}'
                              : '${order.vendorEmployee?.waiterName ?? ''}',
                          style: poppinsMedium.copyWith(
                              fontSize: 11, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  // flex: 2,
                  child: Row(
                    children: [
                      if (order.paymentType == 'prepaid')
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: ColorTheme.appColor,
                            size: 20,
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.parentOrderId != null &&
                                      order.parentOrderId != '' &&
                                      order.parentOrderId != '0' &&
                                      (order.parentOrderId !=
                                          order.restaurantOrderId)
                                  ? '#${order.tablePart}-${order.parentOrderId}'
                                  : '${order.restaurantOrderId}',
                              style: poppinsBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                  color: Colors.black),
                            ),
                            if (order.userName != 'Mygenie' &&
                                order.userName != '')
                              Text(
                                '${order.userName ?? ''}',
                                style: poppinsMedium.copyWith(
                                    fontSize: 11, color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 3),
                //Merge Table button
                // if (order.fOrderStatus != 7 &&
                //     order.orderType != 'delivery' &&
                //     order.orderType != 'take_away' &&
                //     ((order.restaurantTable != null &&
                //             order.restaurantTable?.tableNo != '' &&
                //             order.restaurantTable?.rtype != 'RM') ||
                //         order.tableId == 0) &&
                //     (Get.find<AuthController>()
                //         .profileModel!
                //         .role!
                //         .contains('merge_table')))
                //   Padding(
                //     padding: const EdgeInsets.only(left: 5),
                //     child: InkWell(
                //       onTap: () {
                //         if (order.orderType != 'delivery' &&
                //             order.orderType != 'take_away' &&
                //             ((order.restaurantTable != null &&
                //                     order.restaurantTable!.tableNo != '' &&
                //                     order.restaurantTable!.rtype != 'RM') ||
                //                 order.tableId == 0))
                //           Get.bottomSheet(mergeTable(context, order),
                //               backgroundColor: Colors.transparent,
                //               isScrollControlled: true,
                //               ignoreSafeArea: false);
                //       },
                //       child: SvgPicture.asset(
                //         Images.ic_show_table,
                //       ),
                //     ),
                //   ),
                SizedBox(width: 15),
                //Switch Table button
                // if (order.fOrderStatus == 7 &&
                //     Get.find<AuthController>()
                //         .profileModel!
                //         .role!
                //         .contains('confirm_order'))
                //   InkWell(
                //     onTap: () async {
                //       Get.find<KdsController>().silentBuzzer();
                //     },
                //     child: Icon(
                //       Icons.notifications_off_outlined,
                //       color: ColorTheme.appColor,
                //     ),
                //   ),
                order.orderType == 'delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();

                              showAddressDialog(order);
                            },
                            child: Icon(CupertinoIcons.location_solid,
                                color: ColorTheme.appColor)),
                      )
                    : SizedBox(width: 30),
                if (order.orderType == 'take_away')
                  Text(
                    'Rs. ${double.parse(order.orderAmount!).toStringAsFixed(2)}',
                    style: poppinsMedium.copyWith(
                        fontSize: 11, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (order.orderType != 'take_away' &&
                    ((order.restaurantTable == null) ||
                        (order.restaurantTable != null &&
                            order.restaurantTable!.rtype != 'RM')))
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, right: 15),
                      child: Text(
                        'Rs. ${double.parse(order.orderAmount!).toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Expanded(
                //   flex: 1,
                //   child: Align(
                //     alignment: Alignment.centerRight,
                //     child: Text(
                //       '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(tempDate)}',
                //       style: poppinsMedium.copyWith(
                //           fontSize: 9, color: Color.fromRGBO(193, 30, 30, 1)),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        if(order.scheduleAt!=null&& order.scheduleAt!='')  Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 0, right: 15),
              child: Text(
                '${DateFormat('dd MMM, hh:mm a').format(DateTime.parse(order.scheduleAt!))}',
                style:
                    poppinsMedium.copyWith(fontSize: 11, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 9),
          Divider(color: ColorTheme.hintText, height: 1),
          waiterFoodItemShow(
            order.orderDetails!,
            order,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          order.orderNote == null || order.orderNote!.trim() == ''
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Notes  :',
                            style: poppinsMedium.copyWith(
                                fontSize: 10,
                                color: ColorTheme.kdsLeftMenuBlue),
                          ),
                          TextSpan(
                            text: ' ${order.orderNote}',
                            style: poppinsMedium.copyWith(
                                fontSize: 10, color: ColorTheme.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          order.orderNote == null || order.orderNote!.trim() == ''
              ? const SizedBox.shrink()
              : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          order.isSplitTable &&
                  Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('printer')
              ? GetBuilder<KdsController>(builder: (kdsController) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: InkWell(
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          splitCurrentPrintIndex = 0;
                          // if (!Get.find<KdsController>().isProcessing) {
                          splitCurrentPrintIndex = Get.find<KdsController>()
                              .splitOrderList
                              .indexOf(order);
                          isSplitSelectPrinterList!.clear();
                          isSplitPrintedList!.clear();
                          isSplitPrinterProccessingList!.clear();
                          for (var i = 0;
                              i <
                                  Get.find<KdsController>()
                                      .splitOrderList
                                      .length;
                              i++) {
                            isSplitSelectPrinterList!.add(false);

                            isSplitPrintedList!.add(false);
                            isSplitPrinterProccessingList!.add(false);
                            // if (widget.cartProductList[i].isNotEmpty) {
                            //   printedTotal = printedTotal + 1;
                            // }
                          }
                          isSplitSelectPrinterList![splitCurrentPrintIndex!] =
                              true;
                          // kdsController.setProcessing(true);
                          // if (printSplitBill != null) {
                          //   printSplitBill!('1');
                          // }
                          // Future.delayed(Duration(seconds: 8), () {
                          //   kdsController.setProcessing(false);
                          // });
                          // }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset(
                            Images.ic_print_kot,
                            height: 26,
                          ),
                        )
                        // Image.asset(
                        //   Images.printKot,
                        //   alignment: Alignment.centerLeft,
                        //   height: 30,
                        //   color: ColorTheme.appColor,
                        // ),
                        ),
                  );
                })
              : (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .isDeliveryAssign ==
                          'Yes' &&
                      order.orderType == 'delivery' &&
                      Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('delivery_man') &&
                      Get.find<AuthController>().profileModel!.empId ==
                          order.deliveryManId &&
                      order.deliveryMan != '')
                  ? Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (order.deliveryManStatus == 'No')
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ThemeColorButton(
                                  onTap: () {
                                    searchController.clear();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    Map<String, dynamic> jsonData = {
                                      'order_id': order.id,
                                      'delivery_man_id':
                                          Get.find<AuthController>()
                                              .profileModel!
                                              .empId,
                                    };
                                    Get.find<DeliveryManController>()
                                        .rejectDeliveryMan(jsonData,
                                            (bool isSucces) {
                                      if (isSucces) {}
                                    });
                                  },
                                  varticalPadding: 8,
                                  horizontalPadding: 12,
                                  editPadding:
                                      order.fOrderStatus == 2 ? 25 : 10,
                                  title: 'Reject'),
                            ),
                          ThemeColorButton(
                              onTap: () {
                                searchController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (order.deliveryManStatus == 'No') {
                                  Map<String, dynamic> jsonBody = {
                                    'order_id': order.id.toString(),
                                    'order_status': 'serve',
                                    'delivery_man_status': 'Yes',
                                    'role_name': 'Manager',
                                  };
                                  Get.find<DeliveryManController>()
                                      .changeOrderStatus(jsonBody, callback);
                                } else {
                                  if (order.paymentType == 'prepaid') {
                                    Map<String, dynamic> jsonBodyPrepaid = {
                                      'order_id': order.id.toString(),
                                      'payment_status': 'sucess',
                                    };
                                    Get.find<KdsController>()
                                        .changePrepaidOrderStatus(
                                            jsonBodyPrepaid, callback);
                                  } else {
                                    Get.toNamed(
                                      RouteHelper.getWaiterCollectPaymentRoute(
                                          order.id.toString()),
                                    );
                                  }
                                }
                              },
                              varticalPadding: 8,
                              horizontalPadding: 12,
                              editPadding: order.fOrderStatus == 2 ? 25 : 10,
                              title: order.deliveryManStatus == 'No'
                                  ? 'Accept'
                                  : 'Deliver'),
                          // SizedBox(width: 15),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('order'))
                            ? Row(
                                children: [
                                  Get.find<KdsController>().selectedSubMenu ==
                                              2 &&
                                          Get.find<KdsController>()
                                              .splitOrderList
                                              .isNotEmpty &&
                                          Get.find<KdsController>()
                                                  .splitOrderList
                                                  .first
                                                  .id ==
                                              order.id
                                      ? Get.find<KdsController>()
                                              .splitOrderList
                                              .first
                                              .isShowCheckbox
                                          ? SizedBox.shrink()
                                          : Get.find<AuthController>()
                                                  .profileModel!
                                                  .role!
                                                  .contains('printer')
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: InkWell(
                                                      onTap: () async {
                                                        searchController
                                                            .clear();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();

                                                        splitCurrentPrintIndex =
                                                            0;
                                                        isSplitSelectPrinterList!
                                                            .clear();
                                                        isSplitPrintedList!
                                                            .clear();
                                                        isSplitPrinterProccessingList!
                                                            .clear();
                                                        for (var i = 0;
                                                            i <
                                                                Get.find<
                                                                        KdsController>()
                                                                    .splitOrderList
                                                                    .length;
                                                            i++) {
                                                          isSplitSelectPrinterList!
                                                              .add(i == 0
                                                                  ? true
                                                                  : false);
                                                          isSplitPrintedList!
                                                              .add(false);
                                                          isSplitPrinterProccessingList
                                                              .add(false);
                                                        }
                                                        // if (printSplitBill !=
                                                        //     null) {
                                                        //   printSplitBill!(
                                                        //       '2');
                                                        // }
                                                      },
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: SvgPicture.asset(
                                                          Images.ic_print_kot,
                                                          height: 26,
                                                        ),
                                                      )),
                                                )
                                              : SizedBox.shrink()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(
                                            children: [
                                              ((Get.find<AuthController>()
                                                      .profileModel!
                                                      .role!
                                                      .contains('print_icon')))
                                                  ? InkWell(
                                                      onTap: () async {
                                                        searchController
                                                            .clear();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();

                                                        List<List<OrderDetails>>
                                                            cartProductList =
                                                            [];
                                                        cartProductList = [];
                                                        for (var i = 0;
                                                            i <
                                                                Get.find<
                                                                        AuthController>()
                                                                    .profileModel!
                                                                    .restaurantPrinterNew!
                                                                    .length;
                                                            i++) {
                                                          RestaurantPrinterNew
                                                              printer =
                                                              Get.find<
                                                                      AuthController>()
                                                                  .profileModel!
                                                                  .restaurantPrinterNew![i];
                                                          List<OrderDetails>
                                                              tempCartList = [];
                                                          for (var e in order
                                                              .orderDetails!) {
                                                            if ((printer.areaName!
                                                                            .toUpperCase() ==
                                                                        'MASTER_KOT' ||
                                                                    e.station ==
                                                                        printer
                                                                            .areaName) &&
                                                                (e.foodStatus !=
                                                                    3)) {
                                                              tempCartList
                                                                  .add(e);
                                                            }
                                                          }
                                                          cartProductList.add(
                                                              tempCartList);
                                                        }
                                                        if (cartProductList
                                                            .isNotEmpty) {
                                                          if (order.restaurantTable !=
                                                                  null &&
                                                              order.restaurantTable!
                                                                      .rtype ==
                                                                  'RM') {
                                                          } else {
                                                            showToast(
                                                                'Please wait..');
                                                            Get.find<
                                                                    LoadingController>()
                                                                .startLoading(
                                                                    true);
                                                            await Get.find<
                                                                    PosController>()
                                                                .getCollectBillDetail({
                                                              'order_id':
                                                                  '${order.id}'
                                                            });
                                                            Get.find<
                                                                    LoadingController>()
                                                                .startLoading(
                                                                    false);
                                                            if (Get.isBottomSheetOpen ??
                                                                false)
                                                              Get.back();
                                                          }
                                                          await Get.bottomSheet(
                                                              PrintDialog(
                                                                isBillPrint: order.restaurantTable !=
                                                                            null &&
                                                                        order.restaurantTable!.rtype ==
                                                                            'RM'
                                                                    ? false
                                                                    : true,
                                                                collectBillResponse:
                                                                    Get.find<
                                                                            PosController>()
                                                                        .getCollectBillDetailResponse,
                                                                cartProductList:
                                                                    cartProductList,
                                                                index: Get.find<
                                                                        KdsController>()
                                                                    .getWaiterScheduleOrderListResponse!
                                                                    .orders!
                                                                    .indexOf(
                                                                        order),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              isScrollControlled:
                                                                  true,
                                                              ignoreSafeArea:
                                                                  false);
                                                        }
                                                      },
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: SvgPicture.asset(
                                                          Images.ic_print_kot,
                                                          height: 26,
                                                        ),
                                                      )
                                                      // Image.asset(
                                                      //   Images.printKot,
                                                      //   alignment: Alignment.centerLeft,
                                                      //   height: 30,
                                                      //   color: ColorTheme.appColor,
                                                      // ),
                                                      )
                                                  : SizedBox.shrink(),
                                              (order.restaurantTable != null &&
                                                      order.restaurantTable!
                                                              .rtype ==
                                                          'RM')
                                                  ? SizedBox.shrink()
                                                  : SizedBox(width: 10),
                                              //WhatsApp button
                                              (order.restaurantTable != null &&
                                                      order.restaurantTable!
                                                              .rtype ==
                                                          'RM')
                                                  ? SizedBox.shrink()
                                                  : ((Get.find<AuthController>()
                                                          .profileModel!
                                                          .role!
                                                          .contains(
                                                              'whatsapp_icon')))
                                                      ? InkWell(
                                                          onTap: () {
                                                            Get.bottomSheet(
                                                                whatsAppBottomSheet(
                                                                    context,
                                                                    order:
                                                                        order),
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isScrollControlled:
                                                                    true,
                                                                ignoreSafeArea:
                                                                    false);
                                                          },
                                                          child: Icon(
                                                              FontAwesomeIcons
                                                                  .whatsapp,
                                                              color:
                                                                  Colors.green,
                                                              size: 30),
                                                        )
                                                      : SizedBox.shrink()
                                            ],
                                          ),
                                        ),
                                  // if (order.isShowCheckbox)
                                  //   InkWell(
                                  //     onTap: () {
                                  //       searchController.clear();
                                  //       FocusManager.instance.primaryFocus
                                  //           ?.unfocus();

                                  //       Get.find<KdsController>()
                                  //           .clearSelectedFoodItem();
                                  //     },
                                  //     child: Padding(
                                  //       padding:
                                  //           const EdgeInsets.only(left: 10),
                                  //       child: Icon(Icons.close,
                                  //           size: 35,
                                  //           color: ColorTheme.appColor),
                                  //     ),
                                  //   ),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('order_cancel') &&
                                      ((((Get.find<AuthController>()
                                                                  .profileModel!
                                                                  .restaurants!
                                                                  .first
                                                                  .showOrderStatus ==
                                                              2
                                                          ? order.fOrderStatus! <=
                                                              2
                                                          : order.fOrderStatus! <
                                                              2) ||
                                                      order.orderType ==
                                                          'delivery' ||
                                                      order.orderType ==
                                                          'take_away') &&
                                                  (cookingFoodItemLenght ==
                                                      order.orderDetails!
                                                          .length) ||
                                              Get.find<AuthController>()
                                                      .profileModel!
                                                      .restaurants!
                                                      .first
                                                      .showOrderStatus ==
                                                  5) ||
                                          order.orderType == 'delivery' ||
                                          order.orderType == 'take_away' ||
                                          (order.paymentId == '' &&
                                              order.paymentType == 'prepaid')))
                                    InkWell(
                                      onTap: () {
                                        searchController.clear();
                                        Get.bottomSheet(
                                            CancelOrderDialog(
                                              cancelType: 'order',
                                              orderId: order.id.toString(),
                                              stations: [
                                                ...?order.orderDetails
                                                    ?.map((e) => e.station ?? ''),
                                                ...?order.serveOrderDetails
                                                    ?.map((e) => e.station ?? ''),
                                              ]
                                                  .where((s) => s.isNotEmpty)
                                                  .toSet()
                                                  .toList(),
                                            ),
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            ignoreSafeArea: false);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Icon(Icons.close,
                                            size: 35,
                                            color: ColorTheme.appColor),
                                      ),
                                    ),
                                ],
                              )
                            : SizedBox.shrink(),
                        Spacer(),
                        Row(
                          children: [
                            order.paymentType != 'prepaid' &&
                                    order.fOrderStatus == 2 &&
                                    (Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('order_edit')) &&
                                    Get.find<KdsController>().selectedSubMenu ==
                                        4
                                ? (order.parentOrderId != null &&
                                            order.parentOrderId != '' &&
                                            order.parentOrderId != '0' &&
                                            (order.parentOrderId !=
                                                order.restaurantOrderId) ||
                                        order.isPaymentLinkSent == 'Yes')
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ThemeColorButton(
                                          varticalPadding: 8,
                                          horizontalPadding:
                                              order.fOrderStatus == 2 ? 16 : 35,
                                          onTap: () async {
                                            searchController.clear();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            Get.find<CartController>()
                                                .clearCartList();
                                            if (MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570 ||
                                                GetPlatform.isWindows) {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TabletPosScreen(
                                                              editOrder:
                                                                  order)));
                                            } else {
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WaiterPosScreen(
                                                              editOrder:
                                                                  order)));
                                            }
                                          },
                                          title: 'Edit',
                                        ),
                                      )
                                : SizedBox.shrink(),
                            if (order.fOrderStatus == 1 &&
                                Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('Ready'))
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 8),
                                child: ThemeColorButton(
                                  title: 'Ready',
                                  varticalPadding: 8,
                                  horizontalPadding: 12,
                                  onTap: () {
                                    Map<String, dynamic> jsonBody = {
                                      'order_id': order.id.toString(),
                                      'role_name': 'Manager',
                                      'order_status': 'ready'
                                    };
                                    Get.find<KdsController>()
                                        .changeOrderStatus(jsonBody, callback);
                                  },
                                ),
                              ),
                            order.isShowCheckbox
                                ? SizedBox.shrink()
                                : order.fOrderStatus != 2 &&
                                        (Get.find<KdsController>()
                                                .selectedSubMenu ==
                                            4) &&
                                        order.paymentType == 'prepaid'
                                    ? SizedBox.shrink()
                                    : (Get.find<AuthController>()
                                                .profileModel!
                                                .role!
                                                .contains(order.fOrderStatus ==
                                                        2
                                                    ? 'order'
                                                    : 'order_edit') &&
                                            (Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .isDeliveryAssign ==
                                                        'Yes' &&
                                                    order.orderType ==
                                                        'delivery'
                                                ? (Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains(
                                                        'assign_online_order'))
                                                : true))
                                        ? ((order.parentOrderId != null &&
                                                    order.parentOrderId != '' &&
                                                    order.parentOrderId !=
                                                        '0' &&
                                                    (order.parentOrderId !=
                                                        order
                                                            .restaurantOrderId)) ||
                                                (order.fOrderStatus != 2 &&
                                                    order.isPaymentLinkSent ==
                                                        'Yes'))
                                            ? SizedBox.shrink()
                                            : ThemeColorButton(
                                                color: order.fOrderStatus ==
                                                            2 &&
                                                        order.orderType ==
                                                            'delivery' &&
                                                        Get.find<AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .isDeliveryAssign ==
                                                            'Yes' &&
                                                        order.deliveryManStatus ==
                                                            'Yes'
                                                    ? ColorTheme.green
                                                    : null,
                                                onTap: () async {
                                                  searchController.clear();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();

                                                  if (order.fOrderStatus == 2) {
                                                    Map<String, dynamic>
                                                        jsonBody = {
                                                      'order_id':
                                                          order.id.toString(),
                                                      'order_status': 'serve',
                                                      'role_name': Get.find<
                                                              AuthController>()
                                                          .profileModel!
                                                          .role!
                                                          .first,
                                                    };

                                                    if (order.orderType ==
                                                            'delivery' ||
                                                        order.orderType ==
                                                            'take_away') {
                                                      Get.find<KdsController>()
                                                          .resetSplitBill();
                                                      if (Get.find<AuthController>()
                                                                  .profileModel!
                                                                  .restaurants!
                                                                  .first
                                                                  .isDeliveryAssign ==
                                                              'Yes' &&
                                                          order.orderType ==
                                                              'delivery') {
                                                        await Get.find<
                                                                DeliveryManController>()
                                                            .getDeliveryManList();

                                                        Get.bottomSheet(
                                                            assignDeliveryBoy(
                                                                context, order),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isScrollControlled:
                                                                true,
                                                            ignoreSafeArea:
                                                                false);
                                                      } else {
                                                        if (order.paymentType ==
                                                            'prepaid') {
                                                          Map<String, dynamic>
                                                              jsonBodyPrepaid =
                                                              {
                                                            'order_id': order.id
                                                                .toString(),
                                                            'payment_status':
                                                                'sucess',
                                                          };
                                                          Get.find<
                                                                  KdsController>()
                                                              .changePrepaidOrderStatus(
                                                                  jsonBodyPrepaid,
                                                                  callback);
                                                        } else {
                                                          if (order.orderType ==
                                                              'delivery') {
                                                            jsonBody[
                                                                    'order_dispatch_status'] =
                                                                'Yes';
                                                            Get.find<
                                                                    KdsController>()
                                                                .changeOrderStatus(
                                                                    jsonBody,
                                                                    callback);
                                                          } else {
                                                            Get.toNamed(RouteHelper
                                                                .getWaiterCollectPaymentRoute(
                                                                    order.id
                                                                        .toString()));
                                                          }
                                                        }
                                                      }
                                                    } else if (order
                                                            .paymentType ==
                                                        'prepaid') {
                                                      Map<String, dynamic>
                                                          jsonBodyPrepaid = {
                                                        'order_id':
                                                            order.id.toString(),
                                                        'payment_status':
                                                            'sucess',
                                                      };
                                                      Get.find<KdsController>()
                                                          .changePrepaidOrderStatus(
                                                              jsonBodyPrepaid,
                                                              callback);
                                                    } else {
                                                      if (Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isComplementry ==
                                                          'Yes') {
                                                        showToast(
                                                            'Please wait..');
                                                        Get.find<
                                                                LoadingController>()
                                                            .startLoading(true);
                                                        Map<String, dynamic>
                                                            jsonData = {
                                                          'waiter_id': Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .empId
                                                              .toString(),
                                                          'payment_mode':
                                                              'cash',
                                                          'paid_room': '',
                                                          'payment_status':
                                                              'sucess',
                                                          'email': '',
                                                          'payment_amount': 0,
                                                          'grant_amount': 0,
                                                          'vat_tax': 0,
                                                          'gst_tax': 0,
                                                          'self_discount': 0,
                                                          'comm_discount': 0,
                                                          'tip_amount': '0',
                                                          'order_discount': 0,
                                                          'mobile': '',
                                                          'name': '',
                                                          'restaurant_name': Get
                                                                  .find<
                                                                      AuthController>()
                                                              .profileModel!
                                                              .restaurants![0]
                                                              .name,
                                                          'service_tax': 0,
                                                          'transaction_id': '',
                                                          'order_id': order.id
                                                        };
                                                        Get.find<
                                                                PosController>()
                                                            .collectPayment((bool
                                                                    isSuccess,
                                                                String
                                                                    msg) async {
                                                          Get.find<
                                                                  LoadingController>()
                                                              .startLoading(
                                                                  false);
                                                          await Get.find<
                                                                  LoadingController>()
                                                              .changeText(
                                                                  data: msg);
                                                          await Get.find<
                                                                  LoadingController>()
                                                              .changeStatus(
                                                                  data: true);
                                                        }, jsonData: jsonData);
                                                      } else {
                                                        Get.find<
                                                                KdsController>()
                                                            .changeOrderStatus(
                                                                jsonBody,
                                                                callback);
                                                      }
                                                    }
                                                  }
                                                  // else if (Get.find<
                                                  //             KdsController>()
                                                  //         .selectedSubMenu ==
                                                  //     4) {
                                                  //   Get.find<KdsController>()
                                                  //       .resetSplitBill();
                                                  //   Get.find<CartController>()
                                                  //       .clearCartList();
                                                  //   if (MediaQuery.of(context)
                                                  //               .size
                                                  //               .shortestSide >
                                                  //           570 ||
                                                  //       GetPlatform.isWindows) {
                                                  //     await Navigator.push(
                                                  //         context,
                                                  //         MaterialPageRoute(
                                                  //             builder: (context) =>
                                                  //                 TabletPosScreen(
                                                  //                     editOrder:
                                                  //                         order)));
                                                  //   } else {
                                                  //     await Navigator.push(
                                                  //         context,
                                                  //         MaterialPageRoute(
                                                  //             builder: (context) =>
                                                  //                 WaiterPosScreen(
                                                  //                     editOrder:
                                                  //                         order)));
                                                  //   }
                                                  // }
                                                },
                                                varticalPadding: 8,
                                                horizontalPadding:
                                                    order.fOrderStatus == 2
                                                        ? order.orderType ==
                                                                'delivery'
                                                            ? 14
                                                            : 18
                                                        : 12,
                                                editPadding:
                                                    order.fOrderStatus == 2
                                                        ? 25
                                                        : 10,
                                                title: order.fOrderStatus == 2
                                                    ? order.orderType ==
                                                            'delivery'
                                                        ? Get.find<AuthController>()
                                                                    .profileModel!
                                                                    .restaurants!
                                                                    .first
                                                                    .isDeliveryAssign ==
                                                                'Yes'
                                                            ? order.deliveryMan ==
                                                                    ''
                                                                ? 'Assign'
                                                                : 'Re-Assign'
                                                            : 'Dispatch'
                                                        : 'Serve'.tr
                                                    : 'Edit',
                                              )
                                        : SizedBox.shrink(),
                            order.fOrderStatus == 5
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 18),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // SizedBox(width: 5),
                                        if ((Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains('bill') ||
                                                Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains(
                                                        'clear_payment')) &&
                                            !order.isShowCheckbox &&
                                            (Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .isDeliveryAssign ==
                                                        'Yes' &&
                                                    order.orderType ==
                                                        'delivery'
                                                ? (Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains(
                                                        'assign_online_order'))
                                                : true))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: ThemeColorButton(
                                              varticalPadding: 8,
                                              horizontalPadding: 8,
                                              onTap: () async {
                                                searchController.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();

                                                Get.find<KdsController>()
                                                    .resetSplitBill();
                                                if (Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .isDeliveryAssign ==
                                                        'Yes' &&
                                                    order.orderType ==
                                                        'delivery') {
                                                  await Get.find<
                                                          DeliveryManController>()
                                                      .getDeliveryManList();

                                                  Get.bottomSheet(
                                                      assignDeliveryBoy(
                                                          context, order),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      ignoreSafeArea: false);
                                                } else {
                                                  if (order.orderType ==
                                                          'delivery' &&
                                                      order.deliveryDispatchStatus ==
                                                          'No') {
                                                    Map<String, dynamic>
                                                        jsonBody = {
                                                      'order_id':
                                                          order.id.toString(),
                                                      'order_status': 'serve',
                                                      'role_name': Get.find<
                                                              AuthController>()
                                                          .profileModel!
                                                          .role!
                                                          .first,
                                                    };
                                                    jsonBody[
                                                            'order_dispatch_status'] =
                                                        'Yes';
                                                    Get.find<KdsController>()
                                                        .changeOrderStatus(
                                                            jsonBody, callback);
                                                  } else {
                                                    if (order.paymentType ==
                                                        'prepaid') {
                                                      Map<String, dynamic>
                                                          jsonBodyPrepaid = {
                                                        'order_id':
                                                            order.id.toString(),
                                                        'payment_status':
                                                            'sucess',
                                                      };
                                                      Get.find<KdsController>()
                                                          .changePrepaidOrderStatus(
                                                              jsonBodyPrepaid,
                                                              callback);
                                                    } else {
                                                      Get.toNamed(RouteHelper
                                                          .getWaiterCollectPaymentRoute(
                                                              order.id
                                                                  .toString()));
                                                    }
                                                  }
                                                }
                                              },
                                              color: order.orderType ==
                                                          'delivery' &&
                                                      Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isDeliveryAssign ==
                                                          'Yes'
                                                  ? ColorTheme.green
                                                  : null,
                                              title: order.orderType ==
                                                      'delivery'
                                                  ? Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .isDeliveryAssign ==
                                                          'Yes'
                                                      ? order.deliveryMan == ''
                                                          ? 'Assign'
                                                          : 'Re-Assign'
                                                      // : order.paymentType ==
                                                      //         'prepaid'
                                                      //     ? 'Settle'
                                                      : order.deliveryDispatchStatus ==
                                                              'No'
                                                          ? 'Dispatch'
                                                          : 'Deliver'
                                                  : order.restaurantTable !=
                                                              null &&
                                                          order.restaurantTable!
                                                                  .rtype ==
                                                              'RM'
                                                      ? 'Check-out'
                                                      : order.paymentType ==
                                                              'prepaid'
                                                          ? order.orderType ==
                                                                  'take_away'
                                                              ? 'Handover'
                                                              : 'Settle'
                                                          : 'Collect Bill',
                                            ),
                                          ),

                                        if (Get.find<AuthController>()
                                                .profileModel!
                                                .role!
                                                .contains('bill') &&
                                            order.orderType != 'delivery' &&
                                            order.orderType != 'take_away' &&
                                            (order.restaurantTable == null ||
                                                (order.restaurantTable !=
                                                        null &&
                                                    order.restaurantTable!
                                                            .rtype !=
                                                        'RM')))
                                          order.parentOrderId != null &&
                                                  order.parentOrderId != '' &&
                                                  order.parentOrderId != '0' &&
                                                  (order.parentOrderId !=
                                                      order.restaurantOrderId)
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: ThemeColorButton(
                                                    varticalPadding: 8,
                                                    horizontalPadding: 10,
                                                    onTap: () {
                                                      searchController.clear();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();

                                                      if (order
                                                          .isShowCheckbox) {
                                                        Get.find<
                                                                KdsController>()
                                                            .splitOrder();
                                                      } else {
                                                        Get.find<
                                                                KdsController>()
                                                            .selectSplitOrder(
                                                                order);
                                                      }
                                                    },
                                                    title: 'Split',
                                                  ),
                                                ),
                                        if (order.isShowCheckbox)
                                          SizedBox(width: 10),
                                        if (order.isShowCheckbox)
                                          ThemeColorButton(
                                            varticalPadding: 8,
                                            horizontalPadding: 10,
                                            onTap: () {
                                              searchController.clear();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();

                                              Get.find<KdsController>()
                                                  .resetSplitBill();
                                            },
                                            title: 'Reset',
                                          ),
                                      ],
                                    ),
                                  )
                                : SizedBox(width: 18),
                          ],
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  void showAddressDialog(OrderList order) {
    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(),
                    Text('Address #${order.deliveryAddress?.addressType}',
                        style: poppinsMedium.copyWith(
                            fontSize: 18, color: Colors.black)),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close, color: ColorTheme.appColor))
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Name: ${order.deliveryAddress?.contactPersonName ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                              'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
                              style: poppinsMedium.copyWith(fontSize: 14)),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () async {
                                Get.back();
                                final phoneNumber = order
                                        .deliveryAddress?.contactPersonNumber ??
                                    '';
                                if (phoneNumber.isNotEmpty) {
                                  final Uri callUri =
                                      Uri(scheme: 'tel', path: phoneNumber);
                                  if (await canLaunchUrl(callUri)) {
                                    await launchUrl(callUri);
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Could not open dialer",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } else {
                                  Get.snackbar(
                                    "No Number",
                                    "Phone number not available",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.phone,
                                color: ColorTheme.appColor,
                                size: 20,
                              ))
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Text(
                      //     'Address type: ${order.deliveryAddress?.addressType ?? ''}',
                      //     style: poppinsMedium.copyWith(fontSize: 14)),
                      // const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                                'Address: ${order.deliveryAddress?.address ?? ''}',
                                style: poppinsMedium.copyWith(fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: InkWell(
                              onTap: () async {
                                if (order.deliveryAddress != null &&
                                    order.deliveryAddress!.latitude != null &&
                                    order.deliveryAddress!.longitude != null &&
                                    order.deliveryAddress!.latitude!
                                        .isNotEmpty &&
                                    order.deliveryAddress!.longitude!
                                        .isNotEmpty) {
                                  final latitude = double.tryParse(
                                      order.deliveryAddress!.latitude!);
                                  final longitude = double.tryParse(
                                      order.deliveryAddress!.longitude!);
                                  if (latitude != null && longitude != null) {
                                    final isGoogleAvailable =
                                        await MapLauncher.isMapAvailable(
                                            MapType.google);
                                    if (isGoogleAvailable == true) {
                                      await MapLauncher.showDirections(
                                        mapType: MapType.google,
                                        destination:
                                            Coords(latitude, longitude),
                                      );
                                    } else {
                                      final isAppleAvailable =
                                          await MapLauncher.isMapAvailable(
                                              MapType.apple);
                                      if (isAppleAvailable == true) {
                                        await MapLauncher.showDirections(
                                          mapType: MapType.apple,
                                          destination:
                                              Coords(latitude, longitude),
                                        );
                                      }
                                    }
                                  }
                                }
                                // String googleUrl =
                                //     'https://www.google.com/maps/search/?api=1&query=15.00952529999999995879989000968635082244873046875,74.0489457999999984849637257866561412811279296875';
                                // try {
                                //   if (await canLaunchUrl(Uri.parse(googleUrl))) {
                                //     await launchUrl(Uri.parse(googleUrl));
                                //   } else {
                                //     throw 'Could not open the map.';
                                //   }
                                // } catch (e) {
                                //   print('$e ---------Error');
                                // }
                              },
                              child: Icon(
                                CupertinoIcons.map_pin_ellipse,
                                color: ColorTheme.appColor,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                          'House No/Flat No.: ${order.deliveryAddress?.house ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),

                      const SizedBox(height: 5),

                      Text('Pincode: ${order.deliveryAddress?.pincode ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // showToast(message);
      // showCustomSnackBar(message, isError: false);
    } else {
      // showCustomSnackBar(message);
    }
  }

  Widget assignDeliveryBoy(BuildContext context, OrderList orderDetail) {
    int? selectedOrderId;
    String? selectedTableName;
    List<GetDeliveryBoyList> dmList = [];
    // bool isSwitchNote = false;
    TextEditingController searchTable = TextEditingController();
    dmList = Get.find<DeliveryManController>().deliveryManList;
    return SafeArea(
      child: Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        ),
        child: GetBuilder(builder: (DeliveryManController dmController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Partner',
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        searchController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();

                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: ColorTheme.appColor,
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: ColorTheme.borderGrey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 40,
                child: TextField(
                  controller: searchTable,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                    suffixIcon: Icon(
                      Icons.search,
                      color: ColorTheme.appColor,
                      size: 25,
                    ),
                    hintText: 'Search',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                  ),
                  onChanged: (value) async {
                    if (searchTable.text.isNotEmpty) {
                      dmList = dmController.deliveryManList
                          .where((item) => (item.fName
                              .toLowerCase()
                              .contains(searchTable.text.toLowerCase())))
                          .toList();
                    } else {
                      dmList = dmController.deliveryManList;
                    }
                    dmController.update();
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dmList.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 7,
                            childAspectRatio: 1.8,
                            mainAxisSpacing: 7,
                            crossAxisCount: 3),
                        itemBuilder: (BuildContext context, int index) {
                          GetDeliveryBoyList boy = dmList[index];
                          return InkWell(
                              onTap: () {
                                searchController.clear();
                                // tableIndex = index;
                                FocusManager.instance.primaryFocus?.unfocus();

                                selectedOrderId = boy.id;
                                selectedTableName = boy.fName;
                                // selectedTableName = order.restaurantTable ==
                                //             null ||
                                //         order.restaurantTable.tableNo == ''
                                //     ? order?.orderType == 'delivery'
                                //         ? 'Delivery'
                                //         : order?.orderType == 'take_away'
                                //             ? 'Take Away'
                                //             : order.userName != 'Mygenie' &&
                                //                     order.userName != ''
                                //                 ? order.userName
                                //                 : 'WC'
                                //     : order.restaurantTable.title == ''
                                //         ? '${order.restaurantTable.tableNo}'
                                //         : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}';

                                dmController.update();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: selectedOrderId == boy.id
                                        ? ColorTheme.appColor
                                        : ColorTheme.tableBoxGrey,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: selectedOrderId == boy.id
                                            ? ColorTheme.appColor
                                            : ColorTheme.borderGrey)),
                                child: Center(
                                  child: Text(boy.fName ?? '',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color: selectedOrderId == boy.id
                                              ? Colors.white
                                              : ColorTheme.hintText)),
                                  // child: Text('${order.restaurantOrderId}',
                                  //     style: poppinsMedium.copyWith(
                                  //         fontSize: 10,
                                  //         color: selectedOrderId == order.id
                                  //             ? Colors.white
                                  //             : ColorTheme.hintText)),
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomButton(
                  width: Get.width / 2.0,
                  buttonText: 'Select Runner',
                  onPressed: () async {
                    Map<String, dynamic> jsonData = {
                      'order_id': orderDetail.id,
                      'delivery_man_id': selectedOrderId,
                    };
                    dmController.assignDeliveryMan(jsonData, (bool isSucces) {
                      if (isSucces) {
                        orderDetail.deliveryMan = selectedTableName ?? '';
                        //   order.tableId = tableIdSelect.id;
                        //   order.restaurantTable = RestaurantTable(
                        //       id: tableIdSelect.id,
                        //       rtype: tableIdSelect.type,
                        //       tableNo: tableIdSelect.tableNo,
                        //       title: tableIdSelect.title);
                        Get.find<KdsController>().update();
                        if (Get.isBottomSheetOpen ?? false) Get.back();

                        // } else {
                      }
                    });
                  },
                ),
              ],
            ),
          ]);
        }),
      ),
    );
  }

  Widget waiterFoodItemShow(List<OrderDetails> orderItemList, OrderList order) {
    return Column(
      children: [
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: orderItemList.length,
            itemBuilder: (BuildContext context, int index) {
              String variationText = '';

              if (orderItemList[index].variation != null &&
                  (orderItemList[index].variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance ==
                      'Yes')) {
                variationText += '';
                List<String> labelList = [];

                for (int j = 0;
                    j < (orderItemList[index].variation?.length ?? 0);
                    j++) {
                  final variationJ = orderItemList[index].variation?[j];
                  if (variationJ?.values != null) {
                    for (var element in (variationJ!.values ?? [])) {
                      labelList.add(element.level ?? '');
                    }
                  }
                }
                variationText += '${labelList.join(',')}';
                variationText += '';
              } else if (orderItemList[index].variation != null &&
                  (orderItemList[index].variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance !=
                      'Yes')) {
                for (int j = 0;
                    j < (orderItemList[index].variation?.length ?? 0);
                    j++) {
                  final variationJ = orderItemList[index].variation?[j];
                  variationText +=
                      '${variationText.isNotEmpty ? ', ' : ''}${variationJ?.name ?? ''} (';

                  if (variationJ?.values != null) {
                    List<String> labelList = [];
                    for (var element in (variationJ!.values ?? [])) {
                      labelList.add(element.level ?? '');
                    }
                    variationText +=
                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                  }

                  variationText += ')';
                }
              }

              String addons = '';
              for (var i = 0;
                  i < (orderItemList[index].addOns?.length ?? 0);
                  i++) {
                if (addons != '') {
                  addons += ', ';
                }
                addons +=
                    '${orderItemList[index].addOns?[i].name ?? ''} (${orderItemList[index].addOns?[i].qty ?? ''})';
              }
              return orderItemList[index].foodStatus == 5 &&
                      (Get.find<KdsController>().selectedSubMenu == 1 ||
                          (Get.find<KdsController>().selectedSubMenu == 4 &&
                              order.fOrderStatus == 2))
                  ? SizedBox.shrink()
                  : orderItemList[index].foodDetails!.name!.toUpperCase() ==
                          'CHECK IN'
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Stack(
                              alignment: Alignment.centerLeft,
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 17),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .foodWithVariance ==
                                                'Yes')
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${orderItemList[index].foodDetails?.name ?? ''} (${orderItemList[index].quantity})',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              fontSize: 15,
                                                              decoration: orderItemList[index]
                                                                          .isSplited ||
                                                                      orderItemList[index]
                                                                              .foodStatus ==
                                                                          3
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                              color: orderItemList[
                                                                              index]
                                                                          .isSplited ||
                                                                      orderItemList[index]
                                                                              .foodStatus ==
                                                                          3
                                                                  ? ColorTheme
                                                                      .disableButtonText
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                ' $variationText',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 11,
                                                              decoration: orderItemList[
                                                                          index]
                                                                      .isSplited
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                              color: orderItemList[
                                                                          index]
                                                                      .isSplited
                                                                  ? Colors.grey
                                                                  : ColorTheme
                                                                      .green,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (order.paymentType !=
                                                          'prepaid' &&
                                                      order.isPaymentLinkSent !=
                                                          'Yes')
                                                    InkWell(
                                                      onTap: () async {
                                                        await editProduct(
                                                            foodOrderDetail:
                                                                order.orderDetails![
                                                                    index],
                                                            addons: addons,
                                                            index: index,
                                                            variationText:
                                                                variationText,
                                                            order: order);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Icon(Icons.edit,
                                                            color: ColorTheme
                                                                .appColor,
                                                            size: 20),
                                                      ),
                                                    )
                                                ],
                                              ),

                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .foodWithVariance !=
                                                'Yes')
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      '${orderItemList[index].foodDetails?.name ?? ''} (${orderItemList[index].quantity})',
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                        fontSize: 15,
                                                        decoration: orderItemList[
                                                                        index]
                                                                    .isSplited ||
                                                                orderItemList[
                                                                            index]
                                                                        .foodStatus ==
                                                                    3
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        color: orderItemList[
                                                                        index]
                                                                    .isSplited ||
                                                                orderItemList[
                                                                            index]
                                                                        .foodStatus ==
                                                                    3
                                                            ? ColorTheme
                                                                .disableButtonText
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  if (order.paymentType !=
                                                          'prepaid' &&
                                                      order.isPaymentLinkSent !=
                                                          'Yes')
                                                    InkWell(
                                                      onTap: () async {
                                                        await editProduct(
                                                            foodOrderDetail:
                                                                order.orderDetails![
                                                                    index],
                                                            addons: addons,
                                                            index: index,
                                                            variationText:
                                                                variationText,
                                                            order: order);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 5),
                                                        child: Icon(Icons.edit,
                                                            color: ColorTheme
                                                                .appColor,
                                                            size: 20),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            addons == ''
                                                ? SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Add-Ons :',
                                                            style: poppinsMedium.copyWith(
                                                                fontSize: 11,
                                                                decoration: orderItemList[
                                                                            index]
                                                                        .isSplited
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : TextDecoration
                                                                        .none,
                                                                color: orderItemList[
                                                                            index]
                                                                        .isSplited
                                                                    ? Colors
                                                                        .grey
                                                                    : ColorTheme
                                                                        .kdsLeftMenuBlue),
                                                          ),
                                                          TextSpan(
                                                            text: ' $addons',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              fontSize: 11,
                                                              decoration: orderItemList[
                                                                          index]
                                                                      .isSplited
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                              color: orderItemList[
                                                                          index]
                                                                      .isSplited
                                                                  ? Colors.grey
                                                                  : ColorTheme
                                                                      .green,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .foodWithVariance !=
                                                'Yes')
                                              variationText == ''
                                                  ? SizedBox.shrink()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  'Variants  :',
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize: 11,
                                                                  decoration: orderItemList[
                                                                              index]
                                                                          .isSplited
                                                                      ? TextDecoration
                                                                          .lineThrough
                                                                      : TextDecoration
                                                                          .none,
                                                                  color: orderItemList[
                                                                              index]
                                                                          .isSplited
                                                                      ? Colors
                                                                          .grey
                                                                      : ColorTheme
                                                                          .blue),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' $variationText',
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize: 11,
                                                                  decoration: orderItemList[
                                                                              index]
                                                                          .isSplited
                                                                      ? TextDecoration
                                                                          .lineThrough
                                                                      : TextDecoration
                                                                          .none,
                                                                  color: orderItemList[
                                                                              index]
                                                                          .isSplited
                                                                      ? Colors
                                                                          .grey
                                                                      : ColorTheme
                                                                          .green),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                            orderItemList[index]
                                                            .foodLevelNotes ==
                                                        '' ||
                                                    orderItemList[index]
                                                            .foodLevelNotes ==
                                                        null
                                                ? SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Notes  :',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color: ColorTheme
                                                                        .blue),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                ' ${orderItemList[index].foodLevelNotes}',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color: ColorTheme
                                                                        .green),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                            Row(
                                              children: [
                                                GetBuilder<KdsController>(
                                                    builder: (kdsController) {
                                                  String showTime = '';
                                                  // Duration createTime = DateTime.now().difference(
                                                  //     DateTime.parse(orderItemList[index].createdAt));

                                                  if (orderItemList[index]
                                                          .createdAt !=
                                                      null)
                                                    showTime = Jiffy.parse(
                                                            orderItemList[index]
                                                                .createdAt!)
                                                        .fromNow();
                                                  // Duration readyTime;
                                                  if (orderItemList[index]
                                                          .readyAt !=
                                                      null) {
                                                    // readyTime = DateTime.now().difference(
                                                    //     DateTime.parse(orderItemList[index].readyAt));
                                                    // showTime = '${readyTime.inMinutes}';
                                                    showTime = Jiffy.parse(
                                                            orderItemList[index]
                                                                .readyAt!)
                                                        .fromNow();
                                                  }
                                                  if (orderItemList[index]
                                                          .serveAt !=
                                                      null) {
                                                    // Duration serveTime;

                                                    // serveTime = DateTime.now().difference(
                                                    //     DateTime.parse(orderItemList[index].serveAt));
                                                    // showTime = '${serveTime.inMinutes}';
                                                    showTime = Jiffy.parse(
                                                            orderItemList[index]
                                                                .serveAt!)
                                                        .fromNow();
                                                  }

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            '$showTime',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        10,
                                                                    color: ColorTheme
                                                                        .hintText),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                            // InkWell(
                                            //     onTap: () {
                                            //       speak(
                                            //           '${orderItemList[index].foodDetails.name ?? ''} ${orderItemList[index].quantity}, ${addons == '' ? '' : "Add-Ons' ':''$addons"},  ${variationText == '' ? '' : "Variants  :$variationText"}');
                                            //     },
                                            //     child: Icon(Icons.play_circle_outline_outlined))
                                          ],
                                        ),
                                      ),
                                      // Image.asset(Images.ic_theme_show_addOn, height: 30),
                                      SizedBox(width: 20),
                                      if (Get.find<AuthController>()
                                              .profileModel!
                                              .role!
                                              .contains('order_cancel') &&
                                          order.isPaymentLinkSent != 'Yes')
                                        if (((order.paymentType == 'prepaid' &&
                                                    order.paymentId != '') ||
                                                order.fOrderStatus != 7 &&
                                                    ((Get.find<AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .isPreCancel ==
                                                            'Yes' &&
                                                        (orderItemList[index]
                                                                    .foodStatus ==
                                                                0 ||
                                                            orderItemList[index]
                                                                    .foodStatus ==
                                                                1 ||
                                                            orderItemList[index]
                                                                    .foodStatus ==
                                                                2)))) ||
                                            (order.paymentType != 'prepaid' &&
                                                (order.orderType ==
                                                        'delivery' ||
                                                    order.orderType ==
                                                        'take_away')))
                                          InkWell(
                                            onTap: () async {
                                              searchController.clear();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              List<int> qtyList = [];
                                              for (var i = 0;
                                                  i <
                                                      order.orderDetails![index]
                                                          .quantity!;
                                                  i++) {
                                                qtyList.add(i + 1);
                                              }
                                              await Get.bottomSheet(
                                                  CancelOrderDialog(
                                                    qtyList: qtyList,
                                                    foodStatus: order
                                                        .orderDetails![index]
                                                        .foodStatus,
                                                    itemId: order
                                                        .orderDetails![index].id
                                                        .toString(),
                                                    controller: cancelReason,
                                                    foodId: order
                                                        .orderDetails![index]
                                                        .foodDetails!
                                                        .id
                                                        .toString(),
                                                    orderId:
                                                        order.id.toString(),
                                                    stations: [
                                                      if ((order
                                                                  .orderDetails![
                                                                      index]
                                                                  .station ??
                                                              '')
                                                          .isNotEmpty)
                                                        order
                                                            .orderDetails![
                                                                index]
                                                            .station!,
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  ignoreSafeArea: false);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Icon(Icons.close,
                                                  color: ColorTheme.appColor),
                                            ),
                                          ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(height: 5),
                                          if (orderItemList[index]
                                                  .foodDetails!
                                                  .name!
                                                  .toUpperCase() !=
                                              'CHECK IN')
                                            order.fOrderStatus == 7
                                                ? SizedBox.shrink()
                                                : !Get.find<AuthController>()
                                                        .profileModel!
                                                        .role!
                                                        .contains('order')
                                                    ? FoodButton(
                                                        isDisable: true,
                                                        onTap: () {},
                                                        title: orderItemList[
                                                                        index]
                                                                    .foodStatus ==
                                                                5
                                                            ? 'Served'.tr
                                                            : orderItemList[index]
                                                                        .foodStatus ==
                                                                    3
                                                                ? 'canceled'.tr
                                                                : orderItemList[index]
                                                                            .foodStatus ==
                                                                        2
                                                                    ? 'Serve'.tr
                                                                    : orderItemList[index].foodStatus ==
                                                                            1
                                                                        ? 'Cooking'
                                                                        : 'cancel'
                                                                            .tr,
                                                      )
                                                    : (Get.find<KdsController>().selectedSubMenu == 1 ||
                                                            Get.find<KdsController>()
                                                                    .selectedSubMenu ==
                                                                4 ||
                                                            Get.find<KdsController>()
                                                                    .selectedSubMenu ==
                                                                3)
                                                        ? orderItemList[index].foodStatus == 0 ||
                                                                orderItemList[index].foodStatus ==
                                                                    1 ||
                                                                orderItemList[index].foodStatus ==
                                                                    3 ||
                                                                orderItemList[index]
                                                                        .foodDetails!
                                                                        .name!
                                                                        .toUpperCase() ==
                                                                    'CHECK IN'
                                                            ? FoodButton(
                                                                isDisable: true,
                                                                onTap: () {},
                                                                title: orderItemList[index]
                                                                            .foodStatus ==
                                                                        0
                                                                    ? 'accept'
                                                                        .tr
                                                                    : orderItemList[index].foodStatus ==
                                                                            1
                                                                        ? 'cooking'
                                                                            .tr
                                                                        : orderItemList[index].foodStatus ==
                                                                                3
                                                                            ? 'Cancelled'
                                                                            : 'cancel'.tr,
                                                              )
                                                            : order.orderType == 'delivery' ||
                                                                    order.orderType ==
                                                                        'take_away'
                                                                ? SizedBox
                                                                    .shrink()
                                                                : FoodButton(
                                                                    isDisable: (order.parentOrderId != null &&
                                                                            order.parentOrderId !=
                                                                                '' &&
                                                                            order.parentOrderId !=
                                                                                '0' &&
                                                                            (order.parentOrderId !=
                                                                                order
                                                                                    .restaurantOrderId) &&
                                                                            orderItemList[index].foodStatus !=
                                                                                2) ||
                                                                        (orderItemList[index].foodStatus !=
                                                                                2 &&
                                                                            (!Get.find<AuthController>().profileModel!.role!.contains('order_cancel') ||
                                                                                order.isPaymentLinkSent == 'Yes')),
                                                                    title: orderItemList[index].foodStatus ==
                                                                            2
                                                                        ? 'Serve'
                                                                            .tr
                                                                        : 'Cancel',
                                                                    onTap:
                                                                        () async {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();

                                                                      if (orderItemList[index]
                                                                              .foodStatus ==
                                                                          2) {
                                                                        Map<String,
                                                                                dynamic>
                                                                            jsonBody =
                                                                            {
                                                                          'order_id': order
                                                                              .id
                                                                              .toString(),
                                                                          'order_food_id': order
                                                                              .orderDetails![index]
                                                                              .foodDetails!
                                                                              .id
                                                                              .toString(),
                                                                          'item_id': order
                                                                              .orderDetails![index]
                                                                              .id
                                                                              .toString(),
                                                                          'order_status':
                                                                              'serve'
                                                                        };

                                                                        Get.find<KdsController>().changeFoodOrderStatus(
                                                                            jsonBody,
                                                                            callback);
                                                                      } else if (orderItemList[index].foodStatus ==
                                                                              5 &&
                                                                          Get.find<AuthController>()
                                                                              .profileModel!
                                                                              .role!
                                                                              .contains('order_cancel')) {
                                                                        searchController
                                                                            .clear();
                                                                        List<int>
                                                                            qtyList =
                                                                            [];
                                                                        for (var i =
                                                                                0;
                                                                            i < order.orderDetails![index].quantity!;
                                                                            i++) {
                                                                          qtyList.add(i +
                                                                              1);
                                                                        }
                                                                        await Get.bottomSheet(
                                                                            CancelOrderDialog(
                                                                              qtyList: qtyList,
                                                                              foodStatus: order.orderDetails![index].foodStatus,
                                                                              itemId: order.orderDetails![index].id.toString(),
                                                                              controller: cancelReason,
                                                                              foodId: order.orderDetails![index].foodDetails!.id.toString(),
                                                                              orderId: order.id.toString(),
                                                                              stations: [
                                                                                if ((order.orderDetails![index].station ?? '').isNotEmpty)
                                                                                  order.orderDetails![index].station!,
                                                                              ],
                                                                            ),
                                                                            backgroundColor: Colors.transparent,
                                                                            isScrollControlled: true,
                                                                            ignoreSafeArea: false);
                                                                      }
                                                                    },
                                                                  )
                                                        : (order.paymentType == 'prepaid' &&
                                                                    order.paymentId != '') ||
                                                                order.fOrderStatus == 3 ||
                                                                orderItemList[index].foodStatus != order.fOrderStatus ||
                                                                orderItemList[index].foodDetails!.name!.toUpperCase() == 'CHECK IN'
                                                            ? FoodButton(
                                                                isDisable: true,
                                                                onTap: () {},
                                                                title: order.fOrderStatus ==
                                                                            2 &&
                                                                        orderItemList[index].foodStatus ==
                                                                            5
                                                                    ? 'Serve'.tr
                                                                    : order.fOrderStatus ==
                                                                                5 &&
                                                                            orderItemList[index].foodStatus ==
                                                                                3
                                                                        ? 'canceled'
                                                                            .tr
                                                                        : orderItemList[index].foodStatus ==
                                                                                3
                                                                            ? 'canceled'.tr
                                                                            : 'cancel'.tr,
                                                              )
                                                            : FoodButton(
                                                                isDisable: ((!Get.find<AuthController>().profileModel!.role!.contains('order_cancel') ||
                                                                            order.isPaymentLinkSent ==
                                                                                'Yes') &&
                                                                        orderItemList[index].foodStatus !=
                                                                            2) ||
                                                                    (orderItemList[index]
                                                                                .foodStatus !=
                                                                            2 &&
                                                                        order.parentOrderId !=
                                                                            null &&
                                                                        order.parentOrderId !=
                                                                            '' &&
                                                                        order.parentOrderId !=
                                                                            '0' &&
                                                                        (order.parentOrderId !=
                                                                            order.restaurantOrderId)),
                                                                title: orderItemList[index]
                                                                            .foodStatus ==
                                                                        2
                                                                    ? 'Serve'.tr
                                                                    : 'cancel',
                                                                onTap:
                                                                    () async {
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  if (orderItemList[
                                                                              index]
                                                                          .foodStatus ==
                                                                      2) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        jsonBody =
                                                                        {
                                                                      'order_id':
                                                                          order
                                                                              .id
                                                                              .toString(),
                                                                      'order_food_id': order
                                                                          .orderDetails![
                                                                              index]
                                                                          .foodDetails!
                                                                          .id
                                                                          .toString(),
                                                                      'order_status':
                                                                          'serve',
                                                                      'item_id': order
                                                                          .orderDetails![
                                                                              index]
                                                                          .id
                                                                          .toString(),
                                                                    };

                                                                    Get.find<
                                                                            KdsController>()
                                                                        .changeFoodOrderStatus(
                                                                            jsonBody,
                                                                            callback);
                                                                  } else if (orderItemList[index]
                                                                              .foodStatus ==
                                                                          5 &&
                                                                      Get.find<
                                                                              AuthController>()
                                                                          .profileModel!
                                                                          .role!
                                                                          .contains(
                                                                              'order_cancel')) {
                                                                    List<int>
                                                                        qtyList =
                                                                        [];
                                                                    for (var i =
                                                                            0;
                                                                        i < order.orderDetails![index].quantity!;
                                                                        i++) {
                                                                      qtyList.add(
                                                                          i + 1);
                                                                    }
                                                                    await Get.bottomSheet(
                                                                        CancelOrderDialog(
                                                                          qtyList:
                                                                              qtyList,
                                                                          foodStatus: order
                                                                              .orderDetails![index]
                                                                              .foodStatus,
                                                                          itemId: order
                                                                              .orderDetails![index]
                                                                              .id
                                                                              .toString(),
                                                                          controller:
                                                                              cancelReason,
                                                                          foodId: order
                                                                              .orderDetails![index]
                                                                              .foodDetails!
                                                                              .id
                                                                              .toString(),
                                                                          orderId: order
                                                                              .id
                                                                              .toString(),
                                                                          stations: [
                                                                            if ((order.orderDetails![index].station ?? '').isNotEmpty)
                                                                              order.orderDetails![index].station!,
                                                                          ],
                                                                        ),
                                                                        backgroundColor: Colors.transparent,
                                                                        isScrollControlled: true,
                                                                        ignoreSafeArea: false);
                                                                  }
                                                                },
                                                              )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // if (isPending == true)
                                // Positioned(
                                //   left: -14,
                                //   child: InkWell(
                                //     onTap: () {
                                //       Get.bottomSheet(
                                //           mergeTable(
                                //               context,
                                //               orderItemList[index]
                                //                   .id
                                //                   .toString(),
                                //               '${orderItemList[index].foodDetails?.name ?? ''}'),
                                //           backgroundColor: Colors.transparent,
                                //           isScrollControlled: true,
                                //           ignoreSafeArea: false);
                                //     },
                                //     child: Container(
                                //       height: 28,
                                //       width: 28,
                                //       decoration: BoxDecoration(
                                //         shape: BoxShape.circle,
                                //         color: ColorTheme.appColor,
                                //       ),
                                //       child: Icon(
                                //         Icons.arrow_back_ios_new,
                                //         size: 16,
                                //         color: ColorTheme.productCard,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            // Align(
                            //   alignment: Alignment.centerLeft,
                            //   child: Text(
                            //     '${DateFormat('hh:mm').format(createTime)}',
                            //     // '3 minutes ago',
                            //     // '${timeago.format(tempDate)}', //38minute =38m, about hour ago = ~1h
                            //     style: poppinsMedium.copyWith(
                            //         fontSize: 11, color: Color.fromRGBO(193, 30, 30, 1)),
                            //   ),
                            // ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ],
                        );
            }),
        if (order.serveOrderDetails != null &&
            order.serveOrderDetails!.isNotEmpty &&
            (Get.find<KdsController>().selectedSubMenu == 1 ||
                (order.fOrderStatus == 2 &&
                    Get.find<KdsController>().selectedSubMenu == 4)))
          ExpansionTile(
            title: Row(
              children: [
                Text(
                  'Served Item (${order.serveOrderDetails?.length ?? 0})',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 15,
                    color: ColorTheme.disableButtonText,
                  ),
                ),
              ],
            ),
            children: order.serveOrderDetails!.map((e) {
              String variationText = '';

              // if (e.variation != null && e.variation.isNotEmpty) {
              //   for (int j = 0; j < e.variation.length; j++) {
              //     variationText +=
              //         '${variationText.isNotEmpty ? ', ' : ''}${e.variation[j].name} (';

              //     if (e.variation[j].values != null) {
              //       List<String> labelList = [];
              //       for (var element in e.variation[j].values) {
              //         labelList.add(element.level);
              //       }
              //       variationText +=
              //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
              //     }

              //     variationText += ')';
              //   }
              // }
              if (e.variation != null &&
                  (e.variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance ==
                      'Yes')) {
                variationText += '';
                List<String> labelList = [];

                for (int j = 0; j < (e.variation?.length ?? 0); j++) {
                  final variationJ = e.variation?[j];
                  if (variationJ?.values != null) {
                    for (var element in variationJ!.values!) {
                      labelList.add(element.level ?? '');
                    }
                  }
                }
                variationText += '${labelList.join(',')}';
                variationText += '';
              } else if (e.variation != null &&
                  (e.variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance !=
                      'Yes')) {
                for (int j = 0; j < (e.variation?.length ?? 0); j++) {
                  final variationJ = e.variation?[j];
                  variationText +=
                      '${variationText.isNotEmpty ? ', ' : ''}${variationJ?.name ?? ''} (';

                  if (variationJ?.values != null) {
                    List<String> labelList = [];
                    for (var element in variationJ!.values!) {
                      labelList.add(element.level ?? '');
                    }
                    variationText +=
                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                  }

                  variationText += ')';
                }
              }

              String addons = '';
              for (var i = 0; i < (e.addOns?.length ?? 0); i++) {
                if (addons != '') {
                  addons += ', ';
                }
                addons +=
                    '${e.addOns?[i].name ?? ''} (${e.addOns?[i].qty ?? ''})';
              }
              return Column(
                children: [
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   '${e.foodDetails.name ?? ''} (${e.quantity})',
                              //   style: poppinsSemiBold.copyWith(
                              //     fontSize: 15,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .foodWithVariance ==
                                  'Yes')
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${e.foodDetails?.name ?? ''} (${e.quantity})',
                                        style: poppinsMedium.copyWith(
                                          fontSize: 15,
                                          decoration:
                                              e.isSplited || e.foodStatus == 3
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                          color:
                                              e.isSplited || e.foodStatus == 3
                                                  ? ColorTheme.disableButtonText
                                                  : Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' $variationText',
                                        style: poppinsMedium.copyWith(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 11,
                                          decoration: e.isSplited
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: e.isSplited
                                              ? Colors.grey
                                              : ColorTheme.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .foodWithVariance !=
                                  'Yes')
                                Text(
                                  '${e.foodDetails?.name ?? ''} (${e.quantity})',
                                  style: poppinsSemiBold.copyWith(
                                    fontSize: 15,
                                    decoration: e.isSplited || e.foodStatus == 3
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: e.isSplited || e.foodStatus == 3
                                        ? ColorTheme.disableButtonText
                                        : Colors.black,
                                  ),
                                ),
                              addons == ''
                                  ? SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Add-Ons :',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme
                                                      .kdsLeftMenuBlue),
                                            ),
                                            TextSpan(
                                              text: ' $addons',
                                              style: poppinsMedium.copyWith(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 11,
                                                color: ColorTheme.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .foodWithVariance !=
                                  'Yes')
                                variationText == ''
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Variants  :',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 11,
                                                    color: ColorTheme.blue),
                                              ),
                                              TextSpan(
                                                text: ' $variationText',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 11,
                                                    color: ColorTheme.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              e.foodLevelNotes == ''
                                  ? SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Notes  :',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme.blue),
                                            ),
                                            TextSpan(
                                              text: ' ${e.foodLevelNotes}',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              GetBuilder<KdsController>(
                                  builder: (kdsController) {
                                String showTime = '';
                                showTime = Jiffy.parse(e.createdAt!).fromNow();
                                if (e.readyAt != null) {
                                  showTime = Jiffy.parse(e.readyAt!).fromNow();
                                }
                                if (e.serveAt != null) {
                                  showTime = Jiffy.parse(e.serveAt!).fromNow();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '$showTime',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (e.foodDetails!.name!.toUpperCase() !=
                                'CHECK IN')
                              !Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('order')
                                  ? FoodButton(
                                      isDisable: true,
                                      onTap: () {},
                                      title: 'Served'.tr,
                                    )
                                  : FoodButton(
                                      isDisable: (!Get.find<AuthController>()
                                                  .profileModel!
                                                  .role!
                                                  .contains('order_cancel') ||
                                              order.isPaymentLinkSent ==
                                                  'Yes' ||
                                              order.paymentType == 'prepaid') ||
                                          (order.parentOrderId != null &&
                                              order.parentOrderId != '' &&
                                              order.parentOrderId != '0' &&
                                              (order.parentOrderId !=
                                                  order.restaurantOrderId)),
                                      title: 'cancel',
                                      onTap: () async {
                                        if (Get.find<AuthController>()
                                                .profileModel!
                                                .role!
                                                .contains('order_cancel') &&
                                            order.paymentType != 'prepaid') {
                                          searchController.clear();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          List<int> qtyList = [];
                                          for (var i = 0;
                                              i < e.quantity!;
                                              i++) {
                                            qtyList.add(i + 1);
                                          }
                                          await Get.bottomSheet(
                                              CancelOrderDialog(
                                                qtyList: qtyList,
                                                foodStatus: e.foodStatus,
                                                itemId: e.id.toString(),
                                                controller: cancelReason,
                                                foodId: e.foodDetails!.id
                                                    .toString(),
                                                orderId: order.id.toString(),
                                                stations: [
                                                  if ((e.station ?? '')
                                                      .isNotEmpty)
                                                    e.station!,
                                                ],
                                              ),
                                              backgroundColor:
                                                  Colors.transparent,
                                              isScrollControlled: true,
                                              ignoreSafeArea: false);
                                        }
                                      },
                                    )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                ],
              );
            }).toList(),
          ),
        if (order.roomAssociateOrder != null &&
            order.roomAssociateOrder!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ExpansionTile(
              backgroundColor: Color.fromRGBO(254, 245, 208, 1),
              collapsedBackgroundColor: Color.fromRGBO(254, 245, 208, 1),
              tilePadding: EdgeInsets.symmetric(horizontal: 20),
              childrenPadding: EdgeInsets.symmetric(horizontal: 20),
              title: Row(
                children: [
                  Text(
                    'Associated Orders (${order.roomAssociateOrder?.length ?? 0})',
                    style: poppinsSemiBold.copyWith(
                      fontSize: 15,
                      color: ColorTheme.disableButtonText,
                    ),
                  ),
                ],
              ),
              children: order.roomAssociateOrder!.map((e) {
                return Column(
                  children: [
                    // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Id',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          '${e.restaurantOrderId}',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          '${e.amount!.toStringAsFixed(2)}',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time',
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(e.collectBillDate!)),
                          style: poppinsSemiBold.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> editProduct({
    required int index,
    required String addons,
    required String variationText,
    required OrderDetails foodOrderDetail,
    required OrderList order,
  }) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);
    final foodDetails = order.orderDetails?[index]?.foodDetails;
    final foodId = foodDetails?.id;
    Product? apiProduct = await Get.find<ProductController>()
        .getSingleProduct(foodId?.toString() ?? '');
    Get.find<LoadingController>().startLoading(false);
    if (Get.isBottomSheetOpen ?? false) Get.back();

    Get.find<CartController>().clearCartList();

    OrderDetails orderDetail = foodOrderDetail;
    FoodDetails? food = foodOrderDetail.foodDetails;
    List<AddOns> addonList = [];
    if (food?.addOns != null) {
      for (var e in food!.addOns!) {
        addonList.add(AddOns(
            id: e.id ?? 0, name: e.name, price: e.price, qty: e.qty ?? 0));
      }
    }
    double variationPrice = 0;
    Product product = Product(
        addOns: addonList,
        name: food?.name ?? '',
        id: food?.id ?? 0,
        restaurantDiscount: 0,
        variations: food?.variations ?? [],
        availableTimeStarts: food?.availableTimeStarts,
        availableTimeEnds: food?.availableTimeEnds,
        categoryId: food?.categoryId,
        description: food?.description,
        deliveryFoodPrice: food?.deliveredFoodPrice,
        takeAwayFoodPrice: food?.takeAwayFoodPrice,
        discount: 0,
        qty: 1,
        price: double.tryParse(food?.price ?? '0') ?? 0,
        stationName: orderDetail.station);
    Get.find<CartController>().initData(product, null);

    if (product.variations != null) {
      for (int index = 0; index < (product.variations?.length ?? 0); index++) {
        final prodVar = product.variations?[index];
        for (int i = 0; i < (prodVar?.values?.length ?? 0); i++) {
          for (int j = 0; j < (orderDetail.variation?.length ?? 0); j++) {
            final orderVar = orderDetail.variation?[j];
            for (int k = 0; k < (orderVar?.values?.length ?? 0); k++) {
              if ((prodVar?.name ?? '') == (orderVar?.name ?? '')) {
                if ((prodVar?.values?[i].level ?? '') ==
                    (orderVar?.values?[k].level ?? '')) {
                  Get.find<CartController>().setCartVariationIndex(
                    index,
                    i,
                    product,
                    (prodVar?.type ?? '') == 'multi',
                  );
                  variationPrice +=
                      double.tryParse(prodVar?.values?[i].optionPrice ?? '0') ??
                          0;
                }
              }
            }
          }
        }
      }
    }

    List<AddOn> addOnIdList = [];
    List<AddOns> addOnsList = [];
    for (var i = 0; i < (product.addOns?.length ?? 0); i++) {
      for (int index = 0; index < (orderDetail.addOns?.length ?? 0); index++) {
        if ((orderDetail.addOns?[index].id ?? 0) ==
            (product.addOns?[i].id ?? 0)) {
          addOnIdList.add(AddOn(
              id: product.addOns?[i].id ?? 0,
              name: product.addOns?[i].name ?? '',
              price: product.addOns?[i].price ?? 0,
              quantity: orderDetail.addOns?[index].qty ?? 0));
          addOnsList.add(product.addOns![i]);
        }
      }
    }

    double priceWithVariation =
        (double.tryParse(food?.price ?? '0') ?? 0) + variationPrice;

    CartModel cartModel = CartModel(
        adjustPrice: 1,
        price: priceWithVariation,
        discountedPrice: 0,
        // discountAmount: 0,
        quantity: 1,
        addOnIds: addOnIdList,
        addOns: addOnsList,
        // isCampaign: false,
        product: product,
        variation: Get.find<CartController>().selectedVariations!);
    Get.find<CartController>().addToCart(cartModel, null);

    Get.find<CartController>().calculationCart();
    await Get.bottomSheet(
        EditFoodOrderDialog(
          addonText: addons,
          variationText: variationText,
          foodName: order.orderDetails?[index]?.foodDetails?.name ?? '',
          variation: order.orderDetails?[index]?.variation ?? [],
          foodId: order.orderDetails?[index]?.foodDetails?.id?.toString() ?? '',
          addons: order.orderDetails?[index]?.addOns ?? [],
          orderId: order.id.toString(),
          product: apiProduct!,
          order: order,
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        ignoreSafeArea: false);
  }
}
