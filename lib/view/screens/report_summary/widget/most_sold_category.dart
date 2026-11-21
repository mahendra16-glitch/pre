import 'dart:io';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/category_detail.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/date_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../../../../controller/report_summary_controller.dart';
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MostSoldCategory extends StatelessWidget {
  final int selectedTabIndex;
  MostSoldCategory({key, required this.selectedTabIndex});
  final ReportSummeryController controller =
      Get.find<ReportSummeryController>();

  Future<void> exportToExcel() async {
    if (Platform.isWindows) {
      await _exportToExcelWindows();
    } else {
      await _exportToExcelMobile();
    }
  }

  Future<void> _exportToExcelWindows() async {
    try {
      final fromDate =
          DateFormat('dd_MM_yyyy').format(controller.categoryFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.categoryToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Most Sold Category Report ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Item',
        'Station',
        'Quantity',
        'AddOn Price',
        'Variation Price',
        'GST',
        'VAT',
        'Discount',
        'Amount',
        'Total Amount'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;

      for (var category in controller.topSalesCategoryList) {
        var details = category['details'] as List<dynamic>? ?? [];

        double totalAddOn = 0;
        double totalVariation = 0;
        double totalGst = 0;
        double totalVat = 0;
        double totalDiscount = 0;
        double totalItemPrice = 0;
        double totalPrice = 0;
        int totalQty = 0;
        String station = "";

        for (var item in details) {
          final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
          totalQty += qty;
          station = item['station']?.toString() ?? '';

          totalAddOn +=
              (double.tryParse(item['add_on_price']?.toString() ?? '0') ?? 0) *
                  qty;
          totalVariation +=
              (double.tryParse(item['variation_price']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalGst +=
              (double.tryParse(item['gst_tax_amount']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalVat +=
              (double.tryParse(item['vat_tax_amount']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalDiscount +=
              (double.tryParse(item['discount_on_food']?.toString() ?? '0') ??
                      0) *
                  qty;

          if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .resturantType ==
              'Restaurant') {
            totalPrice += (double.tryParse(
                        item['item_price']?.toString().replaceAll(',', '') ??
                            '0.00') ??
                    0) *
                qty;

            totalItemPrice += (double.tryParse(
                        item['price']?.toString().replaceAll(',', '') ?? '0') ??
                    0) *
                qty;
          }
        }

        List<dynamic> rowData = [
          category['category_name']?.toString() ?? '',
          station,
          totalQty,
          totalAddOn,
          totalVariation,
          totalGst,
          totalVat,
          totalDiscount,
          totalPrice,
          totalItemPrice,
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString());
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }

        rowIndex++;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Most_Sold_Category_Report_${fromDate}_to_${toDate}.xlsx',
      );

      if (outputFile != null) {
        final List<int> bytes = workbook.saveAsStream();
        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        Get.snackbar(
          "Success",
          "Excel file saved to $outputFile",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorTheme.greenColor,
          colorText: Colors.white,
        );

        final fileUri = Uri.file(outputFile);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          Get.snackbar(
            "Warning",
            "Could not open file. Please open it manually from $outputFile",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.yellowAccent,
            colorText: Colors.black,
            duration: Duration(seconds: 5),
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
        backgroundColor: ColorTheme.redColor,
        colorText: Colors.white,
      );
      print('Failed to save file: $e');
    }
  }

  Future<void> _exportToExcelMobile() async {
    try {
      final fromDate =
          DateFormat('dd_MM_yyyy').format(controller.categoryFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.categoryToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Most Sold Category Report ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Item',
        'Station',
        'Quantity',
        'AddOn Price',
        'Variation Price',
        'GST',
        'VAT',
        'Discount',
        'Amount',
        'Total Amount'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;

      for (var category in controller.topSalesCategoryList) {
        var details = category['details'] as List<dynamic>? ?? [];

        double totalAddOn = 0;
        double totalVariation = 0;
        double totalGst = 0;
        double totalVat = 0;
        double totalDiscount = 0;
        double totalItemPrice = 0;
        double totalPrice = 0;
        int totalQty = 0;
        String station = "";

        for (var item in details) {
          final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
          totalQty += qty;
          station = item['station']?.toString() ?? '';

          totalAddOn +=
              (double.tryParse(item['add_on_price']?.toString() ?? '0') ?? 0) *
                  qty;
          totalVariation +=
              (double.tryParse(item['variation_price']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalGst +=
              (double.tryParse(item['gst_tax_amount']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalVat +=
              (double.tryParse(item['vat_tax_amount']?.toString() ?? '0') ??
                      0) *
                  qty;
          totalDiscount +=
              (double.tryParse(item['discount_on_food']?.toString() ?? '0') ??
                      0) *
                  qty;

          totalItemPrice += (double.tryParse(
                      item['item_price']?.toString().replaceAll(',', '') ??
                          '0') ??
                  0) *
              qty;
          if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .resturantType ==
              'Restaurant') {
            totalPrice += (double.tryParse(
                        item['price']?.toString().replaceAll(',', '') ??
                            '0.00') ??
                    0) *
                qty;
          }
        }

        List<dynamic> rowData = [
          category['category_name']?.toString() ?? '', // Category
          station, // Station (last one or common)
          totalQty, // Total Qty
          totalAddOn,
          totalVariation,
          totalGst,
          totalVat,
          totalDiscount,
          totalPrice,
          totalItemPrice,
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString());
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }

        rowIndex++;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Most_Sold_Category_Report_${fromDate}_to_${toDate}.xlsx";
      final tempPath = "${tempDir.path}/$fileName";
      final file = File(tempPath);

      if (await file.exists()) {
        await file.delete();
      }
      final List<int> bytes = workbook.saveAsStream();
      await file.writeAsBytes(bytes);

      await Future.delayed(Duration(milliseconds: 500));

      if (await file.exists()) {
        print("Temporary file exists at: $tempPath");
        print("File size: ${await file.length()} bytes");
      } else {
        print("Temporary file does not exist at: $tempPath");
        Get.snackbar(
          "Error",
          "Temporary file could not be created. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorTheme.redColor,
          colorText: Colors.white,
        );
        return;
      }

      await Future.delayed(Duration(milliseconds: 1000));

      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        Get.snackbar(
          "Success",
          "Excel file saved to Downloads folder",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorTheme.greenColor,
          colorText: Colors.white,
        );
        print("Excel file saved to Downloads folder: $finalPath");

        final result = await openFilex.OpenFile.open(finalPath);
        if (result.type != openFilex.ResultType.done) {
          print("Could not open final file: ${result.message}");

          final tempResult = await openFilex.OpenFile.open(tempPath);
          if (tempResult.type != openFilex.ResultType.done) {
            Get.snackbar(
              "Warning",
              "Could not open temporary file. Please ensure a compatible app (like Microsoft Excel or Google Sheets) is installed, or open it manually from Downloads folder.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.yellowAccent,
              colorText: Colors.black,
              duration: Duration(seconds: 5),
            );
            print("Could not open temporary file: ${tempResult.message}");
          } else {
            print("Temporary file opened successfully as fallback");
          }
        } else {
          print("Final file opened successfully");
        }
      } else {
        Get.snackbar(
          "Info",
          "File save canceled by user. Opening temporary file.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        print("File save canceled by user. Temporary file saved at: $tempPath");

        final result = await openFilex.OpenFile.open(tempPath);
        if (result.type != openFilex.ResultType.done) {
          Get.snackbar(
            "Warning",
            "Could not open file. Please ensure a compatible app (like Microsoft Excel or Google Sheets) is installed, or open it manually.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.yellowAccent,
            colorText: Colors.black,
            duration: Duration(seconds: 5),
          );
          print("Could not open temporary file: ${result.message}");
        } else {
          print("Temporary file opened successfully");
        }
      }

      workbook.dispose();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save file: $e. Please ensure storage permissions are granted in your device settings.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorTheme.redColor,
        colorText: Colors.white,
      );
      print('Failed to save file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize default date
    // String initialDate = DateFormat('d-M-yyyy').format(DateTime.now());
    // controller.fromDate.value = DateTime.now();
    // controller.toDate.value = DateTime.now();
    // Trigger initial fetch
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.topSoldCategory(controller.topSoldListCategorySelected.value); // Initial fetch for 'D' tab
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.topSoldListCategorySelected.value = selectedTabIndex;
      if (!controller.isCategoryCustomDateRange.value) {
        controller.setDateRange(controller.reportList[selectedTabIndex],
            section: 'category');
      }
      controller.topSoldCategory(selectedTabIndex);
    });
    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.resetFilterTopCategory();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.redColor,
            size: 22,
          ),
        ),
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              "Category ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.redColor,
              ),
            ),
            Text(
              "Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.greenColor,
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.print_outlined,
          //       color: Color(0xFFC6C6C6),
          //       size: 28,
          //     )),
          // SizedBox(
          //   width: 8,
          // ),
          InkWell(
              onTap: () {
                exportToExcel();
              },
              child:
                  SizedBox(width: 25, child: SvgPicture.asset(Images.export))),
          SizedBox(
            width: 8,
          ),
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.sync,
          //       color: Color(0xFFC6C6C6),
          //       size: 28,
          //     )),
          // SizedBox(
          //   width: 8,
          // ),
        ],
      ),
      body: Column(
        children: [
          // Add Date Filter
          DateFilterWidget(
            controller: controller,
            section: 'category',
            onDateChanged: (formattedDate) {
              controller.isCategoryCustomDateRange.value = true;
              controller.topSoldCategory(
                  controller.topSoldListCategorySelected.value);
            },
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: ColorTheme.whiteColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    controller.reportList.length,
                    (index) {
                      return GestureDetector(
                        onTap: () {
                          controller.topSoldListCategorySelected.value = index;
                          controller.setDateRange(controller.reportList[index],
                              section: 'category');
                          controller.topSoldCategory(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: controller
                                          .topSoldListCategorySelected.value ==
                                      index
                                  ? ColorTheme.blueColor
                                  : ColorTheme.whiteColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 7),
                            child: Text(
                              controller.reportList[index],
                              style: TextStyle(
                                color: controller.topSoldListCategorySelected
                                            .value ==
                                        index
                                    ? ColorTheme.whiteColor
                                    : ColorTheme.greyColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Obx(
                () {
                  if (controller.isLoadingCategory.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (controller.topSalesCategoryList.value.isEmpty) {
                    return const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(
                            fontSize: 16, color: ColorTheme.greyColor),
                      ),
                    );
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 15,
                        dataRowHeight: 55,
                        horizontalMargin: 0,
                        border: TableBorder(
                            verticalInside: BorderSide(
                                color: Colors.grey.withOpacity(0.5))),
                        showBottomBorder: true,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Item",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.blueColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                "Sold",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: controller.topSalesCategoryList.value.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          AppConstants.networkImage),
                                      radius: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item['category_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: ColorTheme.greyColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Get.to(() => CategoryDetails(
                                            name: item['category_name'],
                                            id: item['category_id'],
                                            selectedTabIndex: controller
                                                .topSoldListCategorySelected
                                                .value));
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: ColorTheme.greyColor,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    item['total_quantity'].toString(),
                                    style: const TextStyle(
                                      color: ColorTheme.greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .resturantType ==
                                            'Restaurant'
                                        ? item['total_sales'].toString()
                                        : '0.00',
                                    style: const TextStyle(
                                      color: ColorTheme.greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
