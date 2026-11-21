import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/controller/expense_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/bottom_sheet/delete_bottomsheet.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/bottom_sheet/show_add_expense_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/widget/add_stock_tab.dart';

class ManageExpenseTab extends StatefulWidget {
  final List<Map<String, dynamic>> manageList;
  final ExpenseManagementController expenseController;

  ManageExpenseTab({required this.manageList, required this.expenseController});

  @override
  State<ManageExpenseTab> createState() => _ManageExpenseTabState();
}

class _ManageExpenseTabState extends State<ManageExpenseTab> {
  @override
  void initState() {
    // ✅ Set dates FIRST before API call
    widget.expenseController.formattedFromDate ??=
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    widget.expenseController.formattedToDate ??=
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    widget.expenseController.selectedPaymentType = "All";
    widget.expenseController.manageList.clear();

    widget.expenseController.manageAmountController.clear();

    // Call API after setting dates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiCalling();
    });
    super.initState();
  }

  apiCalling() async {
    // ✅ Ensure both APIs complete before update
    await widget.expenseController.fetchManageExpenses();
    widget.expenseController.update(); // Single update after API completes
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (controller) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.height,
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 5,
                runSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.expenseController.selectFromDate(context);
                    },
                    child: _buildRoundedButton(
                      widget.expenseController.formattedFromDate.toString(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.expenseController.selectToDate(context);
                    },
                    child: _buildRoundedButton(
                      widget.expenseController.formattedToDate.toString(),
                    ),
                  ),
                  // Container(
                  //   height: 35,
                  //   padding: EdgeInsets.symmetric(horizontal: 15),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: ColorTheme.grey),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: DropdownButton<String>(
                  //     dropdownColor: ColorTheme.whiteColor,
                  //     value: widget.expenseController.selectedPaymentType,
                  //     style: montserratMedium.copyWith(
                  //         fontSize: 13, color: ColorTheme.foodValue),
                  //     hint: Text(AppString.allPayment,
                  //         style: montserratMedium.copyWith(
                  //             fontSize: 12, color: ColorTheme.foodValue)),
                  //     underline: SizedBox(),
                  //     icon: Icon(Icons.keyboard_arrow_down_rounded,
                  //         color: ColorTheme.blackColor),
                  //     items: widget.expenseController.getAllPaymentList
                  //         .map((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value,
                  //             style: montserratMedium.copyWith(
                  //                 fontSize: 12, color: ColorTheme.grey8C)),
                  //       );
                  //     }).toList(),
                  //     onChanged: (String? newValue) async {
                  //       widget.expenseController.selectedPaymentType =
                  //           newValue!;
                  //       await widget.expenseController.fetchManageExpenses();
                  //       widget.expenseController.update();
                  //     },
                  //   ),
                  // ),
                  Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTheme.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        value: widget.expenseController.selectedPaymentType,
                        hint: Text(
                          AppString.allPayment,
                          style: montserratMedium.copyWith(
                            fontSize: 12,
                            color: ColorTheme.foodValue,
                          ),
                        ),
                        style: montserratMedium.copyWith(
                          fontSize: 12,
                          color: ColorTheme.foodValue,
                        ),
                        items: widget.expenseController.getAllPaymentList
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
                        onChanged: (String? newValue) async {
                          widget.expenseController.selectedPaymentType =
                              newValue!;
                          await widget.expenseController.fetchManageExpenses();
                          widget.expenseController.update();
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 35,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          iconEnabledColor: ColorTheme.blackColor,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: ColorTheme.whiteColor,
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).paddingOnly(left: 20),
            10.height,
            // widget.expenseController.manageList.isEmpty
            //     ? SizedBox()
            //     : Container(
            //         width: 150,
            //         height: 40,
            //         child: TextFormField(
            //           readOnly: true,
            //           keyboardType: TextInputType.number,
            //           onChanged: (value) {
            //             widget.expenseController.update();
            //           },
            //           // cursorHeight: 15,
            //           controller:
            //               widget.expenseController.manageAmountController,
            //           style: AppStyle.manageAmount14Green
            //               .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            //           decoration: InputDecoration(
            //             hintText: AppString.enterAmount,
            //             hintStyle: AppStyle.manageAmount14Green,
            //             fillColor: ColorTheme.manageAmountBoxColor,
            //             filled: true,
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(12.0),
            //               borderSide: BorderSide.none,
            //             ),
            //             contentPadding: const EdgeInsets.symmetric(
            //                 vertical: 0.0, horizontal: 20.0),
            //           ),
            //         ),
            //       ).paddingSymmetric(horizontal: 15),
            widget.expenseController.manageList.isNotEmpty
                ? Container(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      readOnly: true,
                      controller:
                          widget.expenseController.manageAmountController,
                      style: AppStyle.manageAmount14Green
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        // hintText: widget.expenseController
                        //         .manageAmountController.text.isEmpty
                        //     ? AppString.enterAmount
                        //     : "₹ ${widget.expenseController.manageAmountController.text}",
                        filled: true,
                        fillColor: ColorTheme.manageAmountBoxColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 20.0),
                      ),
                    ),
                  ).paddingSymmetric(horizontal: 15)
                : SizedBox(),
            10.height,
            widget.expenseController.isManageListLoading
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4),
                    child: Center(child: CircularProgressIndicator()))
                : widget.manageList.isNotEmpty
                    ? SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          border: TableBorder.all(
                              color: ColorTheme.grey.withOpacity(0.2)),
                          children: [
                            _buildTableHeader(),
                            ...widget.manageList.map((expense) {
                              return _buildTableRow(expense);
                            }).toList(),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 4),
                        child: Center(
                          child: Container(
                            child: Text(
                              'No Data Found.',
                              style: montserratMedium.copyWith(
                                fontSize: 12,
                                color: ColorTheme.grey8C,
                              ),
                            ),
                          ),
                        )),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: ColorTheme.whiteColor),
      children: [
        _buildHeaderCell(
          AppString.expenseDetails,
        ),
        _buildHeaderCell(AppString.totalAmount),
        _buildHeaderCell(AppString.action),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> expense) {
    return TableRow(
      decoration: BoxDecoration(color: ColorTheme.whiteColor),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              expense['EXPENSE'] != null
                  ? Text(expense['EXPENSE'] ?? '',
                      style: montserratMedium.copyWith(
                          fontSize: 13, color: ColorTheme.foodValue))
                  : Text("-",
                      style: AppStyle.manageListStyle.copyWith(fontSize: 15)),
              4.height,
              expense['Category'] != null
                  ? Text(expense['Category'] ?? '',
                      style: montserratMedium.copyWith(
                          fontSize: 11, color: ColorTheme.foodValue))
                  : Text("-",
                      style: AppStyle.manageListStyle.copyWith(fontSize: 15)),
              4.height,
              Text(
                expense['Date & Time'] ?? '',
                style: montserratMedium.copyWith(
                    fontSize: 11, color: ColorTheme.manageBlueColor),
              ),
            ],
          ),
        ).paddingSymmetric(horizontal: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  expense['Amount'] ?? '',
                  style: montserratMedium.copyWith(
                      fontSize: 15, color: ColorTheme.green),
                ),
                3.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      expense['quantity'] ?? '',
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: ColorTheme.foodValue),
                    ),
                    3.width,
                    Text(
                      expense['unit'] ?? '',
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: ColorTheme.foodValue),
                    ),
                  ],
                ),
                3.height,
                Text(expense['Payment Method'] ?? '',
                    style: montserratMedium.copyWith(
                        fontSize: 12, color: ColorTheme.blue)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  // // Step 1: Set edit mode first
                  // widget.expenseController.isEditMode = true;
                  // widget.expenseController.currentEditExpense = expense;

                  // // Step 2: Load expense data into controllers
                  // widget.expenseController.showDefaultBottomsSheetData(
                  //   true,
                  //   expense: expense,
                  // );

                  // // Step 3: Force update to refresh UI
                  // widget.expenseController.update();

                  // // Step 4: Small delay to ensure data is populated
                  // await Future.delayed(Duration(milliseconds: 100));

                  // // Step 5: Switch to tab 0
                  // widget.expenseController.tabValue.value = 0;
                  try {
                    print("=== Edit Button Clicked ===");
                    print("Expense Data: $expense");
                    widget.expenseController.manageExpenseResetData(false);
                    // Step 1: Set flags first
                    widget.expenseController.isEditMode = true;
                    widget.expenseController.currentEditExpense = expense;

                    // Step 2: Load data with null safety check
                    if (expense.isNotEmpty) {
                      widget.expenseController.showDefaultBottomsSheetData(
                        true,
                        expense: expense,
                      );

                      // Step 3: Force UI update
                      widget.expenseController.update();

                      // Step 4: Small delay for data loading
                      await Future.delayed(Duration(milliseconds: 150));

                      // Step 5: Navigate to tab 0
                      widget.expenseController.tabValue.value = 0;

                      print("✅ Edit mode activated successfully");
                    } else {
                      print("❌ Expense data is null or empty");
                    }
                  } catch (e) {
                    print("❌ Error in edit button: $e");
                  }
                  // Get.to(
                  //   () => AddExpenseScreen(
                  //     expenseController: widget.expenseController,
                  //     isEdit: true,
                  //     expense: expense,
                  //     onSubmitTap: () async {
                  //       await widget.expenseController
                  //           .editManageExpense(expense['id']);
                  //     },
                  //   ),
                  // );
                },
                child: SvgPicture.asset(
                  Images.Edit,
                  height: 20,
                  color: ColorTheme.greenColor,
                ),
              ),
              20.width,
              GestureDetector(
                onTap: () async {
                  deleteBottomSheet(context,
                      onDeleteTap: widget.expenseController.isSubmitting
                          ? null
                          : () async {
                              await widget.expenseController
                                  .deleteManageExpense(expense['id']);
                            },
                      expenseText: expense['Expense'] ?? '',
                      expenseController: widget.expenseController);
                },
                child: SvgPicture.asset(
                  Images.delete_red,
                  color: ColorTheme.greenColor,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {String align = "center"}) {
    return Padding(
      padding: align == "left"
          ? const EdgeInsets.symmetric(vertical: 8, horizontal: 10)
          : const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: align == "left" ? Alignment.centerLeft : Alignment.center,
        child: Text(
          text,
          style: AppStyle.tx18mediumRed.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppStyle.manageListStyle.copyWith(color: ColorTheme.blackColor),
      ),
    );
  }
}
