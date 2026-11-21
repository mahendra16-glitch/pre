// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:dotted_line/dotted_line.dart';
// import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
// import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
// import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
// import 'package:mygenie_restaurant/view/screens/KDS/home/kds_home_screen.dart';
// import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
// import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
// import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
// import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_inventory.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
// import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart' hide OrderIdType;
// import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
// import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/coupon.dart';

// import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_rate.dart';
// import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
// import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/redemption_rate.dart';
// import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
// import 'package:mygenie_restaurant/view/screens/revenue_report/revenue_report.dart';
// import 'package:mygenie_restaurant/view/screens/settelment_report/settelment_report.dart';
// import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/usb_get_printer_ip.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/home/paid_order/view_paid_orders.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/room_managment/room_orders.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/home/widget/order_content_widget.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_orders.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'
//     as n;
// import 'package:mygenie_restaurant/controller/cart_controller.dart';
// import 'package:mygenie_restaurant/controller/loader_contoller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
// import 'package:mygenie_restaurant/helper/date_converter.dart';
// import 'package:mygenie_restaurant/helper/logo_helper.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/helper/printer_config.dart';
// import 'package:mygenie_restaurant/main.dart';
// import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/check_in/check_in_tablet.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/order_list/tablet_order_list.dart';
// import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:intl/intl.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// // import 'package:mygenie_restaurant/helper/notification_helper.dart';
// import 'package:mygenie_restaurant/helper/route_helper.dart';
// import 'package:mygenie_restaurant/util/app_constants.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
// import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
// import 'package:image/image.dart' as prefix;
// import 'package:flutter/material.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:printing/printing.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:upgrader/upgrader.dart';

// import '../../../../../controller/product_controller.dart';
// import '../../../../../controller/report_summary_controller.dart';
// import '../../../../../controller/table_controller.dart';
// import '../../../../../util/print_byte_convert.dart';
// import '../../../report_summary/report_summary.dart';
// import '../../../swiggy_zomato/date_wise_orderlist.dart';
// import '../../pos_view_mobile/swiggy_zomatao_ui/swiggy_zomato_ui.dart';

// class TabletWaiterHomeScreen extends StatefulWidget {
//   @override
//   State<TabletWaiterHomeScreen> createState() => _TabletWaiterHomeScreenState();
// }

// class _TabletWaiterHomeScreenState extends State<TabletWaiterHomeScreen> {
//   Timer? timer;
//   FlutterTts flutterTts = FlutterTts();
//   List<List<OrderDetails>> cartProductList = [];
//   List<List<OrderDetails>> failedCartProductList = [];
//   List<bool> skipFailedList = [];
//   bool isFailedPrint = false;
//   PackageInfo? packageInfo;
//   List<String> orderTypeList = [
//     'All',
//     'Dine In',
//     // 'Take Away',
//     // 'Delivery',
//     // 'Room'
//   ];
//   int splitCurrentPrintIndex = 0;
//   List<bool> isSplitSelectPrinterList = [];
//   List<bool> isSplitPrinterProccessingList = [];
//   List<bool> isSplitPrintedList = [];
//   FirebaseMessaging? _messaging;
//   bool isSkipFirstTimeOrder = false;
//   bool isSkipSecondTimeOrder = false;

//   var scaffoldKey = GlobalKey<ScaffoldState>();
//   Future<void> initData() async {
//     Get.find<KdsController>().resetSplitBill();
//     await Get.find<TableController>().getTableListFromLocally();
//     await Get.find<KdsController>().getWaiterPOSOrderList();
//     if (Get.find<AuthController>()
//             .profileModel
//             ?.restaurants
//             ?.first
//             .defOrdStatus ==
//         5) {
//       Get.find<KdsController>().setSubMenuIndex(2);
//     }
//     if (Get.find<AuthController>().profileModel?.restaurants?.first.logoPath !=
//         '') {
//       final response = await http.get(Uri.parse(Get.find<AuthController>()
//           .profileModel!
//           .restaurants!
//           .first
//           .logoPath!));
//       if (response.statusCode == 200) {
//         // Decode the image data
//         final image = prefix.decodeImage(response.bodyBytes);
//         if (image != null) {
//           // Resize the image to fit the 58mm printer's width (around 240px)
//           logoHelper.logoUrlPrint =
//               prefix.copyResize(image, width: 240); // Adjusted for 58mm
//         }
//       }
//     }
//     packageInfo = await PackageInfo.fromPlatform();
//     if (mounted) setState(() {});
//   }

//   ScrollController _scrollController = ScrollController();

//   PrinterManager _printerManager = PrinterManager.instance;
//   int currentPrintIndex = 0;
//   bool isConnect = true;
//   StreamSubscription<BTStatus>? _subscriptionBtStatus;
//   StreamSubscription<BTStatus>? _singleSplitBleStatus;

//   List<int>? pendingTask;
//   TextEditingController searchController = TextEditingController();
//   TextEditingController paidController = TextEditingController();
//   int? tableIndex;
//   TextEditingController searchTable = TextEditingController();
//   final _dropdownContoller = SuperTooltipController();
//   bool isProcessingOrderQueue = false;
//   List<OrderIdType> orderIdQueue = [];
//   List<OrderList> orderQueue = [];
//   bool isProcessingOrder = false;

//   @override
//   void initState() {
//     if (Get.find<AuthController>().profileModel!.restaurants!.first.delivery!) {
//       if (!orderTypeList.contains('Delivery')) orderTypeList.add('Delivery');
//       if (!orderTypeList.contains('Take Away')) orderTypeList.add('Take Away');
//     }
//     if (Get.find<AuthController>().profileModel!.restaurants!.first.showRoom ==
//         'Yes') {
//       if (!orderTypeList.contains('Room')) orderTypeList.add('Room');
//     }
//     Get.find<KdsController>().orderIdFromSocket = '';
//     // listenBlutooth();
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('notification_icon');
//     var initializationSettingsIOS = DarwinInitializationSettings();
//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: onSelectNotification);
//     setupInteractedMessage();
//     registerNotification();

//     // checkForInitialMessage();
//     initfirebase();
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//     initCallApi();
//     connectToSocketIO();
//     timer = Timer.periodic(
//         Duration(minutes: 1), (Timer t) => Get.find<KdsController>().update());
//     super.initState();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     _subscriptionBtStatus?.cancel();
//     _singleSplitBleStatus?.cancel();

//     socket?.dispose();
//     super.dispose();
//   }

//   Socket? socket;
//   initCallApi() async {
//     if (Get.find<AuthController>()
//             .profileModel!
//             .restaurants!
//             .first
//             .isShowPopularCategory ==
//         'Yes') await Get.find<ProductController>().getPopularFoodList();
//     await initData();
//   }

//   void connectToSocketIO() {
//     try {
//       // Configure and initialize the socket connection
//       socket = io(
//         AppConstants.SOCKET_BASE_URL,
//         OptionBuilder()
//             // .setPath('/socket') // Same as path in your JS code
//             .setTransports(['websocket']) // Important for WebSocket only
//             .enableForceNew() // Optional: always creates a new connection
//             .enableReconnection()
//             .enableAutoConnect() // Optional: auto reconnect
//             .build(),
//       );

//       // Connect to the WebSocket
//       if (!socket!.connected) {
//         socket?.connect();
//       }

//       // Listen for the 'new_order' event with a dynamic restaurant ID
//       String restaurantId = Get.find<AuthController>()
//           .profileModel!
//           .restaurants![0]
//           .id
//           .toString();
//       socket?.on('new_order_$restaurantId', (data) async {
//         print('Received socket data: $data');

//         // Check if the restaurant ID in the data matches the current restaurant ID
//         if (restaurantId == '${data[2]}') {
//           // Handle various order-related events
//           if (data[0] == 'update-order' ||
//               data[0] == 'new-order' ||
//               data[0] == 'scan-new-order' ||
//               data[0] == 'update-food-status' ||
//               data[0] == 'update-order-status') {
//             checkQueueProcessFromSocket(
//               orderType: data[0],
//               orderId: '${data[1]}',
//               otherValue: data[0] == 'update-food-status' ? '${data[3]}' : '0',
//               newOrderJson: data[0] == 'new-order' ? data[4] : null,
//             );
//           }
//         }
//       });
//       socket?.on('update_table_$restaurantId', (data) async {
//         print('Received socket table data: $data');

//         if (restaurantId == '${data[2]}') {
//           if (data[1].toString() != '0') {
//             await Get.find<TableController>().setValueOfTableFromSocket(
//                 tableId: data[1].toString(),
//                 value: data[3] == 'engage' ? 'Yes' : 'No');
//           }
//         }
//       });

//       // Handle the 'disconnect' event
//       socket?.on('disconnect', (reason) {
//         print('Socket disconnected: $reason');

//         // Attempt to reconnect by reinitializing the socket connection
//         socket = io(
//           AppConstants.SOCKET_BASE_URL,
//           OptionBuilder()
//               // .setPath('/socket') // Same as path in your JS code
//               .setTransports(['websocket']) // Important for WebSocket only
//               .enableForceNew() // Optional: always creates a new connection
//               .enableReconnection()
//               .enableAutoConnect() // Optional: auto reconnect
//               .build(),
//         );
//       });
//     } catch (e) {
//       // Log any errors that occur during socket initialization or connection
//       print('Socket connection error: ${e.toString()}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(Get.width);
//     return UpgradeAlert(
//       upgrader: Upgrader(
//         // showIgnore: false,
//         // showLater: false,
//         durationUntilAlertAgain: Duration(seconds: 5),
//       ),
//       child: SafeArea(
//         child: Scaffold(
//           appBar: AppBar(
//             toolbarHeight: Get.height / 10.72,
//             backgroundColor: Theme.of(context).cardColor,
//             leading: Padding(
//               padding: EdgeInsets.only(
//                   top: Dimensions.PADDING_SIZE_DEFAULT,
//                   left: Dimensions.PADDING_SIZE_SMALL),
//               child: IconButton(
//                 icon: Image.asset(Images.menu),
//                 onPressed: () async {
//                   searchController.clear();
//                   paidController.clear();
//                   await _singleSplitBleStatus?.cancel();

//                   scaffoldKey.currentState?.openDrawer();
//                 },
//               ),
//             ),
//             titleSpacing: 0,
//             elevation: 0,
//             centerTitle: true,
//             title:
//                 //  Get.find<AuthController>()
//                 //                 .profileModel
//                 //                 .restaurants[0]
//                 //                 .isDelivery ==
//                 //             'true' &&
//                 //         Get.find<AuthController>()
//                 //             .profileModel
//                 //             .role
//                 //             .contains('order')
//                 //     ?
//                 //  orderTypeTab(),
//                 // :
//                 foodStatusTabAppBar(),
//             actions: [
//               if (Get.find<AuthController>()
//                   .profileModel!
//                   .role!
//                   .contains('order'))
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL, right: 15),
//                   child: InkWell(
//                     radius: 20,
//                     onTap: () {
//                       FocusManager.instance.primaryFocus?.unfocus();

//                       searchController.clear();
//                       paidController.clear();
//                       Get.find<KdsController>().resetSplitBill();

//                       checkRestaurantIsOpen();
//                     },
//                     child: Container(
//                       // color: Colors.green,
//                       width: 80,
//                       padding: EdgeInsets.only(left: 35, top: 10, bottom: 10),
//                       child: Container(
//                         height: 30,
//                         width: 30,
//                         decoration: BoxDecoration(
//                             color: ColorTheme.appColor, shape: BoxShape.circle),
//                         child: Center(
//                             child:
//                                 Icon(Icons.add, color: Colors.white, size: 20)),
//                       ),
//                     ),
//                   ),
//                 ),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('order') &&
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants![0]
//                           .isDelivery !=
//                       'true')
//                 SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
//             ],
//           ),
//           drawer: Drawer(
//             backgroundColor: Color(0xFFF8F8F8),
//             child: SafeArea(
//               child: ListView(
//                 // padding: EdgeInsets.zero,

//                 children: <Widget>[
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 20, left: 15),
//                       child: Image.asset(
//                         Images.brand_logo,
//                         height: Get.height * 0.1,
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 7),
//                       child: Text(
//                         '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 15, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                   if (Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('bill') &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .showRoom ==
//                           'Yes')
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         expandedAlignment: Alignment.centerLeft,
//                         initiallyExpanded: true,
//                         iconColor: ColorTheme.hintText,
//                         title: Text(
//                           'Rooms',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 16, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState?.closeDrawer();
//                               await _subscriptionBtStatus?.cancel();
//                               await _singleSplitBleStatus?.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               var data = await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => CheckInTablet()));
//                               if (data != null && data) {
//                                 Get.find<KdsController>().setSubMenuIndex(2);
//                               }
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Check In',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // if (Get.find<AuthController>()
//                   //         .profileModel
//                   //         .role
//                   //         .contains('revenue_report') ||
//                   //     Get.find<AuthController>()
//                   //         .profileModel
//                   //         .role
//                   //         .contains('sattle_report'))

//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('report'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Report',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 16, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('revenue_report'))
//                             InkWell(
//                               onTap: () async {
//                                 scaffoldKey.currentState!.closeDrawer();
//                                 _subscriptionBtStatus!.cancel();
//                                 FocusManager.instance.primaryFocus?.unfocus();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) => RevenueReport()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Text(
//                                     'Revenue Report',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 15,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('sattle_report'))
//                             InkWell(
//                               onTap: () async {
//                                 scaffoldKey.currentState!.closeDrawer();
//                                 _subscriptionBtStatus!.cancel();
//                                 FocusManager.instance.primaryFocus?.unfocus();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             SettlementReport()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 15),
//                                   child: Text(
//                                     'Settlement Report',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 15,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           InkWell(
//                             onTap: () async {
//                               FocusManager.instance.primaryFocus?.unfocus();
//                               scaffoldKey.currentState!.closeDrawer();
//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => PrintReport()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Daily report',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // if (Get.find<AuthController>()
//                           //     .profileModel!
//                           //     .role!
//                           //     .contains('report_summery'))
//                           //   InkWell(
//                           //     onTap: () async {
//                           //       FocusManager.instance.primaryFocus?.unfocus();
//                           //       scaffoldKey.currentState!.closeDrawer();

//                           //       await Navigator.push(
//                           //           context,
//                           //           MaterialPageRoute(
//                           //               builder: (builder) =>
//                           //                   ReportSummeryPage()));
//                           //     },
//                           //     child: Align(
//                           //       alignment: Alignment.centerLeft,
//                           //       child: Padding(
//                           //         padding:
//                           //             const EdgeInsets.only(left: 15, top: 15),
//                           //         child: Text(
//                           //           'Report Summary',
//                           //           style: poppinsMedium.copyWith(
//                           //               fontSize: 15,
//                           //               color: ColorTheme.hintText),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   Theme(
//                     data: Theme.of(context)
//                         .copyWith(dividerColor: Colors.transparent),
//                     child: ExpansionTile(
//                       iconColor: ColorTheme.hintText,
//                       initiallyExpanded: true,
//                       expandedAlignment: Alignment.centerLeft,
//                       title: Text(
//                         'Orders',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 16, color: ColorTheme.hintText),
//                       ),
//                       children: <Widget>[
//                         InkWell(
//                           onTap: () async {
//                             scaffoldKey.currentState?.closeDrawer();
//                             _subscriptionBtStatus?.cancel();
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (builder) => ViewPaidOrders()));
//                           },
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 0),
//                               child: Text(
//                                 'Paid Orders',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 15, color: ColorTheme.hintText),
//                               ),
//                             ),
//                           ),
//                         ),
//                         if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .restaurants!
//                                 .first
//                                 .showRoom ==
//                             'Yes')
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState?.closeDrawer();
//                               _subscriptionBtStatus?.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => RoomOrders()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Room Orders',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .restaurants!
//                                 .first
//                                 .payTab ==
//                             'Yes')
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState?.closeDrawer();
//                               _subscriptionBtStatus?.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => TabOrders()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Credit Orders',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (Get.find<AuthController>()
//                             .profileModel!
//                             .role!
//                             .contains('aggregator'))
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState?.closeDrawer();
//                               _subscriptionBtStatus?.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => SwiggyZomatoUI()));
//                               // await Navigator.push(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //         builder: (builder) => SwiggyOrders()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Swiggy Orders',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (Get.find<AuthController>()
//                             .profileModel!
//                             .role!
//                             .contains('aggregator'))
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState?.closeDrawer();
//                               _subscriptionBtStatus?.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) =>
//                                           DateWiseSwiggyOrders()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Completed Swiggy Orders',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .role!
//                                 .contains('bill') &&
//                             Get.find<AuthController>()
//                                     .profileModel!
//                                     .restaurants!
//                                     .first
//                                     .payTab ==
//                                 'Yes')
//                           InkWell(
//                             onTap: () {
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               scaffoldKey.currentState?.closeDrawer();
//                               _subscriptionBtStatus?.cancel();
//                               Get.toNamed(RouteHelper.getTapManagementRoute());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 15),
//                                 child: Text(
//                                   'Credit Management',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 15, left: 15),
//                           child: DottedLine(
//                             direction: Axis.horizontal,
//                             alignment: WrapAlignment.center,
//                             lineThickness: 1.0,
//                             dashLength: 2.5,
//                             dashColor: ColorTheme.hintText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('menu'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Menu Management',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();
//                               Get.find<ExpenseManagementController>()
//                                   .tabValue
//                                   .value = 0;
//                               await Get.to(() => MenuHomeScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Manage Food',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => CategoriesScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Categories',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => AddonsScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Addons',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('expence'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Expense',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();
//                               Get.find<ExpenseManagementController>()
//                                   .tabValue
//                                   .value = 0;
//                               await Get.to(() => ExpenseManagementScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Manage Expenses',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();
//                               Get.find<ExpenseManagementController>()
//                                   .tabValue
//                                   .value = 1;

//                               await Get.to(() => ExpenseManagementScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Add Stock',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('inventory'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Inventory Management',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => CurrentStocksScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Manage Stocks',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => ManageInventory());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Manage Inventory',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => ManageVendor());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Manage Vendor',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => AddIngredientsScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Master Ingredients',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => PurchaseReportScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Purchase Report',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           15.height,
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();

//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Get.to(() => RecipesListScreen());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Recipes List',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('sattle_report'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Settlement',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               scaffoldKey.currentState!.closeDrawer();
//                               // _subscriptionBtStatus!.cancel();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) =>
//                                           SettlementScreen()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 0),
//                                 child: Text(
//                                   'Settlement',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('report_summery') ||
//                       Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('waiter_revenue_report'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Report Summary',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('report_summery'))
//                             InkWell(
//                               onTap: () async {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 scaffoldKey.currentState?.closeDrawer();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             ReportSummeryPage()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 0),
//                                   child: Text(
//                                     'Report Summary',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('waiter_revenue_report'))
//                             InkWell(
//                               onTap: () async {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 scaffoldKey.currentState?.closeDrawer();
//                                 // if (Get.find<AuthController>()
//                                 //     .profileModel!
//                                 //     .role!
//                                 //     .contains('waiter_revenue_report'))
//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             DailyWaiterSalesDetailsReport()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 0),
//                                   child: Text(
//                                     'Report Summary(W)',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                       .profileModel!
//                       .role!
//                       .contains('employee'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Employee Management',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () async {
//                               FocusManager.instance.primaryFocus?.unfocus();
//                               scaffoldKey.currentState?.closeDrawer();

