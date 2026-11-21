import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image/image.dart' as prefix;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/buffet_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/enums.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/data/model/response/buffet_order_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_kds_order_total_food_item_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/main.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/cancel_order/cancel_order.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/customer_report.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/view/customer_designation_master.dart';
import 'package:mygenie_restaurant/view/screens/customer_management/customer_management.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_report.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/stock_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/unit_price_master.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/hyatt/buffet_food_list.dart';
import 'package:mygenie_restaurant/view/screens/hyatt/buffet_order_list.dart';
import 'package:mygenie_restaurant/view/screens/hyatt/buffet_tablet_foodlist.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/daily_consumption_report.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_inventory.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_master.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_report.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/cancellation%20reason/cancellation_master.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/prep_serve_time_report/perp_serve_time_report.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart';
import 'package:mygenie_restaurant/view/screens/online_unpaid_order/online_unpaid_order.dart';
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
import 'package:mygenie_restaurant/view/screens/resturant_config/delivery_management/delivery_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/resturant_setting/resturant_setting.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/printer_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/table_management/table_management_screen.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/revenue_report.dart';
import 'package:mygenie_restaurant/view/screens/settelment_report/settelment_report.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:mygenie_restaurant/view/screens/swiggy_zomato/date_wise_orderlist.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/room_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_report.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

class BuffetHomeScreen extends StatefulWidget {
  @override
  State<BuffetHomeScreen> createState() => _BuffetHomeScreenState();
}

class _BuffetHomeScreenState extends State<BuffetHomeScreen> {
  List<bool> skipFailedList = [];

  int splitCurrentPrintIndex = 0;
  Timer? timer;
  ScrollController _scrollController = ScrollController();
  FirebaseMessaging? _messaging;
  bool isProcessingOrderQueue = false;
  List<OrderIdType> orderIdQueue = [];
  List<OrderList> orderQueue = [];
  bool isProcessingOrder = false;

  bool isCollaps = false;
  bool isOpenedDropdown = false;
  bool isSkipFirstTimeOrder = false;
  List<String> orderTypeList = [
    'All',
    'Dine In',
    // 'Take Away',
    // 'Delivery',
    // 'Room'
  ];
  FlutterTts flutterTts = FlutterTts();
  List<bool> isSplitPrinterProccessingList = [];
  List<bool> isSplitPrintedList = [];

  List<List<OrderDetails>> cartProductList = [];
  List<List<OrderDetails>> failedCartProductList = [];
  bool isFailedPrint = false;
  PackageInfo? packageInfo;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _dropdownContoller = SuperTooltipController();

  Future<void> initData() async {
    await Get.find<BuffetController>().getBuffetOrderList();
    await Get.find<KdsController>().getTotalKdsOrder();

    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .defOrdStatus ==
        5) {
      Get.find<KdsController>().setSubMenuIndex(2);
      Get.find<BuffetController>().update();
    } else {
      Get.find<KdsController>().setSubMenuIndex(1);
      Get.find<BuffetController>().update();
    }
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

  TextEditingController searchController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController searchTable = TextEditingController();

  @override
  void initState() {
    Get.find<KdsController>().orderIdFromSocket = '';
    //    var androidInitialize = AndroidInitializationSettings('notification_icon');
    // var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: DarwinInitializationSettings());
    // flutterLocalNotificationsPlugin.initialize(initializationsSettings);

    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotification);
    setupInteractedMessage();
    registerNotification();

    // checkForInitialMessage();
    initfirebase();
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // listenBlutooth();
    if (Get.find<AuthController>().profileModel!.restaurants!.first.delivery!) {
      if (!orderTypeList.contains('Delivery')) orderTypeList.add('Delivery');
      if (!orderTypeList.contains('Take Away')) orderTypeList.add('Take Away');
    }
    if (Get.find<AuthController>().profileModel!.restaurants!.first.showRoom ==
        'Yes') {
      if (!orderTypeList.contains('Room')) orderTypeList.add('Room');
    }
//  List<String> orderTypeList = [
//     'All',
//     'Dine In',
//     'Take Away',
//     'Delivery',
//     'Room'
//   ];
    initData();

