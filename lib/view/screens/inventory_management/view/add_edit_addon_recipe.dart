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
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'add_Ingredients_screen.dart';

class AddEditAddonRecipeScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic> recipes;

  const AddEditAddonRecipeScreen(
      {Key? key, this.isEdit = false, required this.recipes})
      : super(key: key);

  @override
  State<AddEditAddonRecipeScreen> createState() =>
      _AddEditAddonRecipeScreenState();
}

class _AddEditAddonRecipeScreenState extends State<AddEditAddonRecipeScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;

  @override
  void initState() {
    super.initState();
    log('addon recipes:${widget.recipes}');
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    apicalling();
  }

  apicalling() async {
    await expenseController?.getUnit();
    await inventoryController?.getAddonsWithoutRecipe();

    if (widget.isEdit) {
      inventoryController?.showAddonRecipesData(widget.recipes);
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
      inventoryController?.clearAddonRecipeData();
    }
    inventoryController?.update();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.bgColor,
        appBar: CustomAppBar(
          titleText:
              widget.isEdit ? 'Edit Addon Recipe' : 'Add Addon Recipe',
          actions: [
            widget.isEdit
                ? MyCustomButton(
                    text: AppString.delete,
                    color: ColorTheme.grey8C,
                    width: 150,
                    onTap: () async {
                      deleteRecipesSheet(
                        context,
                        recipeText: widget.recipes["addon_name"],
                        onDeleteTap: () async {
                          await inventoryController?.deleteAddonRecipe(
                              widget.recipes["recipe_id"],
                              deleteInside: true);
                        },
                        inventoryController: inventoryController!,
                      );
                    },
                  ).paddingSymmetric(vertical: 8, horizontal: 10)
                : uploadIconWidget(
                    onDownLoadTap: () async {
                      // TODO: addon recipe export — coming soon
                      // Get.to(() => BulkImportScreen(
                      //       tittleName: 'Add Addon Recipes',
                      //       controller: Get.find<InventoryController>(),
                      //       isFunction: true,
                      //       onDownloadSampleDataTap: () {
                      //         inventoryController?.exportAddonRecipeSample();
                      //       },
                      //       onDownloadExistingDataTap: () {
                      //         inventoryController?.exportAddonRecipe();
                      //       },
                      //       onuploadTap: () {
                      //         inventoryController?.importAddonRecipe();
                      //       },
                      //     ));
                    },
                    onUploadTap: () async {
                      // TODO: addon recipe import — coming soon
                      // Get.to(() => BulkImportScreen(
                      //       tittleName: 'Add Addon Recipes',
                      //       controller: Get.find<InventoryController>(),
                      //       isFunction: true,
                      //       onDownloadSampleDataTap: () {
                      //         inventoryController?.exportAddonRecipeSample();
                      //       },
                      //       onDownloadExistingDataTap: () {
                      //         inventoryController?.exportAddonRecipe();
                      //       },
                      //       onuploadTap: () {
                      //         inventoryController?.importAddonRecipe();
                      //       },
                      //     ));
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
                      SizedBox(height: 2),
                      Container(
                        color: ColorTheme.whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                          child: Column(
                            children: [
                              // ── Name field ──────────────────────────────────────────────
                              Row(
                                children: [
                                  widget.isEdit
                                      // Edit mode → read-only, name already set from showAddonRecipesData()
                                      ? Expanded(
                                          child: CustomTextformField(
                                            readOnly: true,
                                            fillColor: ColorTheme.whiteF0F0F0,
                                            labelText: AppString.name,
                                            controller: inventoryController
                                                ?.recipeNameController,
                                          ),
                                        )
                                      // Add mode → autocomplete picker from addonsWithoutRecipeList
                                      : GetBuilder<InventoryController>(
                                          builder: (controller) =>
                                              CustomAutoCompleteWidget(
                                            onSelected: (selection) {
                                              inventoryController
                                                  ?.recipeNameController
                                                  .text = selection;
                                              final selectedAddon =
                                                  inventoryController
                                                      ?.addonsWithoutRecipeList
                                                      .firstWhere(
                                                (item) =>
                                                    item["name"]
                                                        .toString()
                                                        .toLowerCase() ==
                                                    selection.toLowerCase(),
                                                orElse: () => {},
                                              );
                                              inventoryController
                                                      ?.addonRecipeAddonId =
                                                  selectedAddon?["id"];
                                              inventoryController?.update();
                                            },
                                            appToastMessage:
                                                AppString.noFoodNameAvailable,
                                            customTextEditingController:
                                                inventoryController
                                                    ?.recipeNameController,
                                            hintText: AppString.name,
                                            list: inventoryController
                                                    ?.addonsWithoutRecipeList
                                                    .map((e) =>
                                                        e["name"].toString())
                                                    .toList() ??
                                                [],
                                          ),
                                        ),
                                ],
                              ),

                              20.height,
                              Row(
                                children: [
                                  // ── Unit dropdown → addonRecipeUnitValue ──
                                  GetBuilder<InventoryController>(
                                    builder: (controller) =>
                                        CustomDropdownWidget(
                                      items: expenseController!.getUnitList
                                          .map((String value) {
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
                                       
                                        controller.addonRecipeUnitValue =
                                            newValue ;
                                        controller.update();
                                       
                                      },
                                      value: (controller.addonRecipeUnitValue !=
                                                  null &&
                                              controller.addonRecipeUnitValue!
                                                  .trim()
                                                  .isNotEmpty &&
                                              expenseController!.getUnitList
                                                  .map((e) =>
                                                      e.trim().toLowerCase())
                                                  .contains(controller
                                                      .addonRecipeUnitValue!
                                                      .trim()
                                                      .toLowerCase()))
                                          ? controller.addonRecipeUnitValue!
                                              .trim()
                                          : null,
                                    ),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: CustomTextformField(
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
                                        borderRadius: BorderRadius.circular(30),
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
                                      ),
                                    ),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
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
                                      ),
                                    ),
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
                              // ── Ingredients list ──────────────────────────────
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
                                                      : null,
                                                );
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
                                        ),
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
                              20.height,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Bottom action bar ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      inventoryController?.clearAddonRecipeData();
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
                      onTap: inventoryController!.isAddonRecipeSubmitting.value
                          ? null
                          : () async {
                              if (widget.isEdit) {
                                await inventoryController?.updateAddonRecipe();
                              } else {
                                await inventoryController?.addAddonRecipe();
                              }
                            },
                      child: Container(
                        height: 50,
                        color: ColorTheme.greenColor,
                        alignment: Alignment.center,
                        child: inventoryController!.addAddonRecipeLoader.value
                            ? AppLoader()
                            : Text(
                                AppString.submit,
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
          ],
        ),
      ),
    );
  }
}
