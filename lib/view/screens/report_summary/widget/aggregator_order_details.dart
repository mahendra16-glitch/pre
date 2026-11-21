import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_swiggy_order_list_response.dart';
import 'package:mygenie_restaurant/util/images.dart';

class AggregatorOrderDetails extends StatefulWidget {
  final dynamic orderId;
  final ReportSummeryController? controller;

  AggregatorOrderDetails({required this.orderId, this.controller});

  @override
  State<AggregatorOrderDetails> createState() => _AggregatorOrderDetailsState();
}

class _AggregatorOrderDetailsState extends State<AggregatorOrderDetails> {
  late final ReportSummeryController reportSummeryController;
  bool _showCustomer = false;

  @override
  void initState() {
    super.initState();
    reportSummeryController =
        widget.controller ?? Get.find<ReportSummeryController>();
    reportSummeryController.fetchAggregatorOrderDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: ColorTheme.appColor,
          ),
        ),
        titleSpacing: 0,
        title: Obx(() {
          final orders = reportSummeryController.aggregatorOrderDetails['orders'];
          final details = orders?['order_details_order'];
          return Row(
            children: [
              Text(
                "#${details?['restaurant_order_id'] ?? details?['aggrigator_id'] ?? ''}",
                style: poppinsSemiBold.copyWith(
                    color: ColorTheme.green, fontSize: 18),
              ),
              SizedBox(width: 10),
              Text(
                _formatDateTime(details?['created_at']),
                style: poppinsMedium.copyWith(
                    color: Color(0xFF8C8C8C), fontSize: 9),
              ),
            ],
          );
        }),
        elevation: 0,
      ),
      body: Obx(() {
        if (reportSummeryController.isLoadingAggregatorOrderDetails.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawOrders = reportSummeryController.aggregatorOrderDetails['orders'];
        if (rawOrders == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Failed to load order details"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    reportSummeryController
                        .fetchAggregatorOrderDetails(widget.orderId);
                  },
                  child: const Text("Retry"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          );
        }

        final order = Order.fromJson(Map<String, dynamic>.from(rawOrders));
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(0),
          child: _buildBill(context, order),
        );
      }),
    );
  }

  Widget _buildBill(BuildContext context, Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final details = order.orderDetailsOrder;
    final foods = order.orderDetailsFood;
    final isCancelled = details.fOrderStatus == 3;

    // Use API keys: item_total, coupon_discount_amount, packing_charge, total_gst_tax_amount
    final itemTotal = details.itemTotal;
    final discount = details.couponDiscount ?? 0;
    final couponCode =
        details.couponCode?.isNotEmpty ?? false ? details.couponCode : '';
    final packingCharge = details.packingCharge ?? 0;
    final gst = details.gstTax ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
         border: Border( top: BorderSide(color: Color(0xFFE4E4E4)))
        // color: const Color.fromRGBO(254, 245, 208, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 40, 15, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      details.orderPlateform == 'zomato'
                          ? Images.zomato
                          : Images.swiggy,
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.05,
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
                    child: InkWell(
                      onTap: () =>
                          setState(() => _showCustomer = !_showCustomer),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
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
                              Icon(
                                _showCustomer
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: const Color(0xFF848484),
                              ),
                            ],
                          ),
                          if (order.customerDetails.phone.isNotEmpty)
                            Text(
                              order.customerDetails.phone,
                              style: poppinsMedium.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF848484),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Divider(color: Color(0xFF828282), height: 0.5),
          ),
          // Inline customer details shown just below the header line
          if (_showCustomer)
            _buildInlineCustomerDetails(order.customerDetails),
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
          // if (details.orderNote.isNotEmpty) ...[
          //   const Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          //     child: DottedLine(
          //       direction: Axis.horizontal,
          //       lineThickness: 1.0,
          //       dashLength: 2.5,
          //       dashColor: Color(0xFF828282),
          //     ),
          //   ),
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          //     child: Center(
          //       child: Text(
          //         details.orderNote,
          //         textAlign: TextAlign.center,
          //         style: poppinsMedium.copyWith(
          //           color: const Color.fromARGB(255, 33, 33, 33),
          //           fontSize: 11,
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: DottedLine(
              direction: Axis.horizontal,
              lineThickness: 1.0,
              dashLength: 2.5,
              dashColor: Color(0xFF828282),
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
              dashColor: Color(0xFF828282),
            ),
          ),
          _buildBillRow(
            'Total',
            details.orderAmount.toStringAsFixed(2),
            isTotal: true,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: isCancelled
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCancelled ? Colors.red : ColorTheme.blue,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      isCancelled ? 'Cancelled' : 'Completed',
                      style: poppinsMedium.copyWith(
                        fontSize: 13,
                        color: isCancelled ? Colors.red : ColorTheme.blue,
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
              color: Color(0xFF828282),
            ),
          ),
          Text(
            value,
            style: poppinsMedium.copyWith(
              fontSize: isTotal ? 14 : 13,
              color: Color(0xFF828282),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineCustomerDetails(CustomerDetails customerDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Text(
            "Customer Details",
            style: poppinsMedium.copyWith(
              color: ColorTheme.blue,
              fontSize: 14,
            ),
          ),
        ),
        _buildDetailRow(label: "Name", value: customerDetails.name),
        _buildDetailRow(label: "Phone", value: customerDetails.phone),
        _buildDetailRow(label: "Address", value: customerDetails.address.line1),
        _buildDetailRow(label: "City", value: customerDetails.address.city),
        _buildDetailRow(
            label: "Sub-Locality", value: customerDetails.address.subLocality),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: DottedLine(
            direction: Axis.horizontal,
            lineThickness: 1.0,
            dashLength: 2.5,
            dashColor: Color(0xFF8C8C8C),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Text(
            "$label :",
            style: poppinsMedium.copyWith(
              color: Color(0xFF2E2E2E),
              fontSize: 13,
            ),
          ),
          Text(
            " ${value.isEmpty ? 'No $label' : value}",
            style: poppinsMedium.copyWith(
              color: value.isEmpty ? Colors.red.shade400 : Color(0xFF8C8C8C),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy | HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }
}
