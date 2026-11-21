import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class TabReportScreen extends StatefulWidget {
  const TabReportScreen({super.key});

  @override
  State<TabReportScreen> createState() => _TabReportScreenState();
}

class _TabReportScreenState extends State<TabReportScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final RxBool _showSummary = false.obs;

  late PosController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PosController>();
    _fromController.text = DateFormat('dd/MM/yyyy').format(_fromDate);
    _toController.text = DateFormat('dd/MM/yyyy').format(_toDate);
    _fetchReport();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
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
      if (isFrom) {
        _fromDate = picked;
        _fromController.text = DateFormat('dd/MM/yyyy').format(_fromDate);
      } else {
        _toDate = picked;
        _toController.text = DateFormat('dd/MM/yyyy').format(_toDate);
      }
      // Auto-call API when date changes
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    await controller.getTapCustomerOrderRecords(
      fromDate: _fromController.text.trim(),
      toDate: _toController.text.trim(),
    );
  }

  Future<void> _exportExcel() async {
    await controller.exportTapCustomerOrderRecords(
      fromDate: _fromController.text.trim(),
      toDate: _toController.text.trim(),
    );
  }

  Widget _buildSummaryText() {
    return GetBuilder<PosController>(
      builder: (controller) {
        if (controller.tapCustomerOrderSummary.isEmpty || !_showSummary.value) {
          return const SizedBox.shrink();
        }

        final summary = controller.tapCustomerOrderSummary;
        final totalRecords = summary['total_records']?.toString() ?? '0';
        final totalAmount = summary['total_debit_amount']?.toString() ?? '0';

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
              _summaryRow('Total Records', totalRecords),
              _summaryRow('Total Debit Amount', totalAmount),
            ],
          ),
        );
      },
    );
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE4E4E4)),
        ),
      ),
      child: Row(
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
          // const SizedBox(width: 8),
          // Obx(() => IconButton(
          //       tooltip: _showSummary.value ? 'Hide summary' : 'Show summary',
          //       onPressed: () {
          //         _showSummary.value = !_showSummary.value;
          //         controller.update();
          //       },
          //       icon: Icon(
          //         _showSummary.value ? Icons.expand_less : Icons.expand_more,
          //         color: ColorTheme.appColor,
          //       ),
          //     )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search by customer name or mobile...",
                hintStyle: poppinsMedium.copyWith(
                    fontSize: 13, color: const Color(0xFF828282)),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF828282).withOpacity(0.5),
                  size: 20,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE4E4E4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE4E4E4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE4E4E4)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE4E4E4)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE4E4E4)),
                ),
              ),
              style: poppinsMedium.copyWith(
                color: const Color(0xFF2E2E2E),
                fontSize: 13,
              ),
              onChanged: (value) {
                // Trigger rebuild to show filtered results
                Get.find<PosController>().update();
              },
            ),
          ),
          const SizedBox(width: 8),
          // GetBuilder<PosController>(
          //   builder: (controller) {
          //     final summary = controller.tapCustomerOrderSummary;
          //     final totalRecords = summary.isNotEmpty
          //         ? (summary['total_records']?.toString() ?? '0')
          //         : '0';
          //     final totalAmount = summary.isNotEmpty
          //         ? (summary['total_debit_amount']?.toString() ?? '0')
          //         : '0';
          //     return PopupMenuButton<String>(
          //       tooltip: 'Summary',
          //       icon: Icon(Icons.info_outline, color: ColorTheme.appColor),
          //       onSelected: (value) {},
          //       itemBuilder: (context) => [
          //         PopupMenuItem(
          //           enabled: false,
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Summary',
          //                 style: poppinsSemiBold.copyWith(
          //                   color: const Color(0xFF2E2E2E),
          //                   fontSize: 14,
          //                 ),
          //               ),
          //               const SizedBox(height: 8),
          //               _summaryRow('Total Records', totalRecords),
          //               _summaryRow('Total Amount', totalAmount),
          //             ],
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),

          Obx(() => IconButton(
                tooltip: _showSummary.value ? 'Hide summary' : 'Show summary',
                onPressed: () {
                  _showSummary.value = !_showSummary.value;
                  controller.update();
                },
                icon: Icon(
                  _showSummary.value ? Icons.expand_less : Icons.expand_more,
                  color: ColorTheme.blue,
                ),
              )),
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
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Name',
                textAlign: TextAlign.start,
                style: poppinsSemiBold.copyWith(
                  color: const Color(0xFF2E2E2E),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Waiter Name',
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  color: const Color(0xFF2E2E2E),
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
                  color: const Color(0xFF2E2E2E),
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
    final customerName = (row['customer_name'] ?? '').toString();
    final customerMobile = (row['customer_mobile'] ?? '').toString();
    final waiterName = (row['waiter_name'] ?? '').toString();
    final createdAt = (row['created_at'] ?? '').toString();
    final debitAmount = (row['debit_order_amount'] ?? '0').toString();
    final paymentStatus = (row['payment_status'] ?? '').toString();

    // Format date
    String formattedDate = createdAt;
    try {
      if (createdAt.isNotEmpty && createdAt != 'null') {
        final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } else {
        formattedDate = '';
      }
    } catch (e) {
      // Keep original if parsing fails
      formattedDate = createdAt;
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
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerMobile,
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    waiterName,
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: ColorTheme.blue,
                      fontSize: 10,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    debitAmount,
                    textAlign: TextAlign.left,
                    style: poppinsSemiBold.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paymentStatus.toUpperCase(),
                    textAlign: TextAlign.left,
                    style: poppinsMedium.copyWith(
                      color: ColorTheme.blue,
                      fontSize: 11,
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
          'Tab Report',
          style: poppinsSemiBold.copyWith(
              fontSize: 16, color: const Color(0xFF2E2E2E)),
        ),
        actions: [
          GetBuilder<PosController>(
            builder: (controller) => IconButton(
              tooltip: 'Refresh',
              onPressed: controller.isLoadingTapReport ? null : _fetchReport,
              icon: Icon(Icons.refresh, color: const Color(0xFFC6C6C6)),
            ),
          ),
          const SizedBox(width: 10),
          GetBuilder<PosController>(
            builder: (c) => IconButton(
              tooltip: 'Download (Excel)',
              onPressed:
                  (c.tapCustomerOrderRecords.isEmpty || c.isLoadingTapReport)
                      ? null
                      : _exportExcel,
              mouseCursor:
                  (c.tapCustomerOrderRecords.isEmpty || c.isLoadingTapReport)
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
              icon: const Icon(
                Icons.file_download_outlined,
                size: 25,
                color: Color(0xFFC6C6C6),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<PosController>(
        builder: (controller) => Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildSummaryText(),
            _buildTableHeader(),
            Expanded(
              child: _buildTableData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableData() {
    return GetBuilder<PosController>(
      builder: (controller) {
        if (controller.isLoadingTapReport) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = controller.tapCustomerOrderRecords;
        final search = _searchController.text.trim().toLowerCase();

        // Filter records based on search
        final filteredRecords = records.where((record) {
          if (search.isEmpty) return true;
          final customerName =
              (record['customer_name'] ?? '').toString().toLowerCase();
          final customerMobile =
              (record['customer_mobile'] ?? '').toString().toLowerCase();
          return customerName.contains(search) ||
              customerMobile.contains(search);
        }).toList();

        if (filteredRecords.isEmpty) {
          return Center(
            child: Text(
              search.isEmpty ? 'No data' : 'No results found',
              style: poppinsMedium.copyWith(
                color: const Color(0xFF828282),
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredRecords.length,
          itemBuilder: (context, index) => _buildRow(filteredRecords[index]),
        );
      },
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
        focusedBorder: const OutlineInputBorder(
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
