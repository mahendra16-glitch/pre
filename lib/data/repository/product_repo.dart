import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class ProductRepo {
  final ApiClient apiClient;
  ProductRepo({required this.apiClient});

  Future<Response> getWaiterProductList(String offset, String type) async {
    return await apiClient.getData(
        '${AppConstants.WAITER_PRODUCT_LIST_URI}?offset=$offset&limit=5000&type=$type');
  }

  Future<Response> getSingleProduct(String id) async {
    return await apiClient
        .getData('${AppConstants.GET_SINGLE_PRODUCT}?food_id=$id');
  }

  Future<Response> getBillingProductList(String offset, String type) async {
    return await apiClient.getData(
        '${AppConstants.BILLING_PRODUCT_LIST_URI}?offset=$offset&limit=5000&type=$type');
  }

  Future<Response> getPopularFoodList() async {
    return await apiClient.getData('${AppConstants.POPULAR_FOOD_LIST_URI}');
  }

  Future<Response> addProduct(Map<String, dynamic> jsonData) async {
    return await apiClient.postData(
        '${AppConstants.ADD_PRODUCT_URI}', jsonData);
  }

  Future<Response> getWaiterCategoryWithProductList(
      String offset, String type, int categoryId) async {
    return await apiClient.getData(
        '${AppConstants.WAITER_PRODUCT_LIST_URI}?category_id=$categoryId&offset=$offset&limit=5000&type=$type');
  }

  Future<Response> getCategoryList() async {
    return await apiClient.postData(AppConstants.CATEGORY_URI, {});
  }

  Future<Response> getPopularCategoryList() async {
    return await apiClient.postData(AppConstants.POPULAR_CATEGORY_URI, {});
  }
}
