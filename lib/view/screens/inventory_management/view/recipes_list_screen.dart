import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart'
    show AppString;
import 'package:mygenie_restaurant/admin/constant/app_style.dart' show AppStyle;
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/delete_recipe_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_edit_addon_recipe.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/sub_recipe_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controller/inventory_controller.dart';
import 'add_edit_recipe_screen.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({Key? key}) : super(key: key);

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;
  MenuManagementController? menuController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    menuController = Get.find<MenuManagementController>();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        recipesCall();
      },
    );
    super.initState();
  }

  recipesCall() async {
    inventoryController?.selectedRecipeType = null;

    inventoryController?.recipesCategory = null;
    inventoryController?.recipesFilterValue = null;
    inventoryController?.recipesSearchController.clear();
    inventoryController?.getAllRecipesAndSubRecipes();
    // await inventoryController?.getRecipeList();
    // await inventoryController?.getAllRecipeList();
    await inventoryController?.getRecipesIngredients();
    await menuController?.productCategories();
    // await menuController?.getMenuFoodList();
    await menuController?.fetchFoodFilter();
    await expenseController?.getUnit();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleText: AppString.recipesList,
          // actions: [
          //   uploadIconWidget(
          //     // onDownLoadTap: () async {
          //     //   await inventoryController?.exportRecipe();
          //     // },
          //     // onUploadTap: () async {
          //     //   await inventoryController?.importRecipe();
          //     // },
          //     isUpNotShow: false,
          //     isDownNotShow: false,
          //     isPLusShow: true,
          //     onPlusTap: () {
          //       Get.to(() => AddEditRecipeScreen(recipes: {}));
          //       FocusManager.instance.primaryFocus?.unfocus();
          //     },
          //   ),
          // ],
        ),
        body: Column(
          children: [
            Divider(color: ColorTheme.grey8C.withOpacity(.5), height: 1),
            GetBuilder<InventoryController>(
              builder: (controller) => Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        menuWidth: 180,
                        alignment: Alignment.center,
                        underline: SizedBox.shrink(),
                        hint: Text(
                          AppString.allRecipes,
                          style: AppStyle.tx18mediumRed.copyWith(fontSize: 13),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: ColorTheme.whiteColor,
                        style: TextStyle(color: Colors.red),
                        icon: Icon(Icons.keyboard_arrow_down_outlined,
                            size: 15, color: ColorTheme.grey8C),
                        isDense: true,
                        value: inventoryController?.recipesFilterValue != null
                            ? inventoryController?.recipesFilterValue
                            : null,
                        iconEnabledColor: ColorTheme.transparent,
                        onChanged: (newValue) async {
                          await inventoryController
                              ?.onChangeRecipesFilter(newValue ?? "");
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(
                              AppString.allRecipes,
                              style: TextStyle(
                                  color: ColorTheme.foodValue,
                                  fontFamily: "Montserrat"),
                            ),
                          ),
                          ...inventoryController!.getRecipeAllList
                              .map<DropdownMenuItem<String>>(
                            (Recipes) {
                              String recipesName =
                                  Recipes['food_name'] ?? 'Unnamed Recipes';
                              return DropdownMenuItem<String>(
                                value: recipesName,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    recipesName,
                                    style: TextStyle(
                                      fontFamily: "Montserrat",
                                      color: ColorTheme.foodValue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                  5.width,
                  Container(width: 0.5, height: 40, color: ColorTheme.grey8C),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        alignment: Alignment.center,
                        underline: SizedBox.shrink(),
                        hint: inventoryController?.selectedRecipeType == null
                            ? Text(
                                'Recipe Type',
                                style: AppStyle.tx18mediumRed
                                    .copyWith(fontSize: 13),
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: ColorTheme.whiteColor,
                        value: inventoryController?.selectedRecipeType,
                        style: TextStyle(color: Colors.red),
                        icon: Icon(Icons.keyboard_arrow_down_outlined,
                            size: 15, color: ColorTheme.grey8C),
                        isDense: true,
                        iconEnabledColor: ColorTheme.transparent,
                        onChanged: (newValue) async {
                          await inventoryController
                              ?.onChangedRecipeCategory(newValue ?? "");
                        },
                        items: inventoryController!.recipeType
                            .map<DropdownMenuItem<String>>(
                          (recipeType) {
                            return DropdownMenuItem<String>(
                              value: recipeType,
                              child: Text(
                                recipeType,
                                style: AppStyle.tx18mediumRed
                                    .copyWith(fontSize: 13),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: ColorTheme.grey.withOpacity(.5), height: 1),
            20.height,
            Column(
              children: [
                GetBuilder<InventoryController>(builder: (controller) {
                  return CustomSearchField(
                    onChanged: (p0) {
                      inventoryController?.update();
                    },
                    controller: inventoryController!.recipesSearchController,
                    hitText: 'Search By Recipes / Sub-Recipes',
                  );
                }),
                20.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: MyCustomButton(
                      text: 'Add Recipe',
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: ColorTheme.whiteColor),
                      horizontal: 5,
                      onTap: () {
                        Get.to(() => AddEditRecipeScreen(
                              recipes: {},
                            ));
                      },
                    )),
                    10.width,
                    Expanded(
                        child: MyCustomButton(
                      text: 'Add Sub-Recipe',
                      horizontal: 5,
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: ColorTheme.whiteColor),
                      onTap: () {
                        Get.to(() => SubRecipeScreen(
                              subRecipes: {},
                              isEdit: false,
                            ));
                      },
                    )),
                    10.width,
                    Expanded(
                        child: MyCustomButton(
                      text: "Add Addon-Recipe",
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: ColorTheme.whiteColor),
                      horizontal: 5,
                      onTap: () {
                        Get.to(() => AddEditAddonRecipeScreen(
                              recipes: {},
                              isEdit: false,
                            ));
                      },
                    )),
                  ],
                ),
              ],
            ).paddingSymmetric(horizontal: 20),
            20.height,
            GetBuilder<InventoryController>(builder: (controller) {
              return Container(
                height: 40,
                decoration: BoxDecoration(
                  color: ColorTheme.whiteColor,
                  border: Border(bottom: BorderSide(color: ColorTheme.whiteE7)),
                ),
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          15.width,
                          Text(AppString.name, style: AppStyle.tx18mediumRed),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(color: ColorTheme.whiteE7))),
                      child: Text(AppString.reqTime,
                          style: AppStyle.tx18mediumRed),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                        left: BorderSide(color: ColorTheme.whiteE7),
                      )),
                      child: Text(AppString.quantity,
                          style: AppStyle.tx18mediumRed),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(color: ColorTheme.whiteE7))),
                      child:
                          Text(AppString.action, style: AppStyle.tx18mediumRed),
                    ),
                  ),
                ]),
              );
            }),
            Expanded(child: GetBuilder<InventoryController>(
              builder: (controller) {
                var filteredRecipesList =
                    inventoryController?.recipeList.where((element) {
                  return element["food_name"].toString().toLowerCase().contains(
                      inventoryController!.recipesSearchController.text
                          .toLowerCase());
                }).toList();
                return inventoryController!.getRecipesLoader
                    ? AppLoader()
                    : filteredRecipesList!.isNotEmpty
                        ? Container(
                            color: ColorTheme.whiteColor,
                            child: ListView.builder(
                              itemCount: filteredRecipesList.length ?? 0,
                              itemBuilder: (context, index) {
                                final recipes = filteredRecipesList[index];
                                return IntrinsicHeight(
                                  child: Container(
                                    // height: 85,
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: ColorTheme.whiteE7)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Container(
                                                    //   width: 15,
                                                    //   height: 15,
                                                    //   decoration: BoxDecoration(
                                                    //       color: inventoryController
                                                    //                   ?.selectedRecipeType ==
                                                    //               'Recipe'
                                                    //           ? ColorTheme
                                                    //               .blackColor
                                                    //           : ColorTheme.blue,
                                                    //       shape:
                                                    //           BoxShape.circle),
                                                    //   alignment:
                                                    //       Alignment.center,
                                                    //   child: Text(
                                                    //     inventoryController
                                                    //                 ?.selectedRecipeType ==
                                                    //             'Recipe'
                                                    //         ? "R"
                                                    //         : "SR",
                                                    //     style: TextStyle(
                                                    //         fontWeight:
                                                    //             FontWeight.bold,
                                                    //         color: ColorTheme
                                                    //             .whiteColor,
                                                    //         fontSize: 8),
                                                    //   ),
                                                    // ).paddingOnly(top: 2),

                                                    Container(
                                                      width: 15,
                                                      height: 15,
                                                      decoration: BoxDecoration(
                                                          color: recipes[
                                                                      'type'] ==
                                                                  'sub_recipe'
                                                              ? ColorTheme.blue
                                                              : recipes['type'] ==
                                                                      'addon_recipe'
                                                                  ? ColorTheme
                                                                      .green
                                                                  : ColorTheme
                                                                      .blackColor,
                                                          shape:
                                                              BoxShape.circle),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        recipes['type'] ==
                                                                'sub_recipe'
                                                            ? "SR"
                                                            : recipes['type'] ==
                                                                    'addon_recipe'
                                                                ? "AR"
                                                                : "R",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: ColorTheme
                                                                .whiteColor,
                                                            fontSize: 8),
                                                      ),
                                                    ).paddingOnly(top: 2),

                                                    5.width,
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            recipes["food_name"]
                                                                .toString(),

                                                            softWrap: true,

                                                            // maxLines: 2,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontSize: 14,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                          ),
                                                          5.height,
                                                          Container(
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxWidth: double
                                                                        .infinity),
                                                            child: Text(
                                                              recipes["category_name"] ??
                                                                  '',
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Montserrat",
                                                                fontSize: 12,
                                                                color: ColorTheme
                                                                    .foodValue,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ).paddingOnly(left: 15),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 7),
                                              child: Center(
                                                child: recipes['type'] !=
                                                        'sub_recipe'
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .accessibility_new_rounded,
                                                                color: ColorTheme
                                                                    .blue0090FF,
                                                                size: 16,
                                                              ),
                                                              3.width,
                                                              Flexible(
                                                                child: Text(
                                                                  "${recipes["preparation_time"]} Min.",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontSize:
                                                                        12,
                                                                    color: ColorTheme
                                                                        .foodValue,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.alarm,
                                                                size: 16,
                                                                color: ColorTheme
                                                                    .blue0090FF,
                                                              ),
                                                              const SizedBox(
                                                                  width: 3),
                                                              Flexible(
                                                                child: Text(
                                                                  "${recipes["serve_time"]} Min.",
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontSize:
                                                                        12,
                                                                    color: ColorTheme
                                                                        .foodValue,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    : SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border(
                                              left: BorderSide(
                                                  color: ColorTheme.whiteE7),
                                            )),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${recipes["qty"]} ${recipes["unit"]}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 12,
                                                    color: ColorTheme.foodValue,
                                                  ),
                                                ),
                                                recipes['type'] == 'sub_recipe'
                                                    ? SizedBox.shrink()
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons
                                                              .person_outlined),
                                                          Text(
                                                            recipes["serve_people"]
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontSize: 12,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: Container(
                                        //     decoration: BoxDecoration(
                                        //       border: Border.symmetric(
                                        //           vertical: BorderSide(
                                        //               color:
                                        //                   ColorTheme.whiteE7)),
                                        //     ),
                                        //     height: double.infinity,
                                        //     alignment: Alignment.center,
                                        //     child: Row(
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.spaceEvenly,
                                        //       children: [
                                        //         GestureDetector(
                                        //           onTap: () {
                                        //             inventoryController
                                        //                         ?.selectedRecipeType ==
                                        //                     'Recipe'
                                        //                 ? Get.to(() =>
                                        //                     AddEditRecipeScreen(
                                        //                         isEdit: true,
                                        //                         recipes:
                                        //                             recipes))
                                        //                 : Get.to(() =>
                                        //                     SubRecipeScreen(
                                        //                         isEdit: true,
                                        //                         subRecipes:
                                        //                             recipes));
                                        //           },
                                        //           child: Container(
                                        //             height: 20,
                                        //             width: 20,
                                        //             child: SvgPicture.asset(
                                        //                 Images.Edit,
                                        //                 width: 20.7),
                                        //           ),
                                        //         ),
                                        //         GestureDetector(
                                        //           onTap: () {
                                        //             inventoryController
                                        //                         ?.selectedRecipeType ==
                                        //                     'Recipe'
                                        //                 ? deleteRecipesSheet(
                                        //                     context,
                                        //                     recipeText: recipes[
                                        //                         "food_name"],
                                        //                     onDeleteTap:
                                        //                         () async {
                                        //                       await inventoryController
                                        //                           ?.deleteRecipe(
                                        //                               recipes[
                                        //                                   "recipe_id"]);
                                        //                     },
                                        //                     inventoryController:
                                        //                         inventoryController!,
                                        //                   )
                                        //                 : deleteRecipesSheet(
                                        //                     context,
                                        //                     recipeText: recipes[
                                        //                         "food_name"],
                                        //                     onDeleteTap:
                                        //                         () async {
                                        //                       await inventoryController
                                        //                           ?.deleteSubRecipe(
                                        //                               recipes[
                                        //                                   "recipe_id"]);
                                        //                     },
                                        //                     inventoryController:
                                        //                         inventoryController!,
                                        //                   );
                                        //           },
                                        //           child: Container(
                                        //             height: 20,
                                        //             width: 20,
                                        //             child: SvgPicture.asset(
                                        //               Images.deleteIcon,
                                        //               width: 20.7,
                                        //               color:
                                        //                   ColorTheme.greenColor,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),

                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7),
                                              ),
                                            ),
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // EDIT BUTTON
                                                GestureDetector(
                                                  onTap: () {
                                                    // Check the 'type' field to determine if it's a recipe or sub-recipe
                                                    if (recipes['type'] ==
                                                        'recipe') {
                                                      // For Recipe: Navigate to Recipe Edit Screen
                                                      Get.to(() =>
                                                          AddEditRecipeScreen(
                                                            isEdit: true,
                                                            recipes: recipes,
                                                          ));
                                                    } else if (recipes[
                                                            'type'] ==
                                                        'sub_recipe') {
                                                      // For Sub-Recipe: Navigate to Sub-Recipe Edit Screen
                                                      Get.to(() =>
                                                          SubRecipeScreen(
                                                            isEdit: true,
                                                            subRecipes: recipes,
                                                          ));
                                                    } else if (recipes[
                                                            'type'] ==
                                                        'addon_recipe') {
                                                      Get.to(() =>
                                                          AddEditAddonRecipeScreen(
                                                            isEdit: true,
                                                            recipes: recipes,
                                                          ));
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: SvgPicture.asset(
                                                      Images.Edit,
                                                      width: 20.7,
                                                    ),
                                                  ),
                                                ),

                                                // DELETE BUTTON
                                                GestureDetector(
                                                  onTap: () {
                                                    // Check the 'type' field to determine which delete API to call
                                                    if (recipes['type'] ==
                                                        'recipe') {
                                                      // For Recipe: Call Recipe Delete API
                                                      deleteRecipesSheet(
                                                        context,
                                                        recipeText: recipes[
                                                            "food_name"],
                                                        onDeleteTap: () async {
                                                          await inventoryController
                                                              ?.deleteRecipe(
                                                            recipes[
                                                                "recipe_id"],
                                                          );
                                                        },
                                                        inventoryController:
                                                            inventoryController!,
                                                      );
                                                    } else if (recipes[
                                                            'type'] ==
                                                        'sub_recipe') {
                                                      // For Sub-Recipe: Call Sub-Recipe Delete API
                                                      deleteRecipesSheet(
                                                        context,
                                                        recipeText:
                                                            recipes["name"],
                                                        onDeleteTap: () async {
                                                          await inventoryController
                                                              ?.deleteSubRecipe(
                                                            recipes[
                                                                "recipe_id"],
                                                          );
                                                        },
                                                        inventoryController:
                                                            inventoryController!,
                                                      );
                                                    } else if (recipes[
                                                            'type'] ==
                                                        'addon_recipe') {
                                                      deleteRecipesSheet(
                                                        context,
                                                        recipeText:
                                                            recipes["name"],
                                                        onDeleteTap: () async {
                                                          await inventoryController
                                                              ?.deleteAddonRecipe(
                                                            recipes[
                                                                "recipe_id"],
                                                          );
                                                        },
                                                        inventoryController:
                                                            inventoryController!,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: SvgPicture.asset(
                                                      Images.deleteIcon,
                                                      width: 20.7,
                                                      color:
                                                          ColorTheme.greenColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(child: Text(AppString.noDataFound));
                ;
              },
            ))
          ],
        ),
      ),
    );
  }
}
