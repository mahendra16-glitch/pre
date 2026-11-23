import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/bluetooth_auto_connect.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/most_sell_station_item.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/enums.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/main.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/widget/order_type_listview.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/widget/kds_tablet_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as prefix;
import '../../../../data/model/response/get_station_order_list_response.dart';
import '../../../../util/print_byte_convert.dart' hide formatQuantity;
import '../swiggy/swiggy_order_ui.dart';

class KDSHomeScreen extends StatefulWidget {
  @override
  State<KDSHomeScreen> createState() => _KDSHomeScreenState();
}

class _KDSHomeScreenState extends State<KDSHomeScreen> {
  late final FirebaseMessaging _messaging;
  int? orderTypeStatus;
  final FlutterTts flutterTts = FlutterTts();
  final List<String> orderTypeList = ['All', 'Dine In'];
  Timer? timer;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final PrinterManager _printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  BTStatus currentStatus = BTStatus.none;
  PackageInfo? packageInfo;
  final _dropdownContoller = SuperTooltipController();
  final TextEditingController searchController = TextEditingController();
  RestaurantPrinterNew? printer;
  List<OrderDetailsFood> cartProductList = [];
  bool isFailedPrint = false;
  bool isConnect = true;
  List<Orders> orderQueue = [];
  List<OrderIdType> orderIdQueue = [];
  bool isProcessingOrder = false;
  bool isProcessingOrderQueue = false;

