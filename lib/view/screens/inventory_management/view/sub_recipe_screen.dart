// import 'dart:developer';
// import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
// import 'package:mygenie_restaurant/admin/constant/app_string.dart'
//     show AppString;
// import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
// import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
// import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
// import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
// import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/delete_recipe_sheet.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/widget/custom_auto_complete.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
// import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';

// import '../../../../util/images.dart';
// import 'add_Ingredients_screen.dart';

// class SubRecipeScreen extends StatefulWidget {
//   final bool isEdit;
//   final Map<String, dynamic> subRecipes;

//   const SubRecipeScreen(
//       {Key? key, this.isEdit = false, required this.subRecipes})
//       : super(key: key);

//   @override
//   State<SubRecipeScreen> createState() => _SubRecipeScreenState();
// }

// class _SubRecipeScreenState extends State<SubRecipeScreen> {
//   InventoryController? inventoryController;
//   ExpenseManagementController? expenseController;

//   @override
//   void initState() {
//     inventoryController = Get.find<InventoryController>();
//     expenseController = Get.find<ExpenseManagementController>();
//     // inventoryController?.clearSubRecipesData();
//     apicalling();
//     super.initState();
//   }

//   apicalling() async {
//     await expenseController?.getUnit();
//     if (widget.isEdit) {
//       inventoryController?.showSubRecipesData(widget.subRecipes);
//     } else {
//       inventoryController?.clearSubRecipesData();
//     }
//     inventoryController?.update();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyboardDisable(
//       child: Scaffold(
//         backgroundColor: ColorTheme.bgColor,
//         appBar: CustomAppBar(
//           titleText:
//               widget.isEdit ? 'Edit Sub-Recipe' : AppString.addSubRecipes,
//           actions: [
//             widget.isEdit
//                 ? MyCustomButton(
//                     text: AppString.delete,
//                     color: ColorTheme.grey8C,
//                     width: 150,
//                     onTap: () async {
//                       deleteRecipesSheet(
//                         context,
//                         recipeText: widget.subRecipes["food_name"],
//                         onDeleteTap: () async {
//                           await inventoryController?.deleteSubRecipe(
//                               widget.subRecipes["recipe_id"],
//                               deleteInside: true);
//                         },
//                         inventoryController: inventoryController!,
//                       );
//                     },
//                   ).paddingSymmetric(vertical: 8, horizontal: 10)
//                 : uploadIconWidget(
//                     onDownLoadTap: () async {
//                       await inventoryController?.exportSubRecipes();
//                     },
//                     onUploadTap: () async {
//                       await inventoryController?.importSubRecipes();
//                     },
//                   ),
//           ],
//         ),
//         body: Column(
//           children: [
//             GetBuilder<InventoryController>(
//               builder: (controller) => Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Container(
//                         color: ColorTheme.whiteColor,
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CustomTextformField(
//                                 labelText: AppString.name,
//                                 controller: inventoryController
//                                     ?.subRecipeNameController,
//                               ),
//                               20.height,
//                               Row(
//                                 children: [
//                                   GetBuilder<ExpenseManagementController>(
//                                     builder: (controller) =>
//                                         CustomDropdownWidget(
//                                       items: expenseController!.getUnitList
//                                           .map((String value) {
//                                         return DropdownMenuItem<String>(
//                                           value: value,
//                                           child: Text(
//                                             value,
//                                             style: TextStyle(
//                                               // fontFamily: AppFonts.montserrat,
//                                               fontSize: 12,
//                                               color: ColorTheme.foodValue,
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       hintText: AppString.unit,
//                                       onChanged: (String? newValue) {
//                                         inventoryController?.subRecipeUnit =
//                                             newValue ?? "";
//                                         inventoryController?.update();
//                                       },
//                                       value: (inventoryController
//                                                   ?.subRecipeUnit?.isNotEmpty ??
//                                               false)
//                                           ? inventoryController?.subRecipeUnit
//                                           : null,
//                                     ),
//                                   ),
//                                   20.width,
//                                   Expanded(
//                                     child: CustomTextformField(
//                                       labelText: AppString.quantity,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(r'^\d*\.?\d*')),
//                                       ],
//                                       keyboardType:
//                                           TextInputType.numberWithOptions(
//                                               decimal: true),
//                                       controller: inventoryController
//                                           ?.subRecipeQuantityController,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               20.height,
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(30),
//                                           border: Border.all(
//                                               color: ColorTheme.transparent),
//                                         ),
//                                         child: CustomTextformField(
//                                           keyboardType: TextInputType.number,
//                                           labelText: AppString.preparationTime,
//                                           controller: inventoryController
//                                               ?.subRecipePTimeController,
//                                         )),
//                                   ),
//                                   20.width,
//                                   Expanded(
//                                     child: Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(30),
//                                           border: Border.all(
//                                               color: ColorTheme.transparent),
//                                         ),
//                                         child: CustomTextformField(
//                                           keyboardType: TextInputType.number,
//                                           labelText: AppString.serveTime,
//                                           controller: inventoryController
//                                               ?.subRecipeSTimeController,
//                                         )),
//                                   ),
//                                 ],
//                               ),
//                               20.height,
//                               CustomTextformField(
//                                 keyboardType: TextInputType.number,
//                                 controller: inventoryController
//                                     ?.subRecipeSPeopleController,
//                                 labelText: AppString.servePeople,
//                               ).paddingOnly(
//                                   right:
//                                       MediaQuery.of(context).size.width / 2.17),
//                               20.height,
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: CustomTextformField(
//                                       keyboardType: TextInputType.number,
//                                       controller: inventoryController
//                                           ?.subRecipeThresholdQtyController,
//                                       labelText: AppString.thresholdQty,
//                                     ),
//                                   ),
//                                   20.width,
//                                   GetBuilder<ExpenseManagementController>(
//                                     builder: (controller) =>
//                                         CustomDropdownWidget(
//                                       items: expenseController!.getUnitList
//                                           .map((String value) {
//                                         return DropdownMenuItem<String>(
//                                           value: value,
//                                           child: Text(
//                                             value,
//                                             style: TextStyle(
//                                               // fontFamily: AppFonts.montserrat,
//                                               fontSize: 12,
//                                               color: ColorTheme.foodValue,
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       hintText: AppString.thresholdUnit,
//                                       onChanged: (String? newValue) {
//                                         inventoryController
//                                             ?.subRecipeThresholdUnit = newValue;
//                                         inventoryController?.update();
//                                       },
//                                       value: (inventoryController
//                                                   ?.subRecipeThresholdUnit
//                                                   ?.isNotEmpty ??
//                                               false)
//                                           ? inventoryController
//                                               ?.subRecipeThresholdUnit
//                                           : null,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               15.height,
//                               Divider(color: ColorTheme.whiteE4, thickness: 1),
//                               15.height,
//                               Text(
//                                 AppString.ingredientsList,
//                                 style: TextStyle(color: ColorTheme.grey74),
//                               ),
//                               10.height,
//                               ListView.builder(
//                                 shrinkWrap: true,
//                                 physics: NeverScrollableScrollPhysics(),
//                                 itemCount: inventoryController
//                                     ?.subRecipesIngredientsList.length,
//                                 itemBuilder: (context, index) {
//                                   final subRecipes = inventoryController
//                                       ?.subRecipesIngredientsList[index];
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             CustomAutoCompleteWidget(
//                                               customTextEditingController:
//                                                   subRecipes![
//                                                       "ingredientsNameController"],
//                                               hintText: AppString.ingredients,
//                                               list: inventoryController!
//                                                   .recipeIngredientsList
//                                                   .map(
//                                                     (e) => e["stock_title"],
//                                                   )
//                                                   .toList(),
//                                               onSelected: (selection) async {
//                                                 subRecipes[
//                                                         "ingredientsNameController"]
//                                                     .text = selection;
//                                                 final selectedAddon =
//                                                     inventoryController
//                                                         ?.recipeIngredientsList
//                                                         .firstWhere(
//                                                   (inventory) =>
//                                                       inventory["stock_title"]
//                                                           .toString()
//                                                           .toLowerCase() ==
//                                                       selection.toLowerCase(),
//                                                 );
//                                                 final selectedId =
//                                                     selectedAddon?["id"];

//                                                 subRecipes["ingredientsId"] =
//                                                     selectedId;

//                                                 log('subRecipes["ingredientsId"] :${subRecipes["ingredientsId"]}');
//                                                 await inventoryController
//                                                     ?.getUnitInventory(
//                                                         selectedId ?? 0);
//                                                 print(
//                                                     '......${inventoryController?.getUnitInventoryList.first}');

//                                                 subRecipes["unit"] =
//                                                     inventoryController
//                                                         ?.getUnitInventoryList
//                                                         .first;

//                                                 log('recipes["ingredientsId"] :${subRecipes["ingredientsId"]}');
//                                                 inventoryController?.update();
//                                               },
//                                               appToastMessage: AppString
//                                                   .noIngredientsAvailable,
//                                             ),
//                                             20.width,
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Get.to(() =>
//                                                     AddIngredientsScreen());
//                                               },
//                                               child: Icon(
//                                                   Icons.add_circle_outline,
//                                                   size: 34,
//                                                   color: ColorTheme.grey8C),
//                                             ),
//                                           ],
//                                         ),
//                                         20.height,
//                                         Row(
//                                           children: [
//                                             GetBuilder<
//                                                 ExpenseManagementController>(
//                                               builder: (controller) =>
//                                                   CustomDropdownWidget(
//                                                       items: expenseController!
//                                                           .getUnitList
//                                                           .map((String value) {
//                                                         return DropdownMenuItem<
//                                                             String>(
//                                                           value: value,
//                                                           child: Text(
//                                                             value,
//                                                             style: TextStyle(
//                                                               fontFamily:
//                                                                   "Montserrat",
//                                                               // fontFamily: AppFonts
//                                                               //     .montserrat,
//                                                               fontSize: 12,
//                                                               color: ColorTheme
//                                                                   .foodValue,
//                                                             ),
//                                                           ),
//                                                         );
//                                                       }).toList(),
//                                                       hintText: AppString.unit,
//                                                       onChanged:
//                                                           (String? newValue) {
//                                                         subRecipes["unit"] =
//                                                             newValue ?? "";
//                                                         inventoryController
//                                                             ?.update();
//                                                       },
//                                                       value: (subRecipes["unit"]
//                                                                   ?.isNotEmpty ??
//                                                               false)
//                                                           ? subRecipes["unit"]
//                                                           : null),
//                                             ),

//                                             20.width,
//                                             Expanded(
//                                               child: CustomTextformField(
//                                                 controller:
//                                                     subRecipes["quantity"],
//                                                 labelText: AppString.quantity,
//                                                 inputFormatters: [
//                                                   FilteringTextInputFormatter
//                                                       .allow(RegExp(
//                                                           r'^\d*\.?\d*')),
//                                                 ],
//                                                 keyboardType: TextInputType
//                                                     .numberWithOptions(
//                                                         decimal: true),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         15.height,
//                                         GestureDetector(
//                                           onTap: () {
//                                             inventoryController
//                                                 ?.removeSubRecipesIngredientsData(
//                                                     index);
//                                           },
//                                           child: Align(
//                                             alignment: Alignment.bottomRight,
//                                             child: SvgPicture.asset(
//                                               Images.deleteIcon,
//                                               height: 20,
//                                               color: ColorTheme.red,
//                                             ),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),

//                               20.height,
//                               GestureDetector(
//                                 onTap: () => inventoryController
//                                     ?.addSubRecipesIngredientsData(),
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(Images.add_icon,
//                                         color: ColorTheme.grey, height: 18),
//                                     8.width,
//                                     Text(AppString.addIngredients,
//                                         style: TextStyle(
//                                             color: ColorTheme.greenColor,
//                                             fontSize: 13)),
//                                   ],
//                                 ),
//                               ),
//                               20.height
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       inventoryController?.clearSubRecipesData();
//                       setState(() {});
//                     },
//                     child: Container(
//                       height: 50,
//                       color: ColorTheme.greyColor.withOpacity(0.2),
//                       alignment: Alignment.center,
//                       child: Text(AppString.Reset),
//                     ),
//                   ),
//                 ),
//                 Obx(
//                   () => Expanded(
//                     child: GestureDetector(
//                       onTap:
//                           inventoryController!.isAddSubRecipesSubmitting.value
//                               ? null
//                               : () async {
//                                   if (widget.isEdit) {
//                                     await inventoryController?.updateSubRecipe(
//                                         widget.subRecipes["recipe_id"]);
//                                   } else {
//                                     inventoryController?.addSubRecipe();
//                                   }
//                                 },
//                       child: Container(
//                         height: 50,
//                         color: ColorTheme.greenColor,
//                         alignment: Alignment.center,
//                         child: inventoryController!.addSubRecipesLoader.value
//                             ? AppLoader()
//                             : Text(AppString.submit,
//                                 style: TextStyle(
//                                     color: ColorTheme.whiteColor,
//                                     fontWeight: FontWeight.w800)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart'
    show AppString;
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/delete_recipe_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/custom_auto_complete.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../util/images.dart';
import 'add_Ingredients_screen.dart';

class SubRecipeScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic> subRecipes;

  const SubRecipeScreen(
      {Key? key, this.isEdit = false, required this.subRecipes})
      : super(key: key);

  @override
  State<SubRecipeScreen> createState() => _SubRecipeScreenState();
}

class _SubRecipeScreenState extends State<SubRecipeScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    // inventoryController?.clearSubRecipesData();
    apicalling();
    super.initState();
  }

  apicalling() async {
    await expenseController?.getUnit();
    if (widget.isEdit) {
      inventoryController?.showSubRecipesData(widget.subRecipes);
      // Fetch units for each ingredient in edit mode
      for (int i = 0;
          i < inventoryController!.subRecipesIngredientsList.length;
          i++) {
        final sub = inventoryController!.subRecipesIngredientsList[i];
        if (sub["ingredientsId"] != null &&
            sub["ingredientsId"] is int &&
            (sub["ingredientsId"] as int) > 0) {
          await inventoryController!
              .getUnitInventory(sub["ingredientsId"] as int);
          sub["unitList"] = inventoryController!.getUnitInventoryList
              .cast<String>()
              .toSet()
              .toList();
          // If current unit is not in the list, set to first
          final unitList = sub["unitList"] as List<String>;
          if (unitList.isNotEmpty && !unitList.contains(sub["unit"])) {
            sub["unit"] = unitList.first;
          }
        }
      }
    } else {
      inventoryController?.clearSubRecipesData();
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
              widget.isEdit ? 'Edit Sub-Recipe' : AppString.addSubRecipes,
          actions: [
            widget.isEdit
                ? MyCustomButton(
                    text: AppString.delete,
                    color: ColorTheme.grey8C,
                    width: 150,
                    onTap: () async {
                      deleteRecipesSheet(
                        context,
                        recipeText: widget.subRecipes["food_name"],
                        onDeleteTap: () async {
                          await inventoryController?.deleteSubRecipe(
                              widget.subRecipes["recipe_id"],
                              deleteInside: true);
                        },
                        inventoryController: inventoryController!,
                      );
                    },
                  ).paddingSymmetric(vertical: 8, horizontal: 10)
                : uploadIconWidget(
                    onDownLoadTap: () async {
                      Get.to(() => BulkImportScreen(
                            tittleName: 'Sub Recipes',
                            controller: Get.find<InventoryController>(),
                            isFunction: true,
                            onDownloadSampleDataTap: () {
                              inventoryController?.exportSubRecipeSample();
                            },
                            onDownloadExistingDataTap: () {
                              inventoryController?.exportSubRecipes();
                            },
                            onuploadTap: () {
                              inventoryController?.importSubRecipes();
                            },
                          ));
                    },
                    onUploadTap: () async {
                      // await inventoryController?.importSubRecipes();
                      Get.to(() => BulkImportScreen(
                            tittleName: 'Sub Recipes',
                            controller: Get.find<InventoryController>(),
                            isFunction: true,
                            onDownloadSampleDataTap: () {
                              inventoryController?.exportSubRecipeSample();
                            },
                            onDownloadExistingDataTap: () {
                              inventoryController?.exportSubRecipes();
                            },
                            onuploadTap: () {
                              inventoryController?.importSubRecipes();
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
                      Container(
                        color: ColorTheme.whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextformField(
                                labelText: AppString.name,
                                controller: inventoryController
                                    ?.subRecipeNameController,
                                keyboardType: TextInputType.visiblePassword,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'.*')),
                                ],
                              ),
                              20.height,
                              Row(
                                children: [
                                  GetBuilder<ExpenseManagementController>(
                                    builder: (controller) =>
                                        CustomDropdownWidget(
                                      items: expenseController!.getUnitList
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              // fontFamily: AppFonts.montserrat,
                                              fontSize: 12,
                                              color: ColorTheme.foodValue,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      hintText: AppString.unit,
                                      onChanged: (String? newValue) {
                                        inventoryController?.subRecipeUnit =
                                            newValue ?? "";
                                        inventoryController?.update();
                                      },
                                      value: (inventoryController
                                                  ?.subRecipeUnit?.isNotEmpty ??
                                              false)
                                          ? inventoryController?.subRecipeUnit
                                          : null,
                                    ),
                                  ),
                                  20.width,
                                  Expanded(
                                    child: CustomTextformField(
                                      readOnly: widget.isEdit ? true : false,
                                      fillColor: widget.isEdit == true
                                          ? ColorTheme.whiteF0F0F0
                                          : ColorTheme.whiteColor,
                                      labelText: AppString.quantity,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      controller: inventoryController
                                          ?.subRecipeQuantityController,
                                    ),
                                  ),
                                ],
                              ),
                              20.height,
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: Container(
                              //           decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(30),
                              //             border: Border.all(
                              //                 color: ColorTheme.transparent),
                              //           ),
                              //           child: CustomTextformField(
                              //             keyboardType: TextInputType.number,
                              //             labelText: AppString.preparationTime,
                              //             controller: inventoryController
                              //                 ?.subRecipePTimeController,
                              //           )),
                              //     ),
                              //     20.width,
                              //     Expanded(
                              //       child: Container(
                              //           decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(30),
                              //             border: Border.all(
                              //                 color: ColorTheme.transparent),
                              //           ),
                              //           child: CustomTextformField(
                              //             keyboardType: TextInputType.number,
                              //             labelText: AppString.serveTime,
                              //             controller: inventoryController
                              //                 ?.subRecipeSTimeController,
                              //           )),
                              //     ),
                              //   ],
                              // ),
                              // 20.height,
                              // CustomTextformField(
                              //   keyboardType: TextInputType.number,
                              //   controller: inventoryController
                              //       ?.subRecipeSPeopleController,
                              //   labelText: AppString.servePeople,
                              // ).paddingOnly(
                              //     right:
                              //         MediaQuery.of(context).size.width / 2.17),
                              // 20.height,
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextformField(
                                      keyboardType: TextInputType.number,
                                      controller: inventoryController
                                          ?.subRecipeThresholdQtyController,
                                      labelText: AppString.thresholdQty,
                                    ),
                                  ),
                                  20.width,
                                  GetBuilder<ExpenseManagementController>(
                                    builder: (controller) =>
                                        CustomDropdownWidget(
                                      items: expenseController!.getUnitList
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              // fontFamily: AppFonts.montserrat,
                                              fontSize: 12,
                                              color: ColorTheme.foodValue,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      hintText: AppString.thresholdUnit,
                                      onChanged: (String? newValue) {
                                        inventoryController
                                            ?.subRecipeThresholdUnit = newValue;
                                        inventoryController?.update();
                                      },
                                      value: (inventoryController
                                                  ?.subRecipeThresholdUnit
                                                  ?.isNotEmpty ??
                                              false)
                                          ? inventoryController
                                              ?.subRecipeThresholdUnit
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              15.height,
                              Divider(color: ColorTheme.whiteE4, thickness: 1),
                              15.height,
                              Text(
                                AppString.ingredientsList,
                                style: TextStyle(color: ColorTheme.grey74),
                              ),
                              10.height,
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: inventoryController
                                    ?.subRecipesIngredientsList.length,
                                itemBuilder: (context, index) {
                                  final subRecipes = inventoryController
                                      ?.subRecipesIngredientsList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomAutoCompleteWidget(
                                              customTextEditingController:
                                                  subRecipes![
                                                      "ingredientsNameController"],
                                              hintText: AppString.ingredients,
                                              list: inventoryController!
                                                  .recipeIngredientsList
                                                  .map(
                                                    (e) => e["stock_title"],
                                                  )
                                                  .toList(),
                                              onSelected: (selection) async {
                                                subRecipes[
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

                                                subRecipes["ingredientsId"] =
                                                    selectedId;

                                                log('subRecipes["ingredientsId"] :${subRecipes["ingredientsId"]}');
                                                await inventoryController
                                                    ?.getUnitInventory(
                                                        selectedId ?? 0);
                                                print(
                                                    '......${inventoryController?.getUnitInventoryList.first}');

                                                subRecipes["unitList"] =
                                                    (inventoryController
                                                                ?.getUnitInventoryList ??
                                                            [])
                                                        .cast<String>()
                                                        .toSet()
                                                        .toList();

                                                subRecipes["unit"] =
                                                    subRecipes["unitList"]
                                                            .isNotEmpty
                                                        ? subRecipes["unitList"]
                                                            .first
                                                        : "";

                                                log('subRecipes["ingredientsId"] :${subRecipes["ingredientsId"]}');
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
                                                    subRecipes["unitList"]
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
                                                            // fontFamily: AppFonts
                                                            //     .montserrat,
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
                                                      subRecipes["unit"] =
                                                          newValue ?? "";
                                                      inventoryController
                                                          ?.update();
                                                    },
                                                    value: (subRecipes["unit"]
                                                                ?.isNotEmpty ??
                                                            false)
                                                        ? subRecipes["unit"]
                                                        : null);
                                              },
                                            ),
                                            20.width,
                                            Expanded(
                                              child: CustomTextformField(
                                                controller:
                                                    subRecipes["quantity"],
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
                                                ?.removeSubRecipesIngredientsData(
                                                    index);
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
                              GestureDetector(
                                onTap: () => inventoryController
                                    ?.addSubRecipesIngredientsData(),
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
                      inventoryController?.clearSubRecipesData();
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
                      onTap: inventoryController!
                              .isAddSubRecipesSubmitting.value
                          ? null
                          : () async {
                              List<String> missingFields = [];

                              if (inventoryController!
                                  .subRecipeNameController.text.isEmpty) {
                                missingFields.add('Sub-Recipe Name');
                              }

                              if (inventoryController!.subRecipeUnit?.isEmpty ??
                                  true) {
                                missingFields.add('Sub-Recipe Unit');
                              }

                              // if (inventoryController!
                              //     .subRecipeThresholdQtyController
                              //     .text
                              //     .isEmpty) {
                              //   missingFields.add('Threshold Quantity');
                              // }

                              // if (inventoryController!
                              //         .subRecipeThresholdUnit?.isEmpty ??
                              //     true) {
                              //   missingFields.add('Threshold Unit');
                              // }

                              // Check first ingredient (mandatory)
                              if (inventoryController!
                                  .subRecipesIngredientsList.isNotEmpty) {
                                final firstIngredient = inventoryController!
                                    .subRecipesIngredientsList[0];
                                final firstName =
                                    firstIngredient["ingredientsNameController"]
                                            ?.text ??
                                        '';
                                final firstUnit = firstIngredient["unit"] ?? '';
                                final firstQty =
                                    firstIngredient["quantity"]?.text ?? '';

                                if (firstName.isEmpty) {
                                  missingFields.add('Ingredient Name');
                                }
                                if (firstUnit.isEmpty) {
                                  missingFields.add('Ingredient Unit');
                                }
                                if (firstQty.isEmpty) {
                                  missingFields.add('Ingredient Quantity');
                                }
                              }

                              // Show missing fields snackbar (basic fields + first ingredient)
                              if (missingFields.isNotEmpty) {
                                Get.snackbar(
                                  'Please Check Again!',
                                  'Missing: ${missingFields.join(', ')}',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              // Check additional ingredients (2nd onwards)
                              bool hasEmptyAdditionalIngredient = false;

                              for (int i = 1;
                                  i <
                                      inventoryController!
                                          .subRecipesIngredientsList.length;
                                  i++) {
                                final ingredient = inventoryController!
                                    .subRecipesIngredientsList[i];
                                final name =
                                    ingredient["ingredientsNameController"]
                                            ?.text ??
                                        '';
                                final unit = ingredient["unit"] ?? '';
                                final qty = ingredient["quantity"]?.text ?? '';

                                final isNameFilled = name.isNotEmpty;
                                final isUnitFilled = unit.isNotEmpty;
                                final isQtyFilled = qty.isNotEmpty;

                                final totalFilled = [
                                  isNameFilled,
                                  isUnitFilled,
                                  isQtyFilled
                                ].where((b) => b).length;

                                // If any additional ingredient row is partially or completely empty
                                if (totalFilled < 3) {
                                  hasEmptyAdditionalIngredient = true;
                                  break;
                                }
                              }

                              // Show error for empty additional ingredient rows
                              if (hasEmptyAdditionalIngredient) {
                                Get.snackbar(
                                  'Please Check Again!',
                                  'Please remove empty ingredient fields or fill them completely.',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              if (widget.isEdit) {
                                await inventoryController?.updateSubRecipe(
                                    widget.subRecipes["recipe_id"]);
                              } else {
                                inventoryController?.addSubRecipe();
                              }
                            },
                      child: Container(
                        height: 50,
                        color: ColorTheme.greenColor,
                        alignment: Alignment.center,
                        child: inventoryController!.addSubRecipesLoader.value
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