//                               await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) =>
//                                           EmployeeMgmtScreen()));
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, top: 10),
//                                 child: Text(
//                                   'Employee Management',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('coupon') ||
//                       Get.find<AuthController>()
//                           .profileModel!
//                           .role!
//                           .contains('Loyalty'))
//                     Theme(
//                       data: Theme.of(context)
//                           .copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         iconColor: ColorTheme.hintText,
//                         initiallyExpanded: true,
//                         expandedAlignment: Alignment.centerLeft,
//                         title: Text(
//                           'Resturant Configuration',
//                           style: poppinsMedium.copyWith(
//                               fontSize: 14, color: ColorTheme.hintText),
//                         ),
//                         children: <Widget>[
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('Loyalty'))
//                             InkWell(
//                               onTap: () async {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 scaffoldKey.currentState?.closeDrawer();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             LoyaltyProgramScreen()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 10),
//                                   child: Text(
//                                     'Conversion Rate',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('Loyalty'))
//                             InkWell(
//                               onTap: () async {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 scaffoldKey.currentState?.closeDrawer();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             LoyaltyProgramScreen()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 10),
//                                   child: Text(
//                                     'Redemption Rate',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (Get.find<AuthController>()
//                               .profileModel!
//                               .role!
//                               .contains('coupon'))
//                             InkWell(
//                               onTap: () async {
//                                 FocusManager.instance.primaryFocus?.unfocus();
//                                 scaffoldKey.currentState?.closeDrawer();

//                                 await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (builder) =>
//                                             CouponManagementScreen()));
//                               },
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(left: 15, top: 10),
//                                   child: Text(
//                                     'Coupon',
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13,
//                                         color: ColorTheme.hintText),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 15, left: 15),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               alignment: WrapAlignment.center,
//                               lineThickness: 1.0,
//                               dashLength: 2.5,
//                               dashColor: ColorTheme.hintText,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   Theme(
//                     data: Theme.of(context)
//                         .copyWith(dividerColor: Colors.transparent),
//                     child: ExpansionTile(
//                       iconColor: ColorTheme.hintText,
//                       initiallyExpanded: true,
//                       expandedAlignment: Alignment.centerLeft,
//                       title: Text(
//                         'My Profile',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 16, color: ColorTheme.hintText),
//                       ),
//                       children: <Widget>[
//                         if (GetPlatform.isIOS)
//                           InkWell(
//                             onTap: () {
//                               scaffoldKey.currentState?.closeDrawer();
//                               FocusManager.instance.primaryFocus?.unfocus();

//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (builder) => GetPrinterIp()));
//                               // Get.toNamed(RouteHelper.getTapManagementRoute());
//                             },
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   'Printer Configuration',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 15, color: ColorTheme.hintText),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         InkWell(
//                           onTap: () {
//                             scaffoldKey.currentState?.closeDrawer();
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             String logo = '';
//                             if (!Get.find<AuthController>()
//                                     .profileModel!
//                                     .role!
//                                     .contains('order') &&
//                                 Get.find<AuthController>()
//                                     .profileModel!
//                                     .role!
//                                     .contains('bill')) {
//                               logo = Images.ic_cashier_app_logo;
//                             } else if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .role!
//                                 .contains('report')) {
//                               logo = Images.ic_owner_app_logo;
//                             } else if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .role!
//                                 .contains('Manager')) {
//                               logo = Images.ic_manager_app_logo;
//                             } else {
//                               logo = Images.ic_waiter_app_logo;
//                             }

//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: ((context) =>
//                                         EmployeeResetPassword(
//                                           resetToken: Get.find<AuthController>()
//                                               .getUserToken(),
//                                           email: Get.find<AuthController>()
//                                               .profileModel!
//                                               .empEmail!,
//                                           image: logo,
//                                           password: '',
//                                           fromPasswordChange: true,
//                                         ))));

//                             // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
//                             //     Get.find<AuthController>().profileModel.empEmail,
//                             //     Get.find<AuthController>().getUserToken(),
//                             //     'password-change'));
//                             // Get.toNamed(RouteHelper.getTapManagementRoute());
//                           },
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: 15, top: 15),
//                               child: Text(
//                                 'Reset Password',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 15, color: ColorTheme.hintText),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // if (GetPlatform.isAndroid)
//                         //   InkWell(
//                         //     onTap: () {
//                         //       scaffoldKey.currentState.closeDrawer();
//                         //       FocusManager.instance.primaryFocus?.unfocus();

//                         //       Navigator.push(
//                         //           context,
//                         //           MaterialPageRoute(
//                         //               builder: (builder) => UsbGetPrinterIp()));
//                         //       // Get.toNamed(RouteHelper.getTapManagementRoute());
//                         //     },
//                         //     child: Align(
//                         //       alignment: Alignment.centerLeft,
//                         //       child: Padding(
//                         //         padding:
//                         //             const EdgeInsets.only(left: 15, top: 10),
//                         //         child: Text(
//                         //           'Usb Printer Configuration',
//                         //           style: poppinsMedium.copyWith(
//                         //               fontSize: 13, color: ColorTheme.hintText),
//                         //         ),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // InkWell(
//                         //   onTap: () {
//                         //     Get.to(ConversionRateScreen());
//                         //   },
//                         //   child: Align(
//                         //     alignment: Alignment.centerLeft,
//                         //     child: Padding(
//                         //       padding: EdgeInsets.only(left: 15, top: 15),
//                         //       child: Text(
//                         //         'Conversion',
//                         //         style: poppinsMedium.copyWith(
//                         //             fontSize: 15, color: ColorTheme.hintText),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         // InkWell(
//                         //   onTap: () {
//                         //     Get.to(RedemptionRuleScreen());
//                         //   },
//                         //   child: Align(
//                         //     alignment: Alignment.centerLeft,
//                         //     child: Padding(
//                         //       padding: EdgeInsets.only(left: 15, top: 15),
//                         //       child: Text(
//                         //         'Redemption',
//                         //         style: poppinsMedium.copyWith(
//                         //             fontSize: 15, color: ColorTheme.hintText),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         // InkWell(
//                         //   onTap: () {
//                         //     Get.to(DiscountCouponScreen());
//                         //   },
//                         //   child: Align(
//                         //     alignment: Alignment.centerLeft,
//                         //     child: Padding(
//                         //       padding: EdgeInsets.only(left: 15, top: 15),
//                         //       child: Text(
//                         //         'coupon',
//                         //         style: poppinsMedium.copyWith(
//                         //             fontSize: 15, color: ColorTheme.hintText),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         InkWell(
//                           onTap: () {
//                             Get.to(OrderManagementScreen());
//                           },
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: 15, top: 15),
//                               child: Text(
//                                 'new UI',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 15, color: ColorTheme.hintText),
//                               ),
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             FocusManager.instance.primaryFocus?.unfocus();
//                             scaffoldKey.currentState?.closeDrawer();

//                             Get.bottomSheet(
//                               ConfirmationDialog(
//                                   icon: Images.support,
//                                   description:
//                                       'Are you sure you want to log out from My Genie?',
//                                   isLogOut: true,
//                                   onYesPressed: () async {
//                                     try {
//                                       Response response =
//                                           await Get.find<AuthController>()
//                                               .logout();

//                                       if (response.statusCode == 200) {
//                                         print(response.body);
//                                         socket?.disconnect();
//                                         Get.find<RestaurantController>()
//                                             .clearProductList();
//                                         Get.find<AuthController>()
//                                             .clearSharedData();
//                                         Get.offAllNamed(
//                                             RouteHelper.getSignInRoute());
//                                       }
//                                     } catch (e) {}
//                                   }),
//                             );
//                           },
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 15),
//                               child: Text(
//                                 'Logout',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 15, color: ColorTheme.hintText),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 10),
//                       child: Text(
//                         'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 15, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                   // Spacer(),
//                   ListTile(
//                     title: Text(
//                       'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
//                       style: poppinsMedium.copyWith(
//                           fontSize: 10, color: Colors.grey),
//                     ),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           key: scaffoldKey,
//           body: RefreshIndicator(
//             onRefresh: () async {
//               Get.find<KdsController>().resetSplitBill();
//               await Get.find<TableController>().getTableListFromLocally();

//               return await initData();
//             },
//             child: SingleChildScrollView(
//               controller: _scrollController,

//               physics: BouncingScrollPhysics(),
//               // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants![0]
//                             .isDelivery ==
//                         'true')
//                       SizedBox(height: 15),
//                     Divider(height: 0, color: ColorTheme.hintText),
//                     // Divider(color: Colors.black),
//                     SizedBox(height: 15),
//                     GetBuilder<KdsController>(builder: (kdsController) {
//                       return kdsController.getWaiterOrderListResponse == null
//                           ? SizedBox.shrink()
//                           : kdsController.getWaiterOrderListResponse!.orders!
//                                   .isNotEmpty
//                               ? Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           Dimensions.PADDING_SIZE_DEFAULT),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Container(
//                                           height: 45,
//                                           child: TextField(
//                                             controller: searchController,
//                                             textInputAction:
//                                                 TextInputAction.search,
//                                             autofocus: false,
//                                             textCapitalization:
//                                                 TextCapitalization.words,
//                                             keyboardType: TextInputType.name,
//                                             decoration: InputDecoration(
//                                               contentPadding:
//                                                   EdgeInsets.symmetric(
//                                                       horizontal: Dimensions
//                                                           .PADDING_SIZE_DEFAULT),
//                                               suffixIcon: Icon(Icons.search,
//                                                   color: ColorTheme.appColor),
//                                               hintText:
//                                                   'Search by Table no. / Name / Phone No.',
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(7),
//                                                 borderSide: BorderSide(
//                                                     color:
//                                                         ColorTheme.borderGrey),
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(7),
//                                                 borderSide: BorderSide(
//                                                     color:
//                                                         ColorTheme.borderGrey),
//                                               ),
//                                               border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(7),
//                                                 borderSide: BorderSide(
//                                                     color:
//                                                         ColorTheme.borderGrey),
//                                               ),
//                                               hintStyle:
//                                                   poppinsRegular.copyWith(
//                                                       fontSize: 14,
//                                                       color:
//                                                           ColorTheme.hintText),
//                                               filled: true,
//                                               fillColor: Colors.white,
//                                             ),
//                                             style: poppinsMedium.copyWith(
//                                               color: Colors.black,
//                                               fontSize: 14,
//                                             ),
//                                             onChanged: (value) async {
//                                               kdsController.update();
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       InkWell(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10)),
//                                         radius: 20,
//                                         onTap: () async {
//                                           await Get.find<TableController>()
//                                               .getTableListFromLocally();

//                                           await initCallApi();

//                                           // await Get.find<KdsController>()
//                                           //     .getWaiterPOSOrderList();
//                                         },
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsets.only(left: 10),
//                                           child: Icon(Icons.refresh_outlined,
//                                               color: ColorTheme.appColor,
//                                               size: 35),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               : SizedBox.shrink();
//                     }),
//                     SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

//                     GetBuilder<KdsController>(builder: (kdsController) {
//                       return kdsController.getWaiterOrderListResponse == null
//                           ? const SizedBox.shrink()
//                           : kdsController.isLoading
//                               ? Center(child: CircularProgressIndicator())
//                               : Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           Dimensions.PADDING_SIZE_LARGE),
//                                   child: kdsController.selectedSubMenu == 2 &&
//                                           kdsController
//                                               .splitOrderList.isNotEmpty
//                                       ?
//                                       //  Wrap(
//                                       //     direction: Axis.horizontal,
//                                       //     crossAxisAlignment:
//                                       //         WrapCrossAlignment.start,
//                                       //     runAlignment: WrapAlignment.start,
//                                       //     alignment: WrapAlignment.start,

//                                       //     // spacing: 10,
//                                       //     runSpacing: 10,
//                                       //     children: kdsController.splitOrderList
//                                       //         .map((order) {
//                                       //       return TabletWaiterOrderList(
//                                       //           _subscriptionBtStatus,
//                                       //           isSplitPrintedList:
//                                       //               isSplitPrintedList,
//                                       //           printSplitBill:
//                                       //               (String data) async {
//                                       //         if (data != null) {
//                                       //           if (data == '1') {
//                                       //             splitCurrentPrintIndex =
//                                       //                 kdsController
//                                       //                     .splitOrderList
//                                       //                     .indexOf(order);
//                                       //             showToast('Please wait..');
//                                       //             Get.find<LoadingController>()
//                                       //                 .startLoading(true);
//                                       //             if (Platform.isAndroid) {
//                                       //               await _subscriptionBtStatus
//                                       //                   ?.cancel();
//                                       //               await _singleSplitBleStatus
//                                       //                   ?.cancel();
//                                       //               await singleSplitBillBlutooth();
//                                       //             }
//                                       //             dataCheckSplitBill();
//                                       //           } else if (data == '2') {
//                                       //             await Get.bottomSheet(
//                                       //                 printSummaryDialog(),
//                                       //                 backgroundColor:
//                                       //                     Colors.transparent,
//                                       //                 isScrollControlled: true,
//                                       //                 ignoreSafeArea: false);
//                                       //           }
//                                       //         }
//                                       //       },
//                                       //           isSplitPrinterProccessingList:
//                                       //               isSplitPrinterProccessingList,
//                                       //           isSplitSelectPrinterList:
//                                       //               isSplitSelectPrinterList,
//                                       //           printerManager: _printerManager,
//                                       //           splitCurrentPrintIndex:
//                                       //               splitCurrentPrintIndex,
//                                       //           searchOrder: searchController,
//                                       //           searchTable: searchTable,
//                                       //           flutterTit: flutterTts,
//                                       //           order: order,
//                                       //           isWaiter: true);
//                                       //     }).toList(),
//                                       //   )
//                                       StaggeredGrid.count(
//                                           crossAxisCount: MediaQuery.of(context)
//                                                       .orientation ==
//                                                   Orientation.landscape
//                                               ? 3
//                                               : 2,
//                                           crossAxisSpacing: 15,
//                                           mainAxisSpacing: 15,
//                                           children: kdsController.splitOrderList
//                                               .map((order) {
//                                             // Now return the widget directly
//                                             return TabletWaiterOrderList(
//                                                 _subscriptionBtStatus,
//                                                 isSplitPrintedList:
//                                                     isSplitPrintedList,
//                                                 printSplitBill:
//                                                     (String data) async {
//                                               if (data == '1') {
//                                                 splitCurrentPrintIndex =
//                                                     kdsController.splitOrderList
//                                                         .indexOf(order);
//                                                 if (GetPlatform.isWindows) {
//                                                 } else {
//                                                   showToast('Please wait..');
//                                                   Get.find<LoadingController>()
//                                                       .startLoading(true);
//                                                   if (Platform.isAndroid) {
//                                                     await _subscriptionBtStatus
//                                                         ?.cancel();
//                                                     await _singleSplitBleStatus
//                                                         ?.cancel();
//                                                     await singleSplitBillBlutooth();
//                                                   }
//                                                 }
//                                                 dataCheckSplitBill();
//                                               } else if (data == '2') {
//                                                 await Get.bottomSheet(
//                                                     printSummaryDialog(),
//                                                     backgroundColor:
//                                                         Colors.transparent,
//                                                     isScrollControlled: true,
//                                                     ignoreSafeArea: false);
//                                               }
//                                             },
//                                                 isSplitPrinterProccessingList:
//                                                     isSplitPrinterProccessingList,
//                                                 isSplitSelectPrinterList:
//                                                     isSplitSelectPrinterList,
//                                                 printerManager: _printerManager,
//                                                 splitCurrentPrintIndex:
//                                                     splitCurrentPrintIndex,
//                                                 searchOrder: searchController,
//                                                 searchTable: searchTable,
//                                                 flutterTit: flutterTts,
//                                                 order: order,
//                                                 isWaiter: true);
//                                           }).toList())
//                                       : showConfigOrderList(
//                                           context,
//                                           kdsController,
//                                           searchController,
//                                           _subscriptionBtStatus,
//                                           searchTable,
//                                           flutterTts)
//                                   // orderContentTypeList(kdsController),
//                                   );
//                     }),
//                   ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget orderContentTypeList(KdsController kdsController) {
//   //   return GetBuilder(builder: (CartController cartController) {
//   //     return cartController.isLoading
//   //         ? Center(child: CircularProgressIndicator())
//   //         : Wrap(
//   //             direction: Axis.horizontal,
//   //             crossAxisAlignment: WrapCrossAlignment.start,
//   //             runAlignment: WrapAlignment.start,
//   //             alignment: WrapAlignment.start,
//   //             runSpacing: 10,
//   //             children:
//   //                 kdsController.getWaiterOrderListResponse.orders.map((order) {
//   //               return kdsController.selectedMainMenu == 0
//   //                   ? kdsController.selectedSubMenu == 1
//   //                       ? order.fOrderStatus == 0 ||
//   //                               order.fOrderStatus == 1 ||
//   //                               order.fOrderStatus == 2 ||
//   //                               order.fOrderStatus == 7
//   //                           ? searchController.text.isEmpty
//   //                               ? ((order.restaurantTable != null
//   //                                           ? order.restaurantTable.rtype !=
//   //                                               'RM'
//   //                                           : true) &&
//   //                                       (order?.orderType == 'pos' ||
//   //                                           order?.orderType == 'WalkIn' ||
//   //                                           order?.orderType == 'dinein'))
//   //                                   ? TabletWaiterOrderList(_subscriptionBtStatus,
//   //                                       searchOrder: searchController,
//   //                                       searchTable: searchTable,
//   //                                       flutterTit: flutterTts,
//   //                                       order: order,
//   //                                       isWaiter: true)
//   //                                   : SizedBox.shrink()
//   //                               : (order.restaurantTable != null &&
//   //                                           order.restaurantTable.tableNo !=
//   //                                               '' &&
//   //                                           (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) ||
//   //                                               order.restaurantTable.title
//   //                                                   .toUpperCase()
//   //                                                   .contains(searchController.text
//   //                                                       .toUpperCase()))) ||
//   //                                       (order.userId == null &&
//   //                                           order.userName
//   //                                               .toUpperCase()
//   //                                               .contains(searchController.text
//   //                                                   .toUpperCase())) ||
//   //                                       (order.userId != null &&
//   //                                           (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) ||
//   //                                               order.user.lName
//   //                                                   .toUpperCase()
//   //                                                   .contains(searchController.text.toUpperCase()))) ||
//   //                                       // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                       (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                       (order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase()))
//   //                                   ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
//   //                                       ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                       : const SizedBox.shrink()
//   //                                   : SizedBox.shrink()
//   //                           : const SizedBox.shrink()
//   //                       : kdsController.selectedSubMenu == 2
//   //                           ? (order.fOrderStatus == 5 || (Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 ? order.fOrderStatus == 7 : order.fOrderStatus == 5))
//   //                               ? searchController.text.isEmpty
//   //                                   ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
//   //                                       ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                       : SizedBox.shrink()
//   //                                   : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                           (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                           order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                       ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
//   //                                           ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                           : SizedBox.shrink()
//   //                                       : const SizedBox.shrink()
//   //                               : const SizedBox.shrink()

//   //                           // : const SizedBox.shrink()
//   //                           : const SizedBox.shrink()
//   //                   :

