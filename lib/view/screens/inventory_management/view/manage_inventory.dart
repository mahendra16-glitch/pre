import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/get_storage/get_storage.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_edit_recipe_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/delete_food_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/quick_edit_food_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/add_edit_menu/add_edit_menu_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../employee_management/employee_home_screen.dart';

class ManageInventory extends StatefulWidget {
  @override
  State<ManageInventory> createState() => _ManageInventoryState();
}

class _ManageInventoryState extends State<ManageInventory> {
  MenuManagementController? menuController;
  ExpenseManagementController? expenseController;
  InventoryController? inventoryController;
  AuthController? authController;

  @override
  void initState() {
    menuController = Get.find<MenuManagementController>();
    expenseController = Get.find<ExpenseManagementController>();
    inventoryController = Get.find<InventoryController>();
    // authController = Get.find<AuthController>();
    inventoryController?.resetFilter();
    menuApiCalling();
    super.initState();
  }

  menuApiCalling() async {
    Future.delayed(Duration.zero, () async {
      await inventoryController?.getInventroyFoodList();
      await inventoryController?.getRecipesIngredients();
    });
  }

  GetStoragePref getStoragePref = GetStoragePref();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.whiteColor,
          elevation: 0,
          // leading: IconButton(
          //   icon: Icon(Icons.menu, color: ColorTheme.appColor),
          //   onPressed: () {
          //     scaffoldKey.currentState?.openDrawer();
          //   },
          // ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.appColor,
            ),
            onPressed: () {
              Get.back();
            },
          ),

          titleSpacing: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Manage Inventory',
            style:
                poppinsMedium.copyWith(fontSize: 16, color: ColorTheme.black2E),
          ),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () async {
                  // inventoryController?.resetFilter();
                  // await inventoryController?.getInventroyFoodList();
                  // await inventoryController?.getRecipesIngredients();
                  inventoryController?.saveScroll();
                  inventoryController?.resetFilter();
                  await inventoryController?.getInventroyFoodList();
                  await inventoryController?.getRecipesIngredients();
                  inventoryController?.restoreScroll();
                },
                icon: Icon(
                  Icons.refresh,
                  color: ColorTheme.greyCACACA,
                  size: 35,
                ))
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: Row(
                children: [
                  //Search Field
                  Expanded(
                    flex: 7,
                    child: CustomSearchField(
                      onChanged: (p0) {
                        inventoryController?.update();
                      },
                      controller:
                          inventoryController!.inventorySearchController,
                      hitText: "Search",
                    ),
                  ),
                  // VerticalDivider(
                  //   color: ColorTheme.white,
                  //   width: 20,
                  //   thickness: 1.5,
                  //   endIndent: 15,
                  //   indent: 15,
                  // ),
                  10.width,

                  //Active and inactive filter
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: ColorTheme.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(
                        //     color: ColorTheme.greyCACACA.withOpacity(0.3)),
                      ),
                      child: Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButtonFormField2<String>(
                            isExpanded: true,
                            style: montserratMedium.copyWith(
                                overflow: TextOverflow.ellipsis,
                                color: ColorTheme.grey8C,
                                fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        ColorTheme.greyCACACA.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: ColorTheme.greyCACACA),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        ColorTheme.greyCACACA.withOpacity(0.3)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        ColorTheme.greyCACACA.withOpacity(0.3)),
                              ),
                            ),
                            value: inventoryController?.selectedFilter.value,
                            items: inventoryController?.filterOptions
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: montserratMedium.copyWith(
                                          color: ColorTheme.grey8C,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                inventoryController?.selectedFilter.value =
                                    value;
                                inventoryController?.update();
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            iconStyleData: IconStyleData(
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              iconEnabledColor: ColorTheme.grey8C,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorTheme.greyCACACA.withOpacity(0.3),
                                ),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: ColorTheme.whiteE7,
            ),
            Container(
              height: 40,
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        15.width,
                        Text(AppString.items, style: AppStyle.tx18mediumRed),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    // width: 20.w,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child:
                        Text(AppString.status, style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    // width: 25.w,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Recipe', style: AppStyle.tx18mediumRed),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: GetBuilder<InventoryController>(
                builder: (controller) {
                  // var filteredInventoryFoodList =
                  //     controller.inventroyFoodList.where((element) {
                  //   return element["name"].toString().toLowerCase().contains(
                  //       controller.inventorySearchController.text
                  //           .toLowerCase());
                  // }).toList();
                  var filteredInventoryFoodList =
                      controller.inventroyFoodList.where((element) {
                    // Search filter
                    bool matchesSearch = element["name"]
                        .toString()
                        .toLowerCase()
                        .contains(controller.inventorySearchController.text
                            .toLowerCase());

                    // Status filter
                    bool matchesStatus = true;
                    if (controller.selectedFilter.value == 'Active') {
                      matchesStatus =
                          element['is_inventory'].toString().toLowerCase() ==
                              'yes';
                    } else if (controller.selectedFilter.value == 'Inactive') {
                      matchesStatus =
                          element['is_inventory'].toString().toLowerCase() ==
                              'no';
                    }

                    return matchesSearch && matchesStatus;
                  }).toList();

                  return (inventoryController?.isFoodLoader ?? false)
                      ? Center(
                          child: Center(
                              child: CircularProgressIndicator(
                          backgroundColor: ColorTheme.whiteColor,
                          color: ColorTheme.greenColor,
                        )))
                      : (filteredInventoryFoodList.isNotEmpty ?? false)
                          ? ListView.builder(
                              controller: inventoryController?.scrollController,
                              itemCount: filteredInventoryFoodList.length,
                              itemBuilder: (context, index) {
                                final food = filteredInventoryFoodList[index];

                                String? restaurantType =
                                    Get.find<AuthController>()
                                        .profileModel
                                        ?.restaurants
                                        ?.first
                                        .resturantType;

                                final hasImage = food['image'] != null &&
                                    food['image'].isNotEmpty;
                                String defaultImage =
                                    '${AppConstants.BASE_URL}/public/assets/admin/img/100x100/food-default-image.png';
                                final imageUrl =
                                    hasImage ? food['image'] : null;

                                return Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: ColorTheme.whiteE7),
                                        bottom: BorderSide(
                                            color: ColorTheme.whiteE7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              10.width,
                                              CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Image.asset(
                                                  food['veg'] == 1
                                                      ? Images.Food_V_img
                                                      : Images.Food_NV_img,
                                                  width: 50,
                                                ),
                                              ),
                                              // CircleAvatar(
                                              //   radius: 25,
                                              //   backgroundColor: imageUrl !=
                                              //           defaultImage
                                              //       ? (food?['item_type'] == 0
                                              //           ? Colors.red
                                              //           : food?['item_type'] ==
                                              //                   1
                                              //               ? Colors.green
                                              //               : ColorTheme.yellow)
                                              //       : ColorTheme.transparent,
                                              //   child: CircleAvatar(
                                              //     radius: 23,
                                              //     backgroundColor:
                                              //         Colors.transparent,
                                              //     backgroundImage: (imageUrl ??
                                              //                     '')
                                              //                 .isNotEmpty &&
                                              //             imageUrl !=
                                              //                 defaultImage
                                              //         ? CachedNetworkImageProvider(
                                              //             imageUrl!)
                                              //         : null,
                                              //     child: ((imageUrl ?? '')
                                              //                 .isNotEmpty &&
                                              //             imageUrl !=
                                              //                 defaultImage)
                                              //         ? null
                                              //         : (food?['item_type'] == 1
                                              //             ? Image.asset(
                                              //                 Images.Food_V_img,
                                              //                 width: 50,
                                              //               )
                                              //             : food?['item_type'] ==
                                              //                     0
                                              //                 ? Image.asset(
                                              //                     Images
                                              //                         .Food_NV_img,
                                              //                     width: 50,
                                              //                   )
                                              //                 : Image.asset(
                                              //                     Images
                                              //                         .Food_V_img,
                                              //                     width: 50,
                                              //                   )),
                                              //   ),
                                              // ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0, top: 0),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          food['name'] ?? "",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontSize: 13.7,
                                                            color: ColorTheme
                                                                .foodValue,
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
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7)),
                                          ),
                                          child: inventoryController!
                                                          .foodSwitchLoader[
                                                      food['id']] ==
                                                  true
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : Transform.scale(
                                                  scale: 0.7,
                                                  child: Switch(
                                                      activeColor:
                                                          ColorTheme.appColor,
                                                      activeTrackColor:
                                                          Colors.transparent,
                                                      inactiveTrackColor:
                                                          Colors.transparent,
                                                      trackOutlineWidth:
                                                          const WidgetStatePropertyAll(
                                                              3),
                                                      thumbColor: food[
                                                                  'is_inventory'] ==
                                                              'Yes'
                                                          ? WidgetStatePropertyAll(
                                                              ColorTheme.red)
                                                          : const WidgetStatePropertyAll(
                                                              Color(
                                                                  0xFFCACACA)),
                                                      inactiveThumbColor:
                                                          const Color(
                                                              0xFFCACACA),
                                                      trackOutlineColor: food[
                                                                  'is_inventory'] ==
                                                              'Yes'
                                                          ? WidgetStatePropertyAll(
                                                              ColorTheme.red)
                                                          : const WidgetStatePropertyAll(
                                                              Color(
                                                                  0xFFCACACA)),
                                                      value:
                                                          food['is_inventory'] ==
                                                                  'Yes'
                                                              ? true
                                                              : false,
                                                      onChanged: (value) {
                                                        final data = {
                                                          "food_id":
                                                              "${food["id"]}",
                                                          "is_inventory": value
                                                              ? "Yes"
                                                              : "No",
                                                        };
                                                        if (food[
                                                                'recipe_status'] ==
                                                            'Yes') {
                                                          inventoryController
                                                              ?.statusInventoryFood(
                                                                  data: data);
                                                        } else {
                                                          Get.snackbar(
                                                            "Alert",
                                                            "Please add recipe for this food item before changing the status.",
                                                            snackPosition:
                                                                SnackPosition
                                                                    .TOP,
                                                            backgroundColor:
                                                                ColorTheme
                                                                    .appColor,
                                                            colorText:
                                                                ColorTheme
                                                                    .white,
                                                          );
                                                        }
                                                      }),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  if (food['recipe_status'] ==
                                                      'Yes') {
                                                    await inventoryController
                                                        ?.getRecipeById(
                                                            id: food['recipe']
                                                                ['id']);
                                                    debugPrint(
                                                        "This recipe is going to edit :${inventoryController?.RecipeByIdDetail}");
                                                    Get.to(() =>
                                                        AddEditRecipeScreen(
                                                          isEdit: true,
                                                          recipes:
                                                              inventoryController
                                                                      ?.RecipeByIdDetail ??
                                                                  {},
                                                        ));
                                                  } else {
                                                    Get.to(() =>
                                                        AddEditRecipeScreen(
                                                          recipes: {},
                                                        ));
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: Icon(
                                                    Icons.restaurant_menu,
                                                    size: 30,
                                                    color:
                                                        food['recipe_status'] ==
                                                                'Yes'
                                                            ? ColorTheme.green
                                                            : Color(0xFFCACACA),
                                                  ),
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
                            )
                          : Center(child: Text(AppString.noDataFound));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
