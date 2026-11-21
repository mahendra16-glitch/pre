import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/location_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_manually_print_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_swiggy_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/helper/print_debug_logger.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/widget/print_debug_panel.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/main.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/beep.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/screens/cancel_order/cancel_order.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/customer_report.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/view/customer_designation_master.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_report.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/stock_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/unit_price_master.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/daily_consumption_report.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_inventory.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_master.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_report.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/cancellation%20reason/cancellation_master.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/prep_serve_time_report/perp_serve_time_report.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/home/order_view.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/home/home_page.dart';
import 'package:mygenie_restaurant/view/screens/online_unpaid_order/online_unpaid_order.dart';
import 'package:mygenie_restaurant/view/screens/pay_later_order/pay_later_scree.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/cancel_order_wise_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_details_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/item_wise_addon_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/item_wise_variation_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/order_audit_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/order_wise_logs.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/profit_loss_report.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/aggregator_setup/aggregator_setup.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/coupon.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/coupon_report.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/delivery_management/delivery_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/payment_type/payment_type.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/resturant_setting/resturant_setting.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/printer_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/table_management/table_management_screen.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:mygenie_restaurant/view/screens/swiggy_zomato/date_wise_orderlist.dart';
import 'package:mygenie_restaurant/view/screens/customer_management/customer_management.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/room_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_report.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:upgrader/upgrader.dart';
import '../../../../controller/kds_controller.dart';
import '../../../../controller/table_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as prefix;

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

