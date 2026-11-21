import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/controller/tab_management_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_view_tab_bill_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class CustomerItem extends StatelessWidget {
  final int i;
  final TextEditingController controller;
  final TextEditingController searchController;

  const CustomerItem({
    Key? key,
    required this.i,
    required this.controller,
    required this.searchController,
  }) : super(key: key);

  Future<void> exportToExcel() async {
    if (Platform.isWindows) {
      await _exportToExcelWindows();
    } else {
      await _exportToExcelMobile();
    }
  }

  Future<void> _exportToExcelWindows() async {
    try {
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Customer Tab Bills Report';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.left;
      cellStyle.vAlign = xlsio.VAlignType.center;

      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.hAlign = xlsio.HAlignType.left;
      headerStyle.vAlign = xlsio.VAlignType.center;
      headerStyle.bold = true;

      final model =
          Get.find<TabManagementController>().getViewTabBillsResponseModel;

      if (model == null) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }
      String _formatApiDate(String? raw) {
        if (raw == null || raw.trim().isEmpty) return '';
        try {
          return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw).toLocal());
        } catch (_) {
          return raw;
        }
      }

      final List<CustomerTransactionList> transactionList =
          model.customerTransactionList ?? [];
      final List<CustomerTransactionList> debitList =
          model.customerTransactionListDebit ?? [];
      final tapStartDate = _formatApiDate(model.tapStartDate);
      final lastTapCreditDate = _formatApiDate(model.lastTapCreditDate);
      final lastTapCreditAmount = double.tryParse(
              model.lastTapCreditAmount?.replaceAll(',', '') ?? '0') ??
          0.0;
      final lastTapDebitDate = _formatApiDate(model.lastTapDebitDate);
      final lastTapDebitAmount = double.tryParse(
              model.lastTapDebitAmount?.replaceAll(',', '') ?? '0') ??
          0.0;

      if (transactionList.isEmpty && debitList.isEmpty) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }

      final employeeTapList = Get.find<PosController>()
          .tapManagmentCustomerListResponse!
          .employeeTapList;
      final customer = employeeTapList[i];
      final String name = customer.name;
      final String phone = customer.mobile;

      // Collect all dates for start and end
      List<DateTime> allDates = [];
      for (var item in transactionList) {
        if (item.createdAt != null) {
          allDates.add(DateTime.parse(item.createdAt!));
        }
      }
      for (var item in debitList) {
        if (item.createdAt != null) {
          allDates.add(DateTime.parse(item.createdAt!));
        }
      }

      String startDate = '';
      String endDate = '';
      if (allDates.isNotEmpty) {
        allDates.sort();
        startDate = DateFormat('dd-MM-yyyy').format(allDates.first);
        endDate = DateFormat('dd-MM-yyyy').format(allDates.last);
      }

      // Total Credit
      double totalCredit = 0.0;
      for (var item in transactionList) {
        totalCredit += double.tryParse(
                item.creditOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;
      }

      // Paid
      double paid = 0.0;
      for (var item in debitList) {
        paid += double.tryParse(
                item.debitOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;
      }

      // Remaining
      double remaining = totalCredit - paid;

      // Set summary labels and values
      sheet.getRangeByName('A1').cellStyle = headerStyle;
      sheet.getRangeByName('A1').setText('Name');
      sheet.getRangeByName('B1').setText(name);

      sheet.getRangeByName('A2').cellStyle = headerStyle;
      sheet.getRangeByName('A2').setText('Phone number');
      sheet.getRangeByName('B2').setText(phone);

      // sheet.getRangeByName('A3').cellStyle = headerStyle;
      // sheet.getRangeByName('A3').setText('Start Date');
      // sheet.getRangeByName('B3').setText(startDate);

      // sheet.getRangeByName('A4').cellStyle = headerStyle;
      // sheet.getRangeByName('A4').setText('End Date');
      // sheet.getRangeByName('B4').setText(endDate);

      sheet.getRangeByName('A3').cellStyle = headerStyle;
      sheet.getRangeByName('A3').setText('Total Credit');
      sheet.getRangeByName('B3').number = totalCredit;

      sheet.getRangeByName('A4').cellStyle = headerStyle;
      sheet.getRangeByName('A4').setText('Paid');
      sheet.getRangeByName('B4').number = paid;

      sheet.getRangeByName('A5').cellStyle = headerStyle;
      sheet.getRangeByName('A5').setText('Remaining');
      sheet.getRangeByName('B5').number = remaining;

      //NEW: all 5 keys below Remaining
      sheet.getRangeByName('A6').cellStyle = headerStyle;
      sheet.getRangeByName('A6').setText('Tap Start Date');
      sheet.getRangeByName('B6').setText(tapStartDate);

      sheet.getRangeByName('A7').cellStyle = headerStyle;
      sheet.getRangeByName('A7').setText('Last Tap Credit Date');
      sheet.getRangeByName('B7').setText(lastTapCreditDate);

      sheet.getRangeByName('A8').cellStyle = headerStyle;
      sheet.getRangeByName('A8').setText('Last Tap Credit Amount');
      sheet.getRangeByName('B8').number = lastTapCreditAmount;

      sheet.getRangeByName('A9').cellStyle = headerStyle;
      sheet.getRangeByName('A9').setText('Last Tap Debit Date');
      sheet.getRangeByName('B9').setText(lastTapDebitDate);

      sheet.getRangeByName('A10').cellStyle = headerStyle;
      sheet.getRangeByName('A10').setText('Last Tap Debit Amount');
      sheet.getRangeByName('B10').number = lastTapDebitAmount;

      // Leave row 8 empty

      // Order table headers
      sheet.getRangeByName('A12').setText('Order Date');
      sheet.getRangeByName('B12').setText('Order id');
      sheet.getRangeByName('C12').setText('Amount');

      sheet.getRangeByName('A12:C12').cellStyle = headerStyle;
      sheet.getRangeByName('A12:C12').cellStyle.bold = true;

      // Populate order data
      for (int i = 0; i < transactionList.length; i++) {
        var item = transactionList[i];
        String orderDate = '';
        if (item.createdAt != null) {
          DateTime date = DateTime.parse(
              item.createdAt!.replaceAll(' ', 'T')); // Adjust parsing if needed
          orderDate = DateFormat('dd-MM-yyyy').format(date);
        } else if (item.createdAt != null) {
          DateTime date = DateTime.parse(item.createdAt!);
          orderDate = DateFormat('dd-MM-yyyy').format(date);
        }
        String orderId =
            item.restaurantOrderId ?? item.orderId.toString() ?? '';
        double amount = double.tryParse(
                item.creditOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;

        int row = 13 + i;
        sheet.getRangeByName('A$row').setText(orderDate);
        sheet.getRangeByName('B$row').setText(orderId);
        sheet.getRangeByName('C$row').number = amount;
      }

      // Apply style to cells if needed
      // For simplicity, apply to all
      sheet.getRangeByName('A1:C${13 + transactionList.length - 1}').cellStyle =
          cellStyle;

      // Auto-fit columns
      sheet.autoFitColumn(1);
      sheet.autoFitColumn(2);
      sheet.autoFitColumn(3);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Customer_Tab_Bills_Report_${customer.name}.xlsx',
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
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Customer Tab Bills Report';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.left;
      cellStyle.vAlign = xlsio.VAlignType.center;

      final model =
          Get.find<TabManagementController>().getViewTabBillsResponseModel;

      if (model == null) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }

      String _formatApiDate(String? raw) {
        if (raw == null || raw.trim().isEmpty) return '';
        try {
          return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw).toLocal());
        } catch (_) {
          return raw;
        }
      }

      final List<CustomerTransactionList> transactionList =
          model.customerTransactionList ?? [];
      final List<CustomerTransactionList> debitList =
          model.customerTransactionListDebit ?? [];
      final tapStartDate = _formatApiDate(model.tapStartDate);
      final lastTapCreditDate = _formatApiDate(model.lastTapCreditDate);
      final lastTapCreditAmount = double.tryParse(
              model.lastTapCreditAmount?.replaceAll(',', '') ?? '0') ??
          0.0;
      final lastTapDebitDate = _formatApiDate(model.lastTapDebitDate);
      final lastTapDebitAmount = double.tryParse(
              model.lastTapDebitAmount?.replaceAll(',', '') ?? '0') ??
          0.0;

      if (transactionList.isEmpty && debitList.isEmpty) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }

      final employeeTapList = Get.find<PosController>()
          .tapManagmentCustomerListResponse!
          .employeeTapList;
      final customer = employeeTapList[i];
      final String name = customer.name;
      final String phone = customer.mobile;

      // Collect all dates for start and end
      List<DateTime> allDates = [];
      for (var item in transactionList) {
        if (item.createdAt != null) {
          allDates.add(DateTime.parse(item.createdAt!));
        }
      }
      for (var item in debitList) {
        if (item.createdAt != null) {
          allDates.add(DateTime.parse(item.createdAt!));
        }
      }

      String startDate = '';
      String endDate = '';
      if (allDates.isNotEmpty) {
        allDates.sort();
        startDate = DateFormat('dd-MM-yyyy').format(allDates.first);
        endDate = DateFormat('dd-MM-yyyy').format(allDates.last);
      }

      // Total Credit
      double totalCredit = 0.0;
      for (var item in transactionList) {
        totalCredit += double.tryParse(
                item.creditOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;
      }

      // Paid
      double paid = 0.0;
      for (var item in debitList) {
        paid += double.tryParse(
                item.debitOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;
      }

      // Remaining
      double remaining = totalCredit - paid;

      // Set summary labels and values
      sheet.getRangeByName('A1').setText('Name');
      sheet.getRangeByName('B1').setText(name);

      sheet.getRangeByName('A2').setText('Phone number');
      sheet.getRangeByName('B2').setText(phone);

      // sheet.getRangeByName('A3').setText('Start Date');
      // sheet.getRangeByName('B3').setText(startDate);

      // sheet.getRangeByName('A4').setText('End Date');
      // sheet.getRangeByName('B4').setText(endDate);

      sheet.getRangeByName('A3').setText('Total Credit');
      sheet.getRangeByName('B3').number = totalCredit;

      sheet.getRangeByName('A4').setText('Paid');
      sheet.getRangeByName('B4').number = paid;

      sheet.getRangeByName('A5').setText('Remaining');
      sheet.getRangeByName('B5').number = remaining;

      //NEW: all 5 keys below Remaining

      sheet.getRangeByName('A6').setText('Tap Start Date');
      sheet.getRangeByName('B6').setText(tapStartDate);

      sheet.getRangeByName('A7').setText('Last Tap Credit Date');
      sheet.getRangeByName('B7').setText(lastTapCreditDate);

      sheet.getRangeByName('A8').setText('Last Tap Credit Amount');
      sheet.getRangeByName('B8').number = lastTapCreditAmount;

      sheet.getRangeByName('A9').setText('Last Tap Debit Date');
      sheet.getRangeByName('B9').setText(lastTapDebitDate);

      sheet.getRangeByName('A10').setText('Last Tap Debit Amount');
      sheet.getRangeByName('B10').number = lastTapDebitAmount;

      // Leave row 8 empty

      // Order table headers
      sheet.getRangeByName('A12').setText('Order Date');
      sheet.getRangeByName('B12').setText('Order id');
      sheet.getRangeByName('C12').setText('Amount');

      // Populate order data
      for (int i = 0; i < transactionList.length; i++) {
        var item = transactionList[i];
        String orderDate = '';
        if (item.createdAt != null) {
          DateTime date = DateTime.parse(
              item.createdAt!.replaceAll(' ', 'T')); // Adjust parsing if needed
          orderDate = DateFormat('dd-MM-yyyy').format(date);
        } else if (item.createdAt != null) {
          DateTime date = DateTime.parse(item.createdAt!);
          orderDate = DateFormat('dd-MM-yyyy').format(date);
        }
        String orderId =
            item.restaurantOrderId ?? item.orderId.toString() ?? '';
        double amount = double.tryParse(
                item.creditOrderAmount?.replaceAll(',', '') ?? '0.0') ??
            0.0;

        int row = 13 + i;
        sheet.getRangeByName('A$row').setText(orderDate);
        sheet.getRangeByName('B$row').setText(orderId);
        sheet.getRangeByName('C$row').number = amount;
      }

      // Apply style to cells if needed
      // For simplicity, apply to all
      sheet.getRangeByName('A1:C${13 + transactionList.length - 1}').cellStyle =
          cellStyle;

      // Auto-fit columns
      sheet.autoFitColumn(1);
      sheet.autoFitColumn(2);
      sheet.autoFitColumn(3);

      final tempDir = await getTemporaryDirectory();
      final fileName = "Customer_Tab_Bills_Report_${customer.name}.xlsx";
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
    final employeeTapList = Get.find<PosController>()
        .tapManagmentCustomerListResponse!
        .employeeTapList;
    final customer = employeeTapList[i];

    return Padding(
      padding: EdgeInsets.only(top: i == 0 ? 0 : 13),
      child: Container(
        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xFFF8F8F8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${customer.mobile}',
                style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 13 : 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${customer.name}',
                style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 13 : 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                double.parse('${customer.balance}').toStringAsFixed(2),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Get.find<TabManagementController>()
                    .getViewTabBills(customer.id.toString());
                await exportToExcel();
              },
              child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.file_download_outlined,
                    color: ColorTheme.appColor,
                    size: 30,
                  )),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                searchController.clear();
                controller.text = '0';
                Get.find<PosController>().setTapCustomerData(null, false);
                controller.text = '0';
                Get.toNamed(RouteHelper.getViewTabBills(
                  '${customer.id}',
                  '${customer.name ?? ''}',
                  '${customer.mobile ?? ''}',
                ));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SvgPicture.asset(
                  Images.ic_tab_bills,
                  height: 22,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Get.find<PosController>().setTapCustomerData(i, true);
                controller.text = '0';
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: SvgPicture.asset(
                  Images.ic_paymentTab,
                  height: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