//   //                   ////
//   //                   kdsController.selectedMainMenu == 1
//   //                       ? kdsController.selectedSubMenu == 1
//   //                           ? order.fOrderStatus == 0 || order.fOrderStatus == 1 || order.fOrderStatus == 2 || order.fOrderStatus == 7
//   //                               ? searchController.text.isEmpty
//   //                                   ? (order?.orderType == 'take_away')
//   //                                       ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                       : SizedBox.shrink()
//   //                                   : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           (order.userId == null && order.userName.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                           (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                           // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                           order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                       ? (order?.orderType == 'take_away')
//   //                                           ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                           : SizedBox.shrink()
//   //                                       : const SizedBox.shrink()
//   //                               : const SizedBox.shrink()
//   //                           : kdsController.selectedSubMenu == 2
//   //                               ? (order.fOrderStatus == 5 || (Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 ? order.fOrderStatus == 7 : order.fOrderStatus == 5))
//   //                                   ? searchController.text.isEmpty
//   //                                       ? (order?.orderType == 'take_away')
//   //                                           ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                           : SizedBox.shrink()
//   //                                       : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                               (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                               order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                           ? (order?.orderType == 'take_away')
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : SizedBox.shrink()
//   //                                           : const SizedBox.shrink()
//   //                                   : const SizedBox.shrink()

//   //                               // : const SizedBox.shrink()
//   //                               : const SizedBox.shrink()
//   //                       :
//   //                       ////
//   //                       ///
//   //                       ///
//   //                       kdsController.selectedMainMenu == 2
//   //                           ? kdsController.selectedSubMenu == 1
//   //                               ? order.fOrderStatus == 0 || order.fOrderStatus == 1 || order.fOrderStatus == 2 || order.fOrderStatus == 7
//   //                                   ? searchController.text.isEmpty
//   //                                       ? (order?.orderType == 'delivery')
//   //                                           ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                           : SizedBox.shrink()
//   //                                       : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               (order.userId == null && order.userName.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                               (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                               // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                               order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                           ? (order?.orderType == 'delivery')
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : SizedBox.shrink()
//   //                                           : const SizedBox.shrink()
//   //                                   : const SizedBox.shrink()
//   //                               : kdsController.selectedSubMenu == 2
//   //                                   ? (order.fOrderStatus == 5 || (Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 ? order.fOrderStatus == 7 : order.fOrderStatus == 5))
//   //                                       ? searchController.text.isEmpty
//   //                                           ? (order?.orderType == 'delivery')
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : SizedBox.shrink()
//   //                                           : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                               ? (order?.orderType == 'delivery')
//   //                                                   ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                                   : SizedBox.shrink()
//   //                                               : const SizedBox.shrink()
//   //                                       : const SizedBox.shrink()

//   //                                   // : const SizedBox.shrink()
//   //                                   : const SizedBox.shrink()
//   //                           :
//   //                           ////////////////////////////
//   //                           kdsController.selectedMainMenu == 4
//   //                               ? kdsController.selectedSubMenu == 1
//   //                                   ? order.fOrderStatus == 0 || order.fOrderStatus == 1 || order.fOrderStatus == 2 || order.fOrderStatus == 7
//   //                                       ? searchController.text.isEmpty
//   //                                           ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : SizedBox.shrink()
//   //                                           : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId == null && order.userName.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                               ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
//   //                                                   ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                                   : SizedBox.shrink()
//   //                                               : const SizedBox.shrink()
//   //                                       : const SizedBox.shrink()
//   //                                   : kdsController.selectedSubMenu == 2
//   //                                       ? (order.fOrderStatus == 5 || (Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 ? order.fOrderStatus == 7 : order.fOrderStatus == 5))
//   //                                           ? searchController.text.isEmpty
//   //                                               ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
//   //                                                   ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                                   : SizedBox.shrink()
//   //                                               : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                       (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                       order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                                   ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
//   //                                                       ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                                       : SizedBox.shrink()
//   //                                                   : const SizedBox.shrink()
//   //                                           : const SizedBox.shrink()

//   //                                       // : const SizedBox.shrink()
//   //                                       : const SizedBox.shrink()
//   //                               :

//   //                               ////
//   //                               ///
//   //                               ///
//   //                               kdsController.selectedSubMenu == 1
//   //                                   ? order.fOrderStatus == 0 || order.fOrderStatus == 1 || order.fOrderStatus == 2 || order.fOrderStatus == 7
//   //                                       ? searchController.text.isEmpty
//   //                                           ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                           : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId == null && order.userName.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                   // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                   order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase())
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : const SizedBox.shrink()
//   //                                       : const SizedBox.shrink()
//   //                                   : kdsController.selectedSubMenu == 2
//   //                                       ? (order.fOrderStatus == 5 || (Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 ? order.fOrderStatus == 7 : order.fOrderStatus == 5))
//   //                                           ? searchController.text.isEmpty
//   //                                               ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                               : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                       (order.userId != null && (order.user.fName.toUpperCase().contains(searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
//   //                                                       // (order.id.toUpperCase().contains(searchController.text.toUpperCase())) ||
//   //                                                       (order.restaurantOrderId.toUpperCase().contains(searchController.text.toUpperCase()))
//   //                                                   ? TabletWaiterOrderList(_subscriptionBtStatus, searchOrder: searchController, searchTable: searchTable, flutterTit: flutterTts, order: order, isWaiter: true)
//   //                                                   : const SizedBox.shrink()
//   //                                           : const SizedBox.shrink()

//   //                                       // : const SizedBox.shrink()
//   //                                       : const SizedBox.shrink();
//   //             }).toList(),
//   //           );
//   //   });
//   // }

//   Widget addOrderButton() {
//     return Padding(
//       padding: const EdgeInsets.only(right: 10),
//       child: InkWell(
//         onTap: () {
//           searchController.clear();
//           paidController.clear();
//           Get.find<KdsController>().resetSplitBill();
//           checkRestaurantIsOpen();
//         },
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.only(top: 10),
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                   color: ColorTheme.appColor,
//                   borderRadius:
//                       BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//               child:
//                   Center(child: Icon(Icons.add, color: Colors.white, size: 20)),
//             ),
//             SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//             Text(
//               'add_order'.tr,
//               style: poppinsRegular.copyWith(
//                   fontSize: 14, color: ColorTheme.appColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget foodStatusTabAppBar() {
//     return Padding(
//       padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//       child: GetBuilder<KdsController>(builder: (kdsController) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             MediaQuery.of(context).size.width > 1600
//                 ? SizedBox(
//                     child: Image.asset(
//                       logoHelper.appLogo!,
//                       height: Get.height / 10.72,
//                     ),
//                   )
//                 : SizedBox(
//                     child: Image.asset(
//                       logoHelper.appLogo!,
//                       width: Get.width * 0.135,
//                       // height: Get.height / 10.72,
//                     ),
//                   ),
//             GetBuilder<KdsController>(builder: (kdsController) {
//               return Container(
//                 width: Get.width * 0.55,
//                 color: Color(0xFFF6F6F6),
//                 padding: EdgeInsets.only(right: 10),
//                 child: Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         FocusManager.instance.primaryFocus?.unfocus();

//                         await _dropdownContoller.showTooltip();
//                       },
//                       child: SuperTooltip(
//                         borderRadius: 2,

//                         // elevation: 1,
//                         // hasShadow: false,
//                         borderColor: Colors.white,
//                         shadowColor: Colors.black.withOpacity(0.1),
//                         showBarrier: true,
//                         controller: _dropdownContoller,
//                         popupDirection: TooltipDirection.down,
//                         backgroundColor: Colors.white,
//                         right: Get.width * 0.5 + 20,
//                         left: Get.width * 0.3,

//                         constraints: BoxConstraints(
//                             maxHeight: 40,
//                             minWidth: 0,
//                             minHeight: 10,
//                             maxWidth: 100),
//                         arrowTipDistance: 10,
//                         arrowBaseWidth: 2.0,
//                         arrowLength: 0,
//                         // borderWidth: 2.0,

//                         // showCloseButton: ShowCloseButton.none,
//                         touchThroughAreaShape: ClipAreaShape.rectangle,
//                         touchThroughAreaCornerRadius: 5,
//                         barrierColor: Colors.transparent,
//                         content: ListView.builder(
//                             shrinkWrap: true,
//                             padding: EdgeInsets.zero,
//                             itemCount: orderTypeList.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               return Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 20,
//                                     top: 25,
//                                     bottom: index == orderTypeList.length - 1
//                                         ? 25
//                                         : 0),
//                                 child: InkWell(
//                                   onTap: () async {
//                                     if (orderTypeList[index] == 'Dine In') {
//                                       kdsController.setMainMenuIndex(0);
//                                     } else if (orderTypeList[index] ==
//                                         'Take Away') {
//                                       kdsController.setMainMenuIndex(1);
//                                     } else if (orderTypeList[index] ==
//                                         'Delivery') {
//                                       kdsController.setMainMenuIndex(2);
//                                     } else if (orderTypeList[index] == 'Room') {
//                                       kdsController.setMainMenuIndex(4);
//                                     } else {
//                                       kdsController.setMainMenuIndex(3);
//                                     }
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                     await _dropdownContoller.hideTooltip();
//                                   },
//                                   child: Text(
//                                     orderTypeList[index],
//                                     style: poppinsMedium.copyWith(
//                                         fontSize: 13, color: Colors.black),
//                                   ),
//                                 ),
//                               );
//                             }),
//                         child: Container(
//                           height: 50,
//                           // height: 30,
//                           width: Get.width * 0.15,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: Dimensions.PADDING_SIZE_SMALL),
//                           decoration: BoxDecoration(
//                             color: ColorTheme.dineInDropdownYello,
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   Get.find<AuthController>()
//                                               .profileModel!
//                                               .restaurants!
//                                               .first
//                                               .delivery !=
//                                           true
//                                       ? 'Dine In'
//                                       : kdsController.selectedMainMenu == 0
//                                           ? 'Dine In'
//                                           : kdsController.selectedMainMenu == 1
//                                               ? 'Take Away'
//                                               : kdsController
//                                                           .selectedMainMenu ==
//                                                       2
//                                                   ? 'Delivery'
//                                                   : kdsController
//                                                               .selectedMainMenu ==
//                                                           4
//                                                       ? 'Room'
//                                                       : 'All',
//                                   maxLines: 1,
//                                   style: poppinsMedium.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                               Icon(Icons.keyboard_arrow_down_rounded,
//                                   color: Colors.white)
//                             ],
//                           ),

//                           // child: DropdownButton<String>(
//                           //   // onTap: () {
//                           //   //   // isOpenedDropdown = !isOpenedDropdown;
//                           //   //   print('object');
//                           //   //   // if (mounted) setState(() {});
//                           //   // },
//                           //   // style: TextStyle(color: Colors.white),

//                           //   icon: Icon(Icons.keyboard_arrow_down_outlined,color: Colors.white,),
//                           //   isExpanded: true,
//                           //   value: Get.find<AuthController>()
//                           //               .profileModel
//                           //               .restaurants
//                           //               .first
//                           //               .delivery !=
//                           //           true
//                           //       ? 'Dine In'
//                           //       : kdsController.selectedMainMenu == 0
//                           //           ? 'Dine In'
//                           //           : kdsController.selectedMainMenu == 1
//                           //               ? 'Take Away'
//                           //               : kdsController.selectedMainMenu == 2
//                           //                   ? 'Delivery'
//                           //                   : 'All',
//                           //   items: <String>['All', 'Dine In', 'Take Away', 'Delivery']
//                           //       .map((String value) {
//                           //     return DropdownMenuItem<String>(
//                           //       value: value,
//                           //       child: Text(
//                           //         '$value',
//                           //         maxLines: 1,
//                           //         style: poppinsMedium.copyWith(
//                           //           color: Colors.black,
//                           //           fontSize: 11,
//                           //         ),
//                           //       ),
//                           //     );
//                           //   }).toList(),
//                           //   onChanged: (String value) {
//                           //     if (value == 'Dine In') {
//                           //       kdsController.setMainMenuIndex(0);
//                           //     } else if (value == 'Take Away') {
//                           //       kdsController.setMainMenuIndex(1);
//                           //     } else if (value == 'Delivery') {
//                           //       kdsController.setMainMenuIndex(2);
//                           //     } else {
//                           //       kdsController.setMainMenuIndex(3);
//                           //     }

//                           //     // checkInController.setGuestCount(value);
//                           //   },
//                           //   underline: SizedBox(),
//                           // ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .isShowOrderConfirmTab ==
//                         'Yes')
//                       Expanded(
//                         child: InkWell(
//                           splashColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () {
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             // if (Get.find<AuthController>()
//                             //     .profileModel
//                             //     .role
//                             //     .contains('order')) {
//                             searchController.clear();
//                             paidController.clear();
//                             Get.find<KdsController>().resetSplitBill();
//                             kdsController.setSubMenuIndex(0);
//                             // }
//                           },
//                           child: SizedBox(
//                             child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 7),
//                               decoration: BoxDecoration(
//                                 color: kdsController.selectedSubMenu == 0
//                                     ? ColorTheme.appColor
//                                     : Color(0xFFF6F6F6),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'New',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 11,
//                                       color: kdsController.selectedSubMenu == 0
//                                           ? Colors.white
//                                           : Colors.black),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .defOrdStatus !=
//                         5)
//                       Expanded(
//                         child: InkWell(
//                           splashColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           onTap: () {
//                             FocusManager.instance.primaryFocus?.unfocus();

//                             if (Get.find<AuthController>()
//                                 .profileModel!
//                                 .role!
//                                 .contains('order')) {
//                               searchController.clear();
//                               paidController.clear();
//                               Get.find<KdsController>().resetSplitBill();
//                               kdsController.setSubMenuIndex(1);
//                             }
//                           },
//                           child: SizedBox(
//                             child: Container(
//                               // margin: EdgeInsets.only(right: 5),
//                               padding: EdgeInsets.symmetric(vertical: 7),
//                               decoration: BoxDecoration(
//                                 // border: Border.all(
//                                 //     color: kdsController.selectedSubMenu == 1
//                                 //         ? Colors.transparent
//                                 //         : Theme.of(context).hintColor),
//                                 color: kdsController.selectedSubMenu == 1
//                                     ? ColorTheme.appColor
//                                     : Color(0xFFF6F6F6),

//                                 // border:
//                                 //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                                 // borderRadius: BorderRadius.circular(
//                                 //     Dimensions.RADIUS_DEFAULT)
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Ready',
//                                   style: poppinsMedium.copyWith(
//                                       fontSize: 13,
//                                       color: kdsController.selectedSubMenu == 1
//                                           ? Colors.white
//                                           : Colors.black),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .defOrdStatus !=
//                         5)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Container(
//                           width: 1,
//                           // height: 8,
//                           height: 20,
//                           color: Color(0xFFE6E6E6),
//                         ),
//                       ),
//                     Expanded(
//                       child: InkWell(
//                         splashColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         onTap: () {
//                           FocusManager.instance.primaryFocus?.unfocus();

//                           searchController.clear();
//                           paidController.clear();
//                           kdsController.setSubMenuIndex(2);
//                         },
//                         child: SizedBox(
//                           // width: Get.width * 0.3,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: 7),
//                             decoration: BoxDecoration(
//                               // border: Border.all(
//                               //     color: kdsController.selectedSubMenu == 2
//                               //         ? Colors.transparent
//                               //         : Theme.of(context).hintColor),
//                               color: kdsController.selectedSubMenu == 2
//                                   ? ColorTheme.appColor
//                                   : Color(0xFFF6F6F6),

//                               // border:
//                               //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                               // borderRadius:
//                               //     BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Running',
//                                 style: poppinsMedium.copyWith(
//                                     fontSize: 13,
//                                     color: kdsController.selectedSubMenu == 2
//                                         ? Colors.white
//                                         : Colors.black),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (Get.find<AuthController>()
//                             .profileModel!
//                             .restaurants!
//                             .first
//                             .defOrdStatus ==
//                         5)
//                       SizedBox(width: 20)
//                     // InkWell(
//                     //   splashColor: Colors.transparent,
//                     //   hoverColor: Colors.transparent,
//                     //   highlightColor: Colors.transparent,
//                     //   onTap: () async {
//                     //     if (Get.find<AuthController>()
//                     //         .profileModel
//                     //         .role
//                     //         .contains('bill')) {
//                     //       searchController.clear();
//                     //       paidController.clear();
//                     //       _subscriptionBtStatus?.cancel();
//                     //       kdsController.setSubMenuIndex(4);
//                     //       await kdsController.getPaidOrderList('');
//                     //     }
//                     //   },
//                     //   child: SizedBox(
//                     //     width: Get.width * 0.25,
//                     //     child: Padding(
//                     //       padding: const EdgeInsets.only(top: 10),
//                     //       child: Container(
//                     //         padding: EdgeInsets.symmetric(
//                     //             // horizontal: Dimensions.PADDING_SIZE_DEFAULT,
//                     //             vertical: 4),
//                     //         decoration: BoxDecoration(
//                     //             border: Border.all(
//                     //                 color: kdsController.selectedSubMenu == 4
//                     //                     ? Colors.transparent
//                     //                     : Theme.of(context).hintColor),
//                     //             color: kdsController.selectedSubMenu == 4
//                     //                 ? ColorTheme.appColor
//                     //                 : Colors.white,

//                     //             // border:
//                     //             //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                     //             borderRadius:
//                     //                 BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//                     //         child: Center(
//                     //           child: Text(
//                     //             'paid'.tr,
//                     //             style: poppinsRegular.copyWith(
//                     //                 fontSize: Dimensions.FONT_SIZE_SMALL,
//                     //                 color: kdsController.selectedSubMenu == 4
//                     //                     ? Colors.white
//                     //                     : Colors.black),
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               );
//             }),
//             // InkWell(
//             //   splashColor: Colors.transparent,
//             //   hoverColor: Colors.transparent,
//             //   highlightColor: Colors.transparent,
//             //   onTap: () {
//             //     if (Get.find<AuthController>()
//             //         .profileModel
//             //         .role
//             //         .contains('order')) {
//             //       searchController.clear();
//             //       paidController.clear();
//             //       kdsController.setSubMenuIndex(1);
//             //     }
//             //   },
//             //   child: SizedBox(
//             //     width: Get.width * 0.15,
//             //     child: Stack(
//             //       children: [
//             //         Padding(
//             //           padding: const EdgeInsets.only(top: 10),
//             //           child: Container(
//             //             margin: EdgeInsets.only(right: 5),
//             //             padding: EdgeInsets.symmetric(vertical: 4),
//             //             decoration: BoxDecoration(
//             //                 border: Border.all(
//             //                     color: kdsController.selectedSubMenu == 1
//             //                         ? Colors.transparent
//             //                         : Theme.of(context).hintColor),
//             //                 color: kdsController.selectedSubMenu == 1
//             //                     ? ColorTheme.appColor
//             //                     : Colors.white,

//             //                 // border:
//             //                 //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//             //                 borderRadius: BorderRadius.circular(
//             //                     Dimensions.RADIUS_DEFAULT)),
//             //             child: Center(
//             //               child: Text(
//             //                 'ready'.tr,
//             //                 style: poppinsRegular.copyWith(
//             //                     fontSize: 15,
//             //                     color: kdsController.selectedSubMenu == 1
//             //                         ? Colors.white
//             //                         : Colors.black),
//             //               ),
//             //             ),
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//             // InkWell(
//             //   splashColor: Colors.transparent,
//             //   hoverColor: Colors.transparent,
//             //   highlightColor: Colors.transparent,
//             //   onTap: () {
//             //     searchController.clear();
//             //     paidController.clear();
//             //     kdsController.setSubMenuIndex(2);
//             //   },
//             //   child: SizedBox(
//             //     width: Get.width * 0.15,
//             //     child: Padding(
//             //       padding: const EdgeInsets.only(top: 10),
//             //       child: Container(
//             //         margin: EdgeInsets.only(right: 5),
//             //         padding: EdgeInsets.symmetric(vertical: 4),
//             //         decoration: BoxDecoration(
//             //             border: Border.all(
//             //                 color: kdsController.selectedSubMenu == 2
//             //                     ? Colors.transparent
//             //                     : Theme.of(context).hintColor),
//             //             color: kdsController.selectedSubMenu == 2
//             //                 ? ColorTheme.appColor
//             //                 : Colors.white,

