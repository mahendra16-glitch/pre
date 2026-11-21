import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_order_details.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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

class DailyWaiterSalesDetailsReport extends StatefulWidget {
  final String? waiterName;

  const DailyWaiterSalesDetailsReport({key, this.waiterName});

  @override
  State<DailyWaiterSalesDetailsReport> createState() =>
      _DailyWaiterSalesDetailsReportState();
}

class _DailyWaiterSalesDetailsReportState
    extends State<DailyWaiterSalesDetailsReport> {
  // final controller = Get.put(ReportSummeryController());
  final controller = Get.find<ReportSummeryController>();

  TextEditingController? waiterController;
  String waiterName =
      '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}';

  @override
  void initState() {
      controller.paymentTypes.clear();
      controller.paymentTypes.add(PaymentModes(
          displayName: 'All Payment Types', name: 'All Payment Types'));
      controller.selectedPaymentType.value = controller.paymentTypes.first;
      controller.paymentTypes.addAll(Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .paymentModes!);

      controller.paymentTypes
          .add(PaymentModes(displayName: 'Cancel', name: 'Cancel'));
      controller.paymentTypes
          .add(PaymentModes(displayName: 'Unpaid', name: 'Unpaid'));
    apiCall();
    waiterController =
        TextEditingController(text: capitalizeWord(waiterName ?? ''));
    super.initState();
  }

  void apiCall() async {
    await controller.waiterDailyReportApiCall();
    controller.fromDate.value = DateTime.now();
    controller.toDate.value = DateTime.now();
    await controller.dailyWaiterSalesItemsList(
        DateFormat('d-M-yyyy').format(controller.fromDate.value));
  }

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
          DateFormat('dd_MM_yyyy').format(controller.fromDate.value);
      final toDate = DateFormat('dd_MM_yyyy').format(controller.toDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Daily Waiter Sales Report ${fromDate} to ${toDate} ${controller.selectedOrderType.value} ${controller.selectedPaymentType.value} ${controller.selectedWaiter.value} ${controller.selectedOrderCollectedType.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Order ID',
        'Order Date',
        'Order Time',
        'Order Type',
        'Waiter(Ordered)',
        'Waiter(Collected)',
        'Payment Type',
        'Amount',
        'Gst Amount',
        'Delivery Charge',
        'Service Tax',
        'Tip Amount',
        'Discount'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;
      for (var report in controller.filteredWaiterDailySalesList) {
        for (var item in report.report) {
          List<dynamic> rowData = [
            item.restaurantOrderId.toString() ?? '',
            _formatDateTime(item.orderNewDate, onlyDate: true),
            _formatDateTime(item.orderNewDate),
            item.orderType.toString() ?? '',
            item.waiter.toString() ?? '',
            item.collectedBy.toString() ?? '',
            item.paymentType.toString() ?? '',
            double.tryParse(
                item.amount.toString().replaceAll(',', '') ?? '0.00'),
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

      if (controller.dailyWaiterSalesList.value != null) {
        final grandTotal = controller.dailyWaiterSalesList.value!.grandTotal;
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;
        rowIndex++;

        Map<String, dynamic> total = {
          'Amount': grandTotal.paidRevenue,
          'Gst Amount': grandTotal.gstAmount,
          'Service Tax': grandTotal.serviceTax,
          'Delivery Charge': grandTotal.deliveryCharge,
          'Tip Amount': grandTotal.tipAmount,
          'Discount': grandTotal.totalDiscount,
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

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName:
            'Daily_Waiter_Sales_Report_${fromDate}_${toDate}_${controller.selectedOrderType.value}_${controller.selectedPaymentType.value}_${controller.selectedWaiter.value}_${controller.selectedOrderCollectedType.value}.xlsx',
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
          DateFormat('dd_MM_yyyy').format(controller.fromDate.value);
      final toDate = DateFormat('dd_MM_yyyy').format(controller.toDate.value);
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Daily Waiter Sales Report ${fromDate} to ${toDate} ${controller.selectedOrderType.value} ${controller.selectedPaymentType.value} ${controller.selectedWaiter.value} ${controller.selectedOrderCollectedType.value}';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      List<String> headers = [
        'Order ID',
        'Order Date',
        'Order Time',
        'Order Type',
        'Waiter(Ordered)',
        'Waiter(Collected)',
        'Payment Type',
        'Amount',
        'Gst Amount',
        'Delivery Charge',
        'Service Tax',
        'Tip Amount',
        'Discount',
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
        sheet.autoFitColumn(col + 1);
      }

      int rowIndex = 2;
      for (var report in controller.filteredWaiterDailySalesList) {
        for (var item in report.report) {
          List<dynamic> rowData = [
            item.restaurantOrderId.toString() ?? '',
            _formatDateTime(item.orderNewDate, onlyDate: true),
            _formatDateTime(item.orderNewDate),
            item.orderType.toString() ?? '',
            item.waiter.toString() ?? '',
            item.collectedBy.toString() ?? '',
            item.paymentType.toString() ?? '',
            double.tryParse(
                item.amount.toString().replaceAll(',', '') ?? '0.00'),
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

      if (controller.dailyWaiterSalesList.value != null) {
        final grandTotal = controller.dailyWaiterSalesList.value!.grandTotal;
        final xlsio.Style boldStyle = workbook.styles.add('boldStyle');
        boldStyle.hAlign = xlsio.HAlignType.center;
        boldStyle.vAlign = xlsio.VAlignType.center;
        boldStyle.bold = true;
        rowIndex++;

        Map<String, dynamic> total = {
          'Amount': grandTotal.paidRevenue,
          'Gst Amount': grandTotal.gstAmount,
          'Service Tax': grandTotal.serviceTax,
          'Delivery Charge': grandTotal.deliveryCharge,
          'Tip Amount': grandTotal.tipAmount,
          'Discount': grandTotal.totalDiscount
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

      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Daily_Waiter_Sales_Report_${fromDate}_${toDate}_${controller.selectedOrderType.value}_${controller.selectedPaymentType.value}_${controller.selectedWaiter.value}_${controller.selectedOrderCollectedType.value}.xlsx";
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

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // DateTime parsedDate;
    // try {
    //   parsedDate = DateFormat('d-M-yyyy').parse(date!);
    // } catch (e) {
    //   // Fallback to current date if parsing fails
    //   parsedDate = DateTime.now();
    //   print("Error parsing date: $e, using current date as fallback");
    // }

    // Set the fromDate and toDate in the controller to the parsed date
    // controller!.fromDate.value = parsedDate;
    // controller!.toDate.value = parsedDate;
    // controller!.dailySalesItemsList(date!);

    DateTime fromDateChecker = DateTime.now();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorTheme.grey200Color,
      // drawer: Drawer(
      //   backgroundColor: Color(0xFFF8F8F8),
      //   child: SafeArea(
      //     child: ListView(
      //       // padding: EdgeInsets.zero,

      //       children: <Widget>[
      //         Align(
      //           alignment: Alignment.centerLeft,
      //           child: Padding(
      //             padding: const EdgeInsets.only(top: 20, left: 15),
      //             child: Image.asset(
      //               Images.brand_logo,
      //               height: Get.height * 0.1,
      //             ),
      //           ),
      //         ),
      //         Align(
      //           alignment: Alignment.centerLeft,
      //           child: Padding(
      //             padding: const EdgeInsets.only(left: 15, top: 7),
      //             child: Text(
      //               '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
      //               style: poppinsMedium.copyWith(
      //                   fontSize: 13, color: ColorTheme.hintText),
      //             ),
      //           ),
      //         ),
      //         if (Get.find<AuthController>()
      //             .profileModel!
      //             .role!
      //             .contains('menu'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Menu Management',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();
      //                     Get.find<ExpenseManagementController>()
      //                         .tabValue
      //                         .value = 0;
      //                     await Get.to(() => MenuHomeScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Manage Food',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => CategoriesScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Categories',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => AddonsScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Addons',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         if (Get.find<AuthController>()
      //             .profileModel!
      //             .role!
      //             .contains('expence'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Expense',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();
      //                     Get.find<ExpenseManagementController>()
      //                         .tabValue
      //                         .value = 0;
      //                     await Get.to(() => ExpenseManagementScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Manage Expenses',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();
      //                     Get.find<ExpenseManagementController>()
      //                         .tabValue
      //                         .value = 1;

      //                     await Get.to(() => ExpenseManagementScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Add Stock',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         if (Get.find<AuthController>()
      //             .profileModel!
      //             .role!
      //             .contains('inventory'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Inventory Management',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => CurrentStocksScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Manage Stocks',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => AddIngredientsScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Master Ingredients',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => PurchaseReportScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Purchase Report',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 15.height,
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();

      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Get.to(() => RecipesListScreen());
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Recipes List',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         if (Get.find<AuthController>()
      //             .profileModel!
      //             .role!
      //             .contains('sattle_report'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Settlement',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 InkWell(
      //                   onTap: () async {
      //                     scaffoldKey.currentState!.closeDrawer();
      //                     // _subscriptionBtStatus!.cancel();
      //                     FocusManager.instance.primaryFocus?.unfocus();

      //                     await Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                             builder: (builder) => SettlementScreen()));
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 0),
      //                       child: Text(
      //                         'Settlement',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         if (Get.find<AuthController>()
      //                 .profileModel!
      //                 .role!
      //                 .contains('report_summery') ||
      //             Get.find<AuthController>()
      //                 .profileModel!
      //                 .role!
      //                 .contains('waiter_revenue_report'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Revenue',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 if (Get.find<AuthController>()
      //                     .profileModel!
      //                     .role!
      //                     .contains('report_summery'))
      //                   InkWell(
      //                     onTap: () async {
      //                       FocusManager.instance.primaryFocus?.unfocus();
      //                       scaffoldKey.currentState?.closeDrawer();

      //                       await Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (builder) => ReportSummeryPage()));
      //                     },
      //                     child: Align(
      //                       alignment: Alignment.centerLeft,
      //                       child: Padding(
      //                         padding: const EdgeInsets.only(
      //                             left: 15, top: 0, bottom: 10),
      //                         child: Text(
      //                           'Report Summary',
      //                           style: poppinsMedium.copyWith(
      //                               fontSize: 13, color: ColorTheme.hintText),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 // const SizedBox(
      //                 //   height: 10,
      //                 // ),
      //                 if (Get.find<AuthController>()
      //                     .profileModel!
      //                     .role!
      //                     .contains('waiter_revenue_report'))
      //                   InkWell(
      //                     onTap: () async {
      //                       FocusManager.instance.primaryFocus?.unfocus();
      //                       scaffoldKey.currentState?.closeDrawer();
      //                       // if (Get.find<AuthController>()
      //                       //     .profileModel!
      //                       //     .role!
      //                       //     .contains('waiter_revenue_report'))
      //                       await Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (builder) =>
      //                                   DailyWaiterSalesDetailsReport()));
      //                     },
      //                     child: Align(
      //                       alignment: Alignment.centerLeft,
      //                       child: Padding(
      //                         padding: const EdgeInsets.only(left: 15, top: 0),
      //                         child: Text(
      //                           'Report Summary(W)',
      //                           style: poppinsMedium.copyWith(
      //                               fontSize: 13, color: ColorTheme.hintText),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         if (Get.find<AuthController>()
      //             .profileModel!
      //             .role!
      //             .contains('employee'))
      //           Theme(
      //             data: Theme.of(context)
      //                 .copyWith(dividerColor: Colors.transparent),
      //             child: ExpansionTile(
      //               iconColor: ColorTheme.hintText,
      //               initiallyExpanded: true,
      //               expandedAlignment: Alignment.centerLeft,
      //               title: Text(
      //                 'Employee Management',
      //                 style: poppinsMedium.copyWith(
      //                     fontSize: 14, color: ColorTheme.hintText),
      //               ),
      //               children: <Widget>[
      //                 InkWell(
      //                   onTap: () async {
      //                     FocusManager.instance.primaryFocus?.unfocus();
      //                     scaffoldKey.currentState?.closeDrawer();

      //                     await Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                             builder: (builder) => EmployeeMgmtScreen()));
      //                   },
      //                   child: Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Padding(
      //                       padding: const EdgeInsets.only(left: 15, top: 10),
      //                       child: Text(
      //                         'Employee Management',
      //                         style: poppinsMedium.copyWith(
      //                             fontSize: 13, color: ColorTheme.hintText),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.only(top: 15, left: 15),
      //                   child: DottedLine(
      //                     direction: Axis.horizontal,
      //                     alignment: WrapAlignment.center,
      //                     lineThickness: 1.0,
      //                     dashLength: 2.5,
      //                     dashColor: ColorTheme.hintText,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         Theme(
      //           data: Theme.of(context)
      //               .copyWith(dividerColor: Colors.transparent),
      //           child: ExpansionTile(
      //             iconColor: ColorTheme.hintText,
      //             initiallyExpanded: true,
      //             expandedAlignment: Alignment.centerLeft,
      //             title: Text(
      //               'My Profile',
      //               style: poppinsMedium.copyWith(
      //                   fontSize: 14, color: ColorTheme.hintText),
      //             ),
      //             children: <Widget>[
      //               InkWell(
      //                 onTap: () {
      //                   scaffoldKey.currentState?.closeDrawer();
      //                   FocusManager.instance.primaryFocus?.unfocus();

      //                   String logo = '';
      //                   if (!Get.find<AuthController>()
      //                           .profileModel!
      //                           .role!
      //                           .contains('order') &&
      //                       Get.find<AuthController>()
      //                           .profileModel!
      //                           .role!
      //                           .contains('bill')) {
      //                     logo = Images.ic_cashier_app_logo;
      //                   } else if (Get.find<AuthController>()
      //                       .profileModel!
      //                       .role!
      //                       .contains('report')) {
      //                     logo = Images.ic_owner_app_logo;
      //                   } else if (Get.find<AuthController>()
      //                       .profileModel!
      //                       .role!
      //                       .contains('Manager')) {
      //                     logo = Images.ic_manager_app_logo;
      //                   } else {
      //                     logo = Images.ic_waiter_app_logo;
      //                   }

      //                   Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                           builder: ((context) => EmployeeResetPassword(
      //                                 resetToken: Get.find<AuthController>()
      //                                     .getUserToken(),
      //                                 email: Get.find<AuthController>()
      //                                     .profileModel!
      //                                     .empEmail!,
      //                                 image: logo,
      //                                 password: '',
      //                                 fromPasswordChange: true,
      //                               ))));

      //                   // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
      //                   //     Get.find<AuthController>().profileModel.empEmail,
      //                   //     Get.find<AuthController>().getUserToken(),
      //                   //     'password-change'));
      //                   // Get.toNamed(RouteHelper.getTapManagementRoute());
      //                 },
      //                 child: Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Padding(
      //                     padding: EdgeInsets.only(left: 15, top: 15),
      //                     child: Text(
      //                       'Reset Password',
      //                       style: poppinsMedium.copyWith(
      //                           fontSize: 13, color: ColorTheme.hintText),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               // if (GetPlatform.isAndroid)
      //               //   InkWell(
      //               //     onTap: () {
      //               //       scaffoldKey.currentState.closeDrawer();
      //               //       FocusManager.instance.primaryFocus?.unfocus();

      //               //       Navigator.push(
      //               //           context,
      //               //           MaterialPageRoute(
      //               //               builder: (builder) => UsbGetPrinterIp()));
      //               //       // Get.toNamed(RouteHelper.getTapManagementRoute());
      //               //     },
      //               //     child: Align(
      //               //       alignment: Alignment.centerLeft,
      //               //       child: Padding(
      //               //         padding: const EdgeInsets.only(left: 15, top: 10),
      //               //         child: Text(
      //               //           'Usb Printer Configuration',
      //               //           style: poppinsMedium.copyWith(
      //               //               fontSize: 13, color: ColorTheme.hintText),
      //               //         ),
      //               //       ),
      //               //     ),
      //               //   ),
      //               InkWell(
      //                 onTap: () {
      //                   FocusManager.instance.primaryFocus?.unfocus();
      //                   scaffoldKey.currentState?.closeDrawer();

      //                   Get.bottomSheet(
      //                     ConfirmationDialog(
      //                         icon: Images.support,
      //                         description:
      //                             'Are you sure you want to log out from My Genie?',
      //                         isLogOut: true,
      //                         onYesPressed: () async {
      //                           try {
      //                             Response response =
      //                                 await Get.find<AuthController>().logout();
      //                             if (response.statusCode == 200) {
      //                               Get.find<RestaurantController>()
      //                                   .clearProductList();
      //                               Get.find<AuthController>()
      //                                   .clearSharedData();
      //                               Get.offAllNamed(
      //                                   RouteHelper.getSignInRoute());
      //                             }
      //                           } catch (e) {
      //                             print(e);
      //                           }
      //                           // socket.disconnect();
      //                           // Get.find<RestaurantController>()
      //                           //     .clearProductList();
      //                           // Get.find<AuthController>().clearSharedData();
      //                           // Get.offAllNamed(RouteHelper.getSignInRoute());
      //                         }),
      //                   );
      //                 },
      //                 child: Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: Padding(
      //                     padding: const EdgeInsets.only(left: 15, top: 15),
      //                     child: Text(
      //                       'Logout',
      //                       style: poppinsMedium.copyWith(
      //                           fontSize: 13, color: ColorTheme.hintText),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Align(
      //           alignment: Alignment.centerLeft,
      //           child: Padding(
      //             padding: const EdgeInsets.only(left: 15, top: 10),
      //             child: Text(
      //               'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
      //               style: poppinsMedium.copyWith(
      //                   fontSize: 13, color: ColorTheme.hintText),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.redColor,
            size: 22,
          ),
          onPressed: () {
            Get.back();
            controller.resetFiltersForDailyWaiterRevenueReport();
          },
        ),
        // leading: IconButton(
        //   icon:
        //       Image.asset(Images.menu, color: ColorTheme.appColor, height: 16),
        //   onPressed: () {
        //     scaffoldKey.currentState?.openDrawer();
        //     controller.resetFiltersForDailyWaiterRevenueReport();
        //   },
        // ),
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              "Waiter ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.redColor,
              ),
            ),
            Text(
              "Revenue Report",
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
          InkWell(
              onTap: () {
                exportToExcel();
              },
              child:
                  SizedBox(width: 25, child: SvgPicture.asset(Images.export))),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
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
                    //From Date
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
                              initialDate: controller.fromDate.value,
                              // firstDate: DateTime(2000),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),

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
                                (picked.isBefore(controller.toDate.value) ||
                                    picked.isAtSameMomentAs(
                                        controller.toDate.value))) {
                              controller.fromDate.value = picked;
                              await controller.dailyWaiterSalesItemsList(
                                  DateFormat('d-M-yyyy').format(picked));
                            } else {
                              Get.snackbar(
                                'Select valid Date',
                                "Select a date which lower than and equal to ${DateFormat('dd-MM-yyyy').format(controller.toDate.value)}",
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
                                          .format(controller.fromDate.value),
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

                    //To Date
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: controller.toDate.value,
                              // firstDate: DateTime(2000),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),

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
                                (picked.isAfter(controller.fromDate.value) ||
                                    picked.isAtSameMomentAs(
                                        controller.fromDate.value))) {
                              controller.toDate.value = picked;
                              await controller.dailyWaiterSalesItemsList(
                                  DateFormat('d-M-yyyy').format(picked));
                            } else {
                              Get.snackbar(
                                'Select valid Date',
                                "Select a date which greater than and equal to ${DateFormat('dd-MM-yyyy').format(controller.fromDate.value)}",
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
                                          .format(controller.toDate.value),
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
                              color: controller.showFilterPanel.value
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              if (controller.showFilterPanel.value) {
                                // If panel is open → closing it, so reset filters
                                controller.showFilterPanel.value = false;
                                controller
                                    .resetFiltersForDailyWaiterRevenueReport();
                              } else {
                                // Opening the panel → no reset
                                controller.showFilterPanel.value = true;
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
                  visible: controller.showFilterPanel.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Payment Type Dropdown
                            Expanded(
                              child: Obx(() => DropdownButtonFormField2<PaymentModes>(
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
                                    value:  controller.selectedPaymentType.value,
                                    items: controller.paymentTypes
                                        .map((type) => DropdownMenuItem<PaymentModes>(
                                              value: type,
                                              child: Text(
                                                type.displayName??'',
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
                                      controller.selectedPaymentType.value =
                                          value ?? controller.paymentTypes.first;
                                      controller.dailyWaiterSalesItemsList(
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
                                    value: controller
                                            .selectedOrderType.value.isEmpty
                                        ? null
                                        : controller.selectedOrderType.value,
                                    items: controller.orderTypes
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
                                      controller.selectedOrderType.value =
                                          value ?? 'All Order';
                                      controller.dailyWaiterSalesItemsList(
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
                            // Expanded(
                            //   child: Obx(() => DropdownButtonFormField2<String>(
                            //         isExpanded: true,
                            //         decoration: InputDecoration(
                            //           labelText: "Waiter",
                            //           labelStyle:
                            //               TextStyle(color: ColorTheme.greyColor),
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
                            //         value: controller!.selectedWaiter.value,
                            //         items: controller!.waiters
                            //             .map((waiter) => DropdownMenuItem<String>(
                            //                   value: waiter,
                            //                   child: Text(
                            //                     waiter,
                            //                     style: poppinsMedium.copyWith(
                            //                       color: Color(0xFF828282),
                            //                       fontSize: 12,
                            //                     ),
                            //                     overflow: TextOverflow.ellipsis,
                            //                     maxLines: 1,
                            //                   ),
                            //                 ))
                            //             .toList(),
                            //         onChanged: (value) {
                            //           controller!.selectedWaiter.value =
                            //               value ?? 'All Waiters';
                            //           controller!.dailySalesItemsList(
                            //               DateFormat('d-M-yyyy')
                            //                   .format(DateTime.now()));
                            //         },
                            //         buttonStyleData: ButtonStyleData(
                            //           padding:
                            //               EdgeInsets.symmetric(horizontal: 0),
                            //           // height: 48,
                            //           width: double.infinity,
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(30),
                            //           ),
                            //           overlayColor: WidgetStateProperty.all(
                            //               Colors.transparent),
                            //         ),
                            //         dropdownStyleData: DropdownStyleData(
                            //           maxHeight: 400,
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(14),
                            //             border: Border.all(
                            //               color: Color(0xFFDCDCDC),
                            //             ),
                            //           ),
                            //         ),
                            //         menuItemStyleData: MenuItemStyleData(
                            //           height: 50,
                            //         ),
                            //       )),
                            // ),
                            Expanded(
                                child: TextField(
                              controller: waiterController,
                              readOnly: true,
                              style: poppinsMedium.copyWith(
                                color: Color(0xFF828282),
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                labelText: "Waiter",
                                labelStyle:
                                    TextStyle(color: ColorTheme.greyColor),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                              ),
                            )),
                            SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: "Waiter Type",
                                      labelStyle: TextStyle(
                                          color: ColorTheme.greyColor),
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
                                    value: controller.selectedOrderCollectedType
                                            .value.isEmpty
                                        ? null
                                        : controller
                                            .selectedOrderCollectedType.value,
                                    items: controller.orderCollectedType
                                        .map((waiter) =>
                                            DropdownMenuItem<String>(
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
                                      controller.selectedOrderCollectedType
                                          .value = value ?? 'All Waiters Type';
                                      controller.dailyWaiterSalesItemsList(
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
                      ],
                    ),
                  ),
                )),
            Container(
              color: ColorTheme.grey200Color,
              child: GestureDetector(
                onTap: () {
                  controller.isExpanded2.value = !controller.isExpanded2.value;
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
                                      .format(controller.fromDate.value),
                                  style: const TextStyle(
                                    color: ColorTheme.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
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
                                      .format(controller.toDate.value),
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
                          '₹ ${controller.dailyWaiterSalesList.value?.grandTotal.paidRevenue ?? "0.00"}',
                          style: const TextStyle(
                            color: ColorTheme.blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Obx(
                        () => Icon(
                          controller.isExpanded2.value
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
                    visible: controller.isExpanded2.value,
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
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.orderRevenue.cash
                            },
                            {
                              'name': 'Card',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.orderRevenue.card
                            },
                            {
                              'name': 'UPI',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.orderRevenue.upi
                            },
                          ].map((item) =>
                              buildSection(item['name']!, '₹${item['value']}')),
                          Divider(),
                          Divider(),
                          // Tab Revenue
                          ...[
                            {
                              'name': 'Credit Cash',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.tabRevenue.tabCash
                            },
                            {
                              'name': 'Credit Card',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.tabRevenue.tabCard
                            },
                            {
                              'name': 'Credit UPI',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.tabRevenue.tabUpi
                            },
                          ].map((item) =>
                              buildSection(item['name']!, '₹${item['value']}')),
                          Divider(),
                          Divider(),
                          // Room Revenue
                          ...[
                            {
                              'name': 'Room Cash',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.roomRevenue.roomCash
                            },
                            {
                              'name': 'Room Card',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.roomRevenue.roomCard
                            },
                            {
                              'name': 'Room UPI',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.roomRevenue.roomUpi
                            },
                          ].map((item) =>
                              buildSection(item['name']!, '₹${item['value']}')),
                          Divider(),
                          Divider(),
                          ...[
                            {
                              'name': 'Tip',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.tipAmount
                            },
                            {
                              'name': 'GST',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.gstAmount
                            },
                            {
                              'name': 'Service Tax',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.serviceTax
                            },
                            {
                              'name': 'Delivery Charge',
                              'value': controller.dailyWaiterSalesList.value
                                  ?.grandTotal.deliveryCharge
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
                    if (controller.isLoadingDailyWaiterSalesListItems.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (controller.filteredWaiterDailySalesList.isEmpty) {
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
                                  color:
                                      ColorTheme.greyColor.withOpacity(0.5))),
                          showBottomBorder: true,
                          columns: const [
                            DataColumn(
                              label: Expanded(
                                flex: 7,
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
                          rows: controller.filteredWaiterDailySalesList
                              .expand((report) => report.report)
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
                                                    color:
                                                        ColorTheme.blackColor,
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
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  firstName(item.waiter),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: ColorTheme.greyColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Text('-')),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  firstName(item.collectedBy),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: ColorTheme.greyColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DailySalesOrderDetails(
                                                  orderId:
                                                      item.orderId.toString(),
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
      ),
    );
  }

  String capitalizeWord(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
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
