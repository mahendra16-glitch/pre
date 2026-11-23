import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/token_display_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_token_display_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart';

class TokenDisplayHomeScreen extends StatefulWidget {
  @override
  State<TokenDisplayHomeScreen> createState() => _TokenDisplayHomeScreenState();
}

class _TokenDisplayHomeScreenState extends State<TokenDisplayHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PackageInfo? packageInfo;

  bool isProcessingOrderQueue = false;
  List<OrderIdType> orderIdQueue = [];
  bool isProcessingOrder = false;
  @override
  void initState() {
    super.initState();
    getApiData();
  }

  getApiData() async {
    await Get.find<TokenDisplayController>().fetchOrders();
    connectToSocketIO();
    packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
            child: IconButton(
              icon: Image.asset(Images.menu, color: ColorTheme.appColor),
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
              Get.find<AuthController>().profileModel!.roleName!.toUpperCase(),
              style: poppinsSemiBold.copyWith(
                  color: ColorTheme.appColor, fontSize: 15),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Get.find<TokenDisplayController>().fetchOrders();
              },
              icon: Icon(Icons.refresh, color: ColorTheme.appColor),
            ),
          ]),
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
                    'My Profile',
                    style: poppinsMedium.copyWith(
                        fontSize: 14, color: ColorTheme.hintText),
                  ),
                  children: <Widget>[
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
                                      await Get.find<AuthController>().logout();

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
                  style:
                      poppinsMedium.copyWith(fontSize: 10, color: Colors.grey),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 3),
                ),
                color: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text("No.",
                          style: poppinsSemiBold.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: ColorTheme.appColor))),
                  Expanded(
                      flex: 1,
                      child: Text("Name",
                          textAlign: TextAlign.center,
                          style: poppinsSemiBold.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: ColorTheme.appColor))),
                  // Expanded(
                  //     flex: 2,
                  //     child: Text("Station",
                  //         style: poppinsSemiBold.copyWith(
                  //             fontSize: 22,
                  //             fontWeight: FontWeight.w600,
                  //             color: ColorTheme.appColor))),
                  // Expanded(
                  //     flex: 2,
                  //     child: Text("Counter",
                  //         style: poppinsSemiBold.copyWith(
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 22,
                  //             color: ColorTheme.appColor))),
                  Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 120),
                        child: Text("Status",
                            textAlign: TextAlign.center,
                            style: poppinsSemiBold.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                color: ColorTheme.appColor))),
                  )
                ],
              ),
            ),

            // List
            GetBuilder<TokenDisplayController>(builder: (tokenController) {
              return tokenController.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: tokenController.order.length,
                        itemBuilder: (context, index) {
                          TokenEmployeeList order =
                              tokenController.order[index];
                          return (order.stationStatus == 1 ||
                                  order.stationStatus == 2)
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    color: Colors.black,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(order.tokenNo ?? '',
                                            // customizeOrderId(
                                            //     order.tokenNo ?? ''),
                                            style: poppinsMedium.copyWith(
                                              fontSize: 50,
                                              color: Colors.white,
                                            )),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(order.userName ?? '',
                                              textAlign: TextAlign.center,
                                              style: poppinsMedium.copyWith(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ))),
                                      // Expanded(
                                      //     flex: 2,
                                      //     child: Text(order.stationName ?? '',
                                      //         style: poppinsMedium.copyWith(
                                      //           fontSize: 40,
                                      //         ))),
                                      // Expanded(
                                      //     flex: 2,
                                      //     child: Text(order.counterName ?? '',
                                      //         style: poppinsMedium.copyWith(
                                      //           fontSize: 20,
                                      //           color: Colors.white,
                                      //         ))),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 120),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: order.stationStatus == 1
                                                  ? ColorTheme.appColor
                                                  : Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              order.stationStatus == 1
                                                  ? 'Cooking'
                                                  : "Ready",
                                              textAlign: TextAlign.center,
                                              style: poppinsSemiBold.copyWith(
                                                color: order.stationStatus == 1
                                                    ? ColorTheme.white
                                                    : Colors.white,
                                                fontSize: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  String customizeOrderId(String orderId) {
    // Remove only the first three zeros if they exist
    if (orderId.startsWith('000')) {
      return orderId.substring(3);
    }
    return orderId;
  }

  void connectToSocketIO() {
    try {
      homeSocket = io(AppConstants.SOCKET_BASE_URL, <String, dynamic>{
        'transports': ['websocket'],
        // 'path': '/socket',
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
      homeSocket?.off('new_order_$restaurantId');

      homeSocket?.on('new_order_$restaurantId', (data) async {
        print('Received socket data: $data');
        if (restaurantId == '${data[2]}') {
          // Handle various order-related events
          if (data[0] == 'update-order' ||
              data[0] == 'new-order' ||
              data[0] == 'scan-new-order' ||
              data[0] == 'update-food-status' ||
              data[0] == 'update-item-status' ||
              data[0] == 'update-order-status') {
            checkQueueProcessFromSocket(
              isAggregator: false,
              orderType: data[0],
              orderId: '${data[1]}',
              otherValue: '${data[3]}',
              newOrderJson: data[0] == 'new-order' ? data[4] : null,
            );
          }
        }
      });

      // Handle the 'disconnect' event
      homeSocket?.on('disconnect', (reason) {
        print('Socket disconnected: $reason');
      });

      homeSocket?.onReconnect((_) async {
        print('♻️ Socket Reconnected');

        await Get.find<TokenDisplayController>().fetchOrders();
      });
    } catch (e) {
      // Log any errors that occur during socket initialization or connection
      print('Socket connection error: ${e.toString()}');
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcessFromSocket(
      {String? orderType,
      String? orderId,
      bool? isAggregator,
      String? otherValue,
      dynamic newOrderJson}) {
    // Add the new order to the queue

    orderIdQueue.add(OrderIdType(
        orderId: orderId,
        orderType: orderType,
        isAggregator: isAggregator ?? false,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
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

    mygenieOrder(currentOrder);
  }

  mygenieOrder(OrderIdType currentOrder) async {
    try {
      await Get.find<TokenDisplayController>().getOrderDetailFromSocket(
        type: currentOrder.orderType,
        orderId: '${currentOrder.orderId}',
      );

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
}
