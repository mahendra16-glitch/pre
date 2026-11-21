import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:url_launcher/url_launcher.dart';

class WastageReportScreen extends StatefulWidget {
  const WastageReportScreen({Key? key}) : super(key: key);

  @override
  State<WastageReportScreen> createState() => _WastageReportScreenState();
}

class _WastageReportScreenState extends State<WastageReportScreen> {
  InventoryController? inventoryController;
  String? selectedWasteType = 'Loss';

  @override
  void initState() {
    super.initState();
    inventoryController = Get.find<InventoryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchWastageReport();
    });
  }

  /// Initialize default date range (current month)
  void _initializeDatesAndData() {
    inventoryController?.wastageRecords = [];
    inventoryController?.wastageSummary = {
      'total_records': 0,
      'total_loss': 0.0,
      'total_gain': 0.0,
      'net_wastage': 0.0,
    };
    inventoryController?.update();
    final now = DateTime.now();
    inventoryController?.wastageStartDate =
        DateFormat('dd-MM-yyyy').format(now);
    inventoryController?.wastageEndDate = DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch wastage report data
  void _fetchWastageReport() async {
    if (inventoryController?.wastageStartDate != null &&
        inventoryController?.wastageEndDate != null) {
      await inventoryController?.getWastageReport(
        startDate: inventoryController!.wastageStartDate!,
        endDate: inventoryController!.wastageEndDate!,
        wasteType: selectedWasteType ?? 'Loss',
      );
    }
  }

  /// Export current wastage report to Excel
  Future<void> _exportWastageToExcel() async {
    try {
      final records = inventoryController?.wastageRecords ?? [];
      final summary = inventoryController?.wastageSummary ?? {};
      final totalLoss = (summary['total_loss'] ?? 0).toString();

      // Create workbook and sheet
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      final start = inventoryController?.wastageStartDate ?? '';
      final end = inventoryController?.wastageEndDate ?? '';
      sheet.name = 'Wastage Report $start to $end';

      // Centered style
      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Bold style (for totals)
      final xlsio.Style boldStyle = workbook.styles.add('bold');
      boldStyle.hAlign = xlsio.HAlignType.center;
      boldStyle.vAlign = xlsio.VAlignType.center;
      boldStyle.bold = true;

      // Headers (underscore removed and title-cased)
      final List<String> headers = [
        // 'Wastage Id',
        // 'Food Id',
        'Item Name',
        'Item Type',
        'Waste Type',
        // 'Previous Stock',
        'Wastage Quantity',
        'Unit',
        // 'Wastage Value',
        'Waste Reason',
        'Waste Date',
        // 'Created At',
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
      }

      // Rows
      int rowIndex = 2;
      for (final rec in records) {
        final List<dynamic> rowData = [
          // rec['wastage_id'] ?? '',
          // rec['food_id'] ?? '',
          rec['item_name'] ?? '',
          rec['item_type'] ?? '',
          rec['waste_type'] ?? '',
          // rec['previous_stock'] ?? '',
          rec['wastage_quantity'] ?? '',
          rec['unit'] ?? '',
          // rec['wastage_value'] ?? '',
          rec['waste_reason'] ?? '',
          _formatDate(rec['waste_date']?.toString()),
          // _formatDate(rec['created_at']?.toString()),
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
          final value = rowData[col];
          // Try to write numbers as numbers when applicable
          final parsed = double.tryParse(value?.toString() ?? '');
          if (parsed != null &&
              col != 2 &&
              col != 9 &&
              col != 10 &&
              col != 11) {
            cell.number = parsed;
          } else {
            cell.setText(value?.toString() ?? '');
          }
          cell.cellStyle = cellStyle;
        }
        rowIndex++;
      }

      // Add Total Loss in the "Wastage Quantity" column (7th header -> index 6)
      final int wastageQtyColIndex = headers.indexOf('Wastage Quantity');
      if (wastageQtyColIndex != -1) {
        String columnLetter = String.fromCharCode(65 + wastageQtyColIndex);
        sheet
            .getRangeByName('$columnLetter${rowIndex + 1}')
            .setText('Total = $totalLoss');
        sheet.getRangeByName('$columnLetter${rowIndex + 1}').cellStyle =
            boldStyle;
      }

      // Auto-fit columns
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save flow: Windows → Save dialog; Others → temp/app dir and open
      String fileName =
          'Wastage_Report_${start.replaceAll('-', '_')}_to_${end.replaceAll('-', '_')}.xlsx';

      if (Platform.isWindows) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Excel File',
          fileName: fileName,
        );
        if (outputFile == null) return;
        final List<int> bytes = workbook.saveAsStream();
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        final fileUri = Uri.file(outputFile);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          await openFilex.OpenFile.open(outputFile);
        }
      } else {
        final dir = await getTemporaryDirectory();
        final outputPath = '${dir.path}/$fileName';
        final List<int> bytes = workbook.saveAsStream();
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        await openFilex.OpenFile.open(outputPath);
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
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleWidget: Text(
            'Wastage Report',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Wastage Report',
          actions: [
            IconButton(
              tooltip: 'Export to Excel',
              onPressed: _exportWastageToExcel,
              icon: Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 30,
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchWastageReport,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
          ],
        ),
        body: GetBuilder<InventoryController>(
          builder: (controller) => Column(
            children: [
              SizedBox(height: 10),
              // Date Filter Section
              _buildDateFilterSection(),
              // Divider(color: ColorTheme.black, height: 2),

              _buildSearchBar(),

              // // Waste Type Filter
              // _buildWasteTypeFilter(),
              // Divider(color: ColorTheme.grey8C.withOpacity(.4), height: 1),

              // Summary Cards
              // _buildSummaryCards(),

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
      // color: ColorTheme.whiteColor,
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  inventoryController?.wastageStartDate,
                );
                if (picked != null) {
                  inventoryController?.wastageStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  inventoryController?.update();
                  _fetchWastageReport();
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
                      inventoryController?.wastageStartDate ?? 'DD-MM-YYYY',
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
                  inventoryController?.wastageEndDate,
                );
                if (picked != null) {
                  inventoryController?.wastageEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  inventoryController?.update();
                  _fetchWastageReport();
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
                      inventoryController?.wastageEndDate ?? 'DD-MM-YYYY',
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

  /// Build waste type filter dropdown
  Widget _buildWasteTypeFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: ColorTheme.whiteColor,
      child: Row(
        children: [
          Text(
            'Waste Type:',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: ColorTheme.black5F6368,
              fontWeight: FontWeight.w600,
            ),
          ),
          15.width,
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedWasteType,
                isExpanded: true,
                underline: SizedBox.shrink(),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: ColorTheme.black5F6368,
                ),
                items: ['Loss', 'Gain'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedWasteType = newValue;
                  });
                  _fetchWastageReport();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary cards showing total records, loss, gain, and net wastage
  Widget _buildSummaryCards() {
    final summary = inventoryController?.wastageSummary;
    if (summary == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Records',
              summary['total_records']?.toString() ?? '0',
              ColorTheme.appColor,
            ),
          ),
          10.width,
          Expanded(
            child: _buildSummaryCard(
              'Total Loss',
              summary['total_loss']?.toStringAsFixed(2) ?? '0.00',
              Colors.red,
            ),
          ),
          10.width,
          Expanded(
            child: _buildSummaryCard(
              'Total Gain',
              summary['total_gain']?.toStringAsFixed(2) ?? '0.00',
              Colors.green,
            ),
          ),
          10.width,
          Expanded(
            child: _buildSummaryCard(
              'Net Wastage',
              summary['net_wastage']?.toStringAsFixed(2) ?? '0.00',
              ColorTheme.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual summary card
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: ColorTheme.black5F6368.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          8.height,
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: (Platform.isAndroid || Platform.isIOS) ? 13 : 16,
              color: color,
              fontWeight: FontWeight.w700,
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
          // Name Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Wastage Column
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
                'Wastage',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Stock Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Reason',
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
    if (inventoryController?.isWastageReportLoading ?? false) {
      return AppLoader();
    }

    final search =
        inventoryController?.searchWastageReport.text.trim().toLowerCase() ??
            '';

    final wastageRecords =
        (inventoryController?.wastageRecords ?? []).where((item) {
      // Search Filter
      final name = item['item_name']?.toString().toLowerCase() ?? '';
      final searchMatch = name.contains(search);

      // Type Filter
      final type = item['item_type']?.toString().toLowerCase() ?? '';
      bool typeMatch = true;

      if (inventoryController?.selectedItemType == "ingredient") {
        typeMatch = type == "ingredient";
      } else if (inventoryController?.selectedItemType == "subrecipe") {
        typeMatch = type == "subrecipe";
      }

      return searchMatch && typeMatch;
    }).toList();

    if (wastageRecords.isEmpty) {
      return Center(
        child: Text(
          'No wastage records found',
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
        itemCount: wastageRecords.length,
        itemBuilder: (context, index) {
          final record = wastageRecords[index];
          return _buildTableRow(record);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> record) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Column - item_name, item_type, unit
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['item_name']?.toString() ?? '',
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
                    'Type: ${record['item_type']?.toString() ?? ''}',
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
          // Wastage Column - wastage_quantity, waste_type
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
                    record['wastage_quantity']?.toString() ?? '0',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  4.height,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      // border: Border.all(
                      //   color: (record['waste_type']?.toString() ?? 'Loss') ==
                      //           'Loss'
                      //       ? Colors.red.withOpacity(0.5)
                      //       : Colors.green.withOpacity(0.5),
                      // ),
                    ),
                    child: Text(
                      'Unit: ${record['unit']?.toString() ?? ''}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stock Column - previous_stock, created_at, waste_date
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   'Prev: ${record['previous_stock']?.toString() ?? '0'}',
                  //   style: TextStyle(
                  //     fontFamily: 'Montserrat',
                  //     fontSize: 12,
                  //     color: ColorTheme.black5F6368,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),
                  // 4.height,
                  Text(
                    '${record['waste_reason']?.toString() ?? ''}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: ColorTheme.black5F6368,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event,
                        size: 14,
                        color: ColorTheme.black5F6368,
                      ),
                      6.width,
                      Text(
                        '${_formatDate(record['waste_date']?.toString())}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          color: ColorTheme.black5F6368,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // 2.height,
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.access_time,
                  //       size: 14,
                  //       color: ColorTheme.black5F6368,
                  //     ),
                  //     6.width,
                  //     Text(
                  //       '${_formatDate(record['created_at']?.toString())}',
                  //       style: TextStyle(
                  //         fontFamily: 'Montserrat',
                  //         fontSize: 10.5,
                  //         color: ColorTheme.black5F6368,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: TextField(
              controller: inventoryController?.searchWastageReport,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search by name...",
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
                // setState(() {}); // refresh UI
                inventoryController?.update();
              },
            ),
          ),

          SizedBox(width: 10),

          // FILTER ICON
          PopupMenuButton<String>(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            menuPadding: EdgeInsets.all(10),
            tooltip: 'Item Type Filter',
            position: PopupMenuPosition.under,
            icon: Icon(Icons.filter_list, size: 28, color: ColorTheme.blue),
            onSelected: (value) {
              inventoryController?.selectedItemType =
                  value; // store filter value
              inventoryController?.update();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "all",
                child: Text(
                  "All",
                  style: montserratMedium.copyWith(
                      fontSize: 15, color: ColorTheme.grey8C),
                ),
              ),
              PopupMenuItem(
                value: "ingredient",
                child: Text("Ingredient",
                    style: montserratMedium.copyWith(
                        fontSize: 15, color: ColorTheme.grey8C)),
              ),
              PopupMenuItem(
                value: "subrecipe",
                child: Text("Sub Recipe",
                    style: montserratMedium.copyWith(
                        fontSize: 15, color: ColorTheme.grey8C)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
