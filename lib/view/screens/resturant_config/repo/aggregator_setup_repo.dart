import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class AggregatorSetupRepo {
  final ApiClient apiClient;

  AggregatorSetupRepo({required this.apiClient});

  Future<Response> getRestaurantClients() async {
    return await apiClient.getData(AppConstants.restaurantClients);
  }

  Future<Response> getAggregatorConfig({int? clientId}) async {
    return await apiClient.getData(
      AppConstants.aggregatorConfig,
      query: clientId != null ? {'client_id': clientId} : null,
    );
  }

  Future<Response> toggleStorePlatform(Map<String, dynamic> body) async {
    return await apiClient.postData(
      AppConstants.aggregatorConfigStoreToggle,
      body,
    );
  }

  Future<Response> getRestaurantSettings() async {
    return await apiClient.getData(AppConstants.Get_Resturant_setting);
  }

  Future<Response> updateOperationalSettings(Map<String, String> data) async {
    return await apiClient.postRestaurantSetting(
      AppConstants.Update_Resturant_Setting,
      data,
      null,
      null,
    );
  }

  Future<Response> syncCatalog(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.aggregatorSyncCatalog, body);
  }

  Future<Response> forceSwiggyEnable(Map<String, dynamic> body) async {
    return await apiClient.postData(
      AppConstants.aggregatorForceSwiggyEnable,
      body,
    );
  }

  Future<Response> clearCatalog(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.aggregatorClearCatalog, body);
  }

  Future<Response> clearModifiers(Map<String, dynamic> body) async {
    return await apiClient.postData(
      AppConstants.aggregatorClearModifiers,
      body,
    );
  }

  Future<Response> getCategoryTimings({int? clientId}) async {
    return await apiClient.getData(
      AppConstants.aggregatorCategoryTimings,
      query: clientId != null ? {'client_id': clientId} : null,
    );
  }

  Future<Response> saveCategoryTimings(Map<String, dynamic> body) async {
    return await apiClient.postData(
      AppConstants.aggregatorCategoryTimings,
      body,
    );
  }

  Future<Response> pushCategoryTimings(Map<String, dynamic> body) async {
    return await apiClient.postData(
      AppConstants.aggregatorCategoryTimingsPush,
      body,
    );
  }

  Future<Response> getProductCategories() async {
    return await apiClient.getData(AppConstants.productCategories);
  }
}
