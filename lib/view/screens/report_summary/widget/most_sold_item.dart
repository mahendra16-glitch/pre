import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/date_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:excel/excel.dart' as excel;
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../../../../controller/report_summary_controller.dart';
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MostSoldItem extends StatelessWidget {
  final int selectedTabIndex;

  MostSoldItem({key, required this.selectedTabIndex});
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
          DateFormat('dd_MM_yyyy').format(controller.itemsFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.itemsToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Most Sold Items Report ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      //  Added all other keys here
      List<String> headers = [
        'Item',
        'Station',
        'Category',
        'Item Price',
        'Complimentary Price',
        'Food Price',
        'Variation Price',
        'Addon Price',
        'GST',
        'VAT',
        'Service Charge',
        'Discount',
        'Sold Quantity',
        'Total Sales'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      double totalSales = 0.0;
      for (int i = 0; i < controller.topSoldItemsList.length; i++) {
        var item = controller.topSoldItemsList[i];
        double totalSalesValue = 0.0;
        if (Get.find<AuthController>()
                .profileModel
                ?.restaurants
                ?.first
                .resturantType ==
            'Restaurant') {
          totalSalesValue = double.tryParse(
                  item['total_sales']?.toString().replaceAll(',', '') ??
                      '0.00') ??
              0.0;
        }
        totalSales += totalSalesValue;

        List<dynamic> rowData = [
          item['food_item']?.toString() ?? '',
          item['station_name']?.toString() ?? '',
          item['category_name']?.toString() ?? '',
          double.tryParse(item['item_price']?.toString() ?? '0'),
          double.tryParse(item['complementary_price']?.toString() ?? '0'),
          double.tryParse(item['food_price']?.toString() ?? '0'),
          double.tryParse(item['variation_price']?.toString() ?? '0'),
          double.tryParse(item['addon_price']?.toString() ?? '0'),
          double.tryParse(item['gst']?.toString() ?? '0'),
          double.tryParse(item['vat']?.toString() ?? '0'),
          double.tryParse(item['service_charge']?.toString() ?? '0'),
          double.tryParse(item['discount']?.toString() ?? '0'),
          double.tryParse(item['total_quantity']?.toString() ?? '0'),
          totalSalesValue,
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

      // Add Total Row
      if (controller.topSoldItemsList.isNotEmpty) {
        // Create bold style for total
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;

        // Add blank row gap (row will be empty)
        final totalRowIndex = controller.topSoldItemsList.length + 3;
        final totalCell = sheet.getRangeByName('N$totalRowIndex');
        totalCell.setText('Total : ${totalSales.toStringAsFixed(0)}');
        totalCell.cellStyle = boldStyle;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Most_Sold_Items_Report_${fromDate}_to_${toDate}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller.itemsFromDate.value);
      final toDate =
          DateFormat('dd_MM_yyyy').format(controller.itemsToDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Most Sold Items Report ${fromDate} to ${toDate}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      //  Same headers for mobile
      List<String> headers = [
        'Item',
        'Station',
        'Category',
        'Item Price',
        'Complimentary Price',
        'Food Price',
        'Variation Price',
        'Addon Price',
        'GST',
        'VAT',
        'Service Charge',
        'Discount',
        'Sold Quantity',
        'Total Sales'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      double totalSales = 0.0;
      for (int i = 0; i < controller.topSoldItemsList.length; i++) {
        var item = controller.topSoldItemsList[i];
        double totalSalesValue = 0.0;
        if (Get.find<AuthController>()
                .profileModel
                ?.restaurants
                ?.first
                .resturantType ==
            'Restaurant') {
          totalSalesValue = double.tryParse(
                  item['total_sales']?.toString().replaceAll(',', '') ??
                      '0.00') ??
              0.0;
        }
        totalSales += totalSalesValue;

        List<dynamic> rowData = [
          item['food_item']?.toString() ?? '',
          item['station_name']?.toString() ?? '',
          item['category_name']?.toString() ?? '',
          double.tryParse(item['item_price']?.toString() ?? '0'),
          double.tryParse(item['complementary_price']?.toString() ?? '0'),
          double.tryParse(item['food_price']?.toString() ?? '0'),
          double.tryParse(item['variation_price']?.toString() ?? '0'),
          double.tryParse(item['addon_price']?.toString() ?? '0'),
          double.tryParse(item['gst']?.toString() ?? '0'),
          double.tryParse(item['vat']?.toString() ?? '0'),
          double.tryParse(item['service_charge']?.toString() ?? '0'),
          double.tryParse(item['discount']?.toString() ?? '0'),
          double.tryParse(item['total_quantity']?.toString() ?? '0'),
          totalSalesValue,
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

      // Add Total Row
      if (controller.topSoldItemsList.isNotEmpty) {
        // Create bold style for total
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;

        // Add blank row gap (row will be empty)
        final totalRowIndex = controller.topSoldItemsList.length + 3;
        final totalCell = sheet.getRangeByName('N$totalRowIndex');
        totalCell.setText('Total : ${totalSales.toStringAsFixed(0)}');
        totalCell.cellStyle = boldStyle;
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = "Most_Sold_Items_Report_${fromDate}_to_${toDate}.xlsx";
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
    // controller.itemsSearchController.clear();
    // controller.filteredTopSoldItemsList.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.topSoldListItemSelected.value = selectedTabIndex;
      if (!controller.isItemsCustomDateRange.value) {
        controller.setDateRange(controller.reportList[selectedTabIndex],
            section: 'items');
      }
      controller.topSoldItems(
          controller.itemsFromDate.value, controller.itemsToDate.value);
    });
    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.resetFilterTopSoldItems();
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
              "Item ",
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
          Text('Comp Item',
              style: montserratMedium.copyWith(
                  color: ColorTheme.borderGrey1, fontSize: 13)),
          Obx(() => Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: controller.isCompItemEnabled.value,
                  onChanged: (value) {
                    controller.isCompItemEnabled.value = value;
                    controller.topSoldItems(controller.itemsFromDate.value,
                        controller.itemsToDate.value);
                  },
                  activeColor: ColorTheme.blueColor,
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return ColorTheme.blueColor;
                    }
                    return ColorTheme.borderGrey;
                  }),
                  inactiveThumbColor: ColorTheme.borderGrey,
                  inactiveTrackColor: ColorTheme.transparent,
                ),
              )),
          SizedBox(width: 5),
          InkWell(
              onTap: () {
                exportToExcel();
              },
              child:
                  SizedBox(width: 25, child: SvgPicture.asset(Images.export))),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<ReportSummeryController>(
            builder: (reportSummeryController) {
          return Column(
            children: [
              // const SizedBox(height: 15),
              // Container(
              //   // padding: const EdgeInsets.symmetric(horizontal: 15),
              //   decoration: BoxDecoration(
              //     border: Border(
              //         top: BorderSide(color: Colors.white),
              //         bottom: BorderSide(color: Color(0xFFE4E4E4))),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Expanded(
              //         child: Container(
              //           alignment: Alignment.center,
              //           padding: const EdgeInsets.only(right: 16,left: 10,),
              //           decoration: BoxDecoration(
              //             border: Border(
              //               right: BorderSide(color: Color(0xFFE4E4E4), width: 1),
              //             ),
              //           ),
              //           child: Row(
              //             children: [
              //               Obx(() => Expanded(
              //                     child: TextField(
              //                       controller: TextEditingController(
              //                           text: DateFormat('dd/MM/yyyy')
              //                               .format(controller.fromDate.value)),
              //                       decoration: InputDecoration(
              //                         // labelText: 'From Date',
              //                         labelStyle:
              //                             TextStyle(color: ColorTheme.greyColor),
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
              //                           color: ColorTheme.greyColor,
              //                           fontSize: 16),
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
              //                                   primary: ColorTheme
              //                                       .appColor, // Header color
              //                                   onPrimary: Colors
              //                                       .white, // Text color on header
              //                                   onSurface: ColorTheme
              //                                       .greyColor, // Calendar text
              //                                 ),
              //                                 buttonTheme: ButtonThemeData(
              //                                   colorScheme: ColorScheme.light(
              //                                     primary: ColorTheme
              //                                         .appColor, // Button color
              //                                   ),
              //                                 ),
              //                                 textButtonTheme:
              //                                     TextButtonThemeData(
              //                                   style: TextButton.styleFrom(
              //                                     foregroundColor: ColorTheme
              //                                         .appColor, // OK/Cancel text
              //                                   ),
              //                                 ),
              //                               ),
              //                               child: child!,
              //                             );
              //                           },
              //                         );
              //                         if (picked != null) {
              //                           controller.fromDate.value = picked;
              //                           await controller.topSoldItems(
              //                               controller.fromDate.value,
              //                               controller.toDate.value);
              //                         }
              //                       },
              //                     ),
              //                   )),
              //               // const SizedBox(width: 8),
              //               const Icon(Icons.calendar_today_outlined,
              //                   size: 22, color: Colors.black38),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         child: Container(
              //           alignment: Alignment.center,
              //           padding: const EdgeInsets.only(right: 16 ,left: 10,),
              //           decoration: BoxDecoration(
              //             border: Border(
              //               right: BorderSide(color: Color(0xFFE4E4E4), width: 1),
              //             ),
              //           ),
              //           child: Row(
              //             children: [
              //               Obx(() => Expanded(
              //                     child: TextField(
              //                       controller: TextEditingController(
              //                           text: DateFormat('dd/MM/yyyy')
              //                               .format(controller.toDate.value)),
              //                       decoration: InputDecoration(
              //                         // labelText: 'To Date',
              //                         labelStyle:
              //                             TextStyle(color: ColorTheme.greyColor),
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
              //                           color: ColorTheme.greyColor,
              //                           fontSize: 16),
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
              //                                 buttonTheme: ButtonThemeData(
              //                                   colorScheme: ColorScheme.light(
              //                                     primary: ColorTheme
              //                                         .appColor, // Button color
              //                                   ),
              //                                 ),
              //                                 textButtonTheme:
              //                                     TextButtonThemeData(
              //                                   style: TextButton.styleFrom(
              //                                     foregroundColor: ColorTheme
              //                                         .appColor, // OK/Cancel text
              //                                   ),
              //                                 ),
              //                               ),
              //                               child: child!,
              //                             );
              //                           },
              //                         );
              //                         if (picked != null) {
              //                           controller.toDate.value = picked;
              //                           await controller.topSoldItems(
              //                               controller.fromDate.value,
              //                               controller.toDate.value);
              //                         }
              //                       },
              //                     ),
              //                   )),
              //               // const SizedBox(width: 8),
              //               const Icon(Icons.calendar_today_outlined,
              //                   size: 22, color: Colors.black38),
              //             ],
              //           ),
              //         ),
              //       ),
              //       Center(
              //         child: Container(
              //           padding: const EdgeInsets.only(left: 10, right: 10),
              //           //  decoration: BoxDecoration(
              //           //   border: Border(
              //           //     left: BorderSide(color: Color(0xFFE4E4E4)),
              //           //   ),
              //           // ),
              //           child: Icon(Icons.print_outlined,
              //               size: 28, color: ColorTheme.borderGrey),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              DateFilterWidget(
                controller: controller,
                section: 'items',
                onDateChanged: (formattedDate) {
                  controller.isItemsCustomDateRange.value = true;
                  controller.topSoldItems(controller.itemsFromDate.value,
                      controller.itemsToDate.value);
                },
              ),
              const SizedBox(height: 20),
              // Search Bar Implementation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomSearchField(
                  onChanged: (query) {
                    controller.filterTopSoldItems(query);
                    controller.update();
                  },
                  controller: controller.itemsSearchController,
                  hitText: 'Search By Item Name',
                ),
              ),
              const SizedBox(height: 20),

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
                                controller.topSoldListItemSelected.value =
                                    index;
                                controller.setDateRange(
                                    controller.reportList[index],
                                    section: 'items');
                                controller.topSoldItems(
                                    controller.itemsFromDate.value,
                                    controller.itemsToDate.value);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: controller
                                              .topSoldListItemSelected.value ==
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
                                      color: controller.topSoldListItemSelected
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
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () {
                      if (controller.isLoadingSoldItem.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Use filtered list instead of original list
                      final displayList =
                          controller.itemsSearchController.text.isEmpty
                              ? controller.topSoldItemsList
                              : controller.filteredTopSoldItemsList;

                      if (displayList.isEmpty) {
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
                                bottom: BorderSide(
                                    color: Color(
                                        0xFFE4E4E4), // Bottom border visible
                                    width: 2),
                                top: BorderSide(
                                    color: Color(0xFFE4E4E4), width: 2),
                                horizontalInside: BorderSide(
                                    color: Color(0xFFE4E4E4), width: 1),
                                verticalInside: BorderSide(
                                    color: Color(0xFFE4E4E4), width: 2)),
                            showBottomBorder: true,
                            columns: const [
                              DataColumn(
                                label: Expanded(
                                  flex: 6,
                                  child: Text(
                                    "Item",
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
                                    textAlign: TextAlign.center,
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
                                label: Expanded(
                                  flex: 2,
                                  child: Text(
                                    textAlign: TextAlign.center,
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
                            rows: displayList.map((item) {
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
                                            item['food_item'].toString(),
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
                                            ? item['complementary_price'].toString() != '0.00'
                                                ? '${item['total_sales'].toString()}(${item['complementary_price'].toString()})'
                                                : item['total_sales'].toString()
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
          );
        }),
      ),
    );
  }
}
