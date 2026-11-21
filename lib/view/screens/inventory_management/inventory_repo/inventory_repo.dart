import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class InventoryRepo {
  final ApiClient apiClient;
  InventoryRepo({required this.apiClient});

  Future<Response?> stockInventory() async {
    return await apiClient.getData(AppConstants.stockInventory);
  }

  Future<Response?> getVendor() async {
    return await apiClient.getData(AppConstants.getVendor);
  }

  Future<Response?> addVendor(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addVendor, data);
  }

  Future<Response?> updateVendor(int id, Map<String, dynamic> data) async {
    return await apiClient.putData("${AppConstants.updateVendor}$id", data);
  }

  Future<Response?> deleteVendor(int id) async {
    return await apiClient.deleteData("${AppConstants.deleteVendor}$id");
  }

  Future<Response?> getInventoryIngredients() async {
    return await apiClient.getData(AppConstants.getInventoryIngredients);
  }

  Future<Response?> addInventoryStock(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addInventoryStock, data);
  }

  Future<Response?> inventoryExportStock() async {
    return await apiClient.getData(AppConstants.inventoryExportStock);
  }

  Future<Response?> purchaseExportPurchaseReport(
      {required Map<String, dynamic> data}) async {
    return await apiClient.getData(AppConstants.purchaseExportPurchaseReport,
        query: data);
  }

  Future<Response?> updateStockStatus(int id,
      {required Map<String, dynamic> data}) async {
    return await await apiClient.postData(
        AppConstants.updateStockStatus(id), data);
  }

  Future<Response?> addIngredientsInventory(
      {required List<Map<String, dynamic>> data}) async {
    return await await apiClient.postData(
        AppConstants.addIngredientsInventory, data);
  }

  Future<Response?> getStockCategories() async {
    return await apiClient.getData(AppConstants.getStockCategories);
  }

  Future<Response?> getInventroyFoodList() async {
    return await apiClient.getData(AppConstants.getInventroyFoodList);
  }

  Future<Response?> getActiveFoodsList() async {
    return await apiClient.getData(AppConstants.getActiveFoodsList);
  }

  Future<Response?> getRecipeById(int id) async {
    return await apiClient.getData("${AppConstants.getRecipeById}$id");
  }

  Future<Response?> updateStock(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData(AppConstants.updateStock(id), data);
  }

  Future<Response?> statusInventoryFood(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(
        AppConstants.updateStatusInventoryFood, data);
  }

  Future<Response?> AddStockCategories(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.AddStockCategories, data);
  }

  Future<Response?> productAddCategories(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.productAddCategories, data);
  }

  Future<Response?> updateCategories(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.updateCategories(id), data);
  }

  Future<Response?> getPurchaseReport(Map<String, dynamic> data) async {
    return await apiClient.getData(AppConstants.getPurchaseReport, query: data);
  }

  Future<Response?> vendorType() async {
    return await apiClient.getData(AppConstants.vendorType);
  }

  Future<Response?> deleteReport(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.deleteWData(AppConstants.deleteReport(id),
        body: data);
  }

  Future<Response?> unitInventory(int id) async {
    return await apiClient.getData(AppConstants.unitInventory(id));
  }

  Future<Response?> addSingleStock(
      {required Map<String, dynamic> data, required int id}) async {
    return await apiClient.postData(AppConstants.addSingleStock(id), data);
  }

  Future<Response?> addSubRecipeStock(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.addSubRecipeStock, data);
  }

  //* Recipe
  Future<Response?> getRecipeList({Map<String, dynamic>? data}) async {
    return await apiClient.getData(AppConstants.getRecipeList, query: data);
  }

  Future<Response?> getAllRecipeList() async {
    return await apiClient.getData(AppConstants.getAllRecipeList);
  }

  Future<Response?> addRecipe(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addRecipe, data);
  }

  Future<Response?> updateRecipe(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData(AppConstants.updateRecipe(id), data);
  }

  //Sub-Recipe

  Future<Response?> getSubRecipeList() async {
    return await apiClient.getData(AppConstants.getSubRecipe);
  }

  Future<Response?> addSubRecipe(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addSubRecipe, data);
  }

  Future<Response?> updateSubRecipe(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData('${AppConstants.updateSubRecipe}$id', data);
  }

  Future<Response?> deleteSubRecipe(
    int id,
  ) async {
    return await apiClient.deleteData('${AppConstants.deleteSubRecipe}$id');
  }

  Future<Response?> exportRecipe() async {
    return await apiClient.getData(AppConstants.exportRecipe);
  }

  Future<Response?> exportRecipeSample() async {
    return await apiClient.getData(AppConstants.exportRecipeSample);
  }

  Future<Response?> inventoryExportInventorySemple() async {
    return await apiClient.getData(AppConstants.inventoryExportInventorySemple);
  }

  Future<Response?> exportIngredients() async {
    return await apiClient.getData(AppConstants.exportIngredients);
  }

  Future<Response?> exportSubRecipes() async {
    return await apiClient.getData(AppConstants.exportSubRecipes);
  }

  Future<Response?> exportSubRecipeSample() async {
    return await apiClient.getData(AppConstants.exportSubRecipeSample);
  }

  Future<Response?> deleteRecipe(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.deleteWData(AppConstants.deleteRecipe(id),
        body: data);
  }

  // Addon recipe
  Future<Response?> getAddonRecipeList() async {
    return await apiClient.getData(AppConstants.GET_ADDON_RECIPE_LIST);
  }

  Future<Response?> getAddonsWithoutRecipe() async {
    return await apiClient.getData(AppConstants.GET_ADDONS_WITHOUT_RECIPE);
  }

  Future<Response?> addAddonRecipe({required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.ADD_ADDON_RECIPE, data);
  }

  Future<Response?> deleteAddonRecipe(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient
        .deleteWData('${AppConstants.DELETE_ADDON_RECIPE}/$id', body: data);
  }

  Future<Response?> updateAddonRecipe(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData(
        '${AppConstants.UPDATE_ADDON_RECIPE}/$id', data);
  }

  //

  Future<Response?> getRecipesIngredients() async {
    return await apiClient.getData(AppConstants.getRecipesIngredients);
  }

  Future<Response?> getWastageReasons() async {
    return await apiClient.getData(AppConstants.wastageReasons);
  }

  Future<Response?> getWastageReasonsList() async {
    return await apiClient.getData(AppConstants.wastageReasonsList);
  }

  Future<Response?> addWastageReason(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.wastageReasonsAdd, data);
  }

  Future<Response?> updateWastageReasonStatus(
      int id, Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.wastageReasonsStatus(id), data);
  }

  Future<Response?> updateWastageReason(
      int id, Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.wastageReasonsUpdate(id), data);
  }

  Future<Response?> deleteWastageReason(int id) async {
    return await apiClient.deleteData(AppConstants.wastageReasonsDelete(id));
  }

  Future<Response?> importRecipe(
      {required Map<String, String> data,
      required String fileName,
      required String keyFileName}) async {
    return await apiClient.postFromData(
      AppConstants.importRecipe,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> importSubRecipes(
      {required Map<String, String> data,
      required String fileName,
      required String keyFileName}) async {
    return await apiClient.postFromData(
      AppConstants.importSubRecipes,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> importVendorSupplier(
      {required Map<String, String> data,
      required String fileName,
      required String keyFileName}) async {
    return await apiClient.postFromData(
      AppConstants.importVendorSupplier,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> importInventory(
      {required Map<String, String> data,
      required String fileName,
      required String keyFileName}) async {
    return await apiClient.postFromData(
      AppConstants.importInventory,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> inventoryUploadStockExcel(
      {required Map<String, String> data,
      required String fileName,
      required String keyFileName}) async {
    return await apiClient.postFromData(
      AppConstants.inventoryUploadStockExcel,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> getWastageReport(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.wastageReport, data);
  }

  Future<Response?> getDailyConsumptionReport(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.dailyConsumptionReport, data);
  }

  Future<Response?> exportConsumptionExcel(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.exportConsumptionExcel, data);
  }

  Future<Response?> deleteIngredient(int id) async {
    return await apiClient.deleteData(AppConstants.deleteIngredient(id));
  }
}
