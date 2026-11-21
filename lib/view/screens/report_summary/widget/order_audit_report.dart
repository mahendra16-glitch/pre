import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';

class OrderAuditReportScreen extends StatefulWidget {
  const OrderAuditReportScreen({Key? key}) : super(key: key);

  @override
  State<OrderAuditReportScreen> createState() => _OrderAuditReportScreenState();
}

class _OrderAuditReportScreenState extends State<OrderAuditReportScreen> {
  ReportSummeryController? reportController;
  String? selectedPaymentStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    reportController = Get.find<ReportSummeryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchOrderAuditReport();
    });
  }

  /// Initialize default date range (current date)
  void _initializeDatesAndData() {
    reportController?.orderAuditReportList.clear();
    reportController?.filteredOrderAuditReportList.clear();
    reportController?.orderAuditSearchController.clear();
    selectedPaymentStatusFilter = 'All';
    reportController?.update();
    final now = DateTime.now();
    reportController?.orderAuditStartDate =
        DateFormat('dd-MM-yyyy').format(now);
    reportController?.orderAuditEndDate = DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch order audit report data
  void _fetchOrderAuditReport() async {
    if (reportController?.orderAuditStartDate != null &&
        reportController?.orderAuditEndDate != null) {
      await reportController?.getOrderAuditReport(
        startDate: reportController!.orderAuditStartDate!,
        endDate: reportController!.orderAuditEndDate!,
      );
    }
  }

  /// Download order audit report as Excel
  void _downloadOrderAuditReport() async {
    if (reportController?.orderAuditStartDate != null &&
        reportController?.orderAuditEndDate != null) {
      await reportController?.downloadOrderAuditReport(
        startDate: reportController!.orderAuditStartDate!,
        endDate: reportController!.orderAuditEndDate!,
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
            'Order Audit Report',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Order Audit Report',
          actions: [
            IconButton(
              tooltip: 'Download Excel',
              onPressed: _downloadOrderAuditReport,
              icon: Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 30,
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchOrderAuditReport,
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
              _buildTableHeaders(),

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
                  reportController?.orderAuditStartDate,
                );
                if (picked != null) {
                  reportController?.orderAuditStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderAuditReport();
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
                      reportController?.orderAuditStartDate ?? 'DD-MM-YYYY',
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
                  reportController?.orderAuditEndDate,
                );
                if (picked != null) {
                  reportController?.orderAuditEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderAuditReport();
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
                      reportController?.orderAuditEndDate ?? 'DD-MM-YYYY',
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

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 45,
      color: ColorTheme.whiteColor,
      child: Row(
        children: [
          // Order ID Column
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
          // Order Time Column
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
                'Order Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Collect Bill Column
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
                'Collect Bill',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Payment Status Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text(
                'Payment',
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
    if (reportController?.isLoadingOrderAuditReport.value ?? false) {
      return AppLoader();
    }

    final search = reportController?.orderAuditSearchController.text
            .trim()
            .toLowerCase() ??
        '';

    final orderAuditRecords =
        (reportController?.filteredOrderAuditReportList ?? []).where((item) {
      // Search Filter
      final orderId =
          item['restaurant_order_id']?.toString().toLowerCase() ?? '';
      final paymentStatus =
          item['payment_status']?.toString().toLowerCase() ?? '';
      final paymentMethod =
          item['payment_method']?.toString().toLowerCase() ?? '';

      return orderId.contains(search) ||
          paymentStatus.contains(search) ||
          paymentMethod.contains(search);
    }).toList();

    if (orderAuditRecords.isEmpty) {
      return Center(
        child: Text(
          'No order audit records found',
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
        itemCount: orderAuditRecords.length,
        itemBuilder: (context, index) {
          final record = orderAuditRecords[index];
          return _buildTableRow(record);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> record) {
    final paymentStatus = record['payment_status']?.toString() ?? '';
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order ID Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${record['restaurant_order_id']?.toString() ?? ''}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  4.height,
                  Text(
                    '₹${record['order_amount']?.toString() ?? '0'}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: ColorTheme.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Order Time Column (created_at)
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(record['created_at']?.toString()),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  4.height,
                  Text(
                    _formatTime(record['created_at']?.toString()),
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
          ),
          // Collect Bill Column (collect_bill)
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: record['collect_bill'] != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(record['collect_bill']?.toString()),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: ColorTheme.foodValue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.height,
                        Text(
                          _formatTime(record['collect_bill']?.toString()),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: ColorTheme.black5F6368,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '-',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
          // Payment Status Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paymentStatus.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: isPaid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 4.height,
                  // Text(
                  //   _formatPaymentMethod(
                  //       record['payment_method']?.toString() ?? ''),
                  //   style: TextStyle(
                  //     fontFamily: 'Montserrat',
                  //     fontSize: 10,
                  //     color: ColorTheme.black5F6368,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date from API format to dd-MM-yyyy
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      // Parse API date format: "2025-10-25 21:56:27"
      final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      try {
        // Try alternative format
        final dateTime = DateTime.parse(dateString);
        return DateFormat('dd-MM-yyyy').format(dateTime);
      } catch (e) {
        return dateString;
      }
    }
  }

  /// Format time from API format to HH:mm:ss (24-hour format)
  String _formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      // Parse API date format: "2025-10-25 21:56:27"
      final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
      return DateFormat('HH:mm:ss').format(dateTime);
    } catch (e) {
      try {
        // Try alternative format
        final dateTime = DateTime.parse(dateString);
        return DateFormat('HH:mm:ss').format(dateTime);
      } catch (e) {
        return '';
      }
    }
  }

  /// Format payment method for display
  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return 'COD';
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      default:
        return method.replaceAll('_', ' ').capitalize ?? method;
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: TextField(
              controller: reportController?.orderAuditSearchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search by order ID...",
                hintStyle: montserratMedium.copyWith(
                    fontSize: 15, color: ColorTheme.grey8C),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorTheme.grey8C.withOpacity(0.3),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
              ),
              style: montserratMedium.copyWith(
                  fontSize: 15, color: ColorTheme.black),
              onChanged: (value) {
                _applyFilters();
              },
            ),
          ),
          SizedBox(width: 10),
          // PAYMENT STATUS FILTER
          PopupMenuButton<String>(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            menuPadding: EdgeInsets.all(10),
            tooltip: 'Payment Status Filter',
            position: PopupMenuPosition.under,
            icon: Icon(Icons.filter_list, size: 28, color: ColorTheme.blue),
            onSelected: (value) {
              setState(() {
                selectedPaymentStatusFilter = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "All",
                child: Text(
                  "All",
                  style: montserratMedium.copyWith(
                      fontSize: 15,
                      color: selectedPaymentStatusFilter == 'All'
                          ? ColorTheme.blue
                          : ColorTheme.grey8C),
                ),
              ),
              PopupMenuItem(
                value: "paid",
                child: Text(
                  "Paid",
                  style: montserratMedium.copyWith(
                      fontSize: 15,
                      color: selectedPaymentStatusFilter == 'paid'
                          ? ColorTheme.blue
                          : ColorTheme.grey8C),
                ),
              ),
              PopupMenuItem(
                value: "unpaid",
                child: Text(
                  "Unpaid",
                  style: montserratMedium.copyWith(
                      fontSize: 15,
                      color: selectedPaymentStatusFilter == 'unpaid'
                          ? ColorTheme.blue
                          : ColorTheme.grey8C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Apply search and payment status filters
  void _applyFilters() {
    final searchQuery = reportController?.orderAuditSearchController.text
            .trim()
            .toLowerCase() ??
        '';

    List<Map<String, dynamic>> filtered =
        reportController?.orderAuditReportList.value ?? [];

    // Apply payment status filter
    if (selectedPaymentStatusFilter != null &&
        selectedPaymentStatusFilter != 'All') {
      filtered = filtered.where((item) {
        final paymentStatus =
            item['payment_status']?.toString().toLowerCase() ?? '';
        return paymentStatus == selectedPaymentStatusFilter!.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final orderId =
            item['restaurant_order_id']?.toString().toLowerCase() ?? '';
        final paymentStatus =
            item['payment_status']?.toString().toLowerCase() ?? '';
        final paymentMethod =
            item['payment_method']?.toString().toLowerCase() ?? '';

        return orderId.contains(searchQuery) ||
            paymentStatus.contains(searchQuery) ||
            paymentMethod.contains(searchQuery);
      }).toList();
    }

    reportController?.filteredOrderAuditReportList.value = filtered;
    reportController?.update();
    reportController?.filteredOrderAuditReportList.refresh();
  }
}