  Future<void> initData() async {
    printer = null;
    for (var i = 0;
        i <
            Get.find<AuthController>()
                .profileModel!
                .restaurantPrinterNew!
                .length;
        i++) {
      if (Get.find<AuthController>()
              .profileModel!
              .restaurantPrinterNew![i]
              .areaName!
              .toUpperCase() ==
          Get.find<AuthController>().profileModel!.roleName!.toUpperCase()) {
        printer =
            Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
      }
    }
    if (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .defOrdStatus ==
            2 ||
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .defOrdStatus ==
            5) {
      Get.find<KdsController>().setSubMenuIndex(2);
    }
    await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    await Get.find<KdsController>().getPOSOrderList();
    await Get.find<KdsController>().getTotalKdsOrder();
    if (Get.find<AuthController>().profileModel!.role!.contains('aggregator') &&
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .defOrdStatus ==
            1) {
      await Get.find<SwiggyController>().fetchOrders();
    }

    if ((Get.find<AuthController>().profileModel!.restaurants!.first.logoPath ??
            '')
        .isNotEmpty) {
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

  @override
  void initState() {
    super.initState();
    initNotification();
    Get.find<KdsController>().clearOrderList();
    // ✅ Auto-connect to saved Bluetooth printer on iOS when screen loads
    BluetoothAutoConnect.instance.start();
    if (Get.find<AuthController>().profileModel?.restaurants != null &&
        Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
        Get.find<AuthController>().profileModel!.restaurants!.first.takeAway ==
            true) {
      if (!orderTypeList.contains('Take Away')) orderTypeList.add('Take Away');
    }
    if (Get.find<AuthController>().profileModel?.restaurants != null &&
        Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
        Get.find<AuthController>().profileModel!.restaurants!.first.delivery ==
            true) {
      if (!orderTypeList.contains('Delivery')) orderTypeList.add('Delivery');
    }
    if (Get.find<AuthController>().profileModel?.role != null &&
        Get.find<AuthController>().profileModel!.role!.contains('aggregator') &&
        Get.find<AuthController>().profileModel?.restaurants != null &&
        Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .defOrdStatus ==
            1) {
      if (!orderTypeList.contains('Swiggy-Zommato'))
        orderTypeList.add('Swiggy-Zommato');
    }
    if (Get.find<AuthController>().profileModel?.restaurants != null &&
        Get.find<AuthController>().profileModel!.restaurants!.isNotEmpty &&
        Get.find<AuthController>().profileModel!.restaurants!.first.showRoom ==
            'Yes') {
      if (!orderTypeList.contains('Room')) orderTypeList.add('Room');
    }
    // if (Get.find<AuthController>()
    //         .profileModel
    //         .restaurants[0]
    //         .showOrderStatus ==
    //     1) {
    Get.find<KdsController>().setSubMenuIndex(1);
    // }
    //  else {
    //   Get.find<KdsController>().setSubMenuIndex(0);
    // }
    Get.find<KdsController>().orderIdFromSocket = '';
    initData();

    connectToSocketIO();
  }

  initNotification() async {
    // String deviceToken = await FirebaseMessaging.instance.getToken();
    // print('device token $deviceToken');
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
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  void dispose() {
    timer?.cancel();
    _subscriptionBtStatus?.cancel();
    BluetoothAutoConnect.instance.stop(); // ✅ stop auto-connect on screen exit
    homeSocket?.dispose();
    super.dispose();
  }

  // Socket? socket;

  void connectToSocketIO() async {
    if (Platform.isAndroid) {
      await _subscriptionBtStatus?.cancel();
      await listenBlutooth();
    }
    try {
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

      if (!homeSocket!.connected) {
        homeSocket?.connect();
      }

      homeSocket?.off(
          'new_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}');

      homeSocket?.on(
          'new_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}',
          (data) async {
        print('/////kitchen//////$data');

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
              data[0] == 'update-order-status') {
            checkQueueProcessFromSocket(
                orderType: data[0],
                orderId: '${data[1]}',
                otherValue: data[0] == 'update-food-status'
                    ? '${data[3]}'
                    : data[0] == 'update-item-status'
                        ? '${data[3]}'
                        : '0');
          }
        }
      });

      if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('aggregator') &&
          Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .defOrdStatus ==
              1)
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
              await Get.find<SwiggyController>().getOrderDetailFromSocket(
                foodStatus: '0',
                type: data[0],
                orderId: '${data[1]}',
              );
            }
          }
        });
      homeSocket?.on('disconnect', (d) {
        print('disconnect-----$d');
        // if (!socket.connected) socket.connect();
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

        await Get.find<KdsController>().getPOSOrderList();
        await Get.find<KdsController>().getTotalKdsOrder();

        if (Get.find<AuthController>()
            .profileModel!
            .role!
            .contains('aggregator'))
          await Get.find<SwiggyController>().fetchOrders();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: Duration(seconds: 2)),
      showReleaseNotes: true,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: MediaQuery.of(context).size.shortestSide > 600
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.only(
                      left: Dimensions.PADDING_SIZE_SMALL),
                  child: IconButton(
                    icon: Image.asset(Images.menu,
                        color: ColorTheme.appColor, height: 20),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                titleSpacing: 0,
                centerTitle: false,
                elevation: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    Get.find<AuthController>()
                        .profileModel!
                        .roleName!
                        .toUpperCase(),
                    style: poppinsSemiBold.copyWith(
                        color: ColorTheme.appColor, fontSize: 15),
                  ),
                ),
              ),
        drawer: Drawer(
          backgroundColor: const Color(0xFFF8F8F8),
          child: SafeArea(
            child: Column(
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
                      'Daily Report',
                      style: poppinsMedium.copyWith(
                          fontSize: 14, color: ColorTheme.hintText),
                    ),
                    children: <Widget>[
                      //Station Report
                      InkWell(
                        onTap: () {
                          scaffoldKey.currentState?.closeDrawer();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => MostStationSalesItem(
                                        name:
                                            '${Get.find<AuthController>().profileModel!.roleName}',
                                        selectedTabIndex: 0,
                                      ))));
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15, top: GetPlatform.isIOS ? 10 : 0),
                            child: Text(
                              '${Get.find<AuthController>().profileModel!.roleName!.toUpperCase()} Report',
                              style: poppinsMedium.copyWith(
                                  fontSize: 13, color: ColorTheme.hintText),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 15, right: 15),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => EmployeeResetPassword(
                                        resetToken: Get.find<AuthController>()
                                            .getUserToken(),
                                        email: Get.find<AuthController>()
                                            .profileModel!
                                            .empEmail!,
                                        image: Images.ic_kds_app_logo,
                                        password: '',
                                        fromPasswordChange: true,
                                      ))));
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
                      InkWell(
                        onTap: () {
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
                                      homeSocket?.clearListeners();
                                      homeSocket?.disconnect();
                                      homeSocket?.dispose();
                                      homeSocket = null;
                                      Get.find<AuthController>()
                                          .clearSharedData();
                                      Get.offAllNamed(
                                          RouteHelper.getSignInRoute());
                                    }
                                  } catch (e) {}
                                }),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 10),
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
                    style: poppinsMedium.copyWith(
                        fontSize: 10, color: Colors.grey),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              return await initData();
            },
            child: MediaQuery.of(context).size.shortestSide > 600
                ? KdsTabletHomeView(
                    searchController: searchController,
                    flutterTts: flutterTts,
                    scaffoldKey: scaffoldKey,
                    orderTypeList: orderTypeList,
                    dropdownContoller: _dropdownContoller,
                    isPrintKot: (Orders order) async {
                      checkQueueProcess(order);
                    },
                  )
                : Column(children: [
                    readyTab(),
                    const SizedBox(height: 16),
                    GetBuilder<KdsController>(builder: (kdsController) {
                      return kdsController.selectedSubMenu == 0 ||
                              kdsController.selectedSubMenu == 1 ||
                              kdsController.selectedSubMenu == 2 ||
                              kdsController.selectedSubMenu == 3
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: TextField(
                                        controller: searchController,
                                        textInputAction: TextInputAction.search,
                                        autofocus: false,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        keyboardType: TextInputType.name,
                                        decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(
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
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                borderSide: BorderSide(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                borderSide: BorderSide(
                                                    color: ColorTheme.borderGrey)),
                                            hintStyle: poppinsRegular.copyWith(fontSize: 13, color: ColorTheme.hintText),
                                            filled: true,
                                            fillColor: Colors.white),
                                        style: poppinsMedium.copyWith(
                                            color: Colors.black, fontSize: 13),
                                        onChanged: (value) async {
                                          kdsController.update();
                                        },
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Get.find<KdsController>()
                                          .getPOSOrderList();
                                      if (Get.find<KdsController>()
                                              .selectedMainMenu ==
                                          5) {
                                        await Get.find<SwiggyController>()
                                            .fetchOrders();
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(Icons.refresh_outlined,
                                          color: ColorTheme.appColor, size: 35),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Divider(
                        height: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                    ),
                    Expanded(
                      child: GetBuilder<SwiggyController>(
                          builder: (swiggyController) {
                        return GetBuilder<KdsController>(
                            builder: (kdsController) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              child: kdsController.selectedMainMenu == 5
                                  ? Column(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: KdsSwiggyUI(),
                                        ))
                                      ],
                                    )
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          if (kdsController.selectedMainMenu ==
                                              3)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: KdsSwiggyUI(),
                                            ),
                                          kdsController.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : kdsController
                                                          .getStationOrderListResponse ==
                                                      null
                                                  ? const SizedBox.shrink()
                                                  : KdsOrderTypeListview(
                                                      flutterTts: flutterTts,
                                                      searchController:
                                                          searchController,
                                                      blutoothStatus:
                                                          currentStatus,
                                                      pendingTask: pendingTask,
                                                      printerManager:
                                                          _printerManager,
                                                      isPrintKot:
                                                          (Orders order) async {
                                                        checkQueueProcess(
                                                            order);
                                                      },
                                                      orderStatus:
                                                          orderTypeStatus,
                                                      kdsController:
                                                          kdsController),
                                        ],
                                      ),
                                    ));
                        });
                      }),
                    ),
                  ]),
          ),
        ),
      ),
    );
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
                await _dropdownContoller.showTooltip();
              },
              child: SuperTooltip(
                borderRadius: 2,
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
                            } else if (orderTypeList[index] ==
                                'Swiggy-Zommato') {
                              kdsController.setMainMenuIndex(5);
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
                                              : kdsController
                                                          .selectedMainMenu ==
                                                      5
                                                  ? 'Swiggy-Zommato'
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
                        .restaurants![0]
                        .defOrdStatus ==
                    0 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    1 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    2)
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    searchController.clear();
                    kdsController.setSubMenuIndex(1);
                  },
                  child: Container(
                    height: 50,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 30,
                            width: Get.width * 0.25,
                            child: Container(
                              // padding: EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: kdsController.selectedSubMenu == 1
                                    ? ColorTheme.appColor
                                    : Color(0xFFF6F6F6),
                              ),
                              child: Center(
                                child: Text(
                                  Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('BAR')
                                      ? 'Making'
                                      : 'Cooking',
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
                        (kdsController.getStationOrderListResponse == null) ||
                                (kdsController.getStationOrderListResponse!
                                        .statusCounts!.cooking ==
                                    0)
                            ? SizedBox.shrink()
                            : Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '${kdsController.getStationOrderListResponse!.statusCounts!.cooking}',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 9, color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorTheme.badgeRed),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    0 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    1)
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
                  searchController.clear();
                  kdsController.setSubMenuIndex(2);
                },
                child: SizedBox(
                  // width: Get.width * 0.3,
                  height: 30,
                  child: Container(
                    // padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 2
                          ? ColorTheme.appColor
                          : Color(0xFFF6F6F6),
                    ),
                    child: Center(
                      child: Text(
                        (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .defOrdStatus ==
                                5)
                            ? Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('BAR')
                                ? 'Making'
                                : 'Cooking'
                            : 'Ready',
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
          ],
        ),
      );
    });
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
  void _handleMessage(RemoteMessage message) {}

  // Matches cancel_at with order updated_at across local/ISO/UTC formats
  bool _isSameCancelEventTime(String? cancelAt, String? updatedAt) {
    if (cancelAt == null ||
        updatedAt == null ||
        cancelAt.isEmpty ||
        updatedAt.isEmpty) {
      return false;
    }
    if (cancelAt == updatedAt) return true;
    DateTime? cancelTime = DateTime.tryParse(cancelAt);
    DateTime? updateTime = DateTime.tryParse(updatedAt);
    cancelTime ??= DateTime.tryParse(cancelAt.replaceFirst(' ', 'T'));
    updateTime ??= DateTime.tryParse(updatedAt.replaceFirst(' ', 'T'));
    if (cancelTime == null || updateTime == null) return false;
    return cancelTime.toUtc().difference(updateTime.toUtc()).inSeconds.abs() <=
        2;
  }

  Future<dynamic> onSelectNotification(NotificationResponse payload) async {
    // implement the navigation logic
    if (Platform.isAndroid) {
      var jsonData = jsonDecode(payload.payload ?? '{}');
      // print('$jsonData');
      if (jsonData != null) {
        // print('===============${message.data}');
      }
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('..................message');
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
    final NotificationSettings settings = await _messaging.requestPermission(
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

          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(new_order);
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
            final alertSound = message.notification?.android?.sound;
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
              loopOrderAlert
                  ? orderAlertSilentChannelId
                  : (alertSound ?? 'default'),
              'My Genie',
              importance: Importance.max,
              enableVibration: true,
              playSound: !loopOrderAlert,
              priority: n.Priority.high,
              // priority: Priority.high,
              // ticker: 'ticker',
              sound: loopOrderAlert
                  ? null
                  : RawResourceAndroidNotificationSound(alertSound ?? 'default'),
            );
            NotificationDetails notificationDetails = NotificationDetails(
                android: androidNotificationDetails,
                iOS: DarwinNotificationDetails());
            await flutterLocalNotificationsPlugin.show(
                0,
                message.notification?.title,
                message.notification?.body,
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

  listenBlutooth() {
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' -----------------home status bt $status ------------------ ');

      if (status == BTStatus.connected && pendingTask != null) {
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
            showErrorToast('${printer?.areaName ?? ''} kot failed');
            isConnect = true;
            isFailedPrint = true;
          });
        } else {
          isConnect = false;
          print('%%%%%%%%%');
        }
      }
      //  else {
      //   print('..................printer is open');
      // }
    });
  }

  void processNextOrder() async {
    // If no orders in the queue or an order is currently being processed, return.
    if (orderQueue.isEmpty || isProcessingOrder) return;

    // Mark as processing
    isProcessingOrder = true;

    // Remove the next order from the queue
    var order = orderQueue.removeAt(0); // Get and remove the first order

    try {
      if (GetPlatform.isWindows) {
        final printers = await Printing.listPrinters();
        for (var element in printers) {
          if (element.isAvailable &&
              (element.name.toLowerCase() ==
                  printer!.wifiPrinterName!.toLowerCase())) {
            await Printing.directPrintPdf(
              printer: element,
              onLayout: (_) => generateKotPdf(order),
            );
            break;
          }
        }
      } else {
        // placeOrderByteConvert(currentOrder);
        if (Platform.isIOS) {
          await iosPrintEscPos(
            await PrintByteConvert().byteConvert(
                printType: 'station_kot',
                printTitle: (order.orderDetailsFood ?? []).isNotEmpty &&
                        order.orderDetailsFood!
                            .every((e) => e.foodStatus == 3)
                    ? 'Cancel KOT'
                    : '',
                orderType: order.orderDetailsOrder?.orderType ?? '',
                stationName: (order.orderDetailsFood != null &&
                        order.orderDetailsFood!.isNotEmpty)
                    ? (order.orderDetailsFood!.first.station ?? '')
                    : '',
                paperRoll: printer!.printerPaperRoll == 58 ? 58 : 80,
                orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.now())}',
                waiterName:
                    '${order.restaurantTable?.restaurantWaiterName ?? ''}',
                tablename: order.restaurantTable == null ||
                        (order.restaurantTable?.tableNo ?? '') == ''
                    ? (order.orderDetailsOrder?.orderType == 'delivery'
                        ? 'Delivery'
                        : order.orderDetailsOrder?.orderType == 'take_away'
                            ? 'Take Away'
                            : 'WC')
                    : (order.restaurantTable?.title ?? '') == ''
                        ? '${order.restaurantTable?.tableNo ?? ''}'
                        : '${order.restaurantTable?.title ?? ''}-${order.restaurantTable?.tableNo ?? ''}',
                custName: order.orderDetailsOrder?.username ?? '',
                custPhone: '${order.user?.phone ?? ''}',
                stationOrderList: order.orderDetailsFood ?? [],
                orderNote: order.orderDetailsOrder?.orderNote ?? ''),
          );
        } else {
          await printEscPos(
            await PrintByteConvert().byteConvert(
                printType: 'station_kot',
                printTitle: (order.orderDetailsFood ?? []).isNotEmpty &&
                        order.orderDetailsFood!
                            .every((e) => e.foodStatus == 3)
                    ? 'Cancel KOT'
                    : '',
                orderType: order.orderDetailsOrder?.orderType ?? '',
                stationName: (order.orderDetailsFood != null &&
                        order.orderDetailsFood!.isNotEmpty)
                    ? (order.orderDetailsFood!.first.station ?? '')
                    : '',
                paperRoll: printer!.printerPaperRoll == 58 ? 58 : 80,
                orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.now())}',
                waiterName:
                    '${order.restaurantTable?.restaurantWaiterName ?? ''}',
                tablename: order.restaurantTable == null ||
                        (order.restaurantTable?.tableNo ?? '') == ''
                    ? (order.orderDetailsOrder?.orderType == 'delivery'
                        ? 'Delivery'
                        : order.orderDetailsOrder?.orderType == 'take_away'
                            ? 'Take Away'
                            : 'WC')
                    : (order.restaurantTable?.title ?? '') == ''
                        ? '${order.restaurantTable?.tableNo ?? ''}'
                        : '${order.restaurantTable?.title ?? ''}-${order.restaurantTable?.tableNo ?? ''}',
                custName: order.orderDetailsOrder?.username ?? '',
                custPhone: '${order.user?.phone ?? ''}',
                stationOrderList: order.orderDetailsFood ?? [],
                orderNote: order.orderDetailsOrder?.orderNote ?? ''),
          );
        }
      }
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      await Future.delayed(Duration(seconds: 2)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      isProcessingOrder = false;

      // If there are more orders in the queue, process the next one
      if (orderQueue.isNotEmpty) {
        processNextOrder(); // Continue with the next order
      }
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcess(Orders order) {
    // Add the new order to the queue
    orderQueue.add(order);

    // Start processing the next order if not already processing
    if (!isProcessingOrder) {
      processNextOrder();
    }
  }

// ///////////////////////   SOCKET QUEUE   /////////////
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

      var isCallApi = await Get.find<KdsController>()
          .getStationOrderDetailFromSocket(
              socket: homeSocket!,
              type: currentOrder.orderType!,
              orderId: currentOrder.orderId!,
              foodStatus: currentOrder.orderType == 'update-food-status' ||
                      currentOrder.orderType == 'update-item-status'
                  ? '${currentOrder.orderOthervalue}'
                  : '0',
              callBackFunction: (Orders? order) async {
                if (order != null) {
                  await Future.delayed(
                      Duration(seconds: 2)); // Simulate async processing
                  checkQueueProcess(order);
                }
              });

      if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .printingOption ==
              'Station' &&
          isCallApi != null &&
          isCallApi &&
          ((currentOrder.orderType == 'update-order' ||
                  currentOrder.orderType == 'update-order-status')
              ? Get.find<KdsController>()
                      .getStationOrderListResponse!
                      .orders![Get.find<KdsController>().updatedOrderIndex]
                      .orderDetailsOrder!
                      .isPrintKot ==
                  'Yes'
              : false)) {
        cartProductList = [];
        isFailedPrint = false;
        List<OrderDetailsFood> tempCartList = [];
        List<OrderDetailsFood> cancelFoodList = [];
        if (currentOrder.orderType == 'update-order' ||
            currentOrder.orderType == 'update-order-status') {
          var foodList = Get.find<KdsController>()
              .getStationOrderListResponse!
              .orders![Get.find<KdsController>().updatedOrderIndex]
              .orderDetailsFood;

          for (var e in foodList!) {
            if (currentOrder.orderType == 'update-order-status') {
              if ((e.station!.toUpperCase() ==
                      Get.find<AuthController>()
                          .profileModel!
                          .roleName!
                          .toUpperCase()) &&
                  e.foodStatus == 3 &&
                  e.cancelAt != null &&
                  _isSameCancelEventTime(
                      e.cancelAt,
                      Get.find<KdsController>()
                          .getStationOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .orderDetailsOrder!
                          .updatedAt)) {
                cancelFoodList.add(e);
              }
              if (Get.find<KdsController>()
                          .getStationOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .orderDetailsOrder!
                          .fOrderStatus ==
                      3 &&
                  (e.station!.toUpperCase() ==
                      Get.find<AuthController>()
                          .profileModel!
                          .roleName!
                          .toUpperCase()) &&
                  e.cancelAt != null &&
                  _isSameCancelEventTime(
                      e.cancelAt,
                      Get.find<KdsController>()
                          .getStationOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .orderDetailsOrder!
                          .updatedAt)) {
                tempCartList.add(e);
              }
            } else if (currentOrder.orderType == 'update-order') {
              if ((e.station!.toUpperCase() ==
                      Get.find<AuthController>()
                          .profileModel!
                          .roleName!
                          .toUpperCase()) &&
                  e.foodStatus != 3 &&
                  Get.find<KdsController>()
                          .getStationOrderListResponse!
                          .orders![Get.find<KdsController>().updatedOrderIndex]
                          .orderDetailsOrder!
                          .editOrderCount ==
                      e.editFoodItemCount) {
                tempCartList.add(e);
              }
            }
          }
          if (cancelFoodList.isNotEmpty) {
            Orders tempOrder = Orders(
                deliveryAddress: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .deliveryAddress,
                orderDetailsFood: cancelFoodList,
                orderDetailsOrder: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderDetailsOrder,
                readyDetails: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .readyDetails,
                restaurantTable: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantTable,
                user: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .user);
            Future.delayed(Duration(seconds: 2));
            checkQueueProcess(tempOrder);
          } else if (tempCartList.isNotEmpty) {
            Orders tempOrder = Orders(
                deliveryAddress: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .deliveryAddress,
                orderDetailsFood: tempCartList,
                orderDetailsOrder: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .orderDetailsOrder,
                readyDetails: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .readyDetails,
                restaurantTable: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .restaurantTable,
                user: Get.find<KdsController>()
                    .getStationOrderListResponse!
                    .orders![Get.find<KdsController>().updatedOrderIndex]
                    .user);
            Future.delayed(Duration(seconds: 2));
            checkQueueProcess(tempOrder);
          }
        }
      }

      // await Future.delayed(Duration(seconds: 2)); // Simulate async processing
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
      {String? orderType, String? orderId, String? otherValue}) {
    // Add the new order to the queue
    orderIdQueue.add(OrderIdType(
        orderId: orderId!,
        orderType: orderType!,
        orderOthervalue: otherValue!));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  Future<Uint8List> generateKotPdf(Orders order) async {
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.poppinsMedium();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
            profileModel.billPrinterPaperRoll == 58
                ? 48 * PdfPageFormat.mm
                : 72 * PdfPageFormat.mm,
            double.infinity,
            marginLeft: 0,
            marginRight: 0,
            marginTop: 0,
            marginBottom: 0), // 58mm width
        build: (context) {
          final bool isCancelKot = (order.orderDetailsFood ?? []).isNotEmpty &&
              order.orderDetailsFood!.every((e) => e.foodStatus == 3);
          return pw.Column(
            children: [
              pw.Text(profileModel.restaurants!.first.name!,
                  style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text(profileModel.restaurants!.first.address!,
                  style: pw.TextStyle(font: font, fontSize: 8)),
              if (profileModel.restaurants![0].gstCode != '')
                pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
                    style: pw.TextStyle(font: font, fontSize: 8)),

              if (profileModel.restaurants![0].fssai != '')
                pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
                    style: pw.TextStyle(font: font, fontSize: 8)),
              if (isCancelKot)
                pw.Text('Cancel KOT',
                    style: pw.TextStyle(font: font, fontSize: 10)),

// ////////////////   ORDER DETAIL    /////////////////

              pw.Row(children: [
                pw.Expanded(
                    child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                      'Order ID. ${order.orderDetailsOrder!.restaurantOrderId}',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                )),
                if (order.orderDetailsOrder != 'delivery' &&
                    order.orderDetailsOrder != 'take_away')
                  pw.SizedBox(width: 4),
                if (order.orderDetailsOrder != 'delivery' &&
                    order.orderDetailsOrder != 'take_away')
                  pw.Expanded(
                      child: pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                        '${Get.find<AuthController>().profileModel!.empFname}',
                        style: pw.TextStyle(font: font, fontSize: 8)),
                  )),
                pw.SizedBox(width: 4),
                pw.Expanded(
                    child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ))
              ]),

              // if (order.orderDetailsOrder != 'delivery' &&
              //     order.orderDetailsOrder != 'take_away')
              //   pw.Row(children: [
              //     pw.Expanded(
              //         child: pw.Align(
              //       alignment: pw.Alignment.centerLeft,
              //       child: pw.Text('Dine In',
              //           style: pw.TextStyle(font: font, fontSize: 6)),
              //     )),
              //     pw.SizedBox(width: 5),
              //     pw.Expanded(
              //         child: pw.Align(
              //       alignment: pw.Alignment.centerRight,
              //       child: pw.Text(
              //           '${Get.find<AuthController>().profileModel.empFname}',
              //           style: pw.TextStyle(font: font, fontSize: 6)),
              //     ))
              //   ]),
              pw.Row(children: [
                pw.Expanded(
                    child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(order.orderDetailsOrder?.username ?? '',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                )),
                pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                        order.restaurantTable == null ||
                                order.restaurantTable!.tableNo == ''
                            ? order.orderDetailsOrder == 'delivery'
                                ? 'Delivery'
                                : order.orderDetailsOrder?.orderType ==
                                        'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : order.restaurantTable!.title == ''
                                ? '${order.restaurantTable!.tableNo}'
                                : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                        style: pw.TextStyle(font: font, fontSize: 8)),
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Expanded(
                    child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(order.user?.phone ?? '',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ))
              ]),
              // pw.Text(
              //     order.restaurantTable == null ||
              //             order.restaurantTable.tableNo == ''
              //         ? order?.orderDetailsOrder == 'delivery'
              //             ? 'Delivery'
              //             : order.orderDetailsOrder?.orderType == 'take_away'
              //                 ? 'Take Away'
              //                 : 'WC'
              //         : order.restaurantTable.title == ''
              //             ? '${order.restaurantTable.tableNo}'
              //             : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}',
              //     style: pw.TextStyle(font: font, fontSize: 6)),
              // pw.Divider(),