//             //             // border:
//             //             //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//             //             borderRadius:
//             //                 BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//             //         child: Center(
//             //           child: Text(
//             //             'Served'.tr,
//             //             style: poppinsRegular.copyWith(
//             //                 fontSize: 15,
//             //                 color: kdsController.selectedSubMenu == 2
//             //                     ? Colors.white
//             //                     : Colors.black),
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // InkWell(
//             //   splashColor: Colors.transparent,
//             //   hoverColor: Colors.transparent,
//             //   highlightColor: Colors.transparent,
//             //   onTap: () async {
//             //     if (Get.find<AuthController>()
//             //         .profileModel
//             //         .role
//             //         .contains('bill')) {
//             //       searchController.clear();
//             //       paidController.clear();
//             //       _subscriptionBtStatus?.cancel();
//             //       kdsController.setSubMenuIndex(4);
//             //       await kdsController.getPaidOrderList('');
//             //     }
//             //   },
//             //   child: SizedBox(
//             //     width: Get.width * 0.15,
//             //     child: Padding(
//             //       padding: const EdgeInsets.only(top: 10),
//             //       child: Container(
//             //         padding: EdgeInsets.symmetric(vertical: 4),
//             //         decoration: BoxDecoration(
//             //             border: Border.all(
//             //                 color: kdsController.selectedSubMenu == 4
//             //                     ? Colors.transparent
//             //                     : Theme.of(context).hintColor),
//             //             color: kdsController.selectedSubMenu == 4
//             //                 ? ColorTheme.appColor
//             //                 : Colors.white,
//             //             borderRadius:
//             //                 BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//             //         child: Center(
//             //           child: Text(
//             //             'paid'.tr,
//             //             style: poppinsRegular.copyWith(
//             //                 fontSize: 15,
//             //                 color: kdsController.selectedSubMenu == 4
//             //                     ? Colors.white
//             //                     : Colors.black),
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ],
//         );
//       }),
//     );
//   }

//   checkRestaurantIsOpen() async {
//     List<Schedules> schedules =
//         Get.find<AuthController>().profileModel!.restaurants!.first.schedules!;
//     schedules.sort((a, b) => a.day!.compareTo(b.day!));
//     DateTime currentDate = DateTime.now();
//     String todayName = DateFormat('EEEE').format(currentDate);
//     int? currentDay;
//     if (todayName == 'Sunday') {
//       currentDay = 0;
//     } else if (todayName == 'Monday') {
//       currentDay = 1;
//     } else if (todayName == 'Tuesday') {
//       currentDay = 2;
//     } else if (todayName == 'Wednesday') {
//       currentDay = 3;
//     } else if (todayName == 'Thursday') {
//       currentDay = 4;
//     } else if (todayName == 'Friday') {
//       currentDay = 5;
//     } else if (todayName == 'Saturday') {
//       currentDay = 6;
//     }
//     Schedules? todaySchedule;
//     Schedules? previousDaySchedule;
//     for (var i = 0; i < schedules.length; i++) {
//       if (currentDay == schedules[i].day) {
//         todaySchedule = schedules[i];
//         break;
//       }
//     }

//     for (var i = 0; i < schedules.length; i++) {
//       if (currentDay! - 1 == schedules[i].day) {
//         previousDaySchedule = schedules[i];
//         break;
//       }
//     }
//     if (todaySchedule == null && previousDaySchedule == null) {
//       showCustomSnackBar('Restaurant is closed');
//     } else if (DateConverter.isAvailable(
//         todaySchedule!.openingTime!, todaySchedule.closingTime!)) {
//       bool isRestaurantOpen = DateConverter.isAvailable(
//           todaySchedule.openingTime!, todaySchedule.closingTime!);
//       // print(isRestaurantOpen);
//       if (isRestaurantOpen) {
//         // showCustomSnackBar('Restaurant is open', isError: false);
//         await _singleSplitBleStatus?.cancel();

//         await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => TabletPosScreen(editOrder: null)));
//       }
//       // var data = await Get.toNamed(RouteHelper.getWaiterPosRoute(null));
//     } else {
//       var subtractDate = currentDate.subtract(Duration(days: 1));
//       int closeHour =
//           int.parse(previousDaySchedule!.closingTime!.split(':').first);
//       int closeMinute =
//           int.parse(previousDaySchedule.closingTime!.split(':')[1]);
//       int openHour =
//           int.parse(previousDaySchedule.openingTime!.split(':').first);
//       int openMinute =
//           int.parse(previousDaySchedule.openingTime!.split(':')[1]);

//       if (closeHour <= 9) {
//         bool isbefore = currentDate.isBefore(DateTime(currentDate.year,
//             currentDate.month, currentDate.day, closeHour, closeMinute));
//         bool isAfter = currentDate.isAfter(DateTime(subtractDate.year,
//             subtractDate.month, subtractDate.day, openHour, openMinute));
//         // print(isAfter);
//         if (isbefore && isAfter) {
//           // showCustomSnackBar('Restaurant is open previous day');
//           await _singleSplitBleStatus?.cancel();

//           await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => TabletPosScreen(editOrder: null)));
//         } else {
//           showCustomSnackBar('Restaurant is closed');
//         }
//       } else {
//         showCustomSnackBar('Restaurant is closed');
//       }
//     }
//   }

//   listenBlutooth({OrderList? order}) {
//     _subscriptionBtStatus =
//         PrinterManager.instance.stateBluetooth.listen((status) {
//       log(' -----------------home status bt $status ------------------ ');
//       if (Get.find<KdsController>().splitOrderList.isNotEmpty) {
//         if (status == BTStatus.connected) {
//           isConnect = true;
//           if (Platform.isAndroid) {
//             Future.delayed(const Duration(milliseconds: 1000), () async {
//               // PrinterManager.instance
//               //     .send(type: PrinterType.bluetooth, bytes: pendingTask);
//               pendingTask = null;
//             });
//           } else if (Platform.isIOS) {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//             pendingTask = null;
//           }
//         } else if (status == BTStatus.none) {
//           if (!isConnect) {
//             print('not connect');
//             Future.delayed(Duration(seconds: 2), () async {
//               // showErrorToast(
//               //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
//               isConnect = true;
//               splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//               dataCheckSplitBill();
//             });
//           } else {
//             isConnect = false;
//             print('%%%%%%%%%');
//           }
//         }
//       } else {
//         if (status == BTStatus.connected) {
//           isConnect = true;
//           if (Platform.isAndroid) {
//             Future.delayed(const Duration(milliseconds: 1000), () async {
//               PrinterManager.instance
//                   .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//               pendingTask = null;
//             });
//           } else if (Platform.isIOS) {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//             pendingTask = null;
//           }
//         } else if (status == BTStatus.none) {
//           if (!isConnect) {
//             Future.delayed(Duration(seconds: 2), () async {
//               // showErrorToast(
//               //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
//               if (isSkipFirstTimeOrder && !skipFailedList[currentPrintIndex]) {
//                 Future.delayed(Duration(seconds: 5), () {
//                   isConnect = true;
//                   // isFailedPrint = true;
//                   // failedCartProductList[currentPrintIndex] =
//                   //     cartProductList[currentPrintIndex];
//                   // currentPrintIndex = currentPrintIndex + 1;
//                   skipFailedList[currentPrintIndex] = true;
//                   isSkipFirstTimeOrder = false;
//                   dataCheck(order!);
//                 });
//               } else {
//                 isConnect = true;
//                 isFailedPrint = true;
//                 failedCartProductList[currentPrintIndex] =
//                     cartProductList[currentPrintIndex];
//                 currentPrintIndex = currentPrintIndex + 1;
//                 dataCheck(order!);
//               }
//             });
//           } else {
//             isConnect = false;
//             isSkipFirstTimeOrder = true;
//             print('%%%%%%%%%');
//           }
//         }
//       }
//     });
//   }

//   singleSplitBillBlutooth() {
//     if (Platform.isAndroid) {
//       _singleSplitBleStatus =
//           PrinterManager.instance.stateBluetooth.listen((status) async {
//         log(' -----------------split status bt $status ------------------ ');

//         if (status == BTStatus.connected) {
//           if (Platform.isAndroid) {
//             Future.delayed(Duration(seconds: 11), () async {
//               Get.find<LoadingController>().startLoading(false);
//               await Get.find<LoadingController>()
//                   .changeText(data: 'Successfully printed!!');
//               await Get.find<LoadingController>().changeStatus(data: true);
//               pendingTask = null;
//               await PrinterManager.instance
//                   .disconnect(type: PrinterType.bluetooth);
//             });
//           } else if (Platform.isIOS) {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//             pendingTask = null;
//           }
//         } else if (status == BTStatus.none) {
//           Get.find<LoadingController>().startLoading(false);

//           await Get.find<LoadingController>()
//               .changeText(data: 'Failed to bluetooth connect!!', error: true);
//           await Get.find<LoadingController>().changeStatus(data: true);
//         }
//       });
//     }
//   }

//   Future placeOrderByteConvert(OrderList order) async {
//     bool isOutOfMenu = false;
//     List<int> bytes = [];
//     final profile = await CapabilityProfile.load(name: 'XP-N160I');
//     final generator = Generator(
//         Get.find<AuthController>()
//                     .profileModel!
//                     .restaurantPrinterNew![currentPrintIndex]
//                     .printerPaperRoll ==
//                 58
//             ? PaperSize.mm58
//             : PaperSize.mm80,
//         profile);
//     bytes += generator.setGlobalCodeTable('CP1252');

//     if (Get.find<AuthController>()
//             .profileModel!
//             .restaurants!
//             .first
//             .isShowAddressKot ==
//         'Yes') {
//       if (logoHelper.logoUrlPrint != null) {
//         try {
//           bytes += generator.feed(1);
//           bytes += generator.image(logoHelper.logoUrlPrint!);
//         } catch (e) {
//           print(e);
//         }
//       }
//       bytes += generator.text(
//           Get.find<AuthController>().profileModel!.restaurants![0].name!,
//           styles: PrinterConfig().titleStyle());
//       bytes += generator.text(
//           Get.find<AuthController>().profileModel!.restaurants![0].address!,
//           styles: PrinterConfig().addressStyle());
//     }
//     bytes += generator.text(cartProductList[currentPrintIndex].first.station!,
//         styles: PrinterConfig().titleStyle());

//     bytes += generator.row([
//       PosColumn(
//           text: 'order_id'.tr + ':' + ' ${order.restaurantOrderId}',
//           width: 6,
//           styles: PrinterConfig().orderIdStyle()),
//       PosColumn(
//           text:
//               '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//           width: 6,
//           styles: PrinterConfig().orderCreateDateStyle()),
//     ]);
//     if (order.orderType != 'delivery' && order.orderType != 'take_away')
//       bytes += generator.row([
//         PosColumn(
//             text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
//         PosColumn(
//           text: '',
//           width: 1,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: '${order.vendorEmployee!.waiterName}',
//             width: 6,
//             styles: PrinterConfig().waiterNameStyle()),
//       ]);
//     if (order.userId != null) {
//       bytes += generator.row([
//         PosColumn(
//           text: '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}',
//           width: 5,
//           styles: PosStyles(
//               height: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')
//                       .first),
//               width: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')[1]),
//               bold: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>().profileModel!.printConfig!.restaurantFoodList == null
//                   ? false
//                   : Get.find<AuthController>().profileModel!.printConfig!.restaurantFoodList!.split(',').last == 'true'
//                       ? true
//                       : false,
//               align: PosAlign.left,
//               fontType: PosFontType.fontB),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center, underline: true),
//         ),
//         PosColumn(
//           text: '${order.user?.phone ?? ''}',
//           width: 5,
//           styles: PosStyles(
//               height: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')
//                       .first),
//               width: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')[1]),
//               bold: Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>().profileModel!.printConfig!.restaurantFoodList == null
//                   ? false
//                   : Get.find<AuthController>().profileModel!.printConfig!.restaurantFoodList!.split(',').last == 'true'
//                       ? true
//                       : false,
//               align: PosAlign.right,
//               fontType: PosFontType.fontB),
//         ),
//       ]);
//     } else if (order.userName != '') {
//       bytes += generator.text(
//         '${order.userName}',
//         styles: PosStyles(fontType: PosFontType.fontB),
//       );
//     }
//     bytes += generator.text(
//         order.restaurantTable == null || order.restaurantTable!.tableNo == ''
//             ? order.orderType == 'delivery'
//                 ? 'Delivery'
//                 : Get.find<KdsController>()
//                             .getWaiterOrderListResponse!
//                             .orders![
//                                 Get.find<KdsController>().updatedOrderIndex]
//                             .orderType ==
//                         'take_away'
//                     ? 'Take Away'
//                     : 'WC'
//             : order.restaurantTable!.title == ''
//                 ? '${order.restaurantTable!.tableNo}'
//                 : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//         // ordersPrint.restaurantDetails.tableNo +
//         // '-' +
//         // ordersPrint.restaurantDetails.tableArea,
//         styles: PrinterConfig().tableNoStyle());

//     bytes += generator.hr(ch: '--');

//     bytes += generator.row([
//       PosColumn(
//           text: 'sl'.tr.toUpperCase(),
//           width: 2,
//           styles: PrinterConfig().foodStyle()),
//       PosColumn(
//         text: 'item_info'.tr,
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'qty'.tr,
//         width: 2,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '--');
//     for (var i = 0; i < cartProductList[currentPrintIndex].length; i++) {
//       OrderDetails cart = cartProductList[currentPrintIndex][i];
//       String variationText = '';
//       String addons = '';

//       // if (cart.variation != null && cart.variation.isNotEmpty) {
//       //   for (int j = 0; j < cart.variation.length; j++) {
//       //     variationText +=
//       //         '${variationText.isNotEmpty ? ', ' : ''}${cart.variation[j].name} (';

//       //     if (cart.variation[j].values != null) {
//       //       List<String> labelList = [];
//       //       for (var element in cart.variation[j].values) {
//       //         labelList.add(element.level);
//       //       }
//       //       variationText +=
//       //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//       //     }

//       //     variationText += ')';
//       //   }
//       // }
//       if (cart.variation != null &&
//           cart.variation!.isNotEmpty &&
//           Get.find<AuthController>()
//                   .profileModel!
//                   .restaurants!
//                   .first
//                   .foodWithVariance ==
//               'Yes') {
//         variationText += '(';
//         List<String> labelList = [];

//         for (int j = 0; j < cart.variation!.length; j++) {
//           if (cart.variation![j].values != null) {
//             for (var element in cart.variation![j].values!) {
//               labelList.add(element.level!);
//             }
//           }
//         }
//         variationText += '${labelList.join(',')}';
//         variationText += ')';
//       } else if (cart.variation != null &&
//           cart.variation!.isNotEmpty &&
//           Get.find<AuthController>()
//                   .profileModel!
//                   .restaurants!
//                   .first
//                   .foodWithVariance !=
//               'Yes') {
//         for (int j = 0; j < cart.variation!.length; j++) {
//           variationText +=
//               '${variationText.isNotEmpty ? ', ' : ''}${cart.variation![j].name} (';

//           if (cart.variation![j].values != null) {
//             List<String> labelList = [];
//             for (var element in cart.variation![j].values!) {
//               labelList.add(element.level!);
//             }
//             variationText +=
//                 '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//           }

//           variationText += ')';
//         }
//       }

//       for (var i = 0; i < cart.addOns!.length; i++) {
//         if (addons != '') {
//           addons += ', ';
//         }
//         addons += '${cart.addOns![i].name} (${cart.addOns![i].qty})';
//       }

//       bytes += generator.row([
//         PosColumn(
//             text: '${i + 1}.', width: 2, styles: PrinterConfig().foodStyle()),
//         PosColumn(
//           text: Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .foodWithVariance ==
//                   'Yes'
//               ? '${cart.foodDetails!.name} $variationText'
//               : '${cart.foodDetails!.name}',
//           width: 8,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: '${cart.quantity}',
//           width: 2,
//           styles: PrinterConfig().foodStyle(),
//         ),
//       ]);

//       if (addons != '') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Add-Ons :$addons',
//             width: 8,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//         ]);
//       }
//       if (variationText != '' &&
//           Get.find<AuthController>()
//                   .profileModel!
//                   .restaurants!
//                   .first
//                   .foodWithVariance !=
//               'Yes') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Variants  :$variationText',
//             width: 8,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//         ]);
//       }
//       if (order.orderNote != '' &&
//           cart.foodDetails!.name!.toLowerCase().contains('out of')) {
//         isOutOfMenu = true;
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Notes: ${order.orderNote}',
//             width: 8,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//         ]);
//       }
//       if (cart.foodLevelNotes != '')
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Notes: ${cart.foodLevelNotes}',
//             width: 8,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//         ]);

//       bytes += generator.hr(ch: '....');
//     }

//     if (order.orderNote != '' && !isOutOfMenu) {
//       bytes += generator.text('${'Notes'.tr}:  ${order.orderNote}',
//           styles: PrinterConfig().foodStyle());
//     }
//     print('bytes length:${bytes.length}');
//     if (Platform.isIOS) {
//       await iosPrintEscPos(bytes, order);
//     } else {
//       await printEscPos(bytes, order);
//     }
//   }

//   Future printEscPos(List<int>? bytes, OrderList? order) async {
//     print('bytes length:${bytes!.length}');
//     // bytes += generator.feed(2);
//     // bytes += generator.cut();

//     // await PrinterManager.instance
//     //     .disconnect(type: PrinterType.bluetooth); //  what this do explain
//     BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
//         address: Get.find<AuthController>()
//             .profileModel!
//             .restaurantPrinterNew![currentPrintIndex]
//             .printerIp,
//         deviceName: Get.find<AuthController>()
//             .profileModel!
//             .restaurantPrinterNew![currentPrintIndex]
//             .printerName); //device name or ip was mandadory
//     try {
//       await _printerManager.connect(
//         type: bluetoothPrinter.typePrinter,
//         model: BluetoothPrinterInput(
//           name: bluetoothPrinter.deviceName,
//           address: bluetoothPrinter.address!,
//           isBle: bluetoothPrinter.isBle ?? false,
//         ),
//       );
//       pendingTask = null;
//     } catch (e) {
//       print('%%%%%%%$e');
//     }

//     if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//       try {
//         bool data = await _printerManager.send(
//             type: bluetoothPrinter.typePrinter, bytes: bytes);
//         Future.delayed(Duration(seconds: 2), () async {
//           // print('%%%%%%%%%%%%%isPrinted---$data');
//           bytes = null;
//           Get.find<LoadingController>().startLoading(false);
//           await Get.find<LoadingController>()
//               .changeText(data: 'Successfully printed!!');
//           await Get.find<LoadingController>().changeStatus(data: true);
//           await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//           currentPrintIndex = currentPrintIndex + 1;
//           dataCheck(order!);
//         });
//       } catch (e) {}
//     }
//   }

//   Future iosPrintEscPos(List<int>? bytes, OrderList? order) async {
//     print('########## bytes length ${bytes!.length}');
//     // bytes += generator.feed(2);
//     // bytes += generator.feed(2);
//     // bytes += generator.cut();

//     // await PrintBluetoothThermal.pairedBluetooths;

