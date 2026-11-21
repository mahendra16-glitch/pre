import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  ExpenseManagementController get expenseController =>
      Get.find<ExpenseManagementController>();

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _resetFilters();
  }

  /// Reset filters to current date and clear list
  void _resetFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      expenseController.formattedFromDate =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
      expenseController.formattedToDate =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
      expenseController.selectedReportFromDate = DateTime.now();
      expenseController.selectedReportToDate = DateTime.now();
      expenseController.expenseReportList.clear();
      _searchController.clear();
      expenseController.fetchExpenseReport();
    });
  }

  /// Filter list based on search query
  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = expenseController.expenseReportList;
      } else {
        _filteredList = expenseController.expenseReportList.where((expense) {
          final expName = expense['exp_name']?.toString().toLowerCase() ?? '';
          final category =
              expense['category_name']?.toString().toLowerCase() ?? '';
          final amount = expense['d_amount']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return expName.contains(searchLower) ||
              category.contains(searchLower) ||
              amount.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Date picker for From Date
  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: expenseController.selectedReportFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        expenseController.selectedReportFromDate = pickedDate;
        expenseController.formattedFromDate =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
      await expenseController.fetchExpenseReport();
      _filterList(_searchController.text);
    }
  }

  /// Date picker for To Date
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: expenseController.selectedReportToDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        expenseController.selectedReportToDate = pickedDate;
        expenseController.formattedToDate =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
      await expenseController.fetchExpenseReport();
      _filterList(_searchController.text);
    }
  }

  /// Reload data with reset
  Future<void> _reloadData() async {
    _searchController.clear();
    _resetFilters();
  }

  Future<void> exportExpenseReportToExcel() async {
    if (Platform.isWindows) {
      await _exportExpenseReportWindows();
    } else {
      await _exportExpenseReportMobile();
    }
  }

  Future<void> _exportExpenseReportWindows() async {
    try {
      expenseController.isDownloadLoader = true;
      expenseController.update();
      final fromDate = expenseController.selectedReportFromDate != null
          ? DateFormat('dd_MM_yyyy')
              .format(expenseController.selectedReportFromDate!)
          : DateFormat('dd_MM_yyyy').format(DateTime.now());

      final toDate = expenseController.selectedReportToDate != null
          ? DateFormat('dd_MM_yyyy')
              .format(expenseController.selectedReportToDate!)
          : DateFormat('dd_MM_yyyy').format(DateTime.now());

      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Expense_Report_${expenseController.selectedReportFromDate}_to_${expenseController.selectedReportToDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Headers for Expense Report
      List<String> headers = [
        'Expense Name',
        'Category',
        'Quantity',
        'Unit',
        'Amount',
        'Payment Type',
        'Created At',
      ];

      // Set headers
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      // Fill Data
      double totalAmount = 0.0;
      for (int i = 0; i < expenseController.expenseReportList.length; i++) {
        final item = expenseController.expenseReportList[i];
        final amount =
            double.tryParse(item['d_amount']?.toString() ?? '0.0') ?? 0.0;
        totalAmount += amount;

        List<dynamic> rowData = [
          item['exp_name'] ?? '',
          item['category_name'] ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          item['unit']?.toString() ?? '',
          amount,
          item['payment_method'] ?? '',
          DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss')
              .parse(item['created_at'] ?? '')),
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString()) ?? 0;
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Add Total Row
      if (expenseController.expenseReportList.isNotEmpty) {
        // Create bold style for total
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;

        // Add blank row gap (row will be empty)
        final totalRowIndex = expenseController.expenseReportList.length + 3;
        final totalCell = sheet.getRangeByName('E$totalRowIndex');
        totalCell.setText('Total : ${totalAmount.toStringAsFixed(0)}');
        totalCell.cellStyle = boldStyle;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save File
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Expense_Report_${fromDate}_to_${toDate}.xlsx',
      );

      if (outputFile != null) {
        final List<int> bytes = workbook.saveAsStream();
        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        Get.snackbar(
          "Success",
          "Excel file saved to $outputFile",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final fileUri = Uri.file(outputFile);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          Get.snackbar(
            "Warning",
            "Could not open file. Please open it manually.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.yellowAccent,
            colorText: Colors.black,
          );
        }
      } else {
        Get.snackbar(
          "Info",
          "File save canceled by user.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
      }

      workbook.dispose();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save file: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Failed to save file: $e');
    } finally {
      expenseController.isDownloadLoader = false;
      expenseController.update();
    }
  }

  Future<void> _exportExpenseReportMobile() async {
    try {
      expenseController.isDownloadLoader = true;
      expenseController.update();
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Expense_Report_${expenseController.selectedReportFromDate}_to_${expenseController.selectedReportToDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Headers for Expense Report
      List<String> headers = [
        'Expense Name',
        'Category',
        'Quantity',
        'Unit',
        'Amount',
        'Payment Type',
        'Created At',
      ];

      // Set headers
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      // Fill Data
      double totalAmount = 0.0;
      for (int i = 0; i < expenseController.expenseReportList.length; i++) {
        final item = expenseController.expenseReportList[i];
        final amount =
            double.tryParse(item['d_amount']?.toString() ?? '0.0') ?? 0.0;
        totalAmount += amount;

        List<dynamic> rowData = [
          item['exp_name'] ?? '',
          item['category_name'] ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          item['unit']?.toString() ?? '',
          amount,
          item['payment_method'] ?? '',
          DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss')
              .parse(item['created_at'] ?? '')),
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString()) ?? 0;
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Add Total Row
      if (expenseController.expenseReportList.isNotEmpty) {
        // Create bold style for total
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;

        // Add blank row gap (row will be empty)
        final totalRowIndex = expenseController.expenseReportList.length + 3;
        final totalCell = sheet.getRangeByName('E$totalRowIndex');
        totalCell.setText('Total : ${totalAmount.toStringAsFixed(0)}');
        totalCell.cellStyle = boldStyle;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save file in temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Expense_Report_${expenseController.selectedReportFromDate}_to_${expenseController.selectedReportToDate}.xlsx";
      final tempPath = "${tempDir.path}/$fileName";
      final file = File(tempPath);

      if (await file.exists()) {
        await file.delete();
      }
      final List<int> bytes = workbook.saveAsStream();
      await file.writeAsBytes(bytes);

      await Future.delayed(Duration(milliseconds: 500));

      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        Get.snackbar(
          "Success",
          "Excel file saved successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final result = await openFilex.OpenFile.open(finalPath);
        if (result.type != openFilex.ResultType.done) {
          final tempResult = await openFilex.OpenFile.open(tempPath);
          if (tempResult.type != openFilex.ResultType.done) {
            Get.snackbar(
              "Warning",
              "Could not open file. Please open manually.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.yellowAccent,
              colorText: Colors.black,
            );
          }
        }
      } else {
        Get.snackbar(
          "Info",
          "File save canceled by user.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
      }

      workbook.dispose();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save file: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Failed to save file: $e');
    } finally {
      expenseController.isDownloadLoader = false;
      expenseController.update();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.white,
        elevation: 0,
        title: Text(
          'Expense Report',
          style: montserratMedium.copyWith(
            fontSize: 16,
            color: ColorTheme.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: ColorTheme.appColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Total: ${expenseController.totalExpenseReportAmount ?? '0'}',
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: ColorTheme.white,
                ),
              )),
          5.width,
          GetBuilder<ExpenseManagementController>(
            builder: (c) => IconButton(
              onPressed: c.isDownloadLoader
                  ? null
                  : () {
                      exportExpenseReportToExcel();
                    },
              mouseCursor: c.isDownloadLoader
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              icon: const Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 30,
              ),
              tooltip: 'Download Report',
            ),
          ),
          5.width,
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ColorTheme.greyDFDFDF))),
          child: Column(
            children: [
              // Date Selection Section
              Container(
                color: ColorTheme.whiteColor,
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(
                        context: context,
                        label: 'From Date',
                        date: expenseController.formattedFromDate ??
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        onTap: () => _selectFromDate(context),
                      ),
                    ),
                    15.width,
                    Expanded(
                      child: _buildDateSelector(
                        context: context,
                        label: 'To Date',
                        date: expenseController.formattedToDate ??
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        onTap: () => _selectToDate(context),
                      ),
                    ),
                  ],
                ),
              ),

              10.height,

              // Divider
              // DottedLine(
              //   direction: Axis.horizontal,
              //   lineThickness: 1.0,
              //   dashLength: 2.5,
              //   dashColor: ColorTheme.greyColor,
              // ).paddingSymmetric(horizontal: 15),

              // 20.height,

              // Search Bar Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterList,
                  decoration: InputDecoration(
                    hintText: 'Search by expense, category or amount...',
                    hintStyle: montserratMedium.copyWith(
                      fontSize: 13,
                      color: ColorTheme.grey8C.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: ColorTheme.grey8C),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: ColorTheme.grey8C),
                            onPressed: () {
                              _searchController.clear();
                              _filterList('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: ColorTheme.manageBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              20.height,
              DottedLine(
                direction: Axis.horizontal,
                lineThickness: 1.0,
                dashLength: 2.5,
                dashColor: ColorTheme.greyColor,
              ).paddingSymmetric(horizontal: 15),

              // Title and Refresh Row
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              //   child: Row(
              //     children: [
              //       Text(
              //         'Expense Report',
              //         style: montserratMedium.copyWith(
              //           fontSize: 14,
              //           color: ColorTheme.grey8C,
              //         ),
              //       ),
              //       const Spacer(),
              //       // IconButton(
              //       //   onPressed: _reloadData,
              //       //   icon: Icon(
              //       //     Icons.refresh_rounded,
              //       //     color: ColorTheme.greenColor,
              //       //   ),
              //       //   tooltip: 'Reload',
              //       // ),
              //     ],
              //   ),
              // ),

              20.height,

              // Table Section
              Expanded(
                child: GetBuilder<ExpenseManagementController>(
                  builder: (controller) {
                    if (controller.isExpenseReportLoading ?? false) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Set filtered list if search is empty
                    if (_searchController.text.isEmpty) {
                      _filteredList = controller.expenseReportList;
                    }

                    if (_filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: ColorTheme.grey8C.withOpacity(0.3),
                            ),
                            16.height,
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No results found'
                                  : AppString.noDataFound,
                              style: montserratMedium.copyWith(
                                fontSize: 15,
                                color: ColorTheme.grey8C,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorTheme.grey.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(2.5),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(2),
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: ColorTheme.grey.withOpacity(0.2),
                              ),
                              verticalInside: BorderSide(
                                color: ColorTheme.grey.withOpacity(0.2),
                              ),
                            ),
                            children: [
                              // Header Row
                              _buildHeaderRow(),
                              // Data Rows
                              ..._filteredList
                                  .map((expense) => _buildDataRow(expense)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              20.height,
            ],
          ),
        ),
      ),
    );
  }

  /// Build Date Selector Widget
  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: ColorTheme.manageBgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorTheme.greyColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: ColorTheme.grey8C,
            ),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: montserratMedium.copyWith(
                      fontSize: 10,
                      color: ColorTheme.grey8C,
                    ),
                  ),
                  2.height,
                  Text(
                    date,
                    style: montserratMedium.copyWith(
                      fontSize: 13,
                      color: ColorTheme.grey8C,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Table Header Row
  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: ColorTheme.greenColor.withOpacity(0.1),
      ),
      children: [
        _buildHeaderCell('Expense'),
        _buildHeaderCell('Amount'),
        _buildHeaderCell('Quantity'),
      ],
    );
  }

  /// Build Header Cell
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: montserratMedium.copyWith(
          fontSize: 13,
          color: ColorTheme.grey8C,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build Data Row
  TableRow _buildDataRow(Map<String, dynamic> expense) {
    return TableRow(
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
      ),
      children: [
        // Expense Column
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense['exp_name'] ?? '-',
                overflow: TextOverflow.ellipsis,
                style: montserratMedium.copyWith(
                  fontSize: 13,
                  color: ColorTheme.grey8C,
                  fontWeight: FontWeight.w600,
                ),
              ),
              4.height,
              Text(
                expense['category_name'] ?? '-',
                overflow: TextOverflow.ellipsis,
                style: montserratMedium.copyWith(
                  fontSize: 11,
                  color: ColorTheme.foodValue,
                ),
              ),
              4.height,
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 10,
                    color: ColorTheme.manageBlueColor,
                  ),
                  4.width,
                  Text(
                    expense['e_dates'] ?? '-',
                    style: montserratMedium.copyWith(
                      fontSize: 10,
                      color: ColorTheme.manageBlueColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Amount Column
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${expense['d_amount'] ?? '0'}',
                style: montserratMedium.copyWith(
                  fontSize: 15,
                  color: ColorTheme.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              4.height,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  expense['payment_method'] ?? '-',
                  style: montserratMedium.copyWith(
                    fontSize: 10,
                    color: ColorTheme.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quantity Column
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Qty: ',
                    style: montserratMedium.copyWith(
                      fontSize: 11,
                      color: ColorTheme.grey8C.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${expense['quantity'] ?? '0'} ${expense['unit'] ?? '-'}',
                    style: montserratMedium.copyWith(
                      fontSize: 12,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              6.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Physical: ',
                    style: montserratMedium.copyWith(
                      fontSize: 11,
                      color: ColorTheme.grey8C.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    expense['physical_quantity']?.toString() ?? '0',
                    style: montserratMedium.copyWith(
                      fontSize: 12,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