    connectToSocketIO();
    timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => Get.find<KdsController>().update());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    homeSocket?.dispose();
    super.dispose();
  }

  void connectToSocketIO() {
    try {
      // socket?.disconnect();
      // Configure socket transports must be specified
      homeSocket = io(AppConstants.SOCKET_BASE_URL, <String, dynamic>{
        'transports': ['websocket'],
        //  'path': '/socket',
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 999999,
        'reconnectionDelay': 2000,
      });
      // CR-077: join the restaurant room on every connect/reconnect.
      // Registered before connect() so the first 'connect' event is never missed.
      homeSocket?.onConnect((_) {
        homeSocket?.emit('join_restaurant', {
          'restaurant_id':
              Get.find<AuthController>().profileModel!.restaurants![0].id
        });
      });
      homeSocket?.on('joined_restaurant', (data) {
        print('[socket] joined ${data['room']}');
      });

      // Connect to websocket
      if (!homeSocket!.connected) {
        homeSocket?.connect();
      }

      // Handle homeSocket events
      // socket.on('connect', (_) => print('connect: ${socket.id}'));
      homeSocket?.off(
          'new_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}');

      homeSocket?.on(
          'new_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}',
          (data) async {
        print('/////////$data');
        if (Get.find<AuthController>()
                .profileModel!
                .restaurants![0]
                .id
                .toString() ==
            '${data[2]}') {
          if (data[0] == 'update-order' ||
              data[0] == 'new-order' ||
              data[0] == 'scan-new-order' ||
              data[0] == 'update-food-status' ||
              data[0] == 'update-item-status' ||
              data[0] == 'update-priority-food-status' ||
              data[0] == 'update-order-status') {
            checkQueueProcessFromSocket(
                orderType: data[0],
                orderId: '${data[1]}',
                otherValue: data[0] == 'update-food-status' || data[0] == 'update-item-status' ||
                        data[0] == 'update-priority-food-status'
                    ? '${data[3]}'
                    : '0',
                newOrderJson: data[0] == 'new-order' ? data[4] : null);
          }
        }
      });

      homeSocket?.on('disconnect', (d) {
        print('disconnect----$d');
        // socket = io(
        //   AppConstants.SOCKET_BASE_URL,
        //   OptionBuilder()
        //       .setTransports(['websocket'])
        //       .enableForceNew()
        //       .enableReconnection()
        //       .enableAutoConnect()
        //       .build(),
        // );
      });
      homeSocket?.onReconnect((_) async {
        print('♻️ Socket Reconnected');

        await Get.find<BuffetController>().getBuffetOrderList();
        await Get.find<KdsController>().getTotalKdsOrder();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              paidController.clear();
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        titleSpacing: 0,
        elevation: 0,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? foodStatusTabAppBar()
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
              ),
        //     Image.asset(Images.ic_kds_app_logo, width: Get.width * 0.4),
        actions: [
          if (Get.find<AuthController>().profileModel!.role!.contains('order'))
            Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              child: InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  searchController.clear();
                  paidController.clear();
                  Get.find<RestaurantController>().setOrderType('No');
                  Get.find<RestaurantController>().setFoodType('Normal');
                  checkRestaurantIsOpen();
                },
                child: Container(
                  // color: Colors.green,
                  width: 80,
                  padding: EdgeInsets.only(left: 35, top: 10, bottom: 10),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: ColorTheme.appColor, shape: BoxShape.circle),
                    child: Center(
                        child: Icon(Icons.add, color: Colors.white, size: 20)),
                  ),
                ),
              ),
            ),
          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
        ],
      ),
      drawer: 
      Drawer(
        backgroundColor: Color(0xFFF8F8F8),
        child:sideDrawer()
        //  SafeArea(
        //   child: ListView(
        //     // padding: EdgeInsets.zero,

        //     children: <Widget>[
        //       Align(
        //         alignment: Alignment.centerLeft,
        //         child: Padding(
        //           padding: const EdgeInsets.only(top: 20, left: 15),
        //           child: Image.asset(
        //             Images.brand_logo,
        //             height: Get.height * 0.1,
        //           ),
        //         ),
        //       ),
        //       Align(
        //         alignment: Alignment.centerLeft,
        //         child: Padding(
        //           padding: const EdgeInsets.only(left: 15, top: 7),
        //           child: Text(
        //             '${Get.find<AuthController>()?.profileModel?.empFname ?? ''} ${Get.find<AuthController>()?.profileModel?.empLname ?? ''}',
        //             style: poppinsMedium.copyWith(
        //                 fontSize: 13, color: ColorTheme.hintText),
        //           ),
        //         ),
        //       ),
        //       if (Get.find<AuthController>()
        //           .profileModel!
        //           .role!
        //           .contains('report'))
        //         Theme(
        //           data: Theme.of(context)
        //               .copyWith(dividerColor: Colors.transparent),
        //           child: ExpansionTile(
        //             iconColor: ColorTheme.hintText,
        //             initiallyExpanded: true,
        //             expandedAlignment: Alignment.centerLeft,
        //             title: Text(
        //               'Report',
        //               style: poppinsMedium.copyWith(
        //                   fontSize: 14, color: ColorTheme.hintText),
        //             ),
        //             children: <Widget>[
        //               if (Get.find<AuthController>()
        //                   .profileModel!
        //                   .role!
        //                   .contains('revenue_report'))
        //                 InkWell(
        //                   onTap: () async {
        //                     scaffoldKey.currentState?.closeDrawer();
        //                     FocusManager.instance.primaryFocus?.unfocus();

        //                     await Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                             builder: (builder) => RevenueReport()));
        //                   },
        //                   child: Align(
        //                     alignment: Alignment.centerLeft,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(left: 15),
        //                       child: Text(
        //                         'Revenue Report',
        //                         style: poppinsMedium.copyWith(
        //                             fontSize: 13, color: ColorTheme.hintText),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               if (Get.find<AuthController>()
        //                   .profileModel!
        //                   .role!
        //                   .contains('sattle_report'))
        //                 InkWell(
        //                   onTap: () async {
        //                     scaffoldKey.currentState?.closeDrawer();
        //                     FocusManager.instance.primaryFocus?.unfocus();

        //                     await Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                             builder: (builder) => SettlementReport()));
        //                   },
        //                   child: Align(
        //                     alignment: Alignment.centerLeft,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(left: 15, top: 10),
        //                       child: Text(
        //                         'Settlement Report',
        //                         style: poppinsMedium.copyWith(
        //                             fontSize: 13, color: ColorTheme.hintText),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               InkWell(
        //                 onTap: () async {
        //                   FocusManager.instance.primaryFocus?.unfocus();
        //                   scaffoldKey.currentState?.closeDrawer();
        //                   await Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (builder) => PrintReport()));
        //                 },
        //                 child: Align(
        //                   alignment: Alignment.centerLeft,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(left: 15, top: 10),
        //                     child: Text(
        //                       'Daily report',
        //                       style: poppinsMedium.copyWith(
        //                           fontSize: 13, color: ColorTheme.hintText),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               Padding(
        //                 padding: const EdgeInsets.only(top: 15, left: 15),
        //                 child: DottedLine(
        //                   direction: Axis.horizontal,
        //                   alignment: WrapAlignment.center,
        //                   lineThickness: 1.0,
        //                   dashLength: 2.5,
        //                   dashColor: ColorTheme.hintText,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       Theme(
        //         data: Theme.of(context)
        //             .copyWith(dividerColor: Colors.transparent),
        //         child: ExpansionTile(
        //           iconColor: ColorTheme.hintText,
        //           initiallyExpanded: true,
        //           expandedAlignment: Alignment.centerLeft,
        //           title: Text(
        //             'Orders',
        //             style: poppinsMedium.copyWith(
        //                 fontSize: 14, color: ColorTheme.hintText),
        //           ),
        //           children: <Widget>[
        //             InkWell(
        //               onTap: () async {
        //                 scaffoldKey.currentState?.closeDrawer();
        //                 FocusManager.instance.primaryFocus?.unfocus();

        //                 await Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                         builder: (builder) => ViewPaidOrders()));
        //               },
        //               child: Align(
        //                 alignment: Alignment.centerLeft,
        //                 child: Padding(
        //                   padding: const EdgeInsets.only(left: 15, top: 0),
        //                   child: Text(
        //                     'Paid Orders',
        //                     style: poppinsMedium.copyWith(
        //                         fontSize: 13, color: ColorTheme.hintText),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.only(top: 15, left: 15),
        //               child: DottedLine(
        //                 direction: Axis.horizontal,
        //                 alignment: WrapAlignment.center,
        //                 lineThickness: 1.0,
        //                 dashLength: 2.5,
        //                 dashColor: ColorTheme.hintText,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Theme(
        //         data: Theme.of(context)
        //             .copyWith(dividerColor: Colors.transparent),
        //         child: ExpansionTile(
        //           iconColor: ColorTheme.hintText,
        //           initiallyExpanded: true,
        //           expandedAlignment: Alignment.centerLeft,
        //           title: Text(
        //             'My Profile',
        //             style: poppinsMedium.copyWith(
        //                 fontSize: 14, color: ColorTheme.hintText),
        //           ),
        //           children: <Widget>[
        //             InkWell(
        //               onTap: () {
        //                 scaffoldKey.currentState?.closeDrawer();
        //                 FocusManager.instance.primaryFocus?.unfocus();

        //                 String logo = '';
        //                 if (!Get.find<AuthController>()
        //                         .profileModel!
        //                         .role!
        //                         .contains('order') &&
        //                     Get.find<AuthController>()
        //                         .profileModel!
        //                         .role!
        //                         .contains('bill')) {
        //                   logo = Images.ic_cashier_app_logo;
        //                 } else if (Get.find<AuthController>()
        //                     .profileModel!
        //                     .role!
        //                     .contains('report')) {
        //                   logo = Images.ic_owner_app_logo;
        //                 } else if (Get.find<AuthController>()
        //                     .profileModel!
        //                     .role!
        //                     .contains('Manager')) {
        //                   logo = Images.ic_manager_app_logo;
        //                 } else {
        //                   logo = Images.ic_waiter_app_logo;
        //                 }

        //                 Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                         builder: ((context) => EmployeeResetPassword(
        //                               resetToken: Get.find<AuthController>()
        //                                   .getUserToken(),
        //                               email: Get.find<AuthController>()
        //                                       .profileModel
        //                                       ?.empEmail ??
        //                                   '',
        //                               image: logo,
        //                               password: '',
        //                               fromPasswordChange: true,
        //                             ))));

        //                 // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
        //                 //     Get.find<AuthController>().profileModel.empEmail,
        //                 //     Get.find<AuthController>().getUserToken(),
        //                 //     'password-change'));
        //                 // Get.toNamed(RouteHelper.getTapManagementRoute());
        //               },
        //               child: Align(
        //                 alignment: Alignment.centerLeft,
        //                 child: Padding(
        //                   padding: EdgeInsets.only(
        //                       left: 15, top: GetPlatform.isIOS ? 10 : 0),
        //                   child: Text(
        //                     'Reset Password',
        //                     style: poppinsMedium.copyWith(
        //                         fontSize: 13, color: ColorTheme.hintText),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             InkWell(
        //               onTap: () {
        //                 FocusManager.instance.primaryFocus?.unfocus();
        //                 scaffoldKey.currentState?.closeDrawer();

        //                 if (Get.find<AuthController>().isAdminSession) {
        //                   Get.bottomSheet(
        //                     ConfirmationDialog(
        //                         icon: Images.support,
        //                         description:
        //                             'You will be redirected to MyGenie Admin Dashboard',
        //                         title: 'Logout from Restaurant',
        //                         isLogOut: true,
        //                         onYesPressed: () async {
        //                           try {
        //                             Response response =
        //                                 await Get.find<AuthController>()
        //                                     .logout();
        //                             if (response.statusCode == 200) {
        //                               homeSocket?.clearListeners();
        //                               homeSocket?.disconnect();
        //                               homeSocket?.dispose();
        //                               homeSocket = null;
        //                               Get.find<RestaurantController>()
        //                                   .clearProductList();
        //                               Get.find<AuthController>()
        //                                   .clearSharedData();
        //                               // Get.offAllNamed(RouteHelper.getSignInRoute());

        //                               await Get.find<AuthController>()
        //                                   .logoutFromRestaurant();
        //                               Get.offAllNamed(
        //                                   RouteHelper.getAdminDashboardRoute());

        //                               showCustomSnackBar(
        //                                   'Logged out from restaurant successfully',
        //                                   isError: false);
        //                             }
        //                           } catch (e) {}
        //                         }),
        //                   );
        //                 } else {
        //                   Get.bottomSheet(
        //                     ConfirmationDialog(
        //                         icon: Images.support,
        //                         description:
        //                             'Are you sure you want to log out from My Genie?',
        //                         isLogOut: true,
        //                         onYesPressed: () async {
        //                           try {
        //                             Response response =
        //                                 await Get.find<AuthController>()
        //                                     .logout();
        //                             if (response.statusCode == 200) {
        //                               homeSocket?.clearListeners();
        //                               homeSocket?.disconnect();
        //                               homeSocket?.dispose();
        //                               homeSocket = null;
        //                               Get.find<RestaurantController>()
        //                                   .clearProductList();
        //                               Get.find<AuthController>()
        //                                   .clearSharedData();
        //                               Get.offAllNamed(
        //                                   RouteHelper.getSignInRoute());
        //                             }
        //                           } catch (e) {}
        //                         }),
        //                   );
        //                 }
        //               },
        //               child: Align(
        //                 alignment: Alignment.centerLeft,
        //                 child: Padding(
        //                   padding: const EdgeInsets.only(left: 15, top: 10),
        //                   child: Text(
        //                     'Logout',
        //                     style: poppinsMedium.copyWith(
        //                         fontSize: 13, color: ColorTheme.hintText),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
        //           style:
        //               poppinsMedium.copyWith(fontSize: 10, color: Colors.grey),
        //         ),
        //         onTap: () {},
        //       ),
        //     ],
        //   ),
        // ),
     
      ),
     
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          return await initData();
        },
        child: Column(children: [
          if (MediaQuery.of(context).size.shortestSide < 570) readyTab(),

          SizedBox(height: 16),
          GetBuilder<BuffetController>(builder: (buffetController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
              child: Container(
                height: 36.h,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        autofocus: false,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                          suffixIcon:
                              Icon(Icons.search, color: ColorTheme.appColor),
                          hintText: 'Search by Table no.',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide:
                                BorderSide(color: ColorTheme.borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide:
                                BorderSide(color: ColorTheme.borderGrey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide:
                                BorderSide(color: ColorTheme.borderGrey),
                          ),
                          hintStyle: poppinsRegular.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        onChanged: (value) async {
                          buffetController.update();
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // Get.find<KdsController>().resetSplitBill();
                        await Get.find<BuffetController>().getBuffetOrderList();
                        await Get.find<KdsController>().getTotalKdsOrder();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.refresh_outlined,
                            color: ColorTheme.appColor, size: 35),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),

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
              controller: _scrollController,
              child: GetBuilder<BuffetController>(builder: (buffetController) {
                return buffetController.orderList == null
                    ? const SizedBox.shrink()
                    : buffetController.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_LARGE),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('Buffet'))
                                  if (MediaQuery.of(context).size.width >=
                                          1500 ||
                                      MediaQuery.of(context).orientation ==
                                          Orientation.landscape)
                                    Container(
                                      padding: EdgeInsets.all(
                                          Dimensions.PADDING_SIZE_DEFAULT),
                                      margin: EdgeInsets.only(
                                        left: Dimensions.PADDING_SIZE_SMALL,
                                        right: Dimensions.PADDING_SIZE_DEFAULT,
                                      ),
                                      width: Get.width * 0.2,
                                      // height: Get.height * 0.9,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_LARGE),
                                        // color: Colors.green
                                        color: Color.fromRGBO(250, 250, 250, 1),
                                      ),
                                      child: GetBuilder<KdsController>(
                                          builder: (kdsController) {
                                        return kdsController
                                                    .getKdsTotalOrderResponse ==
                                                null
                                            ? SizedBox.shrink()
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Stations',
                                                    style: poppinsBold.copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_OVER_LARGE,
                                                        color: ColorTheme
                                                            .appColor),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Item',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                      SizedBox(
                                                          width: Dimensions
                                                              .PADDING_SIZE_DEFAULT),
                                                      Text(
                                                        'Quantity',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(color: Colors.black),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .PADDING_SIZE_SMALL),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      itemCount: kdsController
                                                              .getKdsTotalOrderResponse
                                                              ?.orderedCategories
                                                              ?.length ??
                                                          0,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        OrderedCategories
                                                            orderedCategory =
                                                            kdsController
                                                                .getKdsTotalOrderResponse!
                                                                .orderedCategories![index];

                                                        return Container(
                                                          child: Column(
                                                            children: [
                                                              ListView.builder(
                                                                  itemCount:
                                                                      orderedCategory
                                                                          .foodCounts!
                                                                          .length,
                                                                  shrinkWrap:
                                                                      true,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int i) {
                                                                    return Container(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              Dimensions.PADDING_SIZE_SMALL),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                Get.width * 0.14,
                                                                            child:
                                                                                Text(
                                                                              orderedCategory.foodCounts![i].split(':').first,
                                                                              style: poppinsMedium.copyWith(
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  fontSize: 16,
                                                                                  color: index % 3 == 0
                                                                                      ? ColorTheme.kdsLeftMenuBlue
                                                                                      : index % 2 == 0
                                                                                          ? ColorTheme.green
                                                                                          : ColorTheme.kdsLeftMenuBrown),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                              child: DottedLine(
                                                                            direction:
                                                                                Axis.horizontal,
                                                                            alignment:
                                                                                WrapAlignment.center,
                                                                            lineThickness:
                                                                                1.0,
                                                                            dashLength:
                                                                                1.0,
                                                                            dashColor: index % 3 == 0
                                                                                ? ColorTheme.kdsLeftMenuBlue
                                                                                : index % 2 == 0
                                                                                    ? ColorTheme.green
                                                                                    : ColorTheme.kdsLeftMenuBrown,
                                                                          )),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                                                                            child:
                                                                                Text(
                                                                              orderedCategory.foodCounts![i].split(':').last,
                                                                              style: poppinsMedium.copyWith(
                                                                                  fontSize: 14,
                                                                                  color: index % 3 == 0
                                                                                      ? ColorTheme.kdsLeftMenuBlue
                                                                                      : index % 2 == 0
                                                                                          ? ColorTheme.green
                                                                                          : ColorTheme.kdsLeftMenuBrown),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }),
                                                              SizedBox(
                                                                height: Dimensions
                                                                    .PADDING_SIZE_EXTRA_LARGE,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      })
                                                ],
                                              );
                                      }),
                                    ),
                                Expanded(
                                  child: orderListContent(buffetController,
                                      Get.find<KdsController>()),
                                ),
                              ],
                            ));
              }),
            ),
          ),
        ]),
      ),
    );
  }

  Widget orderListContent(
      BuffetController buffetController, KdsController kdsController) {
    return GetBuilder(builder: (BuffetController buffetController) {
      return buffetController.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                StaggeredGrid.count(
                  crossAxisCount: Get.width > 1300
                      ? 4
                      : Get.width > 600
                          ? 2
                          : 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 0,
                  children: [
                    ...buffetController.orderList!.priorityOrderDetails!
                        .where((element) =>
                            (kdsController.selectedSubMenu == 2
                                ? element.foodStatus == 5
                                : element.foodStatus == 2) &&
                            element.tableIdSeq!
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .map((order) {
                      // Now return the widget directly
                      return BuffetOrderList(
                          searchOrder: searchController,
                          searchTable: searchTable,
                          flutterTit: flutterTts,
                          order: order,
                          isWaiter: true);
                    }).toList(),
                    ...buffetController.orderList!.orderDetails!
                        .where((element) =>
                            (kdsController.selectedSubMenu == 2
                                ? element.foodStatus == 5
                                : element.foodStatus == 2) &&
                            element.tableIdSeq!
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                        .map((order) {
                      // Now return the widget directly
                      return BuffetOrderList(
                          searchOrder: searchController,
                          searchTable: searchTable,
                          flutterTit: flutterTts,
                          order: order,
                          isWaiter: true);
                    }).toList(),
                  ],
                ),
                // StaggeredGrid.count(
                //   crossAxisCount: Get.width > 1300 ? 4 : 1,
                //   crossAxisSpacing: 10,
                //   mainAxisSpacing: 0,
                //   children: buffetController.getOrderList.orderDetails
                //       .where((element) =>
                //           element.foodStatus == 2 &&
                //           element.tableIdSeq
                //               .toLowerCase()
                //               .contains(searchController.text.toLowerCase()))
                //       .map((order) {
                //     // Now return the widget directly
                //     return BuffetOrderList(_subscriptionBtStatus,
                //         searchOrder: searchController,
                //         searchTable: searchTable,
                //         flutterTit: flutterTts,
                //         order: order,
                //         isWaiter: true);
                //   }).toList(),
                // ),
              ],
            );
    });
  }

  Widget readyTab() {
    return GetBuilder<KdsController>(builder: (kdsController) {
      return Container(
        color: Color(0xFFF6F6F6),
        padding: EdgeInsets.only(right: 10),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();

                await _dropdownContoller.showTooltip();
              },
              child: SuperTooltip(
                borderRadius: 2,

                // elevation: 1,
                // hasShadow: false,
                borderColor: Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
                showBarrier: true,
                controller: _dropdownContoller,
                popupDirection: TooltipDirection.down,
                backgroundColor: Colors.white,
                right: Get.width * 0.65,
                left: 0,

                constraints: BoxConstraints(
                    maxHeight: 40, minWidth: 0, minHeight: 10, maxWidth: 100),
                arrowTipDistance: 10,
                arrowBaseWidth: 2.0,
                arrowLength: 0,
                // borderWidth: 2.0,

                // showCloseButton: ShowCloseButton.none,
                touchThroughAreaShape: ClipAreaShape.rectangle,
                touchThroughAreaCornerRadius: 5,
                barrierColor: Colors.transparent,
                content: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: orderTypeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 20,
                            top: 25,
                            bottom: index == orderTypeList.length - 1 ? 25 : 0),
                        child: InkWell(
                          onTap: () async {
                            if (orderTypeList[index] == 'Dine In') {
                              kdsController.setMainMenuIndex(0);
                            } else if (orderTypeList[index] == 'Take Away') {
                              kdsController.setMainMenuIndex(1);
                            } else if (orderTypeList[index] == 'Delivery') {
                              kdsController.setMainMenuIndex(2);
                            } else if (orderTypeList[index] == 'Room') {
                              kdsController.setMainMenuIndex(4);
                            } else {
                              kdsController.setMainMenuIndex(3);
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                            await _dropdownContoller.hideTooltip();
                          },
                          child: Text(
                            orderTypeList[index],
                            style: poppinsMedium.copyWith(
                                fontSize: 11, color: Colors.black),
                          ),
                        ),
                      );
                    }),
                child: Container(
                  height: 50,
                  // height: 30,
                  width: Get.width * 0.3,
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    color: ColorTheme.dineInDropdownYello,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .delivery !=
                                  true
                              ? 'Dine In'
                              : kdsController.selectedMainMenu == 0
                                  ? 'Dine In'
                                  : kdsController.selectedMainMenu == 1
                                      ? 'Take Away'
                                      : kdsController.selectedMainMenu == 2
                                          ? 'Delivery'
                                          : kdsController.selectedMainMenu == 4
                                              ? 'Room'
                                              : 'All',
                          maxLines: 1,
                          style: poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .defOrdStatus !=
                5)
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    // if (Get.find<AuthController>()
                    //     .profileModel
                    //     .role
                    //     .contains('order')) {
                    searchController.clear();
                    paidController.clear();
                    kdsController.setSubMenuIndex(1);
                    Get.find<BuffetController>().update();

                    // }
                  },
                  child: SizedBox(
                    width: Get.width * 0.3,
                    child: Container(
                      // margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //     color: kdsController.selectedSubMenu == 1
                        //         ? Colors.transparent
                        //         : Theme.of(context).hintColor),
                        color: kdsController.selectedSubMenu == 1
                            ? ColorTheme.appColor
                            : Color(0xFFF6F6F6),

                        // border:
                        //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                        // borderRadius: BorderRadius.circular(
                        //     Dimensions.RADIUS_DEFAULT)
                      ),
                      child: Center(
                        child: Text(
                          'Ready to serve',
                          style: poppinsMedium.copyWith(
                              fontSize: 11,
                              color: kdsController.selectedSubMenu == 1
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .defOrdStatus !=
                5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 1,
                  // height: 8,
                  height: 20,
                  color: Color(0xFFE6E6E6),
                ),
              ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  searchController.clear();
                  paidController.clear();
                  kdsController.setSubMenuIndex(2);
                  Get.find<BuffetController>().update();
                },
                child: SizedBox(
                  width: Get.width * 0.3,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 2
                          ? ColorTheme.appColor
                          : Color(0xFFF6F6F6),
                    ),
                    child: Center(
                      child: Text(
                        'Running Orders',
                        style: poppinsMedium.copyWith(
                            fontSize: 11,
                            color: kdsController.selectedSubMenu == 2
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .defOrdStatus ==
                5)
              SizedBox(width: 20)
          ],
        ),
      );
    });
  }

  Widget foodStatusTabAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: GetBuilder<KdsController>(builder: (kdsController) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MediaQuery.of(context).size.width > 1600
                ? SizedBox(
                    child: Image.asset(
                      logoHelper.appLogo!,
                      width: Get.width * 0.11,
                    ),
                  )
                : SizedBox(
                    child: Image.asset(
                      logoHelper.appLogo!,
                      width: Get.width * 0.2,
                      // height: Get.height / 10.72,
                    ),
                  ),
            GetBuilder<KdsController>(builder: (kdsController) {
              return Container(
                width: Get.width * 0.55,
                color: Color(0xFFF6F6F6),
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();

                        await _dropdownContoller.showTooltip();
                      },
                      child: SuperTooltip(
                        borderRadius: 2,

                        // elevation: 1,
                        // hasShadow: false,
                        borderColor: Colors.white,
                        shadowColor: Colors.black.withOpacity(0.1),
                        showBarrier: true,
                        controller: _dropdownContoller,
                        popupDirection: TooltipDirection.down,
                        backgroundColor: Colors.white,
                        right: Get.width * 0.5 + 20,
                        left: Get.width * 0.3,

                        constraints: BoxConstraints(
                            maxHeight: 40,
                            minWidth: 0,
                            minHeight: 10,
                            maxWidth: 100),
                        arrowTipDistance: 10,
                        arrowBaseWidth: 2.0,
                        arrowLength: 0,
                        // borderWidth: 2.0,

                        // showCloseButton: ShowCloseButton.none,
                        touchThroughAreaShape: ClipAreaShape.rectangle,
                        touchThroughAreaCornerRadius: 5,
                        barrierColor: Colors.transparent,
                        content: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: orderTypeList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 20,
                                    top: 25,
                                    bottom: index == orderTypeList.length - 1
                                        ? 25
                                        : 0),
                                child: InkWell(
                                  onTap: () async {
                                    if (orderTypeList[index] == 'Dine In') {
                                      kdsController.setMainMenuIndex(0);
                                    } else if (orderTypeList[index] ==
                                        'Take Away') {
                                      kdsController.setMainMenuIndex(1);
                                    } else if (orderTypeList[index] ==
                                        'Delivery') {
                                      kdsController.setMainMenuIndex(2);
                                    } else if (orderTypeList[index] == 'Room') {
                                      kdsController.setMainMenuIndex(4);
                                    } else {
                                      kdsController.setMainMenuIndex(3);
                                    }
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    await _dropdownContoller.hideTooltip();
                                  },
                                  child: Text(
                                    orderTypeList[index],
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13, color: Colors.black),
                                  ),
                                ),
                              );
                            }),
                        child: Container(
                          height: 50,
                          // height: 30,
                          width: Get.width * 0.15,
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL),
                          decoration: BoxDecoration(
                            color: ColorTheme.dineInDropdownYello,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .delivery !=
                                          true
                                      ? 'Dine In'
                                      : kdsController.selectedMainMenu == 0
                                          ? 'Dine In'
                                          : kdsController.selectedMainMenu == 1
                                              ? 'Take Away'
                                              : kdsController
                                                          .selectedMainMenu ==
                                                      2
                                                  ? 'Delivery'
                                                  : kdsController
                                                              .selectedMainMenu ==
                                                          4
                                                      ? 'Room'
                                                      : 'All',
                                  maxLines: 1,
                                  style: poppinsMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .defOrdStatus !=
                        5)
                      Expanded(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();

                            // if (Get.find<AuthController>()
                            //     .profileModel
                            //     .role
                            //     .contains('order')) {
                            searchController.clear();
                            paidController.clear();
                            kdsController.setSubMenuIndex(1);
                            Get.find<BuffetController>().update();

                            // }
                          },
                          child: SizedBox(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: kdsController.selectedSubMenu == 1
                                    ? ColorTheme.appColor
                                    : Color(0xFFF6F6F6),
                              ),
                              child: Center(
                                child: Text(
                                  'Ready to serve',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13,
                                      color: kdsController.selectedSubMenu == 1
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .defOrdStatus !=
                        5)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 1,
                          // height: 8,
                          height: 20,
                          color: Color(0xFFE6E6E6),
                        ),
                      ),
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();

                          searchController.clear();
                          paidController.clear();
                          kdsController.setSubMenuIndex(2);
                          Get.find<BuffetController>().update();
                        },
                        child: SizedBox(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: kdsController.selectedSubMenu == 2
                                  ? ColorTheme.appColor
                                  : Color(0xFFF6F6F6),
                            ),
                            child: Center(
                              child: Text(
                                'Running Orders',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13,
                                    color: kdsController.selectedSubMenu == 2
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .defOrdStatus ==
                        5)
                      SizedBox(width: 20)
                  ],
                ),
              );
            }),
          ],
        );
      }),
    );
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

      await Get.find<BuffetController>().getOrderDetailFromSocket(
        foodStatus: currentOrder.orderType == 'update-food-status' || currentOrder.orderType == 'update-item-status' ||
                currentOrder.orderType == 'update-priority-food-status'
            ? '${currentOrder.orderOthervalue}'
            : '0',
        type: currentOrder.orderType!,
        orderId: '${currentOrder.orderId}',
        socketJson: currentOrder.orderType == 'new-order'
            ? currentOrder.newOrderJson
            : null,
      );
      if (Get.find<AuthController>().profileModel!.role!.contains('Buffet')) {
        await Get.find<KdsController>().getTotalKdsOrder();
      }
      // if (currentOrder.orderType == 'new-order' &&
      //     Get.find<AuthController>().profileModel.empId.toString() ==
      //         Get.find<KdsController>()
      //             .getWaiterOrderListResponse
      //             .orders
      //             .last
      //             .waiterId
      //             .toString() &&
      //     Get.find<KdsController>()
      //             .getWaiterOrderListResponse
      //             .orders
      //             .last
      //             .orderDetails
      //             .length ==
      //         1 &&
      //     Get.find<KdsController>()
      //             .getWaiterOrderListResponse
      //             .orders
      //             .last
      //             .orderDetails
      //             .first
      //             .foodDetails
      //             .name
      //             .toUpperCase() ==
      //         'CHECK IN') {
      //   SchedulerBinding.instance?.addPostFrameCallback((_) {
      //     _scrollController.animateTo(
      //         _scrollController.position.maxScrollExtent,
      //         duration: const Duration(milliseconds: 1),
      //         curve: Curves.fastOutSlowIn);
      //   });
      // }

      await Future.delayed(Duration(seconds: 3)); // Simulate async processing
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
        orderId: orderId!,
        orderType: orderType!,
        orderOthervalue: otherValue ?? '',
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  checkRestaurantIsOpen() async {
    Get.find<CartController>().clearCartList();

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
    } else if (todaySchedule != null) {
      bool isRestaurantOpen = DateConverter.isAvailable(
          todaySchedule.openingTime!, todaySchedule.closingTime!);
      // print(isRestaurantOpen);
      if (isRestaurantOpen) {
        // showCustomSnackBar('Restaurant is open', isError: false);

        MediaQuery.of(context).size.shortestSide > 570
            ? await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BuffetTabletPosScreen(editOrder: null)))
            : await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BuffetWaiterPosScreen(editOrder: null)));
        // var data = await Get.toNamed(RouteHelper.getWaiterPosRoute(null));
      } else {
        if (previousDaySchedule != null) {
          var subtractDate = currentDate.subtract(Duration(days: 1));
          int closeHour =
              int.parse(previousDaySchedule.closingTime!.split(':').first);
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
              MediaQuery.of(context).size.shortestSide > 570
                  ? await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TabletPosScreen(editOrder: null)))
                  : await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WaiterPosScreen(editOrder: null)));
            } else {
              showErrorToast('Restaurant is closed');
            }
          } else {
            showErrorToast('Restaurant is closed');
          }
        } else {
          showErrorToast('Restaurant is closed');
        }
      }
    } else {
      if (previousDaySchedule != null) {
        var subtractDate = currentDate.subtract(Duration(days: 1));
        int closeHour =
            int.parse(previousDaySchedule.closingTime!.split(':').first);
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
          if (isbefore && isAfter) {
            // showErrorToast('Restaurant is open previous day',
            //     isError: false);

            MediaQuery.of(context).size.shortestSide > 570
                ? await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TabletPosScreen(editOrder: null)))
                : await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            WaiterPosScreen(editOrder: null)));
          } else {
            showErrorToast('Restaurant is closed');
          }
        } else {
          showErrorToast('Restaurant is closed');
        }
      }
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
                  message.notification!.android!.sound),
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
          }
          print('.................. register');
        } catch (e) {
          print(e.toString());
        }
      });
      //  await checkForInitialMessage();
    } else {}
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
          if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .settelmentReport ==
              'Yes')
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
                        if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .settelmentReport ==
                            'Yes')
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
                                .restaurants!
                                .first
                                .settelmentReport ==
                            'Yes')
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
                // Padding(
                //   padding: const EdgeInsets.only(top: 10),
                //   child: InkWell(
                //     onTap: () async {
                //       scaffoldKey.currentState?.closeDrawer();
                //       _subscriptionBtStatus?.cancel();
                //       FocusManager.instance.primaryFocus?.unfocus();

                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (builder) => ScheduleOrder()));
                //     },
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 15, top: 0),
                //         child: Text(
                //           'Schedule Orders',
                //           style: poppinsMedium.copyWith(
                //               fontSize: 13, color: ColorTheme.hintText),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () async {
                      scaffoldKey.currentState?.closeDrawer();
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
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('Loyalty'))
                  10.height,
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('Loyalty'))
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => LoyaltyProgramScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Loyalty Management',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                  ),
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('coupon'))
                  10.height,
                if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('coupon'))
                  InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      scaffoldKey.currentState?.closeDrawer();

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CouponManagementScreen()));
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 0),
                        child: Text(
                          'Coupon Management',
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
                  10.height,
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

}

class OrderIdType {
  String? orderId;
  String? orderType;
  String? orderOthervalue;
  dynamic newOrderJson;

  OrderIdType(
      {this.orderId, this.orderType, this.orderOthervalue, this.newOrderJson});
}
