import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';

class CouponReport extends StatefulWidget {
  const CouponReport({super.key});

  @override
  State<CouponReport> createState() => _CouponReportState();
}

class _CouponReportState extends State<CouponReport> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  bool _showSummary = false;
  String _searchQuery = '';

  late LoyaltyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoyaltyController>();
    controller.couponReportOrders.clear();
    controller.couponBreakdown.clear();
    controller.couponReportSummary.clear();
    _fromController.text = DateFormat('yyyy-MM-dd').format(_fromDate);
    _toController.text = DateFormat('yyyy-MM-dd').format(_toDate);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _couponCodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final first = DateTime(2022);
    final last = DateTime.now().add(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          _fromController.text = DateFormat('yyyy-MM-dd').format(_fromDate);
        } else {
          _toDate = picked;
          _toController.text = DateFormat('yyyy-MM-dd').format(_toDate);
        }
      });
    }
  }

  Future<void> _fetchReport() async {
    if (_couponCodeController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a coupon code',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return;
    }
    await controller.getCouponUsageReport(
      _fromController.text.trim(),
      _toController.text.trim(),
      _couponCodeController.text.trim(),
    );
  }

  Widget _buildSummaryText() {
    return Obx(() {
      if (controller.couponReportSummary.isEmpty || !_showSummary) {
        return const SizedBox.shrink();
      }

      final summary = controller.couponReportSummary;
      final breakdown = controller.couponBreakdown;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFE4E4E4)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: poppinsSemiBold.copyWith(
                color: const Color(0xFF2E2E2E),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            _summaryRow('Total Orders with Coupon',
                summary['total_orders_with_coupon']?.toString() ?? '0'),
            _summaryRow('Total Coupons Used',
                summary['total_coupons_used']?.toString() ?? '0'),
            _summaryRow('Total Discount Given',
                summary['total_discount_given']?.toString() ?? '0'),
            _summaryRow('Total Order Value',
                summary['total_order_value']?.toString() ?? '0'),
            if (breakdown.isNotEmpty) ...[
              const Divider(color: Color(0xFFE6E6E6)),
              const Divider(
                color: Color(0xFFE6E6E6),
              ),

              // const SizedBox(height: 8),
              Text(
                'Coupon Breakdown',
                style: poppinsSemiBold.copyWith(
                  color: const Color(0xFF2E2E2E),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              ...breakdown.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryRow('Coupon Code',
                            item['coupon_code']?.toString() ?? '-'),
                        _summaryRow('Total Uses',
                            item['total_uses']?.toString() ?? '0'),
                        _summaryRow('Total Discount Given',
                            item['total_discount_given']?.toString() ?? '0'),
                        _summaryRow('Avg Discount per Use',
                            item['avg_discount_per_use']?.toString() ?? '0'),
                        _summaryRow('Unique Customers',
                            item['unique_customers']?.toString() ?? '0'),
                        if (breakdown.indexOf(item) < breakdown.length - 1)
                          const Divider(color: Color(0xFFE6E6E6)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: poppinsMedium.copyWith(
              color: const Color(0xFF828282),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: poppinsMedium.copyWith(
              color: const Color(0xFF828282),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredOrders() {
    if (_searchQuery.trim().isEmpty) {
      return controller.couponReportOrders;
    }
    final query = _searchQuery.toLowerCase().trim();
    return controller.couponReportOrders.where((order) {
      final orderNumber =
          (order['order_number'] ?? '').toString().toLowerCase();
      final customerName =
          (order['customer_name'] ?? '').toString().toLowerCase();
      final couponCode = (order['coupon_code'] ?? '').toString().toLowerCase();
      final orderType = (order['order_type'] ?? '').toString().toLowerCase();
      final paymentMethod =
          (order['payment_method'] ?? '').toString().toLowerCase();
      final finalOrderAmount =
          (order['final_order_amount'] ?? '').toString().toLowerCase();

      return orderNumber.contains(query) ||
          customerName.contains(query) ||
          couponCode.contains(query) ||
          orderType.contains(query) ||
          paymentMethod.contains(query) ||
          finalOrderAmount.contains(query);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE4E4E4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search by order number, customer, coupon code...',
                hintStyle: poppinsMedium.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF828282),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF828282),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 20,
                          color: Color(0xFF828282),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorTheme.appColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              style: poppinsMedium.copyWith(
                color: const Color(0xFF2E2E2E),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: _showSummary ? 'Hide summary' : 'Show summary',
            onPressed: () {
              setState(() {
                _showSummary = !_showSummary;
              });
            },
            icon: Icon(
              _showSummary ? Icons.expand_less : Icons.expand_more,
              color: ColorTheme.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE4E4E4)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCodeController,
                  decoration: InputDecoration(
                    isDense: false,
                    labelText: 'Coupon Code',
                    labelStyle: poppinsMedium.copyWith(
                        fontSize: 12, color: const Color(0xFF828282)),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  style: poppinsMedium.copyWith(
                    color: const Color(0xFF2E2E2E),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoadingCouponReport.value
                        ? null
                        : _fetchReport,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      backgroundColor: ColorTheme.appColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      disabledBackgroundColor: ColorTheme.appColor,
                    ),
                    child: controller.isLoadingCouponReport.value
                        ? SpinKitFadingCircle(
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            'Submit',
                            style: poppinsMedium.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: _DateField(
                  label: 'From',
                  controller: _fromController,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _DateField(
                  label: 'To',
                  controller: _toController,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE4E4E4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Order',
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.blue,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Coupon',
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.blue,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Amount',
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.blue,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> row) {
    final orderNumber = (row['order_number'] ?? '').toString();
    final orderType = (row['order_type'] ?? '').toString();
    final paymentMethod = (row['payment_method'] ?? '').toString();
    final date = (row['date'] ?? '').toString();
    final couponCode = (row['coupon_code'] ?? '').toString();
    final couponType = (row['coupon_type'] ?? '').toString();
    final couponDiscountAmount =
        (row['coupon_discount_amount'] ?? '0').toString();
    final finalOrderAmount = (row['final_order_amount'] ?? '0').toString();
    final customerName = (row['customer_name'] ?? '').toString();

    // Format date
    String formattedDate = date;
    try {
      if (date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      }
    } catch (e) {
      // Keep original if parsing fails
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE4E4E4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '#${orderNumber}',
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(
                      color: ColorTheme.blue,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderType,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paymentMethod,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    couponCode,
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    couponType,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    couponDiscountAmount,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    finalOrderAmount,
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customerName,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              Icon(Icons.arrow_back_ios_new_sharp, color: ColorTheme.appColor),
        ),
        titleSpacing: 0,
        title: Text(
          'Coupon Usage Report',
          style: poppinsSemiBold.copyWith(
              fontSize: 16, color: const Color(0xFF2E2E2E)),
        ),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Download Report',
                onPressed: controller.isLoadingCouponExport.value
                    ? null
                    : () => controller.exportCouponUsageReport(
                          _fromController.text.trim(),
                          _toController.text.trim(),
                          _couponCodeController.text.trim(),
                        ),
                icon: controller.isLoadingCouponExport.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorTheme.appColor,
                        ),
                      )
                    : Icon(Icons.file_download_outlined, color: ColorTheme.appColor),
              )),
          Obx(() => IconButton(
                tooltip: 'Refresh',
                onPressed: controller.isLoadingCouponReport.value
                    ? null
                    : _fetchReport,
                icon: Icon(Icons.refresh, color: Color(0xFFC6C6C6)),
              )),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildSummaryText(),
          20.height,
          // Obx(() {
          //   if (controller.couponReportOrders.isEmpty &&
          //       !controller.isLoadingCouponReport.value &&
          //       _couponCodeController.text.trim().isEmpty) {
          //     return Expanded(
          //       child: Center(
          //         child: Text(
          //           'Write coupon code in order to see the report',
          //           style: poppinsMedium.copyWith(
          //             color: const Color(0xFF828282),
          //             fontSize: 14,
          //           ),
          //         ),
          //       ),
          //     );
          //   }
          //   return const SizedBox.shrink();
          // }),
          _buildTableHeader(),
          Expanded(
            child: Obx(() {
              if (controller.couponReportOrders.isEmpty &&
                  !controller.isLoadingCouponReport.value &&
                  _couponCodeController.text.trim().isEmpty) {
                return Center(
                  child: Text(
                    'Enter coupon code in order to see the report',
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 14,
                    ),
                  ),
                );
              }
              if (controller.isLoadingCouponReport.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final filteredOrders = _getFilteredOrders();
              if (filteredOrders.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.trim().isNotEmpty
                        ? 'No results found'
                        : 'No data',
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) =>
                    _buildRow(filteredOrders[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: poppinsMedium.copyWith(
            fontSize: 12, color: const Color(0xFF828282)),
        suffixIcon: const Icon(Icons.calendar_today,
            size: 18, color: Color(0xFF828282)),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE4E4E4)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE4E4E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE4E4E4)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      style: poppinsMedium.copyWith(
        color: const Color(0xFF2E2E2E),
        fontSize: 12,
      ),
    );
  }
}
