import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/tap_managment_reesponse_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/widget/customer_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart' as openFilex;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:url_launcher/url_launcher.dart';

class TapManagementPage extends StatefulWidget {
  @override
  State<TapManagementPage> createState() => _TapManagementPageState();
}

class _TapManagementPageState extends State<TapManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _transactionNoController = TextEditingController();
  TextEditingController _paidController = TextEditingController();
  List<String> filterList = ['Default', 'All'];
  String selectedFilter = 'Default';

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
      sheet.name = 'Employee Tap List Report';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      final List<EmployeeTapList> dataList = Get.find<PosController>()
              .tapManagmentCustomerListResponse
              ?.employeeTapList ??
          [];

      if (dataList.isEmpty) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }

      List<String> headers = [
        'ID',
        'Balance Amount',
        'Name',
        'Mobile',
        'Email'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
      }

      for (int i = 0; i < dataList.length; i++) {
        var item = dataList[i];
        List<dynamic> rowData = [
          item.id ?? 0,
          item.balance ?? 0.0,
          item.name ?? '',
          item.mobile ?? '',
          item.email ?? '',
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is num) {
            cell.number = value.toDouble();
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Auto-fit columns after populating data
      for (int col = 1; col <= headers.length; col++) {
        sheet.autoFitColumn(col);
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Excel File',
        fileName: 'Employee_Tap_List_Report.xlsx',
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
      sheet.name = 'Employee Tap List Report';

      final xlsio.Style cellStyle = workbook.styles.add('style');
      cellStyle.hAlign = xlsio.HAlignType.center;
      cellStyle.vAlign = xlsio.VAlignType.center;

      final List<EmployeeTapList> dataList = Get.find<PosController>()
              .tapManagmentCustomerListResponse
              ?.employeeTapList ??
          [];

      if (dataList.isEmpty) {
        Get.snackbar(
          "Info",
          "No data available to export.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.yellowAccent,
          colorText: Colors.black,
        );
        return;
      }

      List<String> headers = [
        'ID',
        'Balance Amount',
        'Name',
        'Mobile',
        'Email'
      ];

      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.getRangeByName('${String.fromCharCode(65 + col)}1');
        cell.setText(headers[col]);
        cell.cellStyle = cellStyle;
      }

      for (int i = 0; i < dataList.length; i++) {
        var item = dataList[i];
        List<dynamic> rowData = [
          item.id ?? 0,
          item.balance ?? 0.0,
          item.name ?? '',
          item.mobile ?? '',
          item.email ?? '',
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell =
              sheet.getRangeByName('${String.fromCharCode(65 + col)}${i + 2}');
          final value = rowData[col];
          if (value is num) {
            cell.number = value.toDouble();
          } else {
            cell.setText(value.toString());
          }
          cell.cellStyle = cellStyle;
        }
      }

      // Auto-fit columns after populating data
      for (int col = 1; col <= headers.length; col++) {
        sheet.autoFitColumn(col);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = "Employee_Tap_List_Report.xlsx";
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
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    Get.find<PosController>().setPaymentTabIndex(0);
    await Get.find<PosController>().getTapManageMentCustomerList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.chevron_left, size: 35, color: ColorTheme.green),
              color: ColorTheme.appColor,
              onPressed: () {
                Get.find<PosController>().clearTapCustomerData();
                Get.back();
              }),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Column(
            children: [
              MediaQuery.of(context).size.width > 650
                  ? Image.asset(logoHelper.appLogo!, width: Get.width * 0.13)
                  : Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: GetBuilder<PosController>(builder: (posController) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 15),
                          child: Text(
                            'Credit Management',
                            style: poppinsSemiBold.copyWith(fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                              onPressed: () {
                                exportToExcel();
                              },
                              icon: Icon(
                                Icons.file_download_outlined,
                                color: ColorTheme.greyCACACA,
                                size: 30,
                              )),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Divider(
                        color: Color(0xFFE6E6E6),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            // height: 30,
                            width: Get.width * 0.25,
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorTheme.borderGrey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButton<String>(
                              icon: Icon(Icons.keyboard_arrow_down_outlined,
                                  color: ColorTheme.appColor),
                              isExpanded: true,
                              value: selectedFilter,
                              items: filterList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    '$value',
                                    maxLines: 1,
                                    style: poppinsMedium.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                selectedFilter = value!;
                                posController.update();
                              },
                              underline: SizedBox(),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 36,
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.PADDING_SIZE_DEFAULT),
                                  suffixIcon: Icon(Icons.search,
                                      size: 22, color: ColorTheme.appColor),
                                  hintText: 'Search by phone / name / email',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: poppinsRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                onChanged: (value) async {
                                  if (_searchController.text.isEmpty) {
                                    posController.clearTapCustomerData();
                                  }
                                  posController.update();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                    posController.tapManagmentCustomerListResponse == null
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.builder(
                                itemCount: posController
                                    .tapManagmentCustomerListResponse!
                                    .employeeTapList
                                    .length,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  EmployeeTapList tapResponse = posController
                                      .tapManagmentCustomerListResponse!
                                      .employeeTapList[i];
                                  double balance = double.parse(
                                      '${Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].balance}');

                                  return Column(
                                    children: [
                                      _searchController.text.isEmpty
                                          ? selectedFilter == 'Default' &&
                                                  balance == 0
                                              ? SizedBox.shrink()
                                              : CustomerItem(
                                                  searchController:
                                                      _searchController,
                                                  i: i,
                                                  controller: _paidController)
                                          : (tapResponse.name
                                                      .toLowerCase()
                                                      .contains(
                                                          _searchController
                                                              .text
                                                              .toLowerCase())) ||
                                                  tapResponse
                                                      .mobile
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(
                                                          _searchController
                                                              .text
                                                              .toLowerCase()) ||
                                                  (tapResponse
                                                      .email
                                                      .toLowerCase()
                                                      .contains(
                                                          _searchController
                                                              .text
                                                              .toLowerCase()))
                                              ? selectedFilter ==
                                                          'Default' &&
                                                      balance == 0
                                                  ? SizedBox.shrink()
                                                  : CustomerItem(
                                                      searchController:
                                                          _searchController,
                                                      i: i,
                                                      controller:
                                                          _paidController)
                                              : SizedBox.shrink(),
                                      posController.isShowCustomerData &&
                                              posController
                                                      .selectedCustomerIndex ==
                                                  i
                                          ? Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 7,
                                                      right: 7,
                                                      top: 15),
                                                  child: DottedLine(
                                                    direction: Axis.horizontal,
                                                    alignment:
                                                        WrapAlignment.center,
                                                    lineThickness: 1.0,
                                                    dashLength: 2.5,
                                                    dashColor:
                                                        ColorTheme.hintText,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: Dimensions
                                                        .PADDING_SIZE_DEFAULT,
                                                    bottom: Dimensions
                                                        .PADDING_SIZE_SMALL,
                                                    left: 7,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Select Payment Method',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                        fontSize: 15,
                                                        // color: Color.fromRGBO(112, 112, 112, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .PADDING_SIZE_DEFAULT),
                                                  child:
                                                      GetBuilder<PosController>(
                                                          builder:
                                                              (posController) {
                                                    return Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 20),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFF8F8F8),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();

                                                                      posController
                                                                          .setPaymentTabIndex(
                                                                              0);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: Get
                                                                          .width,
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              10),
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(color: posController.selectedPaymentTab == 0 ? Colors.transparent : ColorTheme.borderGrey),
                                                                          color: posController.selectedPaymentTab == 0 ? ColorTheme.appColor : Colors.white,
                                                                          // border:
                                                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                          borderRadius: BorderRadius.circular(7)),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Cash'
                                                                              .tr,
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: 13,
                                                                              color: posController.selectedPaymentTab == 0 ? Colors.white : ColorTheme.appColor),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();

                                                                      posController
                                                                          .setPaymentTabIndex(
                                                                              1);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: Get
                                                                          .width,
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              10),
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                      decoration: BoxDecoration(
                                                                          border:
                                                                              Border.all(color: posController.selectedPaymentTab == 1 ? Colors.transparent : ColorTheme.borderGrey),
                                                                          color: posController.selectedPaymentTab == 1 ? ColorTheme.appColor : Colors.white,
                                                                          borderRadius: BorderRadius.circular(7)),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Card'
                                                                              .tr,
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: 13,
                                                                              color: posController.selectedPaymentTab == 1 ? Colors.white : ColorTheme.appColor),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();

                                                                      posController
                                                                          .setPaymentTabIndex(
                                                                              2);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: Get
                                                                          .width,
                                                                      margin: EdgeInsets.only(
                                                                          right:
                                                                              10),
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(color: posController.selectedPaymentTab == 2 ? Colors.transparent : ColorTheme.borderGrey),
                                                                          color: posController.selectedPaymentTab == 2 ? ColorTheme.appColor : Colors.white,

                                                                          // border:
                                                                          //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                          borderRadius: BorderRadius.circular(7)),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'UPI'
                                                                              .tr,
                                                                          style: poppinsMedium.copyWith(
                                                                              fontSize: 13,
                                                                              color: posController.selectedPaymentTab == 2 ? Colors.white : ColorTheme.appColor),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        15),
                                                            child: DottedLine(
                                                              direction: Axis
                                                                  .horizontal,
                                                              alignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              lineThickness:
                                                                  1.0,
                                                              dashLength: 2.5,
                                                              dashColor:
                                                                  ColorTheme
                                                                      .hintText,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            margin: EdgeInsets.only(
                                                                top: Dimensions
                                                                    .PADDING_SIZE_LARGE,
                                                                bottom: 10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Total payable:',
                                                                      // textAlign: TextAlign.right,
                                                                      style: poppinsMedium
                                                                          .copyWith(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                      height: 36,
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: ColorTheme.borderGrey)),
                                                                      child: Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          '  ' +
                                                                              double.parse('${Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].balance}').toStringAsFixed(2),
                                                                          style:
                                                                              poppinsMedium.copyWith(
                                                                            color:
                                                                                ColorTheme.hintText,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Paid: ',
                                                                      // textAlign: TextAlign.right,
                                                                      style: poppinsMedium
                                                                          .copyWith(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    height: 36,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                7),
                                                                        border: Border.all(
                                                                            color:
                                                                                ColorTheme.borderGrey)),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          _paidController,
                                                                      autofocus:
                                                                          false,
                                                                      keyboardType:
                                                                          TextInputType.numberWithOptions(
                                                                              signed: true),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        // hintText: 'phone'.tr,
                                                                        contentPadding:
                                                                            EdgeInsets.symmetric(horizontal: 10),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(7),
                                                                          borderSide: BorderSide(
                                                                              style: BorderStyle.none,
                                                                              width: 0),
                                                                        ),
                                                                        hintStyle: poppinsMedium.copyWith(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                ColorTheme.hintText),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.white,
                                                                      ),
                                                                      style: poppinsMedium
                                                                          .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                      onChanged:
                                                                          (value) async {
                                                                        posController
                                                                            .update();
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        15),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      'Balance: ',
                                                                      // textAlign: TextAlign.right,
                                                                      style: poppinsMedium.copyWith(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                      height: 36,
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: ColorTheme.borderGrey)),
                                                                      child: Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          '   ' +
                                                                              double.parse('  ${(double.parse(Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].balance) - (double.parse(_paidController.text.isEmpty ? '0' : _paidController.text)))}').toStringAsFixed(2),
                                                                          style:
                                                                              poppinsMedium.copyWith(
                                                                            color:
                                                                                ColorTheme.hintText,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          posController.selectedPaymentTab ==
                                                                      0 ||
                                                                  posController
                                                                          .selectedPaymentTab ==
                                                                      2
                                                              ? SizedBox
                                                                  .shrink()
                                                              : Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .only(
                                                                    top: Dimensions
                                                                        .PADDING_SIZE_LARGE,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text(
                                                                            'Transaction No: ',
                                                                            // textAlign: TextAlign.right,
                                                                            style:
                                                                                poppinsMedium.copyWith(
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              36,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(7),
                                                                              border: Border.all(color: ColorTheme.borderGrey)),
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                _transactionNoController,
                                                                            autofocus:
                                                                                false,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              // hintText: 'phone'.tr,
                                                                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(7),
                                                                                borderSide: BorderSide(style: BorderStyle.none, width: 0),
                                                                              ),
                                                                              hintStyle: poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
                                                                              fillColor: Colors.white,
                                                                            ),
                                                                            style:
                                                                                poppinsMedium.copyWith(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                            ),
                                                                            onChanged:
                                                                                (value) async {},
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          posController
                                                                      .selectedPaymentTab ==
                                                                  2
                                                              ? Get.find<AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .upiId ==
                                                                      ''
                                                                  ? SizedBox
                                                                      .shrink()
                                                                  : Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              30),
                                                                      child:
                                                                          QrImageView(
                                                                        data:
                                                                            'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=&tn=',
                                                                        version:
                                                                            QrVersions.auto,
                                                                        size:
                                                                            120,
                                                                        gapless:
                                                                            false,
                                                                      ),
                                                                    )
                                                              : SizedBox
                                                                  .shrink(),
                                                          posController
                                                                  .isLoading
                                                              ? CircularProgressIndicator()
                                                              : Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();

                                                                      // if (posController
                                                                      //         .selectedPaymentTab ==
                                                                      //     3) {
                                                                      if (_paidController
                                                                          .text
                                                                          .isEmpty) {
                                                                        showCustomSnackBar(
                                                                            'Please enter paid amount');
                                                                      } else if (Get.find<PosController>().selectedPaymentTab ==
                                                                              1 &&
                                                                          _transactionNoController
                                                                              .text
                                                                              .isEmpty) {
                                                                        showErrorToast(
                                                                            'Please enter transaction number');
                                                                      } else {
                                                                        if (double.parse(_paidController.text) >
                                                                            double.parse(Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].balance)) {
                                                                          showErrorToast(
                                                                              'You can not extra pay amount more than total payable amount');
                                                                        } else {
                                                                          Map<String, dynamic>
                                                                              jsonData =
                                                                              {
                                                                            'mobile':
                                                                                Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].mobile,
                                                                            'email':
                                                                                Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].email,
                                                                            'name':
                                                                                Get.find<PosController>().tapManagmentCustomerListResponse!.employeeTapList[i].name,
                                                                            'credit_order_amount':
                                                                                '0',
                                                                            'debit_order_amount':
                                                                                double.parse(_paidController.text),
                                                                            'payment_status': Get.find<PosController>().selectedPaymentTab == 0
                                                                                ? 'cash'
                                                                                : Get.find<PosController>().selectedPaymentTab == 1
                                                                                    ? 'card'
                                                                                    : 'upi',
                                                                            'order_id':
                                                                                ''
                                                                          };

                                                                          Get.find<PosController>().collectTapPayment(
                                                                              callback,
                                                                              jsonData: jsonData);
                                                                        }
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets.only(
                                                                          top:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8,
                                                                          horizontal:
                                                                              12),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              7),
                                                                          color:
                                                                              ColorTheme.appColor),
                                                                      child:
                                                                          Text(
                                                                        'Update Credit',
                                                                        style: poppinsMedium.copyWith(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  );
                                }),
                          ),
                    // SizedBox(height: 10),
                  ]);
            }),
          ),
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Get.back();

      showErrorToast(message, isError: false);
      Get.find<PosController>().clearTapCustomerData();
      Get.find<PosController>().getTapManageMentCustomerList();
    } else {
      showErrorToast(message);
    }
  }
}