//     // Future.delayed(Duration(seconds: 5), () async {
//     if (Get.find<AuthController>()
//             .profileModel!
//             .restaurantPrinterNew![currentPrintIndex]
//             .macPrinterIp ==
//         '') {
//       // showErrorToast(
//       //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
//       isConnect = true;
//       isFailedPrint = true;
//       failedCartProductList[currentPrintIndex] =
//           cartProductList[currentPrintIndex];
//       currentPrintIndex = currentPrintIndex + 1;
//       dataCheck(order!);
//     } else {
//       final bool result = await PrintBluetoothThermal.connect(
//           macPrinterAddress: Get.find<AuthController>()
//               .profileModel!
//               .restaurantPrinterNew![currentPrintIndex]
//               .macPrinterIp!);
//       Future.delayed(Duration(seconds: 4), () async {
//         if (result) {
//           await PrintBluetoothThermal.writeBytes(bytes!);
//           Future.delayed(Duration(seconds: 4), () async {
//             bytes = null;
//             var isDisconnect = await PrintBluetoothThermal.disconnect;
//             print('is disconnect $isDisconnect');
//             currentPrintIndex = currentPrintIndex + 1;
//             dataCheck(order!);
//           });
//           print("print test result:  $result");
//         } else {
//           //no conectado, reconecte
//           // showErrorToast('Failed to bluetooth connect');
//           // showErrorToast(
//           //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
//           isConnect = true;
//           isFailedPrint = true;
//           failedCartProductList[currentPrintIndex] =
//               cartProductList[currentPrintIndex];
//           currentPrintIndex = currentPrintIndex + 1;
//           dataCheck(order!);
//         }
//       });
//     }
//     // });
//   }

//   dataCheck(OrderList order) async {
//     try {
//       if (currentPrintIndex <= cartProductList.length - 1) {
//         if (cartProductList[currentPrintIndex].isEmpty) {
//           for (var i = currentPrintIndex; i < cartProductList.length; i++) {
//             if (cartProductList[i].isEmpty) {
//               currentPrintIndex = currentPrintIndex + 1;
//               dataCheck(order);
//               break;
//             } else {
//               if (GetPlatform.isWindows) {
//                 final printers = await Printing.listPrinters();
//                 for (var element in printers) {
//                   if (element.isAvailable &&
//                       (element.name.toLowerCase() ==
//                           Get.find<AuthController>()
//                               .profileModel!
//                               .restaurantPrinterNew![currentPrintIndex]
//                               .wifiPrinterName!
//                               .toLowerCase())) {
//                     await Printing.directPrintPdf(
//                       printer: element,
//                       onLayout: (_) => WindowsPrintByteConvert().byteConvert(
//                           printType: 'kot',
//                           orderType: order.orderType!,
//                           stationName: cartProductList[currentPrintIndex]
//                                   .first
//                                   .station ??
//                               '',
//                           paperRoll: Get.find<AuthController>()
//                                       .profileModel!
//                                       .restaurantPrinterNew![currentPrintIndex]
//                                       .printerPaperRoll ==
//                                   58
//                               ? 58
//                               : 80,
//                           orderId: order.restaurantOrderId!,
//                           date:
//                               '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                           waiterName:
//                               '${order.vendorEmployee?.waiterName ?? ''}',
//                           tablename: order.restaurantTable == null ||
//                                   order.restaurantTable!.tableNo == ''
//                               ? order.orderType == 'delivery'
//                                   ? 'Delivery'
//                                   : order.orderType == 'take_away'
//                                       ? 'Take Away'
//                                       : 'WC'
//                               : order.restaurantTable!.title == ''
//                                   ? '${order.restaurantTable!.tableNo}'
//                                   : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                           custName: order.userName ?? '',
//                           custPhone: '${order.user?.phone ?? ''}',
//                           kotOrderList:
//                               cartProductList[currentPrintIndex] ?? [],
//                           orderNote: order.orderNote ?? ''),
//                       // generateKotPdf(order)
//                     );
//                     break;
//                   }
//                 }
//                 // await Printing.directPrintPdf(
//                 //   printer: printers.first,
//                 //   onLayout: (_) => generateKotPdf(order),
//                 // );
//                 currentPrintIndex = currentPrintIndex + 1;
//                 dataCheck(order);

//                 break;
//               } else {
//                 if (Platform.isIOS) {
//                   await iosPrintEscPos(
//                       await PrintByteConvert().byteConvert(
//                           printType: 'kot',
//                           orderType: order.orderType!,
//                           stationName: cartProductList[currentPrintIndex]
//                                   .first
//                                   .station ??
//                               '',
//                           paperRoll: Get.find<AuthController>()
//                                       .profileModel!
//                                       .restaurantPrinterNew![currentPrintIndex]
//                                       .printerPaperRoll ==
//                                   58
//                               ? 58
//                               : 80,
//                           orderId: order.restaurantOrderId!,
//                           date:
//                               '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                           waiterName:
//                               '${order.vendorEmployee?.waiterName ?? ''}',
//                           tablename: order.restaurantTable == null ||
//                                   order.restaurantTable!.tableNo == ''
//                               ? order.orderType == 'delivery'
//                                   ? 'Delivery'
//                                   : order.orderType == 'take_away'
//                                       ? 'Take Away'
//                                       : 'WC'
//                               : order.restaurantTable!.title == ''
//                                   ? '${order.restaurantTable!.tableNo}'
//                                   : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                           custName: order.userName ?? '',
//                           custPhone: '${order.user?.phone ?? ''}',
//                           kotOrderList:
//                               cartProductList[currentPrintIndex] ?? [],
//                           orderNote: order.orderNote ?? ''),
//                       order);
//                 } else {
//                   await printEscPos(
//                       await PrintByteConvert().byteConvert(
//                           printType: 'kot',
//                           orderType: order.orderType!,
//                           stationName: cartProductList[currentPrintIndex]
//                                   .first
//                                   .station ??
//                               '',
//                           paperRoll: Get.find<AuthController>()
//                                       .profileModel!
//                                       .restaurantPrinterNew![currentPrintIndex]
//                                       .printerPaperRoll ==
//                                   58
//                               ? 58
//                               : 80,
//                           orderId: order.restaurantOrderId!,
//                           date:
//                               '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                           waiterName:
//                               '${order.vendorEmployee?.waiterName ?? ''}',
//                           tablename: order.restaurantTable == null ||
//                                   order.restaurantTable!.tableNo == ''
//                               ? order.orderType == 'delivery'
//                                   ? 'Delivery'
//                                   : order.orderType == 'take_away'
//                                       ? 'Take Away'
//                                       : 'WC'
//                               : order.restaurantTable!.title == ''
//                                   ? '${order.restaurantTable!.tableNo}'
//                                   : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                           custName: order.userName ?? '',
//                           custPhone: '${order.user?.phone ?? ''}',
//                           kotOrderList:
//                               cartProductList[currentPrintIndex] ?? [],
//                           orderNote: order.orderNote ?? ''),
//                       order);
//                 }
//                 break;
//               }
//             }
//           }
//         } else {
//           if (GetPlatform.isWindows) {
//             final printers = await Printing.listPrinters();
//             for (var element in printers) {
//               if (element.isAvailable &&
//                   (element.name.toLowerCase() ==
//                       Get.find<AuthController>()
//                           .profileModel!
//                           .restaurantPrinterNew![currentPrintIndex]
//                           .wifiPrinterName!
//                           .toLowerCase())) {
//                 await Printing.directPrintPdf(
//                   printer: element,
//                   onLayout: (_) => WindowsPrintByteConvert().byteConvert(
//                       printType: 'kot',
//                       orderType: order.orderType,
//                       stationName:
//                           cartProductList[currentPrintIndex].first.station ??
//                               '',
//                       paperRoll: Get.find<AuthController>()
//                                   .profileModel!
//                                   .restaurantPrinterNew![currentPrintIndex]
//                                   .printerPaperRoll ==
//                               58
//                           ? 58
//                           : 80,
//                       orderId: order.restaurantOrderId,
//                       date:
//                           '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                       waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
//                       tablename: order.restaurantTable == null ||
//                               order.restaurantTable!.tableNo == ''
//                           ? order.orderType == 'delivery'
//                               ? 'Delivery'
//                               : order.orderType == 'take_away'
//                                   ? 'Take Away'
//                                   : 'WC'
//                           : order.restaurantTable!.title == ''
//                               ? '${order.restaurantTable!.tableNo}'
//                               : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                       custName: order.userName ?? '',
//                       custPhone: '${order.user?.phone ?? ''}',
//                       kotOrderList: cartProductList[currentPrintIndex] ?? [],
//                       orderNote: order.orderNote ?? ''),
//                   // generateKotPdf(order)
//                 );
//                 break;
//               }
//             }
//             currentPrintIndex = currentPrintIndex + 1;
//             dataCheck(order);
//           } else {
//             if (Platform.isIOS) {
//               await iosPrintEscPos(
//                   await PrintByteConvert().byteConvert(
//                       printType: 'kot',
//                       orderType: order.orderType!,
//                       stationName:
//                           cartProductList[currentPrintIndex].first.station ??
//                               '',
//                       paperRoll: Get.find<AuthController>()
//                                   .profileModel!
//                                   .restaurantPrinterNew![currentPrintIndex]
//                                   .printerPaperRoll ==
//                               58
//                           ? 58
//                           : 80,
//                       orderId: order.restaurantOrderId!,
//                       date:
//                           '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                       waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
//                       tablename: order.restaurantTable == null ||
//                               order.restaurantTable!.tableNo == ''
//                           ? order.orderType == 'delivery'
//                               ? 'Delivery'
//                               : order.orderType == 'take_away'
//                                   ? 'Take Away'
//                                   : 'WC'
//                           : order.restaurantTable!.title == ''
//                               ? '${order.restaurantTable!.tableNo}'
//                               : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
//                       custName: order.userName ?? '',
//                       custPhone: '${order.user?.phone ?? ''}',
//                       kotOrderList: cartProductList[currentPrintIndex] ?? [],
//                       orderNote: order.orderNote ?? ''),
//                   order);
//             } else {
//               await printEscPos(
//                   await PrintByteConvert().byteConvert(
//                       printType: 'kot',
//                       orderType: order.orderType!,
//                       stationName:
//                           cartProductList[currentPrintIndex].first.station ??
//                               '',
//                       paperRoll: Get.find<AuthController>()
//                                   .profileModel!
//                                   .restaurantPrinterNew![currentPrintIndex]
//                                   .printerPaperRoll ==
//                               58
//                           ? 58
//                           : 80,
//                       orderId: order.restaurantOrderId!,
//                       date:
//                           '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                       waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
//                       tablename: order.restaurantTable == null ||
//                               order.restaurantTable!.tableNo == ''
//                           ? order.orderType == 'delivery'
//                               ? 'Delivery'
//                               : order.orderType == 'take_away'
//                                   ? 'Take Away'
//                                   : 'WC'
//                           : order.restaurantTable!.title == ''
//                               ? '${order.restaurantTable!.tableNo}'
//                               : '${order.restaurantTable!.title}-${order.restaurantTable?.tableNo}',
//                       custName: order.userName ?? '',
//                       custPhone: '${order.user?.phone ?? ''}',
//                       kotOrderList: cartProductList[currentPrintIndex] ?? [],
//                       orderNote: order.orderNote ?? ''),
//                   order);
//             }
//           }
//         }
//       } else {
//         if (isFailedPrint) {
//           if (Platform.isAndroid) {
//             await _subscriptionBtStatus?.cancel();
//           }
//           await Get.bottomSheet(PrintDialog(
//             cartProductList: failedCartProductList,
//             index: Get.find<KdsController>().updatedOrderIndex,
//           ));
//           isProcessingOrder = false;
//           if (orderQueue.isNotEmpty) {
//             processNextOrder(); // Continue with the next order
//           }
//         }
//         isProcessingOrder = false;
//         if (orderQueue.isNotEmpty) {
//           processNextOrder(); // Continue with the next order
//         }
//       }
//     } catch (e) {
//       isProcessingOrder = false;
//       if (orderQueue.isNotEmpty) {
//         processNextOrder(); // Continue with the next order
//       }
//     }
//   }

//   // Future printDebug() async {
//   //   try {
//   //     Future.delayed(Duration(seconds: 2), () async {
//   //       // currentPrintIndex = currentPrintIndex + 1;
//   //       if (currentPrintIndex <= cartProductList.length - 1) {
//   //         if (cartProductList[currentPrintIndex].isEmpty) {
//   //           for (var i = currentPrintIndex; i < cartProductList.length; i++) {
//   //             if (cartProductList[i].isEmpty) {
//   //               currentPrintIndex = currentPrintIndex + 1;

//   //               printDebug();
//   //               break;
//   //             } else {
//   //               // await bytesConvert();
//   //               for (var j = 0;
//   //                   j < cartProductList[currentPrintIndex].length;
//   //                   j++) {
//   //                 print(
//   //                     'print name:${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName},   printfood$i${cartProductList[currentPrintIndex][i].foodDetails.name}');
//   //                 currentPrintIndex = currentPrintIndex + 1;

//   //                 printDebug();
//   //               }
//   //               break;
//   //             }
//   //           }
//   //         } else {
//   //           // currentPrintIndex = currentPrintIndex + 1;
//   //           // await bytesConvert();
//   //           for (var i = 0;
//   //               i < cartProductList[currentPrintIndex].length;
//   //               i++) {
//   //             print(
//   //                 'print name:${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName},printfood$i${cartProductList[currentPrintIndex][i].foodDetails.name}');
//   //           }

//   //           currentPrintIndex = currentPrintIndex + 1;
//   //           printDebug();
//   //         }
//   //       } else {}
//   //     });
//   //   } catch (e) {}
//   // }

//   /////////////
//   ///
//   ///
//   ///
//   ///
//   ///

//   Widget printSummaryDialog() {
//     return StatefulBuilder(builder: (context, setState) {
//       return Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
//             color: Colors.white),
//         child: Padding(
//             padding: EdgeInsets.only(
//                 left: 25,
//                 right: 25,
//                 top: 25,
//                 bottom: Dimensions.PADDING_SIZE_DEFAULT),
//             child: GetBuilder<KdsController>(builder: (kdsController) {
//               return SafeArea(
//                 top: false,
//                 child: SingleChildScrollView(
//                   child: Column(mainAxisSize: MainAxisSize.min, children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Select option for print',
//                           textAlign: TextAlign.center,
//                           style: poppinsMedium.copyWith(
//                               fontSize: MediaQuery.of(context).size.width > 1600
//                                   ? 20
//                                   : 18,
//                               color: Colors.black),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Get.back();
//                           },
//                           child: Icon(Icons.close,
//                               color: ColorTheme.appColor, size: 35),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     GetBuilder<LoadingController>(builder: (loadingController) {
//                       return ListView.builder(
//                           shrinkWrap: true,
//                           padding: EdgeInsets.zero,
//                           physics: BouncingScrollPhysics(),
//                           itemCount:
//                               Get.find<KdsController>().splitOrderList.length,
//                           itemBuilder: (BuildContext context, int index) {
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 10),
//                               child: InkWell(
//                                 onTap: () {
//                                   isSplitSelectPrinterList[index] =
//                                       !isSplitSelectPrinterList[index];
//                                   // isPrintKitchen = !isPrintKitchen;
//                                   loadingController.update();
//                                 },
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           height: MediaQuery.of(context)
//                                                       .size
//                                                       .width >
//                                                   1600
//                                               ? 70
//                                               : 30,
//                                           child: Checkbox(
//                                             activeColor: ColorTheme.appColor,
//                                             // value: true,
//                                             value:
//                                                 isSplitSelectPrinterList[index],
//                                             onChanged: (bool? isChecked) {
//                                               isSplitSelectPrinterList[index] =
//                                                   isChecked!;
//                                               loadingController.update();
//                                             },
//                                           ),
//                                         ),
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                     'Bill : ${Get.find<KdsController>().splitOrderList[index].restaurantTable == null ? 'WC' : Get.find<KdsController>().splitOrderList[index].restaurantTable!.title == '' ? '#${Get.find<KdsController>().splitOrderList[index].restaurantTable!.tableNo}' : '#${Get.find<KdsController>().splitOrderList[index].restaurantTable!.title}-${Get.find<KdsController>().splitOrderList[index].restaurantTable!.tableNo}'}',
//                                                     // 'Bill : ${Get.find<KdsController>().splitOrderList[index].id}',
//                                                     style: poppinsRegular.copyWith(
//                                                         color: Colors.black,
//                                                         fontSize: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width >
//                                                                 1600
//                                                             ? 17
//                                                             : 14)),
//                                                 // Spacer(),
//                                                 // if (index != 0) SizedBox(width: 10),
//                                                 // if (index != 0)
//                                                 //   Text('Amount: 100',
//                                                 //       // 'Amount: ${index == 1 ? PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice), isHideCurrency: true, asFixed: 2) : double.parse(customerData.orderAmount).toStringAsFixed(2)}',
//                                                 //       style: poppinsRegular.copyWith(
//                                                 //           fontSize:
//                                                 //               MediaQuery.of(context)
//                                                 //                           .size
//                                                 //                           .width >
//                                                 //                       1600
//                                                 //                   ? 17
//                                                 //                   : 11)),
//                                               ],
//                                             ),
//                                             // Row(
//                                             //   mainAxisAlignment:
//                                             //       MainAxisAlignment.spaceBetween,
//                                             //   children: [
//                                             //     if (index != 0)
//                                             //       Text(
//                                             //           // index == 1
//                                             //           // ? 'Date: ${DateFormat('dd-MMM').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse.orders.orderDetailsOrder.createdAt))}'
//                                             //           // : customerData.createdAt ==
//                                             //           //         ''
//                                             //           //     ? ''
//                                             //           'Date: ${DateFormat('dd-MMM').format(DateTime.parse(Get.find<KdsController>().splitOrderList[index].createdAt))}',
//                                             //           style: poppinsRegular.copyWith(
//                                             //               fontSize:
//                                             //                   MediaQuery.of(context)
//                                             //                               .size
//                                             //                               .width >
//                                             //                           1600
//                                             //                       ? 17
//                                             //                       : 11)),
//                                             //     // Spacer(),
//                                             //     if (index != 0) SizedBox(width: 10),
//                                             //   ],
//                                             // ),
//                                             Text(
//                                                 isSplitPrinterProccessingList[
//                                                         index]
//                                                     ? 'Status: Proccessing'
//                                                     : isSplitPrintedList[index]
//                                                         ? 'Status: Printed'
//                                                         : 'Status: Not Printed',
//                                                 style: poppinsMedium.copyWith(
//                                                     fontSize:
//                                                         MediaQuery.of(context)
//                                                                     .size
//                                                                     .width >
//                                                                 1600
//                                                             ? 15
//                                                             : 10,
//                                                     color: ColorTheme.blue)),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     Divider(),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           });
//                     }),
//                     SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
//                     InkWell(
//                       onTap: () async {
//                         // if (!kdsController.isProcessing) {
//                         splitCurrentPrintIndex = 0;
//                         if (Platform.isAndroid) {
//                           await _subscriptionBtStatus?.cancel();
//                           await _singleSplitBleStatus?.cancel();

