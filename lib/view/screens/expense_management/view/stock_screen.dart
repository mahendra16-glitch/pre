import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/bottom_sheet/category_add_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/bottom_sheet/delete_bottomsheet.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';

class ExpenseStockScreen extends StatefulWidget {
  List<Map<String, dynamic>> masterList;
  List<String> categoryList;
  ExpenseManagementController expenseController;

  ExpenseStockScreen(
      {required this.masterList,
      required this.expenseController,
      required this.categoryList});
  @override
  State<ExpenseStockScreen> createState() => _ExpenseStockScreenState();
}

class _ExpenseStockScreenState extends State<ExpenseStockScreen> {
  @override
  void initState() {
    widget.expenseController.initalResetMasterExpense();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.expenseController.stockInitStateCalling();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: ColorTheme.green,
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Manage Expense List',
          style: montserratSemiBold.copyWith(
              color: ColorTheme.black, fontSize: 16),
        ),
        actions: [
          uploadIconWidget(
            onDownLoadTap: () async {
              Get.to(() => BulkImportScreen(
                    tittleName: 'Manage Expense List',
                    isFunction: true,
                    onuploadTap: () {
                      Get.find<ExpenseManagementController>()
                          .bulkMasterExpenseImport();
                    },
                    onDownloadExistingDataTap: () {
                      Get.find<ExpenseManagementController>()
                          .bulkMasterExpenseExport();
                    },
                    onDownloadSampleDataTap: () {
                      Get.find<ExpenseManagementController>().exportExpenseMasterSample();
                    },
                    controller: Get.find<ExpenseManagementController>(),
                  ));
            },
            onUploadTap: () async {
              Get.to(() => BulkImportScreen(
                    tittleName: 'Manage Expense List',
                    isFunction: true,
                    onuploadTap: () {
                      Get.find<ExpenseManagementController>()
                          .bulkMasterExpenseImport();
                    },
                    onDownloadExistingDataTap: () {
                      Get.find<ExpenseManagementController>()
                          .bulkMasterExpenseExport();
                    },
                    onDownloadSampleDataTap: () {
                      Get.find<ExpenseManagementController>().exportExpenseMasterSample();
                    },
                    controller: Get.find<ExpenseManagementController>(),
                  ));
            },
            isPLusShow: false,
            onPlusTap: () {},
          ),

          // SizedBox(width: 20),
        ],
      ),
      body: GetBuilder<ExpenseManagementController>(
        builder: (controller) => SingleChildScrollView(
          controller: widget.expenseController.masterScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                decoration: BoxDecoration(color: ColorTheme.manageBgColor),
                child: Form(
                  key: widget.expenseController.masterExpenseFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Expense Stock',
                        style: montserratMedium.copyWith(
                          fontSize: 13,
                          color: ColorTheme.grey8C,
                        ),
                      ),
                      10.height,
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          lineThickness: 1.0,
                          dashLength: 2.5,
                          dashColor: ColorTheme.greyColor,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              // height: 43,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                // border: Border.all(
                                //     color: ColorTheme.grey.withOpacity(.8)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField2<String>(
                                  value: widget.expenseController.categoryValue,
                                  isExpanded: true,
                                  // hint: Text(
                                  //   AppString.pleaseSelectCategory,
                                  //   style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: ColorTheme.grey.withOpacity(.8)),
                                  // ),
                                  items: widget.expenseController.categoryList
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: montserratMedium.copyWith(
                                          fontSize: 12,
                                          color: ColorTheme.grey8C,
                                        ),
                                      ),
                                    );
                                  }).toList(),

                                  onChanged: (String? newValue) {
                                    setState(() {
                                      widget.expenseController.categoryValue =
                                          newValue;
                                    });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,

                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Select Category';
                                    }
                                    return null;
                                  },
                                  style: montserratMedium.copyWith(
                                    fontSize: 12,
                                    color: ColorTheme.grey8C,
                                  ),
                                  buttonStyleData: ButtonStyleData(
                                    width: double.infinity,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    iconSize: 24,
                                    iconEnabledColor:
                                        ColorTheme.grey.withOpacity(.8),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: ColorTheme.whiteColor,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Select Category",
                                    labelStyle: montserratMedium.copyWith(
                                      color: ColorTheme.grey8C,
                                      fontSize: 12,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border:
                                        AppBorder.selectStockNameFieldBorder,
                                    focusedBorder:
                                        AppBorder.selectStockNameFieldBorder,
                                    errorBorder:
                                        AppBorder.selectStockNameFieldBorder,
                                    enabledBorder:
                                        AppBorder.selectStockNameFieldBorder,
                                    // contentPadding: const EdgeInsets.symmetric(
                                    //   vertical: 0,
                                    //   horizontal: 10,
                                    // ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          30.width,
                          GestureDetector(
                            onTap: () {
                              categoryAddBottomSheet(
                                context,
                                expenseController: widget.expenseController,
                                onTap: () async {
                                  await widget.expenseController.addCategory();
                                },
                              );
                            },
                            child: SvgPicture.asset(Images.add_icon,
                                height: 28, width: 28, color: ColorTheme.grey),
                          ),
                        ],
                      ),
                      16.height,
                      widget.expenseController.localStockWidgetList.isNotEmpty
                          ? Container(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: widget.expenseController
                                    .localStockWidgetList.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          // height: 40,
                                          child: TextFormField(
                                            controller: widget.expenseController
                                                    .expenseMasterStockTextControllers[
                                                index],
                                            style: montserratMedium.copyWith(
                                              fontSize: 12,
                                              color: ColorTheme.grey8C,
                                            ),
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'.*')),
                                            ],
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please Write Stock Name';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                                isCollapsed: false,
                                                isDense: false,
                                                label: Text('Stock Name'),
                                                floatingLabelAlignment:
                                                    FloatingLabelAlignment
                                                        .start,
                                                labelStyle:
                                                    montserratMedium.copyWith(
                                                  fontSize: 12,
                                                  color: ColorTheme.grey8C,
                                                ),
                                                // contentPadding:
                                                //     EdgeInsets.symmetric(
                                                //         vertical: 16,
                                                //         horizontal: 12),
                                                border: AppBorder
                                                    .selectStockNameFieldBorder,
                                                enabledBorder: AppBorder
                                                    .selectStockNameFieldBorder,
                                                focusedBorder: AppBorder
                                                    .selectStockNameFieldBorder,
                                                errorBorder: AppBorder
                                                    .selectStockNameFieldBorder),
                                          ),
                                        ),
                                      ),
                                      32.width,
                                      GestureDetector(
                                        onTap: () {
                                          widget.expenseController
                                              .removeStockWidget(index);
                                        },
                                        child: SvgPicture.asset(
                                            Images.deleteIcon,
                                            height: 20,
                                            width: 20),
                                      ),
                                      5.width,
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return 10.height;
                                },
                              ),
                            )
                          : SizedBox(),
                      widget.expenseController.isEditMaster.value == false
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: GestureDetector(
                                onTap: () {
                                  widget.expenseController.addStockWidget();
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(Images.add_icon,
                                        height: 18, color: ColorTheme.grey),
                                    8.width,
                                    Text(
                                      AppString.expenseTitle,
                                      style: montserratMedium.copyWith(
                                        fontSize: 12,
                                        color: ColorTheme.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      25.height,
                      Row(
                        children: [
                          Obx(
                            () => GestureDetector(
                              onTap: widget.expenseController.isMasterSubmitting
                                      .value
                                  ? null
                                  : () async {
                                      if (widget.expenseController.isEditMaster
                                              .value ==
                                          false) {
                                        await widget.expenseController
                                            .addMasterExpense();
                                      } else {
                                        await widget.expenseController
                                            .editMasterExpense(widget
                                                    .expenseController
                                                    .editMasterExpenseId ??
                                                0);
                                      }
                                    },
                              child: Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                    color: ColorTheme.greenColor,
                                    borderRadius: BorderRadius.circular(20)),
                                alignment: Alignment.center,
                                child: widget
                                        .expenseController.isMasterLoader.value
                                    ? SpinKitFadingCircle(
                                        color: ColorTheme.borderGrey,
                                        size: 25.0,
                                      )
                                    : Text(
                                        widget.expenseController.isEditMaster
                                                    .value ==
                                                false
                                            ? AppString.submit
                                            : AppString.edit,
                                        style: montserratMedium.copyWith(
                                          fontSize: 12,
                                          color: ColorTheme.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          20.width,
                          GetBuilder<ExpenseManagementController>(
                            builder: (controller) => GestureDetector(
                              onTap: () {
                                // controller.resetExpense();
                              },
                              child: Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: ColorTheme.grey),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  AppString.Reset,
                                  style: montserratMedium.copyWith(
                                    fontSize: 12,
                                    color: ColorTheme.grey8C,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      15.height,
                    ],
                  ),
                ),
              ),
              16.height,
              Container(
                color: ColorTheme.whiteColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppString.stockList,
                            style: montserratMedium.copyWith(
                              fontSize: 14,
                              color: ColorTheme.grey8C,
                            ),
                          ).paddingOnly(left: 15),
                          Spacer(),
                          IconButton(
                              onPressed: () async {
                                widget.expenseController.masterList.clear();
                                await widget.expenseController
                                    .fetchMasterExpenses();
                              },
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                              )).paddingOnly(right: 15),
                        ],
                      ),
                      2.height,
                      DottedLine(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        lineThickness: 1.0,
                        dashLength: 2.5,
                        dashColor: ColorTheme.greyColor,
                      ).paddingSymmetric(horizontal: 15),
                      20.height,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          width: double.infinity,
                          // height: 40,
                          child: CustomTextformField(
                            controller:
                                widget.expenseController.searchController,
                            labelText: AppString.search,
                            keyboardType: TextInputType.text,
                            onChanged: (val) {
                              widget.expenseController.update();
                            },
                            fillColor: ColorTheme.manageBgColor,
                          ),
                        ),
                      ),
                      20.height,
                      widget.expenseController.isMasterExpenseLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  child: Center(
                                child: CircularProgressIndicator(),
                              )),
                            )
                          : (widget.expenseController.masterList.isNotEmpty ||
                                  widget.expenseController.masterList.length !=
                                      0)
                              ? GetBuilder<ExpenseManagementController>(
                                  builder: (controller) =>
                                      SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Table(
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      columnWidths: const {
                                        0: FlexColumnWidth(1.2),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                      },
                                      border: TableBorder.all(
                                          color:
                                              ColorTheme.grey.withOpacity(0.2)),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: ColorTheme.whiteColor),
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                AppString.stockTitle,
                                                style:
                                                    montserratMedium.copyWith(
                                                  fontSize: 13,
                                                  color: ColorTheme.grey8C,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  AppString.categoryDetails,
                                                  style:
                                                      montserratMedium.copyWith(
                                                    fontSize: 13,
                                                    color: ColorTheme.grey8C,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                AppString.action,
                                                style:
                                                    montserratMedium.copyWith(
                                                  fontSize: 13,
                                                  color: ColorTheme.grey8C,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...widget.expenseController.masterList
                                            .where(
                                          (element) =>
                                              element["stock_title" ?? ""]
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(widget
                                                      .expenseController
                                                      .searchController
                                                      .text
                                                      .toLowerCase()),
                                        )
                                            .map((expense) {
                                          return TableRow(
                                            decoration: BoxDecoration(
                                                color: ColorTheme.whiteColor),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 20),
                                                child: Center(
                                                  child: Text(
                                                    expense["stock_title"] ??
                                                        "-",
                                                    textAlign: TextAlign.center,
                                                    style: montserratMedium
                                                        .copyWith(
                                                      fontSize: 13,
                                                      color: ColorTheme.grey8C,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      expense['category_name'] ??
                                                          "",
                                                      style: montserratMedium
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            ColorTheme.grey8C,
                                                      ),
                                                    ),
                                                    4.height,
                                                    Text(
                                                      expense['created_at'] ??
                                                          "",
                                                      style: montserratMedium
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: ColorTheme
                                                            .manageBlueColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 30),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Spacer(
                                                      flex: 1,
                                                    ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          widget
                                                              .expenseController
                                                              .scrollToBottom();
                                                          widget
                                                              .expenseController
                                                              .isEditMaster
                                                              .value = true;
                                                          widget.expenseController
                                                                  .editMasterExpenseId =
                                                              expense['id'];
                                                          widget
                                                              .expenseController
                                                              .categoryValue = expense[
                                                                  'category_name'] ??
                                                              "";
                                                          widget
                                                              .expenseController
                                                              .expenseMasterStockTextControllers[
                                                                  0]
                                                              .text = expense[
                                                                  'stock_title'] ??
                                                              "";
                                                          widget
                                                              .expenseController
                                                              .update();
                                                        },
                                                        child: Icon(
                                                            Icons.edit_outlined,
                                                            color: ColorTheme
                                                                .green),
                                                      ),
                                                    ),
                                                    18.width,
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          deleteBottomSheet(
                                                              context,
                                                              onDeleteTap:
                                                                  () async {
                                                            await widget
                                                                .expenseController
                                                                .deleteMasterExpense(
                                                                    expense['id'] ??
                                                                        0);
                                                          },
                                                              expenseText: expense[
                                                                      'stock_title'] ??
                                                                  "",
                                                              expenseController:
                                                                  widget
                                                                      .expenseController);
                                                        },
                                                        child: SvgPicture.asset(
                                                            Images.deleteIcon,
                                                            height: 20,
                                                            color: ColorTheme
                                                                .greenColor,
                                                            width: 20),
                                                      ),
                                                    ),
                                                    Spacer(
                                                      flex: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          5),
                                  child: Container(
                                    child: Center(
                                        child: Text(
                                      AppString.itemDoesNtExists,
                                      style: montserratMedium.copyWith(
                                        fontSize: 15,
                                        color: ColorTheme.grey8C,
                                      ),
                                    )),
                                  ),
                                ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
