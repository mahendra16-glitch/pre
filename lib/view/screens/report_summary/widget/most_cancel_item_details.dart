import 'package:file_picker/file_picker.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart' as openFilex;
// import 'package:excel/excel.dart' as excel; // Added for Excel file creation
import 'package:path_provider/path_provider.dart'; // Added for storage path
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import 'dart:io'; // Added for File handling
// import 'package:open_file/open_file.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class MostCancelItemDetails extends StatelessWidget {
  final String? orderId;
  final String? foodName;
  ReportSummeryController? controller;

  MostCancelItemDetails(
      {required this.orderId, required this.foodName, this.controller});

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
          DateFormat('dd_MM_yyyy').format(controller!.cancelledFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller!.cancelledToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Cancelled Items $fromDate to $toDate';

      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.hAlign = xlsio.HAlignType.center;
      headerStyle.vAlign = xlsio.VAlignType.center;
      headerStyle.bold = true;

      final xlsio.Style cellStyle = workbook.styles.add('cellStyle');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Headers
      List<String> headers = [
        'Food Name',
        'Category',
        'Order ID',
        'Waiter',
        'Cancel Date',
        'Quantity',
        'Price',
        'Cancellation Reason'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = headerStyle;
        sheet.autoFitColumn(col + 1);
      }

      // Filter data for this specific order and food item
      final filteredList = controller!.topCancelledItems.where((item) {
        return item['other_detail'] != null &&
            item['other_detail'].isNotEmpty &&
            item['other_detail'][0]['order_id'].toString() == orderId &&
            item['food_item'] == foodName;
      }).toList();

      int rowIndex = 2;
      for (var item in filteredList) {
        final otherDetails = item['other_detail'] as List<dynamic>;

        for (var detail in otherDetails) {
          List<dynamic> rowData = [
            item['food_item']?.toString() ?? '',
            detail['category_name']?.toString() ?? '',
            detail['restaurant_order_id']?.toString() ?? '',
            detail['waiter_name']?.toString() ?? '',
            _formatDateTime(detail['cancel_date'], onlyDate: false),
            double.tryParse(detail['quantity']?.toString() ?? '0') ?? 0,
            double.tryParse(
                    item['price']?.toString().replaceAll(',', '') ?? '0.00') ??
                0.00,
            detail['cancel_reason']?.toString().isEmpty ?? true
                ? 'Not Specified'
                : detail['cancel_reason'].toString(),
          ];

          for (int col = 0; col < rowData.length; col++) {
            final cell = sheet
                .getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
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
      }

      // Auto-fit all columns
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Cancelled_Items_${foodName}_${fromDate}_to_${toDate}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller!.cancelledFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller!.cancelledToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();

      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Cancelled Items $fromDate to $toDate';

      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.hAlign = xlsio.HAlignType.center;
      headerStyle.vAlign = xlsio.VAlignType.center;
      headerStyle.bold = true;

      final xlsio.Style cellStyle = workbook.styles.add('cellStyle');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      // Headers
      List<String> headers = [
        'Food Name',
        'Category',
        'Order ID',
        'Waiter',
        'Cancel Date',
        'Quantity',
        'Price',
        'Cancellation Reason'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = headerStyle;
        sheet.autoFitColumn(col + 1);
      }

      // Filter data for this specific order and food item
      final filteredList = controller!.topCancelledItems.where((item) {
        return item['other_detail'] != null &&
            item['other_detail'].isNotEmpty &&
            item['other_detail'][0]['order_id'].toString() == orderId &&
            item['food_item'] == foodName;
      }).toList();

      int rowIndex = 2;
      for (var item in filteredList) {
        final otherDetails = item['other_detail'] as List<dynamic>;

        for (var detail in otherDetails) {
          List<dynamic> rowData = [
            item['food_item']?.toString() ?? '',
            detail['category_name']?.toString() ?? '',
            detail['restaurant_order_id']?.toString() ?? '',
            detail['waiter_name']?.toString() ?? '',
            _formatDateTime(detail['cancel_date'], onlyDate: false),
            double.tryParse(detail['quantity']?.toString() ?? '0') ?? 0,
            double.tryParse(
                    item['price']?.toString().replaceAll(',', '') ?? '0.00') ??
                0.00,
            detail['cancel_reason']?.toString().isEmpty ?? true
                ? 'Not Specified'
                : detail['cancel_reason'].toString(),
          ];

          for (int col = 0; col < rowData.length; col++) {
            final cell = sheet
                .getRangeByName('${String.fromCharCode(65 + col)}$rowIndex');
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
      }

      // Auto-fit all columns
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Cancelled_Items_${foodName}_${fromDate}_to_${toDate}.xlsx";
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
              "Could not open file. Please ensure a compatible app (like Microsoft Excel or Google Sheets) is installed, or open it manually from Downloads folder.",
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
    if (controller == null) {
      // controller = Get.put(ReportSummeryController());
      controller = Get.find<ReportSummeryController>();
    }

    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
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
              "Cancel  ",
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
          Icon(Icons.print_outlined, size: 28, color: Color(0xFFC6C6C6)),
          SizedBox(width: 10),
          InkWell(
              hoverColor: Colors.grey.shade100,
              customBorder: CircleBorder(),
              onTap: () {
                exportToExcel();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    SizedBox(width: 25, child: SvgPicture.asset(Images.export)),
              )),
          // SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Icons.sync,
              size: 28,
              color: Color(0xFFC6C6C6),
            ),
            onPressed: () {},
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: ColorTheme.grey200Color,
            child: GestureDetector(
              onTap: () {
                controller!.isExpanded2.value = !controller!.isExpanded2.value;
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Obx(
                  () {
                    if (controller!.isLoadingTopCancelledItems.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredList =
                        controller!.topCancelledItems.where((item) {
                      return item['other_detail'] != null &&
                          item['other_detail'].isNotEmpty &&
                          item['other_detail'][0]['order_id'].toString() ==
                              orderId &&
                          item['food_item'] == foodName;
                    }).toList();

                    String cancelDate = '';
                    String price = '0.00';

                    if (filteredList.isNotEmpty) {
                      final item = filteredList.first;
                      cancelDate = _formatDateTime(
                          item['other_detail'][0]['cancel_date'],
                          onlyDate: true);
                      price = '₹${item['price']}';
                    }

                    return Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Total Cancellation',
                              style: poppinsSemiBold.copyWith(
                                color: ColorTheme.blueColor,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              cancelDate,
                              style: poppinsMedium.copyWith(
                                color: Color(0xFF828282),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: poppinsSemiBold.copyWith(
                            color: ColorTheme.greenColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  if (controller!.isLoadingTopCancelledItems.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredList =
                      controller!.topCancelledItems.where((item) {
                    return item['other_detail'] != null &&
                        item['other_detail'].isNotEmpty &&
                        item['other_detail'][0]['order_id'].toString() ==
                            orderId &&
                        item['food_item'] == foodName;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return const Center(child: Text("No data available"));
                  }

                  final item = filteredList.first;
                  final otherDetails = item['other_detail'] as List<dynamic>;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 15,
                        dataRowHeight: 70,
                        horizontalMargin: 0,
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                          verticalInside: BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                          bottom:
                              BorderSide(color: Color(0xFFE4E4E4), width: 2),
                          top: BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                        ),
                        showBottomBorder: true,
                        columns: [
                          DataColumn(
                            label: Expanded(
                              flex: 7,
                              child: Text(
                                "Item",
                                style: poppinsSemiBold.copyWith(
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              flex: 2,
                              child: Text(
                                "Count",
                                style: poppinsSemiBold.copyWith(
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: otherDetails.map<DataRow>((otherDetail) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 5),
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            '${item['food_item']}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: poppinsSemiBold.copyWith(
                                              fontSize: 15,
                                              color: Color(0xFF2E2E2E),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              '${otherDetail['category_name']}',
                                              style: poppinsSemiBold.copyWith(
                                                fontSize: 12,
                                                color: Color(0xFF0090FF),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Container(
                                                height: 13,
                                                width: 1,
                                                color: Color(0xFF828282),
                                              ),
                                            ),
                                            Text(
                                              otherDetail['restaurant_order_id']
                                                  .toString(),
                                              style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              otherDetail['waiter_name'],
                                              style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Container(
                                                height: 13,
                                                width: 1,
                                                color: Color(0xFF828282),
                                              ),
                                            ),
                                            Text(
                                              _formatDateTime(
                                                  otherDetail['cancel_date']),
                                              style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DailySalesOrderDetails(
                                              orderId: otherDetail['order_id']
                                                  .toString(),
                                              controller: controller!,
                                            ),
                                          ),
                                        );
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
                                    otherDetail['quantity'].toString(),
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

  String _formatDateTime(String? dateTime, {onlyDate = false}) {
    if (dateTime == null) return '';
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return onlyDate
          ? DateFormat('dd MMM yyyy').format(parsedDate)
          : DateFormat('dd MMM yyyy | HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  Widget buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ColorTheme.greyColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ColorTheme.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
