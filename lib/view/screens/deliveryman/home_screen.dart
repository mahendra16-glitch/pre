import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/location_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/main.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/kds_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/deliveryman/widget/delivery_order_list.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as prefix;
import 'package:http/http.dart' as http;
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/show_paid_order_content.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:qr_flutter/qr_flutter.dart';

// import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../controller/product_controller.dart';
import '../../../../util/print_byte_convert.dart';
import '../report_summary/report_summary.dart';
import '../swiggy_zomato/date_wise_orderlist.dart';
import '../waiter/pos_view_mobile/swiggy_zomatao_ui/swiggy_zomato_ui.dart';
import '../waiter/tablet_screen/order_list/tablet_order_list.dart';

class DeliveyMenHomeScreen extends StatefulWidget {
  @override
  State<DeliveyMenHomeScreen> createState() => _DeliveyMenHomeScreenState();
}

class _DeliveyMenHomeScreenState extends State<DeliveyMenHomeScreen> {
  List<bool> skipFailedList = [];

  int splitCurrentPrintIndex = 0;
  Timer? timer;
  final ScrollController _scrollController = ScrollController();
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

  List<List<OrderDetails>> cartProductList = [];
  List<List<OrderDetails>> failedCartProductList = [];
  bool isFailedPrint = false;
  PackageInfo? packageInfo;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _dropdownContoller = SuperTooltipController();

  Future<void> initData() async {
    await Get.find<DeliveryManController>().getDeliveryOrderList();

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

  final PrinterManager _printerManager = PrinterManager.instance;
  int currentPrintIndex = 0;
  bool isConnect = true;
  List<int>? pendingTask;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<BTStatus>? _singleSplitBleStatus;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController searchTable = TextEditingController();

  @override
  void initState() {
    Get.find<KdsController>().orderIdFromSocket = '';
    // initCallApi();
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

    initCallApi();
    connectToSocketIO();
    timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => Get.find<KdsController>().update());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    _subscriptionBtStatus?.cancel();
    _singleSplitBleStatus?.cancel();
    socket?.dispose();
    super.dispose();
  }

