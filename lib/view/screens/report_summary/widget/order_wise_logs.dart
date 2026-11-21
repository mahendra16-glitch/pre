import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';

class OrderWiseLogsScreen extends StatefulWidget {
  const OrderWiseLogsScreen({Key? key}) : super(key: key);

  @override
  State<OrderWiseLogsScreen> createState() => _OrderWiseLogsScreenState();
}

class _OrderWiseLogsScreenState extends State<OrderWiseLogsScreen> {
  ReportSummeryController? reportController;

  @override
  void initState() {
    super.initState();
    reportController = Get.find<ReportSummeryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchOrderLogs();
    });
  }

  /// Initialize default date range (current date)
  void _initializeDatesAndData() {
    reportController?.orderLogsList.clear();
    reportController?.groupedOrderLogs.clear();
    reportController?.expandedOrderIds.clear();
    reportController?.orderLogsSearchController.clear();
    reportController?.update();
    final now = DateTime.now();
    reportController?.orderLogsStartDate = DateFormat('dd-MM-yyyy').format(now);
    reportController?.orderLogsEndDate = DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch order logs data
  void _fetchOrderLogs() async {
    if (reportController?.orderLogsStartDate != null &&
        reportController?.orderLogsEndDate != null) {
      await reportController?.getOrderLogsReport(
        startDate: reportController!.orderLogsStartDate!,
        endDate: reportController!.orderLogsEndDate!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleWidget: Text(
            'Order Wise Logs',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Order Wise Logs',
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchOrderLogs,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
          ],
        ),
        body: GetBuilder<ReportSummeryController>(
          builder: (controller) => Column(
            children: [
              SizedBox(height: 10),
              // Date Filter Section
              _buildDateFilterSection(),
              _buildSearchBar(),
              // Table Headers
              // _buildTableHeaders(),
              // Table Data
              Expanded(
                child: _buildTableData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build date filter section with start and end date pickers
  Widget _buildDateFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  reportController?.orderLogsStartDate,
                );
                if (picked != null) {
                  reportController?.orderLogsStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderLogs();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reportController?.orderLogsStartDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
                    ),
                  ],
                ),
              ),
            ),
          ),
          10.width,
          Text(
            'to',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: ColorTheme.black5F6368,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.width,
          // End Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  reportController?.orderLogsEndDate,
                );
                if (picked != null) {
                  reportController?.orderLogsEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderLogs();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reportController?.orderLogsEndDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        controller: reportController?.orderLogsSearchController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Search by order ID, operation, name...",
          hintStyle:
              montserratMedium.copyWith(fontSize: 15, color: ColorTheme.grey8C),
          prefixIcon: Icon(
            Icons.search,
            color: ColorTheme.grey8C.withOpacity(0.3),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
        ),
        style: montserratMedium.copyWith(fontSize: 15, color: ColorTheme.black),
        onChanged: (value) {
          reportController?.filterOrderLogs(value);
        },
      ),
    );
  }

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 45,
      color: ColorTheme.whiteColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Order ID',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                'Operation',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Performed By',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Date & Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table data rows
  Widget _buildTableData() {
    if (reportController?.isLoadingOrderLogsReport.value ?? false) {
      return AppLoader();
    }

    final groupedLogs = reportController?.groupedOrderLogs ?? {};

    if (groupedLogs.isEmpty) {
      return Center(
        child: Text(
          'No order logs found',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ColorTheme.black5F6368.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      color: ColorTheme.whiteColor,
      child: ListView.builder(
        itemCount: groupedLogs.length,
        itemBuilder: (context, index) {
          final orderId = groupedLogs.keys.elementAt(index);
          final logs = groupedLogs[orderId] ?? [];
          final isExpanded =
              reportController?.isOrderExpanded(orderId) ?? false;
          final firstLog = logs.isNotEmpty ? logs.first : null;
          final sourceOrder = firstLog?['source_order'] ?? {};

          return _buildOrderGroup(orderId, logs, isExpanded, sourceOrder);
        },
      ),
    );
  }

  /// Build order group with expandable details
  Widget _buildOrderGroup(String orderId, List<Map<String, dynamic>> logs,
      bool isExpanded, Map<String, dynamic> sourceOrder) {
    final firstLog = logs.isNotEmpty ? logs.first : null;
    final logInfo = firstLog?['log_info'] ?? {};
    final performedBy = firstLog?['performed_by'] ?? {};
    final operation = logInfo['operation']?.toString() ?? '';
    // sourceOrder is used in _buildOrderSummary

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Column(
        children: [
          // Main row (always visible)
          InkWell(
            onTap: () {
              reportController?.toggleOrderExpansion(orderId);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              child: Row(
                children: [
                  // Order ID Column
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: ColorTheme.blue,
                          size: 20,
                        ),
                        8.width,
                        Text(
                          orderId,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.foodValue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (logs.length > 1) ...[
                          8.width,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorTheme.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${logs.length}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                color: ColorTheme.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Operation Column
                  // Expanded(
                  //   flex: 2,
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //       border: Border.symmetric(
                  //         vertical: BorderSide(color: ColorTheme.whiteE7),
                  //       ),
                  //     ),
                  //     child: _buildOperationChip(operation),
                  //   ),
                  // ),
                  // // Performed By Column
                  // Expanded(
                  //   flex: 2,
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       performedBy['name']?.toString() ?? 'N/A',
                  //       style: TextStyle(
                  //         fontFamily: 'Montserrat',
                  //         fontSize: 12,
                  //         color: ColorTheme.black5F6368,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),
                  // // Date & Time Column
                  // Expanded(
                  //   flex: 2,
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       _formatDateTime(logInfo['created_at']?.toString()),
                  //       style: TextStyle(
                  //         fontFamily: 'Montserrat',
                  //         fontSize: 11,
                  //         color: ColorTheme.black5F6368,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),
               
                ],
              ),
            ),
          ),
          // Expanded details
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(15),
              color: ColorTheme.grey200Color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(sourceOrder),
                  15.height,
                  // Logs Timeline
                  Text(
                    'Activity Timeline:',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: ColorTheme.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.height,
                  ...logs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final log = entry.value;
                    return _buildLogDetail(log, index, logs.length);
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build operation chip with color coding
  Widget _buildOperationChip(String operation) {
    Color chipColor;
    String displayText = operation.replaceAll('_', ' ').toUpperCase();

    switch (operation.toLowerCase()) {
      case 'new_order_placed':
        chipColor = Colors.green;
        break;
      case 'waiter_record_add':
        chipColor = Colors.blue;
        break;
      case 'place_order_and_payment':
        chipColor = Colors.orange;
        break;
      case 'order_status_update':
        chipColor = Colors.purple;
        break;
      case 'payment_update':
        chipColor = Colors.teal;
        break;
      default:
        chipColor = ColorTheme.grey8C;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build order summary card
  Widget _buildOrderSummary(Map<String, dynamic> sourceOrder) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorTheme.grey8C.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: ColorTheme.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          10.height,
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Amount',
                  '₹${sourceOrder['order_amount']?.toString() ?? '0'}',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Status',
                  sourceOrder['order_status']?.toString().toUpperCase() ??
                      'N/A',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Payment',
                  sourceOrder['payment_status']?.toString().toUpperCase() ??
                      'N/A',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Method',
                  sourceOrder['payment_method']?.toString().toUpperCase() ??
                      'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: ColorTheme.black5F6368.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        4.height,
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: ColorTheme.foodValue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build individual log detail
  Widget _buildLogDetail(Map<String, dynamic> log, int index, int totalLogs) {
    final logInfo = log['log_info'] ?? {};
    final performedBy = log['performed_by'] ?? {};
    final sourceOrder = log['source_order'] ?? {};
    final orderItemsTiming = log['order_items_timing'] as List? ?? [];
    final operation = logInfo['operation']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorTheme.grey8C.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Log header
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: ColorTheme.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${totalLogs - index}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorTheme.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOperationChip(operation),
                    4.height,
                    Text(
                      _formatDateTime(logInfo['created_at']?.toString()),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.height,
          Divider(color: ColorTheme.grey8C.withOpacity(0.3)),
          12.height,
          // Performed By
          _buildDetailRow(
              'Performed By', performedBy['name']?.toString() ?? 'N/A'),
          8.height,
          _buildDetailRow('Email', performedBy['email']?.toString() ?? 'N/A'),
          8.height,
          _buildDetailRow('Phone', performedBy['phone']?.toString() ?? 'N/A'),
          12.height,
          // Order Items Timing
          if (orderItemsTiming.isNotEmpty) ...[
            Text(
              'Order Items:',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: ColorTheme.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
            8.height,
            ...orderItemsTiming
                .map((item) => _buildOrderItemCard(item))
                .toList(),
            12.height,
          ],
          // Payload (if exists)
          if (log['payload'] != null) ...[
            _buildJsonSection('Payload', log['payload']),
            12.height,
          ],
          // Old Values (if exists)
          if (log['old_values'] != null) ...[
            _buildJsonSection('Old Values', log['old_values']),
            12.height,
          ],
          // New Values (if exists)
          if (log['new_values'] != null) ...[
            _buildJsonSection('New Values', log['new_values']),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: ColorTheme.black5F6368.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: ColorTheme.black5F6368,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorTheme.grey200Color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorTheme.grey8C.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['food_name']?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: ColorTheme.foodValue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Qty: ${item['quantity']?.toString() ?? '0'}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: ColorTheme.black5F6368,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          6.height,
          Row(
            children: [
              _buildStatusChip(item['food_status']),
              8.width,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['station']?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: ColorTheme.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          6.height,
          if (item['ordered_at'] != null)
            _buildTimingRow('Ordered', item['ordered_at']),
          if (item['ready_at'] != null)
            _buildTimingRow('Ready', item['ready_at']),
          if (item['served_at'] != null)
            _buildTimingRow('Served', item['served_at']),
          if (item['cancelled_at'] != null)
            _buildTimingRow('Cancelled', item['cancelled_at']),
          if (item['total_time_minutes'] != null)
            _buildTimingRow('Total Time', '${item['total_time_minutes']} min'),
        ],
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    int statusCode =
        status is int ? status : int.tryParse(status?.toString() ?? '0') ?? 0;
    String statusText;
    Color statusColor;

    switch (statusCode) {
      case 1:
        statusText = 'Pending';
        statusColor = Colors.orange;
        break;
      case 2:
        statusText = 'Preparing';
        statusColor = Colors.blue;
        break;
      case 3:
        statusText = 'Ready';
        statusColor = Colors.green;
        break;
      case 4:
        statusText = 'Served';
        statusColor = Colors.teal;
        break;
      case 5:
        statusText = 'Delivered';
        statusColor = Colors.purple;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimingRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                color: ColorTheme.black5F6368.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatDateTime(value?.toString()),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                color: ColorTheme.black5F6368,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonSection(String title, dynamic jsonData) {
    String jsonString = '';
    try {
      if (jsonData is String) {
        jsonString = jsonData;
      } else {
        jsonString = jsonEncode(jsonData);
      }
      // Try to format it
      final decoded = jsonDecode(jsonString);
      jsonString = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      jsonString = jsonData?.toString() ?? '';
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorTheme.grey200Color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorTheme.grey8C.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: ColorTheme.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.height,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorTheme.whiteColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                jsonString,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: ColorTheme.black5F6368,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date from API format to dd-MM-yyyy HH:mm
  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      // Parse API date format: "2025-12-29T10:58:28.000000Z" or "2025-12-29 16:27:31"
      DateTime dateTime;
      if (dateString.contains('T')) {
        dateTime = DateTime.parse(dateString);
      } else {
        dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
      }
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      try {
        final dateTime = DateTime.parse(dateString);
        return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
      } catch (e) {
        return dateString;
      }
    }
  }
}
