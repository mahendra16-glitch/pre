import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/widget/category_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/add_addons_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/model/addons_model.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/category_selection_widget.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../../widget/custom_textform_field.dart' show CustomTextformField;

class AddEditMenuScreen extends StatefulWidget {
  final bool isEdit;
  final String? menuFoodFor;

  Map<String, dynamic> food;

  AddEditMenuScreen({
    required this.isEdit,
    this.menuFoodFor,
    required this.food,
  });

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  MenuManagementController? menuController;
  InventoryController? inventoryController;
  bool showValidateError = false;

  @override
  void initState() {
    menuController = Get.find<MenuManagementController>();
    inventoryController = Get.find<InventoryController>();
    menuController?.onInitCalling(
        isEdit: widget.isEdit,
        myFood: widget.food,
        foodFor: widget.menuFoodFor);
    menuController?.getStationList();
    print(
        '.......${Get.find<AuthController>().profileModel!.restaurants!.first.resturantGst}');
    print(
        'After onInitCalling: variations: ${menuController!.variations.length}, formKeys: ${menuController!.formKeys.length}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.whiteColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: ColorTheme.green,
            onPressed: () {
              Get.back();
            },
          ),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Text(
              widget.isEdit ? 'Edit ${widget.food["name"]}' : AppString.addFood,
              style: AppStyle.stockListStyle
                  .copyWith(color: ColorTheme.blackColor, fontSize: 16)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GetBuilder<MenuManagementController>(
                  builder: (menuController) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionPanelList.radio(
                              expandIconColor: ColorTheme.green,
                              initialOpenPanelValue: 0,
                              dividerColor: ColorTheme.whiteE4,
                              elevation: 0,
                              expandedHeaderPadding: EdgeInsets.zero,
                              children: [
                                // Food Basic Info Panel
                                ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  value: 0,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      selectedTileColor: ColorTheme.green,
                                      selectedColor: ColorTheme.green,
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            SvgPicture.asset(Images.food_info),
                                      ),
                                      title: Text(
                                        AppString.basicFoodInfo,
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    );
                                  },
                                  body: Column(
                                    children: [
                                      5.height,
                                      Divider(
                                          color: ColorTheme.whiteE4,
                                          thickness: 1,
                                          height: 1),
                                      20.height,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GetBuilder<
                                                MenuManagementController>(
                                              builder: (controller) {
                                                print("menuController.selectedValueFoodFoor.value :${menuController.selectedValueFoodFoor.value}");
                                                return CustomDropdownWidget(
                                                  value: menuController
                                                          .selectedValueFoodFoor
                                                          .value
                                                          .isNotEmpty
                                                      ? menuController
                                                          .selectedValueFoodFoor
                                                          .value
                                                      : null,
                                                  hintText: AppString.foodFor,
                                                  labelText: 'Food For',
                                                  onChanged: widget.isEdit ==
                                                          false
                                                      ? null
                                                      : (String? newValue) {
                                                          setState(() {
                                                            menuController
                                                                    .selectedValueFoodFoor
                                                                    .value =
                                                                newValue ?? '';
                                                          });
                                                        },
                                                  items: menuController
                                                      // .foodForApiList                              
                                                      .menuFoodForList
                                                      .toSet()
                                                      .toList()
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: AppStyle
                                                            .txt14FoodValue
                                                            .copyWith(
                                                                color: ColorTheme
                                                                    .foodValue
                                                                    .withOpacity(
                                                                        .7)),
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      20.height,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        child: Container(
                                          child: CustomTextformField(
                                            labelText: AppString.productName,
                                            controller:
                                                menuController.productName,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'.*')),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Obx(() => menuController.isNameValid.value
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                5.height,
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Name is required",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox()),
                                      20.height,
                                      Row(children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: Container(
                                              child: CustomTextformField(
                                                labelText:
                                                    AppString.description,
                                                controller:
                                                    menuController.description,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (widget.menuFoodFor != "Aggregator")
                                          10.width,
                                        if (widget.menuFoodFor != "Aggregator")
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0),
                                              child: Container(
                                                child: CustomTextformField(
                                                  labelText: 'Item Code',
                                                  controller: menuController
                                                      .itemCodeController,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ]),
                                      20.height,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CategorySelectionWidget(
                                              isEdit: widget.isEdit,
                                            ).paddingOnly(left: 0),
                                          ),
                                          10.width,
                                          GestureDetector(
                                            onTap: () {
                                              categoryBootomSheet(context,
                                                  menuManagementController:
                                                      menuController,
                                                  onTap: () async {
                                                if (menuController
                                                        .categoriesController
                                                        .text
                                                        .trim() ==
                                                    "") {
                                                  Get.snackbar("Check Again !",
                                                      'Category name is empty',
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white);
                                                  return;
                                                } else if (menuController
                                                        .selectedStationName ==
                                                    '') {
                                                  Get.snackbar("Check Again !",
                                                      'Please select station name',
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white);
                                                  return;
                                                } else {
                                                  await menuController
                                                      .AddCategories();
                                                }
                                              },
                                                  isEdit: false,
                                                  menuCategory: {});
                                            },
                                            child: Icon(
                                                Icons.add_circle_outline,
                                                size: 34,
                                                color: ColorTheme.grey8C),
                                          ).paddingOnly(right: 12),
                                          // 10.width,
                                          if (menuController
                                                  .selectedValueFoodFoor
                                                  .value !=
                                              "Aggregator")
                                            Expanded(
                                              child: DropdownButtonFormField2<
                                                  String>(
                                                value: menuController
                                                        .selectedComplementary
                                                        .isNotEmpty
                                                    ? menuController
                                                        .selectedComplementary
                                                    : null,

                                                items: menuController
                                                    .complementaryList
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: AppStyle
                                                          .txt14FoodValue
                                                          .copyWith(
                                                        color: ColorTheme
                                                            .foodValue
                                                            .withOpacity(.7),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),

                                                onChanged: (String? newValue) {
                                                  menuController
                                                          .selectedComplementary =
                                                      newValue ?? '';
                                                  menuController.update();
                                                  print(
                                                      "Complementary ${menuController.selectedComplementary}");
                                                },

                                                // ==== Button Style ====
                                                buttonStyleData:
                                                    ButtonStyleData(
                                                  padding: EdgeInsets.zero,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  overlayColor:
                                                      WidgetStateProperty.all(
                                                          Colors.transparent),
                                                ),

                                                // ==== Dropdown Style ====
                                                dropdownStyleData:
                                                    DropdownStyleData(
                                                  maxHeight: 400,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFDCDCDC),
                                                    ),
                                                  ),
                                                ),

                                                menuItemStyleData:
                                                    MenuItemStyleData(
                                                  height: 45,
                                                ),

                                                // ==== Input Decoration ====
                                                decoration: InputDecoration(
                                                  labelText: 'Complementary',
                                                  labelStyle: AppStyle
                                                      .txt14FoodValue
                                                      .copyWith(
                                                    color: ColorTheme.black,
                                                    fontSize: 15,
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFDCDCDC)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFDCDCDC)),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFDCDCDC)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFDCDCDC)),
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                      Obx(() => menuController
                                              .isCategoryValid.value
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                5.height,
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Category is required",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox()),
                                      20.height,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: (Platform.isAndroid ||
                                                        Platform.isIOS)
                                                    ? screenHeight * 0.08
                                                    : screenHeight * 0.1,
                                                child: CustomTextformField(
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                  labelText: AppString.price,
                                                  controller:
                                                      menuController.menuPrice,
                                                ),
                                              ),
                                            ),
                                            10.width,
                                            CustomDropdownWidget(
                                              labelText: 'Item Type',
                                              items: menuController.itemTypeList
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 12,
                                                      color:
                                                          ColorTheme.foodValue,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              hintText: AppString.itemType,
                                              onChanged: (String? newValue) {
                                                menuController.itemType =
                                                    newValue!;
                                                log("itemType ${menuController.itemType}");
                                                setState(() {});
                                              },
                                              value: (menuController.itemType
                                                          ?.isNotEmpty ??
                                                      false)
                                                  ? menuController.itemType
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Obx(() => menuController
                                              .isPriceValid.value
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Price is required",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox()),
                                      // 10.height,
                                      // Tax Type and Tax Row moved here from Food Tax & Charges section
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDropdownWidget(
                                            labelText: 'Tax Type',
                                            // items: menuController.taxTypeList
                                            items: menuController.taxTypeList
                                                .where((value) => !(value ==
                                                        'VAT' &&
                                                    menuController.isVat == 0))
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                          color: ColorTheme
                                                              .foodValue
                                                              .withOpacity(.7)),
                                                ),
                                              );
                                            }).toList(),
                                            value: menuController
                                                    .selectedTaxType
                                                    .value
                                                    .isNotEmpty
                                                ? menuController
                                                    .capitalizeFirstLetter(
                                                        menuController
                                                            .selectedTaxType
                                                            .value)
                                                : null,
                                            hintText: 'Tax Type',
                                            onChanged:
                                                Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .resturantGst ==
                                                        'restaurant'
                                                    ? null
                                                    : (String? newValue) {
                                                        menuController
                                                            .selectedTaxType
                                                            .value = newValue!;
                                                        menuController.update();
                                                        print(
                                                            "selectedTaxType ${menuController.selectedTaxType.value}");
                                                      },
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: 'Tax',
                                                controller: menuController
                                                    .taxController,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      20.height,
                                    ],
                                  ),
                                ),

                                // Food Variations Panel
                                ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  value: 1,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                            Images.food_varations),
                                      ),
                                      title: Text(
                                        AppString.foodVariations,
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    );
                                  },
                                  body: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      menuController.variations.isNotEmpty
                                          ? Divider(
                                                  color: Colors.grey,
                                                  thickness: 1,
                                                  height: 1)
                                              .paddingOnly(top: 5)
                                          : SizedBox(),
                                      menuController.variations.isNotEmpty
                                          ? SingleChildScrollView(
                                              child: ExpansionPanelList.radio(
                                                expandIconColor:
                                                    ColorTheme.green,
                                                initialOpenPanelValue: 0,
                                                dividerColor:
                                                    ColorTheme.whiteE4,
                                                elevation: 0,
                                                expandedHeaderPadding:
                                                    EdgeInsets.zero,
                                                children: List.generate(
                                                  menuController
                                                      .variations.length,
                                                  (variationIndex) {
                                                    final variation =
                                                        menuController
                                                                .variations[
                                                            variationIndex];
                                                    final isMultiple = variation[
                                                            "selectionType"] ==
                                                        "multi";
                                                    final List<bool>
                                                        toggleSelected = [
                                                      !isMultiple,
                                                      isMultiple,
                                                    ];

                                                    return ExpansionPanelRadio(
                                                      value: variationIndex,
                                                      canTapOnHeader: true,
                                                      headerBuilder:
                                                          (BuildContext context,
                                                              bool isExpanded) {
                                                        return ListTile(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5.0),
                                                          title: Text(
                                                            'Variation ${variationIndex + 1}',
                                                            style:
                                                                montserratSemiBold
                                                                    .copyWith(
                                                              fontSize: 14,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      body: Form(
                                                        key: menuController
                                                                .formKeys[
                                                            variationIndex],
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      0.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0,
                                                                    vertical:
                                                                        10),
                                                                child:
                                                                    CustomTextformField(
                                                                  onChanged:
                                                                      (value) {
                                                                    menuController
                                                                            .isValidated[
                                                                        variationIndex] = false;
                                                                    showValidateError =
                                                                        false;
                                                                    menuController
                                                                        .update();
                                                                  },
                                                                  labelText:
                                                                      AppString
                                                                          .name,
                                                                  controller:
                                                                      variation[
                                                                          "nameController"],
                                                                  autovalidateMode:
                                                                      AutovalidateMode
                                                                          .onUserInteraction,
                                                                  errorStyle: AppStyle
                                                                      .txt14FoodValue
                                                                      .copyWith(
                                                                          color: ColorTheme
                                                                              .red,
                                                                          fontSize:
                                                                              9),
                                                                  errorBorder:
                                                                      AppBorder
                                                                          .errorBorder,
                                                                  focusedErrorBorder:
                                                                      AppBorder
                                                                          .errorBorder,
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .trim()
                                                                            .isEmpty) {
                                                                      return 'Please Enter Variation Name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ),
                                                              10.height,
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0),
                                                                child: Row(
                                                                  children: [
                                                                    ToggleButtons(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxHeight: 300),
                                                                      isSelected:
                                                                          toggleSelected,
                                                                      onPressed:
                                                                          (int
                                                                              index) {
                                                                        variation[
                                                                            "selectionType"] = index ==
                                                                                0
                                                                            ? "single"
                                                                            : "multi";
                                                                        if (variation["selectionType"] ==
                                                                            "single") {
                                                                          variation["minController"].text =
                                                                              '';
                                                                          variation["maxController"].text =
                                                                              '';
                                                                          if (variation["options"]
                                                                              .isEmpty) {
                                                                            variation["options"].add({
                                                                              "optionNameController": TextEditingController(),
                                                                              "priceController": TextEditingController(),
                                                                            });
                                                                          }
                                                                        } else {
                                                                          if (variation["options"].length ==
                                                                              1) {
                                                                            variation["options"].add({
                                                                              "optionNameController": TextEditingController(),
                                                                              "priceController": TextEditingController(),
                                                                            });
                                                                          }
                                                                          variation["minController"].text =
                                                                              '1';
                                                                          variation["maxController"].text = variation["options"]
                                                                              .length
                                                                              .toString();
                                                                        }
                                                                        menuController.isValidated[variationIndex] =
                                                                            false;
                                                                        showValidateError =
                                                                            false;
                                                                        menuController
                                                                            .update();
                                                                      },
                                                                      borderColor:
                                                                          ColorTheme
                                                                              .grey8C,
                                                                      selectedBorderColor:
                                                                          ColorTheme
                                                                              .greenColor,
                                                                      fillColor: ColorTheme
                                                                          .greenColor
                                                                          .withOpacity(
                                                                              0.1),
                                                                      selectedColor:
                                                                          ColorTheme
                                                                              .greenColor,
                                                                      color: ColorTheme
                                                                          .foodValue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      children: const [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal: 15.0,
                                                                              vertical: 5),
                                                                          child:
                                                                              Text('Single'),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal: 15.0,
                                                                              vertical: 5),
                                                                          child:
                                                                              Text('Multiple'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    (Platform.isAndroid ||
                                                                            Platform.isIOS)
                                                                        ? 5.width
                                                                        : 20.width,
                                                                    Checkbox(
                                                                      activeColor:
                                                                          ColorTheme
                                                                              .greenColor,
                                                                      value: variation[
                                                                              "required"] ==
                                                                          "on",
                                                                      onChanged:
                                                                          (value) {
                                                                        variation[
                                                                            "required"] = value ==
                                                                                true
                                                                            ? "on"
                                                                            : "off";
                                                                        menuController.isValidated[variationIndex] =
                                                                            false;
                                                                        showValidateError =
                                                                            false;
                                                                        menuController
                                                                            .update();
                                                                      },
                                                                    ),
                                                                    Text(
                                                                        AppString
                                                                            .required,
                                                                        style: AppStyle
                                                                            .txt14FoodValue),
                                                                    Spacer(),
                                                                    IconButton(
                                                                      icon: SvgPicture.asset(
                                                                          Images
                                                                              .deleteIcon,
                                                                          width:
                                                                              18,
                                                                          height:
                                                                              18),
                                                                      onPressed:
                                                                          () {
                                                                        menuController
                                                                            .removeVariationAt(variationIndex);
                                                                        menuController
                                                                            .update();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              isMultiple
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              0.0,
                                                                          vertical:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                CustomTextformField(
                                                                              onChanged: (value) {
                                                                                menuController.isValidated[variationIndex] = false;
                                                                                showValidateError = false;
                                                                                menuController.update();
                                                                              },
                                                                              labelText: AppString.min,
                                                                              controller: variation["minController"],
                                                                              keyboardType: TextInputType.number,
                                                                              autovalidateMode: AutovalidateMode.disabled,
                                                                              errorStyle: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.red, fontSize: 9),
                                                                              errorBorder: AppBorder.errorBorder,
                                                                              focusedErrorBorder: AppBorder.errorBorder,
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return AppString.pleaseEnterMin;
                                                                                }
                                                                                final minVal = int.tryParse(value) ?? 0;
                                                                                final maxVal = int.tryParse(variation["maxController"].text) ?? 0;

                                                                                if (minVal <= 0) {
                                                                                  return AppString.ValueMustBeGreaterThanOrEqualTo;
                                                                                }

                                                                                if (minVal == 1 && maxVal == 1) {
                                                                                  return "Max must be greater than Min";
                                                                                }

                                                                                if (maxVal != 0 && minVal > maxVal) {
                                                                                  return "Min cannot be greater than Max";
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),
                                                                          ),
                                                                          10.width,
                                                                          Expanded(
                                                                            child:
                                                                                CustomTextformField(
                                                                              labelText: AppString.max,
                                                                              controller: variation["maxController"],
                                                                              keyboardType: TextInputType.number,
                                                                              autovalidateMode: AutovalidateMode.disabled,
                                                                              errorStyle: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.red, fontSize: 9),
                                                                              errorBorder: AppBorder.errorBorder,
                                                                              focusedErrorBorder: AppBorder.errorBorder,
                                                                              onChanged: (value) {
                                                                                final maxVal = int.tryParse(value) ?? 0;
                                                                                if (maxVal > 0) {
                                                                                  while (variation["options"].length < maxVal) {
                                                                                    variation["options"].add({
                                                                                      "optionNameController": TextEditingController(),
                                                                                      "priceController": TextEditingController(),
                                                                                    });
                                                                                  }
                                                                                  while (variation["options"].length > maxVal) {
                                                                                    variation["options"].removeLast();
                                                                                  }
                                                                                  menuController.isValidated[variationIndex] = false;
                                                                                  showValidateError = false;
                                                                                  menuController.update();
                                                                                }
                                                                              },
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return AppString.pleaseEnterMax;
                                                                                }

                                                                                final maxVal = int.tryParse(value) ?? 0;
                                                                                final minVal = int.tryParse(variation["minController"].text) ?? 0;

                                                                                if (maxVal <= 0) {
                                                                                  return AppString.ValueMustBeGreaterThanOrEqualTo;
                                                                                }

                                                                                if (minVal == 1 && maxVal == 1) {
                                                                                  return "Max must be greater than Min";
                                                                                }

                                                                                if (maxVal < minVal) {
                                                                                  return "Max must be greater than Min";
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                              5.height,
                                                              Divider(
                                                                  color: Colors
                                                                      .grey,
                                                                  height: 30,
                                                                  thickness: 1),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0),
                                                                child: Column(
                                                                  children: [
                                                                    for (int optionIndex =
                                                                            0;
                                                                        optionIndex <
                                                                            variation["options"].length;
                                                                        optionIndex++)
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Container(
                                                                                child: CustomTextformField(
                                                                                  onChanged: (value) {
                                                                                    menuController.isValidated[variationIndex] = false;
                                                                                    showValidateError = false;
                                                                                    menuController.update();
                                                                                  },
                                                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                  errorBorder: AppBorder.errorBorder,
                                                                                  focusedErrorBorder: AppBorder.errorBorder,
                                                                                  errorStyle: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.red, fontSize: 9),
                                                                                  validator: (value) {
                                                                                    if (value == null || value.trim().isEmpty) {
                                                                                      return AppString.pleaseEnterOptionName;
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  labelText: AppString.optionName,
                                                                                  controller: variation["options"][optionIndex]["optionNameController"],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            10.width,
                                                                            Expanded(
                                                                              child: Container(
                                                                                child: CustomTextformField(
                                                                                  onChanged: (value) {
                                                                                    menuController.isValidated[variationIndex] = false;
                                                                                    showValidateError = false;
                                                                                    menuController.update();
                                                                                  },
                                                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                  errorBorder: AppBorder.errorBorder,
                                                                                  focusedErrorBorder: AppBorder.errorBorder,
                                                                                  errorStyle: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.red, fontSize: 9),
                                                                                  validator: (value) {
                                                                                    if (value == null || value.trim().isEmpty) {
                                                                                      return AppString.pleaseEnterPrice;
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                                  labelText: AppString.additionalPrice,
                                                                                  controller: variation["options"][optionIndex]["priceController"],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (variation["options"].length >
                                                                                1)
                                                                              IconButton(
                                                                                icon: SvgPicture.asset(Images.deleteIcon, width: 18, height: 18),
                                                                                onPressed: () {
                                                                                  variation["options"].removeAt(optionIndex);
                                                                                  if (isMultiple) {
                                                                                    variation["maxController"].text = variation["options"].length.toString();
                                                                                  }
                                                                                  menuController.isValidated[variationIndex] = false;
                                                                                  showValidateError = false;
                                                                                  menuController.update();
                                                                                },
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    5.height,
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              variation["options"].add({
                                                                                "optionNameController": TextEditingController(),
                                                                                "priceController": TextEditingController(),
                                                                              });
                                                                              if (isMultiple) {
                                                                                variation["maxController"].text = variation["options"].length.toString();
                                                                              }
                                                                              menuController.isValidated[variationIndex] = false;
                                                                              showValidateError = false;
                                                                              menuController.update();
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Icon(Icons.add_circle_outline, color: ColorTheme.grey),
                                                                                13.width,
                                                                                Text(
                                                                                  AppString.addNewOptions,
                                                                                  style: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.greenColor),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            style:
                                                                                OutlinedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(30),
                                                                              ),
                                                                              padding: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (menuController.formKeys[variationIndex].currentState!.validate()) {
                                                                                menuController.isValidated[variationIndex] = true;
                                                                                print('Adding new variation. Variations: ${menuController.variations.length}, formKeys: ${menuController.formKeys.length}, _isValidated: ${menuController.isValidated.length}');
                                                                                print('${menuController.variations.isEmpty} ...${menuController.isValidated.every((validated) => validated)}');
                                                                                menuController.update();
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              'Validate',
                                                                              style: AppStyle.txt14FoodValue.copyWith(color: ColorTheme.greenColor),
                                                                            ),
                                                                            style:
                                                                                OutlinedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(30),
                                                                              ),
                                                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              5.height,
                                                              Divider(
                                                                  color: Colors
                                                                      .grey,
                                                                  height: 1,
                                                                  thickness: 1),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, bottom: 0, top: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              OutlinedButton(
                                                onPressed: menuController
                                                            .variations
                                                            .isEmpty ||
                                                        menuController
                                                            .isValidated
                                                            .every(
                                                                (validated) =>
                                                                    validated)
                                                    ? () {
                                                        menuController
                                                            .addVariationWithValidation();
                                                        showValidateError =
                                                            false;
                                                        menuController.update();
                                                      }
                                                    : () {
                                                        showValidateError =
                                                            true;
                                                        menuController.update();
                                                      },
                                                child: Text(
                                                  AppString.addNewVariation,
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                    color:
                                                        ColorTheme.greenColor,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                      color:
                                                          ColorTheme.greenColor,
                                                      width: 1.5),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 14),
                                                ),
                                              ),
                                              if (showValidateError &&
                                                  !menuController.isValidated
                                                      .every((validated) =>
                                                          validated))
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Builder(
                                                    builder: (context) {
                                                      final invalidIndex =
                                                          menuController
                                                              .isValidated
                                                              .indexWhere(
                                                                  (v) => !v);
                                                      if (invalidIndex != -1) {
                                                        final humanIndex =
                                                            invalidIndex + 1;
                                                        return Text(
                                                          'Please validate variation $humanIndex',
                                                          style: montserratMedium
                                                              .copyWith(
                                                                  color:
                                                                      ColorTheme
                                                                          .red,
                                                                  fontSize: 10),
                                                        );
                                                      }
                                                      return SizedBox();
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Food Addons Panel
                                ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  value: 2,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                            Images.food_varations),
                                      ),
                                      title: Text(
                                        AppString.foodAddons,
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    );
                                  },
                                  body: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (menuController
                                            .addonMyList.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 18),
                                            child: Wrap(
                                              spacing: 8.0,
                                              children: menuController
                                                  .addonMyList
                                                  .map(
                                                    (item) => Transform(
                                                      transform:
                                                          new Matrix4.identity()
                                                            ..scale(0.9),
                                                      child: Chip(
                                                        backgroundColor:
                                                            ColorTheme
                                                                .whiteColor,
                                                        label: Text(item.name
                                                            .toString()),
                                                        deleteIcon:
                                                            Icon(Icons.close),
                                                        onDeleted: () {
                                                          menuController
                                                              .addonMyList
                                                              .removeWhere(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      item.id);
                                                          menuController
                                                              .update();
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        5.height,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Autocomplete<String>(
                                                optionsBuilder:
                                                    (TextEditingValue
                                                        textEditingValue) {
                                                  if (textEditingValue
                                                      .text.isEmpty) {
                                                    return const Iterable<
                                                        String>.empty();
                                                  }

                                                  final suggestions = menuController
                                                      .addonList
                                                      .where((element) => element[
                                                              "name"]
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(
                                                              textEditingValue
                                                                  .text
                                                                  .toLowerCase()))
                                                      .map((e) =>
                                                          e["name"].toString())
                                                      .toSet()
                                                      .toList();
                                                  if (suggestions.isEmpty) {
                                                    menuController
                                                        .addonAddTextEditingController
                                                        .clear();
                                                    setState(() {});
                                                    appToast(AppString
                                                        .noAddonsAvailable);
                                                  }

                                                  return suggestions;
                                                },
                                                onSelected: (String selection) {
                                                  menuController
                                                      .addonAddTextEditingController
                                                      .text = selection;

                                                  final selectedAddon =
                                                      menuController.addonList
                                                          .firstWhere(
                                                    (addon) =>
                                                        addon["name"]
                                                            .toString()
                                                            .toLowerCase() ==
                                                        selection.toLowerCase(),
                                                  );
                                                  final selectedId =
                                                      selectedAddon["id"];
                                                  if (!menuController
                                                      .addonMyList
                                                      .any((element) =>
                                                          element.id ==
                                                          selectedId)) {
                                                    menuController.addonMyList
                                                        .add(AddonsModel(
                                                            id: selectedId,
                                                            name: selectedAddon[
                                                                "name"]));

                                                    menuController
                                                        .addonAddTextEditingController
                                                        .clear();
                                                  } else {
                                                    appToast(AppString
                                                        .alreadyDataExits);

                                                    menuController
                                                        .addonAddTextEditingController
                                                        .clear();
                                                  }
                                                  menuController.update();
                                                },
                                                fieldViewBuilder: (
                                                  BuildContext context,
                                                  TextEditingController
                                                      textEditingController,
                                                  FocusNode focusNode,
                                                  VoidCallback onFieldSubmitted,
                                                ) {
                                                  textEditingController.text =
                                                      menuController
                                                          .addonAddTextEditingController
                                                          .text;

                                                  return TextFormField(
                                                    style:
                                                        AppStyle.txt14FoodValue,
                                                    controller:
                                                        textEditingController,
                                                    focusNode: focusNode,
                                                    decoration: InputDecoration(
                                                      hintText: AppString
                                                          .typeAddonsHere,
                                                      hintStyle: AppStyle
                                                          .txt14FoodValue,
                                                      isDense: true,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 10,
                                                              horizontal: 12),
                                                      border: AppBorder
                                                          .whiteDcAddonsBorder,
                                                      enabledBorder: AppBorder
                                                          .whiteDcAddonsBorder,
                                                      focusedBorder: AppBorder
                                                          .whiteDcAddonsBorder,
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return AppString
                                                            .pleaseEnterAddonsHere;
                                                      }
                                                      return null;
                                                    },
                                                  );
                                                },
                                                optionsViewBuilder: (
                                                  BuildContext context,
                                                  AutocompleteOnSelected<String>
                                                      onSelected,
                                                  Iterable<String> options,
                                                ) {
                                                  return Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Material(
                                                      elevation: 4.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxHeight: 150,
                                                                minWidth: 175),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: ColorTheme
                                                                .whiteColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          child:
                                                              ListView.builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemCount:
                                                                options.length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              final String
                                                                  option =
                                                                  options
                                                                      .elementAt(
                                                                          index);
                                                              return InkWell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      option,
                                                                      style: AppStyle
                                                                          .txt14FoodValue),
                                                                ),
                                                                onTap: () {
                                                                  onSelected(
                                                                      option);
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            10.width,
                                            GestureDetector(
                                              onTap: () {
                                                addAddonsSheet(
                                                  context,
                                                  menuController,
                                                  onTap: menuController
                                                          .isAddonsSubmitting
                                                          .value
                                                      ? null
                                                      : () async {
                                                          if (menuController
                                                              .addAddonsFormKey
                                                              .currentState!
                                                              .validate()) {
                                                            await menuController
                                                                .addAddons();
                                                          }
                                                        },
                                                  menuAddons: {},
                                                );
                                              },
                                              child: Icon(
                                                  Icons.add_circle_outline,
                                                  size: 34,
                                                  color: ColorTheme.grey8C),
                                            )
                                          ],
                                        ).paddingOnly(
                                            bottom: 10, right: 18, left: 15),
                                      ],
                                    ),
                                  ),
                                ),

                                // Food Details Panel (Merged with Food Tax & Charges)
                                ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  value: 3,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                            Images.food_details),
                                      ),
                                      title: Text(
                                        AppString.foodDetails,
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    );
                                  },
                                  body: Column(
                                    children: [
                                      5.height,
                                      Divider(
                                          color: ColorTheme.whiteE4,
                                          thickness: 1,
                                          height: 1),
                                      15.height,
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDropdownWidget(
                                            labelText: 'Discount Type',
                                            items: menuController
                                                .discountTypeList
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value == 'Percent'
                                                      ? 'Percent'
                                                      : 'Flat',
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                          color: ColorTheme
                                                              .foodValue
                                                              .withOpacity(.7)),
                                                ),
                                              );
                                            }).toList(),
                                            value: menuController.selectDiscount
                                                    .value.isNotEmpty
                                                ? menuController.selectDiscount
                                                            .value ==
                                                        "amount"
                                                    ? "Flat"
                                                    : menuController
                                                        .capitalizeFirstLetter(
                                                            menuController
                                                                .selectDiscount
                                                                .value)
                                                : null,
                                            hintText: AppString.discountType,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                menuController.selectDiscount
                                                    .value = newValue!;
                                              });
                                            },
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: AppString.discount,
                                                controller: menuController
                                                    .discountAmount,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      25.height,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: AppString
                                                    .availableTimeStarts,
                                                readOnly: true,
                                                controller: menuController
                                                    .startDateController,
                                                onTap: () async {
                                                  TimeOfDay? pickedTime =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );

                                                  if (pickedTime != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime =
                                                        DateFormat('HH:mm:ss')
                                                            .format(
                                                      DateTime(
                                                        now.year,
                                                        now.month,
                                                        now.day,
                                                        pickedTime.hour,
                                                        pickedTime.minute,
                                                      ),
                                                    );

                                                    setState(() {
                                                      menuController
                                                          .startDateController
                                                          .text = formattedTime;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                  color: ColorTheme.transparent,
                                                ),
                                              ),
                                              child: CustomTextformField(
                                                labelText:
                                                    AppString.availableTimeEnds,
                                                controller: menuController
                                                    .expireDateController,
                                                readOnly: true,
                                                onTap: () async {
                                                  TimeOfDay? pickedTime =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );

                                                  if (pickedTime != null) {
                                                    final now = DateTime.now();
                                                    final formattedTime =
                                                        DateFormat('HH:mm:ss')
                                                            .format(
                                                      DateTime(
                                                        now.year,
                                                        now.month,
                                                        now.day,
                                                        pickedTime.hour,
                                                        pickedTime.minute,
                                                      ),
                                                    );

                                                    setState(() {
                                                      menuController
                                                          .expireDateController
                                                          .text = formattedTime;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      25.height,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: CustomTextformField(
                                                labelText: AppString
                                                    .preparationTimeMin,
                                                controller: menuController
                                                    .preparationTime,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              child: CustomTextformField(
                                                labelText:
                                                    AppString.serveTimeMin,
                                                controller:
                                                    menuController.serverTime,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.height,

                                      // Tax and charges fields merged from Food Tax & Charges section
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDropdownWidget(
                                            labelText: 'Given Discount',
                                            items:
                                                menuController.GivenDiscountList
                                                    .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                          color: ColorTheme
                                                              .foodValue
                                                              .withOpacity(.7)),
                                                ),
                                              );
                                            }).toList(),
                                            value: menuController
                                                    .selectedGivenDiscount
                                                    .value
                                                    .isNotEmpty
                                                ? menuController
                                                    .capitalizeFirstLetter(
                                                        menuController
                                                            .selectedGivenDiscount
                                                            .value)
                                                : null,
                                            hintText: 'Given Discount',
                                            onChanged: (String? newValue) {
                                              menuController
                                                  .selectedGivenDiscount
                                                  .value = newValue!;
                                              menuController.update();
                                              print(
                                                  "Given Discount ${menuController.selectedGivenDiscount.value}");
                                            },
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: "Packaging Charge",
                                                controller: menuController
                                                    .packagingCharge,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      if (widget.menuFoodFor != "Aggregator")
                                        10.height,
                                      if (widget.menuFoodFor != "Aggregator")
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Container(
                                                  width: Platform.isWindows
                                                      ? 400
                                                      : 200,
                                                  child: CustomTextformField(
                                                    labelText:
                                                        "Delivery Charge",
                                                    controller: menuController
                                                        .deliveryCharge,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Container(
                                                  width: Platform.isWindows
                                                      ? 400
                                                      : 200,
                                                  child: CustomTextformField(
                                                    labelText:
                                                        "Takeaway Charge",
                                                    controller: menuController
                                                        .takeawayCharge,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (widget.menuFoodFor !=
                                          "Aggregator") ...[
                                        20.height,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GetBuilder<
                                                  MenuManagementController>(
                                                builder: (controller) {
                                                  return DropdownButtonFormField2<
                                                      String>(
                                                    isExpanded:
                                                        true, // 1. Ensures the dropdown fills the width and handles layout better
                                                    value: null,
                                                    hint: Text(
                                                      controller
                                                          .getSelectedAllergensDisplayText(),
                                                      style: montserratMedium
                                                          .copyWith(
                                                        fontSize: 13,
                                                        color: controller
                                                                .selectedAllergens
                                                                .isEmpty
                                                            ? ColorTheme.grey8C
                                                                .withOpacity(.5)
                                                            : ColorTheme.grey8C,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    // 2. Fix the Icon not showing
                                                    iconStyleData:
                                                        const IconStyleData(
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded, // Standard dropdown icon
                                                        color: Colors.black45,
                                                      ),
                                                      iconSize: 24,
                                                    ),

                                                    // 3. Fix Vertical Alignment & Borders
                                                    decoration: InputDecoration(
                                                      isDense:
                                                          true, // Helps with vertical centering
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              top: 10,
                                                              left: 10,
                                                              right: 10,
                                                              bottom: 10),
                                                      labelText: 'Allergens',
                                                      labelStyle: AppStyle
                                                          .txt14FoodValue
                                                          .copyWith(
                                                        color: ColorTheme.black,
                                                        fontSize: 15,
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      // hintText: controller
                                                      //     .getSelectedAllergensDisplayText(),
                                                      // hintStyle: AppStyle
                                                      //     .txt14FoodValue
                                                      //     .copyWith(
                                                      //   color: controller
                                                      //           .selectedAllergens
                                                      //           .isEmpty
                                                      //       ? ColorTheme.foodValue
                                                      //           .withOpacity(.5)
                                                      //       : ColorTheme
                                                      //           .foodValue,
                                                      // overflow: TextOverflow
                                                      //     .ellipsis, // Prevents text overflow issues
                                                      // ),
                                                      // Borders...
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFDCDCDC)),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFDCDCDC)),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFDCDCDC)),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFDCDCDC)),
                                                      ),
                                                    ),

                                                    items: controller
                                                        .allergenList
                                                        .map((allergen) {
                                                      final allergenName =
                                                          allergen["name"]
                                                              as String;
                                                      final allergenLabel =
                                                          allergen["label"]
                                                              as String;

                                                      // 4. Fix "Nothing Happened": Use StatefulBuilder for immediate visual updates
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: allergenName,
                                                        // Disable default tap to handle it manually (prevents menu closing on multi-select)
                                                        enabled: false,
                                                        child: StatefulBuilder(
                                                          builder: (context,
                                                              menuSetState) {
                                                            final isSelected =
                                                                controller
                                                                    .selectedAllergens
                                                                    .contains(
                                                                        allergenName);

                                                            return InkWell(
                                                              onTap: () {
                                                                // Update Controller Data
                                                                if (isSelected) {
                                                                  controller
                                                                      .selectedAllergens
                                                                      .remove(
                                                                          allergenName);
                                                                } else {
                                                                  controller
                                                                      .selectedAllergens
                                                                      .add(
                                                                          allergenName);
                                                                }
                                                                controller
                                                                    .update(); // Updates the Hint Text (Parent)
                                                                menuSetState(
                                                                    () {}); // Updates the Checkbox (Local Menu Item)
                                                              },
                                                              child: Container(
                                                                height: double
                                                                    .infinity,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                      child:
                                                                          Checkbox(
                                                                        value:
                                                                            isSelected,
                                                                        onChanged:
                                                                            (bool?
                                                                                value) {
                                                                          // Forward logic to InkWell onTap
                                                                          if (isSelected) {
                                                                            controller.selectedAllergens.remove(allergenName);
                                                                          } else {
                                                                            controller.selectedAllergens.add(allergenName);
                                                                          }
                                                                          controller
                                                                              .update();
                                                                          menuSetState(
                                                                              () {});
                                                                        },
                                                                        activeColor:
                                                                            ColorTheme.greenColor,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        allergenLabel,
                                                                        style: AppStyle
                                                                            .txt14FoodValue
                                                                            .copyWith(
                                                                          color: ColorTheme
                                                                              .foodValue
                                                                              .withOpacity(.7),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }).toList(),

                                                    onChanged: (String?
                                                        value) {}, // Not used in multi-select

                                                    buttonStyleData:
                                                        const ButtonStyleData(
                                                      height:
                                                          40, // Ensures consistent height matches decoration
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    dropdownStyleData:
                                                        DropdownStyleData(
                                                      maxHeight: 400,
                                                      offset:
                                                          const Offset(0, -5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFDCDCDC)),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    menuItemStyleData:
                                                        const MenuItemStyleData(
                                                      height: 45,
                                                      padding: EdgeInsets
                                                          .zero, // Remove padding so InkWell fills space
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            20.width,
                                            Expanded(
                                              child: Container(
                                                child: CustomTextformField(
                                                  labelText: 'Calorie',
                                                  controller: menuController
                                                      .caloriesController,
                                                  suffixText: 'kcal',
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      20.height,
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Obx(
                                          () => Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomSwitchWidget(
                                                value: menuController
                                                    .isDineIn.value,
                                                title: widget.menuFoodFor ==
                                                        "Aggregator"
                                                    ? AppString.swiggy
                                                    : AppString.dineIn,
                                                onChanged: (value) {
                                                  menuController
                                                      .isDineIn.value = value;
                                                },
                                              ),
                                              10.width,
                                              CustomSwitchWidget(
                                                value: menuController
                                                    .isDelivery.value,
                                                title: widget.menuFoodFor ==
                                                        "Aggregator"
                                                    ? AppString.zomato
                                                    : AppString.delivery,
                                                onChanged: (value) {
                                                  menuController
                                                      .isDelivery.value = value;
                                                },
                                              ),
                                              widget.menuFoodFor == "Aggregator"
                                                  ? 30.width
                                                  : 10.width,
                                              widget.menuFoodFor == "Aggregator"
                                                  ? SizedBox()
                                                  : CustomSwitchWidget(
                                                      value: menuController
                                                          .isTakeAway.value,
                                                      title: AppString.takeAway,
                                                      onChanged: (value) {
                                                        menuController
                                                            .isTakeAway
                                                            .value = value;
                                                      },
                                                    ),
                                              widget.menuFoodFor == "Aggregator"
                                                  ? 30.width
                                                  : 10.width,
                                              widget.menuFoodFor == "Aggregator"
                                                  ? SizedBox()
                                                  : CustomSwitchWidget(
                                                      value: menuController
                                                          .isLiveWeb.value,
                                                      title: 'Live on Web',
                                                      onChanged: (value) {
                                                        menuController.isLiveWeb
                                                            .value = value;
                                                      },
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      20.height,
                                      // Food Image Section moved here
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(AppString.foodImage,
                                              style: AppStyle.stockListStyle
                                                  .copyWith(
                                                      color:
                                                          ColorTheme.foodValue,
                                                      fontSize: 18)),
                                        ),
                                      ),
                                      20.height,
                                      buildFoodImageSection(context),
                                      15.height,
                                    ],
                                  ),
                                ),

                                // Food Tax & Charge Panel - COMMENTED OUT
                                /*
                                ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  value: 4,
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SvgPicture.asset(
                                            Images.food_varations),
                                      ),
                                      title: Text(
                                        'Food Tax & Charge',
                                        style: TextStyle(
                                          color: ColorTheme.foodValue,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                    );
                                  },
                                  body: Column(
                                    children: [
                                      5.height,
                                      Divider(
                                          color: ColorTheme.whiteE4,
                                          thickness: 1,
                                          height: 1),
                                      15.height,
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDropdownWidget(
                                            items: menuController.taxTypeList
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                          color: ColorTheme
                                                              .foodValue
                                                              .withOpacity(.7)),
                                                ),
                                              );
                                            }).toList(),
                                            value: menuController
                                                    .selectedTaxType
                                                    .value
                                                    .isNotEmpty
                                                ? menuController
                                                    .capitalizeFirstLetter(
                                                        menuController
                                                            .selectedTaxType
                                                            .value)
                                                : null,
                                            hintText: 'Tax Type',
                                            onChanged:
                                                Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .resturantGst ==
                                                        'restaurant'
                                                    ? null
                                                    : (String? newValue) {
                                                        menuController
                                                            .selectedTaxType
                                                            .value = newValue!;
                                                        menuController.update();
                                                        print(
                                                            "selectedTaxType ${menuController.selectedTaxType.value}");
                                                      },
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: 'Tax',
                                                controller: menuController
                                                    .taxController,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      25.height,
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDropdownWidget(
                                            items:
                                                menuController.GivenDiscountList
                                                    .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: AppStyle.txt14FoodValue
                                                      .copyWith(
                                                          color: ColorTheme
                                                              .foodValue
                                                              .withOpacity(.7)),
                                                ),
                                              );
                                            }).toList(),
                                            value: menuController
                                                    .selectedGivenDiscount
                                                    .value
                                                    .isNotEmpty
                                                ? menuController
                                                    .capitalizeFirstLetter(
                                                        menuController
                                                            .selectedGivenDiscount
                                                            .value)
                                                : null,
                                            hintText: 'Given Discount',
                                            onChanged: (String? newValue) {
                                              menuController
                                                  .selectedGivenDiscount
                                                  .value = newValue!;
                                              menuController.update();
                                              print(
                                                  "Given Discount ${menuController.selectedGivenDiscount.value}");
                                            },
                                          ),
                                          20.width,
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                labelText: "Packaging Charge",
                                                controller: menuController
                                                    .packagingCharge,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      if (widget.menuFoodFor != "Aggregator")
                                        10.height,
                                      if (widget.menuFoodFor != "Aggregator")
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Container(
                                                  width: Platform.isWindows
                                                      ? 400
                                                      : 200,
                                                  child: CustomTextformField(
                                                    labelText:
                                                        "Delivery Charge",
                                                    controller: menuController
                                                        .deliveryCharge,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Container(
                                                  width: Platform.isWindows
                                                      ? 400
                                                      : 200,
                                                  child: CustomTextformField(
                                                    labelText:
                                                        "Takeaway Charge",
                                                    controller: menuController
                                                        .takeawayCharge,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      15.height,
                                    ],
                                  ),
                                ),
                                */
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              15.height,
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        menuController?.resetData();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: ColorTheme.greyColor.withOpacity(.2)),
                        alignment: Alignment.center,
                        child: Text(AppString.Reset),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: menuController!.isSubmitting
                            ? null
                            : () async {
                                if (menuController!.productName.text
                                    .trim()
                                    .isEmpty) {
                                  menuController!.isNameValid.value = true;
                                  return;
                                } else {
                                  menuController!.isNameValid.value = false;
                                }
                                if (menuController!.categoryIndex == null) {
                                  menuController!.isCategoryValid.value = true;
                                  return;
                                } else {
                                  menuController!.isCategoryValid.value = false;
                                }
                                if (menuController!.menuPrice.text
                                    .trim()
                                    .isEmpty) {
                                  menuController!.isPriceValid.value = true;
                                  return;
                                } else {
                                  menuController!.isPriceValid.value = false;
                                }

                                bool isValid = true;

                                for (int i = 0;
                                    i < menuController!.formKeys.length;
                                    i++) {
                                  final formKey = menuController!.formKeys[i];
                                  if (formKey.currentState != null &&
                                      !formKey.currentState!.validate()) {
                                    isValid = false;
                                  }
                                }

                                if (!isValid) {
                                  print("Form is not valid, show errors.");
                                  return;
                                }

                                print(
                                    "All forms are valid. Proceed with submission.");

                                menuController?.catSearchDataReset();
                                await menuController?.onSubmitFood(
                                    isEdit: widget.isEdit,
                                    id: widget.food["id"]);
                              },
                        child: Container(
                          height: 50,
                          decoration:
                              BoxDecoration(color: ColorTheme.greenColor),
                          alignment: Alignment.center,
                          child: menuController!.isSubmitLoader.value
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
      ),
    );
  }

  Widget buildFoodImageSection(BuildContext context) {
    if (widget.menuFoodFor != "Aggregator") {
      // ---------- Normal Single Picker ----------
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 00.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(
              title: "Food Image",
              file: menuController?.imageFile != null
                  ? File(menuController!.imageFile!.path)
                  : null,
              networkPath: menuController?.imagePath,
              defaultAsset: Images.food_image,
            ),
            10.height,
            _buildFilePickerRow(
              fileName: menuController?.imageFileName,
              onBrowse: () => menuController?.pickImageFromGallery(),
            ),
          ],
        ),
      );
    } else {
      // ---------- Aggregator (Swiggy + Zomato) ----------
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swiggy
            Expanded(
              child: _buildAggregatorBlock(
                context,
                title: "Swiggy Image",
                file: menuController?.swiggyImageFile != null
                    ? File(menuController!.swiggyImageFile!.path)
                    : null,
                fileName: menuController?.swiggyFileName,
                networkPath: menuController?.swiggyImagePath,
                onBrowse: () => menuController?.pickSwiggyImage(),
                infoPoints: [
                  "Format: JPG only.",
                  "File size: max 5 MB.",
                  "Aspect ratio: 17:13 (2720 x 2080 px).",
                  "Good lighting quality, centrally aligned.",
                  "Avoid watermarks or text.",
                ],
              ),
            ),
            20.width,
            // Zomato
            Expanded(
              child: _buildAggregatorBlock(
                context,
                title: "Zomato Image",
                file: menuController?.zomatoImageFile != null
                    ? File(menuController!.zomatoImageFile!.path)
                    : null,
                fileName: menuController?.zomatoFileName,
                networkPath: menuController?.zomatoImagePath,
                onBrowse: () => menuController?.pickZomatoImage(),
                infoPoints: [
                  "Format: PNG or JPG.",
                  "File size: below 20 MB.",
                  "Dimensions: 1024 x 768 px.",
                  "Use only original food images.",
                  "No blurry or cropped photos.",
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  /// ---------- Aggregator Block ----------
  Widget _buildAggregatorBlock(
    BuildContext context, {
    required String title,
    required File? file,
    required String? fileName,
    required String? networkPath,
    required VoidCallback onBrowse,
    required List<String> infoPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Info Icon
        Row(
          children: [
            Text(title,
                style: AppStyle.stockListStyle
                    .copyWith(color: ColorTheme.foodValue, fontSize: 15)),
            8.width,
            InkWell(
              onTap: () => _showInfoDialog(context, title, infoPoints),
              child: Icon(Icons.info_outline, color: ColorTheme.foodValue),
            ),
          ],
        ),
        10.height,
        // Preview
        _buildImagePreview(
          title: title,
          file: file,
          networkPath: networkPath,
          defaultAsset: Images.food_image,
        ),
        10.height,
        // File Picker Row
        _buildFilePickerRow(
          fileName: fileName,
          onBrowse: onBrowse,
        ),
      ],
    );
  }

  /// ---------- Image Preview ----------
  Widget _buildImagePreview({
    required String title,
    required File? file,
    required String? networkPath,
    required String defaultAsset,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: file != null
              ? Image.file(file, fit: BoxFit.cover)
              : (networkPath != null && networkPath.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: networkPath,
                      placeholder: (c, url) => CupertinoActivityIndicator(),
                      errorWidget: (c, url, e) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    )
                  : Image.asset(defaultAsset, fit: BoxFit.cover),
        ),
      ),
    );
  }

  /// ---------- File Picker Row ----------
  Widget _buildFilePickerRow({
    required String? fileName,
    required VoidCallback onBrowse,
  }) {
    return Container(
      height: 53,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ColorTheme.whiteDC),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                width: 180,
                child: Text(
                  fileName ?? AppString.chooseFile,
                  style: AppStyle.stockListStyle.copyWith(
                    fontSize: 15,
                    color: ColorTheme.foodValue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: InkWell(
              onTap: onBrowse,
              child: Container(
                width: 180,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  AppString.browse,
                  style: AppStyle.stockListStyle.copyWith(
                    fontSize: 15,
                    color: ColorTheme.foodValue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ---------- Info Dialog ----------
  void _showInfoDialog(
      BuildContext context, String title, List<String> points) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: AppStyle.stockListStyle
                      .copyWith(color: ColorTheme.foodValue, fontSize: 18)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map((e) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ",
                            style: TextStyle(
                                fontSize: 16, color: ColorTheme.foodValue)),
                        Expanded(
                            child: Text(e,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: ColorTheme.foodValue))),
                      ],
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
