import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/data/model/response/daily_revenue_report_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/aggregator_order_details.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
// import 'package:excel/excel.dart' as excel; // Added for Excel file creation
import 'package:path_provider/path_provider.dart'; // Added for storage path
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import 'dart:io'; // Added for File handling
// import 'package:open_file/open_file.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io' show Platform, File;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class DailySalesDetailsReport extends StatelessWidget {
  String? date;
  ReportSummeryController? controller;

  DailySalesDetailsReport({this.date, this.controller});

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
          DateFormat('dd_MM_yyyy').format(controller!.fromDate.value);
      final toDate = DateFormat('dd_MM_yyyy').format(controller!.toDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Daily Sales Report ${fromDate} to ${toDate} ${controller!.selectedOrderType.value} ${controller!.selectedPaymentType.value} ${controller!.selectedWaiter.value} ${controller!.selectedOrderCollectedType.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Order ID',
        'Order Date',
        'Order Time',
        'Order Type',
        'No. Of Items',
        'Order Details',
        'Waiter(Ordered)',
        'Waiter(Collected)',
        'Payment Type',
        'Gst Amount',
        'Delivery Charge',
        'Service Tax',
        'Tip Amount',
        'Discount',
        'RoundOff',
        'Total Amount',
        'Cash',
        'Card',
        'Upi',
        'Contact Person Name',
        'Contact Person Number',
        'Date Of Birth',
        'Date Of Anniversary',
        'Address Type',
        'Area',
        'Pincode',
        'Complete Address',
        'Location'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;
      for (var report in controller!.filteredDailySalesListReport) {
        for (var item in report.report ?? []) {
          String completeAddress = [
            item.customerInfo?.house ?? '',
            item.customerInfo?.floor ?? '',
            item.customerInfo?.address ?? ''
          ].where((part) => part.isNotEmpty).join(', ');

          List<dynamic> rowData = [
            item.restaurantOrderId.toString() ?? '',
            _formatDateTime(item.orderNewDate, onlyDate: true),
            _formatDateTime(item.orderNewDate),
            item.orderType.toString() ?? '',
            item.quantity.toString() ?? '',
            item.foodName.toString() ?? '',
            item.waiter.toString() ?? '',
            item.collectedBy.toString() ?? '',
            item.paymentType.toString() ?? '',
            double.tryParse(
                item.gstAmount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.deliveryCharge.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.serviceTax.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.tipAmount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.orderDiscount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.roundOff.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.amount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Cash.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Card.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Upi.toString().replaceAll(',', '') ?? '0.00'),
            item.customerInfo?.contactPersonName ?? '',
            item.customerInfo?.contactPersonNumber ?? '',
            item.dateOfBirth ?? '',
            item.dateOfAnniversary ?? '',
            item.customerInfo?.addressType ?? '',
            item.customerInfo?.address ?? '',
            item.customerInfo?.pincode ?? '',
            completeAddress,
            item.membershipId ?? '',
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

      if (controller!.dailySalesListReport.value != null) {
        final grandTotal = controller!.dailySalesListReport.value!.grandTotal;
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;
        rowIndex++;

        Map<String, dynamic> total = {
          'Total Amount': grandTotal?.paidRevenue,
          'Gst Amount': grandTotal?.gstAmount,
          'Service Tax': grandTotal?.serviceTax,
          'Delivery Charge': grandTotal?.deliveryCharge,
          'Tip Amount': grandTotal?.tipAmount,
          'Discount': grandTotal?.totalDiscount,
          'RoundOff': grandTotal?.roundOff,
        };
        total.forEach((header, value) {
          int columnIndex = headers.indexOf(header);
          if (columnIndex != -1) {
            String columnLetter = String.fromCharCode(65 + columnIndex);
            sheet
                .getRangeByName('$columnLetter$rowIndex')
                .setText('Total = ${value?.toString() ?? "0.00"}');
            sheet.getRangeByName('$columnLetter$rowIndex').cellStyle =
                boldStyle;
          }
        });
      }
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName:
            'Daily_Sales_Report_${fromDate}_${toDate}_${controller!.selectedOrderType.value}_${controller!.selectedPaymentType.value}_${controller!.selectedWaiter.value}_${controller!.selectedOrderCollectedType.value}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller!.fromDate.value);
      final toDate = DateFormat('dd_MM_yyyy').format(controller!.toDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Daily Sales Report ${fromDate} to ${toDate} ${controller!.selectedOrderType.value} ${controller!.selectedPaymentType.value} ${controller!.selectedWaiter.value} ${controller!.selectedOrderCollectedType.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Order ID',
        'Order Date',
        'Order Time',
        'Order Type',
        'No. Of Items',
        'Order Details',
        'Waiter(Ordered)',
        'Waiter(Collected)',
        'Payment Type',
        'Gst Amount',
        'Delivery Charge',
        'Service Tax',
        'Tip Amount',
        'Discount',
        'RoundOff',
        'Total Amount',
        'Cash',
        'Card',
        'Upi',
        'Contact Person Name',
        'Contact Person Number',
        'Date Of Birth',
        'Date Of Anniversary',
        'Address Type',
        'Area',
        'Pincode',
        'Complete Address',
        'Location'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        // sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;
      for (var report in controller!.filteredDailySalesListReport) {
        for (var item in report.report ?? []) {
          String completeAddress = [
            item.customerInfo?.house ?? '',
            item.customerInfo?.floor ?? '',
            item.customerInfo?.address ?? ''
          ].where((part) => part.isNotEmpty).join(', ');

          List<dynamic> rowData = [
            item.restaurantOrderId.toString() ?? '',
            _formatDateTime(item.orderNewDate, onlyDate: true),
            _formatDateTime(item.orderNewDate),
            item.orderType.toString() ?? '',
            item.foodName.toString() ?? '',
            item.waiter.toString() ?? '',
            item.waiter.toString() ?? '',
            item.collectedBy.toString() ?? '',
            item.paymentType.toString() ?? '',
            double.tryParse(
                item.gstAmount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.deliveryCharge.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.serviceTax.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.tipAmount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.orderDiscount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.roundOff.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.amount.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Cash.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Card.toString().replaceAll(',', '') ?? '0.00'),
            double.tryParse(
                item.payment.Upi.toString().replaceAll(',', '') ?? '0.00'),
            item.customerInfo?.contactPersonName ?? '',
            item.customerInfo?.contactPersonNumber ?? '',
            item.dateOfBirth ?? '',
            item.dateOfAnniversary ?? '',
            item.customerInfo?.addressType ?? '',
            item.customerInfo?.address ?? '',
            item.customerInfo?.pincode ?? '',
            completeAddress,
            item.membershipId ?? '',
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

      if (controller!.dailySalesListReport.value != null) {
        final grandTotal = controller!.dailySalesListReport.value!.grandTotal;
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;
        rowIndex++;

        Map<String, dynamic> total = {
          'Total Amount': grandTotal?.paidRevenue,
          'Gst Amount': grandTotal?.gstAmount,
          'Service Tax': grandTotal?.serviceTax,
          'Delivery Charge': grandTotal?.deliveryCharge,
          'Tip Amount': grandTotal?.tipAmount,
          'Discount': grandTotal?.totalDiscount,
          'RoundOff': grandTotal?.roundOff,
        };
        total.forEach((header, value) {
          int columnIndex = headers.indexOf(header);
          if (columnIndex != -1) {
            String columnLetter = String.fromCharCode(65 + columnIndex);
            sheet
                .getRangeByName('$columnLetter$rowIndex')
                .setText('Total = ${value?.toString() ?? "0.00"}');
            sheet.getRangeByName('$columnLetter$rowIndex').cellStyle =
                boldStyle;
          }
        });
      }

      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Daily_Sales_Report_${fromDate}_${toDate}_${controller!.selectedOrderType.value}_${controller!.selectedPaymentType.value}_${controller!.selectedWaiter.value}_${controller!.selectedOrderCollectedType.value}.xlsx";
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
    if (controller == null) {
      // controller = Get.put(ReportSummeryController());
      controller = Get.find<ReportSummeryController>();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime parsedDate;
      try {
        parsedDate = DateFormat('d-M-yyyy').parse(date!);
      } catch (e) {
        // Fallback to current date if parsing fails
        parsedDate = DateTime.now();
        print("Error parsing date: $e, using current date as fallback");
      }

      // Set the fromDate and toDate in the controller to the parsed date
      controller!.fromDate.value = parsedDate;
      controller!.toDate.value = parsedDate;
      controller!.dailySalesItemsList(date!);

      controller!.paymentTypes.clear();
      controller!.paymentTypes.add(PaymentModes(
          displayName: 'All Payment Types', name: 'All Payment Types'));
      controller!.selectedPaymentType.value = controller!.paymentTypes.first;
      controller!.paymentTypes.addAll(Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .paymentModes!);

      controller!.paymentTypes
          .add(PaymentModes(displayName: 'Cancel', name: 'Cancel'));
      controller!.paymentTypes
          .add(PaymentModes(displayName: 'Unpaid', name: 'Unpaid'));
    });

    DateTime fromDateChecker = controller!.fromDate.value;
    DateTime ToDateChecker = controller!.toDate.value;

    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller?.resetFilters();
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
              "Daily Revenue ",
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
          SizedBox(width: 13),
          Obx(() {
            final isLoading = controller!.isLoadingDailySalesListItems.value;
            return InkWell(
              onTap: isLoading
                  ? null
                  : () {
                      Get.find<ReportSummeryController>()
                          .exportDailySalesItemWiseList({
                        'from': DateFormat('yyyy-MM-dd')
                            .format(controller!.fromDate.value),
                        'to': DateFormat('yyyy-MM-dd')
                            .format(controller!.toDate.value),
                      });
                    },
              mouseCursor: isLoading
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              child:
                  SizedBox(width: 25, child: SvgPicture.asset(Images.export)),
            );
          }),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white),
                bottom: BorderSide(color: Color(0xFFE4E4E4)),
              ),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(
                children: [
                  //From date
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        border: Border(
                            // right: BorderSide(color: Color(0xFFE4E4E4), width: 1),
                            ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: controller!.fromDate.value,
                            // firstDate: DateTime(2000),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1460)),

                            // lastDate: DateTime(2100),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              // fromDateChecker = controller!.fromDate.value;
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: ColorTheme.appColor,
                                    onPrimary: Colors.white,
                                    onSurface: ColorTheme.greyColor,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: ColorTheme.appColor,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null &&
                              (picked.isBefore(controller!.toDate.value) ||
                                  picked.isAtSameMomentAs(
                                      controller!.toDate.value))) {
                            controller!.fromDate.value = picked;
                            await controller!.dailySalesItemsList(
                                DateFormat('d-M-yyyy').format(picked));
                          } else {
                            Get.snackbar(
                              'Select valid Date',
                              "Select a date which lower than and equal to  ${DateFormat('dd-MM-yyyy').format(controller!.toDate.value)}",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Obx(() => Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(controller!.fromDate.value),
                                    overflow: TextOverflow.ellipsis,
                                    style: poppinsMedium.copyWith(
                                      color: ColorTheme.greyColor,
                                      fontSize: 14,
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: Colors.black38),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Color(0xFFE4E4E4),
                  ),

                  //To date
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: controller!.toDate.value,
                            // firstDate: DateTime(2000),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1460)),

                            // lastDate: DateTime(2100),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: ColorTheme.appColor,
                                    onPrimary: Colors.white,
                                    onSurface: ColorTheme.greyColor,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: ColorTheme.appColor,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null &&
                              (picked.isAfter(controller!.fromDate.value) ||
                                  picked.isAtSameMomentAs(
                                      controller!.fromDate.value))) {
                            controller!.toDate.value = picked;
                            await controller!.dailySalesItemsList(
                                DateFormat('d-M-yyyy').format(picked));
                          } else {
                            Get.snackbar(
                              'Select valid Date',
                              "Select a date which greater than and equal to  ${DateFormat('dd-MM-yyyy').format(controller!.fromDate.value)}",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Obx(() => Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(controller!.toDate.value),
                                    overflow: TextOverflow.ellipsis,
                                    style: poppinsMedium.copyWith(
                                      color: ColorTheme.greyColor,
                                      fontSize: 14,
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: Colors.black38),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border(left: BorderSide(color: Color(0xFFE4E4E4))),
                    ),
                    child: Obx(() => IconButton(
                          icon: Icon(
                            Icons.filter_alt,
                            color: controller!.showFilterPanel.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (controller!.showFilterPanel.value) {
                              // If panel is open → closing it, so reset filters
                              controller!.showFilterPanel.value = false;
                              controller!.resetFiltersForDailyRevenueReport();
                            } else {
                              // Opening the panel → no reset
                              controller!.showFilterPanel.value = true;
                            }
                          },
                        )),
                  ),
                ],
              );
            }),
          ),
          // Filter Panel with Visibility - Dropdowns in a single row
          Obx(() => Visibility(
                visible: controller!.showFilterPanel.value,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Payment Type Dropdown
                          Expanded(
                            child: Obx(() =>
                                DropdownButtonFormField2<PaymentModes>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Payment Type",
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
                                  value: controller!.selectedPaymentType.value,
                                  items: controller!.paymentTypes
                                      .map((type) =>
                                          DropdownMenuItem<PaymentModes>(
                                            value: type,
                                            child: Text(
                                              type.displayName ?? '',
                                              style: poppinsMedium.copyWith(
                                                color: Color(0xFF828282),
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller!.selectedPaymentType.value =
                                        value ?? controller!.paymentTypes.first;
                                    controller!.dailySalesItemsList(
                                        DateFormat('d-M-yyyy')
                                            .format(DateTime.now()));
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
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                )),
                          ),
                          SizedBox(width: 10),
                          // Order Type Dropdown
                          Expanded(
                            child: Obx(() => DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Order Type",
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
                                  value: controller!
                                          .selectedOrderType.value.isEmpty
                                      ? null
                                      : controller!.selectedOrderType.value,
                                  items: controller!.orderTypes
                                      .map((type) => DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(
                                              type,
                                              style: poppinsMedium.copyWith(
                                                color: Color(0xFF828282),
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller!.selectedOrderType.value =
                                        value ?? 'All Order';
                                    controller!.dailySalesItemsList(
                                        DateFormat('d-M-yyyy')
                                            .format(DateTime.now()));
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
                                    maxHeight: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 40,
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
                                  value: controller!.selectedWaiter.value,
                                  items: controller!.waiters
                                      .map((waiter) => DropdownMenuItem<String>(
                                            value: waiter,
                                            child: Text(
                                              waiter,
                                              style: poppinsMedium.copyWith(
                                                color: Color(0xFF828282),
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller!.selectedWaiter.value =
                                        value ?? 'All Waiters';
                                    controller!.dailySalesItemsList(
                                        DateFormat('d-M-yyyy')
                                            .format(DateTime.now()));
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
                          SizedBox(width: 10),
                          Expanded(
                            child: Obx(() => DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Waiter Type",
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
                                  value: controller!.selectedOrderCollectedType
                                          .value.isEmpty
                                      ? null
                                      : controller!
                                          .selectedOrderCollectedType.value,
                                  items: controller!.orderCollectedType
                                      .map((waiter) => DropdownMenuItem<String>(
                                            value: waiter,
                                            child: Text(
                                              waiter,
                                              style: poppinsMedium.copyWith(
                                                color: Color(0xFF828282),
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller!.selectedOrderCollectedType
                                        .value = value ?? 'All Waiters Type';
                                    controller!.dailySalesItemsList(
                                        DateFormat('d-M-yyyy')
                                            .format(DateTime.now()));
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
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pre paid
                          Expanded(
                            child: Row(
                              children: [
                                Obx(() => Checkbox(
                                      value: controller?.prePaid.value,
                                      onChanged: (value) {
                                        controller?.prePaid.value =
                                            value ?? true;
                                        // print(
                                        //     'Pre Paid: ${controller?.prePaid.value}');
                                        controller!.dailySalesItemsList(
                                            DateFormat('d-M-yyyy')
                                                .format(DateTime.now()));
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      activeColor: Colors.blue,
                                      side: BorderSide(
                                          color: (controller?.prePaid.value ??
                                                  true)
                                              ? Colors.blue
                                              : ColorTheme.grey1,
                                          width: 2),
                                    )),
                                Text(
                                  'Pre Paid',
                                  style: poppinsMedium.copyWith(
                                    color: ColorTheme.greyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 30),
                          // Spacer(),
                          Expanded(
                            child: Row(
                              children: [
                                Obx(() => Checkbox(
                                      value: controller?.postPaid.value,
                                      onChanged: (value) {
                                        controller?.postPaid.value =
                                            value ?? true;
                                        // print(
                                        //     'Post Paid: ${controller?.postPaid.value}');

                                        controller!.dailySalesItemsList(
                                            DateFormat('d-M-yyyy')
                                                .format(DateTime.now()));
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      activeColor: Colors.blue,
                                      side: BorderSide(
                                          color: (controller?.postPaid.value ??
                                                  true)
                                              ? Colors.blue
                                              : ColorTheme.grey1,
                                          width: 2),
                                    )),
                                Text(
                                  'Post Paid',
                                  style: poppinsMedium.copyWith(
                                    color: ColorTheme.greyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),

          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: CustomSearchField(
              onChanged: (query) {
                controller?.filterDailySaleItems(query);
                controller?.update();
              },
              controller: controller!.dailySalesItemSearchController,
              hitText: 'Search By Order Id',
            ),
          ),

          Container(
            color: ColorTheme.grey200Color,
            child: GestureDetector(
              onTap: () {
                controller!.isExpanded2.value = !controller!.isExpanded2.value;
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Obx(
                          () => Row(
                            children: [
                              Text(
                                // '$date',
                                DateFormat('dd/MM/yyyy')
                                    .format(controller!.fromDate.value),
                                style: const TextStyle(
                                  color: ColorTheme.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                    .format(controller!.toDate.value),
                                style: const TextStyle(
                                  color: ColorTheme.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(
                      () => Text(
                        '₹ ${controller!.dailySalesList.value?.grandTotal?.paidRevenue ?? "0.00"}',
                        style: const TextStyle(
                          color: ColorTheme.blackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Obx(
                      () => Icon(
                        controller!.isExpanded2.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: ColorTheme.greyColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          Container(
            color: ColorTheme.grey200Color,
            child: Obx(
              () {
                // List paidRevenue = controller!.dailySalesList["order_revenue"]
                //             .toString() ==
                //         "null"
                //     ? []
                //     : (controller!.dailySalesList["order_revenue"].entries
                //         .map((entry) => {
                //               "name": entry.key,
                //               "value": double.parse(
                //                   entry.value.toString().replaceAll(',', ''))
                //             })
                //         .toList());
                // List tabRevenue = controller!.dailySalesList["tab_revenue"]
                //             .toString() ==
                //         "null"
                //     ? []
                //     : (controller!.dailySalesList["tab_revenue"].entries
                //         .map((entry) => {
                //               "name": entry.key,
                //               "value": double.parse(
                //                   entry.value.toString().replaceAll(',', ''))
                //             })
                //         .toList());
                // List roomRevenue = controller!.dailySalesList["room_revenue"]
                //             .toString() ==
                //         "null"
                //     ? []
                //     : (controller!.dailySalesList["room_revenue"].entries
                //         .map((entry) => {
                //               "value": double.parse(
                //                   entry.value.toString().replaceAll(',', ''))
                //             })
                return Visibility(
                  visible: controller!.isExpanded2.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   itemCount: paidRevenue.length,
                        //   itemBuilder: (context, index) {
                        //     var items = paidRevenue[index];
                        //     return buildSection('${items["name"]}',
                        //         '₹${items["value"] ?? '0.00'}');
                        //   },
                        // ),
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   itemCount: tabRevenue.length,
                        //   itemBuilder: (context, index) {
                        //     var items = tabRevenue[index];
                        //     return buildSection('${items["name"]}',
                        //         '₹${items["value"] ?? '0.00'}');
                        //   },
                        // ),
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   itemCount: roomRevenue.length,
                        //   itemBuilder: (context, index) {
                        //     var items = roomRevenue[index];
                        //     return buildSection('${items["name"]}',
                        //         '₹${items["value"] ?? '0.00'}');
                        //   },
                        // ),
                        // Order Revenue
                        ...[
                          {
                            'name': 'Cash',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.orderRevenue?.cash
                          },
                          {
                            'name': 'Card',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.orderRevenue?.card
                          },
                          {
                            'name': 'UPI',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.orderRevenue?.upi
                          },
                        ].map((item) =>
                            buildSection(item['name']!, '₹${item['value']}')),
                        Divider(),
                        Divider(),

                        // Tab Revenue
                        ...[
                          {
                            'name': 'Credit Cash',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.tabRevenue?.tabCash
                          },
                          {
                            'name': 'Credit Card',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.tabRevenue?.tabCard
                          },
                          {
                            'name': 'Credit UPI',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.tabRevenue?.tabUpi
                          },
                        ].map((item) =>
                            buildSection(item['name']!, '₹${item['value']}')),
                        Divider(),
                        Divider(),

                        // Room Revenue
                        ...[
                          {
                            'name': 'Room Cash',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.roomRevenue?.roomCash
                          },
                          {
                            'name': 'Room Card',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.roomRevenue?.roomCard
                          },
                          {
                            'name': 'Room UPI',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.roomRevenue?.roomUpi
                          },
                        ].map((item) =>
                            buildSection(item['name']!, '₹${item['value']}')),
                        Divider(),
                        Divider(),

                        // Other Details
                        ...[
                          {
                            'name': 'Tip',
                            'value': controller!
                                .dailySalesList.value?.grandTotal?.tipAmount
                          },
                          {
                            'name': 'GST',
                            'value': controller!
                                .dailySalesList.value?.grandTotal?.gstAmount
                          },
                          {
                            'name': 'Service Tax',
                            'value': controller!
                                .dailySalesList.value?.grandTotal?.serviceTax
                          },
                          {
                            'name': 'Delivery Charge',
                            'value': controller!.dailySalesList.value
                                ?.grandTotal?.deliveryCharge
                          }
                        ].map((item) =>
                            buildSection(item['name']!, '₹${item['value']}'))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  if (controller!.isLoadingDailySalesListItems.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (controller!.filteredDailySalesList.isEmpty) {
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
                        columns: [
                          DataColumn(
                            label: Expanded(
                              flex: 7,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorTheme.blueColor,
                                  ),
                                  children: [
                                    TextSpan(text: 'Orders '),
                                    TextSpan(text: '('),
                                    TextSpan(
                                      text:
                                          'P - ${controller!.dailySalesList.value?.orderStatus?.paidOrders}',
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 14),
                                    ),
                                    TextSpan(
                                      text: ' , ',
                                      style: TextStyle(
                                          color: ColorTheme.blueColor,
                                          fontSize: 12),
                                    ),
                                    TextSpan(
                                      text:
                                          'U - ${controller!.dailySalesList.value?.orderStatus?.unpaidOrders}',
                                      style: TextStyle(
                                          color: ColorTheme.appColor,
                                          fontSize: 14),
                                    ),
                                    TextSpan(text: ')'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  "Type",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorTheme.blueColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const DataColumn(
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
                        rows: controller!.filteredDailySalesList
                            .expand((report) => report.report ?? [])
                            .map<DataRow>((item) {
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
                                        RichText(
                                          text: TextSpan(
                                            text: '${item.orderDate} ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: ColorTheme.blueColor,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '#${item.restaurantOrderId}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: ColorTheme.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              item.orderType,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: ColorTheme.greyColor,
                                              ),
                                            ),
                                            // Padding(
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 5),
                                            //   child: Container(
                                            //     height: 13,
                                            //     width: 2,
                                            //     color: ColorTheme.greyColor,
                                            //   ),
                                            // ),
                                            // ConstrainedBox(
                                            //   constraints:
                                            //       BoxConstraints(maxWidth: 100),
                                            //   child: Text(
                                            //     item.collectedBy,
                                            //     style: const TextStyle(
                                            //       fontWeight: FontWeight.w600,
                                            //       fontSize: 14,
                                            //       color: ColorTheme.greyColor,
                                            //     ),
                                            //     overflow: TextOverflow.ellipsis,
                                            //     maxLines: 1,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(maxWidth: 80),
                                              child: Text(
                                                firstName(item.waiter),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: ColorTheme.greyColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Text('-')),
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(maxWidth: 80),
                                              child: Text(
                                                firstName(item.collectedBy),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: ColorTheme.greyColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        final isAggregator =
                                            item.orderPlateform != null;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => isAggregator
                                                ? AggregatorOrderDetails(
                                                    orderId: item
                                                        .orderId, // dynamic — no .toString() needed
                                                    controller: controller!,
                                                  )
                                                : DailySalesOrderDetails(
                                                    orderId:
                                                        item.orderId.toString(),
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
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            Platform.isWindows ? 150 : 50),
                                    child: Text(
                                      item.paymentType.toString(),
                                      style: TextStyle(
                                        color: item.paymentType
                                                    .toString()
                                                    .toUpperCase() ==
                                                'CANCEL'
                                            ? ColorTheme.badgeRed
                                            : item.paymentType
                                                        .toString()
                                                        .toUpperCase() ==
                                                    'MERGE'
                                                ? ColorTheme.badgeRed
                                                : ColorTheme.greenColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    item.amount.toString(),
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

  String firstName(String text) {
    if (text.isEmpty || text.trim().isEmpty) {
      return '';
    }
    return text.trim().split(' ').first;
  }

  String _formatDateTime(String? dateTime, {onlyDate = false}) {
    if (dateTime == null) return '';
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return onlyDate
          ? DateFormat('dd MMM yyyy').format(parsedDate)
          : DateFormat('HH:mm').format(parsedDate);
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
