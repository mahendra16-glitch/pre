import 'dart:developer';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/bottom_sheet/show_add_expense_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/widget/add_stock_tab.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/widget/manage_expense_tab.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseManagementScreen> createState() =>
      _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  ExpenseManagementController? expenseController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    expenseController = Get.find<ExpenseManagementController>();
    // Add listener for tab changes
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        // Only clear when moving AWAY from tab 0 to tab 1
        // AND not in edit mode
        if (tabController.previousIndex == 0 &&
            tabController.index == 1 &&
            !expenseController!.isEditMode) {
          expenseController?.manageExpenseResetData(false);
        }
      }
    });
    apiCalling();
    super.initState();
  }

  apiCalling() async {
    await expenseController?.getUnit();
    log("getUnit");
    await expenseController?.fetchCategory();
    log("fetchCategory");
    await expenseController?.expensePaymentMethod(isShowAll: true);
    log("expensePaymentMethod");
    await expenseController?.fetchManageExpenses();
    await expenseController?.fetchMasterExpenses();
    log("Expenses Report");
    await expenseController?.fetchExpenseReport();
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
      final fromDate = expenseController?.selectedReportFromDate != null
          ? DateFormat('dd_MM_yyyy')
              .format(expenseController!.selectedReportFromDate!)
          : DateFormat('dd_MM_yyyy').format(DateTime.now());

      final toDate = expenseController?.selectedReportToDate != null
          ? DateFormat('dd_MM_yyyy')
              .format(expenseController!.selectedReportToDate!)
          : DateFormat('dd_MM_yyyy').format(DateTime.now());

      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Expense_Report_${expenseController?.selectedReportFromDate}_to_${expenseController?.selectedReportToDate}';

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
      for (int i = 0; i < expenseController!.expenseReportList.length; i++) {
        final item = expenseController!.expenseReportList[i];
        List<dynamic> rowData = [
          item['exp_name'] ?? '',
          item['category_name'] ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          item['unit']?.toString() ?? '',
          double.tryParse(item['d_amount']?.toString() ?? '0.0'),
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
    }
  }

  Future<void> _exportExpenseReportMobile() async {
    try {
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name =
          'Expense_Report_${expenseController?.selectedReportFromDate}_to_${expenseController?.selectedReportToDate}';

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
      for (int i = 0; i < expenseController!.expenseReportList.length; i++) {
        final item = expenseController!.expenseReportList[i];
        List<dynamic> rowData = [
          item['exp_name'] ?? '',
          item['category_name'] ?? '',
          double.tryParse(item['quantity']?.toString() ?? '0'),
          item['unit']?.toString() ?? '',
          double.tryParse(item['d_amount']?.toString() ?? '0.0'),
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
      for (int col = 0; col < headers.length; col++) {
        sheet.autoFitColumn(col + 1);
      }

      // Save file in temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          "Expense_Report_${expenseController?.selectedReportFromDate}_to_${expenseController?.selectedReportToDate}.xlsx";
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
    }
  }

  @override
  void dispose() {
    tabController.dispose();

    // Reset everything when screen is closed
    expenseController?.manageExpenseResetData(false);
    expenseController?.isEditMode = false;
    expenseController?.currentEditExpense = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseManagementController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: ColorTheme.manageBgColor,
          appBar: CustomAppBar(
            leadingValue: true,
            // leadingWidget: Padding(
            //   padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
            //   child: IconButton(
            //     icon: Image.asset(Images.menu,
            //         color: ColorTheme.appColor, height: 16),
            //     onPressed: () {
            //       scaffoldKey.currentState?.openDrawer();
            //     },
            //   ),
            // ),
            leadingWidget: IconButton(
              icon: const Icon(
                Icons.chevron_left_outlined,
                color: Color(0xFFF26B33),
                size: 30,
              ),
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
            ),
            titleText: AppString.expense,
            actions: [
              uploadIconWidget(
                onDownLoadTap: () async {
                  // await expenseController?.expenseDownloadSample();
                  // await expenseController?.fetchExpenseReport();
                  // exportExpenseReportToExcel();
                  Get.to(() => BulkImportScreen(
                        tittleName: AppString.expenseManagement,
                        controller: Get.find<ExpenseManagementController>(),
                      ));
                  // Get.to(() => BulkImportScreen(
                  //       tittleName: AppString.expenseManagement,
                  //       controller: Get.find<ExpenseManagementController>(),
                  //     ));
                },
                onUploadTap: () async {
                  // await expenseController?.expenseImportExpense();
                  Get.to(() => BulkImportScreen(
                        tittleName: AppString.expenseManagement,
                        controller: Get.find<ExpenseManagementController>(),
                      ));
                },
                isPLusShow: false,
                onPlusTap: () {
                  // showAddExpenseBottomSheet(
                  //   context,
                  //   expenseController: expenseController!,
                  //   onSubmitTap: () {
                  //     expenseController?.addManageExpense();
                  //   },
                  // );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Divider(color: ColorTheme.grey, height: 1),
              Obx(
                () => Row(
                  children: [
                    9.width,
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // When clicking Add Expense tab
                          // if (!expenseController!.isEditMode) {
                          //   // Not in edit mode, clear everything
                          //   expenseController?.manageExpenseResetData(false);
                          // }
                          // expenseController?.tabValue.value = 0;
                          // print("Switched to Add Expense tab");
                          expenseController?.tabValue.value = 0;
                          await expenseController?.fetchManageExpenses();
                        },
                        child: Container(
                          color: expenseController?.tabValue == 0
                              ? ColorTheme.whiteColor
                              : ColorTheme.transparent,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              "Add Expenses",
                              style: TextStyle(
                                color: expenseController?.tabValue == 0
                                    ? ColorTheme.greenColor
                                    : ColorTheme.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    9.width,
                    Container(width: 0.5, height: 60, color: ColorTheme.grey),
                    9.width,
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // When switching to Manage Expense tab
                          // Clear edit mode
                          // expenseController?.isEditMode = false;
                          // expenseController?.currentEditExpense = null;
                          // expenseController?.manageExpenseResetData(false);
                          // expenseController?.tabValue.value = 1;
                          // print("Switched to Manage Expense tab");
                          expenseController?.tabValue.value = 1;
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          color: expenseController?.tabValue == 1
                              ? ColorTheme.whiteColor
                              : ColorTheme.transparent,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              AppString.manageExpense,
                              style: TextStyle(
                                  color: expenseController?.tabValue == 1
                                      ? ColorTheme.greenColor
                                      : ColorTheme.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    9.width,
                  ],
                ),
              ),
              Divider(color: ColorTheme.grey, height: 1),
              // 20.height,
              Expanded(
                child: Obx(() => expenseController?.tabValue == 1
                    ? ManageExpenseTab(
                        manageList: expenseController?.manageList ?? [],
                        expenseController: expenseController!)
                    : AddExpenseScreen(
                        // masterList: expenseController?.masterList ?? [],
                        // categoryList: expenseController?.categoryList ?? [],
                        expenseController: expenseController!,
                        expense: {},
                        isEdit: false,
                        onSubmitTap: () {
                          expenseController?.addManageExpense();
                        },
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