//                           await listenBlutooth();
//                         }
//                         // kdsController.setProcessing(true);
//                         await dataCheckSplitBill();
//                         // }
//                       },
//                       child: SvgPicture.asset(
//                         Images.ic_print_kot,
//                         height: 26,
//                       ),
//                       // child: Container(
//                       //   padding: EdgeInsets.symmetric(
//                       //       horizontal: Dimensions.PADDING_SIZE_DEFAULT,
//                       //       vertical: Dimensions.PADDING_SIZE_SMALL),
//                       //   decoration: BoxDecoration(
//                       //       color: ColorTheme.appColor,
//                       //       borderRadius:
//                       //           BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//                       //   child: Text(
//                       //     kdsController.isProcessing ? 'Processing' : 'Print',
//                       //     style: poppinsMedium.copyWith(
//                       //         fontSize: MediaQuery.of(context).size.width > 1600
//                       //             ? 19
//                       //             : Dimensions.FONT_SIZE_LARGE,
//                       //         color: Colors.white),
//                       //   ),
//                       // ),
//                     ),
//                   ]),
//                 ),
//               );
//             })),
//       );
//     });
//   }

//   dataCheckSplitBill() async {
//     try {
//       if (splitCurrentPrintIndex <
//           Get.find<KdsController>().splitOrderList.length) {
//         if (isSplitSelectPrinterList[splitCurrentPrintIndex] == false) {
//           for (var i = splitCurrentPrintIndex;
//               i < Get.find<KdsController>().splitOrderList.length;
//               i++) {
//             if (isSplitSelectPrinterList[splitCurrentPrintIndex] == false) {
//               splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//               await dataCheckSplitBill();
//               break;
//             } else {
//               if (splitCurrentPrintIndex == 0) {
//                 if (GetPlatform.isWindows) {
//                   final printers = await Printing.listPrinters();
//                   for (var element in printers) {
//                     if (element.isAvailable &&
//                         (element.name.toLowerCase() ==
//                             Get.find<AuthController>()
//                                 .profileModel!
//                                 .wifiBillPrinterName!
//                                 .toLowerCase())) {
//                       await Printing.directPrintPdf(
//                         printer: element,
//                         onLayout: (_) => generateSplitBillPdf(),
//                       );
//                       break;
//                     }
//                   }
//                   splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//                   await dataCheckSplitBill();
//                 } else {
//                   await currentBillBytesConvert();
//                 }
//               } else
//                 Future.delayed(Duration(seconds: 3), () async {
//                   if (GetPlatform.isWindows) {
//                     final printers = await Printing.listPrinters();
//                     for (var element in printers) {
//                       if (element.isAvailable &&
//                           (element.name.toLowerCase() ==
//                               Get.find<AuthController>()
//                                   .profileModel!
//                                   .wifiBillPrinterName!
//                                   .toLowerCase())) {
//                         await Printing.directPrintPdf(
//                           printer: element,
//                           onLayout: (_) => generateSplitBillPdf(),
//                         );
//                         break;
//                       }
//                     }
//                     splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//                     dataCheckSplitBill();
//                   } else {
//                     await currentBillBytesConvert();
//                   }
//                 });

//               break;
//             }
//           }
//         } else {
//           if (splitCurrentPrintIndex == 0) {
//             if (GetPlatform.isWindows) {
//               final printers = await Printing.listPrinters();
//               for (var element in printers) {
//                 if (element.isAvailable &&
//                     (element.name.toLowerCase() ==
//                         Get.find<AuthController>()
//                             .profileModel!
//                             .wifiBillPrinterName!
//                             .toLowerCase())) {
//                   await Printing.directPrintPdf(
//                     printer: element,
//                     onLayout: (_) => generateSplitBillPdf(),
//                   );
//                   break;
//                 }
//               }
//               splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//               dataCheckSplitBill();
//             } else {
//               await currentBillBytesConvert();
//             }
//           } else
//             Future.delayed(Duration(seconds: 3), () async {
//               if (GetPlatform.isWindows) {
//                 final printers = await Printing.listPrinters();
//                 for (var element in printers) {
//                   if (element.isAvailable &&
//                       (element.name.toLowerCase() ==
//                           Get.find<AuthController>()
//                               .profileModel!
//                               .wifiBillPrinterName!
//                               .toLowerCase())) {
//                     await Printing.directPrintPdf(
//                       printer: element,
//                       onLayout: (_) => generateSplitBillPdf(),
//                     );
//                     break;
//                   }
//                 }
//                 splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//                 dataCheckSplitBill();
//               } else {
//                 await currentBillBytesConvert();
//               }
//             });
//         }
//       } else {
//         Future.delayed(Duration(seconds: 10), () async {
//           if (Platform.isIOS) {
//             await PrintBluetoothThermal.disconnect;
//           } else {
//             await PrinterManager.instance
//                 .disconnect(type: PrinterType.bluetooth);
//           }
//           Get.find<LoadingController>().changeStatus(data: true);
//         });
//         // Execute function After last bill printed
//       }
//     } catch (e) {}
//   }

//   Future currentBillBytesConvert() async {
//     List<OrderDetails> foodOrderList = [];
//     List<int> bytes = [];
//     ProfileModel profileModel = Get.find<AuthController>().profileModel!;
//     foodOrderList.addAll(Get.find<KdsController>()
//         .splitOrderList[splitCurrentPrintIndex]
//         .orderDetails!);

//     final profile = await CapabilityProfile.load(name: 'XP-N160I');
//     final generator = Generator(
//         profileModel.billPrinterPaperRoll == 58
//             ? PaperSize.mm58
//             : PaperSize.mm80,
//         profile);
//     bytes += generator.setGlobalCodeTable('CP1252');

//     if (logoHelper.logoUrlPrint != null) {
//       try {
//         bytes += generator.feed(1);
//         bytes += generator.image(logoHelper.logoUrlPrint!);
//       } catch (e) {
//         print(e);
//       }
//     }
//     bytes += generator.text(profileModel.restaurants![0].name!,
//         styles: PrinterConfig().titleStyle());
//     bytes += generator.text(profileModel.restaurants![0].address!,
//         styles: PrinterConfig().addressStyle());
//     if (profileModel.restaurants![0].gstCode != '')
//       bytes += generator.text('GST no. ${profileModel.restaurants![0].gstCode}',
//           styles: PrinterConfig().gstStyle());
//     if (profileModel.restaurants![0].fssai != '')
//       bytes += generator.text('FSI no. ${profileModel.restaurants![0].fssai}',
//           styles: PrinterConfig().gstStyle());

//     bytes += generator.row([
//       PosColumn(
//           text: 'order_id'.tr +
//               ':' +
//               ' ${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantOrderId == '0' ? Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].id : Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantOrderId}',
//           width: 6,
//           styles: PrinterConfig().orderIdStyle()),
//       PosColumn(
//           text:
//               '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//           width: 6,
//           styles: PrinterConfig().orderCreateDateStyle()),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//           text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
//       PosColumn(
//         text: '',
//         width: 1,
//         styles: PosStyles(align: PosAlign.center),
//       ),
//       PosColumn(
//           text:
//               '${Get.find<KdsController>().splitOrderList.first.vendorEmployee?.waiterName ?? ''}',
//           width: 6,
//           styles: PrinterConfig().waiterNameStyle()),
//     ]);

//     bytes += generator.row([
//       PosColumn(
//         text:
//             '${Get.find<KdsController>().splitOrderList.first.user?.fName ?? ''}',
//         width: 5,
//         styles: PosStyles(
//           height:
//               Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')
//                       .first),
//           width: Get.find<AuthController>().profileModel!.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel!
//                   .printConfig!
//                   .restaurantFoodList!
//                   .split(',')[1]),
//           bold: Get.find<AuthController>().profileModel!.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList ==
//                       null
//               ? false
//               : Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList!
//                           .split(',')
//                           .last ==
//                       'true'
//                   ? true
//                   : false,
//           align: PosAlign.left,
//         ),
//       ),
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text:
//             '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].user?.fName ?? ''}',
//         width: 5,
//         styles: PosStyles(
//           height:
//               Get.find<AuthController>().profileModel!.printConfig == null ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .printConfig!
//                               .restaurantFoodList ==
//                           null
//                   ? PosTextSize.size1
//                   : PrinterConfig().fonstSize(Get.find<AuthController>()
//                       .profileModel!
//                       .printConfig!
//                       .restaurantFoodList!
//                       .split(',')
//                       .first),
//           width: Get.find<AuthController>().profileModel!.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel!
//                   .printConfig!
//                   .restaurantFoodList!
//                   .split(',')[1]),
//           bold: Get.find<AuthController>().profileModel!.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList ==
//                       null
//               ? false
//               : Get.find<AuthController>()
//                           .profileModel!
//                           .printConfig!
//                           .restaurantFoodList!
//                           .split(',')
//                           .last ==
//                       'true'
//                   ? true
//                   : false,
//           align: PosAlign.right,
//           fontType: PosFontType.fontB,
//         ),
//       ),
//     ]);

//     bytes += generator.row([
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//           // fontType: PosFontType.fontB,
//         ),
//       ),
//       PosColumn(
//           text: Get.find<KdsController>()
//                           .splitOrderList[splitCurrentPrintIndex]
//                           .restaurantTable ==
//                       null ||
//                   Get.find<KdsController>()
//                           .splitOrderList[splitCurrentPrintIndex]
//                           .restaurantTable!
//                           .tableNo ==
//                       ''
//               ? 'WC'
//               : Get.find<KdsController>()
//                           .splitOrderList[splitCurrentPrintIndex]
//                           .restaurantTable!
//                           .title ==
//                       ''
//                   ? '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.tableNo}'
//                   : '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.title}:${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.tableNo}',
//           width: 8,
//           styles: PrinterConfig().tableNoStyle()),
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//           fontType: PosFontType.fontB,
//         ),
//       ),
//     ]);
//     bytes += generator.hr(ch: '--');

//     bytes += generator.row([
//       PosColumn(text: 'SL', width: 2, styles: PrinterConfig().foodStyle()),
//       PosColumn(
//         text: 'item_info'.tr,
//         width: 5,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'qty'.tr,
//         width: 2,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'Price',
//         width: 3,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '--');
//     double subTotal = 0;
//     double grandTotal = 0;
//     double gstTotal = 0;
//     double vatTotal = 0;
//     double serviceCharge = 0;
//     for (var i = 0; i < foodOrderList.length; i++) {
//       OrderDetails food = foodOrderList[i];
//       String variationText = '';
//       String addons = '';

//       double itemPrice = 0;
//       int variationTotal = 0;
//       double addonsTotal = 0;
//       double gstCharge = 0;
//       double vatCharge = 0;

//       if (splitCurrentPrintIndex == 0) {
//         if (!food.isSplited) itemPrice = itemPrice + food.price!;
//       } else {
//         itemPrice = itemPrice + food.price!;
//       }
//       if (food.variation != null && food.variation!.isNotEmpty) {
//         variationText += '(';
//         List<String> labelList = [];
//         for (int j = 0; j < food.variation!.length; j++) {
//           // variationText +=
//           //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

//           if (food.variation![j].values != null) {
//             // List<String> labelList = [];
//             for (var element in food.variation![j].values!) {
//               labelList.add(element.level!);
//               if (splitCurrentPrintIndex == 0) {
//                 if (!food.isSplited) {
//                   itemPrice = itemPrice +
//                       (double.parse(element.optionPrice!) * food.quantity!);
//                   variationTotal +=
//                       (int.parse(element.optionPrice!) * food.quantity!);
//                 }
//               } else {
//                 itemPrice = itemPrice +
//                     (double.parse(element.optionPrice!) * food.quantity!);
//                 variationTotal +=
//                     (int.parse(element.optionPrice!) * food.quantity!);
//               }
//             }
//           }
//         }
//         variationText += '${labelList.join(',')}';
//         variationText += ')';
//       }
//       for (var i = 0; i < food.addOns!.length; i++) {
//         if (splitCurrentPrintIndex == 0) {
//           if (!food.isSplited) {
//             itemPrice = itemPrice +
//                 (food.addOns![i].qty! * food.addOns![i].price!).toDouble();
//             addonsTotal = addonsTotal +
//                 ((food.addOns![i].price! * food.addOns![i].qty!) *
//                     food.quantity!);
//           }
//         } else {
//           itemPrice = itemPrice +
//               (food.addOns![i].qty! * food.addOns![i].price!).toDouble();
//           addonsTotal = addonsTotal +
//               ((food.addOns![i].price! * food.addOns![i].qty!) *
//                   food.quantity!);
//         }
//         addons += '${food.addOns![i].name} (${food.addOns![i].qty})';
//       }
//       subTotal += itemPrice;
//       // if (food.foodType == 'FOOD') {
//       if (splitCurrentPrintIndex == 0) {
//         if (!food.isSplited &&
//             Get.find<AuthController>()
//                     .profileModel!
//                     .restaurants!
//                     .first
//                     .gstStatus ==
//                 'true' &&
//             food.foodDetails!.taxType != null &&
//             food.foodDetails!.taxType != '' &&
//             food.foodDetails!.taxType == 'GST' &&
//             food.foodDetails!.taxCalc != null &&
//             food.foodDetails!.taxCalc != '' &&
//             food.foodDetails!.taxCalc == 'Exclusive') {
//           gstCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//           gstTotal += gstCharge;
//         } else if (!food.isSplited &&
//             Get.find<AuthController>()
//                     .profileModel!
//                     .restaurants!
//                     .first
//                     .gstStatus ==
//                 'true' &&
//             food.foodDetails!.taxType != null &&
//             food.foodDetails!.taxType != '' &&
//             food.foodDetails!.taxType == 'VAT' &&
//             food.foodDetails!.taxCalc != null &&
//             food.foodDetails!.taxCalc != '' &&
//             food.foodDetails!.taxCalc == 'Exclusive') {
//           vatCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//           vatTotal += vatCharge;
//         }
//       } else {
//         if (Get.find<AuthController>()
//                     .profileModel!
//                     .restaurants!
//                     .first
//                     .gstStatus ==
//                 'true' &&
//             food.foodDetails!.taxType != null &&
//             food.foodDetails!.taxType != '' &&
//             food.foodDetails!.taxType == 'GST' &&
//             food.foodDetails!.taxCalc != null &&
//             food.foodDetails!.taxCalc != '' &&
//             food.foodDetails!.taxCalc == 'Exclusive') {
//           gstCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//           gstTotal += gstCharge;
//         } else if (Get.find<AuthController>()
//                     .profileModel!
//                     .restaurants!
//                     .first
//                     .gstStatus ==
//                 'true' &&
//             food.foodDetails!.taxType != null &&
//             food.foodDetails!.taxType != '' &&
//             food.foodDetails!.taxType == 'VAT' &&
//             food.foodDetails!.taxCalc != null &&
//             food.foodDetails!.taxCalc != '' &&
//             food.foodDetails!.taxCalc == 'Exclusive') {
//           vatCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//           vatTotal += vatCharge;
//         }
//       }
//       // }
//       // if (food.foodType == 'BAR') {
//       //   if (splitCurrentPrintIndex == 0) {
//       //     if (!food.isSplited) {
//       //       vatCharge = (itemPrice *
//       //               Get.find<AuthController>()
//       //                   .profileModel
//       //                   .restaurants[0]
//       //                   .tax) /
//       //           100;
//       //       vatTotal += vatCharge;
//       //     }
//       //   } else {
//       //     vatCharge = (itemPrice *
//       //             Get.find<AuthController>().profileModel.restaurants[0].tax) /
//       //         100;
//       //     vatTotal += vatCharge;
//       //   }
//       // }
//       if (splitCurrentPrintIndex == 0) {
//         if (!food.isSplited) {
//           serviceCharge += Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .serviceCharge ==
//                       'Yes' &&
//                   Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .autoServiceCharge ==
//                       'Yes'
//               ? ((itemPrice * 10) / 100)
//               : 0;
//         }
//       } else {
//         serviceCharge += Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .serviceCharge ==
//                     'Yes' &&
//                 Get.find<AuthController>()
//                         .profileModel!
//                         .restaurants!
//                         .first
//                         .autoServiceCharge ==
//                     'Yes'
//             ? ((itemPrice * 10) / 100)
//             : 0;
//       }
//       grandTotal = grandTotal + itemPrice;

//       bytes += generator.row([
//         PosColumn(
//             text: '${i + 1}.',
//             width: 2,
//             styles: PrinterConfig().foodStyle(
//                 isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//         PosColumn(
//             text: '${food.foodDetails!.name} $variationText',
//             width: 5,
//             styles: PrinterConfig().foodStyle(
//                 isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//         PosColumn(
//             text: '${food.quantity}',
//             width: 2,
//             styles: PrinterConfig().foodStyle(
//                 isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//         PosColumn(
//             text:
//                 '${((food.unitPrice! * food.quantity!) + variationTotal).toStringAsFixed(2)}',

//             // '${(food.unitPrice * food.quantity) + (variationTotal) + (addonsTotal)}',
//             width: 3,
//             styles: PrinterConfig().foodStyle(
//                 isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//       ]);
//       if (addons != '' && addonsTotal != 0) {
//         bytes += generator.hr(ch: '....');
//         bytes += generator.row([
//           PosColumn(text: '', width: 2, styles: PrinterConfig().foodStyle()),
//           PosColumn(
//               text: 'Add-Ons :$addons',
//               width: 5,
//               styles: PrinterConfig().foodStyle(
//                   isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//           PosColumn(text: '', width: 2, styles: PrinterConfig().foodStyle()),
//           PosColumn(
//               text: '$addonsTotal',
//               width: 3,
//               styles: PrinterConfig().foodStyle()),
//         ]);
//       }
//       // if (variationText != '' && variationTotal != 0) {
//       //   bytes += generator.hr(ch: '....');
//       //   bytes += generator.row([
//       //     PosColumn(
//       //       text: '',
//       //       width: 2,
//       //       styles: PosStyles(
//       //         align: PosAlign.center,
//       //       ),
//       //     ),
//       //     PosColumn(
//       //         text: 'Variants  :$variationText',
//       //         width: 5,
//       //         styles: PrinterConfig().foodStyle(
//       //             isUnderLine: splitCurrentPrintIndex == 0 && food.isSplited)),
//       //     PosColumn(
//       //       text: '',
//       //       width: 2,
//       //       styles: PosStyles(align: PosAlign.center),
//       //     ),
//       //     PosColumn(
//       //       text: '$variationTotal',
//       //       width: 3,
//       //       styles: PosStyles(align: PosAlign.center),
//       //     ),
//       //   ]);
//       // }

//       bytes += generator.hr(ch: '....');
//     }

//     bytes += generator.hr(ch: '....');

//     bytes += generator.row([
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         ),
//       ),
//       PosColumn(
//         text: 'Sub Total ',
//         width: 5,
//         styles: PrinterConfig().subtotalStyle(),
//       ),
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(align: PosAlign.center),
//       ),
//       PosColumn(
//           text:
//               '${PriceConverter.convertPrice(subTotal, isHideCurrency: true, asFixed: 2)}',
//           width: 3,
//           styles: PrinterConfig().subtotalStyle()),
//     ]);

//     if (serviceCharge != 0)
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'Service Charge',
//             width: 5,
//             styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(serviceCharge,
//                 isHideCurrency: true, asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     if (gstTotal != 0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'CGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(gstTotal / 2,
//                 isHideCurrency: true, asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     }
//     if (gstTotal != 0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'SGST ', width: 5, styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(gstTotal / 2,
//                 isHideCurrency: true, asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     }
//     if (vatTotal != 0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//             text: 'VAT ', width: 5, styles: PrinterConfig().subtotalStyle()),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//             text: PriceConverter.convertPrice(vatTotal,
//                 isHideCurrency: true, asFixed: 2),
//             width: 3,
//             styles: PrinterConfig().subtotalStyle()),
//       ]);
//     }

