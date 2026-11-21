import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/widget/category_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/add_edit_menu/add_edit_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';

void quickEditFoodSheet(BuildContext context, Map<String, dynamic> foodItem,
    {required MenuManagementController menuController,
    required InventoryController inventoryController}) {
  menuController.productName.text = foodItem['name'];
  menuController.menuPrice.text = foodItem['price'].toString();

  menuController.quickCategoryValue = foodItem["category"]["name"];
  menuController.quickCategoryIndex = foodItem["category"]["id"];
  menuController.quickItemValue = foodItem["item_type"] == 1
      ? "Veg"
      : foodItem["item_type"] == 2
          ? "Egg"
          : foodItem["item_type"] == 3
              ? "Jain"
              : "Non Veg";
  menuController.selectedTaxType.value = foodItem['tax_type'];
  menuController.taxController.text = foodItem["tax"].toString();
  if (foodItem["food_for"] != "Aggregator")
    menuController.selectedComplementary =
        foodItem['complementary'].toString().toLowerCase();

  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(maxWidth: double.infinity),
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: ColorTheme.whiteColor,
    shape: RoundedRectangleBorder(),
    builder: (context) {
      TextEditingController resturantBueffetPriceController =
          TextEditingController(text: '0');
      return StatefulBuilder(
        builder: (context, setState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppString.quickEdit,
                          style:
                              AppStyle.stockListStyle.copyWith(fontSize: 15)),
                      IconButton(
                        icon: Icon(Icons.close, color: ColorTheme.grey74),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  ).paddingOnly(left: 20, right: 20),
                  10.height,
                  Container(
                      height: 0.5, color: Color(0xff747474).withOpacity(.5)),
                  15.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          style: AppStyle.txt14FoodValue,
                          controller: menuController.productName,
                          decoration: InputDecoration(
                            hintText: AppString.foodName,
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: ColorTheme.grey.withOpacity(.5)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            border: AppBorder.categoryBorder,
                            enabledBorder: AppBorder.categoryBorder,
                            focusedBorder: AppBorder.categoryBorder
                                .copyWith(borderSide: BorderSide(width: 2)),
                          ),
                        ),
                      ),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 43,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorTheme.grey.withOpacity(.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: ColorTheme.whiteColor,
                                  value: menuController.quickCategoryValue,
                                  isExpanded: true,
                                  hint: Text(AppString.categoryName,
                                      style: AppStyle.txt14FoodValue),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: ColorTheme.grey.withOpacity(.5),
                                  ),
                                  items: [
                                    ...menuController.productCategoryList
                                        .map<DropdownMenuItem<String>>(
                                      (category) {
                                        String categoryName =
                                            category['name'] ??
                                                'Unnamed Category';
                                        return DropdownMenuItem<String>(
                                          value: categoryName,
                                          child: Text(
                                            categoryName,
                                            style: AppStyle.txt14FoodValue
                                                .copyWith(
                                                    color: ColorTheme.foodValue
                                                        .withOpacity(.8)),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    menuController.quickCategoryValue =
                                        newValue;
                                    var selectedCategoryData = menuController
                                        .productCategoryList
                                        .firstWhere(
                                      (category) =>
                                          category["name"].toString() ==
                                          menuController.quickCategoryValue,
                                    );

                                    menuController.quickCategoryIndex =
                                        selectedCategoryData["id"];
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                          8.width,
                          GestureDetector(
                            onTap: () {
                              // inventoryCategorySheet(
                              //   context,
                              //   inventoryController: inventoryController,
                              //   onTap: () async {
                              //     await inventoryController
                              //         .productAddCategories(menuController);
                              //   },
                              //   menuCategory: {},
                              // );
                              categoryBootomSheet(context,
                                  menuManagementController: menuController,
                                  onTap: () async {
                                if (menuController.categoriesController.text
                                        .trim() ==
                                    "") {
                                  Get.snackbar(
                                      "Check Again !", 'Category name is empty',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                  return;
                                } else if (menuController.selectedStationName ==
                                    '') {
                                  Get.snackbar("Check Again !",
                                      'Please select station name',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                  return;
                                } else {
                                  await menuController.AddCategories();
                                  setState(() {});
                                }
                              }, isEdit: false, menuCategory: {});
                            },
                            child: SvgPicture.asset(
                              Images.add_icon,
                              color: ColorTheme.grey8C,
                              width: 31.7,
                            ),
                          ),
                          8.width,
                          Expanded(
                            child: Container(
                              height: 45,
                              width: double.infinity,
                              child: TextFormField(
                                style: AppStyle.txt14FoodValue,
                                keyboardType: TextInputType.number,
                                controller: Get.find<AuthController>()
                                            .profileModel
                                            ?.restaurants
                                            ?.first
                                            .resturantType ==
                                        'Restaurant'
                                    ? menuController.menuPrice
                                    : resturantBueffetPriceController,
                                decoration: InputDecoration(
                                  hintText: AppString.price,
                                  hintStyle: AppStyle.stockListStyle.copyWith(
                                      color: ColorTheme.grey.withOpacity(.5)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 12),
                                  border: AppBorder.categoryBorder,
                                  enabledBorder: AppBorder.categoryBorder,
                                  focusedBorder: AppBorder.categoryBorder
                                      .copyWith(
                                          borderSide: BorderSide(width: 2)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      // Container(
                      //   height: 43,
                      //   padding: EdgeInsets.symmetric(horizontal: 15),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //         color: ColorTheme.grey.withOpacity(.5)),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: DropdownButtonHideUnderline(
                      //     child: DropdownButton<String>(
                      //       borderRadius: BorderRadius.circular(12),
                      //       dropdownColor: ColorTheme.whiteColor,
                      //       value: (menuController.quickItemValue?.isNotEmpty ??
                      //               false)
                      //           ? menuController.quickItemValue
                      //           : null,
                      //       isExpanded: true,
                      //       hint: Text(AppString.itemType,
                      //           style: AppStyle.txt14FoodValue),
                      //       icon: Icon(
                      //         Icons.keyboard_arrow_down_rounded,
                      //         color: ColorTheme.grey.withOpacity(.5),
                      //       ),
                      //       items: [
                      //         ...menuController.itemTypeList
                      //             .map<DropdownMenuItem<String>>(
                      //           (e) {
                      //             return DropdownMenuItem<String>(
                      //               value: e,
                      //               child: Text(
                      //                 e.toString(),
                      //                 style: AppStyle.txt14FoodValue.copyWith(
                      //                     color: ColorTheme.foodValue
                      //                         .withOpacity(.8)),
                      //               ),
                      //             );
                      //           },
                      //         ).toList(),
                      //       ],
                      //       onChanged: (String? newValue) {
                      //         menuController.quickItemValue = newValue!;
                      //         setState(() {});
                      //       },
                      //     ),
                      //   ),
                      // ),

                      Row(
                        children: [
                          // ================= LEFT SIDE DROPDOWN (Item Type) =================
                          Expanded(
                            child: Container(
                              height: 43,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorTheme.grey.withOpacity(.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: ColorTheme.whiteColor,
                                  value: (menuController
                                              .quickItemValue?.isNotEmpty ??
                                          false)
                                      ? menuController.quickItemValue
                                      : null,
                                  isExpanded: true,
                                  hint: Text(AppString.itemType,
                                      style: AppStyle.txt14FoodValue),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: ColorTheme.grey.withOpacity(.5),
                                  ),
                                  items: [
                                    ...menuController.itemTypeList
                                        .map<DropdownMenuItem<String>>(
                                      (e) {
                                        return DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e.toString(),
                                            style: AppStyle.txt14FoodValue
                                                .copyWith(
                                                    color: ColorTheme.foodValue
                                                        .withOpacity(.8)),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    menuController.quickItemValue = newValue!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),

                          if (foodItem["food_for"] != "Aggregator")
                            SizedBox(width: 20),

                          // ================= RIGHT SIDE DROPDOWN (Complementary) =================
                          if (foodItem["food_for"] != "Aggregator")
                            Expanded(
                              child: DropdownButtonFormField2<String>(
                                value: menuController
                                        .selectedComplementary.isNotEmpty
                                    ? menuController.selectedComplementary
                                    : null,

                                items: menuController.complementaryList
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: AppStyle.txt14FoodValue.copyWith(
                                        color: ColorTheme.foodValue
                                            .withOpacity(.7),
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (String? newValue) {
                                  menuController.selectedComplementary =
                                      newValue ?? '';
                                  menuController.update();
                                },

                                // Button Style
                                buttonStyleData: ButtonStyleData(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                ),

                                // Dropdown
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: Color(0xFFDCDCDC)),
                                  ),
                                ),

                                menuItemStyleData:
                                    MenuItemStyleData(height: 45),

                                // Decoration
                                decoration: InputDecoration(
                                  labelText: 'Complementary',
                                  labelStyle: AppStyle.txt14FoodValue.copyWith(
                                    color: ColorTheme.black,
                                    fontSize: 15,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      10.height,
                      GetBuilder<MenuManagementController>(builder: (context) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownWidget(
                              // items: menuController.taxTypeList
                              labelText: 'Tax Type',
                              items: menuController.taxTypeList
                                  .where((value) => !(value == 'VAT' &&
                                      menuController.isVat == 0))
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: AppStyle.txt14FoodValue.copyWith(
                                        color: ColorTheme.foodValue
                                            .withOpacity(.7)),
                                  ),
                                );
                              }).toList(),
                              value: menuController
                                      .selectedTaxType.value.isNotEmpty
                                  ? menuController.selectedTaxType.value
                                  : null,
                              hintText: 'Tax Type',
                              onChanged: Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .resturantGst ==
                                      'restaurant'
                                  ? null
                                  : (String? newValue) {
                                      menuController.selectedTaxType.value =
                                          newValue!;
                                      menuController.update();
                                      print(
                                          "selectedTaxType ${menuController.selectedTaxType.value}");
                                    },
                            ),
                            20.width,
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: ColorTheme.transparent),
                                ),
                                child: CustomTextformField(
                                  labelText: 'Tax',
                                  controller: menuController.taxController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  ).paddingOnly(left: 20, right: 20),
                ],
              ),
              20.height,
              Row(
                children: [
                  Obx(
                    () => Expanded(
                      child: GestureDetector(
                        onTap: menuController.isUpdateFoodSubmitting.value
                            ? null
                            : () async {
                                log("food forHHH:${foodItem["food_for"]}");
                                final data = {
                                  "name": menuController.productName.text,
                                  "category_id":
                                      menuController.quickCategoryIndex,
                                  "price": double.tryParse(
                                          menuController.menuPrice.text) ??
                                      0,
                                  "veg": menuController.quickItemValue == "Veg"
                                      ? 1
                                      : menuController.quickItemValue == "Jain"
                                          ? 3
                                          : menuController.quickItemValue ==
                                                  "Egg"
                                              ? 2
                                              : 0,
                                  "food_for": foodItem["food_for"],
                                  "tax_type":
                                      menuController.selectedTaxType.value == ''
                                          ? "GST"
                                          : menuController
                                              .selectedTaxType.value,
                                  "tax":
                                      menuController.taxController.text.trim(),
                                  if (foodItem["food_for"] != "Aggregator")
                                    "complementary":
                                        menuController.selectedComplementary,
                                };
                                await menuController.updateFood(
                                    foodItem['id'], data);
                              },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(color: ColorTheme.appColor),
                          alignment: Alignment.center,
                          child: menuController.isUpdateLoader.value
                              ? AppLoader()
                              : Text(AppString.editChanges,
                                  style: AppStyle.txt14FoodValue.copyWith(
                                      color: ColorTheme.whiteColor,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.to(() => AddEditMenuScreen(
                              isEdit: true,
                              food: foodItem,
                              menuFoodFor: foodItem["food_for"],
                            ));
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(color: ColorTheme.greenColor),
                        alignment: Alignment.center,
                        child: Text(
                          AppString.viewFullInfo,
                          style: AppStyle.txt14FoodValue.copyWith(
                              color: ColorTheme.whiteColor,
                              fontWeight: FontWeight.w600),
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
}
