import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/widget/custom_bottom_textform_field.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void addAddonsSheet(
    BuildContext context, MenuManagementController menuController,
    {void Function()? onTap,
    bool isEdit = false,
    required Map<String, dynamic> menuAddons}) {
  // Fetch units if not already fetched
  // final expenseController = Get.find<ExpenseManagementController>();
  // if (expenseController.getUnitList.isEmpty) {
  //   expenseController.getUnit();
  // }

  if (isEdit) {
    menuController.addAddonNameController.text = menuAddons["name"] ?? '';
    menuController.addAddonPriceController.text =
        menuAddons["price"]?.toString() ?? '';
    // menuController.addAddonQuantityController.text =
    //     menuAddons["qty"]?.toString() ?? '';
    // menuController.selectedAddonUnit = menuAddons["unit"] ?? null;
  } else {
    menuController.addAddonNameController.clear();
    menuController.addAddonPriceController.clear();
    // menuController.addAddonQuantityController.clear();
    // menuController.selectedAddonUnit = null;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: ColorTheme.whiteColor,
    shape: RoundedRectangleBorder(),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            child: Form(
              key: menuController.addAddonsFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              isEdit
                                  ? "Edit Addon ${menuAddons["name"]}"
                                  : AppString.addNewFoodAddons,
                              style: AppStyle.stockListStyle.copyWith(
                                  fontSize: 15, color: ColorTheme.grey74)),
                          IconButton(
                            icon: Icon(Icons.close, color: ColorTheme.grey74),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ],
                      ).paddingOnly(left: 20, right: 20),
                      4.height,
                      Container(
                          height: 0.5,
                          color: ColorTheme.grey74.withOpacity(.5)),
                      15.height,
                      Column(
                        children: [
                          AddonsBottomTextField(
                            validatorText: AppString.pleaseEnterName,
                            hintText: AppString.name,
                            controller: menuController.addAddonNameController,
                            labelText: "Name",
                          ),
                          10.height,
                          AddonsBottomTextField(
                              keyboardType: TextInputType.number,
                              validatorText: AppString.pleaseEnterPrice,
                              hintText: AppString.price,
                              labelText: "Price",
                              controller:
                                  menuController.addAddonPriceController),
                          // 10.height,
                          // AddonsBottomTextField(
                          //   keyboardType:
                          //       TextInputType.numberWithOptions(decimal: true),
                          //   validatorText: '',
                          //   hintText: 'Quantity',
                          //   controller:
                          //       menuController.addAddonQuantityController,
                          //   labelText: "Quantity",
                          //   inputFormatters: [
                          //     FilteringTextInputFormatter.allow(
                          //         RegExp(r'[0-9.]')),
                          //   ],
                          // ),
                          // 10.height,
                          // GetBuilder<ExpenseManagementController>(
                          //   builder: (expenseController) {
                          //     return DropdownButtonFormField2<String>(
                          //       value: menuController.selectedAddonUnit,
                          //       isExpanded: true,
                          //       hint: Text(
                          //         'Select Unit',
                          //         style: montserratMedium.copyWith(
                          //           fontSize: 14,
                          //           color: ColorTheme.blackColor,
                          //         ),
                          //       ),
                          //       items: expenseController.getUnitList
                          //           .map((String unit) {
                          //         return DropdownMenuItem<String>(
                          //           value: unit,
                          //           child: Text(
                          //             unit,
                          //             style: montserratMedium.copyWith(
                          //               fontSize: 14,
                          //               color: ColorTheme.blackColor,
                          //             ),
                          //           ),
                          //         );
                          //       }).toList(),
                          //       onChanged: (String? newValue) {
                          //         menuController.selectedAddonUnit = newValue;
                          //         menuController.update();
                          //       },
                          //       buttonStyleData: ButtonStyleData(
                          //         padding: EdgeInsets.symmetric(horizontal: 0),
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(20),
                          //         ),
                          //         overlayColor: WidgetStateProperty.all(
                          //             Colors.transparent),
                          //       ),
                          //       dropdownStyleData: DropdownStyleData(
                          //         maxHeight: 400,
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(5),
                          //           border: Border.all(
                          //             color: ColorTheme.grey74.withOpacity(0.3),
                          //           ),
                          //         ),
                          //       ),
                          //       menuItemStyleData: MenuItemStyleData(
                          //         height: 45,
                          //       ),
                          //       decoration: InputDecoration(
                          //         labelText: "Unit",
                          //         labelStyle: montserratMedium.copyWith(
                          //           fontSize: 14,
                          //           color: ColorTheme.blackColor,
                          //         ),
                          //         floatingLabelAlignment:
                          //             FloatingLabelAlignment.start,
                          //         contentPadding: EdgeInsets.symmetric(
                          //             vertical: 10, horizontal: 12),
                          //         border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(25),
                          //           borderSide: BorderSide(
                          //               color:
                          //                   ColorTheme.grey74.withOpacity(0.3)),
                          //         ),
                          //         enabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(25),
                          //           borderSide: BorderSide(
                          //               color:
                          //                   ColorTheme.grey74.withOpacity(0.3)),
                          //         ),
                          //         focusedBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(25),
                          //           borderSide: BorderSide(
                          //               color:
                          //                   ColorTheme.grey74.withOpacity(0.3)),
                          //         ),
                          //         errorBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(25),
                          //           borderSide:
                          //               BorderSide(color: ColorTheme.redColor),
                          //         ),
                          //         focusedErrorBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(25),
                          //           borderSide:
                          //               BorderSide(color: ColorTheme.redColor),
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                       
                        ],
                      ).paddingOnly(left: 20, right: 20),
                    ],
                  ),
                  20.height,
                  Obx(
                    () => GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(color: ColorTheme.greenColor),
                        alignment: Alignment.center,
                        child: menuController.isAddAddonsLoader.value
                            ? AppLoader()
                            : Text(
                                isEdit
                                    ? AppString.editAddons
                                    : AppString.addAddons,
                                style: TextStyle(
                                    color: ColorTheme.whiteColor,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                  20.height,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