//     bytes += generator.hr(ch: '....');
//     bytes += generator.text(
//         'Total: ' +
//             '${PriceConverter.convertPrice(grandTotal + serviceCharge + gstTotal + vatTotal, isHideCurrency: true, asFixed: 2)} ${profileModel.restaurants?.first.currency ?? ''}',
//         styles: PrinterConfig().totalStyle());

//     bytes += generator.hr(ch: '....');

//     try {
//       const double qrSize = 170;
//       final uiImg = await QrPainter(
//         data:
//             'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${grandTotal + serviceCharge + gstTotal + vatTotal}&tn=',
//         version: QrVersions.auto,
//         gapless: false,
//       ).toImageData(qrSize);
//       final dir = await getTemporaryDirectory();
//       final pathName = '${dir.path}/qr_tmp.png';
//       final qrFile = File(pathName);
//       final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
//       final img = prefix.decodeImage(imgFile.readAsBytesSync());

//       bytes += generator.text('Scan to pay',
//           styles: const PosStyles(
//               align: PosAlign.center,
//               height: PosTextSize.size1,
//               width: PosTextSize.size1,
//               bold: true,
//               fontType: PosFontType.fontA));

//       bytes += generator.feed(1);
//       bytes += generator.image(img!);
//       bytes += generator.feed(1);

//       // bytes += generator.feed(1);
//     } catch (e) {
//       print(e);
//     }

//     if (Get.find<AuthController>()
//             .profileModel!
//             .restaurants!
//             .first
//             .footerTextBill !=
//         '') {
//       bytes += generator.text(
//           Get.find<AuthController>()
//               .profileModel!
//               .restaurants!
//               .first
//               .footerTextBill!,
//           styles: const PosStyles(
//               align: PosAlign.center,
//               height: PosTextSize.size1,
//               width: PosTextSize.size1,
//               // bold: true,
//               fontType: PosFontType.fontB));
//     }
//     bytes += generator.text('Powered by MyGenie',
//         styles: const PosStyles(
//             align: PosAlign.center,
//             height: PosTextSize.size1,
//             width: PosTextSize.size1,
//             // bold: true,
//             fontType: PosFontType.fontB));
//     bytes += generator.cut();

//     if (Platform.isAndroid) {
//       await _kdsPrintEscPos(bytes, generator); //kitchen
//     } else {
//       await _iosPrintEscPos(bytes, generator); //kitchen
//     }
//   }

//   /// print ticket
//   // Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
//   //   bytes += generator.cut();
//   //   // await printerManager.disconnect(type: PrinterType.bluetooth);
//   //   print('bytes length: ${bytes.length}');
//   //   BluetoothPrinter bluetoothPrinter = await BluetoothPrinter(
//   //       // address: 'DC:0D:30:20:3C:D5');
//   //       address: Get.find<AuthController>().profileModel.billPrinterIp,
//   //       deviceName: Get.find<AuthController>()
//   //           .profileModel
//   //           .billPrinterName); // ip was mandadory
//   //   await _printerManager.connect(
//   //     type: bluetoothPrinter.typePrinter,
//   //     model: BluetoothPrinterInput(
//   //       name: bluetoothPrinter.deviceName,
//   //       address: bluetoothPrinter.address,
//   //     ),
//   //   );
//   //   switch (bluetoothPrinter.typePrinter) {
//   //     case PrinterType.bluetooth:
//   //       bytes += generator.cut();
//   //       await _printerManager.connect(
//   //         type: bluetoothPrinter.typePrinter,
//   //         model: BluetoothPrinterInput(
//   //           name: bluetoothPrinter.deviceName,
//   //           address: bluetoothPrinter.address,
//   //           isBle: bluetoothPrinter.isBle ?? false,
//   //         ),
//   //       );

//   //       break;

//   //     default:
//   //   }
//   //   if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//   //     try {
//   //       await _printerManager.send(
//   //           type: bluetoothPrinter.typePrinter, bytes: bytes);
//   //       isSplitPrintedList[splitCurrentPrintIndex] =
//   //           true; //It show status of start print
//   //       isSplitPrinterProccessingList[splitCurrentPrintIndex] = false;
//   //       splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//   //       Get.find<LoadingController>().update();
//   //       dataCheckSplitBill();
//   //       // if (setState == null) Future.delayed(duration);

//   //       // Future.delayed(Duration(seconds: 15), () async {
//   //       //   await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//   //       // });
//   //       // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//   //     } catch (e) {}
//   //   } else {
//   //     // printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//   //   }
//   // }
//   /// print ticket
//   Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
//     // await printerManager.disconnect(type: PrinterType.bluetooth);
//     BluetoothPrinter bluetoothPrinter;
//     if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
//       bluetoothPrinter = await BluetoothPrinter(
//           productId: Get.find<AuthController>().profileModel!.billProductId,
//           vendorId: Get.find<AuthController>().profileModel!.billVendorId,
//           typePrinter: PrinterType.usb);
//     } else {
//       bluetoothPrinter = await BluetoothPrinter(
//           address: Get.find<AuthController>().profileModel!.billPrinterIp,
//           deviceName: Get.find<AuthController>()
//               .profileModel!
//               .billPrinterName); // ip was mandadory
//     }

//     var data;
//     if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
//       data = await _printerManager.connect(
//         type: PrinterType.usb,
//         model: UsbPrinterInput(
//           productId: Get.find<AuthController>().profileModel!.billProductId,
//           vendorId: Get.find<AuthController>().profileModel!.billVendorId,
//         ),
//       );
//     } else {
//       data = await _printerManager.connect(
//         type: bluetoothPrinter.typePrinter,
//         model: BluetoothPrinterInput(
//           name: bluetoothPrinter.deviceName,
//           address: bluetoothPrinter.address!,
//         ),
//       );
//     }
//     switch (bluetoothPrinter.typePrinter) {
//       case PrinterType.usb:
//         bytes += generator.feed(2);
//         await _printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: UsbPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             productId: bluetoothPrinter.productId,
//             vendorId: bluetoothPrinter.vendorId,
//           ),
//         );
//         break;
//       case PrinterType.bluetooth:
//         await _printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: BluetoothPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             address: bluetoothPrinter.address!,
//             isBle: bluetoothPrinter.isBle ?? false,
//           ),
//         );
//         pendingTask = null;
//         if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
//         break;
//       case PrinterType.network:
//         bytes += generator.feed(2);
//         await _printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
//         );
//         break;
//       default:
//     }
//     print(data);

//     try {
//       await _printerManager.send(
//           type: bluetoothPrinter.typePrinter, bytes: bytes);
//       isSplitPrintedList[splitCurrentPrintIndex] =
//           true; //It show status of start print
//       isSplitPrinterProccessingList[splitCurrentPrintIndex] = false;
//       splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//       Get.find<LoadingController>().update();
//       dataCheckSplitBill();
//       // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//     } catch (e) {}
//     if (data != null && !data) {
//       // await Get.find<LoadingController>().changeText(
//       //     data: Get.find<AuthController>().profileModel.billPrinterType == 'usb'
//       //         ? 'Failed to usb connect!!'
//       //         : 'Failed to bluetooth connect!!',
//       //     error: true);
//       // await Get.find<LoadingController>().changeStatus(data: true);
//     }
//   }

//   Future _iosPrintEscPos(List<int> bytes, Generator generator) async {
//     print('########## bytes length ${bytes.length}');
//     bytes += generator.feed(2);
//     try {
//       if (Get.find<AuthController>().profileModel!.macBillPrinterIp == '') {
//         showErrorToast('Failed to bluetooth connect');
//         isSplitPrintedList[splitCurrentPrintIndex] =
//             false; //It show status of start print
//         isSplitPrinterProccessingList[splitCurrentPrintIndex] = false;
//         splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//         dataCheckSplitBill();
//       } else {
//         await PrintBluetoothThermal.pairedBluetooths;

//         // Future.delayed(Duration(seconds: 5), () async {
//         final bool result = await PrintBluetoothThermal.connect(
//             macPrinterAddress:
//                 Get.find<AuthController>().profileModel!.macBillPrinterIp!);

//         Future.delayed(Duration(seconds: 4), () async {
//           if (result) {
//             // List<int> ticket = await testTicket();
//             await PrintBluetoothThermal.writeBytes(bytes);
//             Get.find<LoadingController>().startLoading(false);
//             await Get.find<LoadingController>()
//                 .changeText(data: 'Successfully printed!!');
//             await Get.find<LoadingController>().changeStatus(data: true);
//             isSplitPrintedList[splitCurrentPrintIndex] =
//                 true; //It show status of start print
//             isSplitPrinterProccessingList[splitCurrentPrintIndex] = false;
//             splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
//             Get.find<LoadingController>().update();
//             dataCheckSplitBill();
//           } else {
//             Get.find<KdsController>().setProcessing(false);
//             Get.find<LoadingController>().startLoading(false);

//             await Get.find<LoadingController>()
//                 .changeText(data: 'Failed to bluetooth connect!!', error: true);
//             await Get.find<LoadingController>().changeStatus(data: true);
//           }
//         });
//       }
//     } catch (e) {
//       Get.find<LoadingController>().startLoading(false);

//       await Get.find<LoadingController>()
//           .changeText(data: 'Failed to bluetooth connect!!', error: true);
//       await Get.find<LoadingController>().changeStatus(data: true);
//     }

//     // });
//   }

//   Future<void> setupInteractedMessage() async {
//     // Get any messages which caused the application to open from
//     // a terminated state.
//     RemoteMessage initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage() ?? RemoteMessage();
//     _handleMessage(initialMessage);
//   }

//   // when app is in background
//   void _handleMessage(RemoteMessage message) {}

//   Future<dynamic> onSelectNotification(NotificationResponse payload) async {
//     // implement the navigation logic
//     if (Platform.isAndroid) {
//       var jsonData = jsonDecode(payload.payload!);
//       // print('$jsonData');
//       if (jsonData != null) {
//         // print('===============${message.data}');
//       }
//     }
//   }

//   Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     await Firebase.initializeApp();
//     print('..................message');
//   }

//   void processNextOrder() async {
//     // If no orders in the queue or an order is currently being processed, return.
//     if (orderQueue.isEmpty || isProcessingOrder) return;

//     // Mark as processing
//     isProcessingOrder = true;

//     // Remove the next order from the queue
//     var currentOrder = orderQueue.removeAt(0); // Get and remove the first order

//     try {
//       currentPrintIndex = 0;
//       cartProductList = [];
//       failedCartProductList = [];
//       skipFailedList = [];
//       isFailedPrint = false;

//       for (var i = 0;
//           i <
//               Get.find<AuthController>()
//                   .profileModel!
//                   .restaurantPrinterNew!
//                   .length;
//           i++) {
//         RestaurantPrinterNew printer =
//             Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
//         skipFailedList.add(false);
//         List<OrderDetails> tempCartList = [];
//         var foodList = currentOrder.orderDetails;
//         for (var e in foodList!) {
//           if (e.station == printer.areaName && e.foodStatus != 3) {
//             tempCartList.add(e);
//           }
//         }
//         cartProductList.add(tempCartList);
//         failedCartProductList.add([]);
//       }
//       if (Platform.isAndroid) {
//         await _subscriptionBtStatus?.cancel();
//         await _singleSplitBleStatus?.cancel();

//         await listenBlutooth(order: currentOrder);
//       }
//       dataCheck(currentOrder);
//       // printDebug();
//       // Your byte conversion or printing logic here
//       // Simulate byte conversion or printing process for the current order
//       // await Future.delayed(Duration(seconds: 2)); // Simulate async processing
//     } finally {
//       // After processing, mark as not processing
//       // isProcessingOrder = false;

//       // If there are more orders in the queue, process the next one
//       if (orderQueue.isNotEmpty) {
//         processNextOrder(); // Continue with the next order
//       }
//     }
//   }

//   // Method to check and add an order to the queue
//   void checkQueueProcess(OrderList order) {
//     // Add the new order to the queue
//     orderQueue.add(order);

//     // Start processing the next order if not already processing
//     if (!isProcessingOrder) {
//       processNextOrder();
//     }
//   }

//   void processNextOrderFromSocket() async {
//     // If no orders in the queue or an order is currently being processed, return.
//     if (orderIdQueue.isEmpty || isProcessingOrderQueue) return;

//     // Mark as processing
//     isProcessingOrderQueue = true;

//     // Remove the next order from the queue
//     var currentOrder =
//         orderIdQueue.removeAt(0); // Get and remove the first order

//     try {
//       // Your byte conversion or printing logic here
//       // Simulate byte conversion or printing process for the current order

//       var isCallApi = await Get.find<KdsController>().getOrderDetailFromSocket(
//           socket: socket,
//           foodStatus: currentOrder.orderType == 'update-food-status'
//               ? '${currentOrder.orderOthervalue}'
//               : '0',
//           type: currentOrder.orderType,
//           orderId: '${currentOrder.orderId}',
//           socketJson: currentOrder.orderType == 'new-order'
//               ? currentOrder.newOrderJson
//               : null,
//           callbackFunction: (OrderList order) async {
//             await Future.delayed(
//                 Duration(seconds: 2)); // Simulate async processing
//             checkQueueProcess(order);
//           });

//       if (currentOrder.orderType == 'new-order' &&
//           Get.find<AuthController>().profileModel!.empId.toString() ==
//               Get.find<KdsController>()
//                   .getWaiterOrderListResponse!
//                   .orders!
//                   .last
//                   .waiterId
//                   .toString() &&
//           Get.find<KdsController>()
//                   .getWaiterOrderListResponse!
//                   .orders!
//                   .last
//                   .orderDetails!
//                   .length ==
//               1 &&
//           Get.find<KdsController>()
//                   .getWaiterOrderListResponse!
//                   .orders!
//                   .last
//                   .orderDetails!
//                   .first
//                   .foodDetails!
//                   .name!
//                   .toUpperCase() ==
//               'CHECK IN') {
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           _scrollController.animateTo(
//               _scrollController.position.maxScrollExtent,
//               duration: const Duration(milliseconds: 1),
//               curve: Curves.fastOutSlowIn);
//         });
//       }
//       if ((Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .printingOption ==
//                   'Waiter' ||
//               (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .printingOption ==
//                       'Fixed' &&
//                   (currentOrder.orderType == 'update-order'
//                       ? Get.find<KdsController>()
//                               .getWaiterOrderListResponse!
//                               .orders![
//                                   Get.find<KdsController>().updatedOrderIndex]
//                               .isPrintKot ==
//                           'Yes'
//                       : false))) &&
//           isCallApi != null &&
//           isCallApi &&
//           Get.find<AuthController>()
//                   .profileModel!
//                   .restaurants!
//                   .first
//                   .printKot ==
//               'Yes') {
//         List<OrderDetails> tempCartList = [];
//         if (currentOrder.orderType == 'update-order' ||
//             currentOrder.orderType == 'update-order-status') {
//           var foodList = Get.find<KdsController>()
//               .getWaiterOrderListResponse!
//               .orders![Get.find<KdsController>().updatedOrderIndex]
//               .orderDetails;

//           for (var e in foodList!) {
//             if (currentOrder.orderType == 'update-order-status') {
//               if (e.foodStatus != 3) {
//                 tempCartList.add(e);
//               }
//             } else if (currentOrder.orderType == 'update-order') {
//               if (e.foodStatus != 3 &&
//                   Get.find<KdsController>()
//                           .getWaiterOrderListResponse!
//                           .orders![Get.find<KdsController>().updatedOrderIndex]
//                           .editOrderCount ==
//                       e.itemUpdateCount) {
//                 tempCartList.add(e);
//               }
//             }
//           }
//           if (tempCartList.isNotEmpty) {
//             OrderList tempOrder = OrderList(
//                 fOrderStatus: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .fOrderStatus,
//                 editOrderCount: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .editOrderCount,
//                 orderNote: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .orderNote,
//                 orderType: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .orderType,
//                 restaurantOrderId: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .restaurantOrderId,
//                 userName: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .userName,
//                 vendorEmployee: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .vendorEmployee,
//                 deliveryAddress: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .deliveryAddress,
//                 orderDetails: tempCartList,
//                 serveOrderDetails: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .serveOrderDetails,
//                 readyDetails: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .readyDetails,
//                 restaurantTable: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .restaurantTable,
//                 user: Get.find<KdsController>()
//                     .getWaiterOrderListResponse!
//                     .orders![Get.find<KdsController>().updatedOrderIndex]
//                     .user);
//             Future.delayed(Duration(seconds: 2));
//             checkQueueProcess(tempOrder);
//           }
//         }
//       }

//       await Future.delayed(Duration(seconds: 3)); // Simulate async processing
//     } finally {
//       // After processing, mark as not processing
//       isProcessingOrderQueue = false;

//       // If there are more orders in the queue, process the next one
//       if (orderIdQueue.isNotEmpty) {
//         processNextOrderFromSocket(); // Continue with the next order
//       }
//     }
//   }

//   // Method to check and add an order to the queue
//   void checkQueueProcessFromSocket(
//       {String? orderType,
//       String? orderId,
//       String? otherValue,
//       dynamic newOrderJson}) {
//     // Add the new order to the queue
//     orderIdQueue.add(OrderIdType(
//         orderId: orderId,
//         orderType: orderType,
//         orderOthervalue: otherValue,
//         newOrderJson: newOrderJson));

//     // Start processing the next order if not already processing
//     if (!isProcessingOrderQueue) {
//       processNextOrderFromSocket();
//     }
//   }

//   Future<Uint8List> generateSplitBillPdf() async {
//     // Orders order = Get.find<KdsController>().paidOrderDetailResponse.orders;
//     ProfileModel profileModel = Get.find<AuthController>().profileModel!;
//     bool isShowDate =
//         profileModel.restaurants!.first.showFoodDate == 'Yes' ? true : false;

//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
//     final font = await PdfGoogleFonts.poppinsMedium();
//     double subTotal = 0;
//     double grandTotal = 0;
//     double gstTotal = 0;
//     double vatTotal = 0;
//     double serviceCharge = 0;
//     // var paymentQr = await generateQrCode(
//     //   'upi://pay?pa=${Get.find<AuthController>().profileModel.restaurants.first.upiId}&pn=&am=${grandTotal + serviceCharge + gstTotal + vatTotal}&tn=',
//     // );
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(
//             profileModel.billPrinterPaperRoll == 58
//                 ? 48 * PdfPageFormat.mm
//                 : 72 * PdfPageFormat.mm,
//             double.infinity,
//             marginLeft: 0,
//             marginRight: 0,
//             marginTop: 0,
//             marginBottom: 0), // 58mm width
//         build: (context) {
//           return pw.Column(
//             children: [
//               pw.Text(profileModel.restaurants!.first.name!,
//                   style: pw.TextStyle(font: font, fontSize: 10)),
//               pw.Text(profileModel.restaurants!.first.address!,
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants![0].gstCode != '')
//                 pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants![0].fssai != '')
//                 pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),

// // ////////////////   ORDER DETAIL    /////////////////

//               pw.Row(children: [
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                       'Order ID. ${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantOrderId}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 )),
//                 if (Get.find<KdsController>()
//                             .splitOrderList[splitCurrentPrintIndex]
//                             .orderType !=
//                         'delivery' &&
//                     Get.find<KdsController>()
//                             .splitOrderList[splitCurrentPrintIndex]
//                             .orderType !=
//                         'take_away')
//                   pw.SizedBox(width: 4),
//                 if (Get.find<KdsController>()
//                             .splitOrderList[splitCurrentPrintIndex]
//                             .orderType !=
//                         'delivery' &&
//                     Get.find<KdsController>()
//                             .splitOrderList[splitCurrentPrintIndex]
//                             .orderType !=
//                         'take_away')
//                   pw.Expanded(
//                       child: pw.Align(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text(
//                         '${Get.find<KdsController>().splitOrderList.first.vendorEmployee?.waiterName ?? ''}',
//                         style: pw.TextStyle(font: font, fontSize: 8)),
//                   )),
//                 pw.SizedBox(width: 4),
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ))
//               ]),
//               // if (Get.find<KdsController>()
//               //             .splitOrderList[splitCurrentPrintIndex]
//               //             .orderType !=
//               //         'delivery' &&
//               //     Get.find<KdsController>()
//               //             .splitOrderList[splitCurrentPrintIndex]
//               //             .orderType !=
//               //         'take_away')
//               //   pw.Row(children: [
//               //     pw.Expanded(
//               //         child: pw.Align(
//               //       alignment: pw.Alignment.centerLeft,
//               //       child: pw.Text('Dine In',
//               //           style: pw.TextStyle(font: font, fontSize: 8)),
//               //     )),
//               //     pw.SizedBox(width: 5),
//               //     pw.Expanded(
//               //         child: pw.Align(
//               //       alignment: pw.Alignment.centerRight,
//               //       child: pw.Text(
//               //           '${Get.find<KdsController>().splitOrderList?.first?.vendorEmployee?.waiterName ?? ''}',
//               //           style: pw.TextStyle(font: font, fontSize: 8)),
//               //     ))
//               //   ]),
//               pw.Row(children: [
//                 // pw.SizedBox(width: 5),
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                       Get.find<KdsController>().splitOrderList.first.userName ??
//                           '',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 )),
//                 pw.SizedBox(width: 5),
//                 pw.Expanded(
//                   child: pw.Center(
//                     child: pw.Text(
//                         Get.find<KdsController>()
//                                         .splitOrderList[splitCurrentPrintIndex]
//                                         .restaurantTable ==
//                                     null ||
//                                 Get.find<KdsController>()
//                                         .splitOrderList[splitCurrentPrintIndex]
//                                         .restaurantTable!
//                                         .tableNo ==
//                                     ''
//                             ? 'WC'
//                             : Get.find<KdsController>()
//                                         .splitOrderList[splitCurrentPrintIndex]
//                                         .restaurantTable!
//                                         .title ==
//                                     ''
//                                 ? '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.tableNo}'
//                                 : '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.title}:${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable!.tableNo}',
//                         style: pw.TextStyle(font: font, fontSize: 8)),
//                   ),
//                 ),
//                 pw.SizedBox(width: 5),
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                       Get.find<KdsController>()
//                               .splitOrderList
//                               .first
//                               .user
//                               ?.phone ??
//                           '',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ))
//               ]),
//               // pw.Text(
//               //     Get.find<KdsController>()
//               //                     .splitOrderList[splitCurrentPrintIndex]
//               //                     .restaurantTable ==
//               //                 null ||
//               //             Get.find<KdsController>()
//               //                     .splitOrderList[splitCurrentPrintIndex]
//               //                     .restaurantTable
//               //                     .tableNo ==
//               //                 ''
//               //         ? 'WC'
//               //         : Get.find<KdsController>()
//               //                     .splitOrderList[splitCurrentPrintIndex]
//               //                     .restaurantTable
//               //                     .title ==
//               //                 ''
//               //             ? '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable.tableNo}'
//               //             : '${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable.title}:${Get.find<KdsController>().splitOrderList[splitCurrentPrintIndex].restaurantTable.tableNo}',
//               //     style: pw.TextStyle(font: font, fontSize: 8)),
//               pw.Divider(height: 0),