// //////////////////   FOOD DETAIL   ///////////////////
              pw.Divider(height: 0),

              pw.Row(children: [
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('SL',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 4,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('item_info'.tr,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('qty'.tr,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              ...List.generate(order.orderDetailsFood!.length, (i) {
                OrderDetailsFood cart = order.orderDetailsFood![i];
                String variationText = '';
                String addons = '';
                if (cart.variation != null && cart.variation!.isNotEmpty) {
                  for (int j = 0; j < cart.variation!.length; j++) {
                    variationText +=
                        '${variationText.isNotEmpty ? ', ' : ''}${cart.variation![j].name} (';

                    if (cart.variation![j].values != null) {
                      List<String> labelList = [];
                      for (var element in cart.variation![j].values!) {
                        labelList.add(element.level!);
                      }
                      variationText +=
                          '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                    }

                    variationText += ')';
                  }
                }

                for (var i = 0; i < cart.addOns!.length; i++) {
                  addons += '${cart.addOns![i].name} (${cart.addOns![i].qty})';
                }

                return (!isCancelKot && cart.foodStatus == 3)
                    ? pw.SizedBox.shrink()
                    : pw.Column(children: [
                        pw.Row(children: [
                          pw.Expanded(
                              flex: 1,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text('${i + 1}.',
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 8,
                                        decoration: cart.foodStatus == 3
                                            ? pw.TextDecoration.lineThrough
                                            : null)),
                              )),
                          pw.Expanded(
                              flex: 4,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text(
                                    '${cart.foodDetails!.name} $variationText',
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 8,
                                        decoration: cart.foodStatus == 3
                                            ? pw.TextDecoration.lineThrough
                                            : null)),
                              )),
                          pw.Expanded(
                              flex: 1,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text(
                                    // '${cart.quantity}',
                                    formatQuantity(cart.quantity),
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 8,
                                        decoration: cart.foodStatus == 3
                                            ? pw.TextDecoration.lineThrough
                                            : null)),
                              )),
                        ]),
                        if (addons != '')
                          pw.Column(children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 1),
                              child: buildDottedLine(180),
                            ),
                            pw.Row(children: [
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text('',
                                        style: pw.TextStyle(
                                            font: font, fontSize: 8)),
                                  )),
                              pw.Expanded(
                                  flex: 2,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text('$addons',
                                        style: pw.TextStyle(
                                            font: font, fontSize: 8)),
                                  )),
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text('',
                                        style: pw.TextStyle(
                                            font: font, fontSize: 6)),
                                  )),
                            ]),
                          ]),
                        if (order.orderDetailsOrder!.orderNote != '' &&
                            cart.foodDetails!.name
                                .toString()
                                .toLowerCase()
                                .contains('out of'))
                          pw.Column(children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 1),
                              child: buildDottedLine(180),
                            ),
                            pw.Row(children: [
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text('',
                                        style: pw.TextStyle(
                                            font: font, fontSize: 6)),
                                  )),
                              pw.Expanded(
                                  flex: 2,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                        'Notes  :${order.orderDetailsOrder!.orderNote}',
                                        style: pw.TextStyle(
                                            font: font, fontSize: 8)),
                                  )),
                            ]),
                          ]),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 1),
                          child: buildDottedLine(180),
                        ),
                      ]);
              }),

              pw.SizedBox(height: 10),
              pw.Text('Powered by MyGenie',
                  style: pw.TextStyle(font: font, fontSize: 8)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Future placeOrderByteConvert(Orders order) async {
  //   List<int> bytes = [];
  //   bool isOutOfMenu = false;
  //   final profile = await CapabilityProfile.load(name: 'XP-N160I');
  //   final generator = Generator(
  //       printer!.printerPaperRoll == 58 ? PaperSize.mm58 : PaperSize.mm80,
  //       profile);
  //   bytes += generator.setGlobalCodeTable('CP1252');

  //   if (Get.find<AuthController>()
  //           .profileModel!
  //           .restaurants
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
  //         Get.find<AuthController>().profileModel.restaurants[0].name,
  //         styles: PrinterConfig().titleStyle());
  //     bytes += generator.text(
  //         Get.find<AuthController>().profileModel.restaurants[0].address,
  //         styles: PrinterConfig().addressStyle());
  //   }
  //   bytes += generator.text(order.orderDetailsFood.first.station,
  //       styles: PrinterConfig().titleStyle());

  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'order_id'.tr +
  //             ':' +
  //             ' ${order.orderDetailsOrder.restaurantOrderId}',
  //         width: 6,
  //         styles: PrinterConfig().orderIdStyle()),
  //     PosColumn(
  //         text:
  //             '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.now())}',
  //         width: 6,
  //         styles: PrinterConfig().orderCreateDateStyle()),
  //   ]);
  //   if (order.orderDetailsOrder.orderType != 'delivery' &&
  //       order.orderDetailsOrder.orderType != 'take_away')
  //     bytes += generator.row([
  //       PosColumn(
  //           text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
  //       PosColumn(
  //         text: '',
  //         width: 1,
  //         styles: PosStyles(align: PosAlign.center),
  //       ),
  //       PosColumn(
  //           text: '${order.restaurantTable.restaurantWaiterName}',
  //           width: 6,
  //           styles: PrinterConfig().waiterNameStyle()),
  //     ]);
  //   bytes += generator.text(
  //       order.restaurantTable == null || order.restaurantTable.tableNo == ''
  //           ? order.orderDetailsOrder.orderType == 'delivery'
  //               ? 'Delivery'
  //               : order.orderDetailsOrder?.orderType == 'take_away'
  //                   ? 'Take Away'
  //                   : 'WC'
  //           : order.restaurantTable.title == ''
  //               ? '${order.restaurantTable.tableNo}'
  //               : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}',
  //       // ordersPrint.restaurantDetails.tableNo +
  //       // '-' +
  //       // ordersPrint.restaurantDetails.tableArea,
  //       styles: PrinterConfig().tableNoStyle());
  //   if (order.orderDetailsOrder.userId != null) {
  //     bytes += generator.row([
  //       PosColumn(
  //         text: '${order?.user?.fName ?? ''} ${order?.user?.lName ?? ''}',
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
  //         text: '${order?.user?.phone ?? ''}',
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
  //   } else if (order.orderDetailsOrder.username != '') {
  //     bytes += generator.text(
  //       '${order.orderDetailsOrder.username}',
  //       styles: PosStyles(fontType: PosFontType.fontB),
  //     );
  //   }
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
  //   for (var i = 0; i < order.orderDetailsFood.length; i++) {
  //     OrderDetailsFood cart = order.orderDetailsFood[i];
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
  //     if (order.orderDetailsOrder.orderNote != '' &&
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
  //           text: 'Notes: ${order.orderDetailsOrder.orderNote}',
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

  //     bytes += generator.hr(ch: '....');
  //   }

  //   if (order.orderDetailsOrder.orderNote != '' && !isOutOfMenu) {
  //     bytes += generator.text(
  //         '${'Notes'.tr}:  ${order.orderDetailsOrder.orderNote}',
  //         styles: PrinterConfig().foodStyle());
  //   }
  //   print('bytes length:${bytes.length}');
  //   if (Platform.isIOS) {
  //     await iosPrintEscPos(bytes);
  //   } else {
  //     await printEscPos(bytes);
  //   }
  // }

  Future printEscPos(List<int> bytes) async {
    print('bytes length:${bytes.length}');
    // bytes += generator.feed(2);
    // bytes += generator.cut();
    // await PrinterManager.instance
    //     .disconnect(type: PrinterType.bluetooth); //  what this do explain
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        address: printer!.printerIp,
        deviceName: printer!.printerName); //device name or ip was mandadory
    try {
      await _printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
          isBle: bluetoothPrinter.isBle ?? false,
        ),
      );
      pendingTask = null;
    } catch (e) {
      print('%%%%%%%$e');
    }

    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try {
        // print('..................printer is open 111111');

        bool data = await _printerManager.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);

        // Future.delayed(Duration(seconds: 2), () async {
        //   // print('%%%%%%%%%%%%%isPrinted---$data');
        //   bytes = null;
        //   print('..................Byte is open 2');

        //   Get.find<LoadingController>().startLoading(false);
        //   await Get.find<LoadingController>()
        //       .changeText(data: 'Successfully printed!!');
        //   await Get.find<LoadingController>().changeStatus(data: true);
        //   // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
        // });
      } catch (e) {}
    }
  }

  Future iosPrintEscPos(List<int> bytes) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    // bytes += generator.cut();

    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    if (printer!.macPrinterIp == '' &&
        NetworkPrinterResolver.kotPrinter(printer) == null) {
      showErrorToast('${printer!.areaName} kot failed');
      isConnect = true;
      isFailedPrint = true;
    } else {
      final bool result = await IosPrintTransport.connect(
          wifiPrinter: NetworkPrinterResolver.kotPrinter(printer),
          macPrinterAddress: printer!.macPrinterIp!);
      if (result) {
        await Future.delayed(const Duration(seconds: 4));
        await IosPrintTransport.writeBytes(bytes);
        await Future.delayed(const Duration(seconds: 4));
        bytes.clear();
        final isDisconnect = await IosPrintTransport.disconnect;
        print('is disconnect $isDisconnect');
        print("print test result: $result");
      } else {
        showErrorToast('${printer!.areaName} kot failed');
        isConnect = true;
        isFailedPrint = true;
      }
    }
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

// String formatQuantity(num? value) {
//   return (value ?? 0)
//       .toStringAsFixed(3)
//       .replaceFirst(RegExp(r'\.?0+$'), '');
// }
