import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show Platform, File;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  MenuManagementController? menuManagementController;
  // InventoryController? inventoryController;

  @override
  void initState() {
    menuManagementController = Get.find<MenuManagementController>();
    // inventoryController = Get.find<InventoryController>();
    menuManagementController?.categoriesSearchController.clear();
    menuManagementController?.getMenuManagementCategories();
    menuManagementController?.getStationList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleText: AppString.categories,
          actions: [
            uploadIconWidget(
              onDownLoadTap: () async {
                // await menuManagementController?.exportCategories();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Categories',
                      controller: Get.find<MenuManagementController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        menuManagementController?.exportCategorySample();
                      },
                      onDownloadExistingDataTap: () {
                        menuManagementController?.exportCategories();
                      },
                      onuploadTap: () {
                        menuManagementController?.importCategories();
                      },
                    ));
              },
              onUploadTap: () async {
                // await menuManagementController?.importCategories();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Categories',
                      controller: Get.find<MenuManagementController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        menuManagementController?.exportCategorySample();
                      },
                      onDownloadExistingDataTap: () {
                        menuManagementController?.exportCategories();
                      },
                      onuploadTap: () {
                        menuManagementController?.importCategories();
                      },
                    ));
              },
              isPLusShow: true,
              onPlusTap: () {
                categoryBootomSheet(context,
                    menuManagementController: menuManagementController!,
                    onTap: () async {
                  if (menuManagementController?.categoriesController.text
                          .trim() ==
                      "") {
                    Get.snackbar("Check Again !", 'Category name is empty',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  } else if (menuManagementController?.selectedStationName ==
                      '') {
                    Get.snackbar("Check Again !", 'Please select station name',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  } else {
                    await menuManagementController?.AddCategories();
                  }
                  // await menuManagementController?.AddCategories();
                }, isEdit: false, menuCategory: {});
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ).paddingOnly(right: 5),
          ],
        ),
        body: Column(
          children: [
            15.height,
            CustomSearchField(
              onChanged: (p0) {
                menuManagementController?.update();
              },
              controller: menuManagementController!.categoriesSearchController,
              hitText: AppString.search,
            ).paddingSymmetric(horizontal: 20),
            15.height,
            Container(
              height: 40,
              color: ColorTheme.whiteColor,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child: Row(
                      children: [
                        15.width,
                        Text(AppString.name, style: AppStyle.tx18mediumRed),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    child:
                        Text(AppString.status, style: AppStyle.tx18mediumRed),
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
            ),
            Expanded(child: GetBuilder<MenuManagementController>(
              builder: (controller) {
                var filteredMenuCategoryList = menuManagementController
                    ?.menuManagementCategoryList
                    .where((element) {
                  return element["name"].toString().toLowerCase().contains(
                      menuManagementController!.categoriesSearchController.text
                          .toLowerCase());
                }).toList();

                return menuManagementController!.isMenuCategoryLoader.value
                    ? AppLoader()
                    : filteredMenuCategoryList!.isNotEmpty
                        ? Container(
                            color: ColorTheme.whiteColor,
                            child: ListView.builder(
                              itemCount: filteredMenuCategoryList.length ?? 0,
                              itemBuilder: (context, index) {
                                final menuCategory =
                                    filteredMenuCategoryList[index];
                                return Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: ColorTheme.whiteE7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                                color: ColorTheme.transparent,
                                                border: Border.symmetric(
                                                    vertical: BorderSide(
                                                        color: ColorTheme
                                                            .whiteE7))),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, top: 0),
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                      child: CachedNetworkImage(
                                                        width: 40,
                                                        height: 40,
                                                        imageUrl: menuCategory[
                                                            "image"],
                                                        placeholder: (context,
                                                                url) =>
                                                            CupertinoActivityIndicator(),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            menuCategory[
                                                                "name"],
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontSize: 13,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                          ),
                                                          2.height,
                                                          Text(
                                                            'Station Name : ${menuCategory["station_name"] ?? ''}',
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontSize: 9,
                                                              color: ColorTheme
                                                                  .blue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Transform.scale(
                                            scale: 0.6,
                                            child: Switch(
                                              value: menuCategory['status'] == 1
                                                  ? true
                                                  : false,
                                              onChanged: (value) {
                                                final data = {
                                                  "status": value ? 1 : 0
                                                };
                                                menuManagementController!
                                                    .categoriesStatusChange(
                                                        menuCategory['id'],
                                                        data: data);
                                              },
                                              activeColor:
                                                  ColorTheme.green,
                                              inactiveTrackColor:
                                                  ColorTheme.switchITrackColor,
                                              inactiveThumbColor:
                                                  ColorTheme.switchIThumbColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7)),
                                          ),
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // inventoryCategorySheet(
                                                  //     context,
                                                  //     inventoryController:
                                                  //         inventoryController!,
                                                  //     onTap: () async {
                                                  //   await menuManagementController
                                                  //       ?.updateCategories(
                                                  //           menuCategory["id"],
                                                  //           inventoryController:
                                                  //               inventoryController!);
                                                  // },
                                                  //     menuCategory:
                                                  //         menuCategory,
                                                  //     isEdit: true);
                                                  categoryBootomSheet(context,
                                                      menuManagementController:
                                                          menuManagementController!,
                                                      onTap: () async {
                                                    if (menuManagementController
                                                            ?.categoriesController
                                                            .text
                                                            .trim() ==
                                                        "") {
                                                      Get.snackbar(
                                                          "Check Again !",
                                                          'Category name is empty',
                                                          backgroundColor:
                                                              Colors.red,
                                                          colorText:
                                                              Colors.white);
                                                      return;
                                                    } else if (menuManagementController
                                                            ?.selectedStationName ==
                                                        '') {
                                                      Get.snackbar(
                                                          "Check Again !",
                                                          'Please select station name',
                                                          backgroundColor:
                                                              Colors.red,
                                                          colorText:
                                                              Colors.white);
                                                      return;
                                                    } else {
                                                      await menuManagementController
                                                          ?.updateCategories(
                                                              menuCategory[
                                                                  "id"]);
                                                    }
                                                  },
                                                      isEdit: true,
                                                      menuCategory:
                                                          menuCategory);
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
                                                onTap: () async {
                                                  // Get.bottomSheet(
                                                  //     confirmationDialog(
                                                  //   confirmDescriptionText:
                                                  //       "${AppString.areYouSureDelete} ${menuCategory["name"]}",
                                                  //   onYesTap: () async {
                                                  //     await menuManagementController
                                                  //         ?.deleteCategories(
                                                  //             menuCategory[
                                                  //                 "id"]);
                                                  //   },
                                                  // ));
                                                  await menuManagementController
                                                      ?.deleteCategories(
                                                          menuCategory["id"]);
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

categoryBootomSheet(BuildContext context,
    {required MenuManagementController menuManagementController,
    void Function()? onTap,
    bool isEdit = false,
    required Map<String, dynamic> menuCategory}) {
  if (isEdit) {
    menuManagementController.categoriesController.text = menuCategory["name"];
    menuManagementController.selectedStationName = menuCategory["station_name"];
    menuManagementController.categoryOrderController.text =
        (menuCategory['cat_order'] ?? 0).toString();
    // Load existing image URL
    menuManagementController.categoryImageUrl = menuCategory["image"];
    menuManagementController.categoryImageFile = null; // Clear new selection
    menuManagementController.categoryImageFileName = null;
    menuManagementController.isCategoryImageUploaded = false;
  } else {
    // menuManagementController.selectedStationName = '';
    final defaultStation = menuManagementController.stationList.firstWhere(
      (station) => station['area_name'] == 'KDS',
      orElse: () => {},
    );

    menuManagementController.selectedStationName =
        defaultStation['area_name'] ?? '';
    menuManagementController.categoriesController.clear();
    menuManagementController.categoryOrderController.clear();
    // Clear category image data for new category
    menuManagementController.categoryImageFile = null;
    menuManagementController.categoryImageUrl = null;
    menuManagementController.categoryImageFileName = null;
    menuManagementController.isCategoryImageUploaded = false;
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: ColorTheme.whiteColor,
    isScrollControlled: true,
    isDismissible: false,
    constraints: BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit
                                ? AppString.editCategory
                                : AppString.newCategory,
                            style: AppStyle.addCategoryTextStyle.copyWith(
                                color: ColorTheme.grey105,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(
                              Icons.close,
                              color: ColorTheme.grey105,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: ColorTheme.grey.withOpacity(.3),
                      ),
                    ),
                    16.height,
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 270),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextformField(
                              onChanged: (value) {},
                              labelText: 'Category Name',
                              controller:
                                  menuManagementController.categoriesController,
                              keyboardType: TextInputType.name,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              errorBorder: AppBorder.errorBorder,
                              focusedErrorBorder: AppBorder.errorBorder,
                            ),
                            // Container(
                            //   height: 45,
                            //   width: double.infinity,
                            //   child: TextFormField(
                            //     controller: menuManagementController
                            //         .categoriesController,
                            //     decoration: InputDecoration(
                            //       hintText: AppString.categoryName,
                            //       hintStyle: TextStyle(
                            //           fontSize: 14,
                            //           color: ColorTheme.grey.withOpacity(.5)),
                            //       contentPadding: EdgeInsets.symmetric(
                            //           vertical: 0, horizontal: 12),
                            //       border: AppBorder.selectStockNameFieldBorder,
                            //       enabledBorder:
                            //           AppBorder.selectStockNameFieldBorder,
                            //       focusedBorder:
                            //           AppBorder.selectStockNameFieldBorder,
                            //     ),
                            //   ),
                            // ),
                            10.height,
                            Row(children: [
                              GetBuilder<MenuManagementController>(
                                builder: (controller) {
                                  return InkWell(
                                    onTap: menuManagementController
                                            .isCategorySubmitting.value
                                        ? null
                                        : () => menuManagementController
                                            .pickCategoryImage(),
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: menuManagementController
                                                  .categoryImageFile !=
                                              null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                File(menuManagementController
                                                    .categoryImageFile!.path),
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : ((menuManagementController
                                                          .categoryImageUrl !=
                                                      null &&
                                                  menuManagementController
                                                          .categoryImageUrl !=
                                                      '')
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        menuManagementController
                                                            .categoryImageUrl!,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.contain,
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add_photo_alternate,
                                                      size: (Platform
                                                                  .isAndroid ||
                                                              Platform.isIOS)
                                                          ? 30
                                                          : 50,
                                                    ),
                                                    Text(
                                                      'Upload Category Image',
                                                      textAlign: TextAlign.center,
                                                      style: AppStyle
                                                          .txt14FoodValue
                                                          .copyWith(
                                                        fontSize: (Platform
                                                                    .isAndroid ||
                                                                Platform.isIOS)
                                                            ? 10
                                                            : 15,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                    ),
                                  );
                                },
                              ),
                              10.width,
                              Expanded(
                                child: Column(
                                  children: [
                                    10.height,
                                    CustomTextformField(
                                      onChanged: (value) {},
                                      labelText: 'Category Order',
                                      controller: menuManagementController
                                          .categoryOrderController,
                                      keyboardType: TextInputType.number,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      errorBorder: AppBorder.errorBorder,
                                      focusedErrorBorder: AppBorder.errorBorder,
                                    ),
                                    15.height,
                                    GetBuilder<MenuManagementController>(
                                      builder: (controller) {
                                        return DropdownButtonFormField2<String>(
                                          isExpanded: true,
                                          value: menuManagementController
                                                      .selectedStationName ==
                                                  ''
                                              ? null
                                              : menuManagementController
                                                  .selectedStationName,
                                          decoration: InputDecoration(
                                            labelText: 'Station Name',
                                            labelStyle: AppStyle.txt14FoodValue
                                                .copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.foodValue
                                                  .withOpacity(.8),
                                            ),
                                            hintText: 'Select Station',
                                            hintStyle: AppStyle.txt14FoodValue
                                                .copyWith(
                                              fontSize: 12,
                                              color: ColorTheme.foodValue
                                                  .withOpacity(.8),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15.0,
                                                    vertical: 0),
                                            filled: true,
                                            // fillColor: null, // Add color if needed
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                color: ColorTheme.whiteDC
                                                    .withOpacity(.6),
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                color: ColorTheme.whiteDC
                                                    .withOpacity(.6),
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide(
                                                color: ColorTheme.whiteDC
                                                    .withOpacity(.6),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            padding: EdgeInsets.zero,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          iconStyleData: IconStyleData(
                                            icon: Icon(
                                                Icons.arrow_drop_down_rounded),
                                            iconSize: 20,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              color: ColorTheme.whiteColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                            ),
                                          ),
                                          items: menuManagementController
                                              .stationList
                                              .map<DropdownMenuItem<String>>(
                                                  (station) {
                                            return DropdownMenuItem<String>(
                                              value: station['area_name'] ?? '',
                                              child: Text(
                                                station['area_name'] ?? '',
                                                style: AppStyle.txt14FoodValue
                                                    .copyWith(
                                                        color: ColorTheme
                                                            .foodValue
                                                            .withOpacity(.7)),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            menuManagementController
                                                    .selectedStationName =
                                                newValue ?? '';
                                            menuManagementController.update();
                                          },
                                        );
                                      },
                                    ),
                                    10.height,
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    20.height,
                  ],
                ),
                Obx(
                  () => GestureDetector(
                    onTap: menuManagementController.isCategorySubmitting.value
                        ? null
                        : onTap,
                    child: Container(
                      height: 60,
                      color: ColorTheme.greenColor,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: menuManagementController.isCategoryLoader.value
                          ? AppLoader()
                          : Text(
                              isEdit
                                  ? AppString.editCategory
                                  : AppString.addCategory,
                              style: AppStyle.addCategoryTextStyle,
                            ),
                    ),
                  ),
                ),
                // 20.height,
              ],
            ),
          ),
        ),
      );
    },
  );
}
