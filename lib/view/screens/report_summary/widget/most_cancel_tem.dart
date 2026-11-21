import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/date_filter_widget.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/most_cancel_item_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:excel/excel.dart' as excel; // Added for Excel file creation
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart'; // Added for storage path
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import 'dart:io'; // Added for File handling
// import 'package:open_file/open_file.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../../../../controller/report_summary_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MostCancelItems extends StatelessWidget {
  final int selectedTabIndex;
  MostCancelItems({key, required this.selectedTabIndex});
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
          DateFormat('dd_MM_yyyy').format(controller.cancelledFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.cancelledToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Most Cancelled Items Report ${fromDate} to ${toDate} ${controller.selectedReasons.value} ${controller.selectedWaiter.value} ${controller.selectedCancelReasons.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = ['Food Name', 'Count', 'Amount'];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        sheet.autoFitColumn(col + 1);
      }

      for (int i = 0; i < controller.filteredTopCancelItemList.length; i++) {
        var item = controller.filteredTopCancelItemList[i];
        List<dynamic> rowData = [
          item['food_item']?.toString() ?? '',
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

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName:
            'Most_Cancelled_Items_Report_${fromDate}_to_${toDate}_${controller.selectedReasons.value}_${controller.selectedWaiter.value}_${controller.selectedCancelReasons.value}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller.cancelledFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.cancelledToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();

      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Most Cancelled Items Report ${fromDate} to ${toDate} ${controller.selectedReasons.value} ${controller.selectedWaiter.value} ${controller.selectedCancelReasons.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Food Name',
        'Count',
        'Amount',
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        sheet.autoFitColumn(col + 1);
      }

      for (int i = 0; i < controller.filteredTopCancelItemList.length; i++) {
        var item = controller.filteredTopCancelItemList[i];
        List<dynamic> rowData = [
          item['food_item']?.toString() ?? '',
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

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Most_Cancelled_Items_Report_${fromDate}_to_${toDate}_${controller.selectedReasons.value}_${controller.selectedWaiter.value}_${controller.selectedCancelReasons.value}.xlsx";
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
          // Get.snackbar(
          //   "Warning",
          //   "Could not open file from Downloads. Trying to open temporary file instead.",
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.yellowAccent,
          //   colorText: Colors.black,
          //   duration: Duration(seconds: 5),
          // );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.topCancelledItemsSelect.value = selectedTabIndex;
      if (!controller.isCancelledCustomDateRange.value) {
        controller.setDateRange(controller.reportList[selectedTabIndex],
            section: 'cancelled');
      }
      controller.topCancelItems(selectedTabIndex);
    });
    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.resetFilterCancelItems();
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
              "Cancel ",
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
          IconButton(
              onPressed: () {
                controller.exportFoodCancelReasonWiseList({
                  'from': DateFormat('yyyy-MM-dd')
                      .format(controller.cancelledFromDate.value),
                  'to': DateFormat('yyyy-MM-dd')
                      .format(controller.cancelledToDate.value)
                });
              },
              icon: Icon(
                Icons.file_present,
                color: Color(0xFFC6C6C6),
                size: 28,
              )),
          SizedBox(
            width: 8,
          ),
          Tooltip(
            message: 'Download Cancel Report',
            child: InkWell(
                hoverColor: Colors.grey.shade100,
                customBorder: CircleBorder(),
                onTap: () {
                  exportToExcel();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 25, child: SvgPicture.asset(Images.export)),
                )),
          ),
          SizedBox(
            width: 8,
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.sync,
                color: Color(0xFFC6C6C6),
                size: 28,
              )),
          SizedBox(
            width: 8,
          ),
        ],
      ),
      body: Column(
        children: [
          DateFilterWidget(
            controller: controller,
            section: 'cancelled',
            onDateChanged: (formattedDate) {
              controller.isCategoryCustomDateRange.value = true;
              controller
                  .topCancelItems(controller.topCancelledItemsSelect.value);
            },
            isFilterIcon: true,
          ),
          // const SizedBox(height: 15),
          // Date Picker Container
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 5),
          //   decoration: BoxDecoration(
          //     border: Border(
          //       top: BorderSide(color: Colors.white),
          //       bottom: BorderSide(color: Color(0xFFE4E4E4)),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       /// From Date
          //       Expanded(
          //         child: Container(
          //           padding: const EdgeInsets.only(right: 16, left: 10),
          //           // decoration: BoxDecoration(
          //           //   border: Border(
          //           //     right: BorderSide(color: Color(0xFFE4E4E4), width: 2),
          //           //   ),
          //           // ),
          //           child: Row(
          //             children: [
          //               Expanded(
          //                 child: Obx(() => TextField(
          //                       controller: TextEditingController(
          //                           text: DateFormat('dd/MM/yyyy')
          //                               .format(controller.fromDate.value)),
          //                       decoration: const InputDecoration(
          //                         isDense: true,
          //                         contentPadding:
          //                             EdgeInsets.symmetric(vertical: 8),
          //                         enabledBorder: UnderlineInputBorder(
          //                           borderSide:
          //                               BorderSide(color: Colors.transparent),
          //                         ),
          //                         focusedBorder: UnderlineInputBorder(
          //                           borderSide:
          //                               BorderSide(color: Colors.transparent),
          //                         ),
          //                       ),
          //                       style: poppinsMedium.copyWith(
          //                           color: ColorTheme.greyColor, fontSize: 16),
          //                       readOnly: true,
          //                       onTap: () async {
          //                         DateTime? picked = await showDatePicker(
          //                           context: context,
          //                           initialDate: controller.fromDate.value,
          //                           firstDate: DateTime(2000),
          //                           lastDate: DateTime(2100),
          //                           builder: (context, child) {
          //                             return Theme(
          //                               data: ThemeData.light().copyWith(
          //                                 colorScheme: ColorScheme.light(
          //                                   primary: ColorTheme.appColor,
          //                                   onPrimary: Colors.white,
          //                                   onSurface: ColorTheme.greyColor,
          //                                 ),
          //                                 textButtonTheme: TextButtonThemeData(
          //                                   style: TextButton.styleFrom(
          //                                     foregroundColor:
          //                                         ColorTheme.appColor,
          //                                   ),
          //                                 ),
          //                               ),
          //                               child: child!,
          //                             );
          //                           },
          //                         );
          //                         if (picked != null) {
          //                           controller.fromDate.value = picked;
          //                           controller.isCustomDateRange.value = true;
          //                           await controller.topCancelItems(-1);
          //                         }
          //                       },
          //                     )),
          //               ),
          //               const SizedBox(width: 4),
          //               const Icon(Icons.calendar_today_outlined,
          //                   size: 20, color: Colors.black38),
          //             ],
          //           ),
          //         ),
          //       ),
          //       Container(
          //         width: 1,
          //         height: 48,
          //         color: Color(0xFFE4E4E4),
          //       ),

          //       /// To Date
          //       Expanded(
          //         child: Container(
          //           padding: const EdgeInsets.only(right: 16, left: 10),
          //           // decoration: BoxDecoration(
          //           //   border: Border(
          //           //     right: BorderSide(color: Color(0xFFE4E4E4), width: 2),
          //           //   ),
          //           // ),
          //           child: Row(
          //             children: [
          //               Expanded(
          //                 child: Obx(() => TextField(
          //                       controller: TextEditingController(
          //                           text: DateFormat('dd/MM/yyyy')
          //                               .format(controller.toDate.value)),
          //                       decoration: const InputDecoration(
          //                         isDense: true,
          //                         contentPadding:
          //                             EdgeInsets.symmetric(vertical: 8),
          //                         enabledBorder: UnderlineInputBorder(
          //                           borderSide:
          //                               BorderSide(color: Colors.transparent),
          //                         ),
          //                         focusedBorder: UnderlineInputBorder(
          //                           borderSide:
          //                               BorderSide(color: Colors.transparent),
          //                         ),
          //                       ),
          //                       style: poppinsMedium.copyWith(
          //                           color: ColorTheme.greyColor, fontSize: 16),
          //                       readOnly: true,
          //                       onTap: () async {
          //                         DateTime? picked = await showDatePicker(
          //                           context: context,
          //                           initialDate: controller.toDate.value,
          //                           firstDate: DateTime(2000),
          //                           lastDate: DateTime(2100),
          //                           builder: (context, child) {
          //                             return Theme(
          //                               data: ThemeData.light().copyWith(
          //                                 colorScheme: ColorScheme.light(
          //                                   primary: ColorTheme.appColor,
          //                                   onPrimary: Colors.white,
          //                                   onSurface: ColorTheme.greyColor,
          //                                 ),
          //                                 textButtonTheme: TextButtonThemeData(
          //                                   style: TextButton.styleFrom(
          //                                     foregroundColor:
          //                                         ColorTheme.appColor,
          //                                   ),
          //                                 ),
          //                               ),
          //                               child: child!,
          //                             );
          //                           },
          //                         );
          //                         if (picked != null) {
          //                           controller.toDate.value = picked;
          //                           controller.isCustomDateRange.value = true;
          //                           await controller.topCancelItems(-1);
          //                         }
          //                       },
          //                     )),
          //               ),
          //               const SizedBox(width: 4),
          //               const Icon(Icons.calendar_today_outlined,
          //                   size: 20, color: Colors.black38),
          //             ],
          //           ),
          //         ),
          //       ),
          //       Container(
          //         width: 1,
          //         height: 48,
          //         color: Color(0xFFE4E4E4),
          //       ),

          //       // Filter Icon
          //       Obx(() => IconButton(
          //             icon: Icon(
          //               Icons.filter_alt,
          //               size: 28,
          //               color: controller.showFilterPanel.value
          //                   ? Colors.blue
          //                   : Colors.grey,
          //             ),
          //             onPressed: () {
          //               // controller.showFilterPanel.value =
          //               //     !controller.showFilterPanel.value;
          //               if (controller.showFilterPanel.value) {
          //                 // If panel is open → closing it, so reset filters
          //                 controller.showFilterPanel.value = false;
          //                 controller.resetFiltersForTopCancelItems();
          //               } else {
          //                 // Opening the panel → no reset
          //                 controller.showFilterPanel.value = true;
          //               }
          //             },
          //           )),
          //     ],
          //   ),
          // ),

          // Filter Panel with Visibility - Dropdowns in a single row
          Obx(() => Visibility(
                visible: controller.showFilterPanel.value,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Payment Type Dropdown
                          // Expanded(
                          //   child: Obx(() => DropdownButtonFormField<String>(
                          //         decoration: InputDecoration(
                          //           labelText: "Payment Type",
                          //           labelStyle:
                          //               TextStyle(color: Color(0xFF828282)),
                          //           border: OutlineInputBorder(
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(30)),
                          //               borderSide: BorderSide(
                          //                   color: Color(0xFFDCDCDC))),
                          //           focusedBorder: OutlineInputBorder(
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(30)),
                          //               borderSide: BorderSide(
                          //                   color: Color(0xFFDCDCDC))),
                          //           errorBorder: OutlineInputBorder(
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(30)),
                          //               borderSide: BorderSide(
                          //                   color: Color(0xFFDCDCDC))),
                          //           enabledBorder: OutlineInputBorder(
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(30)),
                          //               borderSide: BorderSide(
                          //                   color: Color(0xFFDCDCDC))),
                          //         ),
                          //         value: controller!
                          //                 .selectedPaymentType.value.isEmpty
                          //             ? null
                          //             : controller!.selectedPaymentType.value,
                          //         items: controller!.paymentTypes
                          //             .map((type) => DropdownMenuItem<String>(
                          //                   value: type,
                          //                   child: Text(
                          //                     type,
                          //                     style: poppinsMedium.copyWith(
                          //                       color: Color(0xFF828282),
                          //                       fontSize: 12,
                          //                     ),
                          //                   ),
                          //                 ))
                          //             .toList(),
                          //         onChanged: (value) {
                          //           controller!.selectedPaymentType.value =
                          //               value ?? 'All Payment';
                          //           controller!
                          //               .applyFiltersForDailySalesDetails();
                          //         },
                          //       )),
                          // ),

                          // SizedBox(width: 10),
                          // Order Type Dropdown
                          Expanded(
                            child: Obx(() => DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Cancellation Stage",
                                    labelStyle:
                                        TextStyle(color: Color(0xFF828282)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                  value:
                                      controller.selectedReasons.value.isEmpty
                                          ? null
                                          : controller.selectedReasons.value,
                                  items: controller.reasons
                                      .map((type) => DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(
                                              type,
                                              style: poppinsMedium.copyWith(
                                                color: Color(0xFF828282),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller.selectedReasons.value =
                                        value ?? 'All Cancellation Stage';
                                    controller.applyFiltersForTopCancelItems();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    // height: 48,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 50,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          // Waiter Dropdown
                          Expanded(
                            child: Obx(() => DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Waiter",
                                    labelStyle:
                                        TextStyle(color: ColorTheme.greyColor),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                  value: controller.selectedWaiter.value,
                                  items: controller.waiters
                                      .map((waiter) => DropdownMenuItem<String>(
                                            value: waiter,
                                            child: Container(
                                              height: 20,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                waiter,
                                                style: poppinsMedium.copyWith(
                                                  color: Color(0xFF828282),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller.selectedWaiter.value =
                                        value ?? 'All Waiters';
                                    controller.applyFiltersForTopCancelItems();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    // height: 48,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    // padding:
                                    //     EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 50,
                                  ),
                                )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          // Cancellation reason Dropdown
                          Expanded(
                            child: Obx(() => DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Reason",
                                    labelStyle:
                                        TextStyle(color: ColorTheme.greyColor),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide:
                                          BorderSide(color: Color(0xFFDCDCDC)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide:
                                          BorderSide(color: Color(0xFFDCDCDC)),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide:
                                          BorderSide(color: Color(0xFFDCDCDC)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      borderSide:
                                          BorderSide(color: Color(0xFFDCDCDC)),
                                    ),
                                  ),
                                  value: controller
                                          .selectedCancelReasons.value.isEmpty
                                      ? null
                                      : controller.selectedCancelReasons.value,
                                  hint: Text(
                                    'All Reason',
                                    style: poppinsMedium.copyWith(
                                      color: Color(0xFF828282),
                                      fontSize: 12,
                                    ),
                                  ),
                                  items: [
                                    // Add "All Reason" as first option
                                    DropdownMenuItem<String>(
                                      value: 'All Reason',
                                      child: Container(
                                        height: 20,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'All Reason',
                                          style: poppinsMedium.copyWith(
                                            color: Color(0xFF828282),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Add all fetched reasons
                                    ...controller.cancellationReasons
                                        .map((reason) {
                                      return DropdownMenuItem<String>(
                                        value: reason['reason'] as String,
                                        child: Container(
                                          height: 20,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            reason['reason'] as String,
                                            style: poppinsMedium.copyWith(
                                              color: Color(0xFF828282),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    controller.selectedCancelReasons.value =
                                        value ?? 'All Reason';
                                    controller.applyFiltersForTopCancelItems();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 50,
                                  ),
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          // Timeframe Buttons
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
                            controller.topCancelledItemsSelect.value = index;

                            controller.setDateRange(
                                controller.reportList[index],
                                section: 'cancelled');
                            controller.topCancelItems(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: controller.topCancelledItemsSelect.value ==
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
                                  color: controller
                                              .topCancelledItemsSelect.value ==
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
          const SizedBox(height: 0),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Obx(() {
                double price = 0;
                for (var item in controller.filteredTopCancelItemList) {
                  String priceStr =
                      item['price'].toString().replaceAll(',', '');
                  double parsedPrice = double.tryParse(priceStr) ?? 0;
                  price += parsedPrice;
                }
                print("Total Cancellation : $price");

                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Total Cancellation',
                        //   style: poppinsSemiBold.copyWith(
                        //     color: ColorTheme.blueColor,
                        //     fontSize: 14,
                        //   ),
                        // ),
                        Row(
                          children: [
                            Text(
                              // '$date',
                              DateFormat('dd/MM/yyyy')
                                  .format(controller.cancelledFromDate.value),
                              style: const TextStyle(
                                color: ColorTheme.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                '-',
                                style: const TextStyle(
                                  color: ColorTheme.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              // '$date',
                              DateFormat('dd/MM/yyyy')
                                  .format(controller.cancelledToDate.value),
                              style: const TextStyle(
                                color: ColorTheme.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 10),
                        // Text(
                        //   "cancelDate",
                        //   style: poppinsMedium.copyWith(
                        //     color: Color(0xFF828282),
                        //     fontSize: 10,
                        //   ),
                        // ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .resturantType ==
                              'Restaurant'
                          ? "₹ ${price.toStringAsFixed(2)}"
                          : '0.00',
                      style: poppinsSemiBold.copyWith(
                        color: ColorTheme.blackColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  if (controller.isLoadingTopCancelledItems.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.filteredTopCancelItemList.isEmpty) {
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
                          DataColumn(
                            label: Expanded(
                              flex: 2,
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
                        ],
                        rows: controller.filteredTopCancelItemList.map((item) {
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
                                        item['food_item'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: ColorTheme.greyColor,
                                        ),
                                      ),
                                    ),
                                    // Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MostCancelItemDetails(
                                                orderId: item['other_detail'][0]
                                                        ['order_id']
                                                    .toString(),
                                                foodName: item['food_item'],
                                                controller: controller,
                                              ),
                                            ));
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
                                    // item['total_quantity'].toString(),
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
                                    // item['total_sales'].toString(),
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
