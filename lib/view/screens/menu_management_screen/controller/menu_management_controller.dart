import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/get_storage/get_storage.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/menu_management_repo/menu_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/model/addons_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MenuManagementController extends GetxController implements GetxService {
  final MenuManagementRepo menuManagementRepo;
  MenuManagementController({required this.menuManagementRepo});

  GlobalKey<FormState> minMaxFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addAddonsFormKey = GlobalKey<FormState>();

  // Controllers for text fields
  TextEditingController addonAddTextEditingController = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController menuPrice = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  TextEditingController foodOrder = TextEditingController();
  TextEditingController preparationTime = TextEditingController();
  TextEditingController serverTime = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController addonName = TextEditingController();
  TextEditingController addonPrice = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController deliveryCharge = TextEditingController();
  TextEditingController packagingCharge = TextEditingController();
  TextEditingController takeawayCharge = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController newCategoryAddController = TextEditingController();
  TextEditingController itemCodeController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  ScrollController foodScrollController = ScrollController();

  RxBool isCurrentStocksScreenOpen = false.obs;
  RxBool isDrawerOpen = false.obs;
  RxBool isSubmitLoader = false.obs;
  RxBool isNameValid = false.obs;
  RxBool isCategoryValid = false.obs;
  RxBool isPriceValid = false.obs;
  RxBool isFoodDelete = false.obs;
  RxBool isDeleteFoodSubmitting = false.obs;
  RxBool isUpdateFoodSubmitting = false.obs;
  RxBool isAddAddonsLoader = false.obs;
  RxBool isAddonsSubmitting = false.obs;
  RxBool isUpdateLoader = false.obs;
  bool isFoodLoader = false;
  bool isSubmitting = false;
  bool isloading = false;

  // Preference preference = Preference();

  // logOut() async {
  //   try {
  //     ApiResponse response = await repository.logOut();
  //     if (response.isSuccessfull) {
  //       appToast(AppString.logoutSuccessfully);
  //       preference.clearLogin();
  //       preference.clearString("user");
  //       Get.offAll(() => LoginScreen());
  //     }
  //   } catch (e) {
  //     log("logout :$e");
  //   }
  // }

  // Reactive states
  var isVegSwitched = true.obs;
  var isNonVegSwitched = true.obs;
  var isEggSwitched = true.obs;
  var isJainSwitched = true.obs;
  var isDineIn = false.obs;
  var isDelivery = false.obs;
  var isTakeAway = false.obs;
  var isRequired = false.obs;
  var isLiveWeb = false.obs;

  RxBool isStatusLoading = false.obs;

  bool multiBrandIsAvailable = false;

  // Dropdown values
  var selectedItem = ''.obs;
  var selectedValueFoodFoor = 'Normal'.obs;
  var selectDiscount = ''.obs;
  var selectedTaxType = 'GST'.obs;
  var selectedGivenDiscount = ''.obs;
  var selectedCategory = ''.obs;
  var selectedComplementary = 'no';

  Rx<int?> selectedStatus = Rx<int?>(null);

  RxInt updatingFoodId = RxInt(-1);

  // var isEgg = false.obs;

  String? quickCategoryValue;
  String? quickItemValue;
  String? deleteFoodReason;
  // String filterFoodFor = "Default Menu";
  String filterFoodFor = "Normal";
  int? quickCategoryIndex;
  int? categoryIndex;
  int? isVat;

  var toggleStates = <int, bool>{};

  void updateToggleState(int foodId, bool value) {
    toggleStates[foodId] = value;
    update();
  }

  //DropDown List
  List<String> foodForList = ['Normal', 'Party', 'Premium'];
  List<String> discountTypeList = ['Percent', 'Flat'];
  List<String> taxTypeList = ['GST', 'VAT'];
  List<String> GivenDiscountList = ['Yes', 'No'];
  List<String> complementaryList = ['yes', 'no'];
  List<String> itemTypeList = ['Veg', 'Non Veg', 'Jain', 'Egg'];
  List<String> menuFoodForList = [];
  List<String> menuFoodForLists = [
    // "Default Menu",
    // "Party",
    // 'Premium',
    // "Aggregator"
  ];

  // Allergens
  List<Map<String, dynamic>> allergenList = [];
  List<String> selectedAllergens = []; // Stores allergen 'name' values
  RxBool isAllergensLoading = false.obs;

  XFile? imageFile;
  String? imagePath;
  String? imageFileName;
  //Swiggy
  XFile? swiggyImageFile;
  String? swiggyImagePath;
  String? swiggyFileName;
  //Zomatao
  XFile? zomatoImageFile;
  String? zomatoImagePath;
  String? zomatoFileName;
  bool isImageUploaded = false;
  // Allowed extensions
  final List<String> allowedExtensionsZomato = ["png", "jpg", "jpeg"];
  final List<String> allowedExtensionsSwiggy = ["jpg"];
  final allowedExtensions = ['.jpg', '.jpeg', '.png', '.svg', '.webp'];

  // Category image variables
  XFile? categoryImageFile;
  String? categoryImageUrl; // For existing image from GET API
  String? categoryImageFileName;
  bool isCategoryImageUploaded = false;

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Data Lists
  var foodList = <Map<String, dynamic>>[].obs;
  var categoryList = <Map<String, dynamic>>[].obs;
  var productCategoryList = <Map<String, dynamic>>[].obs;
  var addonList = <Map<String, dynamic>>[].obs;
  var filteredFoodList = <Map<String, dynamic>>[].obs;
  var foodDeleteReasonsList = <String>[].obs;
  var restaurantClientsList = <Map<String, dynamic>>[].obs;
  var selectedClientId = Rx<int?>(null);
  var add_Edit_Category_Value = ''.obs;
  var selectedItems = <int>[].obs;
  var selectedAddItems = <int>[].obs;
  var foodForApiList = <String>[].obs;
  List<TextEditingController> addonsTextList = [];
  List<String> addonsTextIdList = [];
  List<Map<String, dynamic>> variations = [
    createNewVariation(),
  ];
  List<bool> isValidated = [];
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>()];
  List<AddonsModel> addonMyList = [];

  //**************************************************FOOD ITEMS*********************************************/
  //*category & search feild data reset
  catSearchDataReset() {
    searchController.clear();
    selectedCategory.value = '';
    selectedStatus.value = null;
    foodList.clear();
    filteredFoodList.clear();
  }

  String getSelectedFoodTypesText() {
    List<String> selected = [];
    if (isVegSwitched.value) selected.add('Veg');
    if (isNonVegSwitched.value) selected.add('Non-Veg');
    if (isEggSwitched.value) selected.add('Egg');
    if (isJainSwitched.value) selected.add('Jain');

    if (selected.isEmpty) return 'Select Food Type';
    if (selected.length == 4) return 'All Types';
    return selected.join(', ');
  }

  List<dynamic> _resolveRawVariations(Map<String, dynamic> food) {
    final plural = food['variations'];
    final singular = food['variation'];

    if (plural is List && plural.isNotEmpty) return plural;
    if (singular is List && singular.isNotEmpty) return singular;
    return [];
  }

  bool _isValidApiVariation(dynamic variation) {
    if (variation is! Map) return false;
    return (variation['name']?.toString().trim() ?? '').isNotEmpty;
  }

  Map<String, dynamic> _mapApiVariationToForm(Map<String, dynamic> variation) {
    return {
      "nameController": TextEditingController(
          text: variation["name"]?.toString() ?? ""),
      "selectionType": variation["type"]?.toString() ?? "single",
      "required": variation["required"]?.toString() ?? "off",
      "minController": TextEditingController(
          text: variation["min"]?.toString() ?? "0"),
      "maxController": TextEditingController(
          text: variation["max"]?.toString() ?? "0"),
      "options": (variation["values"] as List<dynamic>?)?.map((value) {
            return {
              "optionNameController": TextEditingController(
                  text: value["label"]?.toString() ?? ""),
              "priceController": TextEditingController(
                  text: value["optionPrice"]?.toString() ?? "0"),
            };
          }).toList() ??
          [],
    };
  }

  void _clearVariationFormState() {
    variations = [];
    formKeys = [];
    isValidated = [];
  }

  List<Map<String, dynamic>> _variationsForSubmit() {
    return variations
        .where((variation) =>
            variation['nameController'].text.trim().isNotEmpty)
        .map((variation) {
      return {
        "name": variation['nameController'].text,
        "type": variation['selectionType'],
        "min": int.tryParse(variation["minController"].text) ?? 0,
        "max": int.tryParse(variation["maxController"].text) ?? 0,
        "required": variation["required"],
        "values": variation['options'].map((option) {
          return {
            "label": option['optionNameController'].text,
            "optionPrice": option['priceController'].text,
          };
        }).toList(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _resolveRawAddonObjects(
      Map<String, dynamic> food) {
    final Map<int, Map<String, dynamic>> mergedById = {};

    void mergeAddonList(dynamic list) {
      if (list is! List || list.isEmpty) return;

      for (final entry in list) {
        if (entry is! Map) continue;

        final addon = Map<String, dynamic>.from(entry);
        final id = _parseAddonId(addon['id']);
        if (id == null) continue;

        mergedById[id] = addon;
      }
    }

    // API list first, then socket `add_ons` wins on duplicate ids.
    mergeAddonList(food['addons']);
    mergeAddonList(food['add_ons']);

    return mergedById.values.toList();
  }

  int? _parseAddonId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _lookupAddonName(int id) {
    for (final addon in addonList) {
      if (_parseAddonId(addon['id']) == id) {
        return addon['name']?.toString() ?? '';
      }
    }
    return '';
  }

  AddonsModel? _mapAddonEntry(dynamic entry) {
    if (entry is Map) {
      final addon = Map<String, dynamic>.from(entry);
      final id = _parseAddonId(addon['id']);
      if (id == null) return null;

      final name = addon['name']?.toString().trim() ?? '';
      return AddonsModel(
        id: id,
        name: name.isNotEmpty ? name : _lookupAddonName(id),
      );
    }

    final id = _parseAddonId(entry);
    if (id == null) return null;

    return AddonsModel(
      id: id,
      name: _lookupAddonName(id),
    );
  }

  List<AddonsModel> _buildAddonMyListFromFood(Map<String, dynamic> food) {
    final rawAddonObjects = _resolveRawAddonObjects(food);
    if (rawAddonObjects.isNotEmpty) {
      return rawAddonObjects
          .map(_mapAddonEntry)
          .whereType<AddonsModel>()
          .where((addon) => addon.id != null)
          .toList();
    }

    final addonIds = food['addon_ids'];
    if (addonIds is! List || addonIds.isEmpty) return [];

    return addonIds
        .map(_mapAddonEntry)
        .whereType<AddonsModel>()
        .where((addon) => addon.id != null)
        .toList();
  }

  void _populateAddonsFromFood(Map<String, dynamic> food) {
    addonMyList.clear();
    addonMyList.addAll(_buildAddonMyListFromFood(food));

    if (addonMyList.isNotEmpty) {
      selectedItems.assignAll(
        addonMyList.map((addon) => addon.id!).toList(),
      );
    } else {
      selectedItems.clear();
    }
  }

  //* initState call
  onInitCalling(
      {required bool isEdit,
      required Map<String, dynamic> myFood,
      String? foodFor}) async {
    _clearVariationFormState();

    await getAddonList();
    await fetchAllergens();
    // await getStationList();

    if (isEdit) {
      final food = myFood;
      log("ON_INIT FOOD => ${jsonEncode(food)}");
      log("variation type = ${food["variation"]?.runtimeType}");
      log("variations type = ${food["variations"]?.runtimeType}");
      log("variation value = ${food["variation"]}");
      log("variations value = ${food["variations"]}");

      productName.text = food['name'];
      description.text = food['description'] ?? '';

      imageFile = null;
      imagePath = food['image'];
      imageFileName = 'Choose file';

      swiggyImageFile = null;
      swiggyImagePath = food['swiggy_image'];
      swiggyFileName = 'Choose file';

      zomatoImageFile = null;
      zomatoImagePath = food['image'];
      zomatoFileName = 'Choose file';

      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
        (timeStamp) {
          add_Edit_Category_Value.value = food["category"]["name"].toString();
        },
      );

      menuPrice.text = food['price'].toString();
      discountAmount.text = food['discount'].toString();

      selectDiscount.value = food['discount_type'].toString();
      if (food["food_for"] == "Aggregator") {
        isDineIn.value = food['swiggy'] == "YES";
        isDelivery.value = food['zomato'] == "YES";
      } else {
        isDineIn.value = food['dinein'] == "Yes";
        isDelivery.value = food['delivery'] == "Yes";
        isTakeAway.value = food['takeaway'] == "Yes";
        isLiveWeb.value = food['live_web'] == "Y";
      }

      startDateController.text = food['available_time_starts'] ?? "";
      expireDateController.text = food['available_time_ends'] ?? "";
      // selectedItems.assignAll(food['addon_ids'] ?? []);
      // variations.assignAll(food['variations'] ?? []);
      itemType = food["item_type"] == 1
          ? "Veg"
          : food["item_type"] == 2
              ? "Egg"
              : food["item_type"] == 3
                  ? "Jain"
                  : "Non Veg";
      // foodOrder.text = food["food_order"].toString();

      // if (food["food_for"].toString() == "Normal") {
      //   selectedValueFoodFoor.value = "Default Menu";
      // } else {
      selectedValueFoodFoor.value = food["food_for"] ?? "";
      // }

      selectedGivenDiscount.value = food["give_discount"];
      selectedTaxType.value = food['tax_type'];
      selectedComplementary = food['complementary'].toString().toLowerCase();
      preparationTime.text = food["prepration_time_min"].toString();
      serverTime.text = food["serve_time_in_min"].toString();
      deliveryCharge.text = food["delivery_charge"].toString();
      takeawayCharge.text = food["takeaway_charge"].toString();
      packagingCharge.text = food["pack_charges"].toString();
      taxController.text = food["tax"].toString();
      itemCodeController.text = food["item_code"].toString();
      caloriesController.text = food["kcal"] ?? "0";

      // Parse existing allergens (array format)
      if (food["allergens"] != null && food["allergens"] is List) {
        selectedAllergens = (food["allergens"] as List<dynamic>)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      final validVariations = _resolveRawVariations(food)
          .where(_isValidApiVariation)
          .cast<Map<String, dynamic>>()
          .toList();

      if (validVariations.isNotEmpty) {
        variations =
            validVariations.map(_mapApiVariationToForm).toList();
        formKeys =
            List.generate(variations.length, (index) => GlobalKey<FormState>());
        isValidated =
            List<bool>.filled(variations.length, true, growable: true);
      } else {
        _clearVariationFormState();
      }

      categoryIndex = food["category"]["id"];

      _populateAddonsFromFood(food);
      await getFoodsFor(isEdit: true, foodFor: food["food_for"].toString());
    } else {
      // selectedValueFoodFoor.value = foodFor ?? "Default Menu";
      selectedValueFoodFoor.value = foodFor ?? "";
      productName.clear();
      description.clear();
      menuPrice.clear();
      variations.clear();
      startDateController.clear();
      expireDateController.clear();
      itemType = null;
      foodOrder.clear();
      add_Edit_Category_Value.value = "";
      imageFile = null;
      imagePath = '';
      imageFileName = 'Choose File';
      swiggyImageFile = null;
      swiggyImagePath = '';
      swiggyFileName = 'Choose File';
      zomatoImageFile = null;
      zomatoImagePath = '';
      zomatoFileName = 'Choose File';
      selectDiscount.value = '';
      discountAmount.clear();
      preparationTime.clear();
      serverTime.clear();
      itemCodeController.clear();
      caloriesController.clear();
      selectedAllergens.clear();
      selectedGivenDiscount.value = '';
      selectedComplementary = 'no';
      taxController.text = "0.00";
      selectedTaxType.value = 'GST';
      deliveryCharge.text = "0.00";
      takeawayCharge.text = "0.00";
      packagingCharge.text = "0.00";
      isDineIn.value = true;
      isDelivery.value = true;
      isTakeAway.value = true;
      isLiveWeb.value = true;
      isCategoryValid = false.obs;
      isNameValid = false.obs;
      isPriceValid = false.obs;
      addonMyList.clear();
      variations.clear();
      formKeys.clear();
      isValidated.clear();
      await getFoodsFor(
          isEdit: true, foodFor: selectedValueFoodFoor.value.toString());
    }
  }

  setLoader(bool val) {
    isSubmitLoader.value = val;
  }

  //* food submit
  foodSubmit(
    bool isEdit, {
    int? id,
  }) async {
    try {
      log("foodSubmit filterFoodFor :$filterFoodFor");
      variations.map((variation) {
        log("food varitaon required :${variation["required"]}");
      });

      print(isSubmitting);
      if (isSubmitting) return;
      isSubmitting = true;

      setLoader(true);

      final data = {
        "name": productName.text.trim(),
        "description": description.text,
        "category_id": categoryIndex,
        "price": double.tryParse(menuPrice.text) ?? 0,
        "discount": int.tryParse(discountAmount.text) ?? 0,
        if (selectDiscount.value.isNotEmpty)
          "discount_type":
              selectDiscount.value == "Flat" ? "amount" : selectDiscount.value,
        if (selectedValueFoodFoor.value.isNotEmpty)
          "food_for": (selectedValueFoodFoor.value == "Default Menu")
              ? "Normal"
              : selectedValueFoodFoor.value,
        if (filterFoodFor == "Aggregator" &&
            isEdit == false &&
            multiBrandIsAvailable == true &&
            selectedClientId.value != null)
          "client": selectedClientId.value != null ? selectedClientId.value : 0,
        if (filterFoodFor == "Aggregator")
          "swiggy": isDineIn.value ? "YES" : "NO",
        if (filterFoodFor == "Aggregator")
          "zomato": isDelivery.value ? "YES" : "NO",
        if (filterFoodFor != "Aggregator")
          "dinein": isDineIn.value ? "Yes" : "No",
        if (filterFoodFor != "Aggregator")
          "delivery": isDelivery.value ? "Yes" : "No",
        if (filterFoodFor != "Aggregator")
          "takeaway": isTakeAway.value ? "Yes" : "No",
        if (filterFoodFor != "Aggregator")
          "live_web": isLiveWeb.value ? "Y" : "N",
        if (startDateController.text.isNotEmpty)
          "available_time_starts": startDateController.text,
        if (expireDateController.text.isNotEmpty)
          "available_time_ends": expireDateController.text,
        "prepration_time_min": int.tryParse(preparationTime.text) ?? 0,
        "serve_time_in_min": int.tryParse(serverTime.text) ?? 0,
        "pack_charges": packagingCharge.text ?? "0.00",
        "takeaway_charge": takeawayCharge.text ?? "0.00",
        "delivery_charge": deliveryCharge.text ?? "0.00",
        "tax_type": selectedTaxType.value == '' ? "GST" : selectedTaxType.value,
        "tax": taxController.text.trim(),
        if (filterFoodFor != "Aggregator")
          "complementary": selectedComplementary,
        "give_discount": selectedGivenDiscount.value == ''
            ? "Yes"
            : selectedGivenDiscount.value == "Yes"
                ? "Yes"
                : "No",
        if (filterFoodFor != "Aggregator")
          "item_code": itemCodeController.text.trim(),
        if (filterFoodFor != "Aggregator")
          "kcal": double.tryParse(caloriesController.text.trim()) ?? 0,
        if (filterFoodFor != "Aggregator")
          "allergens": selectedAllergens.isNotEmpty
              ? getSelectedAllergensString()
              : null,
        "addon_ids": addonMyList.map((e) => e.id).toList(),
        if (itemType != null)
          "veg": itemType == "Veg"
              ? 1
              : itemType == "Jain"
                  ? 3
                  : itemType == "Egg"
                      ? 2
                      : 0,
        "variations": _variationsForSubmit(),
      };

      if (isEdit) {
        await updateFood(id ?? 0, data, isFullEdit: true);
      } else {
        double? discountAmountValue = double.tryParse(discountAmount.text);
        double? menuPriceValue = double.tryParse(menuPrice.text);

        if (discountAmountValue != null &&
            menuPriceValue != null &&
            discountAmountValue > menuPriceValue) {
          appToast(AppString.discountMoreThanPrice);
        } else {
          filterFoodFor == "Aggregator"
              ? await addFoodAggregator(data)
              : await postFoodList(data);
        }
      }
    } catch (e) {
      log("foodSubmit :$e");
    } finally {
      setLoader(false);
      isSubmitting = false;
    }
  }

  //*addFood
  Future<void> postFoodList(Map<String, dynamic> data) async {
    try {
      String foodInfoJson = jsonEncode(data);

      // Check if product already exists
      if (foodList.any((p0) =>
          p0["name"].toString().replaceAll(' ', '').trim().toLowerCase() ==
          productName.text.replaceAll(' ', '').trim().toLowerCase())) {
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(AppString.foodAlreadyExists)
            : Get.snackbar(
                'Error',
                AppString.foodAlreadyExists,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
              );
        print("Food already exists: ${productName.text}");
        return;
      }

      // Build image list only if imageFile is selected
      // List<MultipartBody> multipartList = [];
      // if (imageFile != null) {
      //   multipartList
      //       .add(MultipartBody('image', imageFile!, null)); // use 'image' key
      // }

      final response = await menuManagementRepo.postFoodWithMuliPartDate({
        'food_info': foodInfoJson,
      }, imageFile);

      if (response.statusCode == 200) {
        await fetchFoodList(
          isVeg: isVegSwitched.value,
          isNoVeg: isNonVegSwitched.value,
          isEgg: isEggSwitched.value,
          isJain: isJainSwitched.value,
          category: selectedCategory.value,
          status: selectedStatus.value,
        );
        appToast(AppString.foodAddedSuccessfully);
        Get.back();
        resetData();
      } else if (response.statusCode == 401) {
        ApiChecker.checkApi(response);
      } else {
        final errorMessage = response.body?['errors'] is List &&
                response.body['errors'].isNotEmpty
            ? response.body['errors'][0]['message'] ?? 'Something went wrong'
            : 'Something went wrong';

        (Platform.isAndroid || Platform.isIOS)
            ? appToast(errorMessage)
            : Get.snackbar(
                'Something Wrong!',
                errorMessage,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
      }
    } catch (e) {
      log("postFoodList Error: $e");
      appToast(AppString.failedToAddFood);
    }
  }

  onSubmitFood({required bool isEdit, int? id}) async {
    try {
      if (isSubmitting) return;
      bool isValid =
          formKeys.every((key) => key.currentState?.validate() ?? true);

      if (isValid) {
        if (isEdit) {
          await foodSubmit(isEdit, id: id);
        } else {
          await foodSubmit(isEdit);
        }
      } else {
        if (variations.any((e) => e["selectionType"] == "multi") || isValid) {
          appToast("Please fill valid variation-value");
        } else {
          if (isEdit) {
            await foodSubmit(isEdit, id: id);
          } else {
            await foodSubmit(isEdit);
          }
        }
      }
    } catch (e) {
      log("onSubmitFood :$e");
    }
  }

  //* addFoodAggregator
  addFoodAggregator(Map<String, dynamic> data) async {
    try {
      String foodInfoJson = jsonEncode(data);
      final response = await menuManagementRepo
          .postFoodAggregatorWithMuliPartDate(
              {'food_info': foodInfoJson}, zomatoImageFile, swiggyImageFile);
      if (response.statusCode == 200) {
        await fetchFoodList(
          isVeg: isVegSwitched.value,
          isNoVeg: isNonVegSwitched.value,
          isEgg: isEggSwitched.value,
          isJain: isJainSwitched.value,
          category: selectedCategory.value,
          status: selectedStatus.value,
        );
        appToast(AppString.foodAddedSuccessfully);
        Get.back();
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log("addFoodAggregator :$e");
    } finally {
      setLoader(false);
      isSubmitting = false;
    }
  }

  //*Food Status

  statusFood(int id, {required Map<String, dynamic> data}) async {
    try {
      // Start loading
      updatingFoodId.value = id;
      isStatusLoading.value = true;

      final response = await menuManagementRepo.statusFood(id, data: data);
      if (response?.statusCode == 200) {
        // Save current scroll position
        double currentScrollPosition =
            foodScrollController.hasClients ? foodScrollController.offset : 0.0;

        appToast(response?.body?["message"]);

        // Fetch food list without resetting scroll
        // await fetchFoodList(
        //   isVeg: isVegSwitched.value,
        //   isNoVeg: isNonVegSwitched.value,
        //   isEgg: isEggSwitched.value,
        //   isJain: isJainSwitched.value,
        //   category: selectedCategory.value,
        //   status: selectedStatus.value,
        // );

        // Restore scroll position after a small delay
        Future.delayed(Duration(milliseconds: 50), () {
          if (foodScrollController.hasClients) {
            foodScrollController.jumpTo(currentScrollPosition);
          }
        });
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("statusFood :$e");
    } finally {
      // Stop loading
      updatingFoodId.value = -1;
      isStatusLoading.value = false;
    }
  }

  bool isAggregatorFood(Map<String, dynamic>? food) {
    return food?['food_for']?.toString() == 'Aggregator';
  }

  int? parseFoodId(dynamic id) {
    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.tryParse(id?.toString() ?? '');
  }

  bool isAggregatorFoodLive(Map<String, dynamic>? food) {
    final status = food?['status'];
    return status == 1 || status?.toString() == '1';
  }

  DateTime? parseAggregatorTurnOnAt(dynamic turnOnAt) {
    if (turnOnAt == null) return null;
    final raw = turnOnAt.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
    try {
      return DateConverter.dateTimeStringToDate(raw);
    } catch (_) {
      return DateTime.tryParse(raw);
    }
  }

  String? formatAggregatorBackAt(dynamic turnOnAt) {
    final dateTime = parseAggregatorTurnOnAt(turnOnAt);
    if (dateTime == null) return null;
    final timeText = DateFormat('h:mm a')
        .format(dateTime)
        .replaceAll('AM', 'am')
        .replaceAll('PM', 'pm');
    return '${DateFormat('d MMM yyyy').format(dateTime)}, $timeText';
  }

  int localDateTimeToUnixMs(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  Future<bool> aggregatorStockToggle({
    required int itemId,
    required String action,
    String? turnOnPreset,
    int? turnOnAtMs,
  }) async {
    try {
      updatingFoodId.value = itemId;
      isStatusLoading.value = true;

      final Map<String, dynamic> data = {
        'action': action,
        'item_ids': [itemId],
      };

      if (selectedClientId.value != null) {
        data['client_id'] = selectedClientId.value;
      }

      if (action == 'disable') {
        if (turnOnAtMs != null) {
          data['turn_on_at'] = turnOnAtMs;
        } else if (turnOnPreset != null && turnOnPreset.isNotEmpty) {
          data['turn_on_preset'] = turnOnPreset;
        }
      }

      final response =
          await menuManagementRepo.aggregatorStockToggle(data: data);
      if (response?.statusCode == 200) {
        double currentScrollPosition = foodScrollController.hasClients
            ? foodScrollController.offset
            : 0.0;

        final message = response?.body?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          appToast(message);
        }

        _applyLocalAggregatorStockState(
          itemId: itemId,
          isLive: action == 'enable',
        );

        await fetchFoodList(
          isVeg: isVegSwitched.value,
          isNoVeg: isNonVegSwitched.value,
          isEgg: isEggSwitched.value,
          isJain: isJainSwitched.value,
          category: selectedCategory.value,
          status: selectedStatus.value,
        );

        Future.delayed(const Duration(milliseconds: 35), () {
          if (foodScrollController.hasClients) {
            foodScrollController.jumpTo(currentScrollPosition);
          }
        });
        return true;
      } else if (response != null) {
        ApiChecker.checkApi(response);
      }
      return false;
    } catch (e) {
      log("aggregatorStockToggle :$e");
      return false;
    } finally {
      updatingFoodId.value = -1;
      isStatusLoading.value = false;
    }
  }

  void _applyLocalAggregatorStockState({
    required int itemId,
    required bool isLive,
  }) {
    final index = foodList
        .indexWhere((food) => parseFoodId(food['id']) == itemId);
    if (index == -1) return;
    final updated = Map<String, dynamic>.from(foodList[index]);
    updated['status'] = isLive ? 1 : 0;
    if (isLive) {
      updated['turn_on_at'] = null;
    }
    foodList[index] = updated;
    update();
  }

  //*Edit Food
  Future<void> updateFood(int id, Map<String, dynamic> data,
      {bool isFullEdit = false, bool isStatus = false}) async {
    try {
      if (isUpdateFoodSubmitting.value) return;
      isUpdateFoodSubmitting.value = true;
      setUpdateLoader(true);

      // Convert to JSON string
      String foodInfoJson = jsonEncode(data);

      final response = await menuManagementRepo.updateFoodWithMultiPartData(
          id,
          {
            'food_info': foodInfoJson,
          },
          (filterFoodFor == "Aggregator") ? zomatoImageFile : imageFile,
          swiggyImageFile);

      if (response.statusCode == 200) {
        if (!isStatus) {
          Get.back();
        }

        await fetchFoodList(
          isVeg: isVegSwitched.value,
          isNoVeg: isNonVegSwitched.value,
          isEgg: isEggSwitched.value,
          isJain: isJainSwitched.value,
          category: selectedCategory.value,
          status: selectedStatus.value,
        );

        appToast(response.body?["message"] ?? AppString.somethingWrong);
        searchController.clear();
        add_Edit_Category_Value.value = "";
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log("updateFood Error: $e");
      appToast(AppString.failedToUpdateFood);
    } finally {
      setUpdateLoader(false);
      isUpdateFoodSubmitting.value = false;
    }
  }

  setUpdateLoader(bool val) {
    isUpdateLoader.value = val;
  }

  //*Delete Food
  deleteFood(int id, {required String foodFor}) async {
    try {
      if (deleteFoodReason?.isNotEmpty ?? false) {
        if (isDeleteFoodSubmitting.value) return;
        isDeleteFoodSubmitting.value = true;
        setFoodDelete(true);
        Map<String, dynamic> data = {
          "delete_reason": deleteFoodReason,
          if (filterFoodFor == "Aggregator") "food_for": "Aggregator",
        };
        final response = await menuManagementRepo.deleteFood(id, data: data);

        if (response?.statusCode == 200) {
          Get.back();
          // catSearchDataReset();
          // await fetchFoodList(
          //   isVeg: isVegSwitched.value,
          //   isNoVeg: isNonVegSwitched.value,
          //   isEgg: isEggSwitched.value,
          //   isJain: isJainSwitched.value,
          //   category: selectedCategory.value,
          //   status: selectedStatus.value,
          // );
          appToast(response?.body?["message"] ?? AppString.somethingWrong);
        } else {
          ApiChecker.checkApi(response!);
        }
      } else {
        appToast(AppString.selectReason);
      }
    } catch (e) {
      log("deleteFood Error: $e");
    } finally {
      setFoodDelete(false);
      isDeleteFoodSubmitting.value = false;
    }
  }

  //*Delete Reason
  getDeleteReasons() async {
    try {
      final response = await menuManagementRepo.getDeleteReasons();
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['reason'] ?? [];
        foodDeleteReasonsList.assignAll(data.cast<String>());
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getDeleteReasons :$e");
    }
  }

  setFoodDelete(bool val) {
    isFoodDelete.value = val;
  }

  /// API sends this flag as a boolean, the string "true", or 1.
  bool _isAggregatorFlag(dynamic value) {
    if (value == true || value == 1) return true;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  /// Categories shown in the menu filter. Aggregator uses the aggregator
  /// flag. Every other menu uses the food flag.
  List<Map<String, dynamic>> categoriesForCurrentMenu() {
    final flagKey =
        filterFoodFor == "Aggregator" ? "aggregator" : "food";
    return productCategoryList
        .where((category) => _isAggregatorFlag(category[flagKey]))
        .toList();
  }

  /// True when the selected category is not valid for the current menu.
  bool isCategoryUnavailableForAggregator(String? category) {
    if (category == null || category.isEmpty) return false;
    final flagKey =
        filterFoodFor == "Aggregator" ? "aggregator" : "food";
    for (final cat in productCategoryList) {
      if (cat['name']?.toString() == category) {
        return !_isAggregatorFlag(cat[flagKey]);
      }
    }
    return true;
  }

  String get categoryUnavailableMessage {
    final menu =
        filterFoodFor == "Aggregator" ? "aggregator" : filterFoodFor;
    return "This category is not available in the $menu menu. Please change the category.";
  }

  //*Food Filter
  changeFoodForFilter(String value) async {
    filterFoodFor = value;
    // Reset selectedClientId when switching away from Aggregator
    if (value != "Aggregator") {
      selectedClientId.value = null;
    } else {
      // Fetch clients when switching to Aggregator if not already fetched
      if (restaurantClientsList.isEmpty) {
        await fetchRestaurantClients();
      }
    }
    selectedCategory.refresh();
    await fetchFoodList(
      isVeg: isVegSwitched.value,
      isNoVeg: isNonVegSwitched.value,
      isEgg: isEggSwitched.value,
      isJain: isJainSwitched.value,
      category: selectedCategory.value,
      status: selectedStatus.value,
    );
    update();
  }

  //*Food For
  getFoodsFor({bool isEdit = false, String? foodFor}) async {
    try {
      Map<String, dynamic> data = {};
      if (isEdit) {
        data = {"food_for": foodFor};
      } else {
        data = {};
      }

      final response = await menuManagementRepo.foodsFor(data);
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['food_for'] ?? [];
        foodForApiList.assignAll(data.cast<String>());
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("foodsFor :$e");
    }
  }

  // This category is no logner use in menu management(use in others)
  Future<void> getCategoryList() async {
    try {
      final response = await menuManagementRepo.getAllCategoryList();

      log("getCategoryList code :${response?.statusCode}");

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body ?? [];
        categoryList.assignAll(data.cast<Map<String, dynamic>>());
        log("categoryList :${categoryList.toList()}");

        update();
      }
    } catch (e) {
      log("getCategoryList :$e");
    }
  }

  //* Resturant Category
  Future<void> productCategories() async {
    try {
      final response = await menuManagementRepo.productCategories();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body ?? [];
        productCategoryList.assignAll(data.cast<Map<String, dynamic>>());

        // await getCategoryList();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("productCategories $e");
    }
  }

  void setSelectedCategory(String newCategory) {
    add_Edit_Category_Value.value = newCategory;
  }

  List<String> get categoryNames {
    return categoryList.map((category) => category['name'] as String).toList();
  }

  setFoodLoader(bool val) {
    isFoodLoader = val;
    update();
  }

  fetchFoodFilter() async {
    isVegSwitched.value = await getStoragePref.getValue("veg");

    isNonVegSwitched.value = await getStoragePref.getValue("noVeg");
    await fetchFoodList(
      isVeg: isVegSwitched.value,
      isNoVeg: isNonVegSwitched.value,
      isEgg: isEggSwitched.value,
      isJain: isJainSwitched.value,
      category: selectedCategory.value,
      status: selectedStatus.value,
    );
  }

  //* Food List
  // Future<void> fetchFoodList(
  //     {String? category,
  //     bool? isVeg,
  //     bool? isNoVeg,
  //     bool? isEgg,
  //     bool? isJain,
  //     }) async {
  //   try {
  //     setFoodLoader(true);
  //     // foodList.clear();
  //     print(
  //         '..ve:$isVeg ..noVeg: $isNoVeg ..isEgg: $isEgg ..isJain: $isJain....category :$category');
  //     log("food .._--> $filterFoodFor");

  //     Map<String, dynamic> data = {"food_for": filterFoodFor};

  //     final response = await menuManagementRepo.getFoodList(data: data);
  //     if (response?.statusCode == 200) {
  //       List<dynamic> data = response?.body?['foods'] ?? [];

  //       var filteredFood = data.where((food) {
  //         bool categoryMatch = category == null ||
  //             category.isEmpty ||
  //             food["category"]["name"] == category;
  //         bool itemTypeMatch = ((isVeg == true && food["item_type"] == 1) ||
  //             (isNoVeg == true && food["item_type"] == 0) ||
  //             (isEgg == true && food["item_type"] == 2) ||
  //             (isJain == true && food["item_type"] == 3));

  //         if ((isVeg == true &&
  //                 isNoVeg == true &&
  //                 isEgg == true &&
  //                 isJain == true) ||
  //             (isVeg == false &&
  //                 isNoVeg == false &&
  //                 isEgg == false &&
  //                 isJain == false)) {
  //           return categoryMatch;
  //         } else {
  //           return categoryMatch && itemTypeMatch;
  //         }
  //       }).toList();

  //       foodList.assignAll(filteredFood.cast<Map<String, dynamic>>());
  //       log("Filtered List Length: ${foodList.length}");
  //     } else {
  //       ApiChecker.checkApi(response!);
  //     }

  //     update();
  //   } catch (e) {
  //     log("fetchFoodList Error: $e");
  //   } finally {
  //     setFoodLoader(false);
  //   }
  // }

  Future<void> fetchRestaurantClients() async {
    try {
      final response = await menuManagementRepo.getRestaurantClients();
      if (response?.statusCode == 200) {
        if (response?.body?['clients'] != 0 &&
            response?.body?['clients_found'] == true) {
          multiBrandIsAvailable = response?.body?['clients_found'];
          List<dynamic> clients = response?.body?['clients'] ?? [];
          restaurantClientsList.assignAll(clients.cast<Map<String, dynamic>>());
          log("Restaurant Clients Count: ${restaurantClientsList.length}");
        } else {
          multiBrandIsAvailable = response?.body?['clients_found'];
          restaurantClientsList.assignAll([]);
          selectedClientId.value = null;
        }
      } else {
        ApiChecker.checkApi(response!);
        selectedClientId.value = null;
        multiBrandIsAvailable = false;
      }
      update();
    } catch (e) {
      log("fetchRestaurantClients Error: $e");
      selectedClientId.value = null;
      multiBrandIsAvailable = false;
    }
  }

  Future<void> fetchFoodList({
    String? category,
    bool? isVeg,
    bool? isNoVeg,
    bool? isEgg,
    bool? isJain,
    int? status,
  }) async {
    try {
      setFoodLoader(false);
      print(
          '..ve:$isVeg ..noVeg: $isNoVeg ..isEgg: $isEgg ..isJain: $isJain....category :$category ...status: $status');
      log("food .._--> $filterFoodFor");

      Map<String, dynamic> data = {"food_for": filterFoodFor};
      if (filterFoodFor == "Aggregator" && multiBrandIsAvailable == true) {
        log("Agg selectedClient: ${selectedClientId.value}");
        data["client"] = selectedClientId.value != null
            ? selectedClientId.value.toString()
            : "0";
      }

      final response = await menuManagementRepo.getFoodList(data: data);
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['foods'] ?? [];

        isVat = response?.body?['restaurant_settings']?['vat']?['status'] ?? 0;

        var filteredFood = data.where((food) {
          bool categoryMatch = category == null ||
              category.isEmpty ||
              food["category"]["name"] == category;

          bool itemTypeMatch = ((isVeg == true && food["item_type"] == 1) ||
              (isNoVeg == true && food["item_type"] == 0) ||
              (isEgg == true && food["item_type"] == 2) ||
              (isJain == true && food["item_type"] == 3));

          bool statusMatch = status == null || food["status"] == status;

          if ((isVeg == true &&
                  isNoVeg == true &&
                  isEgg == true &&
                  isJain == true) ||
              (isVeg == false &&
                  isNoVeg == false &&
                  isEgg == false &&
                  isJain == false)) {
            return categoryMatch && statusMatch;
          } else {
            return categoryMatch && itemTypeMatch && statusMatch;
          }
        }).toList();

        if (isCategoryUnavailableForAggregator(category)) {
          foodList.clear();
        } else {
          foodList.assignAll(filteredFood.cast<Map<String, dynamic>>());
        }
        log("Filtered List Length: ${foodList.length}");
      } else {
        ApiChecker.checkApi(response!);
      }

      update();
    } catch (e) {
      log("fetchFoodList Error: $e");
    } finally {
      setFoodLoader(false);
    }
  }

  Future<void> fetchAllergens() async {
    try {
      isAllergensLoading.value = true;
      update();

      final response = await menuManagementRepo.getAllergens();

      if (response != null && response.statusCode == 200) {
        final body = response.body ?? {};
        final List<dynamic> allergens = body["allergens"] ?? [];
        allergenList = allergens
            .map((allergen) => {
                  "id": allergen["id"],
                  "name": allergen["name"],
                  "label": allergen["label"],
                })
            .toList();
      } else {
        if (response != null) {
          ApiChecker.checkApi(response);
        }
      }
    } catch (e) {
      log("fetchAllergens error: $e");
    } finally {
      isAllergensLoading.value = false;
      update();
    }
  }

  // Helper method to convert selected allergens to comma-separated string
  String getSelectedAllergensString() {
    if (selectedAllergens.isEmpty) return '';
    return selectedAllergens.join(', ');
  }

  // Helper method to get selected allergen labels for display
  String getSelectedAllergensDisplayText() {
    if (selectedAllergens.isEmpty) return 'Select Allergens';

    final selectedLabels = allergenList
        .where((allergen) => selectedAllergens.contains(allergen["name"]))
        .map((allergen) => allergen["label"] as String)
        .toList();

    return selectedLabels.join(', ');
  }

  Future<void> fetchMenuMasterLists() async {
    try {
      final response = await menuManagementRepo.getMenuMasterLists();
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['menus'] ?? [];
        filterFoodFor = data.first['menu_name'] as String;
        print("filterFoodFor : $filterFoodFor");
        menuFoodForList.clear();
        data.forEach(
            (menu) => menuFoodForList.add(menu['menu_name'] as String));
        print("menuFoodForList : $menuFoodForList");
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("fetchMenuFoodForLists Error: $e");
    }
  }
  //**************************************************FOOD ITEMS*********************************************//

  void addAddonsWidget() {
    try {
      addonsTextList.add(TextEditingController(text: ""));
      addonsTextIdList.add("");

      update();
    } catch (e) {
      print("addAddonsWidget : $e");
    }
  }

  deleteAddonsWidget(int index) {
    if (addonsTextList.length != 1) {
      addonsTextList.removeAt(index);
      addonsTextIdList.removeAt(index);
    }

    update();
  }

  static Map<String, dynamic> createNewVariation() {
    return {
      "nameController": TextEditingController(),
      "selectionType": "single", //"multi"
      "minController": TextEditingController(),
      "maxController": TextEditingController(),
      "required": "on", //true
      "options": [
        {
          "optionNameController": TextEditingController(),
          "priceController": TextEditingController()
        }
      ],
    };
  }

  String? itemType;
  GetStoragePref getStoragePref = GetStoragePref();

  TextEditingController addAddonNameController = TextEditingController();
  TextEditingController addAddonPriceController = TextEditingController();
  TextEditingController addAddonQuantityController = TextEditingController();
  String? selectedAddonUnit;

  bool isMinMaxValidate = false;

  // Fetch the addon list from the API
  RxBool isAddonLoader = false.obs;
  Future<void> getAddonList() async {
    try {
      isAddonLoader.value = true;
      final response = await menuManagementRepo.getAddonList();
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['addons'] ?? [];
        addonList.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("fetchAddonList Error: $e");
      appToast("Failed to fetch addon list.");
    } finally {
      isAddonLoader.value = false;
    }
  }

  void addVariationWithValidation() {
    variations.add(createNewVariation());
    formKeys.add(GlobalKey<FormState>());
    isValidated.add(false);
    update();
  }

  void removeVariationAt(int index) {
    variations.removeAt(index);
    formKeys.removeAt(index);
    isValidated.removeAt(index);
    update();
  }

  // Add a new variation
  void addVariation() {
    variations.add({
      "nameController": TextEditingController(),
      "selectionType": "single",
      "minController": TextEditingController(),
      "maxController": TextEditingController(),
      "required": "on",
      "options": [],
    });
    formKeys.add(GlobalKey<FormState>());
    update();
  }

  // Delete a variation
  void deleteVariation(int index) {
    variations.removeAt(index);
    formKeys.removeAt(index);
    update();
  }

  // Add an option to a variation
  void addOption(int variationIndex) {
    variations[variationIndex]["options"].add({
      "optionNameController": TextEditingController(),
      "priceController": TextEditingController(),
    });
    update();
  }

  // Delete an option from a variation
  void deleteOption(int variationIndex, int optionIndex) {
    variations[variationIndex]["options"].removeAt(optionIndex);
    update();
  }

  //add addons
  setAddAddonsLoader(bool val) {
    isAddAddonsLoader.value = val;
  }

  TextEditingController addonsSearchController = TextEditingController();
  addAddons() async {
    try {
      if (isAddonsSubmitting.value) return;
      isAddonsSubmitting.value = true;
      setAddAddonsLoader(true);
      Map<String, dynamic> data = {
        "name": addAddonNameController.text.trim(),
        "price": addAddonPriceController.text.trim(),
      };

      // Conditionally add qty only if user entered a value
      // if (addAddonQuantityController.text.trim().isNotEmpty) {
      //   final qtyValue =
      //       double.tryParse(addAddonQuantityController.text.trim());
      //   if (qtyValue != null) {
      //     data["qty"] = qtyValue.toInt();
      //   }
      // }

      // // Conditionally add unit only if user selected a value
      // if (selectedAddonUnit != null && selectedAddonUnit!.isNotEmpty) {
      //   data["unit"] = selectedAddonUnit;
      // }

      if (addonList.any((p0) =>
          p0["name"].toString().toLowerCase() ==
          addAddonNameController.text.toLowerCase())) {
        appToast(AppString.addonAlreadyExists);
      } else {
        final response = await menuManagementRepo.addAddon(data);
        if (response?.statusCode == 200 || response?.statusCode == 201) {
          await getAddonList();
          appToast(AppString.addAddonsSuccessfully);
          Get.back();
        } else {
          ApiChecker.checkApi(response!);
        }
      }
    } catch (e) {
      log("addAddons :$e");
    } finally {
      setAddAddonsLoader(false);
      isAddonsSubmitting.value = false;
    }
  }

  updateAddon(int id) async {
    try {
      if (isAddonsSubmitting.value) return;
      isAddonsSubmitting.value = true;
      setAddAddonsLoader(true);
      Map<String, dynamic> data = {
        "name": addAddonNameController.text.trim(),
        "price": addAddonPriceController.text.trim(),
      };

      // Conditionally add qty only if user entered a value
      // if (addAddonQuantityController.text.trim().isNotEmpty) {
      //   final qtyValue =
      //       double.tryParse(addAddonQuantityController.text.trim());
      //   if (qtyValue != null) {
      //     data["qty"] = qtyValue.toInt();
      //   }
      // }

      // // Conditionally add unit only if user selected a value
      // if (selectedAddonUnit != null && selectedAddonUnit!.isNotEmpty) {
      //   data["unit"] = selectedAddonUnit;
      // }

      final response = await menuManagementRepo.updateAddon(id, data: data);
      if (response?.statusCode == 200) {
        await getAddonList();
        appToast(response?.body?["message"]);
        Get.back();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("updateAddon :$e");
    } finally {
      setAddAddonsLoader(false);
      isAddonsSubmitting.value = false;
    }
  }

  deleteAddon(int id) async {
    try {
      final response = await menuManagementRepo.deleteAddon(id);

      if (response?.statusCode == 200) {
        await getAddonList();
        appToast(response?.body?["message"]);
        Get.back();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("deleteAddon $e");
    }
  }

  addonStatusChange(int id, {required Map<String, dynamic> data}) async {
    try {
      final response =
          await menuManagementRepo.addonStatusChange(id, data: data);
      if (response?.statusCode == 200) {
        await getAddonList();
        appToast(response?.body?['message']);
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("addonStatusChange :$e");
    }
  }

  @override
  void onClose() {
    productName.dispose();
    description.dispose();
    menuPrice.dispose();
    discountAmount.dispose();
    foodOrder.dispose();
    preparationTime.dispose();
    serverTime.dispose();
    startDateController.dispose();
    expireDateController.dispose();
    addonName.dispose();
    addonPrice.dispose();
    searchController.dispose();
    super.onClose();
  }

  resetData() {
    productName.clear();
    description.clear();
    menuPrice.clear();
    variations.clear();
    startDateController.clear();
    expireDateController.clear();
    itemType = null;
    foodOrder.clear();
    imageFile = null;
    imageFileName = 'imageFileName';

    selectedValueFoodFoor.value = '';
    add_Edit_Category_Value.value = '';

    selectDiscount.value = '';
    discountAmount.clear();
    preparationTime.clear();
    caloriesController.clear();

    serverTime.clear();

    isDineIn.value = true;
    isDelivery.value = true;
    isTakeAway.value = true;
    isLiveWeb.value = false;
    // isEgg.value = false;
    variations.clear();
    formKeys.clear();
    isValidated.clear();
    // variations.add({
    //   "nameController": TextEditingController(),
    //   "selectionType": "multi",
    //   "minController": TextEditingController(),
    //   "maxController": TextEditingController(),
    //   "required": "off",
    //   "options": [
    //     {
    //       "optionNameController": TextEditingController(),
    //       "priceController": TextEditingController()
    //     }
    //   ],
    // });
    // formKeys.add(GlobalKey<FormState>());
    categoryNames.clear();
    addonMyList.clear();
    selectedAllergens.clear();
    update();
  }

//*bulk Export
  RxBool isExportLoader = false.obs;
  RxBool isExportSubmitting = false.obs;
  bulkExport() async {
    try {
      if (isExportSubmitting.value) return;
      isExportSubmitting.value = true;
      isExportLoader.value = true;
      Map<String, dynamic> data = {"type": "all"};
      final response = await menuManagementRepo.bulkExport(data: data);
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("bulkExport :$e");
    } finally {
      isExportLoader.value = false;
      isExportSubmitting.value = false;
    }
  }

  //* exportSample
  RxBool exportSampleLoader = false.obs;
  RxBool isExportSampleSubmitting = false.obs;

  exportSample() async {
    try {
      if (isExportSampleSubmitting.value) return;
      isExportSampleSubmitting.value = true;
      exportSampleLoader.value = true;
      final response = await menuManagementRepo.exportSample();
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      }
      update();
    } catch (e) {
      log("exportSample :$e");
    } finally {
      exportSampleLoader.value = false;
      isExportSampleSubmitting.value = false;
    }
  }

  String? chooseFilePath;
  bool chooseFileLoader = false;

  TextEditingController ChooseFileController = TextEditingController();

  Future<void> pickExcelFile() async {
    chooseFileLoader = true;
    update();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      chooseFilePath = result.files.single.path;
      print("chooseFilePath :$chooseFilePath");
      ChooseFileController.text = chooseFilePath?.split("/").last ?? "";
      update();
    } else {
      log("No file selected or file path is null.");
    }
    chooseFileLoader = false;
    update();
  }

  // * bulk-import
  RxBool isImportLoader = false.obs;
  RxBool isBulkImportSubmitting = false.obs;
  bulkImport() async {
    try {
      if (chooseFilePath?.isNotEmpty ?? false) {
        if (isBulkImportSubmitting.value) return;
        isBulkImportSubmitting.value = true;
        isImportLoader.value = true;
        final response = await menuManagementRepo.bulkImport(
          keyFileName: 'products_file',
          data: {},
          fileName: chooseFilePath ?? "",
        );
        if (response?.statusCode == 200) {
          Get.back();
          await fetchFoodList(
            isVeg: isVegSwitched.value,
            isNoVeg: isNonVegSwitched.value,
            isEgg: isEggSwitched.value,
            isJain: isJainSwitched.value,
            category: selectedCategory.value,
            status: selectedStatus.value,
          );
          Get.snackbar(
              response?.body['message'] ?? 'Message',
              'Imported: ${response?.body?["imported"]}, '
              'Updated: ${response?.body?["updated"]}'
              '${response?.body?.containsKey("duplicates") == true ? ", Duplicates: ${response?.body?["duplicates"]?.length ?? 0}" : ""}',
              backgroundColor: Colors.green,
              colorText: Colors.white);
          // appToast(response?.body?["message"]);
          print(
              'Imported:${response?.body?["imported"]} , Updated:${response?.body?["updated"]} , Duplicates:${response?.body?["duplicates"].length}');
          chooseFilePath = null;
          ChooseFileController.clear();
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else if (response?.statusCode == 201) {
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(response?.body['errors'])
              : Get.snackbar('Error', response?.body['errors'],
                  backgroundColor: Colors.redAccent, colorText: Colors.white);
          print(response?.body['errors']);
        } else {
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(response?.body['errors'])
              : Get.snackbar('Error', response?.body['errors'],
                  backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        update();
      } else {
        appToast(AppString.pleaseChooseFile);
      }
    } catch (e) {
      log("bulkImport error: $e");
    } finally {
      isImportLoader.value = false;
      isBulkImportSubmitting.value = false;
    }
  }

  //****************************************** Categories ******************************************//

  // Only one category api is using for category screen as well as menu edit/add categroy selection & category filter

  TextEditingController categoriesSearchController = TextEditingController();
  TextEditingController categoriesController = TextEditingController();
  TextEditingController categoryOrderController = TextEditingController();

  var menuManagementCategoryList = <Map<String, dynamic>>[];
  var stationList = <Map<String, dynamic>>[];
  Map<String, dynamic> stationListMap = {};

  String? selectedStationName = '';
  RxBool isCategoryNameEmpty = false.obs;
  RxBool isSatationNameEmpty = false.obs;

  bool isEditCategories = false;
  RxBool isCategoryLoader = false.obs;
  RxBool isCategorySubmitting = false.obs;
  RxBool isMenuCategoryLoader = false.obs;

  getMenuManagementCategories() async {
    try {
      isMenuCategoryLoader.value = true;
      update();
      final response = await menuManagementRepo.getMenuManagementCategories();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body;
        menuManagementCategoryList = List<Map<String, dynamic>>.from(data);
        // menuManagementCategoryList.sort(
        //     (a, b) => (a['position'] as int).compareTo(b['position'] as int));
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getMenuManagementCategories :$e");
    } finally {
      isMenuCategoryLoader.value = false;
      update();
    }
  }

  getStationList() async {
    try {
      final response = await menuManagementRepo.getStationList();

      if (response?.statusCode == 200) {
        final body = response?.body ?? {};
        final List<dynamic> data = body["printers"] ?? [];
        // stationList = [
        //   for (var item in data)
        //     {
        //       "area_name": item["area_name"],
        //       "id": item["id"],
        //     }
        // ];
        // stationListMap = {
        //   for (var item in data) item["area_name"]: item["id"],
        // };
        // Add "No Station" as the first option
        stationList = [
          {
            "area_name": "No Station",
            "id": null,
          },
          ...[
            // Spread the rest of the stations
            for (var item in data)
              {
                "area_name": item["area_name"],
                "id": item["id"],
              }
          ]
        ];

        stationListMap = {
          "No Station": null, // Map "No Station" to null
          for (var item in data) item["area_name"]: item["id"],
        };
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getStationList :$e");
    }
  }

  AddCategories() async {
    try {
      if (categoriesController.text.isNotEmpty) {
        if (isCategorySubmitting.value) return;
        isCategorySubmitting.value = true;
        isCategoryLoader.value = true;
        // Check if "No Station" is selected
        final isNoStation = selectedStationName == "No Station";
        Map<String, String> data = {
          "name": categoriesController.text.trim(),
          "cat_type": "food",
          "vendor_type": "restaurant",
          "station_name": isNoStation ? "" : (selectedStationName ?? ""),
          "restaurant_printer_id": isNoStation
              ? ""
              : (stationListMap[selectedStationName]?.toString() ?? ""),
          "cat_order": categoryOrderController.text.isNotEmpty
              ? categoryOrderController.text.trim()
              : "0",
        };
        //  log("AddCategories data $data");

        final response = await menuManagementRepo.addCategoryWithImage(
          data: data,
          image: categoryImageFile,
        );
        if (response.statusCode == 200) {
          Get.back();
          categoriesSearchController.clear();
          await getMenuManagementCategories();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(AppString.addNewCategorySuccessfully)
              : Get.snackbar(
                  response.body['message'] ?? "Category created successfully.",
                  'CategoryId : ${response.body['category_id'] ?? ''}',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
          resetCategoryData();
          await productCategories();
        } else if (response.statusCode == 401) {
          ApiChecker.checkApi(response);
        } else {
          Get.snackbar("Something Wrong !", response.body['error'] ?? '',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        appToast(AppString.pleaseEnterCategoryName);
      }
    } catch (e) {
      log("productAddCategories :$e");
    } finally {
      isCategoryLoader.value = false;
      isCategorySubmitting.value = false;
    }
  }

  updateCategories(
    int id,
  ) async {
    try {
      if (categoriesController.text.isNotEmpty) {
        if (isCategorySubmitting.value) return;
        isCategorySubmitting.value = true;
        isCategoryLoader.value = true;
        // Check if "No Station" is selected
        final isNoStation = selectedStationName == "No Station";
        Map<String, String> data = {
          "name": categoriesController.text.trim(),
          "cat_type": "food",
          "vendor_type": "restaurant",
          "station_name": isNoStation ? "" : (selectedStationName ?? ""),
          "restaurant_printer_id": isNoStation
              ? "0"
              : (stationListMap[selectedStationName] ?? 0).toString(),
          "cat_order": categoryOrderController.text.isNotEmpty
              ? categoryOrderController.text.trim()
              : "0",
        };

        // log("updateCategories data $data");
        final response = await menuManagementRepo.updateCategoryWithImage(
          id: id,
          data: data,
          image: categoryImageFile,
        );

        if (response.statusCode == 200) {
          Get.back();
          categoriesSearchController.clear();
          await getMenuManagementCategories();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(
                  response.body["message"] ?? "Category updated successfully")
              : Get.snackbar(
                  'UPDATED',
                  response.body['message'] ?? "Category Updated successfully.",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else if (response.statusCode == 401) {
          ApiChecker.checkApi(response);
        } else {
          Get.snackbar("Something Wrong !", response.body['error'] ?? '',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        update();
      } else {
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(AppString.pleaseEnterCategoryName)
            : Get.snackbar(
                'AppString.pleaseEnterCategoryName',
                '',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
        ;
      }
    } catch (e) {
      log("updateCategories :$e");
    } finally {
      isCategoryLoader.value = false;
      isCategorySubmitting.value = false;
    }
  }

  deleteCategories(int id) async {
    try {
      isCategoryLoader.value = true;
      update();
      final response = await menuManagementRepo.deleteCategories(id);
      if (response?.statusCode == 200) {
        await getMenuManagementCategories();

        (Platform.isAndroid || Platform.isIOS)
            ? appToast(response?.body?['message'])
            : Get.snackbar(
                'DELETED',
                response?.body?['message'] ?? "Category Deleted successfully.",
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
        // Get.back();
      } else if (response?.statusCode == 401) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar("Something Wrong !", response?.body?['error'] ?? '',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log("deleteCategories :$e");
    } finally {
      isCategoryLoader.value = false;
      update();
    }
  }

  categoriesStatusChange(int id, {required Map<String, dynamic> data}) async {
    try {
      final response =
          await menuManagementRepo.categoriesStatusChange(id, data: data);

      if (response?.statusCode == 200) {
        await getMenuManagementCategories();
        appToast(response?.body?['message']);
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("categoriesStatusChange :$e");
    }
  }

  exportCategorySample() async {
    exportSampleLoader.value = true;
    update();
    print('Downloading Cateogry Bulk Import Sample Excel File ...');
    await appLaunchUrl(
        '${AppConstants.BASE_URL}/bulk_upload_sample/menu_category/Category_Bulk_Import_Sample.xlsx');
    print('Category Bulk Upload Downloaded Successfully.');
    Get.snackbar('Downloaded Successfully',
        'Cateogry Bulk Upload Downloaded Successfully.',
        backgroundColor: ColorTheme.green, colorText: Colors.white);
    exportSampleLoader.value = false;
    update();
  }

  exportCategories() async {
    try {
      isExportLoader.value = true;
      final response = await menuManagementRepo.exportCategories();

      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_link"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("exportCategories :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

  importCategories() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );

      // if (result != null && result.files.single.path != null) {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await menuManagementRepo.importCategories(
          data: {},
          fileName: chooseFilePath ?? '',
          keyFileName: 'file',
        );
        if (response?.statusCode == 200) {
          Get.back();
          await getMenuManagementCategories();
          // appToast(response?.body?["message"]);
          final successList = response?.body?["success"] as List? ?? [];
          final errorsList = response?.body?["errors"] as List? ?? [];

          String formattedSuccess = "";
          if (successList.isNotEmpty) {
            if (successList.length == 1) {
              formattedSuccess = successList.first;
            } else if (successList.length == 2) {
              formattedSuccess = "${successList.first}, ${successList.last}";
            } else {
              formattedSuccess =
                  "${successList.first}, ..., ${successList.last}";
            }
          }

          String formattedErrors = "";
          if (errorsList.isNotEmpty) {
            if (errorsList.length == 1) {
              formattedErrors = errorsList.first;
            } else if (errorsList.length == 2) {
              formattedErrors = "${errorsList.first}, ${errorsList.last}";
            } else {
              formattedErrors = "${errorsList.first}, ..., ${errorsList.last}";
            }
          }

          String snackMessage = "";
          if (formattedSuccess.isNotEmpty) {
            snackMessage += "Success: $formattedSuccess\n";
          }
          if (formattedErrors.isNotEmpty) {
            snackMessage += "Errors: $formattedErrors";
          }

          Get.snackbar(
            response?.body?['message'] ?? "Import Result",
            snackMessage.trim(),
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Error', response?.body?["error"],
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        chooseFilePath = null;
        ChooseFileController.clear();
        update();
      } else {
        log("No file selected or file path is null.");

        Get.snackbar('Check Again', AppString.pleaseChooseFile,
            backgroundColor: ColorTheme.appColor, colorText: Colors.white);
      }

      update();
    } catch (e) {
      appToast(AppString.somethingWrong);
      log("importCategories :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  resetCategoryData() {
    categoriesController.clear();
    categoryOrderController.clear();
    selectedStationName = '';
    isEditCategories = false;
    // Clear category image data
    categoryImageFile = null;
    categoryImageUrl = null;
    categoryImageFileName = null;
    isCategoryImageUploaded = false;
    update();
  }

  //****************************************** Categories ******************************************//

  exportAddonSample() async {
    exportSampleLoader.value = true;
    update();
    print('Downloading Addon Bulk Import Sample Excel File ...');
    await appLaunchUrl(
        '${AppConstants.BASE_URL}/bulk_upload_sample/menu_addon/Addon_Bulk_Import_Sample.xlsx');
    print('Addon Bulk Upload Downloaded Successfully.');
    Get.snackbar(
        'Downloaded Successfully', 'Addon Bulk Upload Downloaded Successfully.',
        backgroundColor: ColorTheme.green, colorText: Colors.white);
    exportSampleLoader.value = false;
    update();
  }

  exportWithoutAddon() async {
    try {
      isExportLoader.value = true;
      final response = await menuManagementRepo.exportAddon();
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("exportWithoutAddon :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

  importAddon() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );

      // if (result != null && result.files.single.path != null) {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await menuManagementRepo.importAddon(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: 'file',
        );

        if (response?.statusCode == 200) {
          Get.back();
          await getAddonList();
          // appToast(response?.body?["message"]);
          final successList = response?.body?["success"] as List? ?? [];
          final errorsList = response?.body?["errors"] as List? ?? [];

          String formattedSuccess = "";
          if (successList.isNotEmpty) {
            if (successList.length == 1) {
              formattedSuccess = successList.first;
            } else if (successList.length == 2) {
              formattedSuccess = "${successList.first}, ${successList.last}";
            } else {
              formattedSuccess =
                  "${successList.first}, ..., ${successList.last}";
            }
          }

          String formattedErrors = "";
          if (errorsList.isNotEmpty) {
            if (errorsList.length == 1) {
              formattedErrors = errorsList.first;
            } else if (errorsList.length == 2) {
              formattedErrors = "${errorsList.first}, ${errorsList.last}";
            } else {
              formattedErrors = "${errorsList.first}, ..., ${errorsList.last}";
            }
          }

          String snackMessage = "";
          if (formattedSuccess.isNotEmpty) {
            snackMessage += "Success: $formattedSuccess\n";
          }
          if (formattedErrors.isNotEmpty) {
            snackMessage += "Errors: $formattedErrors";
          }

          Get.snackbar(
            response?.body?['message'] ?? "Import Result",
            snackMessage.trim(),
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Error', response?.body?["error"],
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }

        chooseFilePath = null;
        ChooseFileController.clear();
        update();
      } else {
        log("No file selected or file path is null.");
        Get.snackbar('Check Again', AppString.pleaseChooseFile,
            backgroundColor: ColorTheme.appColor, colorText: Colors.white);
      }
      update();
    } catch (e) {
      appToast(AppString.somethingWrong);
      log("importAddon :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  Future<XFile?>? testCompressAndGetFile(File file) async {
    final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
    final splitted = file.path.substring(0, (lastIndex));
    final outPath = '${splitted}_out${file.path.substring(lastIndex)}';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      // minWidth: 700,
      quality: 50,
    );

    return result;
  }

  pickImageFromGallery() async {
    try {
      isloading = true;
      isImageUploaded = false;
      update();

      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        isloading = false;
        update();
        return;
      }

      imageFileName = image.name;
      //here checking the image file size
      // int sizeInBytes = await image.length();
      // double sizeInKb = sizeInBytes / 1024;
      // if (sizeInKb < 5 || sizeInKb > 900) {
      //   Get.snackbar(
      //     'Image File size',
      //     'Image size should be between 5KB and 900KB',
      //     backgroundColor: Colors.red.withOpacity(0.5),
      //     colorText: Colors.white,
      //   );
      //   isloading = false;
      //   update();
      //   return;
      // }
      // if (await image.length() > 900000)
      //   image = await testCompressAndGetFile(File(image.path));

      //here checking the image file format
      final fileExt = image.path.toLowerCase();
      bool isAllowed = allowedExtensions.any((ext) => fileExt.endsWith(ext));
      if (!isAllowed) {
        Get.snackbar(
          'Image File format',
          'Image format should be ${allowedExtensions.join(", ")}',
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // Image accepted
      imageFile = image;
      isImageUploaded = true;
      // log('🧪 imageFile path: ${imageFile?.path}');
      // log('🧪 imageFile exists: ${imageFile != null && await File(imageFile!.path).exists()}');
    } catch (e) {
      print("pickImageFromGallery : $e");
    } finally {
      isloading = false;
      update();
    }
  }

  // ----------------------- PICK CATEGORY IMAGE -----------------------
  Future<void> pickCategoryImage() async {
    try {
      isloading = true;
      isCategoryImageUploaded = false;
      update();

      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        isloading = false;
        update();
        return;
      }

      categoryImageFileName = image.name;
      print(categoryImageFileName);
      print(image.path);
      // Format validation (reuse allowedExtensions)
      final fileExt = image.path.toLowerCase();
      bool isAllowed = allowedExtensions.any((ext) => fileExt.endsWith(ext));
      if (!isAllowed) {
        Get.snackbar(
          'Image File format',
          'Image format should be ${allowedExtensions.join(", ")}',
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // Image accepted
      categoryImageFile = image;
      isCategoryImageUploaded = true;
    } catch (e) {
      print("pickCategoryImage : $e");
    } finally {
      isloading = false;
      update();
    }
  }

  // ----------------------- PICK SWIGGY IMAGE -----------------------
  pickSwiggyImage() async {
    try {
      isloading = true;
      update();

      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        isloading = false;
        update();
        return;
      }

      swiggyFileName = image.name;

      // File size check (Swiggy did not give strict MB limit, but we can keep max 5MB)
      int sizeInBytes = await image.length();
      double sizeInMB = sizeInBytes / (1024 * 1024);
      if (sizeInMB > 5) {
        Get.snackbar(
          'Swiggy Image',
          'Image size should be below 5 MB',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // Format check (JPG only)
      final fileExt = image.path.toLowerCase();
      bool isAllowed =
          allowedExtensionsSwiggy.any((ext) => fileExt.endsWith(ext));
      if (!isAllowed) {
        Get.snackbar(
          'Swiggy Image',
          'Image format should be JPG only',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // TODO: Aspect ratio validation (17:13 or 11:13)
      // You can use flutter `package:image` to check width/height
      // and warn user if ratio not matching.

      swiggyImageFile = image;
    } catch (e) {
      print("pickSwiggyImage : $e");
    } finally {
      isloading = false;
      update();
    }
  }

// ----------------------- PICK ZOMATO IMAGE -----------------------
  pickZomatoImage() async {
    try {
      isloading = true;
      update();

      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        isloading = false;
        update();
        return;
      }

      zomatoFileName = image.name;

      // File size check (Below 20 MB)
      int sizeInBytes = await image.length();
      double sizeInMB = sizeInBytes / (1024 * 1024);
      if (sizeInMB > 20) {
        Get.snackbar(
          'Zomato Image',
          'Image size should be below 20 MB',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // Format check (PNG or JPG)
      final fileExt = image.path.toLowerCase();
      bool isAllowed =
          allowedExtensionsZomato.any((ext) => fileExt.endsWith(ext));
      if (!isAllowed) {
        Get.snackbar(
          'Zomato Image',
          'Image format should be PNG or JPG',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        isloading = false;
        update();
        return;
      }

      // TODO: Dimension validation (1024x768)
      // Using `package:image` or `flutter_image_compress` you can check width & height.

      zomatoImageFile = image;
    } catch (e) {
      print("pickZomatoImage : $e");
    } finally {
      isloading = false;
      update();
    }
  }

  //****************************************** PREP SERVE TIME REPORT ******************************************//

  // Prep Serve Time Report Variables
  String? prepServeTimeStartDate;
  String? prepServeTimeEndDate;
  RxBool isPrepServeTimeReportLoading = false.obs;
  List<Map<String, dynamic>> prepServeTimeReportList = [];

  Future<void> getPrepServeTimeReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      isPrepServeTimeReportLoading.value = true;
      update();

      // Convert date from dd-MM-yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> data = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      final response =
          await menuManagementRepo.getPrepServeTimeReport(data: data);

      if (response?.statusCode == 200) {
        if (response?.body?['status'] == true &&
            response?.body?['data'] != null) {
          List<dynamic> dataList = response?.body?['data'] ?? [];
          prepServeTimeReportList = List<Map<String, dynamic>>.from(dataList);
        } else {
          prepServeTimeReportList = [];
          Get.snackbar(
            'No Data',
            'No data found for the selected date range',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response!);
        prepServeTimeReportList = [];
      }
      update();
    } catch (e) {
      log("getPrepServeTimeReport Error: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch prep serve time report',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      prepServeTimeReportList = [];
    } finally {
      isPrepServeTimeReportLoading.value = false;
      update();
    }
  }

  String _convertDateFormat(String date) {
    try {
      // Convert from dd-MM-yyyy to yyyy-MM-dd
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return date;
    } catch (e) {
      log("_convertDateFormat Error: $e");
      return date;
    }
  }

  RxBool isPrepServeTimeExportLoading = false.obs;
  RxBool isPrepServeTimeExportSubmitting = false.obs;

  Future<void> exportPrepServeTimeReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      if (isPrepServeTimeExportSubmitting.value) return;
      isPrepServeTimeExportSubmitting.value = true;
      isPrepServeTimeExportLoading.value = true;
      update();

      // Convert date from dd-MM-yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> data = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      final response =
          await menuManagementRepo.exportPrepServeTimeReport(data: data);

      if (response?.statusCode == 200) {
        if (response?.body?['status'] == true &&
            response?.body?['download_url'] != null) {
          appLaunchUrl(response?.body?["download_url"]);
          Get.snackbar(
            'Success',
            response?.body?['message'] ?? 'Report exported successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to export report',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("exportPrepServeTimeReport Error: $e");
      Get.snackbar(
        'Error',
        'Failed to export prep serve time report',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isPrepServeTimeExportLoading.value = false;
      isPrepServeTimeExportSubmitting.value = false;
      update();
    }
  }

  //****************************************** PREP SERVE TIME REPORT ******************************************//

  //====================== Cancellation Master Management ======================//

  var cancellationMasterList = <Map<String, dynamic>>[].obs;
  TextEditingController cancellationMasterSearchController =
      TextEditingController();
  TextEditingController cancellationMasterAddController =
      TextEditingController();
  RxBool isCancellationMasterLoading = false.obs;
  RxBool isCancellationMasterSubmitting = false.obs;
  RxBool isCancellationMasterStatusUpdating = false.obs;
  RxInt updatingCancellationReasonId = (-1).obs;
  RxInt editingCancellationReasonId =
      (-1).obs; // Track which item is being edited
  String? selectedUserType; // For dropdown: customer, restaurant, deliveryman

  List<String> userTypeOptions = ['customer', 'restaurant', 'deliveryman'];

  /// Clear cancellation master list
  void clearCancellationMasterList() {
    cancellationMasterList.clear();
    update();
  }

  /// Get cancellation reasons list
  Future<void> getCancellationMasterList() async {
    try {
      isCancellationMasterLoading.value = true;
      update();

      final response = await menuManagementRepo.getCancellationReasonsList();

      if (response?.statusCode == 200) {
        final responseBody = response?.body;
        if (responseBody != null && responseBody['data'] != null) {
          final List<dynamic> reasons = responseBody['data']['reasons'] ?? [];
          cancellationMasterList
              .assignAll(reasons.cast<Map<String, dynamic>>());
          log('Cancellation Master List: ${cancellationMasterList.length} items');
        } else {
          cancellationMasterList.clear();
        }
      } else {
        ApiChecker.checkApi(response!);
        cancellationMasterList.clear();
      }
      update();
    } catch (e) {
      log('getCancellationMasterList Error: $e');
      cancellationMasterList.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch cancellation reasons',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCancellationMasterLoading.value = false;
      update();
    }
  }

  /// Add new cancellation reason
  Future<void> addCancellationMasterReason() async {
    try {
      if (cancellationMasterAddController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Please enter cancellation reason',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (isCancellationMasterSubmitting.value) return;
      isCancellationMasterSubmitting.value = true;
      update();

      Map<String, dynamic> data = {
        'reason': cancellationMasterAddController.text.trim(),
        'user_type': 'restaurant', // Default to restaurant
      };

      final response = await menuManagementRepo.addCancellationReason(data);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        cancellationMasterAddController.clear();
        selectedUserType = null; // Reset dropdown
        editingCancellationReasonId.value = -1; // Clear edit mode
        await getCancellationMasterList(); // Refresh list after adding
        Get.snackbar(
          'Success',
          response?.body?['message'] ??
              'Cancellation reason added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('addCancellationMasterReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to add cancellation reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCancellationMasterSubmitting.value = false;
      update();
    }
  }

  /// Update cancellation reason status
  Future<void> updateCancellationMasterStatus(int id, int currentStatus) async {
    try {
      if (isCancellationMasterStatusUpdating.value) return;
      isCancellationMasterStatusUpdating.value = true;
      updatingCancellationReasonId.value = id;
      update();

      // Toggle status: 1 -> 0, 0 -> 1
      final newStatus = currentStatus == 1 ? 0 : 1;

      Map<String, dynamic> data = {
        'status': newStatus,
      };

      final response =
          await menuManagementRepo.updateCancellationReasonStatus(id, data);

      if (response?.statusCode == 200) {
        await getCancellationMasterList(); // Refresh list after status update
        // Update only the specific item that was changed
        update(['cancellation_item_$id']);
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Status updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('updateCancellationMasterStatus Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCancellationMasterStatusUpdating.value = false;
      updatingCancellationReasonId.value = -1;
      update();
    }
  }

  /// Get filtered cancellation reasons based on search
  List<Map<String, dynamic>> getFilteredCancellationMasterList() {
    if (cancellationMasterSearchController.text.trim().isEmpty) {
      return cancellationMasterList.toList();
    }

    final searchQuery =
        cancellationMasterSearchController.text.trim().toLowerCase();
    return cancellationMasterList
        .where((reason) =>
            (reason['reason']?.toString().toLowerCase() ?? '')
                .contains(searchQuery) ||
            (reason['user_type']?.toString().toLowerCase() ?? '')
                .contains(searchQuery))
        .toList();
  }

  /// Update cancellation reason
  RxBool isCancellationMasterUpdating = false.obs;
  Future<void> updateCancellationReason(
      int id, String reason, String userType) async {
    try {
      if (isCancellationMasterUpdating.value) return;
      isCancellationMasterUpdating.value = true;
      update();

      Map<String, dynamic> data = {
        'reason': reason.trim(),
        'user_type': 'restaurant',
      };

      final response =
          await menuManagementRepo.updateCancellationReason(id, data);

      if (response?.statusCode == 200) {
        cancellationMasterAddController.clear();
        selectedUserType = null;
        editingCancellationReasonId.value = -1; // Clear edit mode
        await getCancellationMasterList(); // Refresh list after updating
        Get.snackbar(
          'Success',
          response?.body?['message'] ??
              'Cancellation reason updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('updateCancellationReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update cancellation reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCancellationMasterUpdating.value = false;
      update();
    }
  }

  /// Delete cancellation reason
  RxBool isCancellationMasterDeleting = false.obs;
  Future<void> deleteCancellationReason(int id) async {
    try {
      if (isCancellationMasterDeleting.value) return;
      isCancellationMasterDeleting.value = true;
      update();

      final response = await menuManagementRepo.deleteCancellationReason(id);

      if (response?.statusCode == 200) {
        // If the deleted item was being edited, clear edit mode
        if (editingCancellationReasonId.value == id) {
          cancellationMasterAddController.clear();
          selectedUserType = null;
          editingCancellationReasonId.value = -1;
        }
        await getCancellationMasterList(); // Refresh list after deleting
        Get.snackbar(
          'Success',
          response?.body?['message'] ??
              'Cancellation reason deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('deleteCancellationReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete cancellation reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCancellationMasterDeleting.value = false;
      update();
    }
  }

  //====================== Cancellation Master Management ======================//

  //====================== SOCKET  ======================//
  /// Handles Create and Update socket events
  void handleSocketFoodUpdate(Map<String, dynamic> socketPayload) {
    try {
      if (socketPayload['food_details'] != null) {
        Map<String, dynamic> incomingSocketData =
            Map<String, dynamic>.from(socketPayload['food_details']);

        // Find the food item in our local list safely using toString()
        int existingIndex = foodList.indexWhere((food) =>
            food['id'].toString() == incomingSocketData['id'].toString());

        if (existingIndex != -1) {
          // --- PARTIAL UPDATE ---
          // Grab the exact object currently sitting in local memory
          Map<String, dynamic> localFoodItem =
              Map<String, dynamic>.from(foodList[existingIndex]);

          // Loop through ONLY the keys the socket sent us and overwrite them exactly as they are
          incomingSocketData.forEach((key, value) {
            localFoodItem[key] = value;
          });

          if (incomingSocketData.containsKey('add_ons')) {
             if ((incomingSocketData['add_ons'] as List).isEmpty) {
                localFoodItem['addons'] = []; 
                localFoodItem['addon_ids'] = []; 
             }
          }

          // --- FIX CATEGORY & ITEM TYPE ---

          // Fix Category Mapping (UI expects full category object, socket sends category_id)
          if (localFoodItem['category_id'] != null) {
            var matchingCategory = productCategoryList.firstWhere(
                (cat) =>
                    cat['id'].toString() ==
                    localFoodItem['category_id'].toString(),
                orElse: () =>
                    {"id": localFoodItem['category_id'], "name": "Unknown"});
            localFoodItem['category'] = matchingCategory;
          }

          // Map the socket's 'veg' key to the API's 'item_type' key
          localFoodItem['item_type'] =
              localFoodItem['veg'] ?? localFoodItem['item_type'] ?? 0;

          // --- FILTER CHECK & SAVE ---
          bool matchesFilters = _matchesCurrentFilters(localFoodItem);

          if (matchesFilters) {
            foodList[existingIndex] = localFoodItem;
          } else {
            foodList.removeAt(
                existingIndex); // Remove if it no longer matches user's active filters
          }
        } else {
          // --- IT'S A BRAND NEW ITEM ---

          incomingSocketData['item_type'] = incomingSocketData['veg'] ?? 0;

          if (incomingSocketData['category_id'] != null) {
            incomingSocketData['category'] = productCategoryList.firstWhere(
                (cat) =>
                    cat['id'].toString() ==
                    incomingSocketData['category_id'].toString(),
                orElse: () => {
                      "id": incomingSocketData['category_id'],
                      "name": "Unknown"
                    });
          }

          if (_matchesCurrentFilters(incomingSocketData)) {
            foodList.insert(0, incomingSocketData);
          }
        }

        // Trigger UI rebuild
        update();
      }
    } catch (e) {
      log("handleSocketFoodUpdate Error: $e");
    }
  }

  /// Handles Delete socket events
  void handleSocketFoodDelete(Map<String, dynamic> socketPayload) {
    try {
      if (socketPayload['food_id'] != null) {
        // Added .toString() to both sides to prevent type-mismatch bugs!
        foodList.removeWhere((food) =>
            food['id'].toString() == socketPayload['food_id'].toString());
        update();
      }
    } catch (e) {
      log("handleSocketFoodDelete Error: $e");
    }
  }

  /// Helper: Checks if incoming socket data should be visible based on active dropdowns/switches
  bool _matchesCurrentFilters(Map<String, dynamic> food) {
    // 1. Food For Dropdown Match (Normal, Aggregator, etc.)
    if (food["food_for"] != filterFoodFor) return false;

    if (isCategoryUnavailableForAggregator(selectedCategory.value)) {
      return false;
    }

    // 2. Category Dropdown Match
    bool categoryMatch = selectedCategory.value.isEmpty ||
        (food["category"] != null &&
            food["category"]["name"] == selectedCategory.value);

    // 3. Status Dropdown Match
    bool statusMatch =
        selectedStatus.value == null || food["status"] == selectedStatus.value;

    // 4. Food Type Switches Match (Veg, Non-Veg, Egg, Jain)
    bool typeMatch = false;
    int itemType = food["item_type"];

    if (isVegSwitched.value && itemType == 1) typeMatch = true;
    if (isNonVegSwitched.value && itemType == 0) typeMatch = true;
    if (isEggSwitched.value && itemType == 2) typeMatch = true;
    if (isJainSwitched.value && itemType == 3) typeMatch = true;

    // If all switches are ON, or all switches are OFF, show everything
    bool allOnOrOff = (isVegSwitched.value &&
            isNonVegSwitched.value &&
            isEggSwitched.value &&
            isJainSwitched.value) ||
        (!isVegSwitched.value &&
            !isNonVegSwitched.value &&
            !isEggSwitched.value &&
            !isJainSwitched.value);

    if (allOnOrOff) {
      return categoryMatch && statusMatch;
    }

    return categoryMatch && statusMatch && typeMatch;
  }
  //====================== SOCKET  ======================//
}
