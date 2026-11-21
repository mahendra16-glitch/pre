import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart';
import 'package:open_file/open_file.dart' as open_filex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class SettlementDayWiseReport extends StatefulWidget {
  const SettlementDayWiseReport({super.key});

  @override
  State<SettlementDayWiseReport> createState() =>
      _SettlementDayWiseReportState();
}

class _SettlementDayWiseReportState extends State<SettlementDayWiseReport> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  final RxBool _showSummary = false.obs;

  late SettlementManagementController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SettlementManagementController>();
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
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    await controller.getSettlementClosingReportNew(
      fromDate: _fromController.text.trim(),
      toDate: _toController.text.trim(),
    );
  }

  double _asNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final s = value.toString().replaceAll(',', '');
    return double.tryParse(s) ?? 0.0;
  }

  Widget _buildSummaryText() {
    return Obx(() {
      if (controller.settlementReportSummary.value == null ||
          controller.settlementReportSummary.value!.isEmpty ||
          !_showSummary.value) {
        return const SizedBox.shrink();
      }

      final summary = controller.settlementReportSummary.value!;

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
            _summaryRow('Opening Balance',
                summary['opening_balance']?.toString() ?? '0'),
            _summaryRow('Paid Cash Revenue',
                summary['total_cash_collect']?.toString() ?? '0'),
            _summaryRow('Closing Balance',
                summary['last_day_pending']?.toString() ?? '0'),
            _summaryRow(
                'Today Given', summary['today_given']?.toString() ?? '0'),
            _summaryRow(
                'Current Balance', summary['total_balance']?.toString() ?? '0'),
            _summaryRow(
                'Total Expense', summary['total_expence']?.toString() ?? '0'),
            _summaryRow(
                'Cash Collected', summary['total_settle']?.toString() ?? '0'),
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
            style: montserratMedium.copyWith(
              color: const Color(0xFF2E2E2E),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: montserratMedium.copyWith(
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Search by date ...",
          hintStyle: montserratMedium.copyWith(
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
        style: montserratMedium.copyWith(
          color: const Color(0xFF2E2E2E),
          fontSize: 13,
        ),
        onChanged: (value) {
          setState(() {});
        },
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
                'Date',
                textAlign: TextAlign.center,
                style: montserratSemiBold.copyWith(
                  color: const Color(0xFF2E2E2E),
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
                'Opening & Closing Balance',
                textAlign: TextAlign.center,
                style: montserratSemiBold.copyWith(
                  color: const Color(0xFF2E2E2E),
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
                'Cash Collected',
                textAlign: TextAlign.center,
                style: montserratSemiBold.copyWith(
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
                'Balance Left',
                textAlign: TextAlign.center,
                style: montserratSemiBold.copyWith(
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
    // Handle new API response format
    final date = (row['settle_date'] ?? row['date'] ?? '').toString();
    final openingBalance = (row['opening_balance'] ?? '0').toString();
    final closingBalance =
        (row['closing_balance'] ?? row['last_day_pending'] ?? '0').toString();
    final totalBalance =
        (row['current_balance'] ?? row['total_balance'] ?? '0').toString();
    final cashCollected = (row['cash_collected'] ?? '0').toString();
    final waiterName =
        (row['waiter_name'] ?? row['restaurant_id'] ?? '').toString();

    // Format date
    String formattedDate = date;
    try {
      if (date.isNotEmpty && date != 'null') {
        final dateTime = DateFormat('yyyy-MM-dd').parse(date);
        formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      } else {
        formattedDate = '';
      }
    } catch (e) {
      formattedDate = date;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   waiterName.isNotEmpty ? '#$waiterName' : formattedDate,
                  //   textAlign: TextAlign.center,
                  //   style: montserratMedium.copyWith(
                  //     color: ColorTheme.blue,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // if (waiterName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: montserratMedium.copyWith(
                      color: ColorTheme.blue,
                      fontSize: 12,
                    ),
                  ),
                  // ],
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'O : ',
                          style: montserratSemiBold.copyWith(
                            color: ColorTheme.blue,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: '₹$openingBalance',
                          style: montserratSemiBold.copyWith(
                            color: const Color(0xFF2E2E2E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'C : ',
                          style: montserratSemiBold.copyWith(
                            color: ColorTheme.blue,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: '₹$closingBalance',
                          style: montserratSemiBold.copyWith(
                            color: const Color(0xFF2E2E2E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Cash Collect: ₹${row['total_cash_collect'] ?? '0'}',
                  //   textAlign: TextAlign.left,
                  //   style: poppinsMedium.copyWith(
                  //     color: const Color(0xFF828282),
                  //     fontSize: 11,
                  //   ),
                  // ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Total settlement of that day: ₹${row['total_settle'] ?? '0'}',
                  //   textAlign: TextAlign.left,
                  //   style: poppinsMedium.copyWith(
                  //     color: ColorTheme.blue,
                  //     fontSize: 11,
                  //   ),
                  // ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹$cashCollected',
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                          color: const Color(0xFF2E2E2E),
                          fontSize: 12,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      const SizedBox(height: 4),
                      Text(
                        'Pilferage: ₹${row['total_pilferage'] ?? '0'}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: montserratMedium.copyWith(
                          color: const Color(0xFF828282),
                          fontSize: 11,
                        ),
                      ),
                    ])),
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
                    '₹$totalBalance',
                    textAlign: TextAlign.center,
                    style: montserratSemiBold.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 13,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Expense: ₹${row['total_expence'] ?? '0'}',
                  //   textAlign: TextAlign.left,
                  //   style: poppinsMedium.copyWith(
                  //     color: const Color(0xFF828282),
                  //     fontSize: 11,
                  //   ),
                  // ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Pilferage: ₹${row['total_pilferage'] ?? '0'}',
                  //   textAlign: TextAlign.left,
                  //   style: poppinsMedium.copyWith(
                  //     color: const Color(0xFF828282),
                  //     fontSize: 11,
                  //   ),
                  // )
                  // if (row['total_settle'] != null) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     'Cash Collected: ₹${row['total_settle'] ?? '0'}',
                  //     textAlign: TextAlign.center,
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 1,
                  //     style: montserratMedium.copyWith(
                  //       color: ColorTheme.blue,
                  //       fontSize: 11,
                  //     ),
                  //   ),
                  // ],
                  // if (row['total_cash_collect'] != null) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     'Paid Cash Revenue : ₹${row['total_cash_collect'] ?? '0'}',
                  //     textAlign: TextAlign.center,
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 1,
                  //     style: montserratMedium.copyWith(
                  //       color: const Color(0xFF828282),
                  //       fontSize: 11,
                  //     ),
                  //   ),
                  // ],
                  // if (row['total_pilferage'] != null) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     'Pilferage: ₹${row['total_pilferage'] ?? '0'}',
                  //     textAlign: TextAlign.center,
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 1,
                  //     style: montserratMedium.copyWith(
                  //       color: const Color(0xFF828282),
                  //       fontSize: 11,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportExcel() async {
    try {
      final records = controller.settlementReportRowsNew;
      final summary =
          controller.settlementReportSummary.value ?? <String, dynamic>{};

      // Create workbook and sheet
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      final start = _fromController.text;
      final end = _toController.text;
      sheet.name = 'Settlement_Report_${start}_to_${end}';

      // Centered style
      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Bold style (for totals)
      final xlsio.Style boldStyle = workbook.styles.add('bold');
      boldStyle.hAlign = xlsio.HAlignType.center;
      boldStyle.vAlign = xlsio.VAlignType.center;
      boldStyle.bold = true;

      // Headers
      final List<String> headers = [
        'Date',
        'Waiter ID',
        'Opening Balance',
        'Total Cash Collect',
        'Total Settle',
        'Total Balance',
        'Total Expense'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = boldStyle;
      }

      // Rows
      int rowIndex = 2;
      for (final rec in records) {
        final List<dynamic> rowData = [
          rec['settle_date'] ?? rec['date'] ?? '',
          rec['restaurant_id'] ?? rec['waiter_id'] ?? '',
          rec['opening_balance'] ?? '0',
          rec['total_cash_collect'] ?? '0',
          rec['total_settle'] ?? '0',
          rec['current_balance'] ?? rec['total_balance'] ?? '0',
          rec['total_expence'] ?? '0',
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
          final value = rowData[col];

          // First two columns are text (date and waiter_id), others are numbers
          if (col == 0 || col == 1) {
            cell.setText(value?.toString() ?? '');
          } else {
            final parsed = _asNumber(value);
            cell.setNumber(parsed);
          }
          cell.cellStyle.hAlign = xlsio.HAlignType.center;
          cell.cellStyle.vAlign = xlsio.VAlignType.center;
        }
        rowIndex++;
      }

      // Add empty row
      rowIndex++;

      // Add Totals
      final totalRow = rowIndex;
      final dateLabelCell = sheet.getRangeByName('A$totalRow');
      dateLabelCell.setText('Total:');
      dateLabelCell.cellStyle = boldStyle;

      // Calculate totals from records
      double totalOpening = 0;
      double totalCash = 0;
      double totalSettle = 0;
      double totalBalance = 0;
      double totalExpense = 0;

      for (final rec in records) {
        totalOpening += _asNumber(rec['opening_balance'] ?? '0');
        totalCash += _asNumber(rec['total_cash_collect'] ?? '0');
        totalSettle += _asNumber(rec['total_settle'] ?? '0');
        totalBalance +=
            _asNumber(rec['current_balance'] ?? rec['total_balance'] ?? '0');
        totalExpense += _asNumber(rec['total_expence'] ?? '0');
      }

      // Use summary if available, otherwise use calculated totals
      final totalOpeningValue = summary['opening_balance'] != null
          ? _asNumber(summary['opening_balance'] ?? '0')
          : totalOpening;
      final totalCashValue = summary['total_cash_collect'] != null
          ? _asNumber(summary['total_cash_collect'] ?? '0')
          : totalCash;
      final totalSettleValue = summary['total_settle'] != null
          ? _asNumber(summary['total_settle'] ?? '0')
          : totalSettle;
      final totalBalanceValue = summary['total_balance'] != null
          ? _asNumber(summary['total_balance'] ?? '0')
          : totalBalance;
      final totalExpenseValue = summary['total_expence'] != null
          ? _asNumber(summary['total_expence'] ?? '0')
          : totalExpense;

      // Total Opening Balance
      final totalOpeningCell = sheet.getRangeByName('C$totalRow');
      totalOpeningCell.setNumber(totalOpeningValue);
      totalOpeningCell.cellStyle = boldStyle;

      // Total Cash Collect
      final totalCashCell = sheet.getRangeByName('D$totalRow');
      totalCashCell.setNumber(totalCashValue);
      totalCashCell.cellStyle = boldStyle;

      // Total Settle
      final totalSettleCell = sheet.getRangeByName('E$totalRow');
      totalSettleCell.setNumber(totalSettleValue);
      totalSettleCell.cellStyle = boldStyle;

      // Total Balance
      final totalBalanceCell = sheet.getRangeByName('F$totalRow');
      totalBalanceCell.setNumber(totalBalanceValue);
      totalBalanceCell.cellStyle = boldStyle;

      // Total Expense
      final totalExpenseCell = sheet.getRangeByName('G$totalRow');
      totalExpenseCell.setNumber(totalExpenseValue);
      totalExpenseCell.cellStyle = boldStyle;

      // Auto-fit columns
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save flow: Windows → Save dialog; Others → temp/app dir and open
      String fileName =
          'Settlement_Report_${start.replaceAll('/', '_')}_to_${end.replaceAll('/', '_')}.xlsx';

      if (Platform.isWindows) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Excel File',
          fileName: fileName,
        );
        if (outputFile == null) return;

        final List<int> bytes = workbook.saveAsStream();
        workbook.dispose();

        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        Get.snackbar(
          'Success',
          'Excel exported successfully',
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );

        final fileUri = Uri.file(outputFile);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          await open_filex.OpenFile.open(outputFile);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final outputPath = '${dir.path}/$fileName';

        final List<int> bytes = workbook.saveAsStream();
        workbook.dispose();

        final file = File(outputPath);
        await file.writeAsBytes(bytes);

        Get.snackbar(
          'Success',
          'Excel exported successfully',
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );

        await open_filex.OpenFile.open(outputPath);
      }
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
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
          'Settlement Report',
          style: montserratSemiBold.copyWith(
              fontSize: 16, color: const Color(0xFF2E2E2E)),
        ),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Refresh',
                onPressed: controller.isLoadingSettlementReportNew.value
                    ? null
                    : _fetchReport,
                icon: Icon(Icons.refresh, color: Color(0xFFC6C6C6)),
              )),
          Obx(() => IconButton(
                tooltip: 'Download (Excel)',
                onPressed: controller.isLoadingSettlementExport.value
                    ? null
                    : () => controller.exportSettlementClosingReport(
                          fromDate: _fromController.text.trim(),
                          toDate: _toController.text.trim(),
                        ),
                mouseCursor: controller.isLoadingSettlementExport.value
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.click,
                icon: controller.isLoadingSettlementExport.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFC6C6C6),
                        ),
                      )
                    : const Icon(Icons.file_download_outlined,
                        size: 25, color: Color(0xFFC6C6C6)),
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
          _buildTableHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingSettlementReportNew.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = controller.settlementReportRowsNew;
              final search = _searchController.text.trim().toLowerCase();

              // Filter records based on search
              final filteredRecords = records.where((record) {
                if (search.isEmpty) return true;
                final date = (record['settle_date'] ?? record['date'] ?? '')
                    .toString()
                    .toLowerCase();
                final waiterId =
                    (record['waiter_name'] ?? record['restaurant_id'] ?? '')
                        .toString()
                        .toLowerCase();
                return date.contains(search) || waiterId.contains(search);
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
                itemBuilder: (context, index) =>
                    _buildRow(filteredRecords[index]),
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
