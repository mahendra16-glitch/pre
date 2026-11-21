import 'dart:developer';
import 'dart:io';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/inventory_repo/inventory_repo.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class InventoryController extends GetxController implements GetxService {
  final InventoryRepo inventoryRepo;
  InventoryController({required this.inventoryRepo});

  //* add Stock
  TextEditingController searchController = TextEditingController();
  TextEditingController addStockVendorController = TextEditingController();
  TextEditingController addStockPurchaseDateController =
      TextEditingController();
  TextEditingController addStockTotalTaxController = TextEditingController();
  TextEditingController addStockItemQuantityController =
      TextEditingController();
  TextEditingController addStockTotalAmountController = TextEditingController();
  TextEditingController addStockTotalFairController = TextEditingController();
  TextEditingController thresholdQtyController = TextEditingController();
  String? thresholdUnitValue;
  String? addStockBrowseFilePath;
  String? paymentTypeValue;
  int? addStockVendorId;

  RxBool isImportLoader = false.obs;
  RxBool isExportLoader = false.obs;
  RxBool exportSampleLoader = false.obs;
  bool chooseFileLoader = false;
  TextEditingController ChooseFileController = TextEditingController();
  String? chooseFilePath;

  String stockFilter = 'All'; // 'All' or 'Low Stock'
  String? categoryFilter; // Selected category name for filtering

  void setStockFilter(String value) {
    stockFilter = value;
    update();
  }

  void setCategoryFilter(String? value) {
    categoryFilter = value;
    update();
  }

  // current Stock Quantity order

  bool showMoreInfoPanel = false;
  bool stockQuantityOrderFilter = true;
  setStockOrderFilter() {
    stockQuantityOrderFilter = !stockQuantityOrderFilter;
    update();
  }

  List<String> unitList = [
    "kg",
    "ltr",
    "bundle",
    "pkt",
    "piece",
    'pieces',
    "bottle",
  ];

  List<String> threSholdUnitList = [
    "kg",
    "gm",
    "ltr",
    "ml",
    "bundle",
    "pkt",
    "piece",
    'pieces',
    "bottle",
  ];

  //* edit stock
  TextEditingController editStockIngredientNameController =
      TextEditingController();
  TextEditingController editIngredientsNameController = TextEditingController();
  TextEditingController editStockQuantityController = TextEditingController();
  int? editIngredientId;
  String? editUnitValue;

  //* ingredients
  List<Map<String, dynamic>> ingredientsList = [
    addIngredients(),
  ];

  TextEditingController categoryIngredientsController = TextEditingController();
  static Map<String, dynamic> addIngredients() {
    return {
      "categoryId": "",
      "categoryController": TextEditingController(),
      "ingredientsName": TextEditingController(),
      "bigUnit": "",
      "unit": "",
      "smallUnit": "",
      "thresholdQuantity": TextEditingController(),
    };
  }

  addIngredientsData() {
    ingredientsList.add(InventoryController.addIngredients());
    update();
  }

  removeIngredientsData(int index) {
    ingredientsList.removeAt(index);
    update();
  }

  resetIngredientsData() {
    ingredientsList.clear();
    ingredientsList.add(InventoryController.addIngredients());
    update();
  }

  //* purchase stock
  List<Map<String, dynamic>> purchaseList = [
    addPurchase(),
  ];

  TextEditingController ingredientsPurchaseController = TextEditingController();
  TextEditingController batchController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController consumptionUnitController = TextEditingController();
  TextEditingController conversionFactorController = TextEditingController();

  static Map<String, dynamic> addPurchase() {
    return {
      "ingredientsId": "",
      "ingredientsController": TextEditingController(),
      "unit": "",
      "quantity": TextEditingController(),
      "amount": TextEditingController(),
      "currentStock": TextEditingController(),
      "physicalQty": TextEditingController(),
      "batch": TextEditingController(),
      "brand": TextEditingController(),
      "expiry": TextEditingController(),
      "expiry_date": TextEditingController(),
      "consumption_unit": TextEditingController(),
      "conversion_factor": TextEditingController(),
    };
  }

  addPurchaseData() {
    purchaseList.add(InventoryController.addPurchase());
    update();
  }

  removePurchaseData(int index) {
    purchaseList.removeAt(index);
    update();
  }

  //* totalAmount logic
  totalAmount() {
    num totalAmount = 0;
    int purchaseListTotal = purchaseList.fold(0, (int sum, item) {
      int amount = int.tryParse(item["amount"].text) ?? 0;
      return sum + amount;
    });
    totalAmount += purchaseListTotal;
    double parseControllerText(TextEditingController controller) {
      return double.tryParse(controller.text) ?? 0;
    }

    totalAmount += parseControllerText(addStockTotalTaxController).truncate();
    totalAmount += parseControllerText(addStockTotalFairController).truncate();

    addStockTotalAmountController.text = totalAmount.toString();
    log("total amount :${addStockTotalAmountController.text}");
  }

  var stockList = <Map<String, dynamic>>[].obs;
  bool isStockLoader = false;

  setFoodLoader(bool val) {
    isStockLoader = val;
    update();
  }

  getCurrentStock() async {
    try {
      setFoodLoader(true);
      final response = await inventoryRepo.stockInventory();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['current_stocks'] ?? [];
        stockList.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getCurrentStock :$e");
    } finally {
      setFoodLoader(false);
    }
  }

  var inventoryIngredientsList = <Map<String, dynamic>>[].obs;
  getInventoryIngredients() async {
    try {
      final response = await inventoryRepo.getInventoryIngredients();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['data'] ?? [];
        inventoryIngredientsList.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getInventoryIngredients :$e");
    }
  }

  clearStockData() {
    addStockVendorController.clear();
    addStockItemQuantityController.clear();
    paymentTypeValue = null;
    addStockBrowseFilePath = null;
    addStockTotalFairController.clear();
    addStockVendorController.clear();
    addStockTotalAmountController.clear();
    addStockTotalTaxController.clear();
    addStockPurchaseDateController.clear();
    ingredientsPurchaseController.clear();
    batchController.clear();
    brandController.clear();
    consumptionUnitController.clear();
    conversionFactorController.clear();
    expiryController.clear();
    expiryDateController.clear();
    thresholdQtyController.clear();
    thresholdUnitValue = null;
    purchaseList.clear();
    showMoreInfoPanel = false;
    purchaseList.add({
      "ingredientsId": "",
      "unit": "",
      "ingredientsController": TextEditingController(),
      "quantity": TextEditingController(),
      "amount": TextEditingController(),
      "currentStock": TextEditingController(),
      "physicalQty": TextEditingController(),
    });
  }

  //* update stock status
  updateStockStatus(int id, {required Map<String, dynamic> data}) async {
    try {
      final response = await inventoryRepo.updateStockStatus(id, data: data);

      if (response?.statusCode == 200) {
        await getCurrentStock();
        appToast(response?.body?["message"] ?? AppString.somethingWrong);
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("updateStockStatus :$e");
    }
  }

  RxBool addIngredientsInventoryLoader = false.obs;
  RxBool addIngredientsInventorySubmitting = false.obs;
  addIngredientsInventory() async {
    try {
      if (addIngredientsInventorySubmitting.value) return;
      addIngredientsInventorySubmitting.value = true;
      addIngredientsInventoryLoader.value = true;

      List<Map<String, dynamic>> data = ingredientsList.map((e) {
        return {
          "category_id": e["categoryId"],
          "stock_title": e["ingredientsName"].text,
          "unit": e["bigUnit"],
          "small_unit": e["smallUnit"],
          "minimun_stock_alert": num.tryParse(e["thresholdQuantity"].text),
          "min_unit_alert": e["unit"]
        };
      }).toList();

      final response = await inventoryRepo.addIngredientsInventory(data: data);

      if (response?.statusCode == 200) {
        await getInventoryIngredients();
        await getCurrentStock();
        appToast(response?.body?["Message"]);
        if (response?.body?["success"] == true) {
          Get.back();
        }
      } else if (response?.statusCode == 500) {
        ApiChecker.checkApi(response!);
      } else {
        // Handle validation errors
        try {
          var responseBody = response?.body;
          String message = responseBody?["Message"] ?? "Validation failed";
          Map<String, dynamic>? errors = responseBody?["errors"];

          List<String> errorMessages = [];

          // Safely extract error messages for each field
          if (errors != null) {
            // Handle category_id errors
            if (errors.containsKey("category_id") &&
                errors["category_id"] != null) {
              var categoryErrors = errors["category_id"];
              if (categoryErrors is List && categoryErrors.isNotEmpty) {
                errorMessages.add("Category: ${categoryErrors.first}");
              } else if (categoryErrors is String) {
                errorMessages.add("Category: $categoryErrors");
              }
            }

            // Handle stock_title errors
            if (errors.containsKey("stock_title") &&
                errors["stock_title"] != null) {
              var stockTitleErrors = errors["stock_title"];
              if (stockTitleErrors is List && stockTitleErrors.isNotEmpty) {
                errorMessages.add("Stock Title: ${stockTitleErrors.first}");
              } else if (stockTitleErrors is String) {
                errorMessages.add("Stock Title: $stockTitleErrors");
              }
            }

            // Handle unit errors
            if (errors.containsKey("unit") && errors["unit"] != null) {
              var unitErrors = errors["unit"];
              if (unitErrors is List && unitErrors.isNotEmpty) {
                errorMessages.add("Unit: ${unitErrors.first}");
              } else if (unitErrors is String) {
                errorMessages.add("Unit: $unitErrors");
              }
            }
          }

          // Build the snackbar message
          String snackbarMessage = message;
          if (errorMessages.isNotEmpty) {
            snackbarMessage += "\n\n" + errorMessages.join("\n");
          }

          Get.snackbar(
            "Validation Error",
            snackbarMessage,
            // snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        } catch (e) {
          log("Error parsing validation errors: $e");
          // Fallback to generic error message
          Get.snackbar(
            "Error",
            response?.body?["Message"] ?? "An error occurred",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      log("addIngredientsInventory error: $e");
    } finally {
      addIngredientsInventoryLoader.value = false;
      addIngredientsInventorySubmitting.value = false;
    }
  }

  var categoryStockList = <Map<String, dynamic>>[].obs;
  getStockCategoryList() async {
    try {
      final response = await inventoryRepo.getStockCategories();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['data'] ?? [];
        categoryStockList.assignAll(data.cast<Map<String, dynamic>>());
        print("categoryStockList : ${categoryStockList.toList()}");
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getCategoryList :$e");
    }
  }

  TextEditingController categoryController = TextEditingController();
  RxBool isCategoryLoader = false.obs;
  RxBool isCategorySubmitting = false.obs;
  AddStockCategories() async {
    try {
      if (categoryController.text.isNotEmpty) {
        if (isCategorySubmitting.value) return;
        isCategorySubmitting.value = true;
        isCategoryLoader.value = true;
        Map<String, dynamic> data = {
          // "name": categoryController.text.trim(),
          "category_name": categoryController.text.trim(),
        };

        final response = await inventoryRepo.AddStockCategories(data: data);
        if (response?.statusCode == 201) {
          // if (isMenuCategory) {
          //   menuCategoryFunction?.call();
          // } else {
          //   await menuManagementController.getCategoryList();
          // }
          await getStockCategoryList();

          appToast(AppString.addNewCategorySuccessfully);
          Get.back();
        }
      } else {
        appToast(AppString.pleaseEnterCategoryName);
      }
    } catch (e) {
      log("addStockCategory :$e");
    } finally {
      isCategoryLoader.value = false;
      isCategorySubmitting.value = false;
    }
  }

  productAddCategories(MenuManagementController menuManagementController,
      {bool isMenuCategory = false, Function? menuCategoryFunction}) async {
    try {
      if (categoryController.text.isNotEmpty) {
        if (isCategorySubmitting.value) return;
        isCategorySubmitting.value = true;
        isCategoryLoader.value = true;
        Map<String, dynamic> data = {
          "name": categoryController.text.trim(),
        };

        final response = await inventoryRepo.productAddCategories(data: data);
        if (response?.statusCode == 200) {
          if (isMenuCategory) {
            menuCategoryFunction?.call();
          } else {
            await menuManagementController.getCategoryList();
          }

          appToast(AppString.addNewCategorySuccessfully);
          Get.back();
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

  //* vendor type
  List<Map<String, dynamic>> vendorTypeList = [];

  getVendorType() async {
    try {
      final response = await inventoryRepo.vendorType();

      if (response?.statusCode == 200 && response?.body is List) {
        vendorTypeList = List<Map<String, dynamic>>.from(
          response!.body.map((item) => Map<String, dynamic>.from(item)),
        );
      } else {
        ApiChecker.checkApi(response!);
      }

      log("vendorTypeList : ${vendorTypeList.toList()}");
      update();
    } catch (e) {
      log("vendorType error: $e");
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      addStockBrowseFilePath = result.files.single.path;

      log("addStockBrowseFilePath :$addStockBrowseFilePath");
      update();
    }
  }

  RxBool addInventoryStockLoader = false.obs;
  RxBool isAddInventorySubmitting = false.obs;
  addInventoryStock() async {
    try {
      if (isAddInventorySubmitting.value) return;
      isAddInventorySubmitting.value = true;
      addInventoryStockLoader.value = true;
      Map<String, dynamic> data = {
        "tot_amount":
            num.tryParse(addStockTotalAmountController.text.trim()) ?? 0,
        "item_total":
            num.tryParse(addStockItemQuantityController.text.trim()) ?? 0,
        "tot_fair": addStockTotalFairController.text.trim(),
        "tot_tax": num.tryParse(addStockTotalTaxController.text.trim()),
        "purchase_date": addStockPurchaseDateController.text.trim(),
        "payment_type": paymentTypeValue,
        "vendor_id": addStockVendorId,
        "invoice": addStockBrowseFilePath ?? "",
        "physicalqty_master": Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('physicalqty_master')
            ? true
            : false,
        "purchase_items": purchaseList.map((e) {
          return {
            "Ingredient": e["ingredientsId"],
            "quantity": num.tryParse(e["quantity"]?.text) ?? 0,
            "Unit": e["unit"],
            "Amount": num.tryParse(e["amount"]?.text) ?? 0,
            "physical_qty": e["physicalQty"]?.text,
            "batch": batchController.text,
            "brand": brandController.text ?? '',
            "expiry": expiryController.text ?? '',
            "expiry_date": expiryDateController.text ?? '',
            "consumption_unit": consumptionUnitController.text ?? "",
            "converion_factor": conversionFactorController.text ?? '',
            "waste_reason": getSelectedWastageReasonText() ??
                "Physical stock count adjustment",
          };
        }).toList(),
      };
      final response = await inventoryRepo.addInventoryStock(data);

      if (response?.statusCode == 200) {
        await getCurrentStock();
        appToast(AppString.addStockSuccessfully);
        Get.back();
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("addInventoryStock :$e");
    } finally {
      addInventoryStockLoader.value = false;
      isAddInventorySubmitting.value = false;
    }
  }

  updateStock(int id) async {
    try {
      if (isAddInventorySubmitting.value) return;
      isAddInventorySubmitting.value = true;
      addInventoryStockLoader.value = true;
      Map<String, dynamic> data = {
        "unit": purchaseList[0]["unit"],
        "quantity": purchaseList[0]["currentStock"].text,
        "min_qty_alert": thresholdQtyController.text.trim(),
        "min_unit_alert": thresholdUnitValue ?? "",
      };
      final response = await inventoryRepo.updateStock(id, data: data);

      if (response?.statusCode == 200) {
        appToast(AppString.updateStockSuccessfully);
        await getCurrentStock();
        Get.back();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("updateStock :$e");
    } finally {
      addInventoryStockLoader.value = false;
      isAddInventorySubmitting.value = false;
    }
  }

  inventoryExportStock() async {
    try {
      isExportLoader.value = true;

      final response = await inventoryRepo.inventoryExportStock();

      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("inventoryExportStock :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

  exportStockSample() async {
    try {
      exportSampleLoader.value = true;

      final response = await inventoryRepo.inventoryExportStock();

      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("inventoryExportStock :$e");
    } finally {
      exportSampleLoader.value = false;
    }
  }

  inventoryUploadStockExcel() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );

      // if (result != null && result.files.single.path != null) {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await inventoryRepo.inventoryUploadStockExcel(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: 'products_file',
        );

        if (response?.statusCode == 200) {
          // appToast(response?.body?["message"]);
          Get.back();
          await getCurrentStock();
          Get.snackbar('Import Successfully', response?.body?["message"],
              backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar("Error", response?.body?["error"],
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
      log("inventoryUploadStockExcel :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  addSingleStock(int id) async {
    try {
      if (isAddInventorySubmitting.value) return;
      isAddInventorySubmitting.value = true;
      addInventoryStockLoader.value = true;
      Map<String, dynamic> data = {
        "vendor_id": addStockVendorId ?? 0,
        "purchase_date": addStockPurchaseDateController.text.trim(),
        "payment_type": paymentTypeValue,
        "total_tax": num.tryParse(addStockTotalTaxController.text.trim()),
        "total_fair": num.tryParse(addStockTotalFairController.text.trim()),
        "item_total":
            num.tryParse(addStockItemQuantityController.text.trim()) ?? 0,
        "tot_amount":
            num.tryParse(addStockTotalAmountController.text.trim()) ?? 0,
        "bill_pdf": addStockBrowseFilePath ?? "",
        "quantity": num.tryParse(purchaseList[0]["quantity"].text) ?? 0,
        "unit": purchaseList[0]["unit"],
        "physical_qty": purchaseList[0]["physicalQty"].text,
        "physicalqty_master": Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('physicalqty_master')
            ? true
            : false,
        "waste_reason":
            getSelectedWastageReasonText() ?? "Physical stock count adjustment",
      };
      final response = await inventoryRepo.addSingleStock(data: data, id: id);

      if (response?.statusCode == 200) {
        await getCurrentStock();
        appToast(AppString.addStockSuccessfully);
        Get.back();
      } else if (response?.statusCode == 401) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message']);
      }
    } catch (e) {
      log("addSingleStock :$e");
    } finally {
      addInventoryStockLoader.value = false;
      isAddInventorySubmitting.value = false;
    }
  }

  int? addStockubRecipeId;
  addSubRecipeStock() async {
    try {
      if (isAddInventorySubmitting.value) return;
      isAddInventorySubmitting.value = true;
      addInventoryStockLoader.value = true;
      Map<String, dynamic> data = {
        "sub_recipe_id": addStockubRecipeId,
        "quantity": num.tryParse(purchaseList[0]["quantity"].text) ?? 0,
        "unit": purchaseList[0]["unit"],
        "physical_qty": num.tryParse(purchaseList[0]["physicalQty"].text),
        "physicalqty_master": Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('physicalqty_master')
            ? true
            : false,
        "waste_reason":
            getSelectedWastageReasonText() ?? "Physical stock count adjustment",
      };
      final response = await inventoryRepo.addSubRecipeStock(data: data);

      if (response?.statusCode == 200) {
        await getCurrentStock();
        appToast(AppString.addStockSuccessfully);
        Get.back();
      } else if (response?.statusCode == 401) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log("addSingleStock :$e");
    } finally {
      addInventoryStockLoader.value = false;
      isAddInventorySubmitting.value = false;
    }
  }

  List<dynamic> getUnitInventoryList = [];

  getUnitInventory(int id) async {
    try {
      getUnitInventoryList.clear();
      final response = await inventoryRepo.unitInventory(id);

      if (response?.statusCode == 200) {
        getUnitInventoryList = response?.body?["unitList"];
        log("getUnitInventoryList :${getUnitInventoryList.toList()}");

        update();
      }
    } catch (e) {
      log("getUnitInventory :$e");
    }
  }

  ///* purchase report
  TextEditingController purchaseSearchController = TextEditingController();
  bool getPurchaseReportLoader = false;

  setPurchaseReportLoader(bool val) {
    getPurchaseReportLoader = val;
    update();
  }

  List<String> purchaseReportFilterList = ["All Time", "Date"];
  String purchaseReportFilterValue = "All Time";

  //* Wastage Report Variables
  String? totalPurchaseAmount;
  String? wastageStartDate;
  String? wastageEndDate;
  bool isWastageReportLoading = false;
  Map<String, dynamic>? wastageSummary;
  List<Map<String, dynamic>> wastageRecords = [];

  List<Map<String, dynamic>> getPurchaseReportList = [];

  Future<void> getPurchaseReport(
      {String? purchaseFromDate, String? purchaseToDate}) async {
    try {
      Map<String, dynamic> data = {};

      if (purchaseReportFilterValue == "All Time") {
        data = {"filter": 'all'};
      } else if (purchaseReportFilterValue == "Date") {
        data = {
          "from_date": purchaseFromDate,
          "to_date": purchaseToDate,
        };
      }

      setPurchaseReportLoader(true);
      final response = await inventoryRepo.getPurchaseReport(data);

      if (response?.statusCode == 200) {
        getPurchaseReportList =
            List<Map<String, dynamic>>.from(response!.body['data']);
        totalPurchaseAmount = response.body['total_amount'].toString();
      } else {
        getPurchaseReportList = [];
        totalPurchaseAmount = '0';
      }

      update();
    } catch (e) {
      log("getPurchaseReport error: $e");
    } finally {
      setPurchaseReportLoader(false);
    }
  }

  onChangePurchaseFilter(String newValue) async {
    purchaseReportFilterValue = newValue ?? "";
    purchaseFromDate = null;
    purchaseToDate = null;
    await getPurchaseReport();
    update();
  }

  purchaseExportPurchaseReport() async {
    try {
      Map<String, dynamic> data = {};
      if (purchaseReportFilterValue == "All Time") {
        data = {"filter": 'all'};
      }
      if (purchaseReportFilterValue == "Date") {
        data = {
          "from_date": purchaseFromDate,
          "to_date": purchaseToDate,
        };
      }
      final response =
          await inventoryRepo.purchaseExportPurchaseReport(data: data);

      if (response?.statusCode == 200) {
        appToast(response?.body?["message"]);
        appLaunchUrl(response?.body?["download_url"]);
      }
      update();
    } catch (e) {
      log("purchaseExportPurchaseReport :$e");
    }
  }

  String? purchaseFromDate;
  picFromDate() async {
    DateTime? dateTime = await pickedDate(purchaseFromDate);
    if (dateTime != null) {
      purchaseFromDate = DateFormat('dd-MM-yyyy').format(dateTime);
      if (purchaseToDate != null) {
        await getPurchaseReport(
            purchaseFromDate: purchaseFromDate ?? "",
            purchaseToDate: purchaseToDate ?? "");
      } else {
        appToast(AppString.pleaseSelectToDate);
        getPurchaseReportList.clear();
      }
      purchaseReportFilterValue = "Date";
      update();
    }
  }

  String? purchaseToDate;
  picToDate() async {
    DateTime? minDate = purchaseFromDate != null
        ? DateFormat('dd-MM-yyyy').parse(purchaseFromDate!)
        : DateTime.now();

    DateTime? dateTime = await pickedDate(purchaseToDate,
        minDate: minDate, maxDate: DateTime.now());
    if (dateTime != null) {
      purchaseToDate = DateFormat('dd-MM-yyyy').format(dateTime);
      if (purchaseFromDate != null) {
        await getPurchaseReport(
            purchaseFromDate: purchaseFromDate ?? "",
            purchaseToDate: purchaseToDate ?? "");
      } else {
        appToast(AppString.pleaseSelectFromDate);
        getPurchaseReportList.clear();
      }
      purchaseReportFilterValue = "Date";
      update();
    }
  }

  String? purchaseDateVal;
  picPurchaseDate() async {
    log("purchaseDateVal :$purchaseDateVal");
    DateTime? dateTime = await pickedDate(purchaseDateVal);
    if (dateTime != null) {
      purchaseDateVal = DateFormat('dd-MM-yyyy').format(dateTime);
      addStockPurchaseDateController.text = purchaseDateVal.toString();
      update();
    }
  }

  String? deletePurchaseReason;
  RxBool isDeleteReportLoader = false.obs;
  RxBool isDeleteSubmitting = false.obs;
  deleteReport(int id) async {
    try {
      if (deletePurchaseReason?.isNotEmpty ?? false) {
        if (isDeleteSubmitting.value) return;
        isDeleteSubmitting.value = true;
        isDeleteReportLoader.value = true;
        Map<String, dynamic> data = {"reason": deletePurchaseReason};
        final response = await inventoryRepo.deleteReport(id, data: data);

        if (response?.statusCode == 200) {
          await getPurchaseReport(
              purchaseFromDate: purchaseFromDate ?? "",
              purchaseToDate: purchaseToDate ?? "");
          appToast(response?.body?["message"]);
          Get.back();
        }
        update();
      } else {
        appToast(AppString.selectReason);
      }
    } catch (e) {
      log("deleteReport :$e");
    } finally {
      isDeleteReportLoader.value = false;
      isDeleteSubmitting.value = false;
    }
  }

//* recipes

  //* add Recipes
//   List<Map<String, dynamic>> recipesIngredientsList = [
//     addRecipesIngredients(),
//   ];
//   static Map<String, dynamic> addRecipesIngredients() {
//     return {
//       "ingredientsNameController": TextEditingController(),
//       "ingredientsId": "",
//       "unit": "",
//       "quantity": TextEditingController(),
//     };
//   }

//   addRecipesIngredientsData() {
//     recipesIngredientsList.add(InventoryController.addRecipesIngredients());
//     update();
//   }

//   removeRecipesIngredientsData(int index) {
//     recipesIngredientsList.removeAt(index);
//     update();
//   }

//   clearRecipesData() {
//     recipeNameController.clear();
//     foodRecipeId = null;
//     addRecipesUnitValue = null;
//     quantityController.clear();
//     recipesPreparationTimeController.clear();
//     recipesServeTimeController.clear();
//     servePeopleController.clear();
//     recipesIngredientsList.clear();
//     recipesIngredientsList.add({
//       "ingredientsNameController": TextEditingController(),
//       "ingredientsId": "",
//       "unit": "",
//       "quantity": TextEditingController(),
//     });
//   }

//   var recipeList = <Map<String, dynamic>>[].obs;
//   List<String> recipeType = ['Recipe', 'Sub-Recipe'];
//   TextEditingController recipesSearchController = TextEditingController();
//   bool getRecipesLoader = false;
//   TextEditingController recipeNameController = TextEditingController();
//   TextEditingController quantityController = TextEditingController();
//   TextEditingController recipesPreparationTimeController =
//       TextEditingController();
//   TextEditingController recipesServeTimeController = TextEditingController();
//   TextEditingController servePeopleController = TextEditingController();
//   String? addRecipesUnitValue;
//   String? selectedRecipeType = 'Recipe';
//   int? foodRecipeId;

//   setGetRecipesLoader(bool val) {
//     getRecipesLoader = val;
//     update();
//   }

//   // recipes category & recipes filter
//   String? recipesCategory;
//   String? recipesFilterValue;

//   onChangeRecipesFilter(String value) async {
//     recipesFilterValue = value ?? "";
//     log("recipesFilterValue :$recipesFilterValue");
//     await getRecipeList();
//     update();
//   }

//   onChangedRecipeCategory(String value) async {
//     selectedRecipeType = value;
//     (value == 'Sub-Recipe') ? await getSubRecipeList() : await getRecipeList();
//     update();
//   }

//   getRecipeList() async {
//     try {
//       Map<String, dynamic> data = {
//         "category_name": recipesCategory != null ? recipesCategory : "",
//         "recipe_name": recipesFilterValue != null ? recipesFilterValue : ""
//       };
//       log("getRecipeList data :$data");
//       setGetRecipesLoader(true);
//       final response = await inventoryRepo.getRecipeList(data: data);
//       log('getRecipeList response statusCode :${response?.statusCode}');

//       if (response?.statusCode == 200) {
//         List<dynamic> data = response?.body?['recipes'] ?? [];
//         recipeList.assignAll(data.cast<Map<String, dynamic>>());
//       } else {
//         ApiChecker.checkApi(response!);
//       }
//       log("getRecipeList :${recipeList.toList()}");
//       update();
//     } catch (e) {
//       log("getRecipeList :$e");
//     } finally {
//       setGetRecipesLoader(false);
//     }
//   }

//   var getRecipeAllList = <Map<String, dynamic>>[].obs;
//   getAllRecipeList() async {
//     try {
//       setGetRecipesLoader(true);
//       final response = await inventoryRepo.getAllRecipeList();

//       if (response?.statusCode == 200) {
//         List<dynamic> data = response?.body?['recipes'] ?? [];
//         getRecipeAllList.assignAll(data.cast<Map<String, dynamic>>());
//       } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//         ApiChecker.checkApi(response!);
//       } else {
//         Get.snackbar('Something Went Wrong!', response?.body['message'],
//             backgroundColor: Colors.red, colorText: Colors.white);
//       }
//       log('getAllRecipeList :${getRecipeAllList.toList()}');
//       update();
//     } catch (e) {
//       log("getAllRecipeList :$e");
//     } finally {
//       setGetRecipesLoader(false);
//     }
//   }

//   RxBool addRecipesLoader = false.obs;
//   RxBool isAddRecipesSubmitting = false.obs;
//   addRecipe() async {
//     try {
//       if (recipeNameController.text.isNotEmpty &&
//           foodRecipeId != 0 &&
//           (addRecipesUnitValue?.isNotEmpty ?? false) &&
//           servePeopleController.text.isNotEmpty &&
//           recipesIngredientsList.any(
//             (e) {
//               final ingredientsNameController =
//                   e["ingredientsNameController"]?.text;
//               final unit = e["unit"];
//               final qty = e["quantity"]?.text;

//               return ((ingredientsNameController?.isNotEmpty ?? false) &&
//                   (unit?.isNotEmpty ?? false) &&
//                   (qty?.isNotEmpty ?? false));
//             },
//           )) {
//         if (isAddRecipesSubmitting.value) return;
//         isAddRecipesSubmitting.value = true;
//         addRecipesLoader.value = true;
//         Map<String, dynamic> data = {
//           "name": foodRecipeId,
//           "preparation_time": recipesPreparationTimeController.text,
//           "serve_time": recipesServeTimeController.text,
//           "serves_people": num.tryParse(servePeopleController.text) ?? 0,
//           "recipe_unit": addRecipesUnitValue,
//           "recipe_qty": num.tryParse(quantityController.text) ?? 0,
//           "ingredients": recipesIngredientsList.map(
//             (e) {
//               return {
//                 "id": e["ingredientsId"],
//                 "unit": e["unit"],
//                 "qty": num.tryParse(e["quantity"].text) ?? 0
//               };
//             },
//           ).toList()
//         };
//         final response = await inventoryRepo.addRecipe(data);

//         if (response?.statusCode == 200) {
//           await getRecipeList();
//           await getAllRecipeList();
//           Get.back();

//           (Platform.isAndroid || Platform.isIOS)
//               ? appToast(AppString.addRecipeSuccessfully)
//               : Get.snackbar(
//                   'Added',
//                   'New Recipe Added Successfuly.',
//                   backgroundColor: Colors.green,
//                   colorText: Colors.white,
//                 );
//         } else if (response?.statusCode == 409) {
//           log('Already Exist: ${response?.body['message']}');
//           Get.snackbar(
//               "Already Exist", "This recipe already exists in the restaurant.",
//               colorText: Colors.white,
//               backgroundColor: const Color.fromARGB(255, 195, 69, 15));
//         } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//           ApiChecker.checkApi(response!);
//         } else {
//           Get.snackbar('Something Went Wrong!', response?.body['message'],
//               backgroundColor: Colors.red, colorText: Colors.white);
//         }
//       } else {
//         appToast(AppString.pleaseFillFields);
//       }

//       update();
//     } catch (e) {
//       log("addRecipe :$e");
//     } finally {
//       addRecipesLoader.value = false;
//       isAddRecipesSubmitting.value = false;
//     }
//   }

//   updateRecipe(int id) async {
//     try {
//       if (isAddRecipesSubmitting.value) return;
//       isAddRecipesSubmitting.value = true;
//       addRecipesLoader.value = true;
//       Map<String, dynamic> data = {
//         "name": foodRecipeId,
//         "preparation_time": recipesPreparationTimeController.text,
//         "serve_time": recipesServeTimeController.text,
//         "serves_people": num.tryParse(servePeopleController.text) ?? 0,
//         "recipe_unit": addRecipesUnitValue,
//         "recipe_qty": num.tryParse(quantityController.text) ?? 0,
//         "ingredients": recipesIngredientsList.map(
//           (e) {
//             return {
//               "id": e["ingredientsId"],
//               "unit": e["unit"],
//               "qty": num.tryParse(e["quantity"].text) ?? 0
//             };
//           },
//         ).toList()
//       };
//       final response = await inventoryRepo.updateRecipe(id, data: data);

//       if (response?.statusCode == 200) {
//         await getRecipeList();
//         // appToast(response?.body?["message"]);
//         Get.back();
//         (Platform.isAndroid || Platform.isIOS)
//             ? appToast(response?.body?["message"])
//             : Get.snackbar(
//                 'Updated',
//                 '${response?.body['message']}',
//                 backgroundColor: Colors.green,
//                 colorText: Colors.white,
//               );
//       } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//         ApiChecker.checkApi(response!);
//       } else {
//         Get.snackbar('Something Went Wrong!', response?.body['message'],
//             backgroundColor: Colors.red, colorText: Colors.white);
//       }
//     } catch (e) {
//       log("updateRecipe :$e");
//     } finally {
//       addRecipesLoader.value = false;
//       isAddRecipesSubmitting.value = false;
//     }
//   }

//   showRecipesData(Map<String, dynamic> recipes,
//       {required MenuManagementController menuController}) {
//     Get.find<ExpenseManagementController>().getUnit();
//     final selectedAddon = menuController.foodList.firstWhere(
//       (inventory) {
//         return inventory["name"].toString().toLowerCase() ==
//             recipes["food_name"].toLowerCase();
//       },
//       orElse: () => {},
//     );

//     final selectedId = selectedAddon["id"] ?? 0;

//     foodRecipeId = selectedId;

//     recipeNameController.text = recipes["food_name"];
//     addRecipesUnitValue = recipes["unit"].trim().toLowerCase();
//     quantityController.text = recipes["qty"].toString();
//     print('.................${addRecipesUnitValue}');
//     recipesPreparationTimeController.text =
//         recipes["preparation_time"].toString();
//     recipesServeTimeController.text = recipes["serve_time"];
//     servePeopleController.text = recipes["serve_people"].toString();
//     if (recipes["ingredients"].isNotEmpty) {
//       recipesIngredientsList =
//           (recipes["ingredients"] as List<dynamic>).map((r) {
//         return {
//           "ingredientsNameController":
//               TextEditingController(text: r["ingredient_name"]),
//           "ingredientsId": r["ingredient_id"],
//           "unit": r["ingredient_unit"],
//           "quantity":
//               TextEditingController(text: r["ingredient_qty"].toString()),
//         };
//       }).toList();
//     } else {
//       recipesIngredientsList.clear();
//       recipesIngredientsList.add({
//         "ingredientsNameController": TextEditingController(),
//         "ingredientsId": "",
//         "unit": "",
//         "quantity": TextEditingController(),
//       });
//     }
//   }

//   String? deleteRecipesReason;
//   RxBool deleteRecipesLoader = false.obs;
//   RxBool isDeleteRecipesSubmitting = false.obs;
//   deleteRecipe(int id, {bool deleteInside = false}) async {
//     try {
//       if (deleteRecipesReason?.isNotEmpty ?? false) {
//         if (isDeleteRecipesSubmitting.value) return;
//         isDeleteRecipesSubmitting.value = true;
//         deleteRecipesLoader.value = true;
//         Map<String, dynamic> data = {"reason": deleteRecipesReason};

//         final response = await inventoryRepo.deleteRecipe(id, data: data);

//         if (response?.statusCode == 200) {
//           await getRecipeList();
//           // appToast(response?.body?["message"]);
//           if (deleteInside == true) {
//             Get.back();
//             Get.back();
//           } else {
//             Get.back();
//           }
//           (Platform.isAndroid || Platform.isIOS)
//               ? appToast(response?.body?["message"])
//               : Get.snackbar(
//                   'Deleted',
//                   '${response?.body['message']}',
//                   backgroundColor: Colors.green,
//                   colorText: Colors.white,
//                 );
//         } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//           ApiChecker.checkApi(response!);
//         } else {
//           Get.snackbar('Something Went Wrong!', response?.body['message'],
//               backgroundColor: Colors.red, colorText: Colors.white);
//         }
//         update();
//       } else {
//         appToast(AppString.selectReason);
//       }
//     } catch (e) {
//       log("deleteRecipe :$e");
//     } finally {
//       isDeleteRecipesSubmitting.value = false;
//       deleteRecipesLoader.value = false;
//     }
//   }

//   exportRecipe() async {
//     try {
//       isExportLoader.value = true;
//       final response = await inventoryRepo.exportRecipe();

//       if (response?.statusCode == 200) {
//         appLaunchUrl(response?.body?["download_url"]);
//         appToast(response?.body?["message"]);
//       } else {
//         ApiChecker.checkApi(response!);
//       }
//       update();
//     } catch (e) {
//       log("exportRecipe :$e");
//     } finally {
//       isExportLoader.value = false;
//     }
//   }

//   exportRecipeSample() async {
//     exportSampleLoader.value = true;
//     update();
//     print('Downloading Recipe Bulk Import Sample Excel File ...');
//     await appLaunchUrl(
//         '${AppConstants.BASE_URL}/bulk_upload_sample/recipe/Recipe_Bulk_Import_Sample.xlsx');
//     print('Recipe Bulk Upload Downloaded Successfully.');
//     Get.snackbar('Downloaded Successfully',
//         'Recipe Bulk Upload Downloaded Successfully.',
//         backgroundColor: ColorTheme.green, colorText: Colors.white);
//     exportSampleLoader.value = false;
//     update();
//   }

//   importRecipe() async {
//     try {
//       // FilePickerResult? result = await FilePicker.platform.pickFiles(
//       //   type: FileType.custom,
//       //   allowedExtensions: ['xlsx'],
//       // );

//       // if (result != null && result.files.single.path != null) {
//       isImportLoader.value = true;
//       if (chooseFilePath?.isNotEmpty ?? false) {
//         final response = await inventoryRepo.importRecipe(
//           data: {},
//           fileName: chooseFilePath ?? "",
//           keyFileName: 'products_file',
//         );
//         ;
//         log("importRecipe response code :${response?.statusCode}");

//         if (response?.statusCode == 200) {
//           Get.back();
//           Get.back();

//           await getRecipeList();

//           // appToast(AppString.importRecipesSuccessfully);
//           Get.snackbar(
//               AppString.importRecipesSuccessfully, response?.body?["message"],
//               backgroundColor: Colors.green, colorText: Colors.white);
//         } else if (response?.statusCode == 401) {
//           ApiChecker.checkApi(response!);
//         } else {
//           Get.snackbar("Error", response?.body?["error"],
//               backgroundColor: Colors.redAccent, colorText: Colors.white);
//         }
//         chooseFilePath = null;
//         ChooseFileController.clear();
//         update();
//       } else {
//         log("No file selected or file path is null.");
//         Get.snackbar('Check Again', AppString.pleaseChooseFile,
//             backgroundColor: ColorTheme.appColor, colorText: Colors.white);
//       }
//       update();
//     } catch (e) {
//       log("importRecipe :$e");
//     } finally {
//       isImportLoader.value = false;
//     }
//   }

//   var recipeIngredientsList = <Map<String, dynamic>>[].obs;
//   getRecipesIngredients() async {
//     try {
//       final response = await inventoryRepo.getRecipesIngredients();

//       if (response?.statusCode == 200) {
//         List<dynamic> data = response?.body?['ingredients'] ?? [];
//         recipeIngredientsList.assignAll(data.cast<Map<String, dynamic>>());
//       }
//       update();
//     } catch (e) {
//       log("getRecipesIngredients $e");
//     }
//   }

//   //* SubRecipe
//   TextEditingController subRecipeNameController = TextEditingController();
//   String? subRecipeUnit;
//   TextEditingController subRecipeQuantityController = TextEditingController();
//   TextEditingController subRecipePTimeController = TextEditingController();
//   TextEditingController subRecipeSTimeController = TextEditingController();
//   TextEditingController subRecipeSPeopleController = TextEditingController();
//   TextEditingController subRecipeThresholdQtyController =
//       TextEditingController();
//   String? subRecipeThresholdUnit;
//   RxBool addSubRecipesLoader = false.obs;
//   RxBool isAddSubRecipesSubmitting = false.obs;

//   getSubRecipeList() async {
//     try {
//       setGetRecipesLoader(true);
//       final response = await inventoryRepo.getSubRecipeList();
//       if (response?.statusCode == 200) {
//         List<dynamic> data = response?.body?['sub_recipes'] ?? [];
//         recipeList.assignAll(data.cast<Map<String, dynamic>>());
//       } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//         ApiChecker.checkApi(response!);
//       } else {
//         Get.snackbar('Something Went Wrong!', response?.body['message'],
//             backgroundColor: Colors.red, colorText: Colors.white);
//         print("Failed to get SubRecipe List : ${response?.statusCode}");
//       }
//       update();
//     } catch (e) {
//       log("Failed to get SubRecipe List :$e");
//     } finally {
//       setGetRecipesLoader(false);
//     }
//   }

//   List<Map<String, dynamic>> subRecipesIngredientsList = [
//     addSubRecipesIngredients(),
//   ];

//   static Map<String, dynamic> addSubRecipesIngredients() {
//     return {
//       "ingredientsNameController": TextEditingController(),
//       "ingredientsId": "",
//       "unit": "",
//       "quantity": TextEditingController(),
//     };
//   }

//   addSubRecipesIngredientsData() {
//     subRecipesIngredientsList
//         .add(InventoryController.addSubRecipesIngredients());
//     update();
//   }

//   removeSubRecipesIngredientsData(int index) {
//     subRecipesIngredientsList.removeAt(index);
//     update();
//   }

//   addSubRecipe() async {
//     try {
//       if (subRecipeNameController.text.isNotEmpty &&
//           (subRecipeUnit?.isNotEmpty ?? false) &&
//           subRecipeThresholdQtyController.text.isNotEmpty &&
//           (subRecipeThresholdUnit?.isNotEmpty ?? false) &&
//           // subRecipeSPeopleController.text.isNotEmpty &&
//           subRecipesIngredientsList.any(
//             (e) {
//               final ingredientsNameController =
//                   e["ingredientsNameController"]?.text;
//               final unit = e["unit"];
//               final qty = e["quantity"]?.text;

//               return ((ingredientsNameController?.isNotEmpty ?? false) &&
//                   (unit?.isNotEmpty ?? false) &&
//                   (qty?.isNotEmpty ?? false));
//             },
//           )) {
//         if (isAddSubRecipesSubmitting.value) return;
//         isAddSubRecipesSubmitting.value = true;
//         addSubRecipesLoader.value = true;
//         Map<String, dynamic> data = {
//           "sub_recipe_name": subRecipeNameController.text,
//           "subunit": subRecipeUnit,
//           "qty": subRecipeQuantityController.text ?? '1',
//           "prepration_time": subRecipePTimeController.text ?? '1',
//           "serve_time": subRecipeSTimeController.text ?? '1',
//           "serve_people": num.tryParse(subRecipeSPeopleController.text) ?? 1,
//           "thershold_qty": subRecipeThresholdQtyController.text,
//           "thershold_unit": subRecipeThresholdUnit,
//           "ingredient": subRecipesIngredientsList.map(
//             (e) {
//               return {
//                 "id": e["ingredientsId"],
//                 "unit": e["unit"],
//                 "qty": num.tryParse(e["quantity"].text) ?? 0
//               };
//             },
//           ).toList()
//         };

//         final response = await inventoryRepo.addSubRecipe(data);

//         if (response?.statusCode == 200) {
//           onChangedRecipeCategory('Sub-Recipe');
//           Get.back();
//           (Platform.isAndroid || Platform.isIOS)
//               ? appToast(AppString.addSubRecipeSuccessfully)
//               : Get.snackbar(
//                   'Added',
//                   'New Sub-Recipe Added Successfuly.',
//                   backgroundColor: Colors.green,
//                   colorText: Colors.white,
//                 );
//           // selectedRecipeType = 'Sub-Recipe';
//         } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//           ApiChecker.checkApi(response!);
//         } else {
//           Get.snackbar('Something Went Wrong!', response?.body['message'],
//               backgroundColor: Colors.red, colorText: Colors.white);
//           print(
//               'Failed to Add sub recipe : ${response?.body} , ${response?.statusCode}');
//         }
//       } else {
//         appToast(AppString.pleaseFillFields);
//       }
//     } catch (e) {
//       log("addSubRecipe :$e");
//     } finally {
//       addSubRecipesLoader.value = false;
//       isAddSubRecipesSubmitting.value = false;
//     }
//   }

// //   clearSubRecipesData() {
// //   subRecipeNameController.clear();
// //   subRecipeUnit = null;
// //   subRecipeQuantityController.clear();
// //   subRecipePTimeController.clear();
// //   subRecipeSTimeController.clear();
// //   subRecipeSPeopleController.clear();
// //   subRecipeThresholdQtyController.clear();
// //   subRecipeThresholdUnit = null;
// //   subRecipesIngredientsList.clear();
// //   subRecipesIngredientsList.add({
// //     "ingredientsNameController": TextEditingController(),
// //     "ingredientsId": "",
// //     "unit": "",
// //     "quantity": TextEditingController(),
// //   });
// // }

//   showSubRecipesData(Map<String, dynamic> subRecipe) {
//     subRecipeNameController.text = subRecipe["name"] ?? '';
//     subRecipeUnit = (subRecipe["unit"] ?? '').trim().toLowerCase();
//     subRecipeQuantityController.text = subRecipe["qty"]?.toString() ?? '';
//     subRecipePTimeController.text =
//         subRecipe["preparation_time"]?.toString() ?? '';
//     subRecipeSTimeController.text = subRecipe["serve_time"]?.toString() ?? '';
//     subRecipeSPeopleController.text =
//         subRecipe["serve_people"]?.toString() ?? '';

//     // These keys are not present in the new JSON, so default or blank
//     subRecipeThresholdQtyController.text = subRecipe['min_qty_alert'];
//     subRecipeThresholdUnit = subRecipe['min_unit_alert'];

//     // Handle ingredients
//     if ((subRecipe["ingredients"] ?? []).isNotEmpty) {
//       subRecipesIngredientsList =
//           (subRecipe["ingredients"] as List<dynamic>).map((r) {
//         return {
//           "ingredientsNameController":
//               TextEditingController(text: r["ingredient_name"] ?? ''),
//           "ingredientsId": r["ingredient_id"] ?? '',
//           "unit": r["ingredient_unit"] ?? '',
//           "quantity": TextEditingController(
//               text: r["ingredient_qty"]?.toString() ?? ''),
//         };
//       }).toList();
//     } else {
//       subRecipesIngredientsList.clear();
//       subRecipesIngredientsList.add({
//         "ingredientsNameController": TextEditingController(),
//         "ingredientsId": "",
//         "unit": "",
//         "quantity": TextEditingController(),
//       });
//     }
//   }

//   updateSubRecipe(int id) async {
//     try {
//       if (isAddSubRecipesSubmitting.value) return;
//       isAddSubRecipesSubmitting.value = true;
//       addSubRecipesLoader.value = true;
//       Map<String, dynamic> data = {
//         "sub_recipe_name": subRecipeNameController.text,
//         "subunit": subRecipeUnit,
//         "qty": subRecipeQuantityController.text,
//         "prepration_time": subRecipePTimeController.text,
//         "serve_time": subRecipeSTimeController.text,
//         "serve_people": num.tryParse(subRecipeSPeopleController.text) ?? 0,
//         "thershold_qty": subRecipeThresholdQtyController.text,
//         "thershold_unit": subRecipeThresholdUnit,
//         "ingredients": subRecipesIngredientsList.map(
//           (e) {
//             return {
//               "id": e["ingredientsId"],
//               "unit": e["unit"],
//               "qty": num.tryParse(e["quantity"].text) ?? 0
//             };
//           },
//         ).toList()
//       };
//       final response = await inventoryRepo.updateSubRecipe(id, data: data);

//       if (response?.statusCode == 200) {
//         // await getSubRecipeList();
//         Get.back();
//         onChangedRecipeCategory('Sub-Recipe');
//         (Platform.isAndroid || Platform.isIOS)
//             ? appToast(response?.body?["message"])
//             : Get.snackbar(
//                 'Updated',
//                 '${response?.body['message']}',
//                 backgroundColor: Colors.green,
//                 colorText: Colors.white,
//               );
//       } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//         ApiChecker.checkApi(response!);
//       } else {
//         Get.snackbar('Something Went Wrong!', response?.body['message'],
//             backgroundColor: Colors.red, colorText: Colors.white);
//         print(
//             'Failed to update sub recipe : ${response?.body} , ${response?.statusCode}');
//       }
//     } catch (e) {
//       log("updateSubRecipe :$e");
//     } finally {
//       addSubRecipesLoader.value = false;
//       isAddSubRecipesSubmitting.value = false;
//     }
//   }

//   deleteSubRecipe(int id, {bool deleteInside = false}) async {
//     try {
//       if (isDeleteRecipesSubmitting.value) return;
//       isDeleteRecipesSubmitting.value = true;
//       deleteRecipesLoader.value = true;

//       final response = await inventoryRepo.deleteSubRecipe(id);

//       if (response?.statusCode == 200) {
//         onChangedRecipeCategory('Sub-Recipe');
//         if (deleteInside == true) {
//           Get.back();
//           Get.back();
//         } else {
//           Get.back();
//         }
//         (Platform.isAndroid || Platform.isIOS)
//             ? appToast(response?.body?["message"])
//             : Get.snackbar(
//                 'Deleted',
//                 '${response?.body['message']}',
//                 backgroundColor: Colors.green,
//                 colorText: Colors.white,
//               );
//       } else if (response?.statusCode == 401 || response?.statusCode == 403) {
//         ApiChecker.checkApi(response!);
//       } else {
//         Get.snackbar('Something Went Wrong!', response?.body['message'],
//             backgroundColor: Colors.red, colorText: Colors.white);
//         print(
//             'Failed to Delete sub recipe : ${response?.body} , ${response?.statusCode}');
//       }
//       update();
//     } catch (e) {
//       log("deleteSubRecipe :$e");
//     } finally {
//       isDeleteRecipesSubmitting.value = false;
//       deleteRecipesLoader.value = false;
//     }
//   }

//   clearSubRecipesData() {
//     subRecipeNameController.clear();
//     subRecipeUnit = null;
//     subRecipeQuantityController.clear();
//     subRecipePTimeController.clear();
//     subRecipeSTimeController.clear();
//     subRecipeSPeopleController.clear();
//     subRecipeThresholdQtyController.clear();
//     subRecipeThresholdUnit = null;
//     subRecipesIngredientsList.clear();
//     subRecipesIngredientsList.add({
//       "ingredientsNameController": TextEditingController(),
//       "ingredientsId": "",
//       "unit": "",
//       "quantity": TextEditingController(),
//     });
//   }

//   exportSubRecipes() async {
//     try {
//       final response = await inventoryRepo.exportSubRecipes();

//       if (response?.statusCode == 200) {
//         appLaunchUrl(response?.body?["file_url"]);
//       }
//       update();
//     } catch (e) {
//       log('exportSubRecipes :$e');
//     }
//   }

//   importSubRecipes() async {
//     try {
//       // Use file_picker to select an .xlsx file
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx'],
//       );

//       if (result != null && result.files.single.path != null) {
//         // Send the file to the server
//         final response = await inventoryRepo.importSubRecipes(
//           data: {},
//           fileName: result.files.single.path ?? "",
//           keyFileName: 'file',
//         );

//         if (response?.statusCode == 200) {
//           await getRecipeList();
//           appToast(response?.body?["message"]);
//         } else {
//           appToast(response?.body?["message"]);
//         }
//       } else {
//         log("No file selected or file path is null.");
//       }

//       update();
//     } catch (e) {
//       log("importSubRecipes :$e");
//     }
//   }

/*********************************************************RECIPES********************************************************/

  var recipeList = <Map<String, dynamic>>[].obs;
  List<String> recipeType = ['All', 'Recipe', 'Sub-Recipe', 'Addon-Recipe'];
  TextEditingController recipesSearchController = TextEditingController();
  TextEditingController recipeNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController recipesPreparationTimeController =
      TextEditingController();
  TextEditingController recipesServeTimeController = TextEditingController();
  TextEditingController servePeopleController = TextEditingController();
  String? addRecipesUnitValue;
  String? selectedRecipeType;
  int? foodRecipeId;
  String? deleteRecipesReason;
  bool getRecipesLoader = false;
  RxBool deleteRecipesLoader = false.obs;
  RxBool isDeleteRecipesSubmitting = false.obs;
  String? recipesCategory;
  String? recipesFilterValue;

  //* add Recipes
  List<Map<String, dynamic>> recipesIngredientsList = [
    addRecipesIngredients(),
  ];

  static Map<String, dynamic> addRecipesIngredients() {
    return {
      "ingredientsNameController": TextEditingController(),
      "ingredientsId": "",
      "unit": "",
      "quantity": TextEditingController(),
    };
  }

  addRecipesIngredientsData() {
    recipesIngredientsList.add(InventoryController.addRecipesIngredients());
    update();
  }

  removeRecipesIngredientsData(int index) {
    recipesIngredientsList.removeAt(index);
    update();
  }

  clearRecipesData() {
    recipeNameController.clear();
    foodRecipeId = null;
    addRecipesUnitValue = null;
    quantityController.clear();
    recipesPreparationTimeController.clear();
    recipesServeTimeController.clear();
    servePeopleController.clear();
    recipesIngredientsList.clear();
    recipesIngredientsList.add({
      "ingredientsNameController": TextEditingController(),
      "ingredientsId": "",
      "unit": "",
      "quantity": TextEditingController(),
    });
  }

  setGetRecipesLoader(bool val) {
    getRecipesLoader = val;
    update();
  }

  onChangeRecipesFilter(String value) async {
    recipesFilterValue = value ?? "";
    log("recipesFilterValue :$recipesFilterValue");

    // Call appropriate API based on selected recipe type
    if (selectedRecipeType == 'Recipe') {
      await getRecipeList();
    } else if (selectedRecipeType == 'Sub-Recipe') {
      await getSubRecipeList();
    } else if (selectedRecipeType == 'Addon-Recipe') {
      await getAddonRecipeList();
    } else {
      // For 'All', fetch both
      await getAllRecipesAndSubRecipes();
    }
    update();
  }

  onChangedRecipeCategory(String value) async {
    selectedRecipeType = value;
    log("selectedRecipeType :$selectedRecipeType");
    if (value == 'Recipe') {
      await getRecipeList();
    } else if (value == 'Sub-Recipe') {
      await getSubRecipeList();
    } else if (value == 'Addon-Recipe') {
      await getAddonRecipeList();
    } else {
      // For 'All', fetch both
      await getAllRecipesAndSubRecipes();
    }
    update();
  }

  // New method to fetch both recipes and sub-recipes
  getAllRecipesAndSubRecipes() async {
    try {
      setGetRecipesLoader(true);

      // Fetch both recipes and sub-recipes
      Map<String, dynamic> data = {
        "category_name": recipesCategory != null ? recipesCategory : "",
        "recipe_name": recipesFilterValue != null ? recipesFilterValue : ""
      };

      print("${recipesFilterValue}....${recipesCategory}");
      print("${data['recipe_name']}....${data['category_name']}");

      final recipeResponse = await inventoryRepo.getRecipeList(data: data);
      final subRecipeResponse = await inventoryRepo.getSubRecipeList();
      final addonRecipeResponse = await inventoryRepo.getAddonRecipeList();

      List<Map<String, dynamic>> combinedList = [];

      if (recipeResponse?.statusCode == 200) {
        List<dynamic> recipes = recipeResponse?.body?['recipes'] ?? [];
        // Add type identifier to recipes
        combinedList.addAll(recipes.cast<Map<String, dynamic>>().map((recipe) {
          recipe['type'] = 'recipe';
          return recipe;
        }).toList());
      }

      if (subRecipeResponse?.statusCode == 200) {
        List<dynamic> subRecipes =
            subRecipeResponse?.body?['sub_recipes'] ?? [];
        // Add type identifier to sub-recipes
        combinedList
            .addAll(subRecipes.cast<Map<String, dynamic>>().map((subRecipe) {
          subRecipe['type'] = 'sub_recipe';
          return subRecipe;
        }).toList());
      }

      // Addon Recipes → tag type: 'addon_recipe' (already in response but explicit)
      if (addonRecipeResponse?.statusCode == 200) {
        List<dynamic> addonRecipes =
            addonRecipeResponse?.body?['recipes'] ?? [];
        combinedList.addAll(
          addonRecipes.cast<Map<String, dynamic>>().map((addonRecipe) {
            return {...addonRecipe, 'type': 'addon_recipe'};
          }).toList(),
        );
      }

      recipeList.assignAll(combinedList);
      log("getAllRecipesAndSubRecipes :${recipeList.toList()}");
      update();
    } catch (e) {
      log("getAllRecipesAndSubRecipes :$e");
    } finally {
      setGetRecipesLoader(false);
    }
  }

  getRecipeList() async {
    try {
      Map<String, dynamic> data = {
        "category_name": recipesCategory != null ? recipesCategory : "",
        "recipe_name": recipesFilterValue != null ? recipesFilterValue : ""
      };
      log("getRecipeList data :$data");
      setGetRecipesLoader(true);
      final response = await inventoryRepo.getRecipeList(data: data);
      log('getRecipeList response statusCode :${response?.statusCode}');

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['recipes'] ?? [];
        // Add type identifier to recipes
        recipeList.assignAll(data.cast<Map<String, dynamic>>().map((recipe) {
          recipe['type'] = 'recipe';
          return recipe;
        }).toList());
      } else {
        ApiChecker.checkApi(response!);
      }
      log("getRecipeList :${recipeList.toList()}");
      update();
    } catch (e) {
      log("getRecipeList :$e");
    } finally {
      setGetRecipesLoader(false);
    }
  }

  var getRecipeAllList = <Map<String, dynamic>>[].obs;
  getAllRecipeList() async {
    try {
      setGetRecipesLoader(true);
      final response = await inventoryRepo.getAllRecipeList();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['recipes'] ?? [];
        getRecipeAllList.assignAll(data.cast<Map<String, dynamic>>());
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      log('getAllRecipeList :${getRecipeAllList.toList()}');
      update();
    } catch (e) {
      log("getAllRecipeList :$e");
    } finally {
      setGetRecipesLoader(false);
    }
  }

  RxBool addRecipesLoader = false.obs;
  RxBool isAddRecipesSubmitting = false.obs;
  addRecipe() async {
    try {
      if (recipeNameController.text.isNotEmpty &&
          foodRecipeId != 0 &&
          (addRecipesUnitValue?.isNotEmpty ?? false) &&
          // servePeopleController.text.isNotEmpty &&
          recipesIngredientsList.any(
            (e) {
              final ingredientsNameController =
                  e["ingredientsNameController"]?.text;
              final unit = e["unit"];
              final qty = e["quantity"]?.text;

              return ((ingredientsNameController?.isNotEmpty ?? false) &&
                  (unit?.isNotEmpty ?? false) &&
                  (qty?.isNotEmpty ?? false));
            },
          )) {
        if (isAddRecipesSubmitting.value) return;
        isAddRecipesSubmitting.value = true;
        addRecipesLoader.value = true;
        Map<String, dynamic> data = {
          "name": foodRecipeId,
          "preparation_time": recipesPreparationTimeController.text.isEmpty
              ? '1'
              : recipesPreparationTimeController.text,
          "serve_time": recipesServeTimeController.text.isEmpty
              ? '1'
              : recipesServeTimeController.text,
          "serves_people": servePeopleController.text.isEmpty
              ? 1
              : num.tryParse(servePeopleController.text) ?? 0,
          "recipe_unit": addRecipesUnitValue,
          "recipe_qty": num.tryParse(quantityController.text) ?? 0,
          "ingredients": recipesIngredientsList.map(
            (e) {
              return {
                "id": e["ingredientsId"],
                "unit": e["unit"],
                "qty": num.tryParse(e["quantity"].text) ?? 0
              };
            },
          ).toList()
        };
        final response = await inventoryRepo.addRecipe(data);

        if (response?.statusCode == 200) {
          // Refresh based on current filter
          // if (selectedRecipeType == 'Recipe') {
          //   await getRecipeList();
          // } else if (selectedRecipeType == 'All') {
          //   await getAllRecipesAndSubRecipes();
          // }
          // await getAllRecipeList();
          onChangedRecipeCategory(selectedRecipeType ?? 'All');
          Get.back();

          (Platform.isAndroid || Platform.isIOS)
              ? appToast(AppString.addRecipeSuccessfully)
              : Get.snackbar(
                  'Added',
                  'New Recipe Added Successfuly.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else if (response?.statusCode == 409) {
          log('Already Exist: ${response?.body['message']}');
          Get.snackbar(
              "Already Exist", "This recipe already exists in the restaurant.",
              colorText: Colors.white,
              backgroundColor: const Color.fromARGB(255, 195, 69, 15));
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        appToast(AppString.pleaseFillFields);
      }

      update();
    } catch (e) {
      log("addRecipe :$e");
    } finally {
      addRecipesLoader.value = false;
      isAddRecipesSubmitting.value = false;
    }
  }

  updateRecipe(int id) async {
    try {
      if (isAddRecipesSubmitting.value) return;
      isAddRecipesSubmitting.value = true;
      addRecipesLoader.value = true;
      Map<String, dynamic> data = {
        "name": foodRecipeId,
        "preparation_time": recipesPreparationTimeController.text.isEmpty
            ? '1'
            : recipesPreparationTimeController.text,
        "serve_time": recipesServeTimeController.text.isEmpty
            ? '1'
            : recipesServeTimeController.text,
        "serves_people": servePeopleController.text.isEmpty
            ? 1
            : num.tryParse(servePeopleController.text) ?? 0,
        "recipe_unit": addRecipesUnitValue,
        "recipe_qty": num.tryParse(quantityController.text) ?? 0,
        "ingredients": recipesIngredientsList.map(
          (e) {
            return {
              "id": e["ingredientsId"],
              "unit": e["unit"],
              "qty": num.tryParse(e["quantity"].text) ?? 0
            };
          },
        ).toList()
      };
      final response = await inventoryRepo.updateRecipe(id, data: data);

      if (response?.statusCode == 200) {
        // Refresh based on current filter
        // if (selectedRecipeType == 'Recipe') {
        //   await getRecipeList();
        // } else if (selectedRecipeType == 'All') {
        //   await getAllRecipesAndSubRecipes();
        // }
        onChangedRecipeCategory(selectedRecipeType ?? 'All');

        Get.back();
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(response?.body?["message"])
            : Get.snackbar(
                'Updated',
                '${response?.body['message']}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      log("updateRecipe :$e");
    } finally {
      addRecipesLoader.value = false;
      isAddRecipesSubmitting.value = false;
    }
  }

  showRecipesData(Map<String, dynamic> recipes) {
    Get.find<ExpenseManagementController>().getUnit();
    final selectedAddon = recipeFoodList.firstWhere(
      (inventory) {
        return inventory["name"].toString().toLowerCase() ==
            recipes["food_name"].toLowerCase();
      },
      orElse: () => {},
    );

    final selectedId = selectedAddon["id"] ?? 0;

    foodRecipeId = selectedId;

    recipeNameController.text = recipes["food_name"];
    addRecipesUnitValue = recipes["unit"].trim().toLowerCase();
    quantityController.text = recipes["qty"].toString();
    print('.................${addRecipesUnitValue}');
    recipesPreparationTimeController.text =
        recipes["preparation_time"].toString();
    recipesServeTimeController.text = recipes["serve_time"];
    servePeopleController.text = recipes["serve_people"].toString();
    if (recipes["ingredients"].isNotEmpty) {
      recipesIngredientsList =
          (recipes["ingredients"] as List<dynamic>).map((r) {
        return {
          "ingredientsNameController":
              TextEditingController(text: r["ingredient_name"]),
          "ingredientsId": r["ingredient_id"],
          "unit": r["ingredient_unit"],
          "quantity":
              TextEditingController(text: r["ingredient_qty"].toString()),
        };
      }).toList();
    } else {
      recipesIngredientsList.clear();
      recipesIngredientsList.add({
        "ingredientsNameController": TextEditingController(),
        "ingredientsId": "",
        "unit": "",
        "quantity": TextEditingController(),
      });
    }
  }

  deleteRecipe(int id, {bool deleteInside = false}) async {
    try {
      if (deleteRecipesReason?.isNotEmpty ?? false) {
        if (isDeleteRecipesSubmitting.value) return;
        isDeleteRecipesSubmitting.value = true;
        deleteRecipesLoader.value = true;
        Map<String, dynamic> data = {"reason": deleteRecipesReason};

        final response = await inventoryRepo.deleteRecipe(id, data: data);

        if (response?.statusCode == 200) {
          // Refresh based on current filter
          // if (selectedRecipeType == 'Recipe') {
          //   await getRecipeList();
          // } else if (selectedRecipeType == 'All') {
          //   await getAllRecipesAndSubRecipes();
          // }
          onChangedRecipeCategory(selectedRecipeType ?? 'All');
          if (deleteInside == true) {
            Get.back();
            Get.back();
          } else {
            Get.back();
          }
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(response?.body?["message"])
              : Get.snackbar(
                  'Deleted',
                  '${response?.body['message']}',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        update();
      } else {
        appToast(AppString.selectReason);
      }
    } catch (e) {
      log("deleteRecipe :$e");
    } finally {
      isDeleteRecipesSubmitting.value = false;
      deleteRecipesLoader.value = false;
    }
  }

  exportRecipe() async {
    try {
      isExportLoader.value = true;
      final response = await inventoryRepo.exportRecipe();

      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("exportRecipe :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

  exportRecipeSample() async {
    exportSampleLoader.value = true;
    update();
    try {
      final response = await inventoryRepo.exportRecipeSample();
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
        Get.snackbar("Error", response.body?["error"],
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      update();
    } catch (e) {
      log("exportRecipe :$e");
    } finally {
      exportSampleLoader.value = false;
      update();
    }
  }

  importRecipe() async {
    try {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await inventoryRepo.importRecipe(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: 'products_file',
        );
        log("importRecipe response code :${response?.statusCode}");

        if (response?.statusCode == 200) {
          Get.back();
          Get.back();

          print('selectedRecipeType : $selectedRecipeType');

          // Refresh based on current filter
          if (selectedRecipeType == 'Recipe') {
            await getRecipeList();
          } else if (selectedRecipeType == 'All') {
            await getAllRecipesAndSubRecipes();
          }

          Get.snackbar(
              AppString.importRecipesSuccessfully, response?.body?["message"],
              backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar("Error", response?.body?["error"],
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
      log("importRecipe :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  var recipeIngredientsList = <Map<String, dynamic>>[].obs;
  getRecipesIngredients() async {
    try {
      final response = await inventoryRepo.getRecipesIngredients();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['ingredients'] ?? [];
        recipeIngredientsList.assignAll(data.cast<Map<String, dynamic>>());
      }
      update();
    } catch (e) {
      log("getRecipesIngredients $e");
    }
  }

  /***********************SUB-RECIPES*************************/

  TextEditingController subRecipeNameController = TextEditingController();
  TextEditingController subRecipeQuantityController = TextEditingController();
  TextEditingController subRecipePTimeController = TextEditingController();
  TextEditingController subRecipeSTimeController = TextEditingController();
  TextEditingController subRecipeSPeopleController = TextEditingController();
  TextEditingController subRecipeThresholdQtyController =
      TextEditingController();
  String? subRecipeUnit;
  String? subRecipeThresholdUnit;
  RxBool addSubRecipesLoader = false.obs;
  RxBool isAddSubRecipesSubmitting = false.obs;

  getSubRecipeList() async {
    try {
      setGetRecipesLoader(true);
      final response = await inventoryRepo.getSubRecipeList();
      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['sub_recipes'] ?? [];
        // Add type identifier to sub-recipes
        recipeList.assignAll(data.cast<Map<String, dynamic>>().map((subRecipe) {
          subRecipe['type'] = 'sub_recipe';
          return subRecipe;
        }).toList());
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
        print("Failed to get SubRecipe List : ${response?.statusCode}");
      }
      update();
    } catch (e) {
      log("Failed to get SubRecipe List :$e");
    } finally {
      setGetRecipesLoader(false);
    }
  }

  List<Map<String, dynamic>> subRecipesIngredientsList = [
    addSubRecipesIngredients(),
  ];

  static Map<String, dynamic> addSubRecipesIngredients() {
    return {
      "ingredientsNameController": TextEditingController(),
      "ingredientsId": "",
      "unit": "",
      "quantity": TextEditingController(),
    };
  }

  addSubRecipesIngredientsData() {
    subRecipesIngredientsList
        .add(InventoryController.addSubRecipesIngredients());
    update();
  }

  removeSubRecipesIngredientsData(int index) {
    subRecipesIngredientsList.removeAt(index);
    update();
  }

  addSubRecipe() async {
    try {
      if (subRecipeNameController.text.isNotEmpty &&
          (subRecipeUnit?.isNotEmpty ?? false) &&
          // subRecipeThresholdQtyController.text.isNotEmpty &&
          // (subRecipeThresholdUnit?.isNotEmpty ?? false) &&
          subRecipesIngredientsList.any(
            (e) {
              final ingredientsNameController =
                  e["ingredientsNameController"]?.text;
              final unit = e["unit"];
              final qty = e["quantity"]?.text;

              return ((ingredientsNameController?.isNotEmpty ?? false) &&
                  (unit?.isNotEmpty ?? false) &&
                  (qty?.isNotEmpty ?? false));
            },
          )) {
        if (isAddSubRecipesSubmitting.value) return;
        isAddSubRecipesSubmitting.value = true;
        addSubRecipesLoader.value = true;
        Map<String, dynamic> data = {
          "sub_recipe_name": subRecipeNameController.text,
          "subunit": subRecipeUnit,
          "qty": subRecipeQuantityController.text ?? '1',
          "prepration_time": subRecipePTimeController.text ?? '1',
          "serve_time": subRecipeSTimeController.text ?? '1',
          "serve_people": num.tryParse(subRecipeSPeopleController.text) ?? 1,
          "thershold_qty": subRecipeThresholdQtyController.text,
          "thershold_unit": subRecipeThresholdUnit,
          "ingredient": subRecipesIngredientsList.map(
            (e) {
              return {
                "id": e["ingredientsId"],
                "unit": e["unit"],
                "qty": num.tryParse(e["quantity"].text) ?? 0
              };
            },
          ).toList()
        };

        final response = await inventoryRepo.addSubRecipe(data);

        if (response?.statusCode == 200) {
          // Refresh based on current filter
          // if (selectedRecipeType == 'Sub-Recipe') {
          //   await getSubRecipeList();
          // } else if (selectedRecipeType == 'All') {
          //   await getAllRecipesAndSubRecipes();
          // }
          onChangedRecipeCategory(selectedRecipeType ?? 'All');

          Get.back();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(AppString.addSubRecipeSuccessfully)
              : Get.snackbar(
                  'Added',
                  'New Sub-Recipe Added Successfuly.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
          print(
              'Failed to Add sub recipe : ${response?.body} , ${response?.statusCode}');
        }
      } else {
        appToast(AppString.pleaseFillFields);
      }
    } catch (e) {
      log("addSubRecipe :$e");
    } finally {
      addSubRecipesLoader.value = false;
      isAddSubRecipesSubmitting.value = false;
    }
  }

  showSubRecipesData(Map<String, dynamic> subRecipe) {
    subRecipeNameController.text = subRecipe["name"] ?? '';
    subRecipeUnit = (subRecipe["unit"] ?? '').trim().toLowerCase();
    subRecipeQuantityController.text = subRecipe["qty"]?.toString() ?? '';
    subRecipePTimeController.text =
        subRecipe["preparation_time"]?.toString() ?? '';
    subRecipeSTimeController.text = subRecipe["serve_time"]?.toString() ?? '';
    subRecipeSPeopleController.text =
        subRecipe["serve_people"]?.toString() ?? '';

    // These keys are not present in the new JSON, so default or blank
    subRecipeThresholdQtyController.text = subRecipe['min_qty_alert'];
    subRecipeThresholdUnit = subRecipe['min_unit_alert'];

    // Handle ingredients
    if ((subRecipe["ingredients"] ?? []).isNotEmpty) {
      subRecipesIngredientsList =
          (subRecipe["ingredients"] as List<dynamic>).map((r) {
        return {
          "ingredientsNameController":
              TextEditingController(text: r["ingredient_name"] ?? ''),
          "ingredientsId": r["ingredient_id"] ?? '',
          "unit": r["ingredient_unit"] ?? '',
          "quantity": TextEditingController(
              text: r["ingredient_qty"]?.toString() ?? ''),
        };
      }).toList();
    } else {
      subRecipesIngredientsList.clear();
      subRecipesIngredientsList.add({
        "ingredientsNameController": TextEditingController(),
        "ingredientsId": "",
        "unit": "",
        "quantity": TextEditingController(),
      });
    }
  }

  updateSubRecipe(int id) async {
    try {
      if (isAddSubRecipesSubmitting.value) return;
      isAddSubRecipesSubmitting.value = true;
      addSubRecipesLoader.value = true;
      Map<String, dynamic> data = {
        "sub_recipe_name": subRecipeNameController.text,
        "subunit": subRecipeUnit,
        "qty": subRecipeQuantityController.text,
        "prepration_time": subRecipePTimeController.text,
        "serve_time": subRecipeSTimeController.text,
        "serve_people": num.tryParse(subRecipeSPeopleController.text) ?? 0,
        "thershold_qty": subRecipeThresholdQtyController.text,
        "thershold_unit": subRecipeThresholdUnit,
        "ingredients": subRecipesIngredientsList.map(
          (e) {
            return {
              "id": e["ingredientsId"],
              "unit": e["unit"],
              "qty": num.tryParse(e["quantity"].text) ?? 0
            };
          },
        ).toList()
      };
      final response = await inventoryRepo.updateSubRecipe(id, data: data);

      if (response?.statusCode == 200) {
        // Refresh based on current filter
        // if (selectedRecipeType == 'Sub-Recipe') {
        //   await getSubRecipeList();
        // } else if (selectedRecipeType == 'All') {
        //   await getAllRecipesAndSubRecipes();
        // }
        onChangedRecipeCategory(selectedRecipeType ?? 'All');

        Get.back();
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(response?.body?["message"])
            : Get.snackbar(
                'Updated',
                '${response?.body['message']}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
        print(
            'Failed to update sub recipe : ${response?.body} , ${response?.statusCode}');
      }
    } catch (e) {
      log("updateSubRecipe :$e");
    } finally {
      addSubRecipesLoader.value = false;
      isAddSubRecipesSubmitting.value = false;
    }
  }

  deleteSubRecipe(int id, {bool deleteInside = false}) async {
    try {
      if (isDeleteRecipesSubmitting.value) return;
      isDeleteRecipesSubmitting.value = true;
      deleteRecipesLoader.value = true;

      final response = await inventoryRepo.deleteSubRecipe(id);

      if (response?.statusCode == 200) {
        // Refresh based on current filter
        // if (selectedRecipeType == 'Sub-Recipe') {
        //   await getSubRecipeList();
        // } else if (selectedRecipeType == 'All') {
        //   await getAllRecipesAndSubRecipes();
        // }
        onChangedRecipeCategory(selectedRecipeType ?? 'All');

        if (deleteInside == true) {
          Get.back();
          Get.back();
        } else {
          Get.back();
        }
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(response?.body?["message"])
            : Get.snackbar(
                'Deleted',
                '${response?.body['message']}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
        print(
            'Failed to Delete sub recipe : ${response?.body} , ${response?.statusCode}');
      }
      update();
    } catch (e) {
      log("deleteSubRecipe :$e");
    } finally {
      isDeleteRecipesSubmitting.value = false;
      deleteRecipesLoader.value = false;
    }
  }

  clearSubRecipesData() {
    subRecipeNameController.clear();
    subRecipeUnit = null;
    subRecipeQuantityController.clear();
    subRecipePTimeController.clear();
    subRecipeSTimeController.clear();
    subRecipeSPeopleController.clear();
    subRecipeThresholdQtyController.clear();
    subRecipeThresholdUnit = null;
    subRecipesIngredientsList.clear();
    subRecipesIngredientsList.add({
      "ingredientsNameController": TextEditingController(),
      "ingredientsId": "",
      "unit": "",
      "quantity": TextEditingController(),
    });
  }

  exportSubRecipes() async {
    try {
      final response = await inventoryRepo.exportSubRecipes();

      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["file_url"]);
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('exportSubRecipes :$e');
    }
  }

  exportSubRecipeSample() async {
    exportSampleLoader.value = true;
    update();
    try {
      final response = await inventoryRepo.exportSubRecipeSample();
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      } else {
        ApiChecker.checkApi(response!);
        Get.snackbar("Error", response.body?["error"],
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      update();
    } catch (e) {
      log("exportRecipe :$e");
    } finally {
      exportSampleLoader.value = false;
      update();
    }
  }

  importSubRecipes() async {
    try {
      // Use file_picker to select an .xlsx file
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );

      // if (result != null && result.files.single.path != null) {
      // Send the file to the server
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await inventoryRepo.importSubRecipes(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: 'file',
        );

        if (response?.statusCode == 200) {
          Get.back();
          Get.back();
          // Refresh based on current filter
          if (selectedRecipeType == 'Sub-Recipe') {
            await getSubRecipeList();
          } else if (selectedRecipeType == 'All') {
            await getAllRecipesAndSubRecipes();
          }
          Get.snackbar(
              'Import Sub-Recipe Successfully', response?.body?["message"],
              backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 401) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar("Error", response?.body?["error"],
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
      log("importSubRecipes :$e");
    } finally {
      isImportLoader.value = false;
      update();
    }
  }
  
/***********************SUB-RECIPES*************************/

/*********************************************************RECIPES********************************************************/

  //.....................Bulk Upload.......................//

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

  exportIngredientsSample() async {
    exportSampleLoader.value = true;
    update();
    print('Downloading Ingredients Bulk Import Sample Excel File ...');
    await appLaunchUrl(
        '${AppConstants.BASE_URL}/bulk_upload_sample/Ingredients/Ingredients_Bulk_Import_Sample.xlsx');
    print('Ingredients Bulk Upload Downloaded Successfully.');
    Get.snackbar('Downloaded Successfully',
        'Ingredients Bulk Upload Downloaded Successfully.',
        backgroundColor: ColorTheme.green, colorText: Colors.white);
    exportSampleLoader.value = false;
    update();
  }

  ExportIngredients() async {
    try {
      isExportLoader.value = true;
      update();
      final response = await inventoryRepo.exportIngredients();
      if (response?.statusCode == 200) {
        appLaunchUrl(response?.body?["download_url"]);
        appToast(response?.body?["message"]);
      }
      update();
    } catch (e) {
      log("exportRecipe :$e");
    } finally {
      isExportLoader.value = false;
      update();
    }
  }

  importIngredients() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );
      // if (result != null && result.files.single.path != null) {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final response = await inventoryRepo.importInventory(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: 'file',
        );
        if (response?.statusCode == 200) {
          await getRecipeList();
          Get.back();
          Get.to(CurrentStocksScreen());
          // appToast(response?.body?["message"]);
          Get.snackbar('Import', response?.body?["message"],
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          // appToast(response?.body?["errors"]);
          Get.snackbar('Error', response?.body?["errors"],
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
      log("importSubRecipes :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  importVendorSupplier() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        final response = await inventoryRepo.importVendorSupplier(
          data: {},
          fileName: result.files.single.path ?? "",
          keyFileName: 'file',
        );
        if (response?.statusCode == 200) {
          await getVendor();
          appToast(response?.body?["message"]);
          Get.back();
        }
      } else {
        log("No file selected or file path is null.");
      }
      update();
    } catch (e) {
      log("importVendorSupplier :$e");
    }
  }

  //.....................Manage Inventory....................//
  var inventroyFoodList = <Map<String, dynamic>>[].obs;
  Map<int, bool> foodSwitchLoader = {};

  TextEditingController inventorySearchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  double savedScrollPosition = 0.0;
  Map<String, dynamic> RecipeByIdDetail = {};
  RxString selectedFilter = 'All'.obs;
  List<String> filterOptions = ['All', 'Active', 'Inactive'];

  bool isFoodLoader = false;
  getInventroyFoodList() async {
    try {
      isFoodLoader = true;
      update();
      final response = await inventoryRepo.getInventroyFoodList();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['foods'] ?? [];
        inventroyFoodList.assignAll(data.cast<Map<String, dynamic>>());
        print("inventroyFoodList : ${inventroyFoodList.toList()}");
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getCategoryList :$e");
    } finally {
      isFoodLoader = false;
      update();
    }
  }

  // Recipe Food List - for active foods only
  var recipeFoodList = <Map<String, dynamic>>[].obs;
  bool isRecipeFoodLoader = false;

  getRecipeFoodList() async {
    try {
      isRecipeFoodLoader = true;
      update();
      final response = await inventoryRepo.getActiveFoodsList();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['data']?['foods'] ?? [];
        recipeFoodList.assignAll(data.cast<Map<String, dynamic>>());
        print("recipeFoodList : ${recipeFoodList.length} items");
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getRecipeFoodList error: $e");
    } finally {
      isRecipeFoodLoader = false;
      update();
    }
  }

  void resetFilter() {
    selectedFilter.value = 'All';
    inventorySearchController.clear();
    update();
  }

  // Simple save - bas position save karo
  void saveScroll() {
    if (scrollController.hasClients) {
      savedScrollPosition = scrollController.offset;
    }
  }

// Simple restore - turant position restore karo
  void restoreScroll() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(savedScrollPosition);
    }
  }

  statusInventoryFood({required Map<String, dynamic> data}) async {
    final int foodId = int.parse(data["food_id"]);
    saveScroll(); // Pehle position save karo
    try {
      foodSwitchLoader[foodId] = true;
      update();
      final response = await inventoryRepo.statusInventoryFood(data: data);
      if (response?.statusCode == 200) {
        appToast(response?.body?["message"]);
        await getInventroyFoodList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          restoreScroll();
        });
        update();
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("statusInventoryFood :$e");
    } finally {
      foodSwitchLoader[foodId] = false;
      update();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  getRecipeById({required int id}) async {
    try {
      isFoodLoader = true;
      update();
      final response = await inventoryRepo.getRecipeById(id);

      if (response?.statusCode == 200) {
        RecipeByIdDetail = response?.body?['recipe'] ?? {};
        print("RecipeByIdDetail : ${RecipeByIdDetail}");
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("RecipeByIdDetail :$e");
    } finally {
      isFoodLoader = false;
      update();
    }
  }

//.....................Manage Vendor....................//
  bool isvendorLoader = false;
  List<Map<String, dynamic>> getVendorList = [];
  TextEditingController vendorNameController = TextEditingController();
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController vendorEmailController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();
  TextEditingController vendorSearchController = TextEditingController();
  String? vendorType;
  final GlobalKey<FormState> vendorFormKey = GlobalKey<FormState>();
  RxBool addVendorLoader = false.obs;
  RxBool isVendorSubmitting = false.obs;

  vendorApiCalling(
      {required bool isEdit, Map<String, dynamic>? vendorData}) async {
    if (isEdit) {
      vendorNameController.text = vendorData?['vendor_name'];
      contactPersonController.text = vendorData?['contact_person_name'];
      contactNumberController.text = vendorData?['contact_number'];
      vendorEmailController.text = vendorData?['email'];
      gstNumberController.text = vendorData?['gst_no'];
      vendorType = vendorData?['vendor_type'];
      addressController.text = vendorData?['address'];
    } else {
      vendorNameController.clear();
      contactPersonController.clear();
      contactNumberController.clear();
      vendorEmailController.clear();
      gstNumberController.clear();
      vendorType = vendorData?['vendor_type'];
      addressController.clear();
    }
  }

  getVendor() async {
    try {
      isvendorLoader = true;
      update();
      final response = await inventoryRepo.getVendor();

      if (response?.statusCode == 200 && response?.body != null) {
        final List<dynamic> rawList = response!.body;
        getVendorList =
            rawList.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      log('getVendorList: ${getVendorList.toList()}');
      update();
    } catch (e) {
      log("getVendor: $e");
    } finally {
      isvendorLoader = false;
      update();
    }
  }

  addVendor() async {
    try {
      if (isVendorSubmitting.value) return;
      isVendorSubmitting.value = true;
      addVendorLoader.value = true;
      Map<String, dynamic> data = {
        "vendor_name": vendorNameController.text.trim(),
        "contact_person_name": contactPersonController.text.trim(),
        "contact_number": contactNumberController.text.trim(),
        "email": vendorEmailController.text.trim(),
        "gst_no": gstNumberController.text.trim(),
        "vendor_type": vendorType,
        "address": addressController.text.trim()
      };

      final response = await inventoryRepo.addVendor(data);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        await getVendor();
        appToast(AppString.addVendorSuccessfully);
        Get.back();
      }
      update();
    } catch (e) {
      log("addVendor :$e");
    } finally {
      addVendorLoader.value = false;
      isVendorSubmitting.value = false;
    }
  }

  updateVendor(int id) async {
    try {
      if (isVendorSubmitting.value) return;
      isVendorSubmitting.value = true;
      addVendorLoader.value = true;
      Map<String, dynamic> data = {
        "vendor_name": vendorNameController.text.trim(),
        "contact_person_name": contactPersonController.text.trim(),
        "contact_number": contactNumberController.text.trim(),
        "email": vendorEmailController.text.trim(),
        "gst_no": gstNumberController.text.trim(),
        "vendor_type": vendorType,
        "address": addressController.text.trim()
      };

      final response = await inventoryRepo.updateVendor(id, data);

      if (response?.statusCode == 200) {
        await getVendor();
        appToast(AppString.updateVendorSuccessfully);
        Get.back();
      }
      update();
    } catch (e) {
      log("addVendor :$e");
    } finally {
      addVendorLoader.value = false;
      isVendorSubmitting.value = false;
    }
  }

  deleteVendor({int? id}) async {
    try {
      isvendorLoader = true;
      update();
      Response? response = await inventoryRepo.deleteVendor(id!);
      if (response?.statusCode == 200) {
        // Get.back();
        await getVendor();
        update();
        appToast(AppString.deleteVendorSuccessfully);
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      print(e);
    } finally {
      isvendorLoader = false;
      update();
    }
  }

  vendorDataClear() {
    vendorNameController.clear();
    contactPersonController.clear();
    contactNumberController.clear();
    vendorEmailController.clear();
    addressController.clear();
    vendorType = null;
  }

  //====================== Wastage Reason ======================//

  var wastageReasonsList = <Map<String, dynamic>>[].obs;
  var selectedWastageReasonId = RxnInt();
  bool isWastageReasonsLoading = false;
  Future<void> getWastageReasons() async {
    try {
      isWastageReasonsLoading = true;
      update();

      selectedWastageReasonId.value = null;
      final response = await inventoryRepo.getWastageReasons();

      if (response?.statusCode == 200) {
        final List<dynamic> reasons = response?.body['reasons'] ?? [];
        wastageReasonsList.assignAll(reasons.cast<Map<String, dynamic>>());

        // // Set first reason as default if available
        // if (wastageReasonsList.isNotEmpty) {
        //   selectedWastageReasonId.value = wastageReasonsList[0]['id'];
        // }

        log('Wastage Reasons: ${wastageReasonsList.toList()}');
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('getWastageReasons Error: $e');
    } finally {
      isWastageReasonsLoading = false;
      update();
    }
  }

  /// Set selected wastage reason
  void setWastageReason(int? reasonId) {
    selectedWastageReasonId.value = reasonId;
    update();
  }

  /// Get selected wastage reason text
  String? getSelectedWastageReasonText() {
    if (selectedWastageReasonId.value == null) return null;

    final reason = wastageReasonsList.firstWhere(
      (r) => r['id'] == selectedWastageReasonId.value,
      orElse: () => {},
    );

    return reason['reason'];
  }

  //====================== Wastage Reason ======================//

  //====================== Wastage Report ======================//

  TextEditingController searchWastageReport = TextEditingController();
  String selectedItemType = "all";

  Future<void> getWastageReport({
    required String startDate,
    required String endDate,
    String wasteType = 'Loss',
  }) async {
    try {
      isWastageReportLoading = true;
      update();

      // Convert date format from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime? startDateTime = inputFormat.tryParse(startDate);
      DateTime? endDateTime = inputFormat.tryParse(endDate);

      String apiStartDate = startDateTime != null
          ? outputFormat.format(startDateTime)
          : startDate;
      String apiEndDate =
          endDateTime != null ? outputFormat.format(endDateTime) : endDate;

      Map<String, dynamic> data = {
        'start_date': apiStartDate,
        'end_date': apiEndDate,
        'waste_type': wasteType,
      };

      final response = await inventoryRepo.getWastageReport(data: data);

      if (response?.statusCode == 200 && response?.body != null) {
        final responseBody = response!.body;

        // Extract summary data
        if (responseBody['summary'] != null) {
          wastageSummary = Map<String, dynamic>.from(responseBody['summary']);
        } else {
          wastageSummary = {
            'total_records': 0,
            'total_loss': 0.0,
            'total_gain': 0.0,
            'net_wastage': 0.0,
          };
        }

        // Extract wastage records
        if (responseBody['wastage_records'] != null) {
          final List<dynamic> rawRecords = responseBody['wastage_records'];
          wastageRecords = rawRecords
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else {
          wastageRecords = [];
        }

        log('Wastage Report fetched: ${wastageRecords.length} records');
      } else {
        ApiChecker.checkApi(response!);
        wastageSummary = {
          'total_records': 0,
          'total_loss': 0.0,
          'total_gain': 0.0,
          'net_wastage': 0.0,
        };
        wastageRecords = [];
      }
    } catch (e) {
      log("getWastageReport Error: $e");
      wastageSummary = {
        'total_records': 0,
        'total_loss': 0.0,
        'total_gain': 0.0,
        'net_wastage': 0.0,
      };
      wastageRecords = [];
      appToast('Failed to fetch wastage report');
    } finally {
      isWastageReportLoading = false;
      update();
    }
  }
  //====================== Wastage Report ======================//

  //====================== Daily Consumption Report ======================//

  String? consumptionStartDate;
  String? consumptionEndDate;
  TextEditingController searchConsumptionReport = TextEditingController();
  bool isConsumptionReportLoading = false;
  List<Map<String, dynamic>> consumptionStockSummary = [];

  Future<void> getDailyConsumptionReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      isConsumptionReportLoading = true;
      update();

      // Convert date format from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime? startDateTime = inputFormat.tryParse(startDate);
      DateTime? endDateTime = inputFormat.tryParse(endDate);

      String apiStartDate = startDateTime != null
          ? outputFormat.format(startDateTime)
          : startDate;
      String apiEndDate =
          endDateTime != null ? outputFormat.format(endDateTime) : endDate;

      Map<String, dynamic> data = {
        'from_date': apiStartDate,
        'to_date': apiEndDate,
      };

      final response =
          await inventoryRepo.getDailyConsumptionReport(data: data);

      if (response?.statusCode == 200 && response?.body != null) {
        final responseBody = response!.body;

        // Extract stock_summary data
        if (responseBody['stock_summary'] != null) {
          final List<dynamic> rawSummary = responseBody['stock_summary'];
          consumptionStockSummary = rawSummary
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else {
          consumptionStockSummary = [];
        }

        log('Daily Consumption Report fetched: ${consumptionStockSummary.length} items');
      } else {
        ApiChecker.checkApi(response!);
        consumptionStockSummary = [];
      }
    } catch (e) {
      log("getDailyConsumptionReport Error: $e");
      consumptionStockSummary = [];
      appToast('Failed to fetch daily consumption report');
    } finally {
      isConsumptionReportLoading = false;
      update();
    }
  }

  Future<void> exportConsumptionExcel() async {
    try {
      isConsumptionReportLoading = true;
      update();
      if (consumptionStartDate == null || consumptionEndDate == null) {
        Get.snackbar(
          'Error',
          'Please select date range',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Convert date format from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime? startDateTime = inputFormat.tryParse(consumptionStartDate!);
      DateTime? endDateTime = inputFormat.tryParse(consumptionEndDate!);

      String apiStartDate = startDateTime != null
          ? outputFormat.format(startDateTime)
          : consumptionStartDate!;
      String apiEndDate = endDateTime != null
          ? outputFormat.format(endDateTime)
          : consumptionEndDate!;

      Map<String, dynamic> data = {
        'from_date': apiStartDate,
        'to_date': apiEndDate,
      };

      final response = await inventoryRepo.exportConsumptionExcel(data: data);

      if (response?.statusCode == 200 && response?.body != null) {
        final downloadUrl = response?.body['download_url'];
        final message = response?.body['message'];

        if (downloadUrl != null) {
          appLaunchUrl(downloadUrl);
        }

        if (message != null) {
          Get.snackbar(
            'Success',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("exportConsumptionExcel Error: $e");
      Get.snackbar(
        'Error',
        'Failed to export consumption report',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConsumptionReportLoading = false;
      update();
    }
  }

  //====================== Daily Consumption Report ======================//

  //====================== Recipe Food list  ======================//

  //====================== Wastage Master Management ======================//

  var wastageMasterList = <Map<String, dynamic>>[].obs;
  TextEditingController wastageMasterSearchController = TextEditingController();
  TextEditingController wastageMasterAddController = TextEditingController();
  RxBool isWastageMasterLoading = false.obs;
  RxBool isWastageMasterSubmitting = false.obs;
  RxBool isWastageMasterStatusUpdating = false.obs;
  RxInt updatingWastageReasonId = (-1).obs;
  RxInt editingWastageReasonId = (-1).obs; // Track which item is being edited

  /// Clear wastage master list
  void clearWastageMasterList() {
    wastageMasterList.clear();
    update();
  }

  /// Get wastage reasons list
  Future<void> getWastageMasterList() async {
    try {
      isWastageMasterLoading.value = true;
      update();

      final response = await inventoryRepo.getWastageReasonsList();

      if (response?.statusCode == 200) {
        final responseBody = response?.body;
        if (responseBody != null && responseBody['data'] != null) {
          final List<dynamic> reasons = responseBody['data']['reasons'] ?? [];
          wastageMasterList.assignAll(reasons.cast<Map<String, dynamic>>());
          log('Wastage Master List: ${wastageMasterList.length} items');
        } else {
          wastageMasterList.clear();
        }
      } else {
        ApiChecker.checkApi(response!);
        wastageMasterList.clear();
      }
      update();
    } catch (e) {
      log('getWastageMasterList Error: $e');
      wastageMasterList.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch wastage reasons',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isWastageMasterLoading.value = false;
      update();
    }
  }

  /// Add new wastage reason
  Future<void> addWastageMasterReason() async {
    try {
      if (wastageMasterAddController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Please enter wastage reason',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (isWastageMasterSubmitting.value) return;
      isWastageMasterSubmitting.value = true;
      update();

      Map<String, dynamic> data = {
        'reason': wastageMasterAddController.text.trim(),
      };

      final response = await inventoryRepo.addWastageReason(data);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        wastageMasterAddController.clear();
        editingWastageReasonId.value = -1; // Clear edit mode
        await getWastageMasterList(); // Refresh list after adding
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Wastage reason added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('addWastageMasterReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to add wastage reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isWastageMasterSubmitting.value = false;
      update();
    }
  }

  /// Update wastage reason status
  Future<void> updateWastageMasterStatus(int id, int currentStatus) async {
    try {
      if (isWastageMasterStatusUpdating.value) return;
      isWastageMasterStatusUpdating.value = true;
      update();

      // Toggle status: 1 -> 0, 0 -> 1
      updatingWastageReasonId.value = id;

      final newStatus = currentStatus == 1 ? 0 : 1;
      Map<String, dynamic> data = {
        'status': newStatus,
      };

      final response = await inventoryRepo.updateWastageReasonStatus(id, data);

      if (response?.statusCode == 200) {
        await getWastageMasterList(); // Refresh list after status update
        // Update only the specific item that was changed
        update(['wastage_item_$id']);
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
      log('updateWastageMasterStatus Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isWastageMasterStatusUpdating.value = false;
      updatingWastageReasonId.value = -1;
      update();
    }
  }

  /// Get filtered wastage reasons based on search
  List<Map<String, dynamic>> getFilteredWastageMasterList() {
    if (wastageMasterSearchController.text.trim().isEmpty) {
      return wastageMasterList.toList();
    }

    final searchQuery = wastageMasterSearchController.text.trim().toLowerCase();
    return wastageMasterList
        .where((reason) => (reason['reason']?.toString().toLowerCase() ?? '')
            .contains(searchQuery))
        .toList();
  }

  /// Update wastage reason
  RxBool isWastageMasterUpdating = false.obs;
  Future<void> updateWastageReason(int id, String reason) async {
    try {
      if (isWastageMasterUpdating.value) return;
      isWastageMasterUpdating.value = true;
      update();

      Map<String, dynamic> data = {
        'reason': reason.trim(),
      };

      final response = await inventoryRepo.updateWastageReason(id, data);

      if (response?.statusCode == 200) {
        wastageMasterAddController.clear();
        editingWastageReasonId.value = -1; // Clear edit mode
        await getWastageMasterList(); // Refresh list after updating
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Wastage reason updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('updateWastageReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update wastage reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isWastageMasterUpdating.value = false;
      update();
    }
  }

  /// Delete wastage reason
  RxBool isWastageMasterDeleting = false.obs;
  Future<void> deleteWastageReason(int id) async {
    try {
      if (isWastageMasterDeleting.value) return;
      isWastageMasterDeleting.value = true;
      update();

      final response = await inventoryRepo.deleteWastageReason(id);

      if (response?.statusCode == 200) {
        // If the deleted item was being edited, clear edit mode
        if (editingWastageReasonId.value == id) {
          wastageMasterAddController.clear();
          editingWastageReasonId.value = -1;
        }
        await getWastageMasterList(); // Refresh list after deleting
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Wastage reason deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('deleteWastageReason Error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete wastage reason',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isWastageMasterDeleting.value = false;
      update();
    }
  }

  //====================== Wastage Master Management ======================//

  //====================== Delete Ingredient ======================//

  RxBool isDeletingIngredient = false.obs;
  RxInt deletingIngredientId = (-1).obs;

  Future<void> deleteIngredient(int id) async {
    try {
      if (isDeletingIngredient.value) return;
      isDeletingIngredient.value = true;
      deletingIngredientId.value = id;
      update();

      final response = await inventoryRepo.deleteIngredient(id);

      if (response?.statusCode == 200) {
        // Refresh the stock inventory list
        await getCurrentStock();
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Ingredient deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        final errorMessage =
            response?.body?['message'] ?? 'Failed to delete ingredient';
        final errorData = response?.body?['data'];

        String fullErrorMessage = errorMessage;
        if (errorData != null) {
          if (errorData['type'] == 'SubRecipe') {
            fullErrorMessage =
                '$errorMessage\nIngredient: ${errorData['ingredient_name'] ?? 'N/A'}';
          } else if (errorData['reason'] == 'ingredient_used_in_sub_recipes') {
            final ingredientName = errorData['ingredient_name'] ?? 'N/A';
            final subrecipeCount = errorData['subrecipe_count'] ?? 0;
            final usedInSubrecipes = errorData['used_in_subrecipes'] as List?;
            fullErrorMessage =
                '$errorMessage\nIngredient: $ingredientName\nUsed in $subrecipeCount sub-recipe(s)';
            if (usedInSubrecipes != null && usedInSubrecipes.isNotEmpty) {
              final subrecipeNames = usedInSubrecipes.take(5).join(', ');
              final moreCount = usedInSubrecipes.length > 5
                  ? ' and ${usedInSubrecipes.length - 5} more'
                  : '';
              fullErrorMessage += '\nSub-recipes: $subrecipeNames$moreCount';
            }
          } else if (errorData['reason'] == 'ingredient_used_in_main_recipes') {
            final ingredientName = errorData['ingredient_name'] ?? 'N/A';
            final recipeCount = errorData['recipe_count'] ?? 0;
            final usedInRecipes = errorData['used_in_recipes'] as List?;
            fullErrorMessage =
                '$errorMessage\nIngredient: $ingredientName\nUsed in $recipeCount recipe(s)';
            if (usedInRecipes != null && usedInRecipes.isNotEmpty) {
              final recipeNames = usedInRecipes.take(5).join(', ');
              final moreCount = usedInRecipes.length > 5
                  ? ' and ${usedInRecipes.length - 5} more'
                  : '';
              fullErrorMessage += '\nRecipes: $recipeNames$moreCount';
            }
          }
        }

        Get.snackbar('Error', fullErrorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5));
      }
      update();
    } catch (e) {
      log('deleteIngredient Error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete ingredient',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isDeletingIngredient.value = false;
      deletingIngredientId.value = -1;
      update();
    }
  }

  //====================== Delete Ingredient ======================//

  //======================================= Addon-Recipe Section ======================================//

  // List
  var addonRecipeList = <Map<String, dynamic>>[].obs;
  var addonsWithoutRecipeList = <Map<String, dynamic>>[].obs;

  // Form state
  int? addonRecipeAddonId; // addon_id → goes in request body
  int? editAddonRecipeId; // recipe_id → goes in PUT endpoint URL
  String? addonRecipeUnitValue; // recipe_unit

  // Loaders
  RxBool getAddonRecipeLoader = false.obs;
  RxBool addAddonRecipeLoader = false.obs;
  RxBool isAddonRecipeSubmitting = false.obs;
  RxBool getAddonsWithoutRecipeLoader = false.obs;

  getAddonRecipeList() async {
    try {
      setGetRecipesLoader(true);
      final response = await inventoryRepo.getAddonRecipeList();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['recipes'] ?? [];
        recipeList.assignAll(data.cast<Map<String, dynamic>>().map((recipe) {
          recipe['type'] = 'addon_recipe';
          return recipe;
        }).toList());
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'] ?? '',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      update();
    } catch (e) {
      log('getAddonRecipeList error: $e');
    } finally {
      setGetRecipesLoader(false);
    }
  }

  // ── Addon list without recipe ────────────────────────
  getAddonsWithoutRecipe() async {
    try {
      getAddonsWithoutRecipeLoader.value = true;
      final response = await inventoryRepo.getAddonsWithoutRecipe();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['addons'] ?? [];
        addonsWithoutRecipeList.assignAll(data.cast<Map<String, dynamic>>());
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        ApiChecker.checkApi(response!);
      } else {
        Get.snackbar('Something Went Wrong!', response?.body['message'] ?? '',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      update();
    } catch (e) {
      log('getAddonsWithoutRecipe error: $e');
    } finally {
      getAddonsWithoutRecipeLoader.value = false;
    }
  }

  // ── Populate form fields when editing ────────────────────────
  showAddonRecipesData(Map<String, dynamic> addonRecipe) {
    // IDs
    editAddonRecipeId = addonRecipe['recipe_id'];
    addonRecipeAddonId = addonRecipe['addon_id'];

    // Display fields
    recipeNameController.text = addonRecipe['addon_name'] ?? '';
    quantityController.text = addonRecipe['qty']?.toString() ?? '';
    addonRecipeUnitValue = addonRecipe['unit']?.toString().trim().toLowerCase();
    recipesPreparationTimeController.text =
        addonRecipe['preparation_time']?.toString() ?? '';
    recipesServeTimeController.text =
        addonRecipe['serve_time']?.toString() ?? '';
    servePeopleController.text = addonRecipe['serve_people']?.toString() ?? '';

    // Ingredients rows
    final ingredients = addonRecipe['ingredients'];
    if (ingredients != null && (ingredients as List).isNotEmpty) {
      recipesIngredientsList = (ingredients).map((r) {
        return {
          'ingredientsNameController':
              TextEditingController(text: r['ingredient_name'] ?? ''),
          'ingredientsId': r['ingredient_id'] ?? '',
          'unit': r['ingredient_unit'] ?? '',
          'quantity': TextEditingController(
              text: r['ingredient_qty']?.toString() ?? ''),
        };
      }).toList();
    } else {
      recipesIngredientsList.clear();
      recipesIngredientsList.add(InventoryController.addRecipesIngredients());
    }
    update();
  }

  // ── Clear form ────────────────────────────────────────────────
  clearAddonRecipeData() {
    editAddonRecipeId = null;
    addonRecipeAddonId = null;
    addonRecipeUnitValue = null;
    recipeNameController.clear();
    quantityController.clear();
    recipesPreparationTimeController.clear();
    recipesServeTimeController.clear();
    servePeopleController.clear();
    recipesIngredientsList.clear();
    recipesIngredientsList.add(InventoryController.addRecipesIngredients());
    update();
  }

  // ── Add ───────────────────────────────────────────────────────
  addAddonRecipe() async {
    try {
      log("addAddonRecipe :${recipeNameController.text.isNotEmpty} ${addonRecipeAddonId != 0} ${addRecipesUnitValue?.isNotEmpty ?? false} ");
      if (recipeNameController.text.isNotEmpty &&
          addonRecipeAddonId != 0 &&
          (addonRecipeUnitValue?.isNotEmpty ?? false) &&
          // servePeopleController.text.isNotEmpty &&
          recipesIngredientsList.any(
            (e) {
              final ingredientsNameController =
                  e["ingredientsNameController"]?.text;
              final unit = e["unit"];
              final qty = e["quantity"]?.text;

              return ((ingredientsNameController?.isNotEmpty ?? false) &&
                  (unit?.isNotEmpty ?? false) &&
                  (qty?.isNotEmpty ?? false));
            },
          )) {
        if (isAddonRecipeSubmitting.value) return;
        isAddonRecipeSubmitting.value = true;
        addAddonRecipeLoader.value = true;

        Map<String, dynamic> data = {
          'addon_id': addonRecipeAddonId,
          'preparation_time': recipesPreparationTimeController.text.isEmpty
              ? 1
              : int.tryParse(recipesPreparationTimeController.text) ?? 1,
          'serves_people': int.tryParse(servePeopleController.text) ?? 1,
          'recipe_qty': int.tryParse(quantityController.text) ?? 1,
          'serve_time': recipesServeTimeController.text.isEmpty
              ? 1
              : int.tryParse(recipesServeTimeController.text) ?? 1,
          'recipe_unit': addonRecipeUnitValue,
          'ingredients': recipesIngredientsList.map((e) {
            return {
              'id': e['ingredientsId'],
              'unit': e['unit'],
              'qty': num.tryParse(e['quantity']?.text) ?? 0,
            };
          }).toList(),
        };

        final response = await inventoryRepo.addAddonRecipe(data: data);

        if (response?.statusCode == 200) {
          onChangedRecipeCategory(selectedRecipeType ?? 'All');
          Get.back();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast('Addon Recipe Added Successfully.')
              : Get.snackbar('Added', 'Addon Recipe Added Successfully.',
                  backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 409) {
          Get.snackbar('Already Exists', 'This addon recipe already exists.',
              colorText: Colors.white,
              backgroundColor: const Color.fromARGB(255, 195, 69, 15));
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'] ?? '',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        appToast(AppString.pleaseFillFields);
      }
    } catch (e) {
      log('addAddonRecipe error: $e');
    } finally {
      addAddonRecipeLoader.value = false;
      isAddonRecipeSubmitting.value = false;
    }
  }

  // ── Update ────────────────────────────────────────────────────
  updateAddonRecipe() async {
    try {
      if (recipeNameController.text.isNotEmpty &&
          addonRecipeAddonId != 0 &&
          (addonRecipeUnitValue?.isNotEmpty ?? false) &&
          // servePeopleController.text.isNotEmpty &&
          recipesIngredientsList.any(
            (e) {
              final ingredientsNameController =
                  e["ingredientsNameController"]?.text;
              final unit = e["unit"];
              final qty = e["quantity"]?.text;

              return ((ingredientsNameController?.isNotEmpty ?? false) &&
                  (unit?.isNotEmpty ?? false) &&
                  (qty?.isNotEmpty ?? false));
            },
          )) {
        if (isAddonRecipeSubmitting.value) return;
        isAddonRecipeSubmitting.value = true;
        addAddonRecipeLoader.value = true;

        Map<String, dynamic> data = {
          'addon_id': addonRecipeAddonId,
          'preparation_time': recipesPreparationTimeController.text.isEmpty
              ? 1
              : int.tryParse(recipesPreparationTimeController.text) ?? 1,
          'serves_people': int.tryParse(servePeopleController.text) ?? 1,
          'recipe_qty': int.tryParse(quantityController.text) ?? 1,
          'serve_time': recipesServeTimeController.text.isEmpty
              ? 1
              : int.tryParse(recipesServeTimeController.text) ?? 1,
          'recipe_unit': addonRecipeUnitValue,
          'ingredients': recipesIngredientsList.map((e) {
            return {
              'id': e['ingredientsId'],
              'unit': e['unit'],
              'qty': num.tryParse(e['quantity']?.text) ?? 0,
            };
          }).toList(),
        };

        final response = await inventoryRepo
            .updateAddonRecipe(editAddonRecipeId!, data: data);

        if (response?.statusCode == 200) {
          onChangedRecipeCategory(selectedRecipeType ?? 'All');
          Get.back();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(response?.body?['message'] ?? 'Updated Successfully.')
              : Get.snackbar('Updated',
                  response?.body?['message'] ?? 'Updated Successfully.',
                  backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'] ?? '',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        appToast(AppString.pleaseFillFields);
      }
    } catch (e) {
      log('updateAddonRecipe error: $e');
    } finally {
      addAddonRecipeLoader.value = false;
      isAddonRecipeSubmitting.value = false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────
  deleteAddonRecipe(int id, {bool deleteInside = false}) async {
    try {
      if (deleteRecipesReason?.isNotEmpty ?? false) {
        if (isDeleteRecipesSubmitting.value) return;
        isDeleteRecipesSubmitting.value = true;
        deleteRecipesLoader.value = true;

        Map<String, dynamic> data = {"reason": deleteRecipesReason};
        final response = await inventoryRepo.deleteAddonRecipe(id, data: data);

        if (response?.statusCode == 200) {
          onChangedRecipeCategory(selectedRecipeType ?? 'All');
          if (deleteInside) {
            Get.back();
            Get.back();
          } else {
            Get.back();
          }
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(response?.body?['message'] ?? 'Deleted Successfully.')
              : Get.snackbar('Deleted',
                  response?.body?['message'] ?? 'Deleted Successfully.',
                  backgroundColor: Colors.green, colorText: Colors.white);
        } else if (response?.statusCode == 401 || response?.statusCode == 403) {
          ApiChecker.checkApi(response!);
        } else {
          Get.snackbar('Something Went Wrong!', response?.body['message'] ?? '',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        update();
      } else {
        appToast(AppString.selectReason);
      }
    } catch (e) {
      log('deleteAddonRecipe error: $e');
    } finally {
      isDeleteRecipesSubmitting.value = false;
      deleteRecipesLoader.value = false;
    }
  }
}
