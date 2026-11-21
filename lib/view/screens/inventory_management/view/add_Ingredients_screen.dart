import 'dart:developer';

import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/widget/category_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';

import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';

import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../widget/custom_auto_complete.dart';

class AddIngredientsScreen extends StatefulWidget {
  const AddIngredientsScreen({Key? key}) : super(key: key);

  @override
  State<AddIngredientsScreen> createState() => _AddIngredientsScreenState();
}

class _AddIngredientsScreenState extends State<AddIngredientsScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;
  MenuManagementController? menuManagementController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    menuManagementController = Get.find<MenuManagementController>();

    onCalling();
    inventoryController?.categoryIngredientsController.clear();
    inventoryController?.ingredientsList.clear();
    inventoryController?.ingredientsList
        .add(InventoryController.addIngredients());

    super.initState();
  }

  onCalling() async {
    // menuManagementController?.categoryList.clear();
    inventoryController?.categoryStockList.clear();
    await expenseController?.getUnit();
    await inventoryController?.getStockCategoryList();
    // await menuManagementController.getCategoryList();
    // await menuManagementController?.getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.bgColor,
        appBar: CustomAppBar(
          titleText: AppString.addIngredients,
          actions: [
            uploadIconWidget(
              onDownLoadTap: () async {
                // await inventoryController?.ExportIngredients();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Add Ingredients',
                      controller: Get.find<InventoryController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        inventoryController?.exportIngredientsSample();
                      },
                      onDownloadExistingDataTap: () {
                        inventoryController?.ExportIngredients();
                      },
                      onuploadTap: () {
                        inventoryController?.importIngredients();
                      },
                    ));
              },
              onUploadTap: () async {
                // await inventoryController?.importInventory();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Add Ingredients',
                      controller: Get.find<InventoryController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        inventoryController?.exportIngredientsSample();
                      },
                      onDownloadExistingDataTap: () {
                        inventoryController?.ExportIngredients();
                      },
                      onuploadTap: () {
                        inventoryController?.importIngredients();
                      },
                    ));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            GetBuilder<InventoryController>(
              builder: (controller) => Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // MyCustomButton(
                      //   text: AppString.inventoryBulkImport,
                      //   onTap: () async {
                      //     await inventoryController?.importInventory();
                      //   },
                      // ).paddingSymmetric(horizontal: 16).paddingOnly(top: 20),
                      30.height,
                      Container(
                        color: ColorTheme.whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    inventoryController?.ingredientsList.length,
                                itemBuilder: (context, index) {
                                  final ingredients = inventoryController
                                      ?.ingredientsList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // GetBuilder<
                                            //     MenuManagementController>(
                                            //   builder:
                                            //       (menuManagementController) {
                                            //     return CustomAutoCompleteWidget(
                                            //       appToastMessage:
                                            //           AppString.noCategoryFound,
                                            //       onSelected: (selection) {
                                            //         ingredients?[
                                            //                 "categoryController"]
                                            //             .text = selection;

                                            //         final selectedAddon =
                                            //             menuManagementController
                                            //                 .categoryList
                                            //                 .firstWhere(
                                            //           (vendor) =>
                                            //               vendor["name"]
                                            //                   .toString()
                                            //                   .toLowerCase() ==
                                            //               selection
                                            //                   .toLowerCase(),
                                            //           orElse: () => {},
                                            //         );

                                            //         if (selectedAddon
                                            //             .isNotEmpty) {
                                            //           ingredients?[
                                            //                   "categoryId"] =
                                            //               selectedAddon["id"];
                                            //           log("Category ID: ${ingredients!["categoryId"]}");
                                            //         }
                                            //       },
                                            //       customTextEditingController:
                                            //           ingredients![
                                            //               "categoryController"],
                                            //       hintText: AppString.category,
                                            //       list: menuManagementController
                                            //           .categoryList
                                            //           .map((e) => e["name"])
                                            //           .toList(),
                                            //     );
                                            //   },
                                            // ),
                                            CustomAutoCompleteWidget(
                                              appToastMessage:
                                                  AppString.noCategoryFound,
                                              onSelected: (selection) {
                                                ingredients[
                                                        "categoryController"]
                                                    .text = selection;

                                                final selectedAddon = controller
                                                    .categoryStockList
                                                    .firstWhere(
                                                  (vendor) =>
                                                      vendor["category_name"]
                                                          .toString()
                                                          .toLowerCase() ==
                                                      selection.toLowerCase(),
                                                  orElse: () => {},
                                                );

                                                if (selectedAddon.isNotEmpty ==
                                                    true) {
                                                  ingredients["categoryId"] =
                                                      selectedAddon["id"];
                                                  log("Category ID: ${ingredients["categoryId"]}");
                                                }
                                              },
                                              customTextEditingController:
                                                  ingredients![
                                                      "categoryController"],
                                              hintText: AppString.category,
                                              list: controller.categoryStockList
                                                  .map(
                                                      (e) => e["category_name"])
                                                  .toList(),
                                            ),
                                            20.width,
                                            GestureDetector(
                                              onTap: () {
                                                inventoryCategorySheet(
                                                  context,
                                                  inventoryController:
                                                      inventoryController!,
                                                  onTap: () async {
                                                    await inventoryController
                                                        ?.AddStockCategories();
                                                  },
                                                  menuCategory: {},
                                                );
                                              },
                                              child: Icon(
                                                  Icons.add_circle_outline,
                                                  size: 34,
                                                  color: ColorTheme.grey8C),
                                            ),
                                          ],
                                        ),
                                        20.height,
                                        CustomTextformField(
                                          controller:
                                              ingredients["ingredientsName"],
                                          labelText: AppString.ingredientsName,
                                        ),
                                        20.height,
                                        Row(
                                          children: [
                                            CustomDropdownWidget(
                                                items: inventoryController
                                                    ?.unitList
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Montserrat",
                                                        // fontFamily:
                                                        //     AppFonts.montserrat,
                                                        fontSize: 12,
                                                        color: ColorTheme
                                                            .foodValue,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                hintText: AppString.bigUnit,
                                                onChanged: (String? newValue) {
                                                  ingredients["bigUnit"] =
                                                      newValue;
                                                  if (ingredients["bigUnit"] ==
                                                      "kg") {
                                                    ingredients["smallUnit"] =
                                                        "gm";
                                                  }
                                                  if (ingredients["bigUnit"] ==
                                                      "ltr") {
                                                    ingredients["smallUnit"] =
                                                        "ml";
                                                  }
                                                  if (ingredients["bigUnit"] ==
                                                      "bundle") {
                                                    ingredients["smallUnit"] =
                                                        "bundle";
                                                  }
                                                  if (ingredients["bigUnit"] ==
                                                      "pkt") {
                                                    ingredients["smallUnit"] =
                                                        "pkt";
                                                  }
                                                  if (ingredients["bigUnit"] ==
                                                      "piece") {
                                                    ingredients["smallUnit"] =
                                                        "piece";
                                                  }
                                                  if (ingredients["bigUnit"] ==
                                                      "bottle") {
                                                    ingredients["smallUnit"] =
                                                        "bottle";
                                                  }
                                                  inventoryController?.update();
                                                },
                                                value:
                                                    ingredients["bigUnit"] != ""
                                                        ? ingredients["bigUnit"]
                                                        : null),
                                            20.width,
                                            if ((ingredients["bigUnit"] ==
                                                    "bundle") ||
                                                (ingredients["bigUnit"] ==
                                                    "pkt") ||
                                                (ingredients["bigUnit"] ==
                                                    "piece") ||
                                                (ingredients["bigUnit"] ==
                                                    "bottle"))
                                              CustomDropdownWidget(
                                                  items: [
                                                    "bundle",
                                                    "pkt",
                                                    "piece",
                                                    "bottle"
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Montserrat",
                                                          // fontFamily:
                                                          //     AppFonts.montserrat,
                                                          fontSize: 12,
                                                          color: ColorTheme
                                                              .foodValue,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  hintText: AppString.smallUnit,
                                                  value: ingredients[
                                                              "smallUnit"] !=
                                                          ""
                                                      ? ingredients["smallUnit"]
                                                      : null)
                                            else
                                              CustomDropdownWidget(
                                                  items: ["ml", "gm"]
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Montserrat",
                                                          // fontFamily:
                                                          //     AppFonts.montserrat,
                                                          fontSize: 12,
                                                          color: ColorTheme
                                                              .foodValue,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  hintText: AppString.smallUnit,
                                                  value: ingredients[
                                                              "smallUnit"] !=
                                                          ""
                                                      ? ingredients["smallUnit"]
                                                      : null),
                                          ],
                                        ),
                                        20.height,
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: CustomTextformField(
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^\d*\.?\d*')),
                                                ],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                formBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(30),
                                                    bottomLeft:
                                                        Radius.circular(30),
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: ColorTheme.whiteDC,
                                                    width: 1,
                                                  ),
                                                ),
                                                controller: ingredients[
                                                    "thresholdQuantity"],
                                                labelText:
                                                    AppString.thresholdQuantity,
                                              ),
                                            ),
                                            GetBuilder<
                                                ExpenseManagementController>(
                                              builder: (controller) =>
                                                  CustomDropdownWidget(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(30),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                      items: expenseController
                                                          ?.getUnitList
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Montserrat",
                                                              // fontFamily:
                                                              //     AppFonts.montserrat,
                                                              fontSize: 12,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      hintText: AppString.unit,
                                                      onChanged:
                                                          (String? newValue) {
                                                        ingredients["unit"] =
                                                            newValue;
                                                        controller.update();
                                                      },
                                                      value: ingredients[
                                                                  "unit"] !=
                                                              ""
                                                          ? ingredients["unit"]
                                                          : null),
                                            ),
                                          ],
                                        ),
                                        15.height,
                                        Divider(
                                            color: ColorTheme.whiteE4,
                                            thickness: 1),
                                        GestureDetector(
                                          onTap: () {
                                            inventoryController
                                                ?.removeIngredientsData(index);
                                          },
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: SvgPicture.asset(
                                              Images.deleteIcon,
                                              height: 20,
                                              color: ColorTheme.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              20.height,
                              GetBuilder<InventoryController>(
                                builder: (controller) => GestureDetector(
                                  onTap: () => controller.addIngredientsData(),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(Images.add_icon,
                                          color: ColorTheme.grey, height: 18),
                                      8.width,
                                      Text(AppString.addIngredients,
                                          style: TextStyle(
                                              color: ColorTheme.greenColor,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              20.height
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      inventoryController?.resetIngredientsData();
                    },
                    child: Container(
                      height: 50,
                      color: ColorTheme.greyColor.withOpacity(0.2),
                      alignment: Alignment.center,
                      child: Text(AppString.Reset),
                    ),
                  ),
                ),
                Obx(
                  () => Expanded(
                    child: GestureDetector(
                      onTap: inventoryController!
                              .addIngredientsInventorySubmitting.value
                          ? null
                          : () {
                              inventoryController?.addIngredientsInventory();
                            },
                      child: Container(
                        height: 50,
                        color: ColorTheme.greenColor,
                        alignment: Alignment.center,
                        child: inventoryController!
                                .addIngredientsInventoryLoader.value
                            ? AppLoader()
                            : Text(AppString.submit,
                                style: TextStyle(
                                    color: ColorTheme.whiteColor,
                                    fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
