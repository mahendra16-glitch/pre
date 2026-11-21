import 'package:country_code_picker/country_code_picker.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../controller/auth_controller.dart';
import '../../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../helper/colors.dart';
import '../../../helper/logo_helper.dart';
import '../../../util/app_constants.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../base/my_text_field.dart';
import '../KDS/home/kds_home_screen.dart';

class SwiggyOrders extends StatefulWidget {
  @override
  State<SwiggyOrders> createState() => _SwiggyOrdersState();
}

class _SwiggyOrdersState extends State<SwiggyOrders> {
  TextEditingController searchOrder = TextEditingController();
  Socket? socket;
  List<OrderIdType> orderIdQueue = [];
  List<Order> orderQueue = [];
  bool isProcessingOrderQueue = false;

  @override
  void initState() {
    super.initState();
    Get.find<SwiggyController>().fetchOrders();
    connectToSocketIO();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 35, color: ColorTheme.green),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Image.asset(
              logoHelper.appLogo!,
              width: GetPlatform.isWindows ? Get.width * 0.1 : Get.width * 0.3,
            ),
          ],
        ),
        elevation: 0,
      ),
      body: GetBuilder<SwiggyController>(
        builder: (swiggyController) {
          if (swiggyController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (swiggyController.order.isEmpty) {
            return const Center(child: Text('No orders found... Sorry!'));
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        height: 40,
                        padding: EdgeInsets.only(
                            left: Dimensions.PADDING_SIZE_SMALL,
                            right: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorTheme.borderGrey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextField(
                          controller: searchOrder,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10, top: 5),
                            suffixIcon:
                                Icon(Icons.search, color: ColorTheme.appColor),
                            hintText: 'Search here..',
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onChanged: (value) async {
                            swiggyController.update();
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        swiggyController.fetchOrders();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.refresh_outlined,
                            color: ColorTheme.appColor, size: 35),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: StaggeredGrid.count(
                      crossAxisCount: 1,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: swiggyController.order.where((order) {
                        // Filter with dine in
                        if ((order.orderDetailsOrder.fOrderStatus == 0 ||
                                    order.orderDetailsOrder.fOrderStatus == 1 ||
                                    order.orderDetailsOrder.fOrderStatus == 2 ||
                                    order.orderDetailsOrder.fOrderStatus ==
                                        5) &&
                                (searchOrder.text.isEmpty
                                    ? true
                                    : order.orderDetailsOrder.urbanOrderId
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                            searchOrder.text.toLowerCase()))
                            //  ||
                            // order.orderDetailsOrder.fOrderStatus == 5
                            ) {
                          return true;
                        }

                        return false;
                      }).map((order) {
                        // Now return the widget directly
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.RADIUS_EXTRA_LARGE,
                            ),
                            color: Colors.green.shade100,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _showCustomerDetails(
                                          context, order.customerDetails);
                                    },
                                    child: Text(
                                      order.orderDetailsOrder.userName ??
                                          'Unknown',
                                      style: poppinsMedium.copyWith(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    order.orderDetailsOrder.urbanOrderId ?? '',
                                    style: poppinsMedium.copyWith(fontSize: 14),
                                    maxLines: 2,
                                  ),
                                  Image.asset(
                                    order.orderDetailsOrder.orderPlateform ==
                                            'zomato'
                                        ? Images.zomato
                                        : Images.swiggy,
                                    width: 50,
                                    height: 50,
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFF8C8C8C)),
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.orderDetailsFood.length,
                                itemBuilder: (context, foodIndex) {
                                  final orderFood =
                                      order.orderDetailsFood[foodIndex];

                                  return ListTile(
                                    title: Text(
                                      '${orderFood.title} (${orderFood.quantity})',
                                      style: poppinsMedium.copyWith(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderFood.variation.isNotEmpty)
                                          Text(
                                            'Variants: ${orderFood.variation}',
                                            style: poppinsMedium.copyWith(
                                              color: Color(0xFF848484),
                                              fontSize: 12,
                                            ),
                                          ),
                                        if (orderFood.foodLevelNotes.isNotEmpty)
                                          Text(
                                            'Notes: ${orderFood.foodLevelNotes}',
                                            style: poppinsMedium.copyWith(
                                              color: Color(0xFF848484),
                                              fontSize: 12,
                                            ),
                                          ),
                                        if (orderFood.createdAt.isNotEmpty)
                                          Text(
                                            getShortTimeDifference(
                                                orderFood.createdAt),
                                            style: poppinsMedium.copyWith(
                                              color: Color(0xFF848484),
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    // trailing: IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.cancel))
                                  );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: DottedLine(
                                  direction: Axis.horizontal,
                                  lineThickness: 1.0,
                                  dashLength: 2.5,
                                  dashColor: Color(0xFF8C8C8C),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "${order.orderDetailsOrder.orderNote} " ?? '',
                                  style: poppinsMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Spacer(),
                                    // Column(
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: [
                                    //     Text(
                                    //       'Total tax : ${order.orderDetailsOrder.totaTaxAmount.toString()}',
                                    //       style: poppinsMedium.copyWith(
                                    //         color: Colors.black,
                                    //         fontSize: 14,
                                    //       ),
                                    //     ),
                                    //     SizedBox(height: 5),
                                    //     Text(
                                    //       'Total Amount : ${order.orderDetailsOrder.orderAmount}',
                                    //       style: poppinsMedium.copyWith(
                                    //         color: Colors.black,
                                    //         fontSize: 14,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Text(
                                      order.orderDetailsOrder.otp.isNotEmpty
                                          ? 'OTP : ${order.orderDetailsOrder.otp}'
                                          : 'no otp',
                                      style: poppinsMedium.copyWith(
                                        color: Color(0xFF848484),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    if (order.orderDetailsOrder.fOrderStatus ==
                                        0)
                                      InkWell(
                                        onTap: () {
                                          searchOrder.clear();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          Get.bottomSheet(cancelOrder(order),
                                              backgroundColor:
                                                  Colors.transparent,
                                              isScrollControlled: true,
                                              ignoreSafeArea: false);
                                          // Get.bottomSheet(
                                          //   ConfirmationDialog(
                                          //       icon: Images.support,
                                          //       description:
                                          //           'Are you sure you want to cancel the complete order?',
                                          //       isLogOut: true,
                                          //       onYesPressed: () async {
                                          //         Map<String, dynamic> jsonBody = {
                                          //           'order_id': order.id.toString(),
                                          //           'order_status': 'cancelled',
                                          //           'role_name': Get.find<AuthController>()
                                          //               .profileModel
                                          //               .role
                                          //               .first,
                                          //         };
                                          //         Get.back();
                                          //         Get.find<KdsController>()
                                          //             .changeOrderStatus(jsonBody, callback);
                                          //       }),
                                          // );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Icon(Icons.close,
                                              size: 35,
                                              color: ColorTheme.appColor),
                                        ),
                                      ),
                                    order.orderDetailsOrder.fOrderStatus == 5
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7),
                                            height: 35,
                                            // width: 80,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: ColorTheme
                                                        .disableButtonText),
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Center(
                                              child: Text(
                                                'To be complete',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 13,
                                                    color: ColorTheme
                                                        .disableButtonText),
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(

                                            // style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Color(0xFFDFDFDF))),
                                            onPressed: () async {
                                              Map<String, dynamic> jsonBody = {
                                                'order_id':
                                                    order.orderDetailsOrder.id,
                                                "urban_order_id": order
                                                    .orderDetailsOrder
                                                    .urbanOrderId,

                                                'new_status': order
                                                            .orderDetailsOrder
                                                            .fOrderStatus ==
                                                        0
                                                    ? 'Acknowledged'
                                                    : order.orderDetailsOrder
                                                                .fOrderStatus ==
                                                            1
                                                        ? 'Food Ready'
                                                        : 'Dispatched',
                                                'message': 'Success',
                                                //  if(order.orderDetailsOrder.fOrderStatus)
                                              };
                                              if (order.orderDetailsOrder
                                                      .fOrderStatus ==
                                                  2) {
                                                searchOrder.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                Get.bottomSheet(
                                                    deliveryBoyDetail(order),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    ignoreSafeArea: false);
                                              } else {
                                                await swiggyController
                                                    .changeOrderStatus(
                                                        jsonBody);
                                              }
                                            },
                                            child: Text(order.orderDetailsOrder
                                                        .fOrderStatus ==
                                                    0
                                                ? 'Accept'
                                                : order.orderDetailsOrder
                                                            .fOrderStatus ==
                                                        1
                                                    ? 'Ready'
                                                    : order.orderDetailsOrder
                                                                .fOrderStatus ==
                                                            2
                                                        ? 'Dispatch'
                                                        : order.orderDetailsOrder
                                                                    .fOrderStatus ==
                                                                3
                                                            ? 'Cancel'
                                                            : order.orderDetailsOrder
                                                                        .fOrderStatus ==
                                                                    6
                                                                ? 'Completed'
                                                                : 'Acknowledged'))
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void connectToSocketIO() {
    try {
      // Configure socket transports must be specified
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

      // Connect to websocket
      // if (!socket.connected)
      socket?.connect();

      // Handle socket events
      // socket.on('connect', (_) => print('connect: ${socket.id}'));

      socket?.on(
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
                orderType: data[0],
                orderId: '${data[1]}',
                otherValue: '0',
                newOrderJson: data[0] == 'new-order' ? data[4] : null);
          }
        }
      });

      socket?.on('disconnect', (d) {
        print('disconnect----$d');

        // if (!socket.connected) {
        // print('Attempting to reconnect...');
        // socket.connect();
        // }
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
      print(e.toString());
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

      var isCallApi =
          await Get.find<SwiggyController>().getOrderDetailFromSocket(
        // socket: socket,
        foodStatus: '0',
        type: currentOrder.orderType,
        orderId: '${currentOrder.orderId}',
      );

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
        orderId: orderId,
        orderType: orderType,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  void _showCustomerDetails(
      BuildContext context, CustomerDetails customerDetails) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Customer Details",
                    style: poppinsMedium.copyWith(
                      color: Colors.green.shade400,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.green.shade400,
                      ))
                ],
              ),
              Divider(color: Color(0xFF8C8C8C)),
              const SizedBox(height: 10),
              _buildDetailRow(
                label: "Name",
                value: customerDetails.name ?? "Not Provided",
              ),
              _buildDetailRow(
                label: "Phone",
                value: customerDetails.phone ?? "Not Provided",
              ),
              // _buildDetailRow(
              //   label: "City",
              //   value: customerDetails.city ?? "Not Provided",
              // ),
              _buildDetailRow(
                label: "Address",
                value: customerDetails.address.line1 ?? "Not Provided",
              ),
              _buildDetailRow(
                label: "City",
                value: customerDetails.address.city ?? "Not Provided",
              ),
              _buildDetailRow(
                label: "Sub-Locality",
                value: customerDetails.address.subLocality ?? "Not Provided",
              ),
              // _buildDetailRow(
              //   label: "Pincode",
              //   value: (customerDetails.pincode == null ||
              //           customerDetails.pincode == 0)
              //       ? "Not Provided"
              //       : customerDetails.pincode.toString(),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Text(
            "$label :",
            style: poppinsMedium.copyWith(
              color: Color(0xFF2E2E2E),
              fontSize: 15,
            ),
          ),
          Text(
            " ${value.isEmpty || value == "Not Provided" ? 'No $label' : value}",
            style: poppinsMedium.copyWith(
              color: value.isEmpty || value == "Not Provided"
                  ? Colors.red.shade400
                  : Color(0xFF8C8C8C),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelOrder(Order order) {
    String? selectedReason;
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        // height: Get.height * 0.4,
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Cancel',
                          style: poppinsMedium.copyWith(
                              color: Colors.black, fontSize: 18)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: () {
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
                SizedBox(height: 10),
                GetBuilder<SwiggyController>(builder: (swiggyController) {
                  return swiggyController.cancelReasonList.isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              height: MediaQuery.of(context).size.width > 1600
                                  ? 65
                                  : 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_SMALL),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: ColorTheme.borderGrey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedReason ??
                                    swiggyController.cancelReasonList.first,
                                items: swiggyController.cancelReasonList
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      maxLines: 1,
                                      style: poppinsRegular.copyWith(
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    1600
                                                ? 17
                                                : Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  selectedReason = value!;
                                  swiggyController.update();
                                  // kdsController.setCancelReason(value);
                                },
                                underline: SizedBox(),
                              ),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: swiggyController.isLoading
                                  ? CircularProgressIndicator()
                                  : InkWell(
                                      onTap: () async {
                                        Map<String, dynamic> jsonBody = {
                                          'order_id':
                                              order.orderDetailsOrder.id,
                                          "urban_order_id": order
                                              .orderDetailsOrder.urbanOrderId,

                                          'new_status': 'Cancelled',
                                          'message': 'Success',
                                          'reason_code': selectedReason ?? ''
                                          //  if(order.orderDetailsOrder.fOrderStatus)
                                        };
                                        Get.back();
                                        await swiggyController
                                            .changeOrderStatus(jsonBody);
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 110,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.transparent),
                                            color: ColorTheme.appColor,
                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Text(
                                            'submit'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 18
                                                    : 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        );
                }),
                // TextField(
                //   controller: controller,
                //   autofocus: false,
                //   maxLines: 5,
                //   decoration: InputDecoration(
                //     hintText: 'Type here..'.tr,
                //     contentPadding:
                //         EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide(color: ColorTheme.borderGrey),
                //       borderRadius: BorderRadius.circular(7.0),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: ColorTheme.borderGrey),
                //       borderRadius: BorderRadius.circular(7.0),
                //     ),
                //     disabledBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: ColorTheme.borderGrey),
                //       borderRadius: BorderRadius.circular(7.0),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderSide: BorderSide(color: ColorTheme.borderGrey),
                //       borderRadius: BorderRadius.circular(7.0),
                //     ),
                //     hintStyle: poppinsMedium.copyWith(
                //         fontSize:
                //             MediaQuery.of(context).size.width > 1600 ? 17 : 13,
                //         color: ColorTheme.hintText),
                //     filled: true,
                //     fillColor: Colors.white,
                //   ),
                //   style: poppinsMedium.copyWith(
                //     color: Colors.black,
                //     fontSize:
                //         MediaQuery.of(context).size.width > 1600 ? 17 : 13,
                //   ),
                //   onChanged: (value) async {},
                // ),
              ]),
            ),
          ),
        ));
  }

  Widget deliveryBoyDetail(Order order) {
    bool isTapButton = false;
    TextEditingController addNameController = TextEditingController();
    TextEditingController addPhoneController = TextEditingController();

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        // height: Get.height * 0.4,
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Delivery Detail',
                          style: poppinsMedium.copyWith(
                              color: Colors.black, fontSize: 18)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: () {
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
                SizedBox(height: 10),
                GetBuilder<SwiggyController>(builder: (swiggyController) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: MyTextField(
                          showBorder: true,
                          hintText: 'Person Name'.tr,
                          inputType: TextInputType.name,
                          controller: addNameController,
                          onChanged: (String v) {
                            swiggyController.update();
                          },
                          capitalization: TextCapitalization.words,
                        ),
                      ),
                      if (isTapButton && addNameController.text.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Name required'.tr,
                              style: poppinsRegular.copyWith(
                                  color: Colors.red, fontSize: 10),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorTheme.borderGrey),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(children: [
                            CountryCodePicker(
                              onChanged: (CountryCode _countryCode) {
                                // countryCode = _countryCode;
                              },
                              initialSelection: 'IN',
                              enabled: false,
                              showDropDownButton: true,
                              padding: EdgeInsets.zero,
                              showFlagMain: false,
                              flagWidth: 20,
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                              textStyle: poppinsMedium.copyWith(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 5),
                                height: 40,
                                child: TextField(
                                  onChanged: (String v) {
                                    swiggyController.update();
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  controller: addPhoneController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Allow only digits
                                  ],
                                  textAlignVertical: TextAlignVertical.center,
                                  style: poppinsMedium.copyWith(fontSize: 13),
                                  cursorColor: ColorTheme.appColor,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: 'Person Number',
                                    fillColor: Colors.white,
                                    hintStyle: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                    filled: true,
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ),
                      ),
                      if (isTapButton && addPhoneController.text.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Phone required'.tr,
                              style: poppinsRegular.copyWith(
                                  color: Colors.red, fontSize: 10),
                            ),
                          ),
                        ),
                      if (isTapButton &&
                          addPhoneController.text.isNotEmpty &&
                          (addPhoneController.text.length < 8 ||
                              addPhoneController.text.length > 12))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'enter_a_valid_phone_number'.tr,
                              style: poppinsRegular.copyWith(
                                  color: Colors.red, fontSize: 10),
                            ),
                          ),
                        ),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: swiggyController.isLoading
                            ? CircularProgressIndicator()
                            : InkWell(
                                onTap: () async {
                                  isTapButton = true;
                                  swiggyController.update();
                                  if (addNameController.text.isEmpty) {
                                  } else if (addPhoneController.text.isEmpty) {
                                  } else {
                                    if (addPhoneController.text.length < 8 ||
                                        addPhoneController.text.length > 12) {
                                    } else {
                                      Map<String, dynamic> jsonBody = {
                                        'order_id': order.orderDetailsOrder.id,
                                        "urban_order_id": order
                                            .orderDetailsOrder.urbanOrderId,

                                        'new_status': 'Dispatched',
                                        'message': 'Success',
                                        "extra": {
                                          "rider_name": addNameController.text,
                                          "rider_phone_number":
                                              addPhoneController.text,
                                          "prep_time_mins": 10
                                        }
                                        //  if(order.orderDetailsOrder.fOrderStatus)
                                      };
                                      Get.back();
                                      await swiggyController
                                          .changeOrderStatus(jsonBody);
                                    }
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.transparent),
                                      color: ColorTheme.appColor,
                                      // border:
                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Text(
                                      'submit'.tr,
                                      style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? 18
                                              : 14,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                }),
              ]),
            ),
          ),
        ));
  }
}

String getShortTimeDifference(String dateTime) {
  final jiffy = Jiffy.parse(dateTime);
  final duration = DateTime.now().difference(jiffy.dateTime);

  if (duration.inDays > 0) return "${duration.inDays} Days ago";
  if (duration.inHours > 0) return "${duration.inHours} hrs ago";
  if (duration.inMinutes > 0) return "${duration.inMinutes} min ago";
  if (duration.inSeconds > 0) return "${duration.inSeconds} few sec ago";
  return "Just Now";
}
