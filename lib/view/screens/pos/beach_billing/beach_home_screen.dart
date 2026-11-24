import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/kds_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/billing_view_checkout.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_orders.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/revenue_report.dart';
import 'package:mygenie_restaurant/view/screens/settelment_report/settelment_report.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/widget/product_widget.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../main.dart';
import '../../report_summary/report_summary.dart';
import '../../swiggy_zomato/date_wise_orderlist.dart';
import '../../waiter/pos_view_mobile/swiggy_zomatao_ui/swiggy_zomato_ui.dart';
import '../../waiter/room_managment/room_orders.dart';

class BeachBellingHomeScreen extends StatefulWidget {
  @override
  State<BeachBellingHomeScreen> createState() => _BeachBellingHomeScreenState();
}

class _BeachBellingHomeScreenState extends State<BeachBellingHomeScreen> {
  ScrollController _scrollController = ScrollController();
  FirebaseMessaging? _messaging;

  bool isCollaps = false;
  bool isOpenedDropdown = false;

  PackageInfo? packageInfo;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _dropdownContoller = SuperTooltipController();

  final _controller = SuperTooltipController();
  final _tableController = SuperTooltipController();

  List<Product> products = [];
  TextEditingController searchController = TextEditingController();

  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  PrinterManager _printerManager = PrinterManager.instance;
  List<List<OrderDetails>> cartProductList = [];
  List<List<OrderDetails>> failedCartProductList = [];
  List<OrderList> orderQueue = [];
  List<bool> skipFailedList = [];
  List<OrderIdType> orderIdQueue = [];

  bool isProcessingOrder = false;
  int currentPrintIndex = 0;
  bool isConnect = true;
  List<int>? pendingTask;
  bool isFailedPrint = false;
  bool isSkipFirstTimeOrder = false;
  bool isSkipSecondTimeOrder = false;

  bool isProcessingOrderQueue = false;
  Socket? socket;

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    _subscriptionBtStatus?.cancel();
    socket?.dispose();

