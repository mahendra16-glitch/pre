import 'dart:developer';
import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/stock_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseManagementController expenseController;
  final bool isEdit;
  final Map<String, dynamic>? expense;
  final void Function()? onSubmitTap;

  const AddExpenseScreen({
    super.key,
    required this.expenseController,
    this.isEdit = false,
    this.expense,
    this.onSubmitTap,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        print("=== AddExpenseScreen initState ===");
        print("isEditMode: ${widget.expenseController.isEditMode}");
        if (widget.expenseController.isEditMode &&
            widget.expenseController.currentEditExpense != null) {
          widget.expenseController.showDefaultBottomsSheetData(
            true,
            expense: widget.expenseController.currentEditExpense,
          );
          print("✅ Edit data loaded in initState");
        } else {
          widget.expenseController.manageExpenseResetData(false);
          widget.expenseController.dateController.text =
              DateFormat('dd/MM/yyyy').format(DateTime.now());
          print("✅ Fresh data initialized");
        }
      } catch (e) {
        print("❌ Error in AddExpenseScreen initState: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<String> lastSuggestions = {};
    return Scaffold(
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorTheme.whiteColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.expenseController.isEditMode
                  ? AppString.editExpense
                  : AppString.addExpense,
              style: montserratMedium.copyWith(
                  fontSize: 14, color: ColorTheme.grey74),
            ),
            // 10.height,
            // DottedLine(
            //   dashGapLength: 10,
            //   dashColor: ColorTheme.foodValue,
            // ),
            // 5.height
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: ColorTheme.white,
              size: 10,
            ),
            onPressed: () {
              widget.expenseController.manageExpenseResetData(false);
              widget.expenseController.isEditMode = false;
              widget.expenseController.currentEditExpense = null;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<ExpenseManagementController>(
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: widget.expenseController.manageExpenseFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          5.height,
                          Container(
                            width: 200,
                            height: 43,
                            child: CustomTextformField(
                              controller: controller.dateController,
                              labelText: AppString.selectDate,
                              keyboardType: TextInputType.none,
                              readOnly: true,
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: ColorTheme.greyColor.withOpacity(0.5),
                                size: 17,
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: widget.isEdit
                                      ? DateFormat('dd/MM/yyyy')
                                          .parse(widget.expense!['Date & Time'])
                                      : DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  widget.expenseController.dateController.text =
                                      DateFormat('dd/MM/yyyy')
                                          .format(pickedDate);
                                }
                              },
                            ),
                          ),
                          16.height,
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: controller.addStockExpenseList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: Autocomplete<String>(
                                    //     optionsBuilder: (TextEditingValue
                                    //         textEditingValue) {
                                    //       if (textEditingValue.text.isEmpty) {
                                    //         lastSuggestions.clear();
                                    //         return const Iterable<
                                    //             String>.empty();
                                    //       }
                                    //       final suggestions = widget
                                    //           .expenseController.masterList
                                    //           .where((element) =>
                                    //               element["stock_title"]
                                    //                   .toString()
                                    //                   .toLowerCase()
                                    //                   .contains(textEditingValue
                                    //                       .text
                                    //                       .toLowerCase()))
                                    //           .map((e) =>
                                    //               e["stock_title"].toString())
                                    //           .toSet()
                                    //           .toList();
                                    //       if (suggestions.isEmpty) {
                                    //         WidgetsBinding.instance
                                    //             .addPostFrameCallback((_) {
                                    //           widget.expenseController
                                    //               .addStockTextController[index]
                                    //               .clear();
                                    //           appToast(
                                    //               "Current Balance Not enough");
                                    //         });
                                    //       }
                                    //       return suggestions;
                                    //     },
                                    //     onSelected: (String selection) {
                                    //       widget
                                    //           .expenseController
                                    //           .addStockTextController[index]
                                    //           .text = selection;
                                    //     },
                                    //     fieldViewBuilder: (BuildContext context,
                                    //         TextEditingController
                                    //             textEditingController,
                                    //         FocusNode focusNode,
                                    //         VoidCallback onFieldSubmitted) {
                                    //       textEditingController.text = widget
                                    //           .expenseController
                                    //           .addStockTextController[index]
                                    //           .text;
                                    //       widget.expenseController
                                    //               .addStockTextController[
                                    //           index] = textEditingController;
                                    //       return CustomTextformField(
                                    //         controller: textEditingController,
                                    //         focusNode: focusNode,
                                    //         labelText: AppString.stockName,
                                    //         keyboardType: TextInputType.text,
                                    //         // autovalidateMode: AutovalidateMode
                                    //         //     .onUserInteraction,
                                    //         // validator: (value) {
                                    //         //   if (value == null ||
                                    //         //       value.isEmpty) {
                                    //         //     return AppString
                                    //         //         .pleaseEnterStockName;
                                    //         //   }
                                    //         //   return null;
                                    //         // },
                                    //       );
                                    //     },
                                    //     optionsViewBuilder:
                                    //         (BuildContext context,
                                    //             AutocompleteOnSelected<String>
                                    //                 onSelected,
                                    //             Iterable<String> options) {
                                    //       return Padding(
                                    //         padding: const EdgeInsets.only(
                                    //             right: 30),
                                    //         child: Align(
                                    //           alignment: Alignment.topLeft,
                                    //           child: Material(
                                    //             elevation: 4.0,
                                    //             borderRadius:
                                    //                 BorderRadius.circular(8),
                                    //             child: ConstrainedBox(
                                    //               constraints:
                                    //                   const BoxConstraints(
                                    //                 maxHeight: 150,
                                    //                 minWidth: 175,
                                    //               ),
                                    //               child: Container(
                                    //                 color:
                                    //                     ColorTheme.whiteColor,
                                    //                 child: ListView.builder(
                                    //                   padding: EdgeInsets.zero,
                                    //                   itemCount: options.length,
                                    //                   shrinkWrap: true,
                                    //                   itemBuilder:
                                    //                       (BuildContext context,
                                    //                           int i) {
                                    //                     final String option =
                                    //                         options
                                    //                             .elementAt(i);
                                    //                     return InkWell(
                                    //                       onTap: () =>
                                    //                           onSelected(
                                    //                               option),
                                    //                       child: Padding(
                                    //                         padding:
                                    //                             const EdgeInsets
                                    //                                 .all(8.0),
                                    //                         child: Text(
                                    //                           option,
                                    //                           style:
                                    //                               montserratMedium
                                    //                                   .copyWith(
                                    //                             fontSize: 14,
                                    //                             color:
                                    //                                 ColorTheme
                                    //                                     .grey74,
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     );
                                    //                   },
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),

                                    // GetBuilder<ExpenseManagementController>(
                                    //     builder: (controller) {
                                    //   return Expanded(
                                    //     child: Autocomplete<String>(
                                    //       key: ValueKey('stock_${index}_${controller.autoCompleteRefreshKey}'), // Add this key
                                    //       initialValue: TextEditingValue(
                                    //         text: widget
                                    //             .expenseController
                                    //             .addStockTextController[index]
                                    //             .text,
                                    //       ),
                                    //       optionsBuilder: (TextEditingValue
                                    //           textEditingValue) {
                                    //         if (textEditingValue.text.isEmpty) {
                                    //           lastSuggestions.clear();
                                    //           return const Iterable<
                                    //               String>.empty();
                                    //         }

                                    //         final suggestions = widget
                                    //             .expenseController.masterList
                                    //             .where((element) =>
                                    //                 element["stock_title"]
                                    //                     .toString()
                                    //                     .toLowerCase()
                                    //                     .contains(
                                    //                         textEditingValue
                                    //                             .text
                                    //                             .toLowerCase()))
                                    //             .map((e) =>
                                    //                 e["stock_title"].toString())
                                    //             .toSet()
                                    //             .toList();

                                    //         // If no suggestions found, add "Add [typed text]" option
                                    //         if (suggestions.isEmpty) {
                                    //           return [
                                    //             "Add ${textEditingValue.text}"
                                    //           ];
                                    //         }

                                    //         return suggestions;
                                    //       },
                                    //       onSelected: (String selection) {
                                    //         // Check if it's the "Add" option
                                    //         if (selection.startsWith("Add ")) {
                                    //           final customValue = selection
                                    //               .replaceFirst("Add ", "");
                                    //           widget
                                    //               .expenseController
                                    //               .addStockTextController[index]
                                    //               .text = customValue;
                                    //         } else {
                                    //           widget
                                    //               .expenseController
                                    //               .addStockTextController[index]
                                    //               .text = selection;
                                    //         }
                                    //         // Close the dropdown by unfocusing
                                    //         FocusScope.of(context).unfocus();
                                    //       },
                                    //       fieldViewBuilder: (BuildContext
                                    //               context,
                                    //           TextEditingController
                                    //               textEditingController,
                                    //           FocusNode focusNode,
                                    //           VoidCallback onFieldSubmitted) {
                                    //         // textEditingController.text = widget
                                    //         //     .expenseController
                                    //         //     .addStockTextController[index]
                                    //         //     .text;
                                    //         textEditingController.text = widget
                                    //             .expenseController
                                    //             .addStockTextController[index]
                                    //             .text;

                                    //         widget.expenseController
                                    //                 .addStockTextController[
                                    //             index] = textEditingController;

                                    //         return CustomTextformField(
                                    //           controller: textEditingController,
                                    //           focusNode: focusNode,
                                    //           labelText: AppString.stockName,
                                    //           keyboardType: TextInputType.text,
                                    //           onChanged: (value) {
                                    //             widget
                                    //                 .expenseController
                                    //                 .addStockTextController[
                                    //                     index]
                                    //                 .text = value;
                                    //           },
                                    //           autovalidateMode: AutovalidateMode
                                    //               .onUserInteraction,
                                    //           validator: (value) {
                                    //             if (value == null ||
                                    //                 value.isEmpty) {
                                    //               return AppString
                                    //                   .pleaseEnterStockName;
                                    //             }
                                    //             return null;
                                    //           },
                                    //         );
                                    //       },
                                    //       optionsViewBuilder:
                                    //           (BuildContext context,
                                    //               AutocompleteOnSelected<String>
                                    //                   onSelected,
                                    //               Iterable<String> options) {
                                    //         return Padding(
                                    //           padding: const EdgeInsets.only(
                                    //               right: 30),
                                    //           child: Align(
                                    //             alignment: Alignment.topLeft,
                                    //             child: Material(
                                    //               elevation: 4.0,
                                    //               borderRadius:
                                    //                   BorderRadius.circular(10),
                                    //               child: ConstrainedBox(
                                    //                 constraints:
                                    //                     const BoxConstraints(
                                    //                         maxHeight: 180,
                                    //                         minWidth: 150,
                                    //                         maxWidth: 1200),
                                    //                 child: Container(
                                    //                   color:
                                    //                       ColorTheme.whiteColor,
                                    //                   child: ListView.builder(
                                    //                     padding:
                                    //                         EdgeInsets.zero,
                                    //                     itemCount:
                                    //                         options.length,
                                    //                     shrinkWrap: true,
                                    //                     itemBuilder:
                                    //                         (BuildContext
                                    //                                 context,
                                    //                             int i) {
                                    //                       final String option =
                                    //                           options
                                    //                               .elementAt(i);

                                    //                       // Check if it's the "Add" option
                                    //                       final bool
                                    //                           isAddOption =
                                    //                           option.startsWith(
                                    //                               "Add ");

                                    //                       return InkWell(
                                    //                         onTap: () =>
                                    //                             onSelected(
                                    //                                 option),
                                    //                         child: Container(
                                    //                           padding:
                                    //                               const EdgeInsets
                                    //                                   .all(8.0),
                                    //                           color: isAddOption
                                    //                               ? ColorTheme
                                    //                                   .white
                                    //                                   .withOpacity(
                                    //                                       0.1)
                                    //                               : Colors
                                    //                                   .transparent,
                                    //                           child: Row(
                                    //                             children: [
                                    //                               if (isAddOption)
                                    //                                 Icon(
                                    //                                   Icons
                                    //                                       .add_circle_outline,
                                    //                                   size: 16,
                                    //                                   color: ColorTheme
                                    //                                       .grey8C,
                                    //                                 ),
                                    //                               if (isAddOption)
                                    //                                 const SizedBox(
                                    //                                     width:
                                    //                                         6),
                                    //                               Expanded(
                                    //                                 child: Text(
                                    //                                   option,
                                    //                                   style: montserratMedium
                                    //                                       .copyWith(
                                    //                                     fontSize:
                                    //                                         14,
                                    //                                     color: isAddOption
                                    //                                         ? ColorTheme.grey74
                                    //                                         : ColorTheme.grey74,
                                    //                                     fontWeight: isAddOption
                                    //                                         ? FontWeight.w600
                                    //                                         : FontWeight.normal,
                                    //                                   ),
                                    //                                 ),
                                    //                               ),
                                    //                             ],
                                    //                           ),
                                    //                         ),
                                    //                       );
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         );
                                    //       },
                                    //     ),
                                    //   );
                                    // }),

                                    GetBuilder<ExpenseManagementController>(
                                      builder: (controller) {
                                        return Expanded(
                                          child: TypeAheadField<String>(
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                              controller: widget
                                                      .expenseController
                                                      .addStockTextController[
                                                  index],
                                              style: montserratMedium.copyWith(
                                                color: ColorTheme.grey74,
                                                fontSize: 14,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: AppString.stockName,
                                                labelStyle:
                                                    montserratMedium.copyWith(
                                                  color: ColorTheme.grey74,
                                                  fontSize: 14,
                                                ),
                                                // Border styling
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30)),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFFDCDCDC)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30)),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFFDCDCDC)),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30)),
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFDCDCDC))),

                                                // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                filled: true,
                                                fillColor: ColorTheme
                                                    .whiteColor, // Background color
                                                errorText: index <
                                                            controller
                                                                .stockNameHasError
                                                                .length &&
                                                        controller
                                                            .stockNameHasError[
                                                                index]
                                                    ? AppString
                                                        .pleaseSelectStockName
                                                    : null,
                                                errorStyle:
                                                    montserratMedium.copyWith(
                                                  color: Colors.red,
                                                  fontSize: 11,
                                                ),
                                                focusedErrorBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30)),
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                if (value.trim().isNotEmpty &&
                                                    index <
                                                        controller
                                                            .stockNameHasError
                                                            .length) {
                                                  controller.stockNameHasError[
                                                      index] = false;
                                                }
                                                controller
                                                    .update(); // Rebuild suggestions
                                              },
                                            ),
                                            suggestionsCallback: (pattern) {
                                              if (pattern.isEmpty) {
                                                return [];
                                              }

                                              final suggestions = widget
                                                  .expenseController.masterList
                                                  .where((element) =>
                                                      element["stock_title"]
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase()))
                                                  .map((e) => e["stock_title"]
                                                      .toString())
                                                  .toSet()
                                                  .toList();

                                              // Agar kuch match nahi mila toh "Add" option show karo
                                              if (suggestions.isEmpty) {
                                                return ["Add $pattern"];
                                              }

                                              return suggestions;
                                            },
                                            noItemsFoundBuilder: (context) {
                                              return Container(
                                                padding: EdgeInsets.all(8),
                                                child: Text("No results found"),
                                              );
                                            },
                                            loadingBuilder: (context) {
                                              return Container(
                                                padding: EdgeInsets.all(8),
                                                child: Text("Loading..."),
                                              );
                                            },
                                            debounceDuration:
                                                Duration(milliseconds: 300),
                                            hideOnEmpty: true,
                                            hideOnLoading: false,
                                            itemBuilder:
                                                (context, String suggestion) {
                                              final isAddOption =
                                                  suggestion.startsWith("Add ");

                                              return ListTile(
                                                leading: isAddOption
                                                    ? Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size: 18,
                                                        color:
                                                            ColorTheme.grey8C)
                                                    : SizedBox.shrink(),
                                                title: Text(
                                                  suggestion,
                                                  style:
                                                      montserratMedium.copyWith(
                                                    fontSize: 14,
                                                    color: ColorTheme.grey74,
                                                    fontWeight: isAddOption
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                tileColor: isAddOption
                                                    ? ColorTheme.white
                                                        .withOpacity(0.1)
                                                    : Colors.transparent,
                                                dense: true,
                                              );
                                            },
                                            onSuggestionSelected:
                                                (String suggestion) {
                                              if (suggestion
                                                  .startsWith("Add ")) {
                                                final customValue = suggestion
                                                    .replaceFirst("Add ", "");
                                                widget
                                                    .expenseController
                                                    .addStockTextController[
                                                        index]
                                                    .text = customValue;
                                                if (index <
                                                    widget
                                                        .expenseController
                                                        .stockNameHasError
                                                        .length) {
                                                  widget
                                                      .expenseController
                                                      .stockNameHasError[index] = false;
                                                }
                                                widget.expenseController
                                                    .update();
                                              } else {
                                                widget
                                                    .expenseController
                                                    .addStockTextController[
                                                        index]
                                                    .text = suggestion;
                                                if (index <
                                                    widget
                                                        .expenseController
                                                        .stockNameHasError
                                                        .length) {
                                                  widget
                                                      .expenseController
                                                      .stockNameHasError[index] = false;
                                                }

                                                // Get stock details
                                                final stockDetails = widget
                                                    .expenseController
                                                    .getStockDetailsByName(
                                                        suggestion);

                                                if (stockDetails != null) {
                                                  // Check if unit_price is true
                                                  if (stockDetails[
                                                          "unit_price"] !=
                                                      true) {
                                                    widget
                                                        .expenseController
                                                        .addAmountTextController[
                                                            index]
                                                        .clear();
                                                    controller
                                                        .addQuantityTextController[
                                                            index]
                                                        .clear();
                                                  } else {
                                                    widget
                                                        .expenseController
                                                        .addAmountTextController[
                                                            index]
                                                        .clear();
                                                  }
                                                }
                                                widget.expenseController
                                                    .update();
                                              }
                                              // API call + clear
                                              // widget.expenseController.addOrUpdateExpense(index).then((_) {
                                              //   // Clear after API success
                                              //   widget.expenseController.addStockTextController[index].clear();
                                              //   widget.expenseController.update();
                                              // });
                                            },
                                            // hideOnEmpty: true,
                                            // hideOnLoading: false,
                                            // debounceDuration:
                                            //     Duration(milliseconds: 300),
                                          ),
                                        );
                                      },
                                    ),

                                    25.width,
                                    GestureDetector(
                                      onTap: () {
                                        // Get.back();
                                        // widget.expenseController.tabValue.value =
                                        //     1;
                                        Get.to(() => ExpenseStockScreen(
                                              expenseController: controller,
                                              masterList:
                                                  controller.masterList ?? [],
                                              categoryList:
                                                  controller.categoryList ?? [],
                                            ));
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
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: CustomTextformField(
                                    //     controller: controller
                                    //         .addAmountTextController[index],
                                    //     labelText: AppString.pleaseSelectAmount,
                                    //     keyboardType:
                                    //         TextInputType.numberWithOptions(
                                    //             decimal: true),
                                    //     inputFormatters: [
                                    //       FilteringTextInputFormatter.allow(
                                    //           RegExp(r'^\d*\.?\d*')),
                                    //     ],
                                    //     autovalidateMode:
                                    //         AutovalidateMode.onUserInteraction,
                                    //     validator: (value) {
                                    //       if (value!.isEmpty || value == "") {
                                    //         return AppString.pleaseEnterAmount;
                                    //       }
                                    //       return null;
                                    //     },
                                    //   ),
                                    // ),

                                    GetBuilder<ExpenseManagementController>(
                                      builder: (controller) {
                                        // Check if current stock has fixed unit price
                                        String currentStockName = controller
                                            .addStockTextController[index].text;
                                        Map<String, dynamic>? stockDetails =
                                            controller.getStockDetailsByName(
                                                currentStockName);

                                        bool isFixedPrice = stockDetails !=
                                                null &&
                                            stockDetails["unit_price"] == true;

                                        print(
                                            ' is this fixed price ${isFixedPrice}');

                                        return Expanded(
                                          child: CustomTextformField(
                                            controller: controller
                                                .addAmountTextController[index],
                                            labelText:
                                                AppString.pleaseSelectAmount,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d*')),
                                            ],
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            // enabled:
                                            //     !isFixedPrice, // Disable if fixed price
                                            readOnly:
                                                isFixedPrice, // Make read-only if fixed price
                                            validator: (value) {
                                              if (value!.isEmpty ||
                                                  value == "") {
                                                return AppString
                                                    .pleaseEnterAmount;
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      },
                                    ),

                                    if (controller.isExpenseSplit.length <=
                                            index ||
                                        !controller.isExpenseSplit[index])
                                      _AmountSplitButton(
                                        amountController: controller
                                            .addAmountTextController[index],
                                        onTap: () => controller
                                            .enableExpenseSplit(index),
                                      ),

                                    if (controller.isExpenseSplit.length <=
                                            index ||
                                        !controller.isExpenseSplit[index]) ...[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: DropdownButtonFormField2<String>(
                                          value: controller
                                                  .addExpenseSelectedPaymentType[
                                                      index]
                                                  .isNotEmpty
                                              ? controller
                                                      .addExpenseSelectedPaymentType[
                                                  index]
                                              : null,
                                          isExpanded: true,
                                          style: montserratMedium.copyWith(
                                            color: ColorTheme.grey74,
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 12,
                                          ),
                                          items: controller.getPaymentList
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value.toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    montserratMedium.copyWith(
                                                  color: ColorTheme.grey74,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              controller
                                                      .addExpenseSelectedPaymentType[
                                                  index] = newValue;
                                              // controller.update();
                                              //  setState(() {});
                                            }
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Select Payment Method';
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          buttonStyleData: ButtonStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            overlayColor:
                                                WidgetStateProperty.all(
                                                    Colors.transparent),
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 400,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: Color(0xFFDCDCDC),
                                              ),
                                            ),
                                          ),
                                          menuItemStyleData: MenuItemStyleData(
                                            height: 45,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: AppString.paymentType,
                                            labelStyle:
                                                montserratMedium.copyWith(
                                              color: ColorTheme.grey74,
                                              fontSize: 13,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide:
                                                  BorderSide(color: Colors.red),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            // contentPadding:
                                            //     const EdgeInsets.symmetric(
                                            //   vertical: 10,
                                            //   horizontal: 0,
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ],
                                  ],
                                ),
                                _expenseSplitSection(controller, index),
                                16.height,
                                Row(
                                  children: [
                                    GetBuilder<ExpenseManagementController>(
                                        builder: (controller) {
                                      return Expanded(
                                        child: CustomTextformField(
                                          controller: controller
                                              .addQuantityTextController[index],
                                          labelText: AppString.pleaseQuantity,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          onChanged: (_) {
                                            // Get stock details
                                            final stockDetails = widget
                                                .expenseController
                                                .getStockDetailsByName(
                                                    controller
                                                        .addStockTextController[
                                                            index]
                                                        .text);

                                            if (stockDetails != null) {
                                              // Check if unit_price is true
                                              if (stockDetails["unit_price"] ==
                                                  true) {
                                                // Set the unit_price_amount
                                                final finalAmount = int.parse(
                                                        stockDetails[
                                                                "unit_price_amount"]
                                                            .toString()) *
                                                    int.parse(controller
                                                        .addQuantityTextController[
                                                            index]
                                                        .text);
                                                widget
                                                        .expenseController
                                                        .addAmountTextController[
                                                            index]
                                                        .text =
                                                    finalAmount.toString();
                                              }
                                              //  else {
                                              //   // Clear for manual entry
                                              //   widget
                                              //       .expenseController
                                              //       .addAmountTextController[
                                              //           index]
                                              //       .clear();
                                              // }
                                            }
                                            widget.expenseController.update();
                                          },
                                          // validator: (value) {
                                          //   if (value!.isEmpty || value == "") {
                                          //     return AppString
                                          //         .pleaseEnterQuantity;
                                          //   }
                                          //   return null;
                                          // },
                                        ),
                                      );
                                    }),
                                    8.width,
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: DropdownButtonFormField2<String>(
                                          value: controller
                                                  .addExpenseSelectedUnit[index]
                                                  .isNotEmpty
                                              ? controller
                                                  .addExpenseSelectedUnit[index]
                                              : null,
                                          items: controller.getUnitList
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value.toString(),
                                                style:
                                                    montserratMedium.copyWith(
                                                  color: ColorTheme.grey74,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              controller.addExpenseSelectedUnit[
                                                  index] = newValue;
                                              controller.update();
                                              //  setState(() {});
                                            }
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            overlayColor:
                                                WidgetStateProperty.all(
                                                    Colors.transparent),
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 400,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: Color(0xFFDCDCDC),
                                              ),
                                            ),
                                          ),
                                          menuItemStyleData: MenuItemStyleData(
                                            height: 45,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: AppString.unit,
                                            labelStyle:
                                                montserratMedium.copyWith(
                                              color: ColorTheme.grey74,
                                              fontSize: 14,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDCDCDC)),
                                            ),
                                            // contentPadding:
                                            //     const EdgeInsets.symmetric(
                                            //   vertical: 10,
                                            //   horizontal: 0,
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                16.height,
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextformField(
                                        controller: controller
                                            .addPQuantityTextController[index],
                                        labelText:
                                            AppString.pleasePhysicalQuantity,
                                        keyboardType: TextInputType.number,
                                        // validator: (value) {
                                        //   if (value!.isEmpty || value == "") {
                                        //     return AppString
                                        //         .pleaseEnterPhysicalQuantity;
                                        //   }
                                        //   return null;
                                        // },
                                      ),
                                    ),
                                    8.width,
                                  ],
                                ),
                                _expenseExtraFields(controller, index),
                                Visibility(
                                  visible:
                                      controller.addStockExpenseList.length -
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
                                if (!widget.isEdit)
                                  if (controller.addStockExpenseList.length -
                                          1 ==
                                      index)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.expenseController
                                              .addStockExpense(index);
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              Images.add_icon,
                                              color: ColorTheme.grey,
                                              height: 20,
                                              width: 20,
                                            ),
                                            10.width,
                                            Text(
                                              AppString.addNewExpense,
                                              style: montserratMedium.copyWith(
                                                fontSize: 14,
                                                color: ColorTheme.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return 15.height;
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              controller.manageExpenseResetData(widget.isEdit);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: ColorTheme.greyColor.withOpacity(.2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                AppString.Reset,
                                style: montserratMedium.copyWith(
                                  fontSize: 14,
                                  color: ColorTheme.grey74,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => Expanded(
                            child: GestureDetector(
                              onTap: controller.isSubmitting
                                  ? null
                                  : () async {
                                      if (controller.isEditMode &&
                                          controller.currentEditExpense !=
                                              null) {
                                        await controller.editManageExpense(
                                            controller
                                                .currentEditExpense!['exp_id']);
                                        controller.isEditMode = false;
                                        controller.currentEditExpense = null;
                                      } else {
                                        if (widget.onSubmitTap != null) {
                                          widget.onSubmitTap!();
                                        }
                                      }
                                    },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ColorTheme.greenColor,
                                ),
                                alignment: Alignment.center,
                                child: controller.isSubmitLoader.value
                                    ? AppLoader()
                                    : Text(
                                        controller.isEditMode
                                            ? AppString.edit
                                            : AppString.submit,
                                        style: montserratMedium.copyWith(
                                          fontSize: 14,
                                          color: ColorTheme.whiteColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 20.height,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _splitOpen(ExpenseManagementController controller, int index) {
    return index < controller.isExpenseSplit.length &&
        controller.isExpenseSplit[index] &&
        index < controller.splitAmountTextController.length &&
        index < controller.splitAmount2TextController.length &&
        index < controller.splitPaymentMethod2.length &&
        index < controller.addExpenseSelectedPaymentType.length;
  }

  Widget _expenseSplitSection(
      ExpenseManagementController controller, int index) {
    if (!_splitOpen(controller, index)) return const SizedBox();
    return Column(
      children: [
        16.height,
        _splitPaymentRow(
          controller,
          index,
          row: 1,
          paymentValue: controller.addExpenseSelectedPaymentType[index],
          amountController: controller.splitAmountTextController[index],
          onPaymentChanged: (value) {
            controller.addExpenseSelectedPaymentType[index] = value;
            controller.update();
          },
        ),
        16.height,
        _splitPaymentRow(
          controller,
          index,
          row: 2,
          paymentValue: controller.splitPaymentMethod2[index],
          amountController: controller.splitAmount2TextController[index],
          onPaymentChanged: (value) {
            controller.splitPaymentMethod2[index] = value;
            controller.update();
          },
        ),
        10.height,
        _ExpenseSplitStatus(controller: controller, index: index),
        8.height,
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => controller.cancelExpenseSplit(index),
            child: Text(
              AppString.cancelSplit,
              style: montserratMedium.copyWith(
                fontSize: 14,
                color: ColorTheme.grey74,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _expenseExtraFields(
      ExpenseManagementController controller, int index) {
    if (index >= controller.addNotesTextController.length ||
        index >= controller.addPaidToTextController.length ||
        index >= controller.addRefIdTextController.length) {
      return const SizedBox();
    }
    return Column(
      children: [
        16.height,
        Row(
          children: [
            Expanded(
              child: CustomTextformField(
                controller: controller.addNotesTextController[index],
                labelText: AppString.notesOptional,
              ),
            ),
            8.width,
            Expanded(
              child: CustomTextformField(
                controller: controller.addPaidToTextController[index],
                labelText: AppString.paidToOptional,
              ),
            ),
          ],
        ),
        16.height,
        Row(
          children: [
            Expanded(
              child: CustomTextformField(
                controller: controller.addRefIdTextController[index],
                labelText: AppString.refIdOptional,
              ),
            ),
            8.width,
          ],
        ),
      ],
    );
  }

  Widget _splitPaymentRow(
    ExpenseManagementController controller,
    int index, {
    required int row,
    required String paymentValue,
    required TextEditingController amountController,
    required ValueChanged<String> onPaymentChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            '$row',
            style: montserratMedium.copyWith(
              fontSize: 14,
              color: ColorTheme.grey74,
            ),
          ),
        ),
        Expanded(
          child: _paymentTypeDropdown(
            controller,
            index: index,
            row: row,
            paymentValue: paymentValue,
            onPaymentChanged: onPaymentChanged,
          ),
        ),
        8.width,
        Expanded(
          child: CustomTextformField(
            controller: amountController,
            labelText: AppString.pleaseSelectAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppString.pleaseEnterAmount;
              }
              return null;
            },
          ),
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => controller.cancelExpenseSplit(index),
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _paymentTypeDropdown(
    ExpenseManagementController controller, {
    required int index,
    required int row,
    required String paymentValue,
    required ValueChanged<String> onPaymentChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField2<String>(
        key: ValueKey(
            'split-pay-$index-$row-$paymentValue-${index < controller.splitRowVersion.length ? controller.splitRowVersion[index] : 0}'),
        value: paymentValue.isNotEmpty ? paymentValue : null,
        isExpanded: true,
        style: montserratMedium.copyWith(
          color: ColorTheme.grey74,
          overflow: TextOverflow.ellipsis,
          fontSize: 12,
        ),
        items: controller.getPaymentList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              style: montserratMedium.copyWith(
                color: ColorTheme.grey74,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onPaymentChanged(newValue);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Select Payment Method';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFDCDCDC),
            ),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 45,
        ),
        decoration: InputDecoration(
          labelText: AppString.paymentType,
          labelStyle: montserratMedium.copyWith(
            color: ColorTheme.grey74,
            fontSize: 13,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
        ),
      ),
    );
  }
}

class _AmountSplitButton extends StatefulWidget {
  final TextEditingController amountController;
  final VoidCallback onTap;

  const _AmountSplitButton({
    required this.amountController,
    required this.onTap,
  });

  @override
  State<_AmountSplitButton> createState() => _AmountSplitButtonState();
}

class _AmountSplitButtonState extends State<_AmountSplitButton> {
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _AmountSplitButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountController != widget.amountController) {
      oldWidget.amountController.removeListener(_refresh);
      widget.amountController.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amountController.text.trim().isEmpty) {
      return const SizedBox(width: 8);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: CustomPaint(
            painter: _DashedRRectPainter(color: ColorTheme.redColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Text(
                AppString.splitPayment,
                style: montserratMedium.copyWith(
                  fontSize: 13,
                  color: ColorTheme.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;

  _DashedRRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(12),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ExpenseSplitStatus extends StatefulWidget {
  final ExpenseManagementController controller;
  final int index;

  const _ExpenseSplitStatus({
    required this.controller,
    required this.index,
  });

  @override
  State<_ExpenseSplitStatus> createState() => _ExpenseSplitStatusState();
}

class _ExpenseSplitStatusState extends State<_ExpenseSplitStatus> {
  TextEditingController? _parent;
  TextEditingController? _first;
  TextEditingController? _second;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant _ExpenseSplitStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.controller != widget.controller) {
      _unbind();
      _bind();
    }
  }

  void _bind() {
    final controller = widget.controller;
    final index = widget.index;
    if (index >= controller.addAmountTextController.length ||
        index >= controller.splitAmountTextController.length ||
        index >= controller.splitAmount2TextController.length) {
      return;
    }
    _parent = controller.addAmountTextController[index];
    _first = controller.splitAmountTextController[index];
    _second = controller.splitAmount2TextController[index];
    _parent?.addListener(_refresh);
    _first?.addListener(_refresh);
    _second?.addListener(_refresh);
  }

  void _unbind() {
    _parent?.removeListener(_refresh);
    _first?.removeListener(_refresh);
    _second?.removeListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matched = widget.controller.splitAmountsMatch(widget.index);
    final color = matched ? ColorTheme.green : const Color(0xFFE53935);
    final background =
        matched ? const Color(0xFFE7F6EC) : const Color(0xFFFDECEC);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            matched ? Icons.check : Icons.close,
            size: 16,
            color: color,
          ),
          6.width,
          Expanded(
            child: Text(
              widget.controller.splitStatusMessage(widget.index),
              style: montserratMedium.copyWith(fontSize: 12, color: color),
            ),
          ),
          8.width,
          Flexible(
            child: Text(
              widget.controller.splitEquation(widget.index),
              textAlign: TextAlign.right,
              style: montserratMedium.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
