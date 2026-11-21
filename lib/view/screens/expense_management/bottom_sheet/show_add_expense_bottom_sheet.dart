import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void showAddExpenseBottomSheet(BuildContext context,
    {required ExpenseManagementController expenseController,
    bool isEdit = false,
    Map<String, dynamic>? expense,
    void Function()? onSubmitTap}) {
  Set<String> lastSuggestions = {};

  expenseController.showDefaultBottomsSheetData(isEdit, expense: expense);

  showModalBottomSheet(
    backgroundColor: ColorTheme.whiteColor,
    shape: RoundedRectangleBorder(),
    isDismissible: false,
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: double.infinity),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? AppString.editExpense : AppString.addExpense,
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorTheme.grey105,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: ColorTheme.grey105),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: ColorTheme.grey.withOpacity(.3),
                  ),
                  18.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 43,
                          child: TextFormField(
                            controller: expenseController.dateController,
                            decoration: InputDecoration(
                              hintText: AppString.selectDate,
                              hintStyle: TextStyle(
                                  color: ColorTheme.greyColor, fontSize: 14),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: ColorTheme.greyColor.withOpacity(0.5),
                                size: 17,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12),
                              border: AppBorder.selectStockNameFieldBorder
                                  .copyWith(
                                      borderSide: BorderSide(
                                          color: ColorTheme.greyColor)),
                              enabledBorder:
                                  AppBorder.selectStockNameFieldBorder.copyWith(
                                      borderSide: BorderSide(
                                          color: ColorTheme.greyColor)),
                              focusedBorder:
                                  AppBorder.selectStockNameFieldBorder.copyWith(
                                      borderSide: BorderSide(
                                          color: ColorTheme.greyColor)),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: isEdit
                                    ? DateFormat('dd/MM/yyyy')
                                        .parse(expense!['Date & Time'])
                                    : DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                expenseController.dateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                              }
                            },
                          ),
                        ),
                        16.height,
                      ],
                    ),
                  ),
                  Flexible(
                    child: GetBuilder<ExpenseManagementController>(
                      builder: (controller) => ListView.separated(
                        itemCount:
                            expenseController.addStockExpenseList.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Autocomplete<String>(
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) {
                                          if (textEditingValue.text.isEmpty) {
                                            lastSuggestions.clear();
                                            return const Iterable<
                                                String>.empty();
                                          }

                                          final suggestions = expenseController
                                              .masterList
                                              .where((element) =>
                                                  element["stock_title"]
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(textEditingValue
                                                          .text
                                                          .toLowerCase()))
                                              .map((e) =>
                                                  e["stock_title"].toString())
                                              .toSet()
                                              .toList();

                                          if (suggestions.isEmpty) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              expenseController
                                                  .addStockTextController[index]
                                                  .clear();
                                              appToast(
                                                  "Current Balance Not enough");
                                            });
                                          }

                                          return suggestions;
                                        },
                                        onSelected: (String selection) {
                                          expenseController
                                              .addStockTextController[index]
                                              .text = selection;
                                        },
                                        fieldViewBuilder: (
                                          BuildContext context,
                                          TextEditingController
                                              textEditingController,
                                          FocusNode focusNode,
                                          VoidCallback onFieldSubmitted,
                                        ) {
                                          textEditingController.text =
                                              expenseController
                                                  .addStockTextController[index]
                                                  .text;
                                          expenseController
                                                  .addStockTextController[
                                              index] = textEditingController;

                                          return TextFormField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              hintText: AppString.stockName,
                                              hintStyle: AppStyle.stockListStyle
                                                  .copyWith(
                                                fontSize: 15,
                                                color: ColorTheme.greyColor,
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12),
                                              border: AppBorder.greyWidth120,
                                              enabledBorder:
                                                  AppBorder.greyWidth120,
                                              focusedBorder:
                                                  AppBorder.greyWidth120,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return AppString
                                                    .pleaseEnterStockName;
                                              }
                                              return null;
                                            },
                                          );
                                        },
                                        optionsViewBuilder: (
                                          BuildContext context,
                                          AutocompleteOnSelected<String>
                                              onSelected,
                                          Iterable<String> options,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                elevation: 4.0,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 150,
                                                          minWidth: 175),
                                                  child: Container(
                                                    color:
                                                        ColorTheme.whiteColor,
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      itemCount: options.length,
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        final String option =
                                                            options.elementAt(
                                                                index);
                                                        return InkWell(
                                                          onTap: () =>
                                                              onSelected(
                                                                  option),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              option,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: ColorTheme
                                                                      .black5F6368),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    25.width,
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                        expenseController.tabValue.value = 1;
                                      },
                                      child: SvgPicture.asset(
                                        Images.add_icon,
                                        width: 30,
                                        height: 30,
                                        color: ColorTheme.grey,
                                      ).paddingOnly(right: 12),
                                    ),
                                  ],
                                ),
                                16.height,
                                //1 line
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value!.isEmpty || value == "") {
                                              return AppString
                                                  .pleaseEnterAmount;
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          controller: expenseController
                                              .addAmountTextController[index],
                                          decoration: InputDecoration(
                                            hintText:
                                                AppString.pleaseSelectAmount,
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                color: ColorTheme.greyColor),
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12),
                                            border: AppBorder.greyWidth120,
                                            enabledBorder:
                                                AppBorder.greyWidth120,
                                            focusedBorder:
                                                AppBorder.greyWidth120,
                                          ),
                                        ),
                                      ),
                                    ),
                                    8.width,
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          height: 43,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.whiteColor,
                                            border: Border.all(
                                                color: ColorTheme.grey),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: expenseController
                                                      .addExpenseSelectedPaymentType[
                                                          index]
                                                      .isNotEmpty
                                                  ? expenseController
                                                          .addExpenseSelectedPaymentType[
                                                      index]
                                                  : null,
                                              dropdownColor:
                                                  ColorTheme.whiteColor,
                                              isExpanded: true,
                                              hint: Text(
                                                AppString.paymentType,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        ColorTheme.greyColor),
                                              ),
                                              icon: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: ColorTheme.greyColor,
                                              ),
                                              items: expenseController
                                                  .getPaymentList
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null &&
                                                    expenseController
                                                                .addExpenseSelectedPaymentType[
                                                            index] !=
                                                        newValue) {
                                                  expenseController
                                                          .addExpenseSelectedPaymentType[
                                                      index] = newValue;
                                                  expenseController.update();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                16.height,
                                //2 line
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          validator: (value) {
                                            if (value!.isEmpty || value == "") {
                                              return AppString
                                                  .pleaseEnterQuantity;
                                            }
                                            return null;
                                          },
                                          controller: expenseController
                                              .addQuantityTextController[index],
                                          decoration: InputDecoration(
                                            hintText: AppString.pleaseQuantity,
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                color: ColorTheme.greyColor),
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12),
                                            border: AppBorder.greyWidth120,
                                            enabledBorder:
                                                AppBorder.greyWidth120,
                                            focusedBorder:
                                                AppBorder.greyWidth120,
                                          ),
                                        ),
                                      ),
                                    ),
                                    8.width,
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          height: 43,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.whiteColor,
                                            border: Border.all(
                                                color: ColorTheme.grey),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: expenseController
                                                      .addExpenseSelectedUnit[
                                                          index]
                                                      .isNotEmpty
                                                  ? expenseController
                                                          .addExpenseSelectedUnit[
                                                      index]
                                                  : null,
                                              dropdownColor:
                                                  ColorTheme.whiteColor,
                                              isExpanded: true,
                                              hint: Text(
                                                AppString.unit,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        ColorTheme.greyColor),
                                              ),
                                              icon: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: ColorTheme.greyColor,
                                              ),
                                              items: expenseController
                                                  .getUnitList
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null &&
                                                    expenseController
                                                                .addExpenseSelectedUnit[
                                                            index] !=
                                                        newValue) {
                                                  expenseController
                                                          .addExpenseSelectedUnit[
                                                      index] = newValue;
                                                  expenseController.update();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                16.height,
                                Container(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty || value == "") {
                                        return AppString
                                            .pleaseEnterPhysicalQuantity;
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    controller: expenseController
                                        .addPQuantityTextController[index],
                                    decoration: InputDecoration(
                                      hintText:
                                          AppString.pleasePhysicalQuantity,
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: ColorTheme.greyColor),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                      border: AppBorder.greyWidth120,
                                      enabledBorder: AppBorder.greyWidth120,
                                      focusedBorder: AppBorder.greyWidth120,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: expenseController
                                              .addStockExpenseList.length -
                                          1 !=
                                      index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: DottedLine(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.center,
                                      lineThickness: 1.0,
                                      dashLength: 2.5,
                                      dashColor: ColorTheme.greyColor,
                                    ),
                                  ),
                                ),
                                if (isEdit == false)
                                  if (expenseController
                                              .addStockExpenseList.length -
                                          1 ==
                                      index)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          expenseController
                                              .addStockExpense(index);
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(Images.add_icon,
                                                color: ColorTheme.grey,
                                                height: 20,
                                                width: 20),
                                            10.width,
                                            Text(
                                              AppString.addNewExpense,
                                              style: TextStyle(
                                                color: ColorTheme.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                isEdit ? 10.height : 0.height
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return 15.height;
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            expenseController.manageExpenseResetData(isEdit);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: ColorTheme.greyColor.withOpacity(.2)),
                            alignment: Alignment.center,
                            child: Text(AppString.Reset),
                          ),
                        ),
                      ),
                      Obx(
                        () => Expanded(
                          child: GestureDetector(
                            onTap: expenseController.isSubmitting
                                ? null
                                : onSubmitTap,
                            child: Container(
                              height: 50,
                              decoration:
                                  BoxDecoration(color: ColorTheme.greenColor),
                              alignment: Alignment.center,
                              child: expenseController.isSubmitLoader.value
                                  ? AppLoader()
                                  : Text(
                                      isEdit
                                          ? AppString.edit
                                          : AppString.submit,
                                      style: TextStyle(
                                          color: ColorTheme.whiteColor,
                                          fontWeight: FontWeight.w800),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  20.height,
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
