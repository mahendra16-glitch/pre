import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class MenuManagementRepo {
  final ApiClient apiClient;
  MenuManagementRepo({required this.apiClient});

  Future<Response?> getFoodList({required Map<String, dynamic> data}) async {
    print(
        "FULL API URL: ${Uri.parse(AppConstants.foodList).replace(queryParameters: data)}");
    return await apiClient.getData(AppConstants.foodList, query: data);
  }

  Future<Response?> getRestaurantClients() async {
    return await apiClient.getData(AppConstants.restaurantClients);
  }

  Future<Response?> updateFood(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData(AppConstants.editFood(id), data);
  }

  Future<Response?> deleteFood(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.deleteWData(AppConstants.deleteFood(id), body: data);
  }

  Future<Response?> getMenuMasterLists() async {
    return await apiClient.getData(AppConstants.menuMasterLists);
  }

  Future<Response?> getDeleteReasons() async {
    return await apiClient.getData(AppConstants.deleteReasons);
  }

  Future<Response?> addAddon(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addAddon, data);
  }

  Future<Response?> updateAddon(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.putData(AppConstants.updateAddon(id), data);
  }

  Future<Response?> deleteAddon(int id) async {
    return await apiClient.deleteData(AppConstants.deleteAddon(id));
  }

  Future<Response?> addonStatusChange(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.addonStatusChange(id), data);
  }

  Future<Response?> exportSample() async {
    return await apiClient.getData(AppConstants.exportSample);
  }

  Future<Response?> getMenuManagementCategories() async {
    return await apiClient.getData(AppConstants.getMenuManagementCategories);
  }

  Future<Response?> getStationList() async {
    return await apiClient.getData(AppConstants.stationList);
  }

  Future<Response?> getAllergens() async {
    return await apiClient.getData(AppConstants.allergensUri);
  }

  Future<Response?> AddCategories({required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.AddCategories, data);
  }

  Future<Response?> updateCategories(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.updateCategories(id), data);
  }

  // Add category with image (multipart)
  Future<Response> addCategoryWithImage({
    required Map<String, String> data,
    XFile? image,
  }) async {
    return await apiClient.postFoodInfoWithImage(
      AppConstants.AddCategories,
      data,
      image,
    );
  }

  // Update category with image (multipart)
  Future<Response> updateCategoryWithImage({
    required int id,
    required Map<String, String> data,
    XFile? image,
  }) async {
    return await apiClient.postFoodInfoWithImage(
      AppConstants.updateCategories(id),
      data,
      image,
    );
  }

  Future<Response?> deleteCategories(int id) async {
    return await apiClient.deleteData(AppConstants.deleteCategories(id));
  }

  Future<Response?> categoriesStatusChange(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(
        AppConstants.categoriesStatusChange(id), data);
  }

  Future<Response?> exportCategories() async {
    return await apiClient.getData(AppConstants.exportCategories);
  }

  Future<Response?> exportWithoutAddon() async {
    return await apiClient.getData(AppConstants.exportWithoutAddon);
  }

  Future<Response?> exportAddon() async {
    return await apiClient.getData(AppConstants.exportAddon);
  }

  Future<Response?> addFood(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addFood, data);
  }

  Future<Response?> addFoodAggregator(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.addFoodAggregator, data);
  }

  Future<Response?> statusFood(int id,
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.statusFood(id), data);
  }

  Future<Response?> aggregatorStockToggle(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.aggregatorStockToggle, data);
  }

  Future<Response?> productCategories() async {
    return await apiClient.getData(AppConstants.productCategories);
  }

  Future<Response?> foodsFor(Map<String, dynamic> data) async {
    return await apiClient.getData(AppConstants.foodsFor, query: data);
  }

  Future<Response?> getAllCategoryList() async {
    return await apiClient.getData(AppConstants.allCategoryList);
  }

  Future<Response?> getAddonList() async {
    return await apiClient.getData(AppConstants.addonList);
  }

  Future<Response> postFoodWithMuliPartDate(
      Map<String, String> data, XFile? image) async {
    return apiClient.postFoodInfoWithImage(AppConstants.addFood, data, image);
  }

  Future<Response> postFoodAggregatorWithMuliPartDate(
      Map<String, String> data, XFile? zomatoImage, XFile? swiggyImage) async {
    return apiClient.postAggrFoodInfoWithImage(
        AppConstants.addFoodAggregator, data, zomatoImage, swiggyImage);
  }

  Future<Response> updateFoodWithMultiPartData(
      int id, Map<String, String> data, XFile? image1, XFile? image2) async {
    return apiClient.updateFoodInfoWithImage(
        AppConstants.editFood(id), data, image1, image2);
  }

  Future<Response?> importAddon({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.importAddon,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> importCategories({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.importCategories,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> bulkImport({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.bulkImport,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> bulkExport({required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.bulkExport, data);
  }

  Future<Response?> getPrepServeTimeReport(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(AppConstants.prepServeTimeReport, data);
  }

  Future<Response?> exportPrepServeTimeReport(
      {required Map<String, dynamic> data}) async {
    return await apiClient.postData(
        AppConstants.prepServeTimeReportExport, data);
  }

  //====================== Cancellation Reasons ======================//

  Future<Response?> getCancellationReasonsList() async {
    return await apiClient.getData(AppConstants.cancellationReasonsList);
  }

  Future<Response?> addCancellationReason(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.cancellationReasonsAdd, data);
  }

  Future<Response?> updateCancellationReasonStatus(
      int id, Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.cancellationReasonsStatus(id), data);
  }

  Future<Response?> updateCancellationReason(
      int id, Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.cancellationReasonsUpdate(id), data);
  }

  Future<Response?> deleteCancellationReason(int id) async {
    return await apiClient
        .deleteData(AppConstants.cancellationReasonsDelete(id));
  }

  //====================== Cancellation Reasons ======================//
}
