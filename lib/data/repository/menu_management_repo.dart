import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class MenuManagementRepo {
  final ApiClient apiClient;
  MenuManagementRepo({required this.apiClient});

  Future<Response> getMenuFoodList() async {
    return await apiClient.getData(AppConstants.GET_MENU_FOOD_LIST_URI);
  }

  Future<Response> addFoodList(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.ADD_MENU_FOOD_LIST_URI, body);
  }

  Future<Response> updateFoodList(int addonID, Map<String, dynamic> body) {
    return apiClient.putData(
        AppConstants.UPDATE_MENU_FOOD_LIST_URI + '$addonID', body);
  }

  Future<Response> deleteMenuFoodList(int foodID) {
    return apiClient
        .deleteData(AppConstants.DELETE_MENU_FOOD_LIST_URI + '$foodID');
  }

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.ALL_CATEGORY_URI);
  }

  Future<Response> getAddonList() async {
    return await apiClient.getData(AppConstants.ADDON_LIST_URI);
  }

  Future<Response> addAddonList(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.ADD_ADDON_LIST_URI, body);
  }

  Future<Response> updateAddon(int addonID, Map<String, dynamic> body) {
    return apiClient.putData(
        AppConstants.UPDATE_ADDON_LIST_URI + '$addonID', body);
  }

  Future<Response> deleteAddonList(int addonID) {
    return apiClient
        .deleteData(AppConstants.DELETE_ADDON_LIST_URI + '$addonID');
  }
}