    super.dispose();
  }

  initData() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotification);
    connectToSocketIO();
    setupInteractedMessage();
    registerNotification();

    // checkForInitialMessage();
    initfirebase();
    FirebaseMessaging.onMessage.listen(_handleMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // if (Get.find<RestaurantController>().posFoodCategoryList.isEmpty) {
      Get.find<RestaurantController>().getProductCategoryListFromLocal(
          Get.find<AuthController>().getProductCategoryList());
      // Get.find<RestaurantController>().setCategoryList();
      // }
      Get.find<RestaurantController>().setPOSWaiterCategoryIndex(0);
      if (Get.find<RestaurantController>().productList.isEmpty) {
        Get.find<RestaurantController>().getProductListFromLocal(
            Get.find<AuthController>().getProductList());
      }
      if (Get.find<AuthController>().employeeList.isEmpty &&
          Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .isShowEmpList ==
              'Yes') {
        Get.find<AuthController>().getEmployeeListFromLocal(
            Get.find<AuthController>().convertEmployeeListFromLocal());
      }
      Get.find<AuthController>().setEmployeeIndex(null);
      Get.find<CartController>().calculationCart();
      products = Get.find<AuthController>().getProductList();
      Get.find<RestaurantController>().update();

      // await listenBlutooth();
    });
  }

  void connectToSocketIO() {
    try {
      // Configure and initialize the socket connection
      socket = io(
        AppConstants.SOCKET_BASE_URL,
        OptionBuilder()
            // .setPath('/socket') // Same as path in your JS code
            .setTransports(['websocket']) // Important for WebSocket only
            .enableForceNew() // Optional: always creates a new connection
            .enableReconnection()
            .enableAutoConnect() // Optional: auto reconnect
            .build(),
      );

      // CR-077: join the restaurant room on every connect/reconnect.
      // Registered before connect() so the first 'connect' event is never missed.
      socket?.onConnect((_) {
        socket?.emit('join_restaurant', {
          'restaurant_id':
              Get.find<AuthController>().profileModel!.restaurants![0].id
        });
      });
      socket?.on('joined_restaurant', (data) {
        print('[socket] joined ${data['room']}');
      });

      // Connect to the WebSocket
      if (!socket!.connected) {
        socket?.connect();
      }

      // Listen for the 'new_order' event with a dynamic restaurant ID
      String restaurantId = Get.find<AuthController>()
          .profileModel!
          .restaurants![0]
          .id
          .toString();
      socket?.on('new_order_$restaurantId', (data) async {
        print('Received socket data: $data');
        if (restaurantId == '${data[2]}') {
          // Handle various order-related events
          if (data[0] == 'new-order') {
            checkQueueProcessFromSocket(
              orderType: data[0],
              orderId: '${data[1]}',
              otherValue: data[0] == 'update-food-status'
                  ? '${data[3]}'
                  : data[0] == 'update-item-status'
                      ? '${data[3]}'
                      :data[0] == 'delivery-assign-order'
                      ? '${data[3]}'
                      : '0',
              newOrderJson: data[0] == 'new-order' ? data[4] : null,
            );
          }
        }
      });

      // Handle the 'disconnect' event
      socket?.on('disconnect', (reason) {
        print('Socket disconnected: $reason');

        // Attempt to reconnect by reinitializing the socket connection
        socket = io(
          AppConstants.SOCKET_BASE_URL,
          OptionBuilder()
              // .setPath('/socket') // Same as path in your JS code
              .setTransports(['websocket']) // Important for WebSocket only
              .enableForceNew() // Optional: always creates a new connection
              .enableReconnection()
              .enableAutoConnect() // Optional: auto reconnect
              .build(),
        );
      });
    } catch (e) {
      // Log any errors that occur during socket initialization or connection
      print('Socket connection error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        UpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: Duration(seconds: 5)),
          child:
        Scaffold(
            appBar: AppBar(
              // toolbarHeight: Get.height / 10.72,
              backgroundColor: Theme.of(context).cardColor,
              leading: Padding(
                padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                child: IconButton(
                  icon: Image.asset(Images.menu,
                      color: ColorTheme.appColor, height: 16),
                  onPressed: () {
                    searchController.clear();
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              titleSpacing: 0,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
              ),
              //     Image.asset(Images.ic_kds_app_logo, width: Get.width * 0.4),
              actions: [
                SizedBox(
                  height: 10,
                  child: GetBuilder<CartController>(builder: (posController) {
                    return posController.cartList.isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Get.find<CartController>().clearCartList();
                              products =
                                  Get.find<AuthController>().getProductList();

                              // Get.find<RestaurantController>()
                              //     .getWaiterProductList('1', 'all');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(
                                  right: 20, top: 13, bottom: 13),
                              height: 10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: ColorTheme.appColor),
                              child: Center(
                                child: Text(
                                  'Clear Cart'.tr,
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                  }),
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: Color(0xFFF8F8F8),
              child: SafeArea(
                child: ListView(
                  // padding: EdgeInsets.zero,

                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 15),
                        child: Image.asset(
                          Images.brand_logo,
                          height: Get.height * 0.1,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 7),
                        child: Text(
                          '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('bill') &&
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .showRoom ==
                            'Yes')
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: true,
                          iconColor: ColorTheme.hintText,
                          title: Text(
                            'Rooms',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                await _subscriptionBtStatus?.cancel();
                                // await _singleSplitBleStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                var data = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => CheckIn()));
                                if (data != null && data) {
                                  Get.find<KdsController>().setSubMenuIndex(2);
                                }
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Check In',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('report'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Report',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('revenue_report'))
                              InkWell(
                                onTap: () async {
                                  scaffoldKey.currentState?.closeDrawer();
                                  _subscriptionBtStatus?.cancel();
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              RevenueReport()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      'Revenue Report',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('sattle_report'))
                              InkWell(
                                onTap: () async {
                                  scaffoldKey.currentState?.closeDrawer();
                                  _subscriptionBtStatus?.cancel();
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              SettlementReport()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 10),
                                    child: Text(
                                      'Settlement Report',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState!.closeDrawer();
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => PrintReport()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    'Daily report',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('report_summery'))
                              InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  scaffoldKey.currentState!.closeDrawer();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              ReportSummeryPage()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 15),
                                    child: Text(
                                      'Report Summary',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState?.closeDrawer();
                              _subscriptionBtStatus?.cancel();
                              FocusManager.instance.primaryFocus?.unfocus();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => ViewPaidOrders()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Paid Orders',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .showRoom ==
                              'Yes')
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => RoomOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    'Room Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('aggregator'))
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            SwiggyZomatoUI()));
                                // await Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (builder) => SwiggyOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 15),
                                  child: Text(
                                    'Aggregator Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('aggregator'))
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            DateWiseSwiggyOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 15),
                                  child: Text(
                                    'Completed Aggregator Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .payTab ==
                              'Yes')
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => TabOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    'Credit Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('bill') &&
                              Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payTab ==
                                  'Yes')
                            InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();

                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                Get.toNamed(
                                    RouteHelper.getTapManagementRoute());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    'Credit Management',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15),
                            child: DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'My Profile',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          if (GetPlatform.isIOS)
                            InkWell(
                              onTap: () {
                                scaffoldKey.currentState?.closeDrawer();
                                FocusManager.instance.primaryFocus?.unfocus();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => GetPrinterIp()));
                                // Get.toNamed(RouteHelper.getTapManagementRoute());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    'Printer Configuration',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          InkWell(
                            onTap: () {
                              scaffoldKey.currentState!.closeDrawer();
                              FocusManager.instance.primaryFocus?.unfocus();

                              String logo = '';
                              if (!Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('order') &&
                                  Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('bill')) {
                                logo = Images.ic_cashier_app_logo;
                              } else if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('report')) {
                                logo = Images.ic_owner_app_logo;
                              } else if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('Manager')) {
                                logo = Images.ic_manager_app_logo;
                              } else {
                                logo = Images.ic_waiter_app_logo;
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          EmployeeResetPassword(
                                            resetToken:
                                                Get.find<AuthController>()
                                                    .getUserToken(),
                                            email: Get.find<AuthController>()
                                                .profileModel!
                                                .empEmail!,
                                            image: logo,
                                            password: '',
                                            fromPasswordChange: true,
                                          ))));

                              // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
                              //     Get.find<AuthController>().profileModel.empEmail,
                              //     Get.find<AuthController>().getUserToken(),
                              //     'password-change'));
                              // Get.toNamed(RouteHelper.getTapManagementRoute());
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, top: GetPlatform.isIOS ? 10 : 0),
                                child: Text(
                                  'Reset Password',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          // if (GetPlatform.isAndroid)
                          //   InkWell(
                          //     onTap: () {
                          //       scaffoldKey.currentState.closeDrawer();
                          //       FocusManager.instance.primaryFocus?.unfocus();

                          //       Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (builder) => UsbGetPrinterIp()));
                          //       // Get.toNamed(RouteHelper.getTapManagementRoute());
                          //     },
                          //     child: Align(
                          //       alignment: Alignment.centerLeft,
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(left: 15, top: 10),
                          //         child: Text(
                          //           'Usb Printer Configuration',
                          //           style: poppinsMedium.copyWith(
                          //               fontSize: 13, color: ColorTheme.hintText),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              Get.bottomSheet(
                                ConfirmationDialog(
                                    icon: Images.support,
                                    description:
                                        'Are you sure you want to log out from My Genie?',
                                    isLogOut: true,
                                    onYesPressed: () async {
                                      try {
                                        Response response =
                                            await Get.find<AuthController>()
                                                .logout();
                                        if (response.statusCode == 200) {
                                          Get.find<RestaurantController>()
                                              .clearProductList();
                                          Get.find<AuthController>()
                                              .clearSharedData();
                                          Get.offAllNamed(
                                              RouteHelper.getSignInRoute());
                                        }
                                      } catch (e) {}
                                      // socket.disconnect();
                                      // Get.find<RestaurantController>()
                                      //     .clearProductList();
                                      // Get.find<AuthController>().clearSharedData();
                                      // Get.offAllNamed(RouteHelper.getSignInRoute());
                                    }),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  'Logout',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // DrawerHeader(
                    //   child: Text('Drawer Header'),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue,
                    //   ),
                    // ),
                    // if (Get.find<AuthController>()
                    //     .profileModel
                    //     .role
                    //     .contains('bill'))
                    //   ListTile(
                    //     title: Text('Tab Managment'),
                    //     onTap: () {
                    //       scaffoldKey.currentState.closeDrawer();
                    //       _subscriptionBtStatus?.cancel();
                    //       Get.toNamed(RouteHelper.getTapManagementRoute());
                    //     },
                    //   ),
                    // if (Get.find<AuthController>()
                    //     .profileModel
                    //     .role
                    //     .contains('bill'))
                    //   ListTile(
                    //     title: Text('Check In'),
                    //     onTap: () async {
                    //       scaffoldKey.currentState.closeDrawer();
                    //       _subscriptionBtStatus?.cancel();
                    //       var data = await Navigator.push(context,
                    //           MaterialPageRoute(builder: (builder) => CheckIn()));
                    //       if (data != null && data) {
                    //         Get.find<KdsController>().setSubMenuIndex(2);
                    //       }
                    //     },
                    //   ),

                    // ListTile(
                    //   title: Text('Revenue Report'),
                    //   onTap: () async {
                    //     scaffoldKey.currentState.closeDrawer();
                    //     _subscriptionBtStatus?.cancel();
                    //     await Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (builder) => RevenueReport()));
                    //   },
                    // ),
                    // if (Get.find<AuthController>()
                    //     .profileModel
                    //     .role
                    //     .contains('sattle_report'))
                    //   ListTile(
                    //     title: Text('Settlement Report'),
                    //     onTap: () async {
                    //       scaffoldKey.currentState.closeDrawer();
                    //       _subscriptionBtStatus?.cancel();
                    //       await Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (builder) => SettlementReport()));
                    //     },
                    //   ),
                    // ListTile(
                    //   title: Text('Paid Orders'),
                    //   onTap: () async {
                    //     scaffoldKey.currentState.closeDrawer();
                    //     _subscriptionBtStatus?.cancel();
                    //     await Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (builder) => ViewPaidOrders()));
                    //   },
                    // ),
                    // ListTile(
                    //   title: Text('Order'),
                    //   onTap: () async {
                    //     scaffoldKey.currentState.closeDrawer();
                    //     _subscriptionBtStatus?.cancel();
                    //     var data = await Navigator.push(context,
                    //         MaterialPageRoute(builder: (builder) => CheckIn()));
                    //     if (data != null && data) {
                    //       Get.find<KdsController>().setSubMenuIndex(2);
                    //     }
                    //   },
                    // ),
                    // ExpansionPanelList(
                    //   expansionCallback: (panelIndex, expanded) {
                    //     isCollaps = !isCollaps;
                    //     setState(() {});
                    //   },
                    //   children: [
                    //     ExpansionPanel(
                    //         backgroundColor: Colors.white,
                    //         headerBuilder: (context, isExpanded) {
                    //           return ListTile(
                    //             title: Text("Orders"),
                    //           );
                    //         },
                    //         body: buildNewTasks(context),
                    //         isExpanded: isCollaps,
                    //         canTapOnHeader: true),
                    //   ],
                    // ),
                    // if (Get.find<AuthController>()
                    //     .profileModel
                    //     .role
                    //     .contains('bill'))
                    //   ListTile(
                    //     title: Text('Rooms'),
                    //     onTap: () {
                    //       scaffoldKey.currentState.closeDrawer();
                    //       _subscriptionBtStatus?.cancel();
                    //       Get.toNamed(RouteHelper.getRoomManagementRoute());
                    //     },
                    //   ),
                    // ListTile(
                    //   title: Text('Reset Password'),
                    //   onTap: () {
                    //     scaffoldKey.currentState.closeDrawer();
                    //     String logo = '';
                    //     if (!Get.find<AuthController>()
                    //             .profileModel
                    //             .role
                    //             .contains('order') &&
                    //         Get.find<AuthController>()
                    //             .profileModel
                    //             .role
                    //             .contains('bill')) {
                    //       logo = Images.ic_cashier_app_logo;
                    //     } else if (Get.find<AuthController>()
                    //         .profileModel
                    //         .role
                    //         .contains('report')) {
                    //       logo = Images.ic_owner_app_logo;
                    //     } else if (Get.find<AuthController>()
                    //         .profileModel
                    //         .role
                    //         .contains('Manager')) {
                    //       logo = Images.ic_manager_app_logo;
                    //     } else {
                    //       logo = Images.ic_waiter_app_logo;
                    //     }

                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: ((context) => EmployeeResetPassword(
                    //                   resetToken:
                    //                       Get.find<AuthController>().getUserToken(),
                    //                   email: Get.find<AuthController>()
                    //                       .profileModel
                    //                       .empEmail,
                    //                   image: logo,
                    //                   password: '',
                    //                   fromPasswordChange: true,
                    //                 ))));

                    //     // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
                    //     //     Get.find<AuthController>().profileModel.empEmail,
                    //     //     Get.find<AuthController>().getUserToken(),
                    //     //     'password-change'));
                    //     // Get.toNamed(RouteHelper.getTapManagementRoute());
                    //   },
                    // ),
                    // if (GetPlatform.isIOS)
                    //   ListTile(
                    //     title: Text('Get ip of printer'),
                    //     onTap: () {
                    //       scaffoldKey.currentState.closeDrawer();
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (builder) => GetPrinterIp()));
                    //       // Get.toNamed(RouteHelper.getTapManagementRoute());
                    //     },
                    //   ),
                    // ListTile(
                    //   title: Text('Logout'),
                    //   onTap: () {
                    //     scaffoldKey.currentState.closeDrawer();
                    //     Get.dialog(
                    //         ConfirmationDialog(
                    //             icon: Images.support,
                    //             description: 'are_you_sure_to_logout'.tr,
                    //             isLogOut: true,
                    //             onYesPressed: () async {
                    //               socket.disconnect();
                    //               Get.find<RestaurantController>()
                    //                   .clearProductList();
                    //               Get.find<AuthController>().clearSharedData();
                    //               Get.offAllNamed(RouteHelper.getSignInRoute());
                    //             }),
                    //         useSafeArea: false);
                    //   },
                    // ),
                    // Spacer(),
                    ListTile(
                      title: Text(
                        'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
                        style: poppinsMedium.copyWith(
                            fontSize: 10, color: Colors.grey),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            key: scaffoldKey,
            backgroundColor: Colors.white,
            body: SafeArea(
              child:
                  GetBuilder<RestaurantController>(builder: (restController) {
                return GetBuilder<CartController>(builder: (posController) {
                  return posController.isLoading || restController.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // Divider(),
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              child: Row(
                                children: [
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowEmpList ==
                                      'Yes')
                                    Get.find<AuthController>()
                                            .employeeList
                                            .isNotEmpty
                                        ? GetBuilder<AuthController>(
                                            builder: (authController) {
                                            return SuperTooltip(
                                              borderRadius: 2,
                                              // bottom: 50,
                                              hasShadow: false,
                                              borderColor:
                                                  ColorTheme.borderGrey,
                                              // shadowColor: Colors.black
                                              //     .withOpacity(0.1),
                                              showBarrier: true,
                                              controller: _tableController,
                                              borderWidth: 1,
                                              popupDirection:
                                                  TooltipDirection.down,
                                              backgroundColor: Colors.white,
                                              left: 15,
                                              right: Get.width * 0.6 + 25,
                                              arrowTipDistance: 20,
                                              arrowBaseWidth: 0,
                                              arrowLength: 0,
                                              // borderWidth: 2.0,
                                              // showCloseButton:
                                              //     ShowCloseButton.none,
                                              touchThroughAreaShape:
                                                  ClipAreaShape.rectangle,
                                              touchThroughAreaCornerRadius: 5,
                                              minimumOutsideMargin: 0,
                                              barrierColor: Colors.transparent,

                                              content: ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  itemCount: authController
                                                      .employeeList.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        authController.setEmployeeIndex(
                                                            Get.find<AuthController>()
                                                                    .employeeList[
                                                                index]);
                                                        await _tableController
                                                            .hideTooltip();
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                left: 20,
                                                                bottom: authController.employeeList.length -
                                                                            1 ==
                                                                        index
                                                                    ? 10
                                                                    : 0,
                                                                top: index == 0
                                                                    ? 10
                                                                    : 0),
                                                            child: Text(
                                                              '${authController.employeeList[index].fName}',
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: ColorTheme
                                                                          .hintText),
                                                            ),
                                                          ),
                                                          if (authController
                                                                      .employeeList
                                                                      .length -
                                                                  1 !=
                                                              index)
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Divider(
                                                                  height: 1,
                                                                  color: ColorTheme
                                                                      .borderGrey),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                              child: Container(
                                                height: 40,
                                                width: Get.width * 0.3,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                  // color: ColorTheme.borderGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        authController
                                                                    .selectedEmployee ==
                                                                null
                                                            ? '${authController.profileModel!.empFname}'
                                                            : '${authController.selectedEmployee!.fName}',
                                                        maxLines: 1,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          color: ColorTheme
                                                              .hintText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        color:
                                                            ColorTheme.appColor)
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                        : SizedBox.shrink(),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowEmpList ==
                                      'Yes')
                                    SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_SMALL),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorTheme.borderGrey),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: searchController,
                                              textInputAction:
                                                  TextInputAction.search,
                                              autofocus: false,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              keyboardType: TextInputType.name,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5),
                                                suffixIcon: Icon(Icons.search,
                                                    color: ColorTheme.appColor),
                                                hintText:
                                                    '${Get.find<AuthController>().profileModel!.restaurants!.first.searchFood}',
                                                hintStyle:
                                                    poppinsMedium.copyWith(
                                                        fontSize: 13,
                                                        color: ColorTheme
                                                            .hintText),
                                                filled: true,
                                                fillColor:
                                                    Theme.of(context).cardColor,
                                              ),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                              onChanged: (value) async {
                                                if (restController
                                                        .categoryIndex !=
                                                    0)
                                                  restController
                                                      .setPOSWaiterCategoryIndex(
                                                          0);
                                                restController.update();
                                              },
                                            ),
                                          ),
                                          Container(
                                              height: 50,
                                              width: 1,
                                              color: Colors.grey),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: InkWell(
                                              onTap: () async {
                                                await _controller.showTooltip();
                                              },
                                              child: SuperTooltip(
                                                borderRadius: 2,
                                                // bottom: 50,
                                                hasShadow: false,
                                                borderColor:
                                                    ColorTheme.borderGrey,
                                                // shadowColor: Colors.black
                                                //     .withOpacity(0.1),
                                                showBarrier: true,
                                                controller: _controller,
                                                borderWidth: 1,
                                                popupDirection:
                                                    TooltipDirection.down,
                                                backgroundColor: Colors.white,
                                                right: 15,
                                                left: Get.width * 0.3 + 25,
                                                arrowTipDistance: 20,
                                                arrowBaseWidth: 0,
                                                arrowLength: 0,
                                                // borderWidth: 2.0,
                                                // showCloseButton:
                                                //     ShowCloseButton.none,
                                                touchThroughAreaShape:
                                                    ClipAreaShape.rectangle,
                                                touchThroughAreaCornerRadius: 5,
                                                minimumOutsideMargin: 0,
                                                barrierColor:
                                                    Colors.transparent,
                                                content: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: restController
                                                        .posFoodCategoryList
                                                        .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          restController
                                                              .setPOSWaiterCategoryIndex(
                                                                  restController
                                                                      .posFoodCategoryList[
                                                                          index]
                                                                      .id);
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          searchController
                                                              .clear();
                                                          await _controller
                                                              .hideTooltip();
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20,
                                                                      top: index ==
                                                                              0
                                                                          ? 10
                                                                          : 0,
                                                                      bottom: restController.posFoodCategoryList.length - 1 ==
                                                                              index
                                                                          ? restController.posFoodCategoryList.length > 14
                                                                              ? 50
                                                                              : 15
                                                                          : 0

                                                                      //  restController.posFoodCategoryList.length>14&&
                                                                      ),
                                                              child: Text(
                                                                restController
                                                                    .posFoodCategoryList[
                                                                        index]
                                                                    .name,
                                                                style: poppinsMedium.copyWith(
                                                                    fontSize:
                                                                        13,
                                                                    color: restController.posFoodCategoryList[index].id ==
                                                                            restController
                                                                                .categoryIndex
                                                                        ? ColorTheme
                                                                            .appColor
                                                                        : ColorTheme
                                                                            .hintText),
                                                              ),
                                                            ),
                                                            if (restController
                                                                        .posFoodCategoryList
                                                                        .length -
                                                                    1 !=
                                                                index)
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10),
                                                                child: Divider(
                                                                    height: 1,
                                                                    color: ColorTheme
                                                                        .borderGrey),
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                child: Icon(
                                                    Icons
                                                        .keyboard_arrow_down_outlined,
                                                    color: ColorTheme.appColor),
                                              ),
                                            ),
                                            // Icon(
                                            //     Icons
                                            //         .keyboard_arrow_down_outlined,
                                            //     color: ColorTheme.appColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              child: Divider(
                                color: Color(0xFFE6E6E6),
                                height: 1,
                              ),
                            ),
                            if (MediaQuery.of(context).size.shortestSide < 570)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 33,
                                  child: ListView.builder(
                                    // scrollDirection: Axis.horizontal,
                                    itemCount: restController
                                        .posFoodCategoryList.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          restController
                                              .setPOSWaiterCategoryIndex(
                                                  restController
                                                      .posFoodCategoryList[
                                                          index]
                                                      .id);
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          searchController.clear();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: index == 0 ? 0 : 11),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: restController
                                                            .posFoodCategoryList[
                                                                index]
                                                            .id ==
                                                        restController
                                                            .categoryIndex
                                                    ? ColorTheme.appColor
                                                    : ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            color: restController
                                                        .posFoodCategoryList[
                                                            index]
                                                        .id ==
                                                    restController.categoryIndex
                                                ? ColorTheme.appColor
                                                : Colors.white,
                                          ),
                                          child: Center(
                                            child: Text(
                                              restController
                                                  .posFoodCategoryList[index]
                                                  .name,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 14,
                                                  color: restController
                                                              .posFoodCategoryList[
                                                                  index]
                                                              .id ==
                                                          restController
                                                              .categoryIndex
                                                      ? Colors.white
                                                      : Colors.grey),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (MediaQuery.of(context).size.shortestSide < 570)
                              SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (MediaQuery.of(context).size.shortestSide >
                                      570)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: Dimensions.PADDING_SIZE_LARGE,
                                          left:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      height: Get.height,
                                      width: MediaQuery.of(context).size.width >
                                              1600
                                          ? Get.width * 0.15
                                          : Get.width * 0.25,
                                      decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              248, 248, 248, 1.0),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.RADIUS_DEFAULT)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL,
                                          horizontal:
                                              Dimensions.PADDING_SIZE_SMALL),
                                      child: ListView.builder(
                                        // scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: restController
                                            .posFoodCategoryList.length,

                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              restController
                                                  .setPOSWaiterCategoryIndex(
                                                      restController
                                                          .posFoodCategoryList[
                                                              index]
                                                          .id);
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              searchController.clear();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .PADDING_SIZE_EXTRA_SMALL,
                                                  vertical: 10),
                                              margin: EdgeInsets.only(
                                                top: Dimensions
                                                    .PADDING_SIZE_DEFAULT,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .RADIUS_DEFAULT),
                                                color: restController
                                                            .posFoodCategoryList[
                                                                index]
                                                            .id ==
                                                        restController
                                                            .categoryIndex
                                                    ? ColorTheme.appColor
                                                    : Colors.white,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  restController
                                                      .posFoodCategoryList[
                                                          index]
                                                      .name,
                                                  style: poppinsRegular.copyWith(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width >
                                                                  1600
                                                              ? 20
                                                              : 14,
                                                      color: restController
                                                                  .posFoodCategoryList[
                                                                      index]
                                                                  .id ==
                                                              restController
                                                                  .categoryIndex
                                                          ? Colors.white
                                                          : Color.fromRGBO(152,
                                                              152, 152, 1.0)),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  Expanded(
                                    // width: Get.width * 0.7,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      // key: UniqueKey(),
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15, bottom: 20),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        return products[index]
                                                    .name!
                                                    .toUpperCase() ==
                                                'CHECK IN'
                                            ? SizedBox.shrink()
                                            : DateConverter.isAvailable(
                                                    products[index]
                                                        .availableTimeStarts!,
                                                    products[index]
                                                        .availableTimeEnds!)
                                                ? products[index]
                                                        .name!
                                                        .toLowerCase()
                                                        .contains(
                                                            searchController
                                                                .text
                                                                .toLowerCase())
                                                    ? restController
                                                            .posFoodCategoryList
                                                            .isEmpty
                                                        ? WaiterProductWidget(
                                                            products: products,
                                                            scrollController:
                                                                _scrollController,
                                                            searchController:
                                                                searchController,
                                                            product:
                                                                products[index],
                                                            index: index,
                                                            length:
                                                                products.length,
                                                            isCampaign: false,
                                                          )
                                                        : restController
                                                                    .categoryIndex ==
                                                                0
                                                            ? WaiterProductWidget(
                                                                products:
                                                                    products,
                                                                scrollController:
                                                                    _scrollController,
                                                                searchController:
                                                                    searchController,
                                                                product:
                                                                    products[
                                                                        index],
                                                                index: index,
                                                                length: products
                                                                    .length,
                                                                isCampaign:
                                                                    false,
                                                              )
                                                            : products[index]
                                                                    .mainCategoryId!
                                                                    .contains(restController
                                                                        .categoryIndex
                                                                        .toString())
                                                                ? WaiterProductWidget(
                                                                    products:
                                                                        products,
                                                                    scrollController:
                                                                        _scrollController,
                                                                    searchController:
                                                                        searchController,
                                                                    product:
                                                                        products[
                                                                            index],
                                                                    index:
                                                                        index,
                                                                    length: products
                                                                        .length,
                                                                    isCampaign:
                                                                        false,
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                                                    : SizedBox.shrink()
                                                : SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                });
              }),
            ),
            bottomNavigationBar:
                GetBuilder<CartController>(builder: (cartController) {
              return cartController.cartList.isNotEmpty
                  ? SafeArea(
                      child: Container(
                      height: 65,
                      width: Get.width,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions
                            .PADDING_SIZE_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2A2A2A).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5))
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${'item'.tr}: ${cartController.cartList.length}',
                                      style: poppinsMedium.copyWith(
                                          color: ColorTheme.blue,
                                          fontSize: 11)),
                                  const SizedBox(
                                      height:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  Text(
                                    'Rs. ${PriceConverter.convertPrice(cartController.calculationCart(), isHideCurrency: true)}',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ]),
                            InkWell(
                              onTap: () async {
                                Get.find<CartController>().update();
                                searchController.clear();
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BillingViewCheckout()));
                                if (cartController.cartList.isNotEmpty) {
                                  for (var i = 0; i < products.length; i++) {
                                    for (var cart in cartController.cartList) {
                                      if (cart.product.id == products[i].id) {
                                        products[i].qty = cart.quantity;
                                        break;
                                      } else {
                                        products[i].qty = 0;
                                      }
                                    }
                                  }
                                } else {
                                  products = Get.find<AuthController>()
                                      .getProductList();
                                }
                                Get.find<RestaurantController>().update();
                              },
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.PADDING_SIZE_DEFAULT),
                                decoration: BoxDecoration(
                                    color: ColorTheme.appColor,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Center(
                                  child: Text(
                                    'Review Order',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ))
                  : const SizedBox();
            })
            ),
            );
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  // when app is in background
  void _handleMessage(RemoteMessage message) async {
    await Firebase.initializeApp();

    // if (message.data != null) {
    //   print(message.notification.android.sound);

    //   AndroidNotificationDetails androidNotificationDetails =
    //       AndroidNotificationDetails(
    //     message.notification.android.sound,
    //     'My Genie',
    //     importance: Importance.max,
    //     enableVibration: true,
    //     playSound: true,
    //     priority: n.Priority.high,
    //     // priority: Priority.high,
    //     // ticker: 'ticker',
    //     sound: RawResourceAndroidNotificationSound(
    //         message.notification.android.sound),
    //   );
    //   NotificationDetails notificationDetails = NotificationDetails(
    //       android: androidNotificationDetails,
    //       iOS: DarwinNotificationDetails());
    //   await flutterLocalNotificationsPlugin.show(0, message.notification.title,
    //       message.notification.body, notificationDetails,
    //       payload: jsonEncode(message.data));
    // }
  }

  Future<dynamic> onSelectNotification(NotificationResponse payload) async {
    // implement the navigation logic
    if (Platform.isAndroid) {
      var jsonData = jsonDecode(payload.payload!);
      // print('$jsonData');
      if (jsonData != null) {
        // print('===============${message.data}');
      }
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('..................message');

    if (GetPlatform.isAndroid) {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        message.notification!.android!.sound!,
        'My Genie',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        priority: Priority.high,
        // priority: Priority.high,
        // ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound(
            message.notification!.android!.sound!),
      );
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: jsonEncode(message.data));
    }
  }

  Future initfirebase() async {
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> registerNotification() async {
    _messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        try {
          var new_order = AndroidNotificationChannel(
            'new_order', // Unique ID for channel 1
            'new_order', // Name of channel 1
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'new_order'), // Sound file for channel 1
          );

          var confirm_order = AndroidNotificationChannel(
            'confirm_order', // Unique ID for channel 2
            'confirm_order', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'confirm_order'), // Sound file for channel 2
          );
          var item_added = AndroidNotificationChannel(
            'item_added', // Unique ID for channel 2
            'item_added', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'item_added'), // Sound file for channel 2
          );
          var settle_bill = AndroidNotificationChannel(
            'settle_bill', // Unique ID for channel 2
            'settle_bill', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'settle_bill'), // Sound file for channel 2
          );
          var attend_table = AndroidNotificationChannel(
            'attend_table', // Unique ID for channel 2
            'attend_table', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'attend_table'), // Sound file for channel 2
          );

          var order_ready = AndroidNotificationChannel(
            'order_ready', // Unique ID for channel 2
            'order_ready', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'order_ready'), // Sound file for channel 2
          );
          var swiggy_new_order = AndroidNotificationChannel(
            'swiggy_new_order', // Unique ID for channel 2
            'swiggy_new_order', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'swiggy_new_order'), // Sound file for channel 2
          );
          var five_sec_buzzer = AndroidNotificationChannel(
            'five_sec_buzzer', // Unique ID for channel 2
            'five_sec_buzzer', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'five_sec_buzzer'), // Sound file for channel 2
          );
          var ten_sec_buzzer = AndroidNotificationChannel(
            'ten_sec_buzzer', // Unique ID for channel 2
            'ten_sec_buzzer', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'ten_sec_buzzer'), // Sound file for channel 2
          );
          var forty_five_sec_buzzer = AndroidNotificationChannel(
            'forty_five_sec_buzzer', // Unique ID for channel 2
            'forty_five_sec_buzzer', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'forty_five_sec_buzzer'), // Sound file for channel 2
          );
          var silent = AndroidNotificationChannel(
            'silent', // Unique ID for channel 2
            'silent', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'silent'), // Sound file for channel 2
          );
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(new_order);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(silent);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(forty_five_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(five_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(ten_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(confirm_order);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(item_added);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(settle_bill);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(attend_table);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(order_ready);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(swiggy_new_order);
          if (Platform.isIOS) {
          } else if (Platform.isAndroid) {
            // _showNotification(message);
            final alertSound = message.notification!.android!.sound;
            final loopOrderAlert = isLoopingOrderAlertSound(alertSound);
            if (loopOrderAlert) {
              await flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>()
                  ?.createNotificationChannel(const AndroidNotificationChannel(
                    orderAlertSilentChannelId,
                    'Order alert',
                    importance: Importance.high,
                    playSound: false,
                  ));
            }
            AndroidNotificationDetails androidNotificationDetails =
                AndroidNotificationDetails(
              loopOrderAlert ? orderAlertSilentChannelId : alertSound!,
              'My Genie',
              importance: Importance.max,
              enableVibration: true,
              playSound: !loopOrderAlert,
              priority: Priority.high,
              // priority: Priority.high,
              // ticker: 'ticker',
              sound: loopOrderAlert
                  ? null
                  : RawResourceAndroidNotificationSound(alertSound!),
            );
            NotificationDetails notificationDetails = NotificationDetails(
                android: androidNotificationDetails,
                iOS: DarwinNotificationDetails());
            await flutterLocalNotificationsPlugin.show(
                0,
                message.notification!.title,
                message.notification!.body,
                notificationDetails,
                payload: jsonEncode(message.data));
            if (loopOrderAlert) {
              await startOrderAlert('${message.data['order_id'] ?? ''}');
            }
          }
          print('.................. register');
        } catch (e) {
          print(e.toString());
        }
      });
      //  await checkForInitialMessage();
    } else {}
  }

  dataCheck(OrderList order) async {
    try {
      if (currentPrintIndex <= cartProductList.length - 1) {
        if (cartProductList[currentPrintIndex].isEmpty) {
          for (var i = currentPrintIndex; i < cartProductList.length; i++) {
            if (cartProductList[i].isEmpty) {
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck(order);
              break;
            } else {
              if (GetPlatform.isWindows) {
                final printers = await Printing.listPrinters();
                for (var element in printers) {
                  if (element.isAvailable &&
                      (element.name.toLowerCase() ==
                          Get.find<AuthController>()
                              .profileModel!
                              .restaurantPrinterNew![currentPrintIndex]
                              .wifiPrinterName!
                              .toLowerCase())) {
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          printType: 'kot',
                          orderType: order.orderType!,
                          stationName: cartProductList[currentPrintIndex]
                                  .first
                                  .station ??
                              '',
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.restaurantOrderId!,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName:
                              '${order.vendorEmployee?.waiterName ?? ''}',
                          tablename: order.restaurantTable == null ||
                                  order.restaurantTable!.tableNo == ''
                              ? order.orderType == 'delivery'
                                  ? 'Delivery'
                                  : order.orderType == 'take_away'
                                      ? 'Take Away'
                                      : 'WC'
                              : order.restaurantTable!.title == ''
                                  ? '${order.restaurantTable!.tableNo}'
                                  : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                          custName: order.userName ?? '',
                          custPhone: '${order.user?.phone ?? ''}',
                          kotOrderList:
                              cartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderNote ?? ''),
                      // generateKotPdf(order)
                    );

                    break;
                  }
                }
                // await Printing.directPrintPdf(
                //   printer: printers.first,
                //   onLayout: (_) => generateKotPdf(order),
                // );
                currentPrintIndex = currentPrintIndex + 1;
                dataCheck(order);

                break;
              } else {
                if (Platform.isIOS) {
                  await iosPrintEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'kot',
                          orderType: order.orderType!,
                          stationName: cartProductList[currentPrintIndex]
                                  .first
                                  .station ??
                              '',
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.restaurantOrderId!,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName:
                              '${order.vendorEmployee?.waiterName ?? ''}',
                          tablename: order.restaurantTable == null ||
                                  order.restaurantTable!.tableNo == ''
                              ? order.orderType == 'delivery'
                                  ? 'Delivery'
                                  : order.orderType == 'take_away'
                                      ? 'Take Away'
                                      : 'WC'
                              : order.restaurantTable!.title == ''
                                  ? '${order.restaurantTable!.tableNo}'
                                  : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                          custName: order.userName ?? '',
                          custPhone: '${order.user?.phone ?? ''}',
                          kotOrderList:
                              cartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderNote ?? ''),
                      order);
                } else {
                  await printEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'kot',
                          orderType: order.orderType!,
                          stationName: cartProductList[currentPrintIndex]
                                  .first
                                  .station ??
                              '',
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.restaurantOrderId!,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName:
                              '${order.vendorEmployee?.waiterName ?? ''}',
                          tablename: order.restaurantTable == null ||
                                  order.restaurantTable!.tableNo == ''
                              ? order.orderType == 'delivery'
                                  ? 'Delivery'
                                  : order.orderType == 'take_away'
                                      ? 'Take Away'
                                      : 'WC'
                              : order.restaurantTable!.title == ''
                                  ? '${order.restaurantTable!.tableNo}'
                                  : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                          custName: order.userName ?? '',
                          custPhone: '${order.user?.phone ?? ''}',
                          kotOrderList:
                              cartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderNote ?? ''),
                      order);
                }
                break;
              }
            }
          }
        } else {
          if (GetPlatform.isWindows) {
            final printers = await Printing.listPrinters();
            for (var element in printers) {
              if (element.isAvailable &&
                  (element.name.toLowerCase() ==
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurantPrinterNew![currentPrintIndex]
                          .wifiPrinterName!
                          .toLowerCase())) {
                await Printing.directPrintPdf(
                  printer: element,
                  onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                      printType: 'kot',
                      orderType: order.orderType,
                      stationName:
                          cartProductList[currentPrintIndex].first.station ??
                              '',
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.restaurantOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                      tablename: order.restaurantTable == null ||
                              order.restaurantTable!.tableNo == ''
                          ? order.orderType == 'delivery'
                              ? 'Delivery'
                              : order.orderType == 'take_away'
                                  ? 'Take Away'
                                  : 'WC'
                          : order.restaurantTable!.title == ''
                              ? '${order.restaurantTable!.tableNo}'
                              : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                      custName: order.userName ?? '',
                      custPhone: '${order.user?.phone ?? ''}',
                      kotOrderList: cartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderNote ?? ''),
                  // generateKotPdf(order)
                );
                break;
              }
            }
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck(order);
          } else {
            if (Platform.isIOS) {
              await iosPrintEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'kot',
                      orderType: order.orderType!,
                      stationName:
                          cartProductList[currentPrintIndex].first.station ??
                              '',
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.restaurantOrderId!,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                      tablename: order.restaurantTable == null ||
                              order.restaurantTable!.tableNo == ''
                          ? order.orderType == 'delivery'
                              ? 'Delivery'
                              : order.orderType == 'take_away'
                                  ? 'Take Away'
                                  : 'WC'
                          : order.restaurantTable!.title == ''
                              ? '${order.restaurantTable!.tableNo}'
                              : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                      custName: order.userName ?? '',
                      custPhone: '${order.user?.phone ?? ''}',
                      kotOrderList: cartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderNote ?? ''),
                  order);
            } else {
              await printEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'kot',
                      orderType: order.orderType!,
                      stationName:
                          cartProductList[currentPrintIndex].first.station ??
                              '',
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.restaurantOrderId!,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                      tablename: order.restaurantTable == null ||
                              order.restaurantTable!.tableNo == ''
                          ? order.orderType == 'delivery'
                              ? 'Delivery'
                              : order.orderType == 'take_away'
                                  ? 'Take Away'
                                  : 'WC'
                          : order.restaurantTable!.title == ''
                              ? '${order.restaurantTable!.tableNo}'
                              : '${order.restaurantTable!.title}-${order.restaurantTable?.tableNo}',
                      custName: order.userName ?? '',
                      custPhone: '${order.user?.phone ?? ''}',
                      kotOrderList: cartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderNote ?? ''),
                  order);
            }
          }
        }
      } else {
        if (isFailedPrint) {
          if (Platform.isAndroid) {
            await _subscriptionBtStatus?.cancel();
          }
          await Get.bottomSheet(PrintDialog(
            cartProductList: failedCartProductList,
            index: Get.find<KdsController>().updatedOrderIndex,
          ));
          isProcessingOrder = false;
          if (orderQueue.isNotEmpty) {
            processNextOrder(); // Continue with the next order
          }
        }
        isProcessingOrder = false;
        if (orderQueue.isNotEmpty) {
          processNextOrder(); // Continue with the next order
        }
      }
    } catch (e) {
      isProcessingOrder = false;
      if (orderQueue.isNotEmpty) {
        processNextOrder(); // Continue with the next order
      }
    }
  }

  Future printEscPos(List<int>? bytes, OrderList? order) async {
    print('bytes length:${bytes!.length}');
    // bytes += generator.feed(2);
    // bytes += generator.cut();

    // await PrinterManager.instance
    //     .disconnect(type: PrinterType.bluetooth); //  what this do explain
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        port: '9100',
        typePrinter:
            Get.find<AuthController>().profileModel!.isLANPrint == 'Yes'
                ? PrinterType.network
                : PrinterType.bluetooth,
        address: Get.find<AuthController>().profileModel!.isLANPrint == 'Yes'
            ? Get.find<AuthController>()
                .profileModel!
                .restaurantPrinterNew![currentPrintIndex]
                .wifiPrinterIp
            : Get.find<AuthController>()
                .profileModel!
                .restaurantPrinterNew![currentPrintIndex]
                .printerIp,
        deviceName: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerName); //device name or ip was mandadory
    // try {
    //   await _printerManager.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(
    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address!,
    //       isBle: bluetoothPrinter.isBle ?? false,
    //     ),
    //   );
    //   pendingTask = null;
    // } catch (e) {
    //   print('%%%%%%%$e');
    // }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
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
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }

    try {
      bool data = await _printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      bytes = null;
      Future.delayed(Duration(seconds: 2), () async {
        // print('%%%%%%%%%%%%%isPrinted---$data');
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance.disconnect(
            type: Get.find<AuthController>().profileModel!.isLANPrint == 'Yes'
                ? PrinterType.network
                : PrinterType.bluetooth);
        currentPrintIndex = currentPrintIndex + 1;
        dataCheck(order!);
      });
    } catch (e) {}
  }

  Future iosPrintEscPos(List<int>? bytes, OrderList? order) async {
    print('########## bytes length ${bytes!.length}');
    // bytes += generator.feed(2);
    // bytes += generator.feed(2);
    // bytes += generator.cut();

    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    if (Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .macPrinterIp ==
            '' &&
        NetworkPrinterResolver.kotPrinterAt(currentPrintIndex) == null) {
      // showErrorToast(
      //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
      isConnect = true;
      isFailedPrint = true;
      failedCartProductList[currentPrintIndex] =
          cartProductList[currentPrintIndex];
      currentPrintIndex = currentPrintIndex + 1;
      dataCheck(order!);
    } else {
      final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
          macPrinterAddress: Get.find<AuthController>()
              .profileModel!
              .restaurantPrinterNew![currentPrintIndex]
              .macPrinterIp!);
      Future.delayed(Duration(seconds: 2), () async {
        if (result) {
          await IosPrintTransport.writeBytes(bytes!);
          Future.delayed(Duration(seconds: 2), () async {
            bytes = null;
            var isDisconnect =
            print('is disconnect $isDisconnect');
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck(order!);
          });
          print("print test result:  $result");
        } else {
          //no conectado, reconecte
          // showErrorToast('Failed to bluetooth connect');
          // showErrorToast(
          //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
          isConnect = true;
          isFailedPrint = true;
          failedCartProductList[currentPrintIndex] =
              cartProductList[currentPrintIndex];
          currentPrintIndex = currentPrintIndex + 1;
          dataCheck(order!);
        }
      });
    }
    // });
  }

  void processNextOrder() async {
    // If no orders in the queue or an order is currently being processed, return.
    if (orderQueue.isEmpty || isProcessingOrder) return;

    // Mark as processing
    isProcessingOrder = true;

    // Remove the next order from the queue
    var currentOrder = orderQueue.removeAt(0); // Get and remove the first order

    try {
      currentPrintIndex = 0;
      cartProductList = [];
      failedCartProductList = [];
      skipFailedList = [];
      isFailedPrint = false;

      for (var i = 0;
          i <
              Get.find<AuthController>()
                  .profileModel!
                  .restaurantPrinterNew!
                  .length;
          i++) {
        RestaurantPrinterNew printer =
            Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
        skipFailedList.add(false);
        List<OrderDetails> tempCartList = [];
        var foodList = currentOrder.orderDetails;
        for (var e in foodList!) {
          if (e.station == printer.areaName && e.foodStatus != 3) {
            tempCartList.add(e);
          } else if (currentOrder.fOrderStatus == 3 &&
              e.station == printer.areaName) {
            tempCartList.add(e);
          } else if (e.station == printer.areaName &&
              e.cancelBy != '' &&
              e.cancelBy ==
                  Get.find<AuthController>().profileModel!.empId.toString() &&
              e.cancelAt != null &&
              e.cancelAt == currentOrder.updatedAt) {
            tempCartList.add(e);
          }
        }
        cartProductList.add(tempCartList);
        failedCartProductList.add([]);
      }
      if (Platform.isAndroid) {
        await _subscriptionBtStatus?.cancel();

        await listenBlutooth(order: currentOrder);
      }
      dataCheck(currentOrder);
      // printDebug();
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      // await Future.delayed(Duration(seconds: 2)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      // isProcessingOrder = false;

      // If there are more orders in the queue, process the next one
      if (orderQueue.isNotEmpty) {
        processNextOrder(); // Continue with the next order
      }
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcess(OrderList order) {
    // Add the new order to the queue
    orderQueue.add(order);

    // Start processing the next order if not already processing
    if (!isProcessingOrder) {
      processNextOrder();
    }
  }

  void processNextOrderFromSocket() async {
    // If no orders in the queue or an order is currently being processed, return.
    if (orderIdQueue.isEmpty || isProcessingOrderQueue) return;

    // Mark as processing
    isProcessingOrderQueue = true;

    // Remove the next order from the queue
    var currentOrder =
        orderIdQueue.removeAt(0); // Get and remove the first order

    try {
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      // showCustomSnackBar('Socket order api call');

      var isCallApi = currentOrder.orderType != 'new-order'
          ? false
          : await Get.find<KdsController>().getOrderDetailFromSocket(
              socket: socket,
              foodStatus: '0',
              type: currentOrder.orderType,
              orderId: '${currentOrder.orderId}',
              socketJson: currentOrder.orderType == 'new-order'
                  ? currentOrder.newOrderJson
                  : null,
              callbackFunction: (OrderList? order) async {
                await Future.delayed(
                    Duration(seconds: 2)); // Simulate async processing
                if (order != null) checkQueueProcess(order);
              });

      // if (currentOrder.orderType == 'new-order' &&
      //     Get.find<AuthController>().profileModel!.empId.toString() ==
      //         Get.find<KdsController>()
      //             .getWaiterOrderListResponse!
      //             .orders!
      //             .last
      //             .waiterId
      //             .toString() &&
      //     Get.find<KdsController>()
      //             .getWaiterOrderListResponse!
      //             .orders!
      //             .last
      //             .orderDetails!
      //             .length ==
      //         1 &&
      //     Get.find<KdsController>()
      //             .getWaiterOrderListResponse!
      //             .orders!
      //             .last
      //             .orderDetails!
      //             .first
      //             .foodDetails!
      //             .name!
      //             .toUpperCase() ==
      //         'CHECK IN') {
      //   SchedulerBinding.instance.addPostFrameCallback((_) {
      //     // _scrollController.animateTo(
      //     //     _scrollController.position.maxScrollExtent,
      //     //     duration: const Duration(milliseconds: 1),
      //     // curve: Curves.fastOutSlowIn);
      //   });
      // }
      if ((Get.find<AuthController>()
                      .profileModel
                      ?.restaurants
                      ?.first
                      .printingOption ==
                  'Waiter' ||
              (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .printingOption ==
                      'Fixed' &&
                  Get.find<AuthController>().profileModel?.defaultUser ==
                      'Yes')) &&
          isCallApi != null &&
          isCallApi &&
          ((currentOrder.orderType == 'update-order' ||
                  currentOrder.orderType == 'update-order-status')
              ? Get.find<KdsController>()
                      .getWaiterOrderListResponse
                      ?.orders![Get.find<KdsController>().updatedOrderIndex]
                      .isPrintKot ==
                  'Yes'
              : false)) {
        // showCustomSnackBar('Socket order processing');

        List<OrderDetails> tempCartList = [];
        List<OrderDetails> cancelFoodList = [];
        if (currentOrder.orderType == 'update-order' ||
            currentOrder.orderType == 'update-order-status') {
          var foodList = Get.find<KdsController>()
              .getWaiterOrderListResponse!
              .orders![Get.find<KdsController>().updatedOrderIndex]
              .orderDetails;

          for (var e in foodList!) {
            if (currentOrder.orderType == 'update-order-status') {
              if (cancelFoodList.isEmpty && e.foodStatus != 3) {
                tempCartList.add(e);
              } else if (e.foodStatus == 3 &&
                  e.cancelBy != '' &&
                  e.cancelBy ==
                      Get.find<AuthController>()
                          .profileModel!
                          .empId
                          .toString() &&
                  e.cancelAt != null &&
                  e.cancelAt ==
                      Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .updatedAt) {
                cancelFoodList.add(e);
                tempCartList = [];
              }
              if (Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .fOrderStatus ==
                      3 &&
                  e.cancelBy != '' &&
                  e.cancelBy ==
                      Get.find<AuthController>()
                          .profileModel!
                          .empId
                          .toString() &&
                  e.cancelAt != null &&
                  e.cancelAt ==
                      Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .updatedAt) {
                tempCartList.add(e);
              }
            } else if (currentOrder.orderType == 'update-order') {
              if (e.foodStatus != 3 &&
                  Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .editOrderCount ==
                      e.itemUpdateCount) {
                tempCartList.add(e);
              }
            }
          }
          if (cancelFoodList.isNotEmpty) {
            OrderList tempOrder = OrderList(
                updatedAt: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .updatedAt,
                fOrderStatus: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .fOrderStatus,
                editOrderCount: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .editOrderCount,
                orderNote: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderNote,
                orderType: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderType,
                restaurantOrderId: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantOrderId,
                userName: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .userName,
                vendorEmployee: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .vendorEmployee,
                deliveryAddress: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .deliveryAddress,
                orderDetails: cancelFoodList,
                serveOrderDetails: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .serveOrderDetails,
                restaurantTable: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantTable,
                user: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .user);
            Future.delayed(Duration(seconds: 2));
            checkQueueProcess(tempOrder);
          } else if (tempCartList.isNotEmpty) {
            OrderList tempOrder = OrderList(
                updatedAt: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .updatedAt,
                fOrderStatus: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .fOrderStatus,
                editOrderCount: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .editOrderCount,
                orderNote: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderNote,
                orderType: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderType,
                restaurantOrderId: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantOrderId,
                userName: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .userName,
                vendorEmployee: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .vendorEmployee,
                deliveryAddress: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .deliveryAddress,
                orderDetails: tempCartList,
                serveOrderDetails: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .serveOrderDetails,
                restaurantTable: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantTable,
                user: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .user);
            Future.delayed(Duration(seconds: 2));
            checkQueueProcess(tempOrder);
          }
        }
      }

      await Future.delayed(Duration(seconds: 1)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      isProcessingOrderQueue = false;

      // If there are more orders in the queue, process the next one
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket(); // Continue with the next order
      }
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcessFromSocket(
      {String? orderType,
      String? orderId,
      String? otherValue,
      dynamic newOrderJson}) {
    // Add the new order to the queue

    orderIdQueue.add(OrderIdType(
        orderId: orderId,
        orderType: orderType,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  listenBlutooth({OrderList? order}) {
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' -----------------beach billing status bt $status ------------------ ');

      if (status == BTStatus.connected) {
        isConnect = true;
        if (Platform.isAndroid) {
          // Future.delayed(const Duration(milliseconds: 1000), () async {
          //   PrinterManager.instance.send(
          //       type: Get.find<AuthController>().profileModel!.isLANPrint ==
          //               'Yes'
          //           ? PrinterType.network
          //           : PrinterType.bluetooth,
          //       bytes: pendingTask!);
          //   pendingTask = null;
          // });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      } else if (status == BTStatus.none) {
        if (!isConnect) {
          Future.delayed(Duration(seconds: 2), () async {
            // showErrorToast(
            //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
            if (isSkipFirstTimeOrder && !skipFailedList[currentPrintIndex]) {
              Future.delayed(Duration(seconds: 5), () {
                isConnect = true;
                // isFailedPrint = true;
                // failedCartProductList[currentPrintIndex] =
                //     cartProductList[currentPrintIndex];
                // currentPrintIndex = currentPrintIndex + 1;
                skipFailedList[currentPrintIndex] = true;
                isSkipFirstTimeOrder = false;
                dataCheck(order!);
              });
            } else {
              isConnect = true;
              isFailedPrint = true;
              failedCartProductList[currentPrintIndex] =
                  cartProductList[currentPrintIndex];
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck(order!);
            }
          });
        } else {
          isConnect = false;
          isSkipFirstTimeOrder = true;
          print('%%%%%%%%%');
        }
      }
    });
  }
}