  Socket? socket;
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
      if (!(socket?.connected ?? false)) {
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
// [delivery-assign-order, 180027, 2, 1256]

        // Check if the restaurant ID in the data matches the current restaurant ID
        if (restaurantId == '${data[2]}') {
          // Handle various order-related events
          if (data[0] == 'delivery-assign-order' ||
              data[0] == 'update-order-status' ||
              data[0] == 'update-order' ||
              data[0] == 'update-food-status' ||
              data[0] == 'update-item-status' ||
              data[0] == 'update-order-paid'
              ) {
            checkQueueProcessFromSocket(
              orderType: data[0],
              orderId: '${data[1]}',
              otherValue:
                  data[0] == 'delivery-assign-order' ? '${data[3]}' : '0',
              newOrderJson:  data.length > 4 ? data[4] : null,
            );
          }
        }
      });

      socket?.on('update_table_$restaurantId', (data) async {
        print('Received socket table data: $data');

        if (restaurantId == '${data[2]}') {
          if (data[1].toString() != '0') {
            await Get.find<TableController>().setValueOfTableFromSocket(
                tableId: data[1].toString(),
                value: data[3] == 'engage' ? 'Yes' : 'No');
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

  initCallApi() async {
    await initData();
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
              paidController.clear();
              _singleSplitBleStatus?.cancel();
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
                                      resetToken: Get.find<AuthController>()
                                          .getUserToken(),
                                      email: Get.find<AuthController>()
                                              .profileModel!
                                              .empEmail ??
                                          '',
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
                          padding: EdgeInsets.only(left: 15, top: 15),
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
                                      await Get.find<AuthController>().logout();
                                  if (response.statusCode == 200) {
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
                          padding: const EdgeInsets.only(left: 15, top: 15),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
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
                  style:
                      poppinsMedium.copyWith(fontSize: 10, color: Colors.grey),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await Get.find<TableController>().getTableListFromLocally();

          return await initData();
        },
        child: Column(children: [
          // SizedBox(height: 16s),
          Divider(color: Colors.black),
          GetBuilder<DeliveryManController>(builder: (dmController) {
            return dmController.isLoading
                ? CircularProgressIndicator()
                : dmController.getWaiterOrderListResponse == null
                    ? SizedBox.shrink()
                    : dmController
                            .getWaiterOrderListResponse!.orders!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    child: TextField(
                                      controller: searchController,
                                      textInputAction: TextInputAction.search,
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: Dimensions
                                                .PADDING_SIZE_DEFAULT),
                                        suffixIcon: Icon(Icons.search,
                                            color: ColorTheme.appColor),
                                        hintText:
                                            'Search by Table no. / Name / Phone No.',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          borderSide: BorderSide(
                                              color: ColorTheme.borderGrey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          borderSide: BorderSide(
                                              color: ColorTheme.borderGrey),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          borderSide: BorderSide(
                                              color: ColorTheme.borderGrey),
                                        ),
                                        hintStyle: poppinsRegular.copyWith(
                                            fontSize: 13,
                                            color: ColorTheme.hintText),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      style: poppinsMedium.copyWith(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                      onChanged: (value) async {
                                        dmController.update();
                                      },
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await initCallApi();

                                    // Get.find<KdsController>().resetSplitBill();
                                    // await Get.find<KdsController>()
                                    //     .getWaiterPOSOrderList();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Icon(Icons.refresh_outlined,
                                        color: ColorTheme.appColor, size: 35),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox.shrink();
          }),

          Padding(
            padding: const EdgeInsets.only(top: 16),
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
              child: GetBuilder<DeliveryManController>(builder: (dmController) {
                return dmController.getWaiterOrderListResponse == null
                    ? const SizedBox.shrink()
                    : dmController.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : dmController.getWaiterOrderListResponse == null
                            ? SizedBox.shrink()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: orderListContent(dmController),
                              );
                // WaiterOrderList(
                // orderList: kdsController.getOrderListResponse.orders
                // );
              }),
            ),
          ),
        ]),
      ),
      ),
    );
  }

  Widget orderListContent(DeliveryManController dmController) {
    return StaggeredGrid.count(
      crossAxisCount: MediaQuery.of(context).size.shortestSide <= 570
          ? 1
          : MediaQuery.of(context).orientation == Orientation.landscape
              ? 3
              : 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: dmController.getWaiterOrderListResponse!.orders!.where((order) {
        ///////////    Filter with delivery

        if (order.fOrderStatus == 0 ||
            order.fOrderStatus == 1 ||
            order.fOrderStatus == 2 ||
            order.fOrderStatus == 5 ||
            order.fOrderStatus == 7) {
          if (searchController.text.isEmpty) {
            if (order.orderType == 'delivery') {
              return true;
            }
          } else if ((Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('table no') &&
                  (order.restaurantTable != null &&
                      order.restaurantTable!.tableNo != '' &&
                      (order.restaurantTable!.tableNo!.toUpperCase().contains(searchController.text.toUpperCase()) ||
                          order.restaurantTable!.title!.toUpperCase().contains(
                              searchController.text.toUpperCase())))) ||
              (Get.find<AuthController>().profileModel!.restaurants!.first.searchBy!.contains('user id') &&
                  (order.deliveryAddress != null &&
                      order.deliveryAddress!.contactPersonName!
                          .toUpperCase()
                          .contains(searchController.text.toUpperCase()))) ||
              (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                  (order.deliveryAddress?.contactPersonNumber != null &&
                      (order.deliveryAddress?.contactPersonNumber?.length ?? 0) >
                          2 &&
                      (order.deliveryAddress?.contactPersonNumber
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) ||
              (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true &&
                  ((order.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase())) ?? false))) {
            if (order.orderType == 'delivery') {
              return true;
            }
          }
        }

        return false;
      }).map((order) {
        // Now return the widget directly
        return DeliveryOrderList(
          searchOrder: searchController,
          subscriptionBtStatus: _subscriptionBtStatus,
          searchTable: searchTable,
          flutterTit: flutterTts,
          order: order,
          isWaiter: true,
        );
      }).toList(),
    );
  }

  Widget orderTypeTab() {
    return GetBuilder<KdsController>(builder: (kdsController) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  kdsController.setMainMenuIndex(0);
                },
                child: Column(
                  children: [
                    // Image.asset(Images.dine_in,
                    //     height: 30,
                    //     width: 30,
                    //     color: Theme.of(context).hintColor),
                    Container(
                      margin: EdgeInsets.only(top: 5, right: 5),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: kdsController.selectedMainMenu == 0
                              ? ColorTheme.appColor
                              : Color.fromRGBO(243, 189, 71, 1),
                          // border:
                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_LARGE)),
                      child: Center(
                        child: Text(
                          'dine_in'.tr,
                          style: poppinsRegular.copyWith(
                              fontSize: 12,
                              color: kdsController.selectedMainMenu == 0
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  kdsController.setMainMenuIndex(1);
                },
                child: Column(
                  children: [
                    // Image.asset(Images.take_away,
                    //     height: 30,
                    //     width: 30,
                    //     color: Theme.of(context).hintColor),
                    Container(
                      margin: EdgeInsets.only(top: 5, right: 5),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: kdsController.selectedMainMenu == 1
                              ? ColorTheme.appColor
                              : Color.fromRGBO(243, 189, 71, 1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_LARGE)),
                      child: Center(
                        child: Text(
                          'take_away'.tr,
                          style: poppinsRegular.copyWith(
                              fontSize: 12,
                              color: kdsController.selectedMainMenu == 1
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  kdsController.setMainMenuIndex(2);
                },
                child: Column(
                  children: [
                    // Image.asset(Images.ic_kds_delivery,
                    //     height: 30,
                    //     width: 30,
                    // color: Theme.of(context).hintColor),
                    Container(
                      margin: EdgeInsets.only(top: 5, right: 5),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: kdsController.selectedMainMenu == 2
                              ? ColorTheme.appColor
                              : Color.fromRGBO(243, 189, 71, 1),
                          // border:
                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_LARGE)),
                      child: Center(
                        child: Text(
                          'delivery'.tr,
                          style: poppinsRegular.copyWith(
                              fontSize: 12,
                              color: kdsController.selectedMainMenu == 2
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  kdsController.setMainMenuIndex(3);
                },
                child: Column(
                  children: [
                    // Image.asset(Images.ic_kds_all_menu,
                    //     height: 30,
                    //     width: 30,
                    //     color: Theme.of(context).hintColor),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: kdsController.selectedMainMenu == 3
                              ? ColorTheme.appColor
                              : Color.fromRGBO(243, 189, 71, 1),
                          // border:
                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_LARGE)),
                      child: Center(
                        child: Text(
                          'all'.tr,
                          style: poppinsRegular.copyWith(
                              fontSize: 12,
                              color: kdsController.selectedMainMenu == 3
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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
      isFailedPrint = false;
      skipFailedList = [];

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
        if (foodList != null) {
          for (var e in foodList) {
            if (e.station == printer.areaName && e.foodStatus != 3) {
              tempCartList.add(e);
            }
          }
        }
        cartProductList.add(tempCartList);
        failedCartProductList.add([]);
      }
      if (Platform.isAndroid) {
        await _subscriptionBtStatus?.cancel();
        await _singleSplitBleStatus?.cancel();

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

      await Get.find<DeliveryManController>().getOrderDetailFromSocket(
          foodStatus: currentOrder.orderType == 'delivery-assign-order'
              ? '${currentOrder.orderOthervalue}'
              : '0',
          type: currentOrder.orderType,
          orderId: '${currentOrder.orderId}',
          socketJson: null,
          callbackFunction: (OrderList order) async {
            // if (order != null) {
            //   await Future.delayed(
            //       Duration(seconds: 2)); // Simulate async processing
            //   checkQueueProcess(order);
            // }
          });

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
  void checkQueueProcessFromSocket({
    String? orderType,
    String? orderId,
    String? otherValue,
    dynamic newOrderJson,
  }) {
    // Add the new order to the queue
    orderIdQueue.add(OrderIdType(
      orderId: orderId,
      orderType: orderType,
      orderOthervalue: otherValue,
      newOrderJson: newOrderJson,
    ));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
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
              // PrinterManager.instance
              //     .send(type: PrinterType.bluetooth, bytes: pendingTask);
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
              splitCurrentPrintIndex = splitCurrentPrintIndex + 1;
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
              if (isSkipFirstTimeOrder && !skipFailedList[currentPrintIndex]) {
                Future.delayed(Duration(seconds: 5), () {
                  isConnect = true;
                  skipFailedList[currentPrintIndex] = true;

                  // isFailedPrint = true;
                  // failedCartProductList[currentPrintIndex] =
                  //     cartProductList[currentPrintIndex];
                  // currentPrintIndex = currentPrintIndex + 1;
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
      }
    });
  }

  singleSplitBillBlutooth() {
    if (Platform.isAndroid) {
      _singleSplitBleStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        log(' -----------------split status bt $status ------------------ ');

        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(Duration(seconds: 11), () async {
              Get.find<LoadingController>().startLoading(false);
              await Get.find<LoadingController>()
                  .changeText(data: 'Successfully printed!!');
              await Get.find<LoadingController>().changeStatus(data: true);
              pendingTask = null;
              await PrinterManager.instance
                  .disconnect(type: PrinterType.bluetooth);
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
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

  // Future placeOrderByteConvert(OrderList order) async {
  //   List<int> bytes = [];
  //   bool isOutOfMenu = false;
  //   final profile = await CapabilityProfile.load(name: 'XP-N160I');
  //   final generator = Generator(
  //       Get.find<AuthController>()
  //                   .profileModel!
  //                   .restaurantPrinterNew![currentPrintIndex]
  //                   .printerPaperRoll ==
  //               58
  //           ? PaperSize.mm58
  //           : PaperSize.mm80,
  //       profile);
  //   bytes += generator.setGlobalCodeTable('CP1252');

  //   if (Get.find<AuthController>()
  //           .profileModel!
  //           .restaurants!
  //           .first
  //           .isShowAddressKot ==
  //       'Yes') {
  //     if (logoHelper.logoUrlPrint != null) {
  //       try {
  //         bytes += generator.feed(1);
  //         bytes += generator.image(logoHelper.logoUrlPrint!);
  //       } catch (e) {
  //         print(e);
  //       }
  //     }
  //     bytes += generator.text(
  //         Get.find<AuthController>().profileModel?.restaurants != null &&
  //                 Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
  //                 Get.find<AuthController>().profileModel!.restaurants![0].name != null
  //             ? Get.find<AuthController>().profileModel!.restaurants![0].name!
  //             : '',
  //         styles: PrinterConfig().titleStyle());
  //     bytes += generator.text(
  //         Get.find<AuthController>().profileModel?.restaurants != null &&
  //                 Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
  //                 Get.find<AuthController>().profileModel!.restaurants![0].address != null
  //             ? Get.find<AuthController>().profileModel!.restaurants![0].address!
  //             : '',
  //         styles: PrinterConfig().addressStyle());
  //   }

  //   bytes += generator.text(cartProductList[currentPrintIndex].first.station,
  //       styles: PrinterConfig().titleStyle());

  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'order_id'.tr + ':' + ' ${order.restaurantOrderId}',
  //         width: 6,
  //         styles: PrinterConfig().orderIdStyle()),
  //     PosColumn(
  //         text:
  //             '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.now())}',
  //         width: 6,
  //         styles: PrinterConfig().orderCreateDateStyle()),
  //   ]);
  //   if (order.orderType != 'delivery' && order.orderType != 'take_away')
  //     bytes += generator.row([
  //       PosColumn(
  //           text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 1,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: '${order.vendorEmployee.waiterName}',
  //           width: 6,
  //           styles: PrinterConfig().waiterNameStyle()),
  //     ]);
  //   if (order.userId != null) {
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}',
  //         width: 5,
  //         styles: PosStyles(
  //             height: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>()
  //                             .profileModel
  //                             .printConfig
  //                             .restaurantFoodList ==
  //                         null
  //                 ? PosTextSize.size1
  //                 : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                     .profileModel
  //                     .printConfig
  //                     .restaurantFoodList
  //                     .split(',')
  //                     .first),
  //             width: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>()
  //                             .profileModel
  //                             .printConfig
  //                             .restaurantFoodList ==
  //                         null
  //                 ? PosTextSize.size1
  //                 : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                     .profileModel
  //                     .printConfig
  //                     .restaurantFoodList
  //                     .split(',')[1]),
  //             bold: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>().profileModel.printConfig.restaurantFoodList == null
  //                 ? false
  //                 : Get.find<AuthController>().profileModel.printConfig.restaurantFoodList.split(',').last == 'true'
  //                     ? true
  //                     : false,
  //             align: PosAlign.left,
  //             fontType: PosFontType.fontB),
  //       ),
  //       PosColumn(
  //         text: '',
  //         width: 2,
  //         styles: PosStyles(align: PosAlign.center, underline: true),
  //       ),
  //       PosColumn(
  //         text: '${order.user?.phone ?? ''}',
  //         width: 5,
  //         styles: PosStyles(
  //             height: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>()
  //                             .profileModel
  //                             .printConfig
  //                             .restaurantFoodList ==
  //                         null
  //                 ? PosTextSize.size1
  //                 : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                     .profileModel
  //                     .printConfig
  //                     .restaurantFoodList
  //                     .split(',')
  //                     .first),
  //             width: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>()
  //                             .profileModel
  //                             .printConfig
  //                             .restaurantFoodList ==
  //                         null
  //                 ? PosTextSize.size1
  //                 : PrinterConfig().fonstSize(Get.find<AuthController>()
  //                     .profileModel
  //                     .printConfig
  //                     .restaurantFoodList
  //                     .split(',')[1]),
  //             bold: Get.find<AuthController>().profileModel.printConfig == null ||
  //                     Get.find<AuthController>().profileModel.printConfig.restaurantFoodList == null
  //                 ? false
  //                 : Get.find<AuthController>().profileModel.printConfig.restaurantFoodList.split(',').last == 'true'
  //                     ? true
  //                     : false,
  //             align: PosAlign.right,
  //             fontType: PosFontType.fontB),
  //       ),
  //     ]);
  //   } else if (order.userName != '' && order.userName != 'Noname') {
  //     bytes += generator.text(
  //       '${order.userName}',
  //       styles: PosStyles(fontType: PosFontType.fontB),
  //     );
  //   }
  //   bytes += generator.text(
  //       order.restaurantTable == null || order.restaurantTable.tableNo == ''
  //           ? order.orderType == 'delivery'
  //               ? 'Delivery'
  //               : Get.find<KdsController>()
  //                           .getWaiterOrderListResponse
  //                           .orders[Get.find<KdsController>().updatedOrderIndex]
  //                           .orderType ==
  //                       'take_away'
  //                   ? 'Take Away'
  //                   : 'WC'
  //           : order.restaurantTable.title == ''
  //               ? '${order.restaurantTable.tableNo}'
  //               : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}',
  //       // ordersPrint.restaurantDetails.tableNo +
  //       // '-' +
  //       // ordersPrint.restaurantDetails.tableArea,
  //       styles: PrinterConfig().tableNoStyle());

  //   bytes += generator.hr(ch: '--');

  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'sl'.tr.toUpperCase(),
  //         width: 2,
  //         styles: PrinterConfig().foodStyle()),
  //     PosColumn(
  //       text: 'item_info'.tr,
  //       width: 8,
  //       styles: PrinterConfig().foodStyle(),
  //     ),
  //     PosColumn(
  //       text: 'qty'.tr,
  //       width: 2,
  //       styles: PrinterConfig().foodStyle(),
  //     ),
  //   ]);
  //   bytes += generator.hr(ch: '--');
  //   for (var i = 0; i < cartProductList[currentPrintIndex].length; i++) {
  //     OrderDetails cart = cartProductList[currentPrintIndex][i];
  //     String variationText = '';
  //     String addons = '';
  //     if (cart.variation != null &&
  //         cart.variation.isNotEmpty &&
  //         Get.find<AuthController>()
  //                 .profileModel
  //                 .restaurants
  //                 .first
  //                 .foodWithVariance ==
  //             'Yes') {
  //       variationText += '(';
  //       List<String> labelList = [];

  //       for (int j = 0; j < cart.variation.length; j++) {
  //         if (cart.variation[j].values != null) {
  //           for (var element in cart.variation[j].values) {
  //             labelList.add(element.level);
  //           }
  //         }
  //       }
  //       variationText += '${labelList.join(',')}';
  //       variationText += ')';
  //     } else if (cart.variation != null &&
  //         cart.variation.isNotEmpty &&
  //         Get.find<AuthController>()
  //                 .profileModel
  //                 .restaurants
  //                 .first
  //                 .foodWithVariance !=
  //             'Yes') {
  //       for (int j = 0; j < cart.variation.length; j++) {
  //         variationText +=
  //             '${variationText.isNotEmpty ? ', ' : ''}${cart.variation[j].name} (';

  //         if (cart.variation[j].values != null) {
  //           List<String> labelList = [];
  //           for (var element in cart.variation[j].values) {
  //             labelList.add(element.level);
  //           }
  //           variationText +=
  //               '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
  //         }

  //         variationText += ')';
  //       }
  //     }
  //     // if (cart.variation != null && cart.variation.isNotEmpty) {
  //     //   for (int j = 0; j < cart.variation.length; j++) {
  //     //     variationText +=
  //     //         '${variationText.isNotEmpty ? ', ' : ''}${cart.variation[j].name} (';

  //     //     if (cart.variation[j].values != null) {
  //     //       List<String> labelList = [];
  //     //       for (var element in cart.variation[j].values) {
  //     //         labelList.add(element.level);
  //     //       }
  //     //       variationText +=
  //     //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
  //     //     }

  //     //     variationText += ')';
  //     //   }
  //     // }

  //     for (var i = 0; i < cart.addOns.length; i++) {
  //       if (addons != '') {
  //         addons += ', ';
  //       }
  //       addons += '${cart.addOns[i].name} (${cart.addOns[i].qty})';
  //     }

  //     bytes += generator.row([
  //       PosColumn(
  //           text: '${i + 1}.', width: 2, styles: PrinterConfig().foodStyle()),
  //       PosColumn(
  //         text: Get.find<AuthController>()
  //                     .profileModel
  //                     .restaurants
  //                     .first
  //                     .foodWithVariance ==
  //                 'Yes'
  //             ? '${cart.foodDetails.name} $variationText'
  //             : '${cart.foodDetails.name}',
  //         width: 8,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //       PosColumn(
  //         text: '${cart.quantity}',
  //         width: 2,
  //         styles: PrinterConfig().foodStyle(),
  //       ),
  //     ]);

  //     if (addons != '') {
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //           text: 'Add-Ons :$addons',
  //           width: 8,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //       ]);
  //     }
  //     if (variationText != '' &&
  //         Get.find<AuthController>()
  //                 .profileModel
  //                 .restaurants
  //                 .first
  //                 .foodWithVariance !=
  //             'Yes') {
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //           text: 'Variants  :$variationText',
  //           width: 8,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //       ]);
  //     }
  //     if (order.orderNote != '' &&
  //         cart.foodDetails.name.toLowerCase().contains('out of')) {
  //       isOutOfMenu = true;
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //           text: 'Notes: ${order.orderNote}',
  //           width: 8,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //       ]);
  //     }
  //     if (cart.foodLevelNotes != '')
  //       bytes += generator.row([
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(
  //             align: PosAlign.center,
  //           ),
  //         ),
  //         PosColumn(
  //           text: 'Notes: ${cart.foodLevelNotes}',
  //           width: 8,
  //           styles: PrinterConfig().foodStyle(),
  //         ),
  //         PosColumn(
  //           text: '',
  //           width: 2,
  //           styles: PosStyles(align: PosAlign.center),
  //         ),
  //       ]);

  //     bytes += generator.hr(ch: '....');
  //   }

  //   if (order.orderNote != '' && !isOutOfMenu) {
  //     bytes += generator.text('${'Notes'.tr}:  ${order.orderNote}',
  //         styles: PrinterConfig().foodStyle());
  //   }

  //   print('bytes length:${bytes.length}');
  //   if (Platform.isIOS) {
  //     await iosPrintEscPos(bytes, order);
  //   } else {
  //     await printEscPos(bytes, order);
  //   }
  // }

  Future printEscPos(List<int> bytes, OrderList order) async {
    print('bytes length:${bytes.length}');
    // bytes += generator.feed(2);
    // bytes += generator.cut();

    // await PrinterManager.instance
    //     .disconnect(type: PrinterType.bluetooth); //  what this do explain
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        port: '9100',
        typePrinter: Get.find<AuthController>().profileModel!.billWifiIp != ''
            ? PrinterType.network
            : PrinterType.bluetooth,
        address: Get.find<AuthController>().profileModel!.billWifiIp != ''
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

    // if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
    try {
      bool data = await _printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      Future.delayed(Duration(seconds: 2), () async {
        // print('%%%%%%%%%%%%%isPrinted---$data');
        bytes = [];
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance
            .disconnect(type: bluetoothPrinter.typePrinter);
        currentPrintIndex = currentPrintIndex + 1;
        dataCheck(order);
      });
    } catch (e) {}
    // }
  }

  Future iosPrintEscPos(List<int> bytes, OrderList order) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    // await PrintBluetoothThermal.pairedBluetooths;
    // bytes += generator.feed(2);
    // bytes += generator.cut();

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
      dataCheck(order);
    } else {
      final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
          macPrinterAddress: Get.find<AuthController>()
                  .profileModel!
                  .restaurantPrinterNew![currentPrintIndex]
                  .macPrinterIp ??
              '');
      Future.delayed(Duration(seconds: 2), () async {
        if (result) {
          await IosPrintTransport.writeBytes(bytes);
          // Do not assign null to bytes, just clear if needed or leave as is
          Future.delayed(Duration(seconds: 2), () async {
            var isDisconnect =
            print('is disconnect $isDisconnect');
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck(order);
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
          dataCheck(order);
        }
      });
    }
    // });
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
              // placeOrderByteConvert(order);
              if (Platform.isIOS) {
                await iosPrintEscPos(
                    await PrintByteConvert().byteConvert(
                        printType: 'kot',
                        orderType: order.orderType ?? '',
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
                        orderId: order.restaurantOrderId ?? '',
                        date:
                            '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                        waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                        tablename: order.restaurantTable == null ||
                                order.restaurantTable?.tableNo == ''
                            ? order.orderType == 'delivery'
                                ? 'Delivery'
                                : order.orderType == 'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : order.restaurantTable?.title == ''
                                ? '${order.restaurantTable?.tableNo}'
                                : '${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                        custName: order.userName,
                        custPhone: '${order.user?.phone ?? ''}',
                        kotOrderList: cartProductList[currentPrintIndex],
                        orderNote: order.orderNote ?? ''),
                    order);
              } else {
                await printEscPos(
                    await PrintByteConvert().byteConvert(
                        printType: 'kot',
                        orderType: order.orderType ?? '',
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
                        orderId: order.restaurantOrderId ?? '',
                        date:
                            '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                        waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                        tablename: order.restaurantTable == null ||
                                order.restaurantTable?.tableNo == ''
                            ? order.orderType == 'delivery'
                                ? 'Delivery'
                                : order.orderType == 'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : order.restaurantTable?.title == ''
                                ? '${order.restaurantTable?.tableNo}'
                                : '${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                        custName: order.userName ?? '',
                        custPhone: '${order.user?.phone ?? ''}',
                        kotOrderList: cartProductList[currentPrintIndex],
                        orderNote: order.orderNote ?? ''),
                    order);
              }
              break;
            }
          }
        } else {
          // placeOrderByteConvert(order);
          if (Platform.isIOS) {
            await iosPrintEscPos(
                await PrintByteConvert().byteConvert(
                    printType: 'kot',
                    orderType: order.orderType ?? '',
                    stationName:
                        cartProductList[currentPrintIndex].first.station ?? '',
                    paperRoll: Get.find<AuthController>()
                                .profileModel!
                                .restaurantPrinterNew![currentPrintIndex]
                                .printerPaperRoll ==
                            58
                        ? 58
                        : 80,
                    orderId: order.restaurantOrderId ?? '',
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                    waiterName: '${order.vendorEmployee?.waiterName ?? ''}',
                    tablename: order.restaurantTable == null ||
                            order.restaurantTable?.tableNo == ''
                        ? order.orderType == 'delivery'
                            ? 'Delivery'
                            : order.orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : order.restaurantTable?.title == ''
                            ? '${order.restaurantTable?.tableNo}'
                            : '${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                    custName: order.userName,
                    custPhone: '${order.user?.phone ?? ''}',
                    kotOrderList: cartProductList[currentPrintIndex],
                    orderNote: order.orderNote ?? ''),
                order);
          } else {
            await printEscPos(
                await PrintByteConvert().byteConvert(
                    printType: 'kot',
                    orderType: order.orderType!,
                    stationName:
                        cartProductList[currentPrintIndex].first.station ?? '',
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
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(new_order);
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
              ?.createNotificationChannel(swiggy_new_order);
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
}
