import 'dart:io';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/date_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controller/report_summary_controller.dart';

class MostStationSalesItem extends StatelessWidget {
  String? name;
  final int selectedTabIndex;
  MostStationSalesItem({this.name, required this.selectedTabIndex});

  // final controller = Get.put(ReportSummeryController());
  final controller = Get.find<ReportSummeryController>();

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
          DateFormat('dd_MM_yyyy').format(controller.stationFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.stationToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = '${name ?? "Station"} Sales ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Food Name',
        'Count',
        'Amount',
        'Station',
        'Category',
        'Variation',
        'Addon',
        'GST',
        'VAT',
        "Discount",
        'Total Amount'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      for (int i = 0; i < controller.allStationSalesDataDetails.length; i++) {
        var item = controller.allStationSalesDataDetails[i];
        List<dynamic> rowData = [
          item['name']?.toString() ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          double.tryParse(
              item['item_price']?.toString().replaceAll(',', '') ?? '0.00'),
          item['station']?.toString() ?? '',
          item['category']?.toString() ?? '',
          double.tryParse(item['variation_price']?.toString() ?? '0'),
          double.tryParse(item['add_on_price']?.toString() ?? '0'),
          double.tryParse(item['gst_tax_amount']?.toString() ?? '0'),
          double.tryParse(item['vat_tax_amount']?.toString() ?? '0'),
          double.tryParse(item['discount_on_food']?.toString() ?? '0'),
          Get.find<AuthController>()
                      .profileModel
                      ?.restaurants
                      ?.first
                      .resturantType ==
                  'Restaurant'
              ? double.tryParse(
                  item['price']?.toString().replaceAll(',', '') ?? '0.00')
              : '0.00',
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString());
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Commented-out total row logic preserved as-is
      // if (controller.allStationSalesDataDetail.value != null) {
      //   int rowIndex = controller.allStationSalesDataDetails.length + 2;
      //   final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
      //   boldStyle.hAlign = xlsio.HAlignType.center;
      //   boldStyle.vAlign = xlsio.VAlignType.center;
      //   boldStyle.bold = true;
      //
      //   Map<String, String> total = {
      //     'Amount': controller.allStationSalesDataDetail['total_price'],
      //     // 'Gst Amount': grandTotal.gstAmount,
      //     // 'Service Tax': grandTotal.serviceTax,
      //     // 'Delivery Charge': grandTotal.deliveryCharge,
      //     // 'Tip Amount': grandTotal.tipAmount,
      //   };
      //   total.forEach((header, value) {
      //     int ColumnIndex = headers.indexOf(header);
      //     if (ColumnIndex != -1) {
      //       String columnLetter = String.fromCharCode(65 + ColumnIndex);
      //       sheet.getRangeByName('$columnLetter$rowIndex').setText('Total = ${value}');
      //       sheet.getRangeByName('$columnLetter$rowIndex').cellStyle = boldStyle;
      //     }
      //   });
      // }
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: '${name ?? "Station"}_Sales_${fromDate}_to_${toDate}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller.stationFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.stationToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = '${name ?? "Station"} Sales ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Food Name',
        'Count',
        'Amount',
        'Station',
        'Category',
        'Variation',
        'Addon',
        'GST',
        'VAT',
        "Discount",
        'Total Amount'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        sheet.autoFitColumn(col + 1);
      }

      for (int i = 0; i < controller.allStationSalesDataDetails.length; i++) {
        var item = controller.allStationSalesDataDetails[i];
        List<dynamic> rowData = [
          item['name']?.toString() ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          Get.find<AuthController>()
                      .profileModel
                      ?.restaurants
                      ?.first
                      .resturantType ==
                  'Restaurant'
              ? double.tryParse(
                  item['price']?.toString().replaceAll(',', '') ?? '0.00')
              : '0.00',
          item['station']?.toString() ?? '',
          item['category']?.toString() ?? '',
          double.tryParse(item['variation_price']?.toString() ?? '0'),
          double.tryParse(item['add_on_price']?.toString() ?? '0'),
          double.tryParse(item['gst_tax_amount']?.toString() ?? '0'),
          double.tryParse(item['vat_tax_amount']?.toString() ?? '0'),
          double.tryParse(item['discount_on_food']?.toString() ?? '0'),
          double.tryParse(
              item['item_price']?.toString().replaceAll(',', '') ?? '0.00')
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is int || value is double) {
            cell.number = double.tryParse(value.toString());
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Commented-out total row logic preserved as-is
      // if (controller.allStationSalesDataDetail.value != null) {
      //   int rowIndex = controller.allStationSalesDataDetails.length + 2;
      //   final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
      //   boldStyle.hAlign = xlsio.HAlignType.center;
      //   boldStyle.vAlign = xlsio.VAlignType.center;
      //   boldStyle.bold = true;
      //
      //   Map<String, String> total = {
      //     'Amount': controller.allStationSalesDataDetail['total_price'],
      //     // 'Gst Amount': grandTotal.gstAmount,
      //     // 'Service Tax': grandTotal.serviceTax,
      //     // 'Delivery Charge': grandTotal.deliveryCharge,
      //     // 'Tip Amount': grandTotal.tipAmount,
      //   };
      //   total.forEach((header, value) {
      //     int ColumnIndex = headers.indexOf(header);
      //     if (ColumnIndex != -1) {
      //       String columnLetter = String.fromCharCode(65 + ColumnIndex);
      //       sheet.getRangeByName('$columnLetter$rowIndex').setText('Total = ${value}');
      //       sheet.getRangeByName('$columnLetter$rowIndex').cellStyle = boldStyle;
      //     }
      //   });
      // }
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "${name ?? 'Station'}_Sales_${fromDate}_to_${toDate}.xlsx";
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
    // controller.stationSalesRevenueReportDetails(
    //     controller.stationListSelectedDetails.value, name!);
    // String initialDate = DateFormat('d-M-yyyy').format(DateTime.now());
    // controller.fromDate.value = DateTime.now();
    // controller.toDate.value = DateTime.now();
    // Trigger initial fetch
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.stationSalesRevenueReportDetails(
    //       0, ''); // Initial fetch for 'D' tab
    // });
    //  controller.stationSalesRevenueReportDetails(
    //       controller.stationListSelectedDetails.value, name!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.stationListSelectedDetails.value = selectedTabIndex;
      if (!controller.isStationCustomDateRange.value) {
        controller.setDateRange(controller.reportList[selectedTabIndex],
            section: 'station');
      }
      controller.stationSalesRevenueReportDetails(selectedTabIndex, name!);
    });
    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.resetFilterStationSales();
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
              "$name ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.redColor,
              ),
            ),
            Text(
              "Sales",
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
          DateFilterWidget(
            controller: controller,
            section: 'station',
            onDateChanged: (formattedDate) {
              controller.isStationCustomDateRange.value = true;
              controller.stationSalesRevenueReportDetails(
                  controller.stationListSelectedDetails.value, name ?? '');
            },
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
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
                            controller.stationListSelectedDetails.value = index;
                            controller.setDateRange(
                                controller.reportList[index],
                                section: 'station');
                            controller.isStationCustomDateRange.value = false;
                            controller.stationSalesRevenueReportDetails(
                                index, name!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  controller.stationListSelectedDetails.value ==
                                          index
                                      ? ColorTheme.blueColor
                                      : ColorTheme.whiteColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 7),
                              child: Text(
                                controller.reportList[index],
                                style: TextStyle(
                                  color: controller.stationListSelectedDetails
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
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  if (controller.isLoadingStationSalesDetails.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.allStationSalesDataDetails.isEmpty) {
                    return const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorTheme.greyColor,
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 15,
                        dataRowHeight: 70,
                        horizontalMargin: 0,
                        border: TableBorder(
                            verticalInside: BorderSide(
                                color: ColorTheme.greyColor.withOpacity(0.5))),
                        showBottomBorder: true,
                        columns: const [
                          DataColumn(
                            label: Expanded(
                              flex: 6,
                              child: Text(
                                "Food Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Count",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorTheme.blueColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorTheme.blueColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: controller.allStationSalesDataDetails.map((item) {
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
                                        item['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: ColorTheme.greyColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    item['quantity'].toString(),
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
                                        ? item['price'].toString()
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
