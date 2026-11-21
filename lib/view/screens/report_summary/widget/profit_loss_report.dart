import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:open_file/open_file.dart' as open_filex;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class ProfitLossReport extends StatefulWidget {
  const ProfitLossReport({super.key});

  @override
  State<ProfitLossReport> createState() => _ProfitLossReportState();
}

class _ProfitLossReportState extends State<ProfitLossReport> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  bool _showSummary = false;

  late ReportSummeryController controller;

  @override
  void initState() {
    super.initState();
    
    controller = Get.find<ReportSummeryController>();
    controller.profitLossSummary.value = {};
    controller.profitLossRows.value = [];
    _fromController.text = DateFormat('dd/MM/yyyy').format(_fromDate);
    _toController.text = DateFormat('dd/MM/yyyy').format(_toDate);
    _fetchReport();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
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
          _fromController.text = DateFormat('dd/MM/yyyy').format(_fromDate);
        } else {
          _toDate = picked;
          _toController.text = DateFormat('dd/MM/yyyy').format(_toDate);
        }
      });
      // Auto-call API when date changes
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    await controller.getProfitLossReport(
      _fromController.text.trim(),
      _toController.text.trim(),
    );
  }

  Color _profitColor(String value) {
    final n = _asNumber(value);
    if (n < 0) return Colors.red;
    if (n > 0) return Colors.green;
    return const Color(0xFF828282);
  }

  double _asNumber(String? s) {
    if (s == null) return 0.0;
    return double.tryParse(s.replaceAll(',', '')) ?? 0.0;
  }

  Widget _buildSummaryText() {
    return Obx(() {
      if (controller.profitLossSummary.isEmpty || controller.isLoadingProfitLoss.value ) {
        return const SizedBox.shrink();
      }

      final summary = controller.profitLossSummary;
      final profitLoss = summary['total_profit_loss']?.toString() ?? '0';
      final profitColor = _profitColor(profitLoss);

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
            // _summaryRow(
            //     'Total Sales', summary['total_sales']?.toString() ?? '0'),
            _summaryRow('Total Paid Revenue',
                summary['total_paid_revenue']?.toString() ?? '0'),
            _summaryRow(
                'Total Expenses', summary['total_expenses']?.toString() ?? '0'),
            _summaryRow(
                'Total Purchase', summary['total_purchase']?.toString() ?? '0'),
            // _summaryRow('Total Expenses Combined',
            //     summary['total_expenses_combined']?.toString() ?? '0'),
            // const Divider(color: Color(0xFFE6E6E6)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Profit Loss',
                    style: poppinsSemiBold.copyWith(
                      color: const Color(0xFF2E2E2E),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    profitLoss,
                    style: poppinsSemiBold.copyWith(
                      color: profitColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
          // IconButton(
          //   tooltip: _showSummary ? 'Hide summary' : 'Show summary',
          //   onPressed: () {
          //     setState(() {
          //       _showSummary = !_showSummary;
          //     });
          //   },
          //   icon: Icon(
          //     _showSummary ? Icons.expand_less : Icons.expand_more,
          //     color: ColorTheme.appColor,
          //   ),
          // ),
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
                'Date',
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Paid Revenue',
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Text(
                'Expense & Purchase',
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
                'Profit/Loss',
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
    final date = (row['date'] ?? '').toString();
    final paidRevenue = (row['paid_revenue'] ?? '0').toString();
    final totalExpenses = (row['total_expenses'] ?? '0').toString();
    final profitLoss = (row['profit_loss'] ?? '0').toString();

    final double pnl = _asNumber(profitLoss);
    final label = pnl < 0
        ? 'Loss'
        : pnl > 0
            ? 'Profit'
            : '';
    final color = _profitColor(profitLoss);

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
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: poppinsMedium.copyWith(
                  color: const Color(0xFF2E2E2E),
                  fontSize: 12,
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
                paidRevenue,
                textAlign: TextAlign.center,
                style: poppinsMedium.copyWith(
                  color: const Color(0xFF828282),
                  fontSize: 12,
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
                totalExpenses,
                textAlign: TextAlign.center,
                style: poppinsMedium.copyWith(
                  color: const Color(0xFF828282),
                  fontSize: 12,
                ),
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
                    profitLoss,
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: poppinsMedium.copyWith(
                        color: color.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
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
      controller.isLoadingProfitLoss.value = true;
      controller.update();
      final records = controller.profitLossRows;
      final summary = controller.profitLossSummary;

      // Create workbook and sheet
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      final start = _fromController.text;
      final end = _toController.text;
      sheet.name = 'Profit_Loss_${start}_to_${end}';

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
        'Sales',
        'Paid Revenue',
        'Expenses',
        'Purchase',
        'Total Expenses',
        'Profit/Loss'
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
          rec['date'] ?? '',
          rec['sales'] ?? '0',
          rec['paid_revenue'] ?? '0',
          rec['expenses'] ?? '0',
          rec['purchase'] ?? '0',
          rec['total_expenses'] ?? '0',
          rec['profit_loss'] ?? '0',
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
          final value = rowData[col];

          // First column is date (text), others are numbers
          if (col == 0) {
            cell.setText(value?.toString() ?? '');
          } else {
            final parsed = _asNumber(value?.toString() ?? '0');
            cell.setNumber(parsed);

            // Color profit/loss column (index 6)
            if (col == 6) {
              if (parsed < 0) {
                cell.cellStyle.fontColor = '#FF0000';
                cell.cellStyle.bold = true;
              } else if (parsed > 0) {
                cell.cellStyle.fontColor = '#008000';
                cell.cellStyle.bold = true;
              }
            }
          }
          cell.cellStyle.hAlign = xlsio.HAlignType.center;
          cell.cellStyle.vAlign = xlsio.VAlignType.center;
        }
        rowIndex++;
      }

      // Add empty row
      rowIndex++;

      // Add ALL Totals in the SAME ROW
      final totalRow = rowIndex;

      // Total label in Date column
      final dateLabelCell = sheet.getRangeByName('A$totalRow');
      dateLabelCell.setText('Total:');
      dateLabelCell.cellStyle = boldStyle;

      // Total Sales
      final totalSalesCell = sheet.getRangeByName('B$totalRow');
      final totalSales = _asNumber((summary['total_sales'] ?? '0').toString());
      totalSalesCell.setNumber(totalSales);
      totalSalesCell.cellStyle = boldStyle;

      // Total Paid Revenue
      final totalPaidRevenueCell = sheet.getRangeByName('C$totalRow');
      final totalPaidRevenue =
          _asNumber((summary['total_paid_revenue'] ?? '0').toString());
      totalPaidRevenueCell.setNumber(totalPaidRevenue);
      totalPaidRevenueCell.cellStyle = boldStyle;

      // Total Expenses
      final totalExpensesCell = sheet.getRangeByName('D$totalRow');
      final totalExpenses =
          _asNumber((summary['total_expenses'] ?? '0').toString());
      totalExpensesCell.setNumber(totalExpenses);
      totalExpensesCell.cellStyle = boldStyle;

      // Total Purchase
      final totalPurchaseCell = sheet.getRangeByName('E$totalRow');
      final totalPurchase =
          _asNumber((summary['total_purchase'] ?? '0').toString());
      totalPurchaseCell.setNumber(totalPurchase);
      totalPurchaseCell.cellStyle = boldStyle;

      // Total Expenses Combined
      final totalExpensesCombinedCell = sheet.getRangeByName('F$totalRow');
      final totalExpensesCombined =
          _asNumber((summary['total_expenses_combined'] ?? '0').toString());
      totalExpensesCombinedCell.setNumber(totalExpensesCombined);
      totalExpensesCombinedCell.cellStyle = boldStyle;

      // Total Profit/Loss
      final totalProfitLossCell = sheet.getRangeByName('G$totalRow');
      final totalProfitLoss =
          _asNumber((summary['total_profit_loss'] ?? '0').toString());
      totalProfitLossCell.setNumber(totalProfitLoss);
      totalProfitLossCell.cellStyle = boldStyle;

      // Color the total profit/loss
      if (totalProfitLoss < 0) {
        totalProfitLossCell.cellStyle.fontColor = '#FF0000';
      } else if (totalProfitLoss > 0) {
        totalProfitLossCell.cellStyle.fontColor = '#008000';
      }

      // Auto-fit columns
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save flow: Windows → Save dialog; Others → temp/app dir and open
      String fileName =
          'Profit_Loss_${start.replaceAll('/', '_')}_to_${end.replaceAll('/', '_')}.xlsx';

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
        // Request permission for non-Windows
        // if (!Platform.isWindows) {
        //   final status = await Permission.storage.request();
        //   if (!status.isGranted) {
        //     Get.snackbar('Permission', 'Storage permission denied',
        //         colorText: Colors.white, backgroundColor: Colors.red);
        //     return;
        //   }
        // }

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
    } finally {
      controller.isLoadingProfitLoss.value = false;
      controller.update();
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
          'Profit Loss Report',
          style: poppinsSemiBold.copyWith(
              fontSize: 16, color: const Color(0xFF2E2E2E)),
        ),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Refresh',
                onPressed:
                    controller.isLoadingProfitLoss.value ? null : _fetchReport,
                icon: Icon(Icons.refresh, color: Color(0xFFC6C6C6)),
              )),
          Obx(() => IconButton(
                tooltip: 'Download (Excel)',
                onPressed:
                    controller.profitLossRows.isEmpty || controller.isLoadingProfitLoss.value ? null : _exportExcel,
                mouseCursor: controller.profitLossRows.isEmpty || controller.isLoadingProfitLoss.value ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
                icon: const Icon(Icons.file_download_outlined,
                    size: 25, color: Color(0xFFC6C6C6)),
              )),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSummaryText(),
          20.height,
          _buildTableHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingProfitLoss.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.profitLossRows.isEmpty) {
                return Center(
                  child: Text(
                    'No data',
                    style: poppinsMedium.copyWith(
                      color: const Color(0xFF828282),
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.profitLossRows.length,
                itemBuilder: (context, index) =>
                    _buildRow(controller.profitLossRows[index]),
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