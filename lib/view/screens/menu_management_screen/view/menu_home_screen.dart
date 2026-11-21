import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/get_storage/get_storage.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
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
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/delete_food_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/quick_edit_food_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/add_edit_menu/add_edit_menu_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/aggregator_stock_status_button.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../employee_management/employee_home_screen.dart';

class MenuHomeScreen extends StatefulWidget {
  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  MenuManagementController? menuController;
  ExpenseManagementController? expenseController;
  InventoryController? inventoryController;
  AuthController? authController;

  @override
  void initState() {
    menuController = Get.find<MenuManagementController>();
    expenseController = Get.find<ExpenseManagementController>();
    inventoryController = Get.find<InventoryController>();
    authController = Get.find<AuthController>();

    menuApiCalling();
    super.initState();
  }

  @override
  void dispose() {
    menuController?.foodScrollController.dispose();
    super.dispose();
  }

  menuApiCalling() async {
    menuController?.catSearchDataReset();
    // menuController?.filterFoodFor = "Default Menu";
    menuController?.filterFoodFor = "Normal";
    await menuController?.fetchMenuMasterLists();
    // Reset selectedClientId on init
    menuController?.selectedClientId.value = null;
    await menuController?.fetchFoodFilter();
    // await menuController?.getCategoryList();
    await menuController?.productCategories();
    await menuController?.getDeleteReasons();
    await menuController?.getStationList();
    // Fetch clients but only show dropdown when filterFoodFor is Aggregator
    await menuController?.fetchRestaurantClients();
  }

