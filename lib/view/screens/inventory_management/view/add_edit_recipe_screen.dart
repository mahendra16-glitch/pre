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
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/delete_recipe_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/custom_auto_complete.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/add_edit_menu/add_edit_menu_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import 'add_Ingredients_screen.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic> recipes;

  const AddEditRecipeScreen(
      {Key? key, this.isEdit = false, required this.recipes})
      : super(key: key);

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;

  @override
  void initState() {
    super.initState();
    log('recipes:${widget.recipes}');
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    apicalling();
    // if (widget.isEdit) {
    //   inventoryController?.showRecipesData(widget.recipes);
    // } else {
    //   inventoryController?.clearRecipesData();
    // }
  }

  apicalling() async {
    await expenseController?.getUnit();
    await inventoryController?.getRecipeFoodList(); // Load active foods list

    if (widget.isEdit) {
      inventoryController?.showRecipesData(widget.recipes);
      // Fetch units for each ingredient in edit mode
      for (int i = 0;
          i < inventoryController!.recipesIngredientsList.length;
          i++) {
        final recipes = inventoryController!.recipesIngredientsList[i];
        if (recipes["ingredientsId"] != null &&
            recipes["ingredientsId"] is int &&
            (recipes["ingredientsId"] as int) > 0) {
          await inventoryController!
              .getUnitInventory(recipes["ingredientsId"] as int);
          recipes["unitList"] = inventoryController!.getUnitInventoryList
              .cast<String>()
              .toSet()
              .toList();
          // If current unit is not in the list, set to first
          final unitList = recipes["unitList"] as List<String>;
          if (unitList.isNotEmpty && !unitList.contains(recipes["unit"])) {
            recipes["unit"] = unitList.first;
          }
        }
      }
    } else {
      inventoryController?.clearRecipesData();
    }
    inventoryController?.update(); // important after setting recipe
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.bgColor,
        appBar: CustomAppBar(
          titleText:
              widget.isEdit ? AppString.editRecipes : AppString.addRecipes,
          actions: [
            widget.isEdit
                ? MyCustomButton(
                    text: AppString.delete,
                    color: ColorTheme.grey8C,
                    width: 150,
                    onTap: () async {
                      deleteRecipesSheet(
                        context,
                        recipeText: widget.recipes["food_name"],
                        onDeleteTap: () async {
                          await inventoryController?.deleteRecipe(
                              widget.recipes["recipe_id"],
                              deleteInside: true);
                        },
                        inventoryController: inventoryController!,
                      );
                    },
                  ).paddingSymmetric(vertical: 8, horizontal: 10)
                : uploadIconWidget(
                    onDownLoadTap: () async {
                      // await inventoryController?.exportRecipe();
                      Get.to(() => BulkImportScreen(
                            tittleName: 'Add Recipes',
                            controller: Get.find<InventoryController>(),
                            isFunction: true,
                            onDownloadSampleDataTap: () {
                              inventoryController?.exportRecipeSample();
                            },
                            onDownloadExistingDataTap: () {
                              inventoryController?.exportRecipe();
                            },
                            onuploadTap: () {
                              inventoryController?.importRecipe();
                            },
                          ));
                    },
                    onUploadTap: () async {
                      // await inventoryController?.importRecipe();
                      Get.to(() => BulkImportScreen(
                            tittleName: 'Add Recipes',
                            controller: Get.find<InventoryController>(),
                            isFunction: true,
                            onDownloadSampleDataTap: () {
                              inventoryController?.exportRecipeSample();
                            },
                            onDownloadExistingDataTap: () {
                              inventoryController?.exportRecipe();
                            },
                            onuploadTap: () {
                              inventoryController?.importRecipe();
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
                      // widget.isEdit == false
                      //     ? MyCustomButton(
                      //         text: AppString.bulkUpload,
                      //         onTap: () async {
                      //           await inventoryController?.importRecipe();
                      //         },
                      //       )
                      //         .paddingSymmetric(horizontal: 16)
                      //         .paddingOnly(top: 20, bottom: 30)
                      //     : SizedBox(),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        color: ColorTheme.whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GetBuilder<InventoryController>(
                                    builder: (controller) =>
                                        CustomAutoCompleteWidget(
                                      onSelected: (selection) {
                                        inventoryController
                                            ?.recipeNameController
                                            .text = selection;
                                        final selectedAddon =
                                            inventoryController?.recipeFoodList
                                                .firstWhere(
                                          (inventory) =>
                                              inventory["name"]
                                                  .toString()
                                                  .toLowerCase() ==
                                              selection.toLowerCase(),
                                        );
                                        final selectedId = selectedAddon?["id"];

                                        inventoryController?.foodRecipeId =
                                            selectedId;
                                      },
                                      appToastMessage:
                                          AppString.noFoodNameAvailable,
                                      customTextEditingController:
                                          inventoryController
                                              ?.recipeNameController,
                                      hintText: AppString.name,
                                      list: inventoryController?.recipeFoodList
                                              .map((e) => e["name"])
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                  20.width,
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => AddEditMenuScreen(
                                            isEdit: false,
                                            food: {},
                                          ));
                                    },
                                    child: Icon(Icons.add_circle_outline,
                                        size: 34, color: ColorTheme.grey8C),
                                  ),
                                ],
                              ),
                              20.height,
                              Row(
                                children: [
                                  // GetBuilder<InventoryController>(
                                  //   builder: (controller) =>
                                  //       CustomDropdownWidget(
                                  //     items: expenseController!.getUnitList
                                  //         .map((String value) {
                                  //       print(expenseController!.getUnitList);
                                  //       return DropdownMenuItem<String>(
                                  //         value: value,
                                  //         child: Text(
                                  //           value,
                                  //           style: TextStyle(
                                  //             fontFamily: "Montserrat",
                                  //             // fontFamily: AppFonts.montserrat,
                                  //             fontSize: 12,
                                  //             color: ColorTheme.foodValue,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }).toList(),
                                  //     hintText: AppString.unit,
                                  //     onChanged: (String? newValue) {
                                  //       controller
                                  //               ?.addRecipesUnitValue =
                                  //           newValue ?? "";
                                  //       controller?.update();
                                  //     },
                                  //     value: (inventoryController
                                  //                     ?.addRecipesUnitValue !=
                                  //                 null &&
                                  //             inventoryController!
                                  //                 .addRecipesUnitValue!
                                  //                 .isNotEmpty &&
                                  //             expenseController!.getUnitList
                                  //                 .contains(inventoryController!
                                  //                     .addRecipesUnitValue))
                                  //         ? controller
                                  //             ?.addRecipesUnitValue
                                  //         : null,
                                  //   ),
                                  // ),

                                  GetBuilder<InventoryController>(
                                    builder: (controller) =>
                                        CustomDropdownWidget(
                                      items: expenseController!.getUnitList
                                          .map((String value) {
                                        // print(
                                        //     'Unit List: ${expenseController!.getUnitList}');
                                        // print(
                                        //     'Selected Unit: ${controller.addRecipesUnitValue}');
                                        // print(
                                        //     'Contains check: ${expenseController!.getUnitList.contains(controller.addRecipesUnitValue)}');

                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 12,
                                              color: ColorTheme.foodValue,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      hintText: AppString.unit,
                                      onChanged: (String? newValue) {
                                        // print(
                                        //     'Unit List: ${expenseController!.getUnitList}');
                                        // print(
                                        //     'Selected Unit: ${controller.addRecipesUnitValue}');
                                        // print(
                                        //     'Contains check: ${expenseController!.getUnitList.contains(controller.addRecipesUnitValue)}');

                                        controller.addRecipesUnitValue =
                                            newValue ?? "";
                                        controller.update();
                                      },
                                      value: (controller.addRecipesUnitValue !=
                                                  null &&
                                              controller.addRecipesUnitValue!
                                                  .trim()
                                                  .isNotEmpty &&
                                              expenseController!.getUnitList
                                                  .map((e) =>
                                                      e.trim().toLowerCase())
                                                  .contains(controller
                                                      .addRecipesUnitValue!
                                                      .trim()
                                                      .toLowerCase()))
                                          ? controller.addRecipesUnitValue!
                                              .trim()
                                          : null,
                                    ),
                                  ),

                                  20.width,
                                  Expanded(
                                    child: CustomTextformField(
                                      // readOnly: widget.isEdit ? true : false,
                                      // fillColor: widget.isEdit == true
                                      //     ? ColorTheme.whiteF0F0F0
                                      //     : ColorTheme.whiteColor,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      labelText: AppString.quantity,
                                      controller: inventoryController
                                          ?.quantityController,
                                    ),
                                  ),
                                ],
                              ),
                              20.height,
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color: ColorTheme.transparent),
                                        ),
                                        child: CustomTextformField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          labelText: AppString.preparationTime,
                                          controller: inventoryController
                                              ?.recipesPreparationTimeController,
                                        )),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color: ColorTheme.transparent),
                                        ),
                                        child: CustomTextformField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          labelText: AppString.serveTime,
                                          controller: inventoryController
                                              ?.recipesServeTimeController,
                                        )),
                                  ),
                                ],
                              ),
                              20.height,
                              CustomTextformField(
                                keyboardType: TextInputType.number,
                                labelText: AppString.servePeople,
                                controller:
                                    inventoryController?.servePeopleController,
                              ).paddingOnly(
                                  right:
                                      MediaQuery.of(context).size.width / 2.17),
                              20.height,
                              Divider(color: ColorTheme.whiteE4, thickness: 1),
                              10.height,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: inventoryController
                                    ?.recipesIngredientsList.length,
                                itemBuilder: (context, index) {
                                  final recipes = inventoryController
                                      ?.recipesIngredientsList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            CustomAutoCompleteWidget(
                                              customTextEditingController:
                                                  recipes?[
                                                      "ingredientsNameController"],
                                              hintText: AppString.ingredients,
                                              list: inventoryController
                                                      ?.recipeIngredientsList
                                                      .map(
                                                        (e) => e["stock_title"],
                                                      )
                                                      .toList() ??
                                                  [],
                                              onSelected: (selection) async {
                                                recipes?[
                                                        "ingredientsNameController"]
                                                    .text = selection;
                                                final selectedAddon =
                                                    inventoryController
                                                        ?.recipeIngredientsList
                                                        .firstWhere(
                                                  (inventory) =>
                                                      inventory["stock_title"]
                                                          .toString()
                                                          .toLowerCase() ==
                                                      selection.toLowerCase(),
                                                );
                                                final selectedId =
                                                    selectedAddon?["id"];

                                                recipes?["ingredientsId"] =
                                                    selectedId;

                                                await inventoryController
                                                    ?.getUnitInventory(
                                                        selectedId ?? 0);

                                                print(
                                                    '......${inventoryController?.getUnitInventoryList.first}');
                                                recipes?["unitList"] =
                                                    (inventoryController
                                                                ?.getUnitInventoryList ??
                                                            [])
                                                        .cast<String>()
                                                        .toSet()
                                                        .toList();

                                                recipes?["unit"] =
                                                    recipes["unitList"]
                                                            .isNotEmpty
                                                        ? recipes["unitList"]
                                                            .first
                                                        : "";

                                                log('recipes["ingredientsId"] :${recipes?["ingredientsId"]}');
                                                inventoryController?.update();
                                              },
                                              appToastMessage: AppString
                                                  .noIngredientsAvailable,
                                            ),
                                            20.width,
                                            GestureDetector(
                                              onTap: () {
                                                Get.to(() =>
                                                    AddIngredientsScreen());
                                              },
                                              child: Icon(
                                                  Icons.add_circle_outline,
                                                  size: 34,
                                                  color: ColorTheme.grey8C),
                                            ),
                                          ],
                                        ),
                                        20.height,
                                        Row(
                                          children: [
                                            GetBuilder<
                                                ExpenseManagementController>(
                                              builder: (controller) {
                                                final unitList =
                                                    recipes?["unitList"]
                                                        as List<String>?;
                                                final List<String> baseList =
                                                    (unitList != null &&
                                                            unitList.isNotEmpty)
                                                        ? unitList
                                                        : expenseController!
                                                            .getUnitList;
                                                final List<String> itemsList =
                                                    baseList.toSet().toList();
                                                return CustomDropdownWidget(
                                                    items: itemsList
                                                        .map((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            // fontFamily: AppFonts.montserrat,
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
                                                      recipes?["unit"] =
                                                          newValue ?? "";
                                                      inventoryController
                                                          ?.update();
                                                    },
                                                    value: (recipes?["unit"]
                                                                ?.isNotEmpty ??
                                                            false)
                                                        ? recipes!["unit"]
                                                        : null);
                                              },
                                            ),
                                            20.width,
                                            Expanded(
                                              child: CustomTextformField(
                                                controller:
                                                    recipes?["quantity"],
                                                labelText: AppString.quantity,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^\d*\.?\d*')),
                                                ],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          ],
                                        ),
                                        15.height,
                                        GestureDetector(
                                          onTap: () {
                                            inventoryController
                                                ?.removeRecipesIngredientsData(
                                                    index);
                                          },
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: SvgPicture.asset(
                                              Images.deleteIcon,
                                              height: 20,
                                              color: ColorTheme.redColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              20.height,
                              GestureDetector(
                                onTap: () => inventoryController
                                    ?.addRecipesIngredientsData(),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(Images.add_icon,
                                        color: ColorTheme.grey, height: 18),
                                    8.width,
                                    Text(AppString.addItem,
                                        style: TextStyle(
                                            color: ColorTheme.greenColor,
                                            fontSize: 13)),
                                  ],
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
                      inventoryController?.clearRecipesData();
                      setState(() {});
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
                      onTap: inventoryController!.isAddRecipesSubmitting.value
                          ? null
                          : () async {
                              if (widget.isEdit) {
                                await inventoryController
                                    ?.updateRecipe(widget.recipes["recipe_id"]);
                              } else {
                                await inventoryController?.addRecipe();
                              }
                            },
                      child: Container(
                        height: 50,
                        color: ColorTheme.greenColor,
                        alignment: Alignment.center,
                        child: inventoryController!.addRecipesLoader.value
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
