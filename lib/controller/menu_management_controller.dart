import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/addon_list_model.dart';
import 'package:mygenie_restaurant/data/model/response/menu_food_list_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/model/response/category_model.dart';
import '../data/repository/menu_management_repo.dart';

class MenuManagementController extends GetxController implements GetxService {
  final MenuManagementRepo menuManagementRepo;
  MenuManagementController({required this.menuManagementRepo});
  TextEditingController addonName = TextEditingController();
  TextEditingController addonPrice = TextEditingController();
  List<CategoryModel> _categoryList = [];
  AddonListModel? _addonList;
  MenuFoodListModel? _menuFoodList;

  List<CategoryModel> get categoryList => _categoryList;
  AddonListModel? get addonList => _addonList;
  MenuFoodListModel? get menuFoodList => _menuFoodList;
  int? selectedItem;
  List<dynamic> selectedItems = [];

  // ---------------------------------
  final TextEditingController productName = TextEditingController();
  final TextEditingController menuPrice = TextEditingController();
  final TextEditingController discountAmount = TextEditingController();
  final TextEditingController foodOrder = TextEditingController();
  final TextEditingController preparationTime = TextEditingController();
  final TextEditingController serverTime = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController expireDateController = TextEditingController();
  final TextEditingController choiceName = TextEditingController();
  final TextEditingController minFood = TextEditingController();
  final TextEditingController maxFood = TextEditingController();
  List<Map<String, dynamic>> variations = [
    MenuManagementController.createNewVariation(),
  ];

  static Map<String, dynamic> createNewVariation() {
    return {
      "nameController": TextEditingController(),
      "selectionType": "multi",
      "minController": TextEditingController(),
      "maxController": TextEditingController(),
      "isRequired": false,
      "options": [
        {
          "optionNameController": TextEditingController(),
          "priceController": TextEditingController()
        }
      ],
    };
  }

  bool isToggled = false;
  bool isDineIn = false;
  bool isDelivery = false;
  bool isTakeAway = false;
  bool isRequired = false;
  String selectedValue = 'Food For';
  String selectDiscount = 'Select Discount';
  String selectedOption = 'Multiple';
  // ---------------------------------

  Future<void> getMenuFoodList() async {
    Response response = await menuManagementRepo.getMenuFoodList();
    if (response.statusCode == 200) {
      _menuFoodList = MenuFoodListModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getMenuCategoryList() async {
    _categoryList = [];
    Response response = await menuManagementRepo.getCategoryList();
    if (response.statusCode == 200) {
      for (var category in response.body) {
        _categoryList.add(CategoryModel(
            id: category['id'],
            name: category['name'].toString().toUpperCase()));
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> postFoodList(Map<String, dynamic> jsonBody) async {
    Response response = await menuManagementRepo.addFoodList(jsonBody);
    if (response.statusCode == 200) {
      showCustomSnackBar('food_added_successfully'.tr, isError: false);
      Get.back();
      getMenuFoodList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> updateFood(int foodID, Map<String, dynamic> jsonBody) async {
    Response response =
        await menuManagementRepo.updateFoodList(foodID, jsonBody);
    if (response.statusCode == 200) {
      showCustomSnackBar('food_updated_successfully'.tr, isError: false);
      Get.back();
      getMenuFoodList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> deleteFood(int foodID) async {
    Response response = await menuManagementRepo.deleteMenuFoodList(foodID);
    if (response.statusCode == 200) {
      showCustomSnackBar('food_removed_successfully'.tr, isError: false);
      getMenuFoodList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getAddonList() async {
    Response response = await menuManagementRepo.getAddonList();
    if (response.statusCode == 200) {
      _addonList = AddonListModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  postAddonBottomSheet() {
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
          color: Colors.white),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25,
              right: 25,
              top: 30,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  controller: addonName,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Add addon name',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: addonPrice,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Add addon price',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> jsonBody = {
                      'name': addonName.text,
                      'price': int.tryParse(addonPrice.text) ?? 0,
                    };
                    Get.back();
                    Get.find<MenuManagementController>()
                        .postAddonList(jsonBody);
                    addonName.clear();
                    addonPrice.clear();
                  },
                  child: const Text("Add Addon"),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> postAddonList(Map<String, dynamic> jsonBody) async {
    Response response = await menuManagementRepo.addAddonList(jsonBody);
    if (response.statusCode == 200) {
      showCustomSnackBar('addon_added_successfully'.tr, isError: false);
      getAddonList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  updateAddonBottomSheet(Addons addon) {
    TextEditingController nameController =
        TextEditingController(text: addon.name);
    TextEditingController priceController =
        TextEditingController(text: addon.price.toString());
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
          color: Colors.white),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25,
              right: 25,
              top: 30,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'Addon Name',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: priceController,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Addon Price',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> jsonBody = {
                      'name': nameController.text,
                      'price':
                          int.tryParse(priceController.text) ?? addon.price,
                    };
                    Get.back();
                    Get.find<MenuManagementController>()
                        .updateAddon(addon.id, jsonBody);
                  },
                  child: const Text("Edit Addon"),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> updateAddon(int addonID, Map<String, dynamic> jsonBody) async {
    Response response = await menuManagementRepo.updateAddon(addonID, jsonBody);
    if (response.statusCode == 200) {
      showCustomSnackBar('addon_updated_successfully'.tr, isError: false);
      getAddonList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> deleteAddon(int addonID) async {
    Response response = await menuManagementRepo.deleteAddonList(addonID);
    if (response.statusCode == 200) {
      showCustomSnackBar('addon_removed_successfully'.tr, isError: false);
      getAddonList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