  GetStoragePref getStoragePref = GetStoragePref();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorTheme.whiteColor,
        appBar: CustomAppBar(
          leadingValue: true,
          // leadingWidget: Padding(
          //   padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
          //   child: IconButton(
          //     icon: Image.asset(Images.menu,
          //         color: ColorTheme.appColor, height: 16),
          //     onPressed: () {
          //       scaffoldKey.currentState?.openDrawer();
          //     },
          //   ),
          // ),
          leadingWidget: IconButton(
            icon: const Icon(
              Icons.chevron_left_outlined,
              color: Color(0xFFF26B33),
              size: 30,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          // titleWidget: Image.asset(Images.app_logo, width: 32.5),
          titleText: Platform.isWindows ? 'Menu Management' : 'Menu Management',
          actions: [
            Container(
              height: 50,
              width: 150,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: ColorTheme.whiteDC.withOpacity(.6), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    GetBuilder<MenuManagementController>(
                      builder: (controller) => Flexible(
                        child: DropdownButton<String>(
                          dropdownColor: ColorTheme.whiteColor,
                          isExpanded: true,
                          // isDense: true,
                          underline: SizedBox.shrink(),
                          value: (menuController?.filterFoodFor.isNotEmpty ??
                                  false)
                              ? menuController?.filterFoodFor
                              : null,
                          items:
                              // (Get.find<AuthController>()
                              //             .profileModel!
                              //             .role!
                              //             .contains('aggregator')
                              //         ? menuController?.menuFoodForLists:
                              menuController?.menuFoodForList
                                  .map<DropdownMenuItem<String>>(
                                      (dynamic value) {
                            String item = value.toString();

                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontFamily: "Montserrat",
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  color: ColorTheme.foodValue,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            await menuController
                                ?.changeFoodForFilter(value ?? "");
                          },
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          hint: Text(
                            'Normal' ?? "",
                            style: AppStyle.txt14FoodValue.copyWith(
                              fontSize: 12,
                              color: ColorTheme.foodValue.withOpacity(.8),
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.arrow_drop_down_rounded),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ).paddingOnly(right: 15, bottom: 5, top: 5),
            GetBuilder<MenuManagementController>(
              builder: (controller) {
                // Only show dropdown when filterFoodFor is "Aggregator" and clients list is not empty
                if (controller.filterFoodFor != "Aggregator") {
                  return SizedBox.shrink();
                }
                return Obx(() {
                  if (controller.restaurantClientsList.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Container(
                    height: 50,
                    width: 150,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: ColorTheme.whiteDC.withOpacity(.6), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: DropdownButton<int?>(
                              dropdownColor: ColorTheme.whiteColor,
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              value: controller.selectedClientId.value,
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(
                                    "Main Brand",
                                    style: TextStyle(
                                      fontFamily: "Montserrat",
                                      fontSize: 12,
                                      color: ColorTheme.foodValue,
                                    ),
                                  ),
                                ),
                                ...controller.restaurantClientsList
                                    .map<DropdownMenuItem<int?>>((client) {
                                  return DropdownMenuItem<int?>(
                                    value: client['id'] as int?,
                                    child: Text(
                                      client['name'] ?? "",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 12,
                                        color: ColorTheme.foodValue,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) async {
                                controller.selectedClientId.value = value;
                                await controller.fetchFoodList(
                                  category: controller.selectedCategory.value,
                                  isVeg: controller.isVegSwitched.value,
                                  isNoVeg: controller.isNonVegSwitched.value,
                                  isEgg: controller.isEggSwitched.value,
                                  isJain: controller.isJainSwitched.value,
                                  status: controller.selectedStatus.value,
                                );
                              },
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              icon: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(Icons.arrow_drop_down_rounded),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ).paddingOnly(right: 15, bottom: 5, top: 5);
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: ColorTheme.grey200Color,
                border: Border(top: BorderSide(color: ColorTheme.whiteE4)),
              ),
              child: Column(
                children: [
                  // Container(
                  //   height: 55,
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Container(
                  //         alignment: Alignment.center,
                  //         height: double.infinity,
                  //         width: Platform.isWindows
                  //             ? MediaQuery.of(context).size.width * 0.7
                  //             : MediaQuery.of(context).size.width * 0.6,
                  //         child: SingleChildScrollView(
                  //           scrollDirection: Axis.horizontal,
                  //           child: Row(
                  //             // mainAxisSize: MainAxisSize.min,
                  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //             children: [
                  //               Transform.scale(
                  //                 scale: 0.7,
                  //                 child: Obx(() {
                  //                   return Switch(
                  //                     value:
                  //                         menuController!.isVegSwitched.value,
                  //                     onChanged: (value) async {
                  //                       menuController!.isVegSwitched.value =
                  //                           value;

                  //                       await getStoragePref.setValue(
                  //                           "veg", value);

                  //                       await menuController?.fetchFoodList(
                  //                           category: menuController
                  //                               ?.selectedCategory.value,
                  //                           isVeg: menuController
                  //                               ?.isVegSwitched.value,
                  //                           isNoVeg: menuController
                  //                               ?.isNonVegSwitched.value,
                  //                           isEgg: menuController
                  //                               ?.isEggSwitched.value,
                  //                           isJain: menuController
                  //                               ?.isJainSwitched.value);
                  //                     },
                  //                     activeColor: const Color(0xFF18A84A),
                  //                     inactiveThumbColor: ColorTheme.greenColor,
                  //                   );
                  //                 }),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 20,
                  //                 ),
                  //               Text(
                  //                 AppString.veg,
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   fontFamily: "Montserrat",
                  //                   color: ColorTheme.grey8C,
                  //                 ),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 60,
                  //                 ),

                  //               // Non-Veg Switch Row
                  //               Transform.scale(
                  //                 scale: 0.7,
                  //                 child: Obx(() {
                  //                   return Switch(
                  //                     value: menuController!
                  //                         .isNonVegSwitched.value,
                  //                     onChanged: (value) async {
                  //                       menuController?.isNonVegSwitched.value =
                  //                           value;

                  //                       await getStoragePref.setValue(
                  //                           "noVeg", value);

                  //                       await menuController?.fetchFoodList(
                  //                           category: menuController
                  //                               ?.selectedCategory.value,
                  //                           isVeg: menuController
                  //                               ?.isVegSwitched.value,
                  //                           isNoVeg: menuController
                  //                               ?.isNonVegSwitched.value,
                  //                           isEgg: menuController
                  //                               ?.isEggSwitched.value,
                  //                           isJain: menuController
                  //                               ?.isJainSwitched.value);
                  //                     },
                  //                     activeColor: ColorTheme.redF13,
                  //                     inactiveThumbColor: ColorTheme.redF13,
                  //                   );
                  //                 }),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 20,
                  //                 ),

                  //               Text(
                  //                 AppString.nonVeg,
                  //                 style: TextStyle(
                  //                     fontSize: 14,
                  //                     fontFamily: "Montserrat",
                  //                     color: ColorTheme.grey8C),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 60,
                  //                 ),

                  //               //egg switch
                  //               Transform.scale(
                  //                 scale: 0.7,
                  //                 child: Obx(() {
                  //                   return Switch(
                  //                     value:
                  //                         menuController!.isEggSwitched.value,
                  //                     onChanged: (value) async {
                  //                       menuController!.isEggSwitched.value =
                  //                           value;

                  //                       await getStoragePref.setValue(
                  //                           "egg", value);

                  //                       await menuController?.fetchFoodList(
                  //                           category: menuController
                  //                               ?.selectedCategory.value,
                  //                           isVeg: menuController
                  //                               ?.isVegSwitched.value,
                  //                           isNoVeg: menuController
                  //                               ?.isNonVegSwitched.value,
                  //                           isEgg: menuController
                  //                               ?.isEggSwitched.value,
                  //                           isJain: menuController
                  //                               ?.isJainSwitched.value);
                  //                     },
                  //                     activeColor: const Color(0xFFFFB300),
                  //                     inactiveThumbColor: Color(0xFFFFB300),
                  //                   );
                  //                 }),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 20,
                  //                 ),

                  //               Text(
                  //                 "Egg",
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   fontFamily: "Montserrat",
                  //                   color: ColorTheme.grey8C,
                  //                 ),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 60,
                  //                 ),

                  //               // jain switch
                  //               Transform.scale(
                  //                 scale: 0.7,
                  //                 child: Obx(() {
                  //                   return Switch(
                  //                     value:
                  //                         menuController!.isJainSwitched.value,
                  //                     onChanged: (value) async {
                  //                       menuController!.isJainSwitched.value =
                  //                           value;

                  //                       await getStoragePref.setValue(
                  //                           "jain", value);

                  //                       await menuController?.fetchFoodList(
                  //                           category: menuController
                  //                               ?.selectedCategory.value,
                  //                           isVeg: menuController
                  //                               ?.isVegSwitched.value,
                  //                           isNoVeg: menuController
                  //                               ?.isNonVegSwitched.value,
                  //                           isEgg: menuController
                  //                               ?.isEggSwitched.value,
                  //                           isJain: menuController
                  //                               ?.isJainSwitched.value);
                  //                     },
                  //                     activeColor: const Color(0xFF18A84A),
                  //                     inactiveThumbColor: ColorTheme.greenColor,
                  //                   );
                  //                 }),
                  //               ),
                  //               if (Platform.isWindows)
                  //                 const SizedBox(
                  //                   width: 20,
                  //                 ),

                  //               Text(
                  //                 'jain',
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   fontFamily: "Montserrat",
                  //                   color: ColorTheme.grey8C,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       VerticalDivider(
                  //           color: ColorTheme.whiteDF,
                  //           width: 20,
                  //           thickness: 1.5,
                  //           endIndent: 15,
                  //           indent: 15),
                  //       Expanded(
                  //         flex: 2,
                  //         child: Padding(
                  //           padding:
                  //               const EdgeInsets.symmetric(horizontal: 8.0),
                  //           child: Container(
                  //             width: double.infinity,
                  //             child: Obx(() {
                  //               return DropdownButton<String>(
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 dropdownColor: ColorTheme.whiteColor,
                  //                 isExpanded: true,
                  //                 value: menuController!
                  //                         .selectedCategory.value.isEmpty
                  //                     ? null
                  //                     : menuController!.selectedCategory.value,
                  //                 hint: Text(
                  //                   AppString.allCategory,
                  //                   style: TextStyle(
                  //                     fontSize: 13,
                  //                     fontFamily: "Montserrat",
                  //                     color: ColorTheme.grey8C,
                  //                     height: 16 / 19,
                  //                   ),
                  //                 ),
                  //                 underline: SizedBox.shrink(),
                  //                 onChanged: (newValue) async {
                  //                   menuController?.selectedCategory.value =
                  //                       newValue ?? '';
                  //                   await menuController?.fetchFoodList(
                  //                     category: newValue,
                  //                     isVeg:
                  //                         menuController?.isVegSwitched.value,
                  //                     isNoVeg: menuController
                  //                         ?.isNonVegSwitched.value,
                  //                     isEgg:
                  //                         menuController?.isEggSwitched.value,
                  //                     isJain:
                  //                         menuController?.isJainSwitched.value,
                  //                   );
                  //                 },
                  //                 items: [
                  //                   DropdownMenuItem<String>(
                  //                     value: '',
                  //                     child: Text(
                  //                       AppString.allCategory,
                  //                       style: TextStyle(
                  //                         color: ColorTheme.foodValue,
                  //                         fontFamily: "Montserrat",
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   ...menuController!.productCategoryList
                  //                       .map<DropdownMenuItem<String>>(
                  //                     (category) {
                  //                       String categoryName =
                  //                           category['name'] ??
                  //                               'Unnamed Category';
                  //                       return DropdownMenuItem<String>(
                  //                         value: categoryName,
                  //                         child: Text(
                  //                           categoryName,
                  //                           style: TextStyle(
                  //                             color: ColorTheme.foodValue,
                  //                             fontFamily: "Montserrat",
                  //                           ),
                  //                         ),
                  //                       );
                  //                     },
                  //                   ).toList(),
                  //                 ],
                  //               );
                  //             }),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    height: 55,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Food Type Multi-Select Dropdown
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Obx(() {
                              return PopupMenuButton<String>(
                                offset: Offset(0, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          menuController!
                                              .getSelectedFoodTypesText(),
                                          style: montserratMedium.copyWith(
                                              color: ColorTheme.grey8C,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down,
                                          color: ColorTheme.grey8C),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    enabled: false,
                                    child: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return Obx(() {
                                          return Column(
                                            children: [
                                              CheckboxListTile(
                                                title: Text(
                                                  AppString.veg,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color:
                                                              ColorTheme.grey8C,
                                                          fontSize: 14),
                                                ),
                                                value: menuController!
                                                    .isVegSwitched.value,
                                                onChanged: (value) async {
                                                  menuController!.isVegSwitched
                                                      .value = value!;
                                                  await getStoragePref.setValue(
                                                      "veg", value);
                                                  await menuController
                                                      ?.fetchFoodList(
                                                    category: menuController
                                                        ?.selectedCategory
                                                        .value,
                                                    isVeg: menuController
                                                        ?.isVegSwitched.value,
                                                    isNoVeg: menuController
                                                        ?.isNonVegSwitched
                                                        .value,
                                                    isEgg: menuController
                                                        ?.isEggSwitched.value,
                                                    isJain: menuController
                                                        ?.isJainSwitched.value,
                                                    status: menuController
                                                        ?.selectedStatus.value,
                                                  );
                                                },
                                                activeColor:
                                                    const Color(0xFF18A84A),
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                                dense: true,
                                              ),
                                              CheckboxListTile(
                                                title: Text(
                                                  AppString.nonVeg,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color:
                                                              ColorTheme.grey8C,
                                                          fontSize: 14),
                                                ),
                                                value: menuController!
                                                    .isNonVegSwitched.value,
                                                onChanged: (value) async {
                                                  menuController!
                                                      .isNonVegSwitched
                                                      .value = value!;
                                                  await getStoragePref.setValue(
                                                      "noVeg", value);
                                                  await menuController
                                                      ?.fetchFoodList(
                                                    category: menuController
                                                        ?.selectedCategory
                                                        .value,
                                                    isVeg: menuController
                                                        ?.isVegSwitched.value,
                                                    isNoVeg: menuController
                                                        ?.isNonVegSwitched
                                                        .value,
                                                    isEgg: menuController
                                                        ?.isEggSwitched.value,
                                                    isJain: menuController
                                                        ?.isJainSwitched.value,
                                                    status: menuController
                                                        ?.selectedStatus.value,
                                                  );
                                                },
                                                activeColor: ColorTheme.redF13,
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                                dense: true,
                                              ),
                                              CheckboxListTile(
                                                title: Text(
                                                  "Egg",
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color:
                                                              ColorTheme.grey8C,
                                                          fontSize: 14),
                                                ),
                                                value: menuController!
                                                    .isEggSwitched.value,
                                                onChanged: (value) async {
                                                  menuController!.isEggSwitched
                                                      .value = value!;
                                                  await getStoragePref.setValue(
                                                      "egg", value);
                                                  await menuController
                                                      ?.fetchFoodList(
                                                    category: menuController
                                                        ?.selectedCategory
                                                        .value,
                                                    isVeg: menuController
                                                        ?.isVegSwitched.value,
                                                    isNoVeg: menuController
                                                        ?.isNonVegSwitched
                                                        .value,
                                                    isEgg: menuController
                                                        ?.isEggSwitched.value,
                                                    isJain: menuController
                                                        ?.isJainSwitched.value,
                                                    status: menuController
                                                        ?.selectedStatus.value,
                                                  );
                                                },
                                                activeColor:
                                                    const Color(0xFFFFB300),
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                                dense: true,
                                              ),
                                              CheckboxListTile(
                                                title: Text(
                                                  "Jain",
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color:
                                                              ColorTheme.grey8C,
                                                          fontSize: 14),
                                                ),
                                                value: menuController!
                                                    .isJainSwitched.value,
                                                onChanged: (value) async {
                                                  menuController!.isJainSwitched
                                                      .value = value!;
                                                  await getStoragePref.setValue(
                                                      "jain", value);
                                                  await menuController
                                                      ?.fetchFoodList(
                                                    category: menuController
                                                        ?.selectedCategory
                                                        .value,
                                                    isVeg: menuController
                                                        ?.isVegSwitched.value,
                                                    isNoVeg: menuController
                                                        ?.isNonVegSwitched
                                                        .value,
                                                    isEgg: menuController
                                                        ?.isEggSwitched.value,
                                                    isJain: menuController
                                                        ?.isJainSwitched.value,
                                                    status: menuController
                                                        ?.selectedStatus.value,
                                                  );
                                                },
                                                activeColor:
                                                    const Color(0xFF18A84A),
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                                dense: true,
                                              ),
                                            ],
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),

                        VerticalDivider(
                          color: ColorTheme.whiteDF,
                          width: 20,
                          thickness: 1.5,
                          endIndent: 15,
                          indent: 15,
                        ),

                        // Status Dropdown
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: double.infinity,
                              child: Obx(() {
                                return DropdownButton<int?>(
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: ColorTheme.whiteColor,
                                  isExpanded: true,
                                  value: menuController!.selectedStatus.value,
                                  hint: Text(
                                    "All Status",
                                    style: montserratMedium.copyWith(
                                        color: ColorTheme.grey8C, fontSize: 14),
                                  ),
                                  underline: SizedBox.shrink(),
                                  onChanged: (newValue) async {
                                    menuController?.selectedStatus.value =
                                        newValue;
                                    await menuController?.fetchFoodList(
                                      category: menuController
                                          ?.selectedCategory.value,
                                      isVeg:
                                          menuController?.isVegSwitched.value,
                                      isNoVeg: menuController
                                          ?.isNonVegSwitched.value,
                                      isEgg:
                                          menuController?.isEggSwitched.value,
                                      isJain:
                                          menuController?.isJainSwitched.value,
                                      status: newValue,
                                    );
                                  },
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        "All Status",
                                        style: montserratMedium.copyWith(
                                            color: ColorTheme.grey8C,
                                            fontSize: 14),
                                      ),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 1,
                                      child: Text(
                                        "Active",
                                        style: montserratMedium.copyWith(
                                            color: ColorTheme.grey8C,
                                            fontSize: 14),
                                      ),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 0,
                                      child: Text(
                                        "Inactive",
                                        style: montserratMedium.copyWith(
                                            color: ColorTheme.grey8C,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),

                        VerticalDivider(
                          color: ColorTheme.whiteDF,
                          width: 20,
                          thickness: 1.5,
                          endIndent: 15,
                          indent: 15,
                        ),

                        // Category Dropdown
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: double.infinity,
                              child: Obx(() {
                                final selectedName =
                                    menuController!.selectedCategory.value;
                                final categoryOptions = menuController!
                                    .categoriesForCurrentMenu();
                                final selectedVisible = selectedName.isNotEmpty &&
                                    categoryOptions.any((category) =>
                                        category['name']?.toString() ==
                                        selectedName);
                                return DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: ColorTheme.whiteColor,
                                  isExpanded: true,
                                  value: selectedVisible ? selectedName : null,
                                  hint: Text(
                                    AppString.allCategory,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Montserrat",
                                      color: ColorTheme.grey8C,
                                      height: 16 / 19,
                                    ),
                                  ),
                                  underline: SizedBox.shrink(),
                                  onChanged: (newValue) async {
                                    menuController?.selectedCategory.value =
                                        newValue ?? '';
                                    await menuController?.fetchFoodList(
                                      category: newValue,
                                      isVeg:
                                          menuController?.isVegSwitched.value,
                                      isNoVeg: menuController
                                          ?.isNonVegSwitched.value,
                                      isEgg:
                                          menuController?.isEggSwitched.value,
                                      isJain:
                                          menuController?.isJainSwitched.value,
                                      status:
                                          menuController?.selectedStatus.value,
                                    );
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: '',
                                      child: Text(
                                        AppString.allCategory,
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    ),
                                    ...categoryOptions
                                        .map<DropdownMenuItem<String>>(
                                      (category) {
                                        String categoryName =
                                            category['name'] ??
                                                'Unnamed Category';
                                        return DropdownMenuItem<String>(
                                          value: categoryName,
                                          child: Text(
                                            categoryName,
                                            style: TextStyle(
                                              color: ColorTheme.foodValue,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: ColorTheme.whiteE4, thickness: 0.7, height: 0),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, right: 20, left: 20, bottom: 10),
                          child: TextFormField(
                            onChanged: (value) {
                              menuController?.update();
                            },
                            controller: menuController?.searchController,
                            showCursor: true,
                            cursorColor: ColorTheme.greyBE,
                            cursorHeight: 15.0,
                            cursorRadius: Radius.circular(10),
                            cursorWidth: 2.0,
                            decoration: InputDecoration(
                              fillColor: ColorTheme.whiteColor,
                              filled: true,
                              hintText: AppString.searchFood,
                              prefixIcon:
                                  Icon(Icons.search, color: ColorTheme.greyBE),
                              hintStyle: TextStyle(
                                fontSize: 16,
                                fontFamily: "Montserrat",
                                color: ColorTheme.grey8C,
                                height: 16 / 19,
                              ),
                              border: AppBorder.menuSearchBorder.copyWith(
                                  borderSide: BorderSide(
                                      width: 2, color: ColorTheme.transparent)),
                              enabledBorder: AppBorder.menuSearchBorder
                                  .copyWith(
                                      borderSide: BorderSide(
                                          width: 2,
                                          color: ColorTheme.transparent)),
                              focusedBorder: AppBorder.menuSearchBorder
                                  .copyWith(
                                      borderSide: BorderSide(
                                          color: ColorTheme.transparent)),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Montserrat",
                              color: ColorTheme.grey8C,
                              height: 16 / 19,
                            ),
                          ),
                        ),
                      ),
                      uploadIconWidget(
                        onDownLoadTap: () {
                          Get.to(() => BulkImportScreen(
                                tittleName: AppString.menuBulkImport,
                                onuploadTap: () {
                                  Get.find<MenuManagementController>()
                                      .bulkImport();
                                },
                                onDownloadExistingDataTap: () {
                                  Get.find<MenuManagementController>()
                                      .bulkExport();
                                },
                                onDownloadSampleDataTap: () {
                                  Get.find<MenuManagementController>()
                                      .exportSample();
                                },
                                controller:
                                    Get.find<MenuManagementController>(),
                              ));
                        },
                        onUploadTap: () {
                          Get.to(() => BulkImportScreen(
                                tittleName: AppString.menuBulkImport,
                                onuploadTap: () {
                                  Get.find<MenuManagementController>()
                                      .bulkImport();
                                },
                                onDownloadExistingDataTap: () {
                                  Get.find<MenuManagementController>()
                                      .bulkExport();
                                },
                                onDownloadSampleDataTap: () {
                                  Get.find<MenuManagementController>()
                                      .exportSample();
                                },
                                controller:
                                    Get.find<MenuManagementController>(),
                              ));
                        },
                        isPLusShow: true,
                        onPlusTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();

                          Get.to(() => AddEditMenuScreen(
                                isEdit: false,
                                food: {},
                                menuFoodFor: menuController?.filterFoodFor,
                              ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                    child:
                        Text(AppString.action, style: AppStyle.tx18mediumRed),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: GetBuilder<MenuManagementController>(
                builder: (controller) {
                  var filteredFoodList =
                      menuController?.foodList.where((element) {
                    return element["name"].toString().toLowerCase().contains(
                        menuController!.searchController.text.toLowerCase());
                  }).toList();

                  final categoryUnavailable = menuController
                          ?.isCategoryUnavailableForAggregator(
                              menuController?.selectedCategory.value) ??
                      false;

                  return (menuController?.isFoodLoader ?? false)
                      ? Center(
                          child: Center(
                              child: CircularProgressIndicator(
                          backgroundColor: ColorTheme.whiteColor,
                          color: ColorTheme.greenColor,
                        )))
                      : categoryUnavailable
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  menuController?.categoryUnavailableMessage ??
                                      "This category is not available in the aggregator menu. Please change the category.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Montserrat",
                                    color: ColorTheme.grey8C,
                                  ),
                                ),
                              ),
                            )
                          : (filteredFoodList?.isNotEmpty ?? false)
                          ? ListView.builder(
                              controller: menuController!.foodScrollController,
                              itemCount: filteredFoodList?.length,
                              itemBuilder: (context, index) {
                                final food = filteredFoodList?[index];
                                var categoryName = food?['category'] != null
                                    ? food?['category']?['name'] ?? ""
                                    : 'N/A';

                                // print('>>>>>>>>>>>>>${food?['food_for']}');
                                String? restaurantType =
                                    Get.find<AuthController>()
                                        .profileModel
                                        ?.restaurants
                                        ?.first
                                        .resturantType;

                                final hasImage = food?['image'] != null &&
                                    food?['image'].isNotEmpty;
                                String defaultImage =
                                    '${AppConstants.BASE_URL}/public/assets/admin/img/100x100/food-default-image.png';
                                final imageUrl =
                                    hasImage ? food!['image'] : null;

                                return Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: ColorTheme.whiteE7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            quickEditFoodSheet(
                                                context, food ?? {},
                                                menuController: menuController!,
                                                inventoryController:
                                                    inventoryController!);
                                          },
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                10.width,
                                                // Image.asset(
                                                //   food?['item_type'] == 1
                                                //       ? Images.Food_V_img
                                                //       : Images.Food_NV_img,
                                                //   width: 50,
                                                // ),
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: imageUrl !=
                                                          defaultImage
                                                      ? (food?['item_type'] == 0
                                                          ? Colors.red
                                                          : food?['item_type'] ==
                                                                  2
                                                              ? Color(
                                                                  0xFFFFB300)
                                                              : food?['item_type'] ==
                                                                      3
                                                                  ? Colors.green
                                                                  : food?['item_type'] ==
                                                                          1
                                                                      ? Colors
                                                                          .green
                                                                      : ColorTheme
                                                                          .yellow)
                                                      : ColorTheme.transparent,
                                                  child: CircleAvatar(
                                                    radius: 23,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage: (imageUrl ??
                                                                    '')
                                                                .isNotEmpty &&
                                                            imageUrl !=
                                                                defaultImage
                                                        ? CachedNetworkImageProvider(
                                                            imageUrl!)
                                                        : null,
                                                    child: ((imageUrl ?? '')
                                                                .isNotEmpty &&
                                                            imageUrl !=
                                                                defaultImage)
                                                        ? null
                                                        : (food?['item_type'] ==
                                                                1
                                                            ? Image.asset(
                                                                Images
                                                                    .Food_V_img,
                                                                width: 50,
                                                              )
                                                            : food?['item_type'] ==
                                                                    2
                                                                ? Image.asset(
                                                                    Images
                                                                        .Food_E_img,
                                                                    width: 50,
                                                                  )
                                                                : food?['item_type'] ==
                                                                        3
                                                                    ? Image
                                                                        .asset(
                                                                        Images
                                                                            .Food_V_img,
                                                                        width:
                                                                            50,
                                                                      )
                                                                    : food?['item_type'] ==
                                                                            0
                                                                        ? Image
                                                                            .asset(
                                                                            Images.Food_NV_img,
                                                                            width:
                                                                                50,
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            Images.Food_V_img,
                                                                            width:
                                                                                50,
                                                                          )),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0, top: 7),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 120,
                                                          child: Text(
                                                            food?['name'] ?? "",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
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
                                                        SizedBox(height: 5),
                                                        Container(
                                                          width: 120,
                                                          child: Text(
                                                            categoryName,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontSize: 13,
                                                              color: ColorTheme
                                                                  .blue0090FF,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          authController
                                                                      ?.profileModel
                                                                      ?.restaurants
                                                                      ?.first
                                                                      .resturantType ==
                                                                  'Restaurant'
                                                              ? '₹ ${food?['price']}'
                                                              : '₹ 0',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .switchColor,
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
                                          child: Obx(() {
                                            bool isUpdating = menuController!
                                                    .updatingFoodId.value ==
                                                food?['id'];

                                            if (isUpdating) {
                                              return SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    ColorTheme.greenColor,
                                                  ),
                                                ),
                                              );
                                            }

                                            if (menuController!
                                                .isAggregatorFood(food)) {
                                              return AggregatorStockStatusButton(
                                                food: food ?? {},
                                              );
                                            }

                                            return Transform.scale(
                                              scale: 0.7,
                                              child: Switch(
                                                inactiveTrackColor: ColorTheme
                                                    .switchITrackColor,
                                                inactiveThumbColor: ColorTheme
                                                    .switchIThumbColor,
                                                value: food?['status'] == 1
                                                    ? true
                                                    : false,
                                                onChanged: (value) {
                                                  final data = {
                                                    "status":
                                                        value ? "1" : "0",
                                                    if (food?['food_for'] ==
                                                        'Aggregator')
                                                      "food_for":
                                                          food?["food_for"]
                                                  };
                                                  menuController?.statusFood(
                                                      food?['id'],
                                                      data: data);
                                                },
                                                activeColor: ColorTheme.green,
                                              ),
                                            );
                                          }),
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
                                                onTap: () {
                                                  Get.to(() =>
                                                      AddEditMenuScreen(
                                                        isEdit: true,
                                                        food: food ?? {},
                                                        menuFoodFor:
                                                            food?["food_for"],
                                                      ));
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: SvgPicture.asset(
                                                      Images.Edit,
                                                      color: ColorTheme.green,
                                                      width: 20.7),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  deleteFoodSheet(
                                                    context,
                                                    menuManagementController:
                                                        menuController!,
                                                    foodText:
                                                        food?['name'] ?? "",
                                                    onDeleteTap: () async {
                                                      await menuController
                                                          ?.deleteFood(
                                                        food?['id'],
                                                        foodFor:
                                                            food?["food_for"] ??
                                                                "",
                                                      );
                                                    },
                                                  );
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
                                              )
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