// // //////////////////   FOOD DETAIL   ///////////////////

//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('SL',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('item_info'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('qty'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Price'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 // if (isShowDate) pw.SizedBox(width: 3),
//                 // if (isShowDate)
//                 //   pw.Expanded(
//                 //       flex: 1,
//                 //       child: pw.Align(
//                 //         alignment: pw.Alignment.centerLeft,
//                 //         child: pw.Text('Date'.tr,
//                 //             style: pw.TextStyle(font: font, fontSize: 8)),
//                 //       ))
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),

//               ...List.generate(
//                   Get.find<KdsController>()
//                       .splitOrderList[splitCurrentPrintIndex]
//                       .orderDetails!
//                       .length, (i) {
//                 OrderDetails food = Get.find<KdsController>()
//                     .splitOrderList[splitCurrentPrintIndex]
//                     .orderDetails![i];
//                 String variationText = '';
//                 String addons = '';

//                 double itemPrice = 0;
//                 int variationTotal = 0;
//                 double addonsTotal = 0;
//                 double gstCharge = 0;
//                 double vatCharge = 0;

//                 if (splitCurrentPrintIndex == 0) {
//                   if (!food.isSplited) itemPrice = itemPrice + food.price!;
//                 } else {
//                   itemPrice = itemPrice + food.price!;
//                 }
//                 if (food.variation != null && food.variation!.isNotEmpty) {
//                   variationText += '(';
//                   List<String> labelList = [];
//                   for (int j = 0; j < food.variation!.length; j++) {
//                     // variationText +=
//                     //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

//                     if (food.variation![j].values != null) {
//                       // List<String> labelList = [];
//                       for (var element in food.variation![j].values!) {
//                         labelList.add(element.level!);
//                         if (splitCurrentPrintIndex == 0) {
//                           if (!food.isSplited) {
//                             itemPrice = itemPrice +
//                                 (double.parse(element.optionPrice!) *
//                                     food.quantity!);
//                             variationTotal += (int.parse(element.optionPrice!) *
//                                 food.quantity!);
//                           }
//                         } else {
//                           itemPrice = itemPrice +
//                               (double.parse(element.optionPrice!) *
//                                   food.quantity!);
//                           variationTotal += (int.parse(element.optionPrice!) *
//                               food.quantity!);
//                         }
//                       }
//                     }
//                   }
//                   variationText += '${labelList.join(',')}';
//                   variationText += ')';
//                 }
//                 for (var i = 0; i < food.addOns!.length; i++) {
//                   if (splitCurrentPrintIndex == 0) {
//                     if (!food.isSplited) {
//                       itemPrice = itemPrice +
//                           (food.addOns![i].qty! * food.addOns![i].price!)
//                               .toDouble();
//                       addonsTotal = addonsTotal +
//                           ((food.addOns![i].price! * food.addOns![i].qty!) *
//                               food.quantity!);
//                     }
//                   } else {
//                     itemPrice = itemPrice +
//                         (food.addOns![i].qty! * food.addOns![i].price!)
//                             .toDouble();
//                     addonsTotal = addonsTotal +
//                         ((food.addOns![i].price! * food.addOns![i].qty!) *
//                             food.quantity!);
//                   }
//                   addons += '${food.addOns![i].name} (${food.addOns![i].qty})';
//                 }
//                 subTotal += itemPrice;
//                 // if (food.foodType == 'FOOD') {
//                 if (splitCurrentPrintIndex == 0) {
//                   if (!food.isSplited &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .gstStatus ==
//                           'true' &&
//                       food.foodDetails!.taxType != null &&
//                       food.foodDetails!.taxType != '' &&
//                       food.foodDetails!.taxType == 'GST' &&
//                       food.foodDetails!.taxCalc != null &&
//                       food.foodDetails!.taxCalc != '' &&
//                       food.foodDetails!.taxCalc == 'Exclusive') {
//                     gstCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//                     gstTotal += gstCharge;
//                   } else if (!food.isSplited &&
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .gstStatus ==
//                           'true' &&
//                       food.foodDetails!.taxType != null &&
//                       food.foodDetails!.taxType != '' &&
//                       food.foodDetails!.taxType == 'VAT' &&
//                       food.foodDetails!.taxCalc != null &&
//                       food.foodDetails!.taxCalc != '' &&
//                       food.foodDetails!.taxCalc == 'Exclusive') {
//                     vatCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//                     vatTotal += vatCharge;
//                   }
//                 } else {
//                   if (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .gstStatus ==
//                           'true' &&
//                       food.foodDetails!.taxType != null &&
//                       food.foodDetails!.taxType != '' &&
//                       food.foodDetails!.taxType == 'GST' &&
//                       food.foodDetails!.taxCalc != null &&
//                       food.foodDetails!.taxCalc != '' &&
//                       food.foodDetails!.taxCalc == 'Exclusive') {
//                     gstCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//                     gstTotal += gstCharge;
//                   } else if (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .gstStatus ==
//                           'true' &&
//                       food.foodDetails!.taxType != null &&
//                       food.foodDetails!.taxType != '' &&
//                       food.foodDetails!.taxType == 'VAT' &&
//                       food.foodDetails!.taxCalc != null &&
//                       food.foodDetails!.taxCalc != '' &&
//                       food.foodDetails!.taxCalc == 'Exclusive') {
//                     vatCharge = (itemPrice * food.foodDetails!.tax!) / 100;
//                     vatTotal += vatCharge;
//                   }
//                 }
//                 // }
//                 // if (food.foodType == 'BAR') {
//                 //   if (splitCurrentPrintIndex == 0) {
//                 //     if (!food.isSplited) {
//                 //       vatCharge = (itemPrice *
//                 //               Get.find<AuthController>()
//                 //                   .profileModel
//                 //                   .restaurants[0]
//                 //                   .tax) /
//                 //           100;
//                 //       vatTotal += vatCharge;
//                 //     }
//                 //   } else {
//                 //     vatCharge = (itemPrice *
//                 //             Get.find<AuthController>().profileModel.restaurants[0].tax) /
//                 //         100;
//                 //     vatTotal += vatCharge;
//                 //   }
//                 // }
//                 if (splitCurrentPrintIndex == 0) {
//                   if (!food.isSplited) {
//                     serviceCharge += Get.find<AuthController>()
//                                 .profileModel!
//                                 .restaurants!
//                                 .first
//                                 .serviceCharge ==
//                             'Yes'
//                         ? ((itemPrice * 10) / 100)
//                         : 0;
//                   }
//                 } else {
//                   serviceCharge += Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .serviceCharge ==
//                           'Yes'
//                       ? ((itemPrice * 10) / 100)
//                       : 0;
//                 }
//                 grandTotal = grandTotal + itemPrice;

//                 return pw.Column(children: [
//                   pw.Row(children: [
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text('${i + 1}.',
//                               style: pw.TextStyle(
//                                 font: font,
//                                 fontSize: 8,
//                                 decoration: splitCurrentPrintIndex == 0 &&
//                                         food.isSplited
//                                     ? pw.TextDecoration.lineThrough
//                                     : pw.TextDecoration.none,
//                               )),
//                         )),
//                     pw.Expanded(
//                         flex: 2,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text(
//                               '${food.foodDetails!.name} $variationText',
//                               style: pw.TextStyle(
//                                 font: font,
//                                 fontSize: 8,
//                                 decoration: splitCurrentPrintIndex == 0 &&
//                                         food.isSplited
//                                     ? pw.TextDecoration.lineThrough
//                                     : pw.TextDecoration.none,
//                               )),
//                         )),
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text('${food.quantity}',
//                               style: pw.TextStyle(
//                                 font: font,
//                                 fontSize: 8,
//                                 decoration: splitCurrentPrintIndex == 0 &&
//                                         food.isSplited
//                                     ? pw.TextDecoration.lineThrough
//                                     : pw.TextDecoration.none,
//                               )),
//                         )),
//                     pw.SizedBox(width: 3),
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text(
//                               '${((food.unitPrice! * food.quantity!) + variationTotal).toStringAsFixed(2)}',
//                               style: pw.TextStyle(
//                                 font: font,
//                                 fontSize: 8,
//                                 decoration: splitCurrentPrintIndex == 0 &&
//                                         food.isSplited
//                                     ? pw.TextDecoration.lineThrough
//                                     : pw.TextDecoration.none,
//                               )),
//                         )),
//                   ]),
//                   if (addons != '' && addonsTotal != 0)
//                     pw.Column(children: [
//                       pw.Padding(
//                         padding: pw.EdgeInsets.symmetric(vertical: 1),
//                         child: buildDottedLine(180),
//                       ),
//                       pw.Row(children: [
//                         pw.Expanded(
//                             flex: 1,
//                             child: pw.Align(
//                               alignment: pw.Alignment.centerLeft,
//                               child: pw.Text('',
//                                   style: pw.TextStyle(font: font, fontSize: 8)),
//                             )),
//                         pw.Expanded(
//                             flex: 2,
//                             child: pw.Align(
//                               alignment: pw.Alignment.centerLeft,
//                               child: pw.Text('$addons',
//                                   style: pw.TextStyle(
//                                     font: font,
//                                     fontSize: 8,
//                                     decoration: splitCurrentPrintIndex == 0 &&
//                                             food.isSplited
//                                         ? pw.TextDecoration.lineThrough
//                                         : pw.TextDecoration.none,
//                                   )),
//                             )),
//                         pw.Expanded(
//                             flex: 1,
//                             child: pw.Align(
//                               alignment: pw.Alignment.centerLeft,
//                               child: pw.Text('',
//                                   style: pw.TextStyle(font: font, fontSize: 8)),
//                             )),
//                         pw.SizedBox(width: 3),
//                         pw.Expanded(
//                             flex: 1,
//                             child: pw.Align(
//                               alignment: pw.Alignment.centerLeft,
//                               child:
//                                   pw.Text('${addonsTotal.toStringAsFixed(2)}',
//                                       style: pw.TextStyle(
//                                         font: font,
//                                         fontSize: 8,
//                                         decoration:
//                                             splitCurrentPrintIndex == 0 &&
//                                                     food.isSplited
//                                                 ? pw.TextDecoration.lineThrough
//                                                 : pw.TextDecoration.none,
//                                       )),
//                             )),
//                       ]),
//                     ]),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.symmetric(vertical: 1),
//                     child: buildDottedLine(180),
//                   ),
//                 ]);
//               }),
//               // pw.Padding(
//               //   padding: pw.EdgeInsets.symmetric(vertical: 1),
//               //   child: buildDottedLine(180),
//               // ),

//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                     'Sub Total ${PriceConverter.convertPrice(subTotal, isHideCurrency: true, asFixed: 2)}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               ),

//               if (serviceCharge != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'Service Charge ${PriceConverter.convertPrice(serviceCharge, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),

//               if (gstTotal != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'CGST ${PriceConverter.convertPrice(gstTotal / 2, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (gstTotal != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'SGST ${PriceConverter.convertPrice(gstTotal / 2, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (vatTotal != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'VAT ${PriceConverter.convertPrice(vatTotal, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),

//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                     'Total: ${PriceConverter.convertPrice(grandTotal + serviceCharge + gstTotal + vatTotal, isHideCurrency: true, asFixed: 2)}',
//                     style: pw.TextStyle(font: font, fontSize: 10)),
//               ),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),

//               if (profileModel.restaurants!.first.footerTextBill != '')
//                 pw.SizedBox(height: 20),
//               if (profileModel.restaurants!.first.footerTextBill != '')
//                 pw.Text(profileModel.restaurants!.first.footerTextBill!,
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               pw.SizedBox(height: 5),
//               pw.Text('Powered by MyGenie',
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   Future initfirebase() async {
//     try {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//       await FirebaseMessaging.instance
//           .setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<void> registerNotification() async {
//     _messaging = FirebaseMessaging.instance;
//     final NotificationSettings settings = await _messaging!.requestPermission(
//       alert: true,
//       badge: false,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//         try {
//           var new_order = AndroidNotificationChannel(
//             'new_order', // Unique ID for channel 1
//             'new_order', // Name of channel 1
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'new_order'), // Sound file for channel 1
//           );
//           var order_accepted = AndroidNotificationChannel(
//             'order_accepted', // Unique ID for channel 1
//             'order_accepted', // Name of channel 1
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'order_accepted'), // Sound file for channel 1
//           );

//           var confirm_order = AndroidNotificationChannel(
//             'confirm_order', // Unique ID for channel 2
//             'confirm_order', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'confirm_order'), // Sound file for channel 2
//           );
//           var item_added = AndroidNotificationChannel(
//             'item_added', // Unique ID for channel 2
//             'item_added', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'item_added'), // Sound file for channel 2
//           );
//           var settle_bill = AndroidNotificationChannel(
//             'settle_bill', // Unique ID for channel 2
//             'settle_bill', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'settle_bill'), // Sound file for channel 2
//           );
//           var attend_table = AndroidNotificationChannel(
//             'attend_table', // Unique ID for channel 2
//             'attend_table', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'attend_table'), // Sound file for channel 2
//           );
//           var five_sec_buzzer = AndroidNotificationChannel(
//             'five_sec_buzzer', // Unique ID for channel 2
//             'five_sec_buzzer', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'five_sec_buzzer'), // Sound file for channel 2
//           );
//           var silent = AndroidNotificationChannel(
//             'silent', // Unique ID for channel 2
//             'silent', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'silent'), // Sound file for channel 2
//           );
//           var ten_sec_buzzer = AndroidNotificationChannel(
//             'ten_sec_buzzer', // Unique ID for channel 2
//             'ten_sec_buzzer', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'ten_sec_buzzer'), // Sound file for channel 2
//           );
//           var swiggy_new_order = AndroidNotificationChannel(
//             'swiggy_new_order', // Unique ID for channel 2
//             'swiggy_new_order', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'swiggy_new_order'), // Sound file for channel 2
//           );
//           var order_ready = AndroidNotificationChannel(
//             'order_ready', // Unique ID for channel 2
//             'order_ready', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'order_ready'), // Sound file for channel 2
//           );
//           var order_rejected = AndroidNotificationChannel(
//             'order_rejected', // Unique ID for channel 2
//             'order_rejected', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'order_rejected'), // Sound file for channel 2
//           );
//           var forty_five_sec_buzzer = AndroidNotificationChannel(
//             'forty_five_sec_buzzer', // Unique ID for channel 2
//             'forty_five_sec_buzzer', // Name of channel 2
//             importance: Importance.high,
//             sound: RawResourceAndroidNotificationSound(
//                 'forty_five_sec_buzzer'), // Sound file for channel 2
//           );

//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(new_order);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(silent);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(forty_five_sec_buzzer);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(five_sec_buzzer);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(ten_sec_buzzer);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(order_rejected);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(confirm_order);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(item_added);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(order_accepted);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(settle_bill);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(attend_table);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(order_ready);
//           flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.createNotificationChannel(swiggy_new_order);
//           if (Platform.isIOS) {
//           } else if (Platform.isAndroid) {
//             // _showNotification(message);
//             AndroidNotificationDetails androidNotificationDetails =
//                 AndroidNotificationDetails(
//               message.notification!.android!.sound!,
//               'My Genie',
//               importance: Importance.max,
//               enableVibration: true,
//               playSound: true,
//               priority: n.Priority.high,
//               // priority: Priority.high,
//               // ticker: 'ticker',
//               sound: RawResourceAndroidNotificationSound(
//                   message.notification?.android?.sound),
//             );
//             NotificationDetails notificationDetails = NotificationDetails(
//                 android: androidNotificationDetails,
//                 iOS: DarwinNotificationDetails());
//             await flutterLocalNotificationsPlugin.show(
//                 0,
//                 message.notification?.title,
//                 message.notification?.body,
//                 notificationDetails,
//                 payload: jsonEncode(message.data));
//           }
//           print('.................. register');
//         } catch (e) {
//           print(e.toString());
//         }
//       });
//       //  await checkForInitialMessage();
//     } else {}
//   }

//   AndroidNotificationChannel channel = AndroidNotificationChannel(
//       '1', // id
//       'High Importance Notifications', // title
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//       enableVibration: true,
//       playSound: true);
// }