Socket? homeSocket;

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<BTStatus>? _singleSplitBleStatus;
  TextEditingController searchController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  PackageInfo? packageInfo;
  PrinterManager _printerManager = PrinterManager.instance;
  List<List<OrderDetails>> cartProductList = [];
  List<List<OrderFoodDetails>> swiggyCartProductList = [];
  List<List<OrderDetails>> failedCartProductList = [];
  List<bool> skipFailedList = [];
  int currentPrintIndex = 0;
  FirebaseMessaging? _messaging;
  bool isFailedPrint = false;
  List<int>? pendingTask;
  bool isConnect = true;
  bool isSkipFirstTimeOrder = false;
  bool isSkipSecondTimeOrder = false;

  String selectedFilter = 'all';
  // int status = 0;
  late TabController _tabController;
  Timer? timer;

  bool isSwitched = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<KdsController>().setMainMenuIndex(3);
      Get.find<KdsController>().setSubMenuIndex(4);
      if (!GetPlatform.isWindows) {
        var initializationSettingsAndroid =
            AndroidInitializationSettings('notification_icon');
        var initializationSettingsIOS = DarwinInitializationSettings();
        var initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
        flutterLocalNotificationsPlugin.initialize(initializationSettings,
            onDidReceiveNotificationResponse: onSelectNotification);

        setupInteractedMessage();
        registerNotification();

        // checkForInitialMessage();
        initfirebase();
        FirebaseMessaging.onMessage.listen(_handleMessage);
      }
      initApiCall();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    homeSocket?.dispose();
    super.dispose();
  }

  initApiCall() async {
    if (Get.find<AuthController>().profileModel!.role!.contains('aggregator'))
      await Get.find<SwiggyController>().fetchOrders();
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
    _subscriptionBtStatus?.cancel();
    _singleSplitBleStatus?.cancel();
    await Get.find<KdsController>().getWaiterPOSOrderList();
    await Get.find<TableController>().getTableListFromLocally();
    if (Get.find<AuthController>().profileModel!.role!.contains('table_view'))
      await Get.find<TableController>().getWaiterOrderListForTableView();
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .isShowPopularCategory ==
        'Yes') await Get.find<ProductController>().getPopularFoodList();

    connectToSocketIO();
    packageInfo = await PackageInfo.fromPlatform();

    timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => Get.find<KdsController>().update());
  }

  void connectToSocketIO() {
    try {
      // Configure and initialize the socket connection
      // homeSocket = io(
      //   AppConstants.SOCKET_BASE_URL,
      //   OptionBuilder()
      //       .setPath('/socket') // Same as path in your JS code
      //       .setTransports(['websocket']) // Important for WebSocket only
      //       .enableForceNew() // Optional: always creates a new connection
      //       .enableReconnection()
      //       .enableAutoConnect() // Optional: auto reconnect
      //       .build(),
      // );
      homeSocket = io(AppConstants.SOCKET_BASE_URL, <String, dynamic>{
        'transports': ['websocket'],
        // 'path': '/socket',
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 999999,
        'reconnectionDelay': 2000,
      });

      homeSocket?.onConnect((_) {
        homeSocket?.emit('join_restaurant', {
          'restaurant_id':
              Get.find<AuthController>().profileModel!.restaurants![0].id
        });
      });
      homeSocket?.on('joined_restaurant', (data) {
        log('[socket] joined ${data['room']}');
      });

      // Connect to the WebSocket
      if (!homeSocket!.connected) {
        homeSocket?.connect();
      }

      // Listen for the 'new_order' event with a dynamic restaurant ID
      String restaurantId = Get.find<AuthController>()
          .profileModel!
          .restaurants![0]
          .id
          .toString();
      homeSocket?.off('order-engage_$restaurantId');

      homeSocket?.on('order-engage_$restaurantId', (data) async {
        log('Received socket data: $data');
        if (restaurantId == '${data[2]}') {
          // Handle various order-related events
          await Get.find<KdsController>().orderEngageFromSocket(
            orderId: '${data[0]}',
            status: data[3],
          );
        }
      });
      homeSocket?.off('new_order_$restaurantId');

      homeSocket?.on('new_order_$restaurantId', (data) async {
         final receivedOrderId = '${data[1]}';
  log('socket_id: ${homeSocket?.id}, order_id: $receivedOrderId');
  log('Received socket data: $data');
        if (restaurantId == '${data[2]}') {
          // Handle various order-related events
          if (data[0] == 'update-order' ||
              data[0] == 'delivery-assign-order' ||
              data[0] == 'new-order' ||
              data[0] == 'update-order-paid' ||
              data[0] == 'scan-new-order' ||
              data[0] == 'split-order' ||
              data[0] == 'update-order-target' ||
              data[0] == 'update-order-source' ||
              data[0] == 'update-food-status' ||
              data[0] == 'update-item-status' ||
              data[0] == 'update-order-status') {
            checkQueueProcessFromSocket(
              isAggregator: false,
              orderType: data[0],
              orderId: '${data[1]}',
              otherValue: data[0] == 'update-food-status'
                  ? '${data[3]}'
                  : data[0] == 'update-item-status'
                      ? '${data[3]}'
                      : data[0] == 'delivery-assign-order'
                          ? '${data[3]}'
                          : '0',
              newOrderJson: data.length > 4 ? data[4] : null,
              // newOrderJson: data[0] == 'new-order' ? data[4] : null,
            );
          }
        }
      });
      homeSocket?.off(
          'aggregator_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}');

      homeSocket?.on(
          'aggregator_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}',
          (data) async {
        print('////aggregator_order_/////$data');
        if (Get.find<AuthController>()
                .profileModel!
                .restaurants![0]
                .id
                .toString() ==
            '${data[2]}') {
          if (data[0] == 'aggrigator-order' ||
              data[0] == 'aggrigator-order-update') {
            checkQueueProcessFromSocket(
                isAggregator: true,
                orderType: data[0],
                orderId: '${data[1]}',
                otherValue:
                    data[0] == 'aggrigator-order-update' ? '${data[3]}' : '0',
                newOrderJson: data.length > 4 ? data[4] : null);
          }
        }
      });
      homeSocket?.off('update_table_$restaurantId');

      // homeSocket?.on('update_table_$restaurantId', (data) async {
      //   print('Received socket table data: $data');

      //   if (restaurantId == '${data[2]}' &&
      //       Get.find<AuthController>()
      //               .profileModel!
      //               .restaurants!
      //               .first
      //               .settings!
      //               .autoPaid !=
      //           'Yes') {
      //     if (data[1].toString() != '0') {
      //       await Get.find<TableController>().setValueOfTableFromSocket(
      //           tableId: data[1].toString(),
      //           value: data[3] == 'engage' ? 'Yes' : 'No');
      //     }
      //   }
      // });
      homeSocket?.on('manually_print_$restaurantId', (data) async {
        print('Received socket Manual Print data: $data');

        if (restaurantId == '${data[2]}') {
          if (data[0].toString().toLowerCase() == 'kot') {
            checkQueueProcessFromSocket(
                isAggregator: false,
                orderType: '',
                orderId: '${data[1]}',
                otherValue: '${data[3]}',
                newOrderJson: null,
                isKOTFromFixedStation: true);
          } else if (data[0].toString().toLowerCase() == 'bill') {
            checkQueueProcessFromSocket(
                isAggregator: false,
                orderType: '',
                orderId: '${data[1]}',
                otherValue: '0',
                newOrderJson: null,
                isBillFromFixedStation: true,
                isKOTFromFixedStation: false);
          } else if (data[0].toString().toLowerCase() == 'both') {
            checkQueueProcessFromSocket(
                isAggregator: false,
                orderType: '',
                orderId: '${data[1]}',
                otherValue: '${data[3]}',
                newOrderJson: null,
                isBillFromFixedStation: false,
                isKOTFromFixedStation: true);
            checkQueueProcessFromSocket(
                isAggregator: false,
                orderType: '',
                orderId: '${data[1]}',
                otherValue: '0',
                newOrderJson: null,
                isBillFromFixedStation: true,
                isKOTFromFixedStation: false);
          }
        }
      });

      homeSocket?.on('food_update_$restaurantId', (data) async {
        log('Received food update Print data: $data');
        if (data['type'] == 'update-food') {
          log('Processing Update Food Socket');
          await Get.find<AuthController>().syncProductFromSocket(data);
          Get.find<MenuManagementController>().handleSocketFoodUpdate(data);
        } else if (data['type'] == 'delete-food') {
          log('Processing Delete Food Socket');
          await Get.find<AuthController>().deleteProductFromSocket(data);
          Get.find<MenuManagementController>().handleSocketFoodDelete(data);
        }
      });

      // Handle the 'disconnect' event
      homeSocket?.on('disconnect', (reason) {
        print('Socket disconnected: $reason');

        // Attempt to reconnect by reinitializing the socket connection
        // homeSocket = io(
        //   AppConstants.SOCKET_BASE_URL,
        //   OptionBuilder()
        //       // .setPath('/socket') // Same as path in your JS code
        //       .setTransports(['websocket']) // Important for WebSocket only
        //       .enableForceNew() // Optional: always creates a new connection
        //       .enableReconnection()
        //       .enableAutoConnect() // Optional: auto reconnect
        //       .build(),
        // );
      });

      homeSocket?.onReconnect((_) async {
        print('♻️ Socket Reconnected');

        await Get.find<KdsController>().getWaiterPOSOrderList();
        await Get.find<TableController>().getTableListFromLocally();
        if (Get.find<AuthController>()
            .profileModel!
            .role!
            .contains('aggregator'))
          await Get.find<SwiggyController>().fetchOrders();
      });
    } catch (e) {
      // Log any errors that occur during socket initialization or connection
      print('Socket connection error: ${e.toString()}');
    }
  }

  bool isProcessingOrderQueue = false;
  // bool isSwiggyProcessingOrderQueue = false;
  List<OrderIdType> orderIdQueue = [];
  // List<OrderIdType> swiggyOrderIdQueue = [];
  List<AutoPrintType> orderQueue = [];
  bool isProcessingOrder = false;
  // Completer held for the lifetime of one print job so that listenBluetooth
  // callbacks (which run outside the call-stack of printMyGenieOrderQueue) can
  // still signal completion through the same completer.
  Completer<void>? _activePrintCompleter;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: Duration(seconds: 2)),
      showReleaseNotes: true,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        drawer: Drawer(backgroundColor: Color(0xFFF8F8F8), child: sideDrawer()),
        key: scaffoldKey,
        appBar: (isMobile(context)) || (isTablet(context))
            ? AppBar(
                backgroundColor: ColorTheme.white,
                centerTitle: false,
                leading: IconButton(
                  onPressed: () {
                    _singleSplitBleStatus?.cancel();
                    scaffoldKey.currentState?.openDrawer();
                  },
                  icon:
                      SizedBox(width: 20, child: Image.asset(Images.ham_menu)),
                ),
                title: SizedBox(width: 30, child: Image.asset(Images.app_logo)),
                titleSpacing: 0,
                scrolledUnderElevation: 0,
                actions: [
                  GetBuilder<KdsController>(
                    builder: (kdsController) {
                      return Row(
                        children: [
                          // Show Table View + Switch + Add Button ONLY if search is disabled
                          if (!kdsController.isSearchEnabled) ...[
                            if ((Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('table_view')))
                              Text(
                                'Table View',
                                style: poppinsMedium.copyWith(
                                  fontSize: 15,
                                  color: ColorTheme.green,
                                ),
                              ),
                            const SizedBox(width: 0),
                            if ((Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('table_view')))
                              GetBuilder<TableController>(
                                builder: (tableController) {
                                  return tableController.isLoading
                                      ? const SizedBox.shrink()
                                      : Transform.scale(
                                          scale: 0.6,
                                          child: Switch(
                                            value: kdsController.isTableView,
                                            onChanged: (value) {
                                              kdsController
                                                  .changeOrderTableView(value);
                                            },
                                            activeColor: ColorTheme.green,
                                            activeTrackColor:
                                                Colors.transparent,
                                            inactiveTrackColor:
                                                Colors.transparent,
                                            trackOutlineWidth:
                                                const WidgetStatePropertyAll(3),
                                            thumbColor: kdsController
                                                    .isTableView
                                                ? WidgetStatePropertyAll(
                                                    ColorTheme.green)
                                                : const WidgetStatePropertyAll(
                                                    Color(0xFFCACACA)),
                                            inactiveThumbColor:
                                                const Color(0xFFCACACA),
                                            trackOutlineColor: kdsController
                                                    .isTableView
                                                ? WidgetStatePropertyAll(
                                                    ColorTheme.green)
                                                : const WidgetStatePropertyAll(
                                                    Color(0xFFCACACA)),
                                          ),
                                        );
                                },
                              ),
                            const SizedBox(width: 0),
                          ],

                          // Search Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: kdsController.isSearchEnabled ? 250 : 35,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: ColorTheme.borderGrey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (!kdsController.isSearchEnabled) {
                                      kdsController.isSearchEnabled = true;
                                      kdsController.update();
                                    }
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 20,
                                      color: ColorTheme.appColor,
                                    ),
                                  ),
                                ),

                                // Show TextField & Close Button only if search is enabled
                                if (kdsController.isSearchEnabled) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: TextField(
                                      controller: searchController,
                                      autofocus: true,
                                      textInputAction: TextInputAction.search,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText:
                                            'Search by Table / Name / Phone',
                                        hintStyle: poppinsRegular.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        kdsController.update();
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      searchController.clear();
                                      kdsController.isSearchEnabled = false;
                                      kdsController.update();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (kdsController.isSearchEnabled)
                            const SizedBox(width: 10),
                          if (!kdsController.isSearchEnabled)
                            InkWell(
                              onTap: () async {
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('aggregator'))
                                  await Get.find<SwiggyController>()
                                      .fetchOrders();
                                await Get.find<KdsController>()
                                    .getWaiterPOSOrderList();
                                await Get.find<TableController>()
                                    .getTableListFromLocally();
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('table_view'))
                                  await Get.find<TableController>()
                                      .getWaiterOrderListForTableView();
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .isShowPopularCategory ==
                                    'Yes')
                                  await Get.find<ProductController>()
                                      .getPopularFoodList();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(Icons.refresh,
                                    color: ColorTheme.appColor, size: 35),
                              ),
                            ),
                              PrintDebugOpenButton(),

                          // Show Add Button only if search is disabled
                          if (!kdsController.isSearchEnabled &&
                              Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('order_edit')) ...[
                            IconButton(
                              onPressed: () async {
                                checkRestaurantIsOpen();
                              },
                              icon: Icon(
                                Icons.add_circle_outlined,
                                color: ColorTheme.appColor,
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        
                        ],
                      );
                    },
                  ),
                ],
              )
            // TAB AND WINDOWS APPBAR
            : AppBar(
                toolbarHeight: screenHeight * 0.085,
                backgroundColor: Colors.white,
                scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: IconButton(
                    icon: Icon(Icons.menu, color: Colors.deepOrangeAccent),
                    onPressed: () async {
                      _singleSplitBleStatus?.cancel();
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                titleSpacing: 0,
                centerTitle: false,
                title: Row(
                  children: [
                    Image.asset(
                      Images.app_logo,
                      height: Get.width * 0.1,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child:
                          GetBuilder<KdsController>(builder: (kdsController) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .delivery!)
                              tabButton(Icons.delivery_dining, "Delivery", 2,
                                  kdsController),
                            SizedBox(width: 15),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .takeAway!)
                              tabButton(Icons.takeout_dining_outlined,
                                  "TakeAway", 1, kdsController),
                            SizedBox(width: 15),
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .isDineIn ==
                                'Yes')
                              tabButton(Icons.restaurant_menu, "Dine In", 0,
                                  kdsController),
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .showRoom ==
                                'Yes')
                              SizedBox(width: 15),
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .showRoom ==
                                'Yes')
                              tabButton(Icons.meeting_room_outlined, "Room", 4,
                                  kdsController),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
                elevation: 0,
                actions: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if ((Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('table_view')))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // const Icon(Icons.circle, color: Colors.green, size: 14),
                                  Text(
                                    'Table View',
                                    style: poppinsSemiBold.copyWith(
                                      fontSize: 14,
                                      color: Color(0xFF329937),
                                    ),
                                  ),
                                  // const SizedBox(width: 5),
                                  GetBuilder<TableController>(
                                      builder: (tableController) {
                                    return GetBuilder<KdsController>(
                                        builder: (kdsController) {
                                      return tableController.isLoading
                                          ? SizedBox.shrink()
                                          : Transform.scale(
                                              scale: 0.5,
                                              child: Switch(
                                                value:
                                                    kdsController.isTableView,
                                                onChanged: (value) {
                                                  kdsController
                                                      .changeOrderTableView(
                                                          value);
                                                  // setState(() {
                                                  //   status = value ? 1 : 0;
                                                  // });
                                                },
                                                activeColor: ColorTheme.green,
                                                activeTrackColor:
                                                    Colors.transparent,
                                                inactiveTrackColor:
                                                    Colors.transparent,
                                                trackOutlineWidth:
                                                    const WidgetStatePropertyAll(
                                                        3),
                                                thumbColor: kdsController
                                                        .isTableView
                                                    ? WidgetStatePropertyAll(
                                                        ColorTheme.green)
                                                    : const WidgetStatePropertyAll(
                                                        Color(0xFFCACACA)),
                                                inactiveThumbColor:
                                                    const Color(0xFFCACACA),
                                                trackOutlineColor: kdsController
                                                        .isTableView
                                                    ? WidgetStatePropertyAll(
                                                        ColorTheme.green)
                                                    : const WidgetStatePropertyAll(
                                                        Color(0xFFCACACA)),
                                              ));
                                    });
                                  }),
                                ],
                              ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('aggregator'))
                                  await Get.find<SwiggyController>()
                                      .fetchOrders();
                                await Get.find<KdsController>()
                                    .getWaiterPOSOrderList();
                                await Get.find<TableController>()
                                    .getTableListFromLocally();
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('table_view'))
                                  await Get.find<TableController>()
                                      .getWaiterOrderListForTableView();
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .isShowPopularCategory ==
                                    'Yes')
                                  await Get.find<ProductController>()
                                      .getPopularFoodList();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(Icons.refresh,
                                    color: ColorTheme.appColor, size: 35),
                              ),
                            ),
                            const SizedBox(width: 0),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.18,
                              height: 35,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Color(0xFFDEDEDE)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Color(0xFFFF7E27)),
                                  SizedBox(width: 8),
                                  // Expanded(
                                  //   child: Text('Search',
                                  //       style: poppinsSemiBold.copyWith(
                                  //           fontSize: 12, color: Color(0xFF828282))),
                                  // ),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(bottom: 23),
                                        border: InputBorder.none,
                                        hintText: 'Search',
                                        hintStyle: poppinsSemiBold.copyWith(
                                            fontSize: 12,
                                            color: Color(0xFF828282)),
                                      ),
                                      onChanged: (d) {
                                        Get.find<KdsController>().update();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            PrintDebugOpenButton(),
                            const SizedBox(width: 15),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('order_edit'))
                              InkWell(
                                onTap: () {
                                  checkRestaurantIsOpen();
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Color(0xFFFF7E27),
                                  radius: 16,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                        
                            const SizedBox(width: 15),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
        body: (isMobile(context)) || (isTablet(context))
            ? GetBuilder<KdsController>(builder: (kdsController) {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.symmetric(
                            horizontal: BorderSide(color: Color(0xFFDEDEDE)),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .delivery!)
                                tabButton(Icons.delivery_dining, "Delivery", 2,
                                    kdsController),
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .takeAway!)
                                tabButton(Icons.takeout_dining_outlined,
                                    "TakeAway", 1, kdsController),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .isDineIn ==
                                  'Yes')
                                tabButton(Icons.restaurant_menu, "Dine In", 0,
                                    kdsController),
                              if (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .showRoom ==
                                  'Yes')
                                tabButton(Icons.meeting_room_outlined, "Room",
                                    4, kdsController),
                            ]
                                .map((btn) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child: btn,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      // DefaultTabController(
                      //   length: 4,
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(vertical: 8),
                      //     decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         border: Border.symmetric(
                      //             horizontal:
                      //                 BorderSide(color: Color(0xFFDEDEDE)))),
                      //     child: TabBar(
                      //       controller: _tabController,
                      //       isScrollable: true,
                      //       physics: const BouncingScrollPhysics(),
                      //       indicator: BoxDecoration(
                      //         color: ColorTheme.green,
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       indicatorColor: Colors.transparent,
                      //       indicatorSize: TabBarIndicatorSize.tab,
                      //       labelColor: ColorTheme.white,
                      //       unselectedLabelColor: Color(0xFF828282),
                      //       tabAlignment: TabAlignment.start,
                      //       dividerColor: Colors.transparent,
                      //       padding: EdgeInsets.only(left: 10, right: 10),
                      //       labelPadding:
                      //           EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      //       overlayColor:
                      //           WidgetStateProperty.all(Colors.transparent),
                      //       tabs: [

                      //         Tab(
                      //           child: Row(
                      //             children: [
                      //               Icon(
                      //                 Icons.delivery_dining,

                      //               ),
                      //               const SizedBox(
                      //                 width: 3,
                      //               ),
                      //               Text(
                      //                 'Delivery',
                      //                 style: poppinsBold.copyWith(
                      //                   fontSize: 12,
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Tab(
                      //           child: Row(
                      //             children: [
                      //               const Icon(
                      //                 Icons.takeout_dining_outlined,
                      //               ),
                      //               const SizedBox(
                      //                 width: 3,
                      //               ),
                      //               Text(
                      //                 'TakeAway',
                      //                 style: poppinsBold.copyWith(
                      //                   fontSize: 12,
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Tab(
                      //           child: Row(
                      //             children: [
                      //               const Icon(
                      //                 Icons.restaurant_menu,
                      //               ),
                      //               const SizedBox(
                      //                 width: 3,
                      //               ),
                      //               Text(
                      //                 'Dine In',
                      //                 style: poppinsBold.copyWith(
                      //                   fontSize: 12,
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Tab(
                      //           child: Row(
                      //             children: [
                      //               const Icon(
                      //                 Icons.meeting_room_outlined,
                      //               ),
                      //               const SizedBox(
                      //                 width: 3,
                      //               ),
                      //               Text(
                      //                 'Room',
                      //                 style: poppinsBold.copyWith(
                      //                   fontSize: 12,
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child:
                            // TabBarView(controller: _tabController, children: [
                            // DeliveryDashboard(),
                            kdsController.selectedMainMenu == 0
                                ? WindowPosHome(
                                    searchController: searchController,
                                    singleSplitBleStatus: _singleSplitBleStatus,
                                    subscriptionBtStatus: _subscriptionBtStatus)
                                : OrderViewScreen(
                                    searchController: searchController,
                                    singleSplitBleStatus: _singleSplitBleStatus,
                                    subscriptionBtStatus:
                                        _subscriptionBtStatus),
                      ),
                    ],
                  ),
                );
              })
            : GetBuilder<KdsController>(builder: (kdsController) {
                return kdsController.selectedMainMenu == 0
                    ? WindowPosHome(
                        searchController: searchController,
                        singleSplitBleStatus: _singleSplitBleStatus,
                        subscriptionBtStatus: _subscriptionBtStatus)
                    : OrderViewScreen(
                        searchController: searchController,
                        singleSplitBleStatus: _singleSplitBleStatus,
                        subscriptionBtStatus: _subscriptionBtStatus);
                //  TabBarView(controller: _tabController, children: [
                //   // DeliveryDashboard(),
                //   OrderViewScreen(
                //       singleSplitBleStatus: _singleSplitBleStatus,
                //       subscriptionBtStatus: _subscriptionBtStatus),
                //   OrderViewScreen(
                //       singleSplitBleStatus: _singleSplitBleStatus,
                //       subscriptionBtStatus: _subscriptionBtStatus),
                //   OrderViewScreen(
                //       singleSplitBleStatus: _singleSplitBleStatus,
                //       subscriptionBtStatus: _subscriptionBtStatus),
                //   // DeliveryDashboard(),
                //   // Text('takeway'),
                //   WindowPosHome(
                //       singleSplitBleStatus: _singleSplitBleStatus,
                //       subscriptionBtStatus: _subscriptionBtStatus),
                //   // Text('rom'),
                //   OrderViewScreen(
                //       singleSplitBleStatus: _singleSplitBleStatus,
                //       subscriptionBtStatus: _subscriptionBtStatus),
                // ]);
              }),
      ),
    );
  }

  void processNextOrder() async {
    print("========== PROCESS NEXT ==========");
    print("Queue Length : ${orderQueue.length}");
    print("isProcessingOrder : $isProcessingOrder");
    if (orderQueue.isEmpty || isProcessingOrder) return;
    isProcessingOrder = true;

    final _nextJob = orderQueue.first;
    final _flowNext = _nextJob.isAggregator!
        ? (_nextJob.isBillPrint ? PrintFlowTag.bill : PrintFlowTag.aggregator)
        : (_nextJob.isManualBillPrint ? PrintFlowTag.fixedManual : PrintFlowTag.normalPos);
    final _traceNext = PrintDebugController.generateTraceId(isAggregator: _nextJob.isAggregator!);

    // 1. THE WAITING ROOM (Check for Red Light)
    int timeoutCounter = 0;
    while (Get.find<CartController>().isPrinterBusy && timeoutCounter < 20) {
      PrintDebugLogger.lockWait(
        traceId: _traceNext,
        flow: _flowNext,
        waitCycle: timeoutCounter + 1,
        details: {'queue': 'orderQueue', 'queueLen': orderQueue.length},
      );
      await Future.delayed(const Duration(seconds: 2));
      timeoutCounter++; // Prevents infinite loops if the printer crashes
    }

    // Safety reset just in case the bill print crashed
    if (timeoutCounter >= 20) {
      PrintDebugLogger.lockTimeout(
        traceId: _traceNext,
        flow: _flowNext,
        details: {'queue': 'orderQueue', 'waitCycles': timeoutCounter},
      );
    }
    Get.find<CartController>().isPrinterBusy = false;

    // 2. CLAIM THE PRINTER FOR THE KOT
    Get.find<CartController>().isPrinterBusy = true; // Turn Light RED

    PrintDebugLogger.lockClaim(
      traceId: _traceNext,
      flow: _flowNext,
      details: {'queue': 'orderQueue', 'orderQueueLen': orderQueue.length},
    );

    // GAP 3: Guard removeAt — if a concurrent call already emptied the queue,
    // release the lock and exit cleanly instead of crashing with RangeError.
    if (orderQueue.isEmpty) {
      Get.find<CartController>().isPrinterBusy = false;
      isProcessingOrder = false;
      return;
    }
    var currentOrder = orderQueue.removeAt(0);

    // 3. AWAIT THE PRINT JOBS — wrapped in try-finally so the lock is ALWAYS
    //    released even when an unexpected exception escapes the print functions.
    try {
      if (currentOrder.isAggregator!) {
        if (currentOrder.isBillPrint && currentOrder.aggregatorOrder != null) {
          await printSwiggyBill(currentOrder.aggregatorOrder!);
        } else if (currentOrder.aggregatorOrder != null) {
          await printAggregatorKotQueue(currentOrder.aggregatorOrder!);
        }
      } else {
        if (currentOrder.isManualBillPrint) {
          await printManuallyBillFromFixed(currentOrder.mygenieOrderFromFixed!);
        } else {
          await printMyGenieOrderQueue(currentOrder.mygenieOrder!);
        }
      }
    } catch (e, s) {
      // GAP 7: log every uncaught print exception so failures are never silent.
      PrintDebugLogger.error(
        traceId: _traceNext,
        orderId: null,
        flow: _flowNext,
        message: 'Uncaught exception in processNextOrder print job: $e',
        details: {'stackTrace': s.toString()},
      );
    } finally {
      // Safety net — ensures lock is always released even on crash.
      Get.find<CartController>().isPrinterBusy = false;
      isProcessingOrder = false;
      if (orderQueue.isNotEmpty) processNextOrder();
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcess(AutoPrintType order) {
    print("========== QUEUE ==========");
    print("Added Order");
    print("Queue Length : ${orderQueue.length}");
    print("isProcessingOrder : $isProcessingOrder");
    // Add the new order to the queue
    orderQueue.add(order);

    // Start processing the next order if not already processing
    if (!isProcessingOrder) {
      processNextOrder();
    }
  }

  printMyGenieOrderQueue(OrderList currentOrder) async {
    final _tracePosKot = PrintDebugController.generateTraceId();
    // GAP 1+8: Create a Completer that the recursive dataCheck chain will
    // complete only when the very last station finishes printing.
    // This makes the await below truly wait for all physical printing to finish.
    final _printCompleter = Completer<void>();
    _activePrintCompleter = _printCompleter;

    try {
      PrintDebugLogger.stateReset(
        traceId: _tracePosKot,
        flow: PrintFlowTag.normalPos,
        note: 'printMyGenieOrderQueue – clearing shared state vars',
        details: {
          'orderId': currentOrder.id,
          'prevPrintIndex': currentPrintIndex,
          'prevCartListLen': cartProductList.length,
        },
      );
      currentPrintIndex = 0;
      cartProductList = [];
      swiggyCartProductList = [];
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
          if ((printer.areaName!.toUpperCase() == 'MASTER_KOT' ||
                  e.station == printer.areaName) &&
              e.foodStatus != 3) {
            tempCartList.add(e);
          } else if (currentOrder.fOrderStatus == 3 &&
              (printer.areaName!.toUpperCase() == 'MASTER_KOT' ||
                  e.station == printer.areaName)) {
            tempCartList.add(e);
          } else if ((printer.areaName!.toUpperCase() == 'MASTER_KOT' ||
                  e.station == printer.areaName) &&
              e.cancelBy != '' &&
              (e.cancelBy ==
                      Get.find<AuthController>()
                          .profileModel!
                          .empId
                          .toString() ||
                  ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .printingOption ==
                          'Fixed' &&
                      Get.find<AuthController>().profileModel?.defaultUser ==
                          'Yes'))) &&
              e.cancelAt != null &&
              e.cancelAt == currentOrder.updatedAt) {
            tempCartList.add(e);
          }
        }
        cartProductList.add(tempCartList);
        failedCartProductList.add([]);
      }

      final _printerCount = Get.find<AuthController>().profileModel!.restaurantPrinterNew!.length;
      final _nonEmptyStations = cartProductList.where((l) => l.isNotEmpty).length;
      PrintDebugLogger.stationSplit(
        traceId: _tracePosKot,
        orderId: currentOrder.id?.toString(),
        flow: PrintFlowTag.normalPos,
        printerCount: _printerCount,
        totalItems: cartProductList.fold(0, (s, l) => s + l.length),
        details: {
          'stations': _printerCount,
          'nonEmptyStations': _nonEmptyStations,
          'orderId': currentOrder.id,
        },
      );

      if (Platform.isAndroid) {
        await _subscriptionBtStatus?.cancel();
        await _singleSplitBleStatus?.cancel();

        await listenBlutooth(order: currentOrder);
      }
      PrintDebugLogger.info(
        traceId: _tracePosKot,
        orderId: currentOrder.id?.toString(),
        event: PrintEvent.printStart,
        flow: PrintFlowTag.normalPos,
        message: 'dataCheck() called with Completer – awaiting all stations',
      );
      // GAP 1+8: Pass the completer into dataCheck. The recursive chain carries
      // it through every station and every platform path. When the last station
      // is done (or an error occurs) the completer fires and the await below
      // unblocks — so the finally block runs at exactly the right moment.
      dataCheck(currentOrder, completer: _printCompleter);
      await _printCompleter.future;

    } finally {
      _activePrintCompleter = null;
      // Lock is released AFTER all stations have physically printed.
      PrintDebugLogger.lockRelease(
        traceId: _tracePosKot,
        orderId: currentOrder.id?.toString(),
        flow: PrintFlowTag.normalPos,
        source: 'printMyGenieOrderQueue finally',
        note: 'Completer-based: fires only after last station prints',
        details: {'orderQueueLen': orderQueue.length},
      );
      Get.find<CartController>().isPrinterBusy = false;
      // GAP 2: isProcessingOrder was missing here — added.
      isProcessingOrder = false;
      // Chaining is handled by processNextOrder's own finally — calling it here
      // causes a double-trigger that overrides isPrinterBusy/isProcessingOrder.
      // if (orderQueue.isNotEmpty) processNextOrder();
    }
  }

  printAggregatorKotQueue(Order currentOrder) async {
    print("========== PRINT AGG KOT ==========");
    print("Order : ${currentOrder.orderDetailsOrder.id}");
    final _traceAggKot = PrintDebugController.generateTraceId(isAggregator: true);
    // GAP 1+8: Completer for the aggregator KOT station chain.
    final _aggCompleter = Completer<void>();
    try {
      PrintDebugLogger.stateReset(
        traceId: _traceAggKot,
        flow: PrintFlowTag.aggregator,
        note: 'printAggregatorKotQueue – clearing shared state vars',
        details: {
          'orderId': currentOrder.orderDetailsOrder.id,
          'prevPrintIndex': currentPrintIndex,
          'prevSwiggyCartListLen': swiggyCartProductList.length,
        },
      );
      currentPrintIndex = 0;
      swiggyCartProductList = [];
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
        List<OrderFoodDetails> tempCartList = [];
        var foodList = currentOrder.orderDetailsFood;
        for (var e in foodList) {
          if (e.station == printer.areaName) {
            tempCartList.add(e);
          }
        }
        swiggyCartProductList.add(tempCartList);
        failedCartProductList.add([]);
      }

      final _aggPrinterCount = Get.find<AuthController>().profileModel!.restaurantPrinterNew!.length;
      final _aggNonEmpty = swiggyCartProductList.where((l) => l.isNotEmpty).length;
      PrintDebugLogger.stationSplit(
        traceId: _traceAggKot,
        orderId: currentOrder.orderDetailsOrder.id.toString(),
        flow: PrintFlowTag.aggregator,
        printerCount: _aggPrinterCount,
        totalItems: swiggyCartProductList.fold(0, (s, l) => s + l.length),
        details: {
          'stations': _aggPrinterCount,
          'nonEmptyStations': _aggNonEmpty,
          'aggregatorOrderId': currentOrder.orderDetailsOrder.aggregatorOrderId,
        },
      );
      PrintDebugLogger.info(
        traceId: _traceAggKot,
        orderId: currentOrder.orderDetailsOrder.id.toString(),
        event: PrintEvent.printStart,
        flow: PrintFlowTag.aggregator,
        message: 'aggregatorKotCheck() called with Completer – awaiting all stations',
      );
      aggregatorKotCheck(currentOrder, completer: _aggCompleter);
      await _aggCompleter.future;

    } finally {
      PrintDebugLogger.lockRelease(
        traceId: _traceAggKot,
        orderId: currentOrder.orderDetailsOrder.id.toString(),
        flow: PrintFlowTag.aggregator,
        source: 'printAggregatorKotQueue finally',
        note: 'Completer-based: fires only after last aggregator station prints',
        details: {'orderQueueLen': orderQueue.length},
      );
      Get.find<CartController>().isPrinterBusy = false;
      isProcessingOrder = false;
      // Chaining is handled by processNextOrder's own finally — calling it here
      // causes a double-trigger that overrides isPrinterBusy/isProcessingOrder.
      // if (orderQueue.isNotEmpty) processNextOrder();
    }
  }

  printSwiggyBill(Order order) async {
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');
    try {
      if (GetPlatform.isWindows) {
        final printers = await Printing.listPrinters();
        for (var element in printers) {
          if (element.isAvailable &&
              (element.name.toLowerCase() ==
                  Get.find<AuthController>()
                      .profileModel!
                      .wifiBillPrinterName!
                      .toLowerCase())) {
            for (int i = 0; i < numberOfPrint; i++) {
              await Printing.directPrintPdf(
                printer: element,
                onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                  printType: 'swiggy_bill',
                  paperRoll: Get.find<AuthController>()
                              .profileModel!
                              .billPrinterPaperRoll ==
                          58
                      ? 58
                      : 80,
                  brandName: order.brandName ?? '',
                  orderId: order.orderDetailsOrder.aggregatorOrderId,
                  date:
                      '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
                  waiterName: '',
                  tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
                      ? 'Zomato'
                      : 'Swiggy',
                  custName: order.customerDetails.name ?? '',
                  custPhone: order.customerDetails.phone ?? '',
                  swiggyOrderList: order.orderDetailsFood,
                  charge: order.orderDetailsOrder.charges ?? 0.0,
                  orderNote: order.orderDetailsOrder.orderNote ?? '',
                  orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
                  discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
                  serviceChargeAmount: 0,
                  deliveryCharge: 0,
                  gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
                  vatAmount: 0,
                  grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
                  deliveryCustName: order.customerDetails.name ?? '',
                  deliveryCustPhone: order.customerDetails.phone ?? '',
                  deliveryAddressType: '',
                  // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,
                  deliveryCustAddress:
                      '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
                  deliveryCustPincode: order.customerDetails.address.pin ?? '',
                  tips: order.orderDetailsOrder.tipAmount ?? 0.0,
                  orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
                      ? 'Zomato'
                      : 'Swiggy',
                ),
              );
              await Future.delayed(Duration(seconds: 2));
            }
            break;
          }
        }
      } else {
        showToast('Please wait..');
        Get.find<LoadingController>().startLoading(true);
        if (Platform.isIOS) {
          await iosPrintEscPos(
              await PrintByteConvert().byteConvert(
                printType: 'swiggy_bill',
                // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,

                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
                orderId: order.orderDetailsOrder.aggregatorOrderId,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
                waiterName: '',
                tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
                    ? 'Zomato'
                    : 'Swiggy',
                custName: order.customerDetails.name ?? '',
                custPhone: order.customerDetails.phone ?? '',
                swiggyOrderList: order.orderDetailsFood,
                charge: order.orderDetailsOrder.charges ?? 0.0,
                orderNote: order.orderDetailsOrder.orderNote ?? '',
                orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
                discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
                serviceChargeAmount: 0,
                deliveryCharge: 0,
                gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
                vatAmount: 0,
                grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
                deliveryCustName: order.customerDetails.name ?? '',
                deliveryCustPhone: order.customerDetails.phone ?? '',
                deliveryAddressType: '',
                deliveryCustAddress:
                    '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
                deliveryCustPincode: order.customerDetails.address.pin ?? '',
                tips: order.orderDetailsOrder.tipAmount ?? 0.0,
                orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
                    ? 'Zomato'
                    : 'Swiggy',
              ),
              null);
        } else {
          await swiggyBillPrintAndroid(await PrintByteConvert().byteConvert(
            printType: 'swiggy_bill',
            // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,

            paperRoll:
                Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
            orderId: order.orderDetailsOrder.aggregatorOrderId,
            date:
                '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
            waiterName: '',
            tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
                ? 'Zomato'
                : 'Swiggy',
            custName: order.customerDetails.name ?? '',
            custPhone: order.customerDetails.phone ?? '',
            swiggyOrderList: order.orderDetailsFood,
            charge: order.orderDetailsOrder.charges ?? 0.0,
            orderNote: order.orderDetailsOrder.orderNote ?? '',
            orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
            discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
            serviceChargeAmount: 0,
            deliveryCharge: 0,
            gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
            vatAmount: 0,
            grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
            deliveryCustName: order.customerDetails.name ?? '',
            deliveryCustPhone: order.customerDetails.phone ?? '',
            deliveryAddressType: '',
            deliveryCustAddress:
                '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
            deliveryCustPincode: order.customerDetails.address.pin ?? '',
            tips: order.orderDetailsOrder.tipAmount ?? 0.0,
            orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
                ? 'Zomato'
                : 'Swiggy',
          ));
        }
      }

      //   RestaurantPrinterNew printer =
      //       Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
      //   skipFailedList.add(false);
      //   List<OrderDetails> tempCartList = [];
      //   var foodList = currentOrder.orderDetails;
      //   for (var e in foodList!) {
      //     if (e.station == printer.areaName && e.foodStatus != 3) {
      //       tempCartList.add(e);
      //     } else if (currentOrder.fOrderStatus == 3 &&
      //         e.station == printer.areaName) {
      //       tempCartList.add(e);
      //     } else if (e.station == printer.areaName &&
      //         e.cancelBy != '' &&
      //         e.cancelBy ==
      //             Get.find<AuthController>().profileModel!.empId.toString() &&
      //         e.cancelAt != null &&
      //         e.cancelAt == currentOrder.updatedAt) {
      //       tempCartList.add(e);
      //     }
      //   }
      //   cartProductList.add(tempCartList);
      //   failedCartProductList.add([]);

      // if (Platform.isAndroid) {
      //   await _subscriptionBtStatus?.cancel();
      //   await _singleSplitBleStatus?.cancel();

      //   await listenBlutooth(order: currentOrder);
      // }
      // dataCheck(currentOrder);
      // printDebug();
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      // await Future.delayed(Duration(seconds: 2)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      // 1. RELEASE THE PRINTER FOR THE NEXT JOB
      Get.find<CartController>().isPrinterBusy = false; // Turn Light GREEN
      isProcessingOrder = false;

      // If there are more orders in the queue, process the next one
      if (orderQueue.isNotEmpty) {
        processNextOrder(); // Continue with the next order
      }
    }
  }

  printManuallyBillFromFixed(Bill order) async {
    double serviceChargeTax = 0;
    double tipTax = 0;
    if (order.serviceChargeAmount != 0) {
      serviceChargeTax = ((((order.serviceChargeAmount ?? 0.0) *
              Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .serviceChargeTaxPercent!) /
          100));
    }
    if (order.tipAmount != 0) {
      tipTax = ((((order.tipAmount ?? 0.0) *
              Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .tipTaxPercent!) /
          100));
    }

    try {
      if (GetPlatform.isWindows) {
        int numberOfPrint = int.parse(Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .settings!
                .noOfBillPrint ??
            '1');
        final printers = await Printing.listPrinters();
        for (var element in printers) {
          if (element.isAvailable &&
              (element.name.toLowerCase() ==
                  Get.find<AuthController>()
                      .profileModel!
                      .wifiBillPrinterName!
                      .toLowerCase())) {
            for (int i = 0; i < numberOfPrint; i++) {
              // print('${order.paymentMethod}---- ${order.paymentStatus}');
              await Printing.directPrintPdf(
                printer: element,
                onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                  roomAdvancePay: order.roomAdvancePay ?? 0,
                  roomRemainingPay: order.roomRemainingPay ?? 0,
                  printType: 'bill',
                  couponCode: order.couponCode ?? '',
                  paperRoll: Get.find<AuthController>()
                              .profileModel!
                              .billPrinterPaperRoll ==
                          58
                      ? 58
                      : 80,
                  orderId: '${order.restaurantOrderId}',
                  date: order.orderDate ?? '',
                  waiterName: order.waiterName ?? '',
                  tablename: order.tableName ?? '',
                  custName: order.custName ?? '',
                  custPhone: order.custPhone ?? '',
                  billFoodList: order.billFoodList ?? [],
                  orderNote: order.orderNote ?? '',
                  orderSubTotal: order.orderItemtotal ?? 0,
                  subTotalWithoutTax: order.orderSubtotal ?? 0,
                  discount: order.discountAmount ?? 0,
                  serviceChargeAmount: order.serviceChargeAmount ?? 0,
                  deliveryCharge: order.deliveryCharge ?? 0,
                  // gstAmount:
                  //     ((order.gstTax ?? 0) + serviceChargeTax + tipTax),
                  gstAmount: ((order.gstTax ?? 0) + tipTax),
                  vatAmount: order.vatTax ?? 0,
                  loyaltyUsed: order.loyaltyDiscountAmount ?? 0,
                  walletUsed: order.walletUsedAmount ?? 0,
                  grandTotal: order.grantAmount ?? 0,
                  paymentAmount: order.paymentAmount,
                  deliveryCustName: order.deliveryCustName ?? '',
                  deliveryCustPhone: order.deliveryCustPhone ?? '',
                  deliveryAddressType: order.deliveryAddressType ?? '',
                  deliveryCustAddress: order.deliveryCustAddress ?? '',
                  deliveryCustPincode: order.deliveryCustPincode ?? '',
                  tips: order.tipAmount ?? 0,
                  orderType: order.orderType ?? '',
                  associatedOrders: order.associatedOrders ?? [],
                  rType: order.rType ?? '',
                  paymentType: order.paymentMethod ?? '',
                  paymentStatus: order.paymentStatus ?? '',
                ),
              );
              await Future.delayed(Duration(seconds: 2));
            }
            break;
          }
        }
      } else {
        showToast('Please wait..');
        Get.find<LoadingController>().startLoading(true);
        if (Platform.isIOS) {
          await iosPrintEscPos(
              await PrintByteConvert().byteConvert(
                  roomAdvancePay: order.roomAdvancePay ?? 0,
                  roomRemainingPay: order.roomRemainingPay ?? 0,
                  printType: 'bill',
                  couponCode: order.couponCode ?? '',
                  paperRoll: Get.find<AuthController>()
                              .profileModel!
                              .billPrinterPaperRoll ==
                          58
                      ? 58
                      : 80,
                  orderId: '${order.restaurantOrderId}',
                  date: order.orderDate ?? '',
                  waiterName: order.waiterName ?? '',
                  tablename: order.tableName ?? '',
                  custName: order.custName ?? '',
                  custPhone: order.custPhone ?? '',
                  billFoodList: order.billFoodList ?? [],
                  orderNote: order.orderNote ?? '',
                  orderSubTotal: order.orderItemtotal ?? 0,
                  subTotalWithoutTax: order.orderSubtotal ?? 0,
                  discount: order.discountAmount ?? 0,
                  serviceChargeAmount: order.serviceChargeAmount ?? 0,
                  deliveryCharge: order.deliveryCharge ?? 0,
                  // gstAmount: ((order.gstTax ?? 0) + serviceChargeTax + tipTax),
                  gstAmount: ((order.gstTax ?? 0) + tipTax),
                  vatAmount: order.vatTax ?? 0,
                  loyaltyUsed: order.loyaltyDiscountAmount ?? 0,
                  walletUsed: order.walletUsedAmount ?? 0,
                  grandTotal: order.grantAmount ?? 0,
                  deliveryCustName: order.deliveryCustName ?? '',
                  deliveryCustPhone: order.deliveryCustPhone ?? '',
                  deliveryAddressType: order.deliveryAddressType ?? '',
                  deliveryCustAddress: order.deliveryCustAddress ?? '',
                  deliveryCustPincode: order.deliveryCustPincode ?? '',
                  tips: order.tipAmount ?? 0,
                  orderType: order.orderType ?? ''),
              null);
        } else {
          await swiggyBillPrintAndroid(await PrintByteConvert().byteConvert(
              roomAdvancePay: order.roomAdvancePay ?? 0,
              roomRemainingPay: order.roomRemainingPay ?? 0,
              printType: 'bill',
              couponCode: order.couponCode ?? '',
              paperRoll: Get.find<AuthController>()
                          .profileModel!
                          .billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80,
              orderId: '${order.restaurantOrderId}',
              date: order.orderDate ?? '',
              waiterName: order.waiterName ?? '',
              tablename: order.tableName ?? '',
              custName: order.custName ?? '',
              custPhone: order.custPhone ?? '',
              billFoodList: order.billFoodList ?? [],
              orderNote: order.orderNote ?? '',
              orderSubTotal: order.orderItemtotal ?? 0,
              subTotalWithoutTax: order.orderSubtotal ?? 0,
              discount: order.discountAmount ?? 0,
              serviceChargeAmount: order.serviceChargeAmount ?? 0,
              deliveryCharge: order.deliveryCharge ?? 0,
              // gstAmount: ((order.gstTax ?? 0) + serviceChargeTax + tipTax),
              gstAmount: ((order.gstTax ?? 0) + tipTax),
              vatAmount: order.vatTax ?? 0,
              loyaltyUsed: order.loyaltyDiscountAmount ?? 0,
              walletUsed: order.walletUsedAmount ?? 0,
              grandTotal: order.grantAmount ?? 0,
              deliveryCustName: order.deliveryCustName ?? '',
              deliveryCustPhone: order.deliveryCustPhone ?? '',
              deliveryAddressType: order.deliveryAddressType ?? '',
              deliveryCustAddress: order.deliveryCustAddress ?? '',
              deliveryCustPincode: order.deliveryCustPincode ?? '',
              tips: order.tipAmount ?? 0,
              orderType: order.orderType ?? ''));
        }
      }

      //   RestaurantPrinterNew printer =
      //       Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
      //   skipFailedList.add(false);
      //   List<OrderDetails> tempCartList = [];
      //   var foodList = currentOrder.orderDetails;
      //   for (var e in foodList!) {
      //     if (e.station == printer.areaName && e.foodStatus != 3) {
      //       tempCartList.add(e);
      //     } else if (currentOrder.fOrderStatus == 3 &&
      //         e.station == printer.areaName) {
      //       tempCartList.add(e);
      //     } else if (e.station == printer.areaName &&
      //         e.cancelBy != '' &&
      //         e.cancelBy ==
      //             Get.find<AuthController>().profileModel!.empId.toString() &&
      //         e.cancelAt != null &&
      //         e.cancelAt == currentOrder.updatedAt) {
      //       tempCartList.add(e);
      //     }
      //   }
      //   cartProductList.add(tempCartList);
      //   failedCartProductList.add([]);

      // if (Platform.isAndroid) {
      //   await _subscriptionBtStatus?.cancel();
      //   await _singleSplitBleStatus?.cancel();

      //   await listenBlutooth(order: currentOrder);
      // }
      // dataCheck(currentOrder);
      // printDebug();
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      // await Future.delayed(Duration(seconds: 2)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      // 1. RELEASE THE PRINTER FOR THE NEXT JOB
      Get.find<CartController>().isPrinterBusy = false; // Turn Light GREEN
      isProcessingOrder = false;

      // If there are more orders in the queue, process the next one
      // if (orderQueue.isNotEmpty) {
      //   processNextOrder(); // Continue with the next order
      // }
    }
  }

  mygenieOrder(OrderIdType currentOrder) async {
    final _tracePosSocket = PrintDebugController.generateTraceId();
    PrintDebugLogger.apiStart(
      traceId: _tracePosSocket,
      orderId: '${currentOrder.orderId}',
      controller: 'KdsController',
      apiName: 'getOrderDetailFromSocket',
      flow: PrintFlowTag.normalPos,
      details: {
        'orderType': currentOrder.orderType,
        'foodStatus': currentOrder.orderOthervalue ?? '0',
      },
    );
    try {
      var isCallApi = await Get.find<KdsController>().getOrderDetailFromSocket(
          socket: homeSocket,
          foodStatus: currentOrder.orderType == 'update-food-status' ||
                  currentOrder.orderType == 'update-item-status' ||
                  currentOrder.orderType == 'delivery-assign-order'
              ? '${currentOrder.orderOthervalue}'
              : '0',
          type: currentOrder.orderType,
          orderId: '${currentOrder.orderId}',
          socketJson: currentOrder.newOrderJson,
          // socketJson: currentOrder.orderType == 'new-order'
          //     ? currentOrder.newOrderJson
          //     : null,
          callbackFunction: (OrderList? order) async {
            print("========== CALLBACK ==========");
            PrintDebugLogger.info(
              traceId: _tracePosSocket,
              orderId: '${currentOrder.orderId}',
              event: PrintEvent.decision,
              flow: PrintFlowTag.normalPos,
              message: 'KdsController callback: order=${order != null ? "received" : "null (no print)"}',
              details: {
                'orderId': order?.id,
                'isPrintKot': order?.isPrintKot,
              },
            );
            await Future.delayed(
                Duration(seconds: 2)); // Simulate async processing

            if (order != null) {
              PrintDebugLogger.queueIn(
                traceId: _tracePosSocket,
                orderId: order.id?.toString(),
                queueName: 'orderQueue',
                jobType: 'normalPos_KOT',
                queueLen: orderQueue.length + 1,
                flow: PrintFlowTag.normalPos,
                isAuto: true,
                isPrinterBusy: Get.find<CartController>().isPrinterBusy,
              );
              checkQueueProcess(AutoPrintType(
                  isBillPrint: false,
                  isAggregator: false,
                  mygenieOrder: order));
            }
          });
      print(Get.find<AuthController>()
          .profileModel
          ?.restaurants
          ?.first
          .printingOption);
      print(Get.find<AuthController>().profileModel?.defaultUser);
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
                  (e.cancelBy ==
                          Get.find<AuthController>()
                              .profileModel!
                              .empId
                              .toString() ||
                      (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .printingOption ==
                              'Fixed' &&
                          Get.find<AuthController>()
                                  .profileModel!
                                  .defaultUser ==
                              'Yes')) &&
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
                  (e.cancelBy ==
                          Get.find<AuthController>()
                              .profileModel!
                              .empId
                              .toString() ||
                      (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .printingOption ==
                              'Fixed' &&
                          Get.find<AuthController>()
                                  .profileModel!
                                  .defaultUser ==
                              'Yes')) &&
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
                tablePart: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .tablePart,
                parentOrderId: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .parentOrderId,
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
            checkQueueProcess(AutoPrintType(
                isBillPrint: false,
                isAggregator: false,
                mygenieOrder: tempOrder));
          } else if (tempCartList.isNotEmpty) {
            OrderList tempOrder = OrderList(
                updatedAt: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .updatedAt,
                tablePart: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .tablePart,
                parentOrderId: Get.find<KdsController>()
                    .getWaiterOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .parentOrderId,
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
            checkQueueProcess(AutoPrintType(
                isBillPrint: false,
                isAggregator: false,
                mygenieOrder: tempOrder));
          }
        }
      }

      await Future.delayed(Duration(seconds: 3)); // Simulate async processing
    } finally {
      // 1. RELEASE THE PRINTER FOR THE NEXT JOB
      PrintDebugLogger.lockRelease(
        traceId: _tracePosSocket,
        orderId: '${currentOrder.orderId}',
        flow: PrintFlowTag.normalPos,
        source: 'mygenieOrder finally',
        details: {'socketQueueLen': orderIdQueue.length},
      );
      Get.find<CartController>().isPrinterBusy = false; // Turn Light GREEN
      isProcessingOrderQueue = false;

      // If there are more orders in the queue, process the next one
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket(); // Continue with the next order
      }
    }
  }

  printFromFixedStation(OrderIdType currentOrder) async {
    try {
      if (currentOrder.isKOTFromFixedStation) {
        OrderList? isCallApi =
            await Get.find<KdsController>().getOrderDetailFromSocketForKot(
          orderId: '${currentOrder.orderId}',
        );
        if ((Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .printingOption ==
                    'Fixed' &&
                Get.find<AuthController>().profileModel?.defaultUser ==
                    'Yes') &&
            isCallApi != null &&
            currentOrder.orderOthervalue != null &&
            currentOrder.orderOthervalue != '') {
          List<String> printers = currentOrder.orderOthervalue!.split(',');
          List<OrderDetails> tempFoodList = [];
          OrderList tempOrder = isCallApi;
          for (var element in tempOrder.orderDetails!) {
            for (var splitStation in printers) {
              if ((splitStation.toUpperCase() ==
                      element.station!.toUpperCase()) ||
                  splitStation.toUpperCase() == 'MASTER_KOT') {
                tempFoodList.add(element);
              }
            }
          }
          tempOrder.orderDetails = tempFoodList;
          Future.delayed(Duration(seconds: 2));
          checkQueueProcess(AutoPrintType(
              isBillPrint: false,
              isAggregator: false,
              mygenieOrder: tempOrder));
        }
      } else if (currentOrder.isBillFromFixedStation) {
        Bill? isCallApi = await Get.find<KdsController>()
            .getOrderDetailFromSocketForBill(
                orderId: '${currentOrder.orderId}');
        if ((Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .printingOption ==
                    'Fixed' &&
                Get.find<AuthController>().profileModel?.defaultUser ==
                    'Yes') &&
            isCallApi != null) {
          Future.delayed(Duration(seconds: 2));
          checkQueueProcess(AutoPrintType(
              isBillPrint: false,
              isAggregator: false,
              isManualBillPrint: true,
              mygenieOrderFromFixed: isCallApi));
        }
      }

      await Future.delayed(Duration(seconds: 3)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      // 1. RELEASE THE PRINTER FOR THE NEXT JOB
      Get.find<CartController>().isPrinterBusy = false; // Turn Light GREEN
      isProcessingOrderQueue = false;

      // If there are more orders in the queue, process the next one
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket(); // Continue with the next order
      }
    }
  }

  void processNextOrderFromSocket() async {
    // If no orders in the queue or an order is currently being processed, return.
    if (orderIdQueue.isEmpty || isProcessingOrderQueue) return;
    isProcessingOrderQueue = true;

    final _nextOrder = orderIdQueue.first;
    final _flow = _nextOrder.isAggregator!
        ? PrintFlowTag.aggregator
        : (_nextOrder.isKOTFromFixedStation || _nextOrder.isBillFromFixedStation)
            ? PrintFlowTag.fixedManual
            : PrintFlowTag.normalPos;
    final _trace = PrintDebugController.generateTraceId(isAggregator: _nextOrder.isAggregator!);

    // ---> ADD THE WAITING ROOM HERE TOO <---
    int timeoutCounter = 0;
    while (Get.find<CartController>().isPrinterBusy && timeoutCounter < 20) {
      PrintDebugLogger.lockWait(
        traceId: _trace,
        orderId: '${_nextOrder.orderId}',
        flow: _flow,
        waitCycle: timeoutCounter + 1,
      );
      await Future.delayed(const Duration(seconds: 2));
      timeoutCounter++;
    }
    // Safety reset just in case
    if (timeoutCounter >= 20) {
      PrintDebugLogger.lockTimeout(
        traceId: _trace,
        orderId: '${_nextOrder.orderId}',
        flow: _flow,
        details: {'waitCycles': timeoutCounter},
      );
    }
    Get.find<CartController>().isPrinterBusy = false;
    // ----------------------------------------

    // CLAIM THE RED LIGHT
    Get.find<CartController>().isPrinterBusy = true;

    PrintDebugLogger.lockClaim(
      traceId: _trace,
      orderId: '${_nextOrder.orderId}',
      flow: _flow,
      details: {'socketQueueLen': orderIdQueue.length},
    );

    // Remove the next order from the queue
    var currentOrder = orderIdQueue.removeAt(0);

    if (currentOrder.isAggregator!) {
      processSwiggyNextOrderFromSocket(currentOrder);
    } else if (currentOrder.isKOTFromFixedStation ||
        currentOrder.isBillFromFixedStation) {
      printFromFixedStation(currentOrder);
    } else {
      mygenieOrder(currentOrder);
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcessFromSocket(
      {String? orderType,
      String? orderId,
      bool? isKOTFromFixedStation,
      bool? isBillFromFixedStation,
      bool? isAggregator,
      String? otherValue,
      dynamic newOrderJson}) {
    final _flow = (isAggregator ?? false)
        ? PrintFlowTag.aggregator
        : (isKOTFromFixedStation ?? false) || (isBillFromFixedStation ?? false)
            ? PrintFlowTag.fixedManual
            : PrintFlowTag.normalPos;

    final _trace = PrintDebugController.generateTraceId(isAggregator: isAggregator ?? false);

    PrintDebugLogger.socketRx(
      traceId: _trace,
      orderId: orderId,
      socketType: orderType ?? (isKOTFromFixedStation == true ? 'manually_print_kot' : isBillFromFixedStation == true ? 'manually_print_bill' : 'unknown'),
      flow: _flow,
      isAuto: true,
      details: {
        'otherValue': otherValue ?? '0',
        'isAggregator': isAggregator ?? false,
        'isKOTFromFixed': isKOTFromFixedStation ?? false,
        'isBillFromFixed': isBillFromFixedStation ?? false,
      },
    );

    PrintDebugLogger.queueIn(
      traceId: _trace,
      orderId: orderId,
      queueName: 'socketIdQueue',
      jobType: _flow.label,
      queueLen: orderIdQueue.length + 1,
      flow: _flow,
      isAuto: true,
      isPrinterBusy: Get.find<CartController>().isPrinterBusy,
      details: {'isProcessingOrderQueue': isProcessingOrderQueue},
    );

    orderIdQueue.add(OrderIdType(
        orderId: orderId,
        orderType: orderType,
        isAggregator: isAggregator ?? false,
        isKOTFromFixedStation: isKOTFromFixedStation ?? false,
        isBillFromFixedStation: isBillFromFixedStation ?? false,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  void processSwiggyNextOrderFromSocket(OrderIdType currentOrder) async {
    final _traceSwiggy = PrintDebugController.generateTraceId(isAggregator: true);

    PrintDebugLogger.apiStart(
      traceId: _traceSwiggy,
      orderId: '${currentOrder.orderId}',
      controller: 'SwiggyController',
      apiName: 'getOrderDetailFromSocket',
      flow: PrintFlowTag.aggregator,
      details: {
        'orderType': currentOrder.orderType,
        'foodStatus': currentOrder.orderType == 'aggrigator-order-update'
            ? currentOrder.orderOthervalue
            : '0',
      },
    );

    try {
      await Get.find<SwiggyController>().getOrderDetailFromSocket(
          foodStatus: currentOrder.orderType == 'aggrigator-order-update'
              ? currentOrder.orderOthervalue
              : '0',
          type: currentOrder.orderType,
          orderId: '${currentOrder.orderId}',
          socketJson: currentOrder.newOrderJson,
          callbackFunction: (String? type) async {
            PrintDebugLogger.info(
              traceId: _traceSwiggy,
              orderId: '${currentOrder.orderId}',
              event: PrintEvent.decision,
              flow: PrintFlowTag.aggregator,
              message: 'Aggregator callback received: type=$type → queuing job',
            );
            if (type != null) {
              await Future.delayed(Duration(seconds: 1));
              if (type == 'bill') {
                checkQueueProcess(AutoPrintType(
                    isBillPrint: true,
                    isAggregator: true,
                    aggregatorOrder: Get.find<SwiggyController>().order[
                        Get.find<SwiggyController>()
                            .updatedOrderIndex]));
              } else if (type == 'kot' || type == 'cancel_kot') {
                checkQueueProcess(AutoPrintType(
                    isBillPrint: false,
                    isAggregator: true,
                    aggregatorOrder: Get.find<SwiggyController>().order[
                        Get.find<SwiggyController>().updatedOrderIndex]));
              } else if (type == 'both') {
                checkQueueProcess(AutoPrintType(
                    isBillPrint: false,
                    isAggregator: true,
                    aggregatorOrder: Get.find<SwiggyController>().order[
                        Get.find<SwiggyController>().updatedOrderIndex]));
                await Future.delayed(Duration(seconds: 3));
                checkQueueProcess(AutoPrintType(
                    isBillPrint: true,
                    isAggregator: true,
                    aggregatorOrder: Get.find<SwiggyController>().order[
                        Get.find<SwiggyController>().updatedOrderIndex]));
              }
            } else {
              PrintDebugLogger.skip(
                traceId: _traceSwiggy,
                orderId: '${currentOrder.orderId}',
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                reason: 'callbackFunction type==null – no print queued',
              );
            }
          });
    } finally {
      // 1. RELEASE THE PRINTER FOR THE NEXT JOB
      PrintDebugLogger.lockRelease(
        traceId: _traceSwiggy,
        orderId: '${currentOrder.orderId}',
        flow: PrintFlowTag.aggregator,
        source: 'processSwiggyNextOrderFromSocket finally',
        details: {'socketQueueLen': orderIdQueue.length},
      );
      Get.find<CartController>().isPrinterBusy = false; // Turn Light GREEN
      isProcessingOrderQueue = false;

      // If there are more orders in the queue, process the next one
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket(); // Continue with the next order
      }
    }
  }

  checkRestaurantIsOpen() async {
    Get.find<CartController>().clearCartList();
    await Get.find<LocationController>().clearAddressList();
    List<Schedules> schedules =
        Get.find<AuthController>().profileModel!.restaurants!.first.schedules!;
    schedules.sort((a, b) => a.day!.compareTo(b.day!));
    DateTime currentDate = DateTime.now();
    String todayName = DateFormat('EEEE').format(currentDate);
    int? currentDay;
    if (todayName == 'Sunday') {
      currentDay = 0;
    } else if (todayName == 'Monday') {
      currentDay = 1;
    } else if (todayName == 'Tuesday') {
      currentDay = 2;
    } else if (todayName == 'Wednesday') {
      currentDay = 3;
    } else if (todayName == 'Thursday') {
      currentDay = 4;
    } else if (todayName == 'Friday') {
      currentDay = 5;
    } else if (todayName == 'Saturday') {
      currentDay = 6;
    }
    Schedules? todaySchedule;
    Schedules? previousDaySchedule;
    for (var i = 0; i < schedules.length; i++) {
      if (currentDay == schedules[i].day) {
        todaySchedule = schedules[i];
        break;
      }
    }

    for (var i = 0; i < schedules.length; i++) {
      if (currentDay! - 1 == schedules[i].day) {
        previousDaySchedule = schedules[i];
        break;
      }
    }
    if (todaySchedule == null && previousDaySchedule == null) {
      showErrorToast('Restaurant is closed');
    } else if (DateConverter.isAvailable(
        todaySchedule!.openingTime!, todaySchedule.closingTime!)) {
      // showCustomSnackBar('Restaurant is open', isError: false);
      // _singleSplitBleStatus?.cancel();
      if (MediaQuery.of(context).size.shortestSide > 570 ||
          GetPlatform.isWindows) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TabletPosScreen(editOrder: null)));
      } else {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WaiterPosScreen(editOrder: null)));
      }
      // var data = await Get.toNamed(RouteHelper.getWaiterPosRoute(null));
    } else {
      var subtractDate = currentDate.subtract(Duration(days: 1));
      int closeHour =
          int.parse(previousDaySchedule!.closingTime!.split(':').first);
      int closeMinute =
          int.parse(previousDaySchedule.closingTime!.split(':')[1]);
      int openHour =
          int.parse(previousDaySchedule.openingTime!.split(':').first);
      int openMinute =
          int.parse(previousDaySchedule.openingTime!.split(':')[1]);

      if (closeHour <= 9) {
        bool isbefore = currentDate.isBefore(DateTime(currentDate.year,
            currentDate.month, currentDate.day, closeHour, closeMinute));
        bool isAfter = currentDate.isAfter(DateTime(subtractDate.year,
            subtractDate.month, subtractDate.day, openHour, openMinute));
        // print(isAfter);
        if (isbefore && isAfter) {
          // showCustomSnackBar('Restaurant is open previous day');
          if (MediaQuery.of(context).size.shortestSide > 570 ||
              GetPlatform.isWindows) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TabletPosScreen(editOrder: null)));
          } else {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WaiterPosScreen(editOrder: null)));
          }
        } else {
          showErrorToast('Restaurant is closed');
        }
      } else {
        showErrorToast('Restaurant is closed');
      }
    }
  }

  Widget sideDrawer() {
    return SafeArea(
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
          InkWell(
            onTap: () {
              // Clipboard.setData(ClipboardData(
              //     text:
              //         "${Get.find<AuthController>().profileModel?.firebaseToken}"));
              // showErrorToast('Address coppied', isError: false);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 7),
                child: Text(
                  '${Get.find<AuthController>().profileModel?.restaurants?.first.name ?? ''}(${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? ''}) - ${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.hintText),
                ),
              ),
            ),
          ),
          if (Get.find<AuthController>().profileModel!.role!.contains('bill') &&
              Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .showRoom ==
                  'Yes')
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                      await _singleSplitBleStatus?.cancel();
                      FocusManager.instance.primaryFocus?.unfocus();

                      var data = await Navigator.push(context,
                          MaterialPageRoute(builder: (builder) => CheckIn()));
                      if (data != null && data) {
                        Get.find<KdsController>().setSubMenuIndex(2);
                      }
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Check In',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
          // if (Get.find<AuthController>()
          //         .profileModel!
          //         .restaurants!
          //         .first
          //         .settelmentReport ==
          //     'Yes')
          if(Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('sattle_report'))
            Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                    iconColor: ColorTheme.hintText,
                    initiallyExpanded: true,
                    expandedAlignment: Alignment.centerLeft,
                    title: Text(
                      'Day Closing',
                      style: poppinsMedium.copyWith(
                          fontSize: 14, color: ColorTheme.hintText),
                    ),
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          scaffoldKey.currentState!.closeDrawer();
                          // _subscriptionBtStatus!.cancel();
                          FocusManager.instance.primaryFocus?.unfocus();

                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SettlementScreen()));
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 0),
                            child: Text(
                              'Settlement',
                              style: poppinsMedium.copyWith(
                                  fontSize: 13, color: ColorTheme.hintText),
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
                    ])),
          if (Get.find<AuthController>().profileModel!.role!.contains('report'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                dense: false,
                minTileHeight: 10,
                childrenPadding: EdgeInsets.only(left: 5),
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Report',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  // Sales Report
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      dense: false,
                      minTileHeight: 10,
                      childrenPadding: EdgeInsets.only(left: 8),
                      iconColor: ColorTheme.hintText,
                      initiallyExpanded: false,
                      expandedAlignment: Alignment.centerLeft,
                      title: Text(
                        'Sales Report',
                        style: poppinsMedium.copyWith(
                            fontSize: 14, color: ColorTheme.hintText),
                      ),
                      children: <Widget>[
                        // if (Get.find<AuthController>()
                        //         .profileModel!
                        //         .restaurants!
                        //         .first
                        //         .settelmentReport ==
                        //     'Yes')
                        if(Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('sattle_report'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          SettlementDayWiseReport()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Closing Report', //Settlement Report
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('sattle_report'))
                          10.height,
                        InkWell(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            scaffoldKey.currentState?.closeDrawer();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => PrintReport()));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 0),
                              child: Text(
                                'Daily report ( summary )',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.hintText),
                              ),
                            ),
                          ),
                        ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              final date = DateTime.now(); // Current Date
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          DailySalesDetailsReport(
                                            date: DateFormat('d-M-yyyy')
                                                .format(date),
                                          )));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Daily Report ( order wise )',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              final date = DateTime.now(); // Current Date
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          CancelOrderWiseReportScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Cancel Report ( order wise )',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          ReportSummeryPage()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Report Summary',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          ItemWiseVariationReport()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Variation Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('report_summery'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          ItemWiseAddonReport()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Addon Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('waiter_revenue_report'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('waiter_revenue_report'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();
                              // if (Get.find<AuthController>()
                              //     .profileModel!
                              //     .role!
                              //     .contains('waiter_revenue_report'))
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          DailyWaiterSalesDetailsReport()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Report Summary(W)',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 15, left: 15),
                        //   child: DottedLine(
                        //     direction: Axis.horizontal,
                        //     alignment: WrapAlignment.center,
                        //     lineThickness: 1.0,
                        //     dashLength: 2.5,
                        //     dashColor: ColorTheme.hintText,
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // PLN Report
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      dense: false,
                      minTileHeight: 10,
                      childrenPadding: EdgeInsets.only(left: 8),
                      iconColor: ColorTheme.hintText,
                      initiallyExpanded: false,
                      expandedAlignment: Alignment.centerLeft,
                      title: Text(
                        'PLN Report',
                        style: poppinsMedium.copyWith(
                            fontSize: 14, color: ColorTheme.hintText),
                      ),
                      children: <Widget>[
                        // if (Get.find<AuthController>()
                        //     .profileModel!
                        //     .role!
                        //     .contains('expence'))
                        //   10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('expence'))
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          ExpenseReportScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Expense Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('inventory'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('inventory'))
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState!.closeDrawer();

                              FocusManager.instance.primaryFocus?.unfocus();

                              await Get.to(() => PurchaseReportScreen());
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Purchase Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        10.height,
                        InkWell(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            scaffoldKey.currentState?.closeDrawer();

                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) =>
                                        DailyConsumptionReportScreen()));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 0),
                              child: Text(
                                'Consumption Report',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.hintText),
                              ),
                            ),
                          ),
                        ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('wastage_report'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('wastage_report'))
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState!.closeDrawer();

                              FocusManager.instance.primaryFocus?.unfocus();

                              await Get.to(() => WastageReportScreen());
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Wastage Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),

                        10.height,
                        InkWell(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            scaffoldKey.currentState?.closeDrawer();

                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => TabReportScreen()));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 0),
                              child: Text(
                                'Credit Report',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.hintText),
                              ),
                            ),
                          ),
                        ),
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('pl_report'))
                          10.height,
                        if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('pl_report'))
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState!.closeDrawer();

                              FocusManager.instance.primaryFocus?.unfocus();

                              await Get.to(() => ProfitLossReport());
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Profit Loss Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        10.height,
                        InkWell(
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            scaffoldKey.currentState?.closeDrawer();

                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => CouponReport()));
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 0),
                              child: Text(
                                'Coupon Usage Report',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.hintText),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Audit Report
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                        dense: false,
                        minTileHeight: 10,
                        childrenPadding: EdgeInsets.only(left: 8),
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: false,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'Audit Report',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          // 10.height,
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          OrderAuditReportScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Order Audit Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          10.height,
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          OrderWiseLogsScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Order Logs',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),

                          10.height,
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          PrepServeTimeReportScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Prepration & Serve Time',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),

                  // 10.height,
                  // InkWell(
                  //   onTap: () async {
                  //     FocusManager.instance.primaryFocus?.unfocus();
                  //     scaffoldKey.currentState?.closeDrawer();

                  //     await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (builder) => SettlementDayWiseReport()));
                  //   },
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(left: 15, top: 0),
                  //       child: Text(
                  //         'Settlement Report',
                  //         style: poppinsMedium.copyWith(
                  //             fontSize: 13, color: ColorTheme.hintText),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // if (Get.find<AuthController>()
                  //     .profileModel!
                  //     .role!
                  //     .contains('report_summery'))
                  //   InkWell(
                  //     onTap: () async {
                  //       FocusManager.instance.primaryFocus?.unfocus();
                  //       scaffoldKey.currentState?.closeDrawer();

                  //       await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (builder) =>
                  //                   ReportSummeryPage()));
                  //     },
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Padding(
                  //         padding:
                  //             const EdgeInsets.only(left: 15, top: 15),
                  //         child: Text(
                  //           'Report Summary',
                  //           style: poppinsMedium.copyWith(
                  //               fontSize: 13, color: ColorTheme.hintText),
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  //Profit and loss reprot coming soon
                  // Wastage reprot coming soon

                  // if (Get.find<AuthController>()
                  //     .profileModel!
                  //     .role!
                  //     .contains('sattle_report'))
                  //   InkWell(
                  //     onTap: () async {
                  //       scaffoldKey.currentState?.closeDrawer();
                  //       _subscriptionBtStatus?.cancel();
                  //       FocusManager.instance.primaryFocus?.unfocus();

                  //       await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (builder) => SettlementReport()));
                  //     },
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(left: 15, top: 0),
                  //         child: Text(
                  //           'Settlement Report',
                  //           style: poppinsMedium.copyWith(
                  //               fontSize: 13, color: ColorTheme.hintText),
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // if (Get.find<AuthController>()
                  //     .profileModel!
                  //     .role!
                  //     .contains('revenue_report'))
                  //   10.height,

                  // if (Get.find<AuthController>()
                  //     .profileModel!
                  //     .role!
                  //     .contains('revenue_report'))
                  //   InkWell(
                  //     onTap: () async {
                  //       scaffoldKey.currentState?.closeDrawer();
                  //       _subscriptionBtStatus?.cancel();
                  //       FocusManager.instance.primaryFocus?.unfocus();

                  //       await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (builder) => RevenueReport()));
                  //     },
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(left: 15),
                  //         child: Text(
                  //           'Revenue Report',
                  //           style: poppinsMedium.copyWith(
                  //               fontSize: 13, color: ColorTheme.hintText),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // 10.height,

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
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                      padding: const EdgeInsets.only(left: 15, top: 0),
                      child: Text(
                        'Completed Paid Orders',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () async {
                      scaffoldKey.currentState?.closeDrawer();
                      _subscriptionBtStatus?.cancel();
                      FocusManager.instance.primaryFocus?.unfocus();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => PayLaterOrderScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Pay Later Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () async {
                      scaffoldKey.currentState?.closeDrawer();
                      _subscriptionBtStatus?.cancel();
                      FocusManager.instance.primaryFocus?.unfocus();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CancelledOrders()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Cancelled Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                ),

                10.height,

                InkWell(
                  onTap: () async {
                    scaffoldKey.currentState?.closeDrawer();
                    _subscriptionBtStatus?.cancel();
                    FocusManager.instance.primaryFocus?.unfocus();

                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => OnlineUnpaidOrder()));
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 0),
                      child: Text(
                        'Online Unpaid Orders',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                ),

                // InkWell(
                //   onTap: () async {
                //     scaffoldKey.currentState?.closeDrawer();
                //     _subscriptionBtStatus??.cancel();
                //     FocusManager.instance.primaryFocus?.unfocus();

                //     await Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (builder) => ChangePaymentViewOrders()));
                //   },
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: Padding(
                //         padding: const EdgeInsets.only(left: 15, top: 15),
                //       child: Text(
                //         'Change Payment Method',
                //         style: poppinsMedium.copyWith(
                //             fontSize: 13, color: ColorTheme.hintText),
                //       ),
                //     ),
                //   ),
                // ),
                if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .showRoom ==
                    'Yes')
                  10.height,

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
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Room Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                // if (Get.find<AuthController>()
                //     .profileModel!
                //     .role!
                //     .contains('aggregator'))
                //   InkWell(
                //     onTap: () async {
                //       scaffoldKey.currentState?.closeDrawer();
                //       _subscriptionBtStatus?.cancel();
                //       FocusManager.instance.primaryFocus?.unfocus();

                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (builder) => SwiggyZomatoUI()));
                //       // await Navigator.push(
                //       //     context,
                //       //     MaterialPageRoute(
                //       //         builder: (builder) => SwiggyOrders()));
                //     },
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 15, top: 15),
                //         child: Text(
                //           'Aggregator Orders',
                //           style: poppinsMedium.copyWith(
                //               fontSize: 13, color: ColorTheme.hintText),
                //         ),
                //       ),
                //     ),
                //   ),
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('aggregator'))
                  10.height,

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
                              builder: (builder) => DateWiseSwiggyOrders()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Completed Aggregator Orders',
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
                        .payTab ==
                    'Yes')
                  10.height,
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

                      await Navigator.push(context,
                          MaterialPageRoute(builder: (builder) => TabOrders()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Credit Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
                  10.height,
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
                      Get.toNamed(RouteHelper.getTapManagementRoute());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Credit Management',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
          //customer management
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: ColorTheme.hintText,
              initiallyExpanded: true,
              expandedAlignment: Alignment.centerLeft,
              title: Text(
                'Customer Data',
                style: poppinsMedium.copyWith(
                    fontSize: 14, color: ColorTheme.hintText),
              ),
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    scaffoldKey.currentState?.closeDrawer();

                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => CustomerReportScreen()));
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 0),
                      child: Text(
                        'Customer Report',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                ),
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('customer_management'))
                  10.height,
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('customer_management'))
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CustomerManagement()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Wallet Management', //'Customer Management'
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                // if (Get.find<AuthController>()
                //     .profileModel!
                //     .role!
                //     .contains('Loyalty'))
                //   10.height,
                // if (Get.find<AuthController>()
                //     .profileModel!
                //     .role!
                //     .contains('Loyalty'))
                //   InkWell(
                //     onTap: () async {
                //       FocusManager.instance.primaryFocus?.unfocus();
                //       scaffoldKey.currentState?.closeDrawer();

                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (builder) => LoyaltyProgramScreen()));
                //     },
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 15, top: 0),
                //         child: Text(
                //           'Loyalty Management',
                //           style: poppinsMedium.copyWith(
                //               fontSize: 13, color: ColorTheme.hintText),
                //         ),
                //       ),
                //     ),
                //   ),
                // if (Get.find<AuthController>()
                //     .profileModel!
                //     .role!
                //     .contains('coupon'))
                //   10.height,
                // if (Get.find<AuthController>()
                //     .profileModel!
                //     .role!
                //     .contains('coupon'))
                //   InkWell(
                //     onTap: () async {
                //       FocusManager.instance.primaryFocus?.unfocus();
                //       scaffoldKey.currentState?.closeDrawer();

                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (builder) => CouponManagementScreen()));
                //     },
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 15, top: 0),
                //         child: Text(
                //           'Coupon Management',
                //           style: poppinsMedium.copyWith(
                //               fontSize: 13, color: ColorTheme.hintText),
                //         ),
                //       ),
                //     ),
                //   ),
                10.height,
                InkWell(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    scaffoldKey.currentState?.closeDrawer();

                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) =>
                                CustomerDesignationMasterScreen()));
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 0),
                      child: Text(
                        'Additional Fields', //'Customer Designation'
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
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

          // Employee Management
          if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('employee'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Employee Management',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => EmployeeMgmtScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Employee Management',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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

          if (Get.find<AuthController>().profileModel!.role!.contains('menu'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Menu Management',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => CategoriesScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Category',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => AddonsScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Addons',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.find<ExpenseManagementController>().tabValue.value =
                          0;
                      await Get.to(() => MenuHomeScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Menu Items',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => CancellationMasterScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Cancellation Reason',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
              .contains('expence'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Expense Management',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.find<ExpenseManagementController>().tabValue.value =
                          0;
                      await Get.to(() => ExpenseManagementScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Add Expenses',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();
                      // Get.find<ExpenseManagementController>().tabValue.value =
                      //     1;

                      // await Get.to(() => ExpenseManagementScreen());

                      Get.to(() => ExpenseStockScreen(
                            expenseController:
                                Get.find<ExpenseManagementController>(),
                            masterList: Get.find<ExpenseManagementController>()
                                    .masterList ??
                                [],
                            categoryList:
                                Get.find<ExpenseManagementController>()
                                        .categoryList ??
                                    [],
                          ));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Expense List',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();
                      // Get.find<ExpenseManagementController>().tabValue.value =
                      //     1;

                      // await Get.to(() => ExpenseManagementScreen());

                      Get.to(() => UnitPriceMasterScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Unit Price Master',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
              .contains('inventory'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Inventory Management',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => CurrentStocksScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Add Stock( Purchase )',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => AddIngredientsScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Ingredients',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  // 15.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => ManageVendor());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Vendor',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  // InkWell(
                  //   onTap: () async {
                  //     scaffoldKey.currentState!.closeDrawer();

                  //     FocusManager.instance.primaryFocus?.unfocus();

                  //     await Get.to(() => PurchaseReportScreen());
                  //   },
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(left: 15, top: 0),
                  //       child: Text(
                  //         'Purchase Report',
                  //         style: poppinsMedium.copyWith(
                  //             fontSize: 13, color: ColorTheme.hintText),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // 15.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => RecipesListScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Recipes',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => WastageMasterScreen());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Wastage Reason',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () async {
                      scaffoldKey.currentState!.closeDrawer();

                      FocusManager.instance.primaryFocus?.unfocus();

                      await Get.to(() => ManageInventory());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Manage Inventory( on /off )',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
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
          // if (Get.find<AuthController>()
          //     .profileModel!
          //     .role!
          //     .contains('sattle_report'))
          //   Theme(
          //     data:
          //         Theme.of(context).copyWith(dividerColor: Colors.transparent),
          //     child: ExpansionTile(
          //       iconColor: ColorTheme.hintText,
          //       initiallyExpanded: true,
          //       expandedAlignment: Alignment.centerLeft,
          //       title: Text(
          //         'Settlement',
          //         style: poppinsMedium.copyWith(
          //             fontSize: 14, color: ColorTheme.hintText),
          //       ),
          //       children: <Widget>[
          //         InkWell(
          //           onTap: () async {
          //             scaffoldKey.currentState!.closeDrawer();
          //             // _subscriptionBtStatus!.cancel();
          //             FocusManager.instance.primaryFocus?.unfocus();

          //             await Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (builder) => SettlementScreen()));
          //           },
          //           child: Align(
          //             alignment: Alignment.centerLeft,
          //             child: Padding(
          //               padding: const EdgeInsets.only(left: 15, top: 0),
          //               child: Text(
          //                 'Settlement',
          //                 style: poppinsMedium.copyWith(
          //                     fontSize: 13, color: ColorTheme.hintText),
          //               ),
          //             ),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 15, left: 15),
          //           child: DottedLine(
          //             direction: Axis.horizontal,
          //             alignment: WrapAlignment.center,
          //             lineThickness: 1.0,
          //             dashLength: 2.5,
          //             dashColor: ColorTheme.hintText,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),

          // if (Get.find<AuthController>()
          //         .profileModel!
          //         .role!
          //         .contains('report_summery') ||
          //     Get.find<AuthController>()
          //         .profileModel!
          //         .role!
          //         .contains('waiter_revenue_report'))
          //   Theme(
          //     data:
          //         Theme.of(context).copyWith(dividerColor: Colors.transparent),
          //     child: ExpansionTile(
          //       iconColor: ColorTheme.hintText,
          //       initiallyExpanded: true,
          //       expandedAlignment: Alignment.centerLeft,
          //       title: Text(
          //         'Report Summary',
          //         style: poppinsMedium.copyWith(
          //             fontSize: 14, color: ColorTheme.hintText),
          //       ),
          //       children: <Widget>[
          //         // if (Get.find<AuthController>()
          //         //     .profileModel!
          //         //     .role!
          //         //     .contains('report_summery'))
          //         //   InkWell(
          //         //     onTap: () async {
          //         //       FocusManager.instance.primaryFocus?.unfocus();
          //         //       scaffoldKey.currentState?.closeDrawer();

          //         //       final date = DateTime.now(); // Current Date
          //         //       await Navigator.push(
          //         //           context,
          //         //           MaterialPageRoute(
          //         //               builder: (builder) => DailySalesDetailsReport(
          //         //                     date: DateFormat('d-M-yyyy').format(date),
          //         //                   )));
          //         //     },
          //         //     child: Align(
          //         //       alignment: Alignment.centerLeft,
          //         //       child: Padding(
          //         //         padding: const EdgeInsets.only(left: 15, top: 0),
          //         //         child: Text(
          //         //           'Daily Report (NEW)',
          //         //           style: poppinsMedium.copyWith(
          //         //               fontSize: 13, color: ColorTheme.hintText),
          //         //         ),
          //         //       ),
          //         //     ),
          //         //   ),
          //         // const SizedBox(
          //         //   height: 10,
          //         // ),
          //         if (Get.find<AuthController>()
          //             .profileModel!
          //             .role!
          //             .contains('report_summery'))
          //           InkWell(
          //             onTap: () async {
          //               FocusManager.instance.primaryFocus?.unfocus();
          //               scaffoldKey.currentState?.closeDrawer();

          //               await Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                       builder: (builder) => ReportSummeryPage()));
          //             },
          //             child: Align(
          //               alignment: Alignment.centerLeft,
          //               child: Padding(
          //                 padding: const EdgeInsets.only(left: 15, top: 0),
          //                 child: Text(
          //                   'Report Summary',
          //                   style: poppinsMedium.copyWith(
          //                       fontSize: 13, color: ColorTheme.hintText),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         if (Get.find<AuthController>()
          //             .profileModel!
          //             .role!
          //             .contains('waiter_revenue_report'))
          //           10.height,
          //         if (Get.find<AuthController>()
          //             .profileModel!
          //             .role!
          //             .contains('waiter_revenue_report'))
          //           InkWell(
          //             onTap: () async {
          //               FocusManager.instance.primaryFocus?.unfocus();
          //               scaffoldKey.currentState?.closeDrawer();
          //               // if (Get.find<AuthController>()
          //               //     .profileModel!
          //               //     .role!
          //               //     .contains('waiter_revenue_report'))
          //               await Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                       builder: (builder) =>
          //                           DailyWaiterSalesDetailsReport()));
          //             },
          //             child: Align(
          //               alignment: Alignment.centerLeft,
          //               child: Padding(
          //                 padding: const EdgeInsets.only(left: 15, top: 0),
          //                 child: Text(
          //                   'Report Summary(W)',
          //                   style: poppinsMedium.copyWith(
          //                       fontSize: 13, color: ColorTheme.hintText),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 15, left: 15),
          //           child: DottedLine(
          //             direction: Axis.horizontal,
          //             alignment: WrapAlignment.center,
          //             lineThickness: 1.0,
          //             dashLength: 2.5,
          //             dashColor: ColorTheme.hintText,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),

          if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('coupon') ||
              Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('Loyalty') ||
              Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('restaurant_settings'))
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: ColorTheme.hintText,
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerLeft,
                title: Text(
                  'Resturant Configuration',
                  style: poppinsMedium.copyWith(
                      fontSize: 14, color: ColorTheme.hintText),
                ),
                children: <Widget>[
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('restaurant_settings'))
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        scaffoldKey.currentState?.closeDrawer();

                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    RestaurantSettingsScreen()));
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 0),
                          child: Text(
                            'Resturant Setting',
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                          ),
                        ),
                      ),
                    ),

                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('delivery_management'))
                    10.height,
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('delivery_management'))
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        scaffoldKey.currentState?.closeDrawer();

                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    DeliverySettingsScreen()));
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 0),
                          child: Text(
                            'Delivery Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                          ),
                        ),
                      ),
                    ),
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('printer_management'))
                    10.height,
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('printer_management'))
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        scaffoldKey.currentState?.closeDrawer();

                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    PrinterManagementScreen()));
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 0),
                          child: Text(
                            'Printer Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                          ),
                        ),
                      ),
                    ),
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('table_management'))
                    10.height,
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('table_management'))
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        scaffoldKey.currentState?.closeDrawer();

                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => TableManagementScreen()));
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 0),
                          child: Text(
                            'Table Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                          ),
                        ),
                      ),
                    ),
                     if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('aggregator'))
                  10.height,
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('aggregator'))
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) =>
                                  const AggregatorSetupScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Aggregator Setup',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('restaurant_settings'))
                  10.height,
                  if (Get.find<AuthController>()
                      .profileModel!
                      .role!
                      .contains('restaurant_settings'))
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) =>
                                  const PaymentTypeScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Payment Type',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),

                  // Table settings
                  // Website settings
                  // Printer Testing
                  // Printer settings
                  // Room settings

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
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
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
                            builder: ((context) => EmployeeResetPassword(
                                  resetToken:
                                      Get.find<AuthController>().getUserToken(),
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
                      padding: EdgeInsets.only(left: 15, top: 0),
                      child: Text(
                        'Reset Password',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                ),
                10.height,
                // if (GetPlatform.isAndroid)
                //   InkWell(
                //     onTap: () {
                //       scaffoldKey.currentState?.closeDrawer();
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

                    if (Get.find<AuthController>().isAdminSession) {
                      Get.bottomSheet(
                        ConfirmationDialog(
                            icon: Images.support,
                            description:
                                'You will be redirected to MyGenie Admin Dashboard',
                            title: 'Logout from Restaurant',
                            isLogOut: true,
                            onYesPressed: () async {
                              try {
                                Response response =
                                    await Get.find<AuthController>().logout();
                                if (response.statusCode == 200) {
                                  homeSocket?.clearListeners();
                                  homeSocket?.disconnect();
                                  homeSocket?.dispose();
                                  homeSocket = null;
                                  Get.find<RestaurantController>()
                                      .clearProductList();
                                  Get.find<AuthController>().clearSharedData();
                                  // Get.offAllNamed(RouteHelper.getSignInRoute());

                                  await Get.find<AuthController>()
                                      .logoutFromRestaurant();
                                  Get.offAllNamed(
                                      RouteHelper.getAdminDashboardRoute());

                                  showCustomSnackBar(
                                      'Logged out from restaurant successfully',
                                      isError: false);
                                }
                              } catch (e) {}
                            }),
                      );
                    } else {
                      Get.bottomSheet(
                        ConfirmationDialog(
                            icon: Images.support,
                            description:
                                'Are you sure you want to log out from My Genie?',
                            isLogOut: true,
                            onYesPressed: () async {
                              try {
                                Response response =
                                    await Get.find<AuthController>().logout();
                                if (response.statusCode == 200) {
                                  homeSocket?.clearListeners();
                                  homeSocket?.disconnect();
                                  homeSocket?.dispose();
                                  homeSocket = null;
                                  Get.find<RestaurantController>()
                                      .clearProductList();
                                  Get.find<AuthController>().clearSharedData();
                                  Get.offAllNamed(RouteHelper.getSignInRoute());
                                }
                              } catch (e) {}
                            }),
                      );
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 0),
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
          10.height,
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 0),
              child: Text(
                'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
                style: poppinsMedium.copyWith(
                    fontSize: 13, color: ColorTheme.hintText),
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
              style: poppinsMedium.copyWith(fontSize: 10, color: Colors.grey),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget tabButton(
      IconData icon, String label, int index, KdsController kdsController) {
    return GestureDetector(
      onTap: () {
        kdsController.setMainMenuIndex(
            index == kdsController.selectedMainMenu ? 3 : index);
        kdsController.setSubMenuIndex(4);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: index == kdsController.selectedMainMenu
              ? ColorTheme.green
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: index == kdsController.selectedMainMenu
                  ? Colors.white
                  : Color(0xFF828282),
              size: isDesktop(context)
                  ? 36
                  : isTablet(context)
                      ? 33
                      : 30,
            ),
            SizedBox(width: 5),
            Text(
              label,
              style: poppinsBold.copyWith(
                fontSize: isDesktop(context)
                    ? 15
                    : isTablet(context)
                        ? 13
                        : 12,
                color: index == kdsController.selectedMainMenu
                    ? Colors.white
                    : Color(0xFF828282),
              ),
            ),
          ],
        ),
      ),
    );
  }

  listenBlutooth({OrderList? order}) {
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' -----------------home status bt $status ------------------ ');
      if (Get.find<KdsController>().splitOrderList.isNotEmpty) {
        if (status == BTStatus.connected) {
          isConnect = true;
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              pendingTask = null;
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          }
        } else if (status == BTStatus.none) {
          if (!isConnect) {
            print('not connect');
            Future.delayed(Duration(seconds: 2), () async {
              // showErrorToast(
              //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
              isConnect = true;
              // splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
              // dataCheckSplitBill();
            });
          } else {
            isConnect = false;
            print('%%%%%%%%%');
          }
        }
      } else {
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
                  // GAP 1+8: use _activePrintCompleter so the BT callback
                  // stays part of the same awaitable Completer chain.
                  dataCheck(order!, completer: _activePrintCompleter);
                });
              } else {
                isConnect = true;
                isFailedPrint = true;
                failedCartProductList[currentPrintIndex] =
                    cartProductList[currentPrintIndex];
                currentPrintIndex = currentPrintIndex + 1;
                dataCheck(order!, completer: _activePrintCompleter);
              }
            });
          } else {
            isConnect = false;
            isSkipFirstTimeOrder = true;
            print('%%%%%%%%%');
          }
        }
      }
    });
  }

  // GAP 1+8: completer parameter propagates through the entire recursive chain.
  // Only the "all-done" branch calls completer.complete(); every other path
  // just passes the completer to the next recursive call.
  dataCheck(OrderList order, {Completer<void>? completer}) async {
    try {
      if (currentPrintIndex <= cartProductList.length - 1) {
        if (cartProductList[currentPrintIndex].isEmpty) {
          for (var i = currentPrintIndex; i < cartProductList.length; i++) {
            if (cartProductList[i].isEmpty) {
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck(order, completer: completer);
              break;
            } else {
              print(
                  'cancel KOT ${cartProductList[currentPrintIndex].first.foodStatus}');
              if (GetPlatform.isWindows) {
                int numberOfPrint = int.parse(Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .settings!
                        .noOfKotPrint ??
                    '1');
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
                          tokenNo: order.tokenNo ?? '',
                          printType: 'kot',
                          printTitle: cartProductList[currentPrintIndex]
                                      .first
                                      .foodStatus ==
                                  3
                              ? 'Cancel KOT'
                              : Get.find<AuthController>()
                                          .profileModel!
                                          .restaurantPrinterNew![
                                              currentPrintIndex]
                                          .areaName!
                                          .toUpperCase() ==
                                      'MASTER_KOT'
                                  ? 'Master KOT'
                                  : '',
                          orderType: order.orderType!,
                          stationName: cartProductList[currentPrintIndex]
                                  .first
                                  .station ??
                              '',
                          printEditOrderCount: '${order.editOrderCount}',
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
                    if (numberOfPrint > 1) {
                      for (int i = 1; i < numberOfPrint; i++) {
                        await Future.delayed(Duration(seconds: 2));
                        await Printing.directPrintPdf(
                          printer: element,
                          onLayout: (_) => WindowsPrintByteConvert()
                              .byteConvert(
                                  tokenNo: order.tokenNo ?? '',
                                  printType: 'kot',
                                  printTitle: cartProductList[currentPrintIndex]
                                              .first
                                              .foodStatus ==
                                          3
                                      ? 'Cancel KOT'
                                      : Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurantPrinterNew![
                                                      currentPrintIndex]
                                                  .areaName!
                                                  .toUpperCase() ==
                                              'MASTER_KOT'
                                          ? 'Master KOT'
                                          : '',
                                  orderType: order.orderType!,
                                  stationName:
                                      cartProductList[currentPrintIndex]
                                              .first
                                              .station ??
                                          '',
                                  printEditOrderCount:
                                      '${order.editOrderCount}',
                                  paperRoll: Get.find<AuthController>()
                                              .profileModel!
                                              .restaurantPrinterNew![
                                                  currentPrintIndex]
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
                      }
                    }
                    beepWindows();

                    break;
                  }
                }
                // await Printing.directPrintPdf(
                //   printer: printers.first,
                //   onLayout: (_) => generateKotPdf(order),
                // );
                currentPrintIndex = currentPrintIndex + 1;
                dataCheck(order, completer: completer);

                break;
              } else {
                if (Platform.isIOS) {
                  await iosPrintEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'kot',
                          printTitle: cartProductList[currentPrintIndex]
                                      .first
                                      .foodStatus ==
                                  3
                              ? 'Cancel KOT'
                              : Get.find<AuthController>()
                                          .profileModel!
                                          .restaurantPrinterNew![
                                              currentPrintIndex]
                                          .areaName!
                                          .toUpperCase() ==
                                      'MASTER_KOT'
                                  ? 'Master KOT'
                                  : '',
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
                      order,
                      completer: completer);
                } else {
                  await printEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'kot',
                          printTitle: cartProductList[currentPrintIndex]
                                      .first
                                      .foodStatus ==
                                  3
                              ? 'Cancel KOT'
                              : Get.find<AuthController>()
                                          .profileModel!
                                          .restaurantPrinterNew![
                                              currentPrintIndex]
                                          .areaName!
                                          .toUpperCase() ==
                                      'MASTER_KOT'
                                  ? 'Master KOT'
                                  : '',
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
                      order,
                      completer: completer);
                }
                break;
              }
            }
          }
        } else {
          print(
              'cancel KOT ${cartProductList[currentPrintIndex].first.foodStatus}');
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
                      tokenNo: order.tokenNo ?? '',
                      printTitle: cartProductList[currentPrintIndex]
                                  .first
                                  .foodStatus ==
                              3
                          ? 'Cancel KOT'
                          : Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .areaName!
                                      .toUpperCase() ==
                                  'MASTER_KOT'
                              ? 'Master KOT'
                              : '',
                      printEditOrderCount: '${order.editOrderCount}',
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
                int numberOfPrint = int.parse(Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .settings!
                        .noOfKotPrint ??
                    '1');
                if (numberOfPrint > 1) {
                  for (int i = 1; i < numberOfPrint; i++) {
                    await Future.delayed(Duration(seconds: 2));
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          printType: 'kot',
                          tokenNo: order.tokenNo ?? '',
                          printTitle: cartProductList[currentPrintIndex]
                                      .first
                                      .foodStatus ==
                                  3
                              ? 'Cancel KOT'
                              : Get.find<AuthController>()
                                          .profileModel!
                                          .restaurantPrinterNew![
                                              currentPrintIndex]
                                          .areaName!
                                          .toUpperCase() ==
                                      'MASTER_KOT'
                                  ? 'Master KOT'
                                  : '',
                          orderType: order.orderType!,
                          stationName: cartProductList[currentPrintIndex]
                                  .first
                                  .station ??
                              '',
                          printEditOrderCount: '${order.editOrderCount}',
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
                  }
                }
                break;
              }
            }
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck(order, completer: completer);
          } else {
            if (Platform.isIOS) {
              await iosPrintEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'kot',
                      printTitle: cartProductList[currentPrintIndex]
                                  .first
                                  .foodStatus ==
                              3
                          ? 'Cancel KOT'
                          : Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .areaName!
                                      .toUpperCase() ==
                                  'MASTER_KOT'
                              ? 'Master KOT'
                              : '',
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
                  order,
                  completer: completer);
            } else {
              await printEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'kot',
                      printTitle: cartProductList[currentPrintIndex]
                                  .first
                                  .foodStatus ==
                              3
                          ? 'Cancel KOT'
                          : Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .areaName!
                                      .toUpperCase() ==
                                  'MASTER_KOT'
                              ? 'Master KOT'
                              : '',
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
                  order,
                  completer: completer);
            }
          }
        }
      } else {
        // GAP 1+8: All stations done — signal the Completer so that the
        // awaiter in printMyGenieOrderQueue can release the lock.
        // processNextOrder() is now handled by printMyGenieOrderQueue's finally.
        if (isFailedPrint) {
          if (Platform.isAndroid) {
            await _subscriptionBtStatus?.cancel();
          }
          await Get.bottomSheet(PrintDialog(
            cartProductList: failedCartProductList,
            index: Get.find<KdsController>().updatedOrderIndex,
          ));
        }
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      }
    } catch (e, s) {
      // GAP 7: Log every exception from the print chain.
      PrintDebugLogger.error(
        traceId: PrintDebugController.generateTraceId(),
        orderId: null,
        flow: PrintFlowTag.normalPos,
        message: 'Exception in dataCheck: $e',
        details: {'stackTrace': s.toString()},
      );
      if (completer != null && !completer.isCompleted) {
        completer.completeError(e, s);
      }
    }
  }

  // GAP 1+8: completer parameter propagates through the aggregator station chain.
  aggregatorKotCheck(Order order, {Completer<void>? completer}) async {
    print("========== aggregatorKotCheck ==========");
    final String cancelKotTitle =
        order.orderDetailsOrder.fOrderStatus == 3 ? 'Cancel KOT' : '';
    try {
      if (currentPrintIndex <= swiggyCartProductList.length - 1) {
        if (swiggyCartProductList[currentPrintIndex].isEmpty) {
          for (var i = currentPrintIndex;
              i < swiggyCartProductList.length;
              i++) {
            if (swiggyCartProductList[i].isEmpty) {
              currentPrintIndex = currentPrintIndex + 1;
              aggregatorKotCheck(order, completer: completer);
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
                    int numberOfPrint = int.parse(Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .settings!
                            .noOfKotPrint ??
                        '1');

                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          brandName: order.brandName ?? '',
                          printType: 'swiggy_kot',
                          printTitle: cancelKotTitle,
                          orderType:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          stationName: swiggyCartProductList[currentPrintIndex]
                              .first
                              .station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.orderDetailsOrder.aggregatorOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName: '',
                          tablename:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          custName: order.customerDetails.name ?? '',
                          custPhone: order.customerDetails.phone ?? '',
                          swiggyOrderList:
                              swiggyCartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderDetailsOrder.orderNote ?? ''),
                    );
                    if (numberOfPrint > 1) {
                      for (int i = 1; i < numberOfPrint; i++) {
                        await Future.delayed(Duration(seconds: 2));
                        await Printing.directPrintPdf(
                          printer: element,
                          onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                              brandName: order.brandName ?? '',
                              printType: 'swiggy_kot',
                              printTitle: cancelKotTitle,
                              orderType: order.orderDetailsOrder.orderPlateform ==
                                      'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                              stationName: swiggyCartProductList[currentPrintIndex]
                                  .first
                                  .station,
                              paperRoll: Get.find<AuthController>()
                                          .profileModel!
                                          .restaurantPrinterNew![
                                              currentPrintIndex]
                                          .printerPaperRoll ==
                                      58
                                  ? 58
                                  : 80,
                              orderId:
                                  order.orderDetailsOrder.aggregatorOrderId,
                              date:
                                  '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                              waiterName: '',
                              tablename:
                                  order.orderDetailsOrder.orderPlateform ==
                                          'zomato'
                                      ? 'Zomato'
                                      : 'Swiggy',
                              custName: order.customerDetails.name ?? '',
                              custPhone: order.customerDetails.phone ?? '',
                              swiggyOrderList:
                                  swiggyCartProductList[currentPrintIndex] ?? [],
                              orderNote: order.orderDetailsOrder.orderNote ?? ''),
                        );
                      }
                    }
                    break;
                  }
                }
                // await Printing.directPrintPdf(
                //   printer: printers.first,
                //   onLayout: (_) => generateKotPdf(order),
                // );
                currentPrintIndex = currentPrintIndex + 1;
                aggregatorKotCheck(order, completer: completer);

                break;
              } else {
                if (Platform.isIOS) {
                  await iosPrintEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'swiggy_kot',
                          printTitle: cancelKotTitle,
                          orderType:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          stationName: swiggyCartProductList[currentPrintIndex]
                              .first
                              .station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.orderDetailsOrder.aggregatorOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName: '',
                          tablename:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          custName: order.customerDetails.name ?? '',
                          custPhone: order.customerDetails.phone ?? '',
                          swiggyOrderList:
                              swiggyCartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderDetailsOrder.orderNote ?? ''),
                      null,
                      swiggyKot: order,
                      completer: completer);
                } else {
                  await printEscPos(
                      await PrintByteConvert().byteConvert(
                          printType: 'swiggy_kot',
                          printTitle: cancelKotTitle,
                          orderType:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          stationName: swiggyCartProductList[currentPrintIndex]
                              .first
                              .station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.orderDetailsOrder.aggregatorOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName: '',
                          tablename:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          custName: order.customerDetails.name ?? '',
                          custPhone: order.customerDetails.phone ?? '',
                          swiggyOrderList:
                              swiggyCartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderDetailsOrder.orderNote ?? ''),
                      null,
                      swiggyKot: order,
                      completer: completer);
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
                int numberOfPrint = int.parse(Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .settings!
                        .noOfKotPrint ??
                    '1');
                await Printing.directPrintPdf(
                  printer: element,
                  onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                      printType: 'swiggy_kot',
                      printTitle: cancelKotTitle,
                      brandName: order.brandName ?? '',
                      orderType:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      stationName: swiggyCartProductList[currentPrintIndex]
                          .first
                          .station,
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.orderDetailsOrder.aggregatorOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '',
                      tablename:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      custName: order.customerDetails.name ?? '',
                      custPhone: order.customerDetails.phone ?? '',
                      swiggyOrderList:
                          swiggyCartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderDetailsOrder.orderNote ?? ''),
                );
                if (numberOfPrint > 1) {
                  for (int i = 1; i < numberOfPrint; i++) {
                    await Future.delayed(Duration(seconds: 2));
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          printType: 'swiggy_kot',
                          printTitle: cancelKotTitle,
                          brandName: order.brandName ?? '',
                          orderType:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          stationName: swiggyCartProductList[currentPrintIndex]
                              .first
                              .station,
                          paperRoll: Get.find<AuthController>()
                                      .profileModel!
                                      .restaurantPrinterNew![currentPrintIndex]
                                      .printerPaperRoll ==
                                  58
                              ? 58
                              : 80,
                          orderId: order.orderDetailsOrder.aggregatorOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                          waiterName: '',
                          tablename:
                              order.orderDetailsOrder.orderPlateform == 'zomato'
                                  ? 'Zomato'
                                  : 'Swiggy',
                          custName: order.customerDetails.name ?? '',
                          custPhone: order.customerDetails.phone ?? '',
                          swiggyOrderList:
                              swiggyCartProductList[currentPrintIndex] ?? [],
                          orderNote: order.orderDetailsOrder.orderNote ?? ''),
                    );
                  }
                }
                break;
              }
            }
            currentPrintIndex = currentPrintIndex + 1;
            aggregatorKotCheck(order, completer: completer);
          } else {
            if (Platform.isIOS) {
              await iosPrintEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'swiggy_kot',
                      printTitle: cancelKotTitle,
                      orderType:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      stationName: swiggyCartProductList[currentPrintIndex]
                          .first
                          .station,
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.orderDetailsOrder.aggregatorOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '',
                      tablename:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      custName: order.customerDetails.name ?? '',
                      custPhone: order.customerDetails.phone ?? '',
                      swiggyOrderList:
                          swiggyCartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderDetailsOrder.orderNote ?? ''),
                  null,
                  swiggyKot: order,
                  completer: completer);
            } else {
              await printEscPos(
                  await PrintByteConvert().byteConvert(
                      printType: 'swiggy_kot',
                      printTitle: cancelKotTitle,
                      orderType:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      stationName: swiggyCartProductList[currentPrintIndex]
                          .first
                          .station,
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .restaurantPrinterNew![currentPrintIndex]
                                  .printerPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: order.orderDetailsOrder.aggregatorOrderId,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName: '',
                      tablename:
                          order.orderDetailsOrder.orderPlateform == 'zomato'
                              ? 'Zomato'
                              : 'Swiggy',
                      custName: order.customerDetails.name ?? '',
                      custPhone: order.customerDetails.phone ?? '',
                      swiggyOrderList:
                          swiggyCartProductList[currentPrintIndex] ?? [],
                      orderNote: order.orderDetailsOrder.orderNote ?? ''),
                  null,
                  swiggyKot: order,
                  completer: completer);
            }
          }
        }
      } else {
        // GAP 1+8: All aggregator stations done — signal the Completer.
        if (isFailedPrint) {
          if (Platform.isAndroid) {
            await _subscriptionBtStatus?.cancel();
          }
        }
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      }
    } catch (e, s) {
      // GAP 7: log and propagate error through completer.
      PrintDebugLogger.error(
        traceId: PrintDebugController.generateTraceId(isAggregator: true),
        orderId: null,
        flow: PrintFlowTag.aggregator,
        message: 'Exception in aggregatorKotCheck: $e',
        details: {'stackTrace': s.toString()},
      );
      if (completer != null && !completer.isCompleted) {
        completer.completeError(e, s);
      }
    }
  }

  // GAP 1+8: completer propagated so printEscPos can carry it into the
  // Future.delayed callback where the next recursive call happens.
  Future printEscPos(List<int>? bytes, OrderList? order,
      {Order? swiggyKot, Completer<void>? completer}) async {
    print('bytes length:${bytes!.length}');
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        productId: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .productId,
        vendorId: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .vendorId,
        port: '9100',
        typePrinter: Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew![currentPrintIndex]
                    .printerName!
                    .toLowerCase() ==
                'usb'
            ? PrinterType.usb
            : Get.find<AuthController>()
                        .profileModel!
                        .restaurantPrinterNew![currentPrintIndex]
                        .printerName!
                        .toLowerCase() ==
                    'wifi'
                ? PrinterType.network
                : PrinterType.bluetooth,
        address: Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew![currentPrintIndex]
                    .printerName!
                    .toLowerCase() ==
                'wifi'
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
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfKotPrint ??
        '1');
    try {
      await _printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);

      if (numberOfPrint > 1) {
        for (int i = 1; i < numberOfPrint; i++) {
          await Future.delayed(Duration(seconds: 2));
          await _printerManager.send(
              type: bluetoothPrinter.typePrinter, bytes: bytes);
        }
      }
      bytes = null;

      // GAP 1+8: Pass the completer into the delayed callback so that the
      // recursive chain (dataCheck / aggregatorKotCheck) continues to carry it
      // and can complete it when the last station finishes.
      Future.delayed(Duration(seconds: 2), () async {
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance.disconnect(
            type: Get.find<AuthController>()
                        .profileModel!
                        .restaurantPrinterNew![currentPrintIndex]
                        .printerName!
                        .toLowerCase() ==
                    'usb'
                ? PrinterType.usb
                : Get.find<AuthController>()
                            .profileModel!
                            .restaurantPrinterNew![currentPrintIndex]
                            .printerName!
                            .toLowerCase() ==
                        'wifi'
                    ? PrinterType.network
                    : PrinterType.bluetooth);
        currentPrintIndex = currentPrintIndex + 1;
        swiggyKot != null
            ? aggregatorKotCheck(swiggyKot, completer: completer)
            : dataCheck(order!, completer: completer);
      });
    } catch (e, s) {
      // GAP 7: surface print errors instead of silently swallowing them.
      PrintDebugLogger.error(
        traceId: PrintDebugController.generateTraceId(),
        orderId: null,
        flow: swiggyKot != null ? PrintFlowTag.aggregator : PrintFlowTag.normalPos,
        message: 'printEscPos exception: $e',
        details: {'stackTrace': s.toString()},
      );
      if (completer != null && !completer.isCompleted) {
        completer.completeError(e, s);
      }
    }
  }

  Future swiggyBillPrintAndroid(List<int>? bytes) async {
    print('bytes length:${bytes!.length}');
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        productId: Get.find<AuthController>().profileModel?.billProductId ?? '',
        vendorId: Get.find<AuthController>().profileModel?.billVendorId ?? '',
        port: '9100',
        typePrinter:
            ((Get.find<AuthController>().profileModel?.billPrinterName ?? '')
                        .toLowerCase() ==
                    'usb')
                ? PrinterType.usb
                : ((Get.find<AuthController>().profileModel!.billPrinterName ??
                                '')
                            .toLowerCase() ==
                        'wifi'
                    ? PrinterType.network
                    : PrinterType.bluetooth),
        address:
            (Get.find<AuthController>().profileModel!.billPrinterName ?? '')
                        .toLowerCase() ==
                    'wifi'
                ? Get.find<AuthController>().profileModel!.billWifiIp
                : Get.find<AuthController>().profileModel!.billPrinterIp,
        deviceName: Get.find<AuthController>()
            .profileModel!
            .billPrinterName); //device name or ip was mandadory

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
            type: ((Get.find<AuthController>().profileModel?.billPrinterName ??
                            '')
                        .toLowerCase() ==
                    'usb')
                ? PrinterType.usb
                : (Get.find<AuthController>().profileModel!.billPrinterName ??
                                '')
                            .toLowerCase() ==
                        'wifi'
                    ? PrinterType.network
                    : PrinterType.bluetooth);
      });
    } catch (e) {}
  }

  // GAP 1+8: completer flows through iosPrintEscPos so the finally block can
  // carry it to the next recursive call, keeping the chain awaitable.
  Future iosPrintEscPos(
    List<int>? bytes,
    OrderList? order, {
    Order? swiggyKot,
    Completer<void>? completer,
  }) async {
    if (bytes == null) return;

    print('########## bytes length ${bytes.length}');

    final auth = Get.find<AuthController>();

    // 🔴 Case: printer IP missing
    if (auth.profileModel!.restaurantPrinterNew![currentPrintIndex]
                .macPrinterIp ==
            '' &&
        NetworkPrinterResolver.kotPrinterAt(currentPrintIndex) == null &&
        (order != null || swiggyKot != null)) {
      isConnect = true;

      if (swiggyKot == null) {
        isFailedPrint = true;
        failedCartProductList[currentPrintIndex] =
            cartProductList[currentPrintIndex];
      }

      currentPrintIndex++;

      swiggyKot == null
          ? dataCheck(order!, completer: completer)
          : aggregatorKotCheck(swiggyKot, completer: completer);
      return;
    }

    final String macAddress = order == null && swiggyKot == null
        ? auth.profileModel!.billPrinterIp!
        : auth.profileModel!.restaurantPrinterNew![currentPrintIndex]
            .macPrinterIp!;

    final bool connected =
        await IosPrintTransport.connect(wifiPrinter: order == null && swiggyKot == null ? NetworkPrinterResolver.billPrinter() : NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), macPrinterAddress: macAddress);

    // ✅ iPad needs settle time
    await Future.delayed(const Duration(seconds: 5));

    if (!connected) {
      // ❌ Connection failed — advance to next station and carry completer
      if (order != null) {
        isConnect = true;
        isFailedPrint = true;
        failedCartProductList[currentPrintIndex] =
            cartProductList[currentPrintIndex];
        currentPrintIndex++;
        dataCheck(order, completer: completer);
      } else if (swiggyKot != null) {
        isConnect = true;
        currentPrintIndex++;
        aggregatorKotCheck(swiggyKot, completer: completer);
      }
      return;
    }

    try {
      int numberOfPrint = int.parse(Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .settings!
              .noOfKotPrint ??
          '1');
      if (auth.profileModel!.billPrinterPaperRoll == 58 ||
          MediaQuery.of(context).size.shortestSide < 570) {
        // 58mm OR phone → direct write
        await IosPrintTransport.writeBytes(bytes);

        if (numberOfPrint > 1) {
          for (int i = 1; i < numberOfPrint; i++) {
            await Future.delayed(Duration(seconds: 2));
            await IosPrintTransport.writeBytes(bytes);
          }
        }
      } else {
        // 80mm + iPad → chunked write
        await _writeBytesForIPad(bytes);
        if (numberOfPrint > 1) {
          for (int i = 1; i < numberOfPrint; i++) {
            await Future.delayed(Duration(seconds: 2));
            await _writeBytesForIPad(bytes);
          }
        }
      }

      // Allow printer buffer to flush
      await Future.delayed(const Duration(seconds: 4));

      bytes.clear();
    } catch (e, s) {
      // GAP 7: log iOS print errors.
      print('iosPrintEscPos error: $e');
      PrintDebugLogger.error(
        traceId: PrintDebugController.generateTraceId(),
        orderId: null,
        flow: swiggyKot != null ? PrintFlowTag.aggregator : PrintFlowTag.normalPos,
        message: 'iosPrintEscPos exception: $e',
        details: {'stackTrace': s.toString()},
      );
    } finally {
      await IosPrintTransport.disconnect;

      // Carry completer to the next station in the chain.
      if (order != null) {
        currentPrintIndex++;
        dataCheck(order, completer: completer);
      } else if (swiggyKot != null) {
        currentPrintIndex++;
        aggregatorKotCheck(swiggyKot, completer: completer);
      }
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 180; // iPad-safe BLE MTU
    const int delayMs = 60;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    _handleMessage(initialMessage);
  }

  // when app is in background
  void _handleMessage(RemoteMessage? message) async {
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
      print(message.notification!.android!.sound);

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        message.notification!.android!.sound!,
        'My Genie',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        priority: n.Priority.high,
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
          var order_accepted = AndroidNotificationChannel(
            'order_accepted', // Unique ID for channel 1
            'order_accepted', // Name of channel 1
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'order_accepted'), // Sound file for channel 1
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
          var forty_five_sec_buzzer = AndroidNotificationChannel(
            'forty_five_sec_buzzer', // Unique ID for channel 2
            'forty_five_sec_buzzer', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'forty_five_sec_buzzer'), // Sound file for channel 2
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
          var order_rejected = AndroidNotificationChannel(
            'order_rejected', // Unique ID for channel 2
            'order_rejected', // Name of channel 2
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(
                'order_rejected'), // Sound file for channel 2
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
              ?.createNotificationChannel(five_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(forty_five_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(ten_sec_buzzer);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(order_accepted);
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(order_rejected);
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
            print('order push sound: $alertSound data: ${message.data} loopOrderAlert: $loopOrderAlert');
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
              priority: n.Priority.high,
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
                message.notification!.title!,
                message.notification!.body!,
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
}

class OrderIdType {
  String? orderId;
  String? orderType;
  bool? isAggregator;
  String? orderOthervalue;
  bool isKOTFromFixedStation;
  bool isBillFromFixedStation;
  dynamic newOrderJson;

  OrderIdType(
      {this.orderId,
      this.orderType,
      this.isAggregator,
      this.orderOthervalue,
      this.isKOTFromFixedStation = false,
      this.isBillFromFixedStation = false,
      this.newOrderJson});
}

class AutoPrintType {
  OrderList? mygenieOrder;
  Bill? mygenieOrderFromFixed;
  Order? aggregatorOrder;
  bool? isAggregator;
  bool isBillPrint;
  bool isManualBillPrint;

  AutoPrintType(
      {this.mygenieOrder,
      this.mygenieOrderFromFixed,
      this.aggregatorOrder,
      this.isAggregator,
      this.isBillPrint = false,
      this.isManualBillPrint = false});
}
