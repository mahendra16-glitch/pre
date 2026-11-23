import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../../controller/auth_controller.dart';
import '../../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../helper/colors.dart';
import '../../../helper/logo_helper.dart';
import '../../../util/app_constants.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../KDS/home/kds_home_screen.dart';

class DateWiseSwiggyOrders extends StatefulWidget {
  @override
  State<DateWiseSwiggyOrders> createState() => _DateWiseSwiggyOrdersState();
}

class _DateWiseSwiggyOrdersState extends State<DateWiseSwiggyOrders> {
  TextEditingController searchOrder = TextEditingController();
  Socket? socket;
  List<OrderIdType> orderIdQueue = [];
  List<Order> orderQueue = [];
  bool isProcessingOrderQueue = false;
  DateTime? selectedDate;
  final Set<int> expandedOrderIds = {};

  @override
  void initState() {
    super.initState();
    Get.find<SwiggyController>().getSwiggyOrderByDate('');
    connectToSocketIO();
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 35, color: ColorTheme.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Image.asset(
              logoHelper.appLogo!,
              width: GetPlatform.isWindows ? Get.width * 0.1 : Get.width * 0.3,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Download Report',
            onPressed: () async {
              Get.find<SwiggyController>().isLoadingExport
                  ? null
                  : await Get.find<SwiggyController>()
                      .exportAggregatorOrderReport(DateFormat('yyyy-MM-dd')
                          .format(selectedDate ?? DateTime.now()));
            },
            icon:
                Icon(Icons.file_download_outlined, color: ColorTheme.appColor),
          ),
        ],
        elevation: 0,
      ),
      body: GetBuilder<SwiggyController>(
        builder: (swiggyController) {
          if (swiggyController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.shortestSide > 570
                            ? 50
                            : 36,
                        child: TextField(
                          controller: searchOrder,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            suffixIcon:
                                Icon(Icons.search, color: ColorTheme.appColor),
                            hintText: 'Search here..',
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
                            hintStyle: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13,
                                color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 13,
                          ),
                          onChanged: (value) async {
                            swiggyController.update();
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        searchOrder.clear();
                        _selectDate(context);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.shortestSide > 570
                            ? 50
                            : 36,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.white,
                            border: Border.all(color: ColorTheme.borderGrey)),
                        child: Center(
                          child: Text(
                            selectedDate == null
                                ? 'Filter by date'
                                : DateFormat('yyyy-MM-dd')
                                    .format(selectedDate!),
                            style: poppinsMedium.copyWith(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        swiggyController.getSwiggyOrderByDate('');
                      },
                      child: Icon(Icons.refresh_outlined,
                          color: ColorTheme.appColor, size: 35),
                    )
                  ],
                ),
                SizedBox(height: 10),
                swiggyController.completedOrderByDate.isEmpty
                    ? Center(child: Text('No orders found... Sorry!'))
                    : Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: StaggeredGrid.count(
                            crossAxisCount: 1,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: swiggyController.completedOrderByDate
                                .where((order) {
                              // Filter with dine in
                              if (
                                // (order.orderDetailsOrder.fOrderStatus == 3 || order.orderDetailsOrder.fOrderStatus == 5 ||
                                //           order.orderDetailsOrder
                                //                   .fOrderStatus ==
                                //               6) &&
                                      (searchOrder.text.isEmpty
                                          ? true
                                          : order.orderDetailsOrder.urbanOrderId
                                              .toString()
                                              .toLowerCase()
                                              .contains(searchOrder.text
                                                  .toLowerCase()))
                                  //  ||
                                  // order.orderDetailsOrder.fOrderStatus == 5
                                  ) {
                                return true;
                              }

                              return false;
                            }).map((order) {
                              final orderId = order.orderDetailsOrder.id;
                              final isExpanded =
                                  expandedOrderIds.contains(orderId);
                              return _buildOrderCard(
                                context: context,
                                order: order,
                                isExpanded: isExpanded,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                onToggleExpand: () {
                                  setState(() {
                                    if (isExpanded) {
                                      expandedOrderIds.remove(orderId);
                                    } else {
                                      expandedOrderIds.add(orderId);
                                    }
                                  });
                                },
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023, 6),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;

      await Get.find<SwiggyController>()
          .getSwiggyOrderByDate(DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required Order order,
    required bool isExpanded,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onToggleExpand,
  }) {
    final details = order.orderDetailsOrder;
    final foods = order.orderDetailsFood;
    final currency =
        Get.find<AuthController>().profileModel?.restaurants?.first.currency ??
            '';
    final isCancelled = details.fOrderStatus == 3;
    final isDispatched = details.fOrderStatus == 5;
    final statusLabel = isCancelled
        ? 'Cancelled'
        : isDispatched
            ? 'Dispatched'
            : 'Completed';
    final statusColor = isCancelled
        ? Colors.red
        : isDispatched
            ? ColorTheme.orangeFF7E27
            : ColorTheme.green;
    final showOtp = isDispatched && details.otp.trim().isNotEmpty;
    final canShowPrice = Get.find<AuthController>()
            .profileModel!
            .role!
            .contains('swiggy_zomato_price');

    // Use API keys: item_total, coupon_discount_amount, packing_charge, total_gst_tax_amount
    final itemTotal = details.itemTotal;
    final discount = details.couponDiscount ?? 0;
    final couponCode =
        details.couponCode?.isNotEmpty ?? false ? details.couponCode : '';
    final packingCharge = details.packingCharge ?? 0;
    final gst = details.gstTax ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        color: const Color.fromRGBO(254, 245, 208, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () =>
                          _showCustomerDetails(context, order.customerDetails),
                      child: Text(
                        details.userName.isNotEmpty
                            ? details.userName
                            : 'Unknown',
                        style: poppinsMedium.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (order.brandName != null &&
                          order.brandName!.isNotEmpty)
                        Text(
                          order.brandName!,
                          textAlign: TextAlign.center,
                          style: montserratMedium.copyWith(
                            fontSize: 14,
                            color: ColorTheme.greenColor,
                          ),
                        ),
                      if (order.brandName != null &&
                          order.brandName!.isNotEmpty)
                        const SizedBox(height: 2),
                      Text(
                        details.aggregatorOrderId,
                        textAlign: TextAlign.center,
                        style: poppinsMedium.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      details.orderPlateform == 'zomato'
                          ? Images.zomato
                          : Images.swiggy,
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Divider(color: Color(0xFF8C8C8C), height: 1),
          ),
          if (!isExpanded || !canShowPrice) ...[
            if (foods.isNotEmpty)
              InkWell(
                onTap: canShowPrice ? onToggleExpand : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(foods.length, (index) {
                            final food = foods[index];
                            return Padding(
                              padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
                              child: Text(
                                '${index + 1}. ${food.title} (${food.quantity})',
                                style: poppinsMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (canShowPrice)
                        const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF848484)),
                    ],
                  ),
                ),
              ),
          ] else ...[
            InkWell(
              onTap: onToggleExpand,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hide Bill Details',
                        style: poppinsMedium.copyWith(
                          color: Color(0xFF848484),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_up,
                        color: Color(0xFF848484)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: DottedLine(
                direction: Axis.horizontal,
                lineThickness: 1.0,
                dashLength: 2.5,
                dashColor: Color(0xFF8C8C8C),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15),
            //   child: Text(
            //     'Food Items',
            //     style: poppinsMedium.copyWith(
            //       fontSize: 14,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 6),
            ...foods.map((food) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.title,
                          style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          'x${food.quantity}',
                          textAlign: TextAlign.center,
                          style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF848484),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          food.price.toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            if (details.orderNote.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: DottedLine(
                  direction: Axis.horizontal,
                  lineThickness: 1.0,
                  dashLength: 2.5,
                  dashColor: Color(0xFF8C8C8C),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                // child: Center(
                  child: Text(
                    details.orderNote,
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: const Color.fromARGB(255, 33, 33, 33),
                      fontSize: 11,
                    ),
                  ),
                // ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: DottedLine(
                direction: Axis.horizontal,
                lineThickness: 1.0,
                dashLength: 2.5,
                dashColor: Color(0xFF8C8C8C),
              ),
            ),
            _buildBillRow('Item Total', itemTotal.toStringAsFixed(2)),
            if (couponCode?.isNotEmpty ?? false)
              _buildBillRow('Coupon Code', couponCode ?? ''),
            if (discount > 0)
              _buildBillRow('Discount', '-${discount.toStringAsFixed(2)}'),
            if (packingCharge > 0)
              _buildBillRow('Packing Charge', packingCharge.toStringAsFixed(2)),
            if (gst > 0) _buildBillRow('GST', gst.toStringAsFixed(2)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: DottedLine(
                direction: Axis.horizontal,
                lineThickness: 1.0,
                dashLength: 2.5,
                dashColor: Color(0xFF8C8C8C),
              ),
            ),
            _buildBillRow(
              'Total',
              currency.isNotEmpty
                  ? '${details.orderAmount.toStringAsFixed(2)}'
                  : details.orderAmount.toStringAsFixed(2),
              isTotal: true,
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: (isCancelled || showOtp)
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (isCancelled)
                  Flexible(
                    child: Text(
                      'Reason : ${details.cancelReason ?? ''}',
                      style: poppinsMedium.copyWith(fontSize: 12),
                    ),
                  ),
                if (showOtp)
                  Text(
                    'OTP : ${details.otp}',
                    style: poppinsMedium.copyWith(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: statusColor,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      statusLabel,
                      style: poppinsMedium.copyWith(
                        fontSize: 13,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: poppinsMedium.copyWith(
              fontSize: isTotal ? 14 : 13,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: poppinsMedium.copyWith(
              fontSize: isTotal ? 14 : 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
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
}
