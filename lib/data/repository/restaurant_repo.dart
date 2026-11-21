import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  RestaurantRepo({required this.apiClient});

  // Future<Response> getProductList(String offset, String type) async {
  //   return await apiClient.getData(
  //       '${AppConstants.PRODUCT_LIST_URI}?offset=$offset&limit=150&type=$type');
  // }

  Future<Response> getWaiterProductList(String offset, String type) async {
    return await apiClient.getData(
        '${AppConstants.WAITER_PRODUCT_LIST_URI}?offset=$offset&limit=5000&type=$type');
  }

  Future<Response> getBillingProductList(String offset, String type) async {
    return await apiClient.getData(
        '${AppConstants.BILLING_PRODUCT_LIST_URI}?offset=$offset&limit=100&type=$type');
  }

  Future<Response> getPopularFoodList() async {
    return await apiClient.getData('${AppConstants.POPULAR_FOOD_LIST_URI}');
  }

  Future<Response> addProduct(Map<String, dynamic> jsonData) async {
    return await apiClient.postData(
        '${AppConstants.ADD_PRODUCT_URI}', jsonData);
  }

  // Future<Response> getWaiterCategoryWithProductList(
  //     String offset, String type, int categoryId) async {
  //   return await apiClient.getData(
  //       '${AppConstants.WAITER_PRODUCT_LIST_URI}?category_id=$categoryId&offset=$offset&limit=5000&type=$type');
  // }

  // Future<Response> waiterSearchProductList(String searchText) async {
  //   return await apiClient.postData(
  //       AppConstants.WAITER_SEARCH_PRODUCT_LIST_URI, {'name': searchText});
  // }

  // Future<Response> searchProductList(String searchText) async {
  //   return await apiClient
  //       .postData(AppConstants.SEARCH_PRODUCT_LIST_URI, {'name': searchText});
  // }

  // Future<Response> getAttributeList() async {
  //   return apiClient.getData(AppConstants.ATTRIBUTE_URI);
  // }

  // Future<Response> getCategoryList() async {
  //   return await apiClient.postData(AppConstants.CATEGORY_URI, {});
  // }
  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.FOOD_CATEGORY_URI);
  }

  Future<Response> getPopularCategoryList() async {
    return await apiClient.postData(AppConstants.POPULAR_CATEGORY_URI, {});
  }

  // Future<Response> getSubCategoryList(int parentID) async {
  //   return await apiClient.getData('${AppConstants.SUB_CATEGORY_URI}$parentID');
  // }

  // Future<Response> getPosWithCategoryProductList(
  //     String offset, int categoryID, String type) async {
  //   return await apiClient.getData(
  //     '${AppConstants.PRODUCT_LIST_URI}?category_id=$categoryID&offset=$offset&limit=10&type=$type',
  //   );
  // }

  // Future<Response> updateRestaurant(Restaurant restaurant,
  //     List<String> cuisines, XFile logo, XFile cover, String token) async {
  //   Map<String, String> _fields = Map();
  //   _fields.addAll(<String, String>{
  //     '_method': 'put',
  //     'name': restaurant.name,
  //     'contact_number': restaurant.phone,
  //     'schedule_order': restaurant.scheduleOrder ? '1' : '0',
  //     'address': restaurant.address,
  //     'minimum_order': restaurant.minimumOrder.toString(),
  //     'delivery': restaurant.delivery ? '1' : '0',
  //     'take_away': restaurant.takeAway ? '1' : '0',
  //     // 'gst_status': restaurant.gstStatus ? '1' : '0',
  //     'gst': restaurant.gstCode,
  //     'veg': restaurant.veg.toString(),
  //     'non_veg': restaurant.nonVeg.toString(),
  //     'cuisine_ids': jsonEncode(cuisines),
  //   });
  //   if (restaurant.minimumShippingCharge != null &&
  //       restaurant.perKmShippingCharge != null &&
  //       restaurant.maximumShippingCharge != null) {
  //     _fields.addAll(<String, String>{
  //       'minimum_delivery_charge': restaurant.minimumShippingCharge.toString(),
  //       'maximum_delivery_charge': restaurant.maximumShippingCharge.toString(),
  //       'per_km_delivery_charge': restaurant.perKmShippingCharge.toString(),
  //     });
  //   }
  //   return apiClient.postMultipartData(
  //     AppConstants.RESTAURANT_UPDATE_URI,
  //     _fields,
  //     [
  //       MultipartBody('logo', logo, null),
  //       MultipartBody('cover_photo', cover, null)
  //     ],
  //   );
  // }

  // Future<Response> addProduct(
  //     Product product, XFile image, bool isAdd, String tags) async {
  //   Map<String, String> _fields = Map();
  //   _fields.addAll(<String, String>{
  //     'price': product.price.toString(),
  //     'discount': product.discount.toString(),
  //     'discount_type': product.discountType,
  //     'category_id': product.categoryIds[0].id.toString(),
  //     'available_time_starts': product.availableTimeStarts,
  //     'available_time_ends': product.availableTimeEnds,
  //     'veg': product.veg.toString(),
  //     'translations': jsonEncode(product.translations),
  //     'tags': tags,
  //     'options': jsonEncode(product.variations),
  //   });
  //   String _addon = '';
  //   for (int index = 0; index < product.addOns.length; index++) {
  //     _addon = _addon +
  //         '${index == 0 ? product.addOns[index].id : ',${product.addOns[index].id}'}';
  //   }
  //   _fields.addAll(<String, String>{'addon_ids': _addon});
  //   if (product.categoryIds.length > 1) {
  //     _fields.addAll(<String, String>{
  //       'sub_category_id': product.categoryIds[1].id.toString()
  //     });
  //   }
  //   if (!isAdd) {
  //     _fields.addAll(
  //         <String, String>{'_method': 'put', 'id': product.id.toString()});
  //   }
  //   return apiClient.postMultipartData(
  //     isAdd ? AppConstants.ADD_PRODUCT_URI : AppConstants.UPDATE_PRODUCT_URI,
  //     _fields,
  //     [MultipartBody('image', image, null)],
  //   );
  // }

  // Future<Response> deleteProduct(int productID) async {
  //   return await apiClient
  //       .deleteData('${AppConstants.DELETE_PRODUCT_URI}?id=$productID');
  // }

  // Future<Response> getRestaurantReviewList(int restaurantID) async {
  //   return await apiClient.getData(
  //       '${AppConstants.RESTAURANT_REVIEW_URI}?restaurant_id=$restaurantID');
  // }

  // Future<Response> getProductReviewList(int productID) async {
  //   return await apiClient
  //       .getData('${AppConstants.PRODUCT_REVIEW_URI}/$productID');
  // }

  // Future<Response> updateProductStatus(int productID, int status) async {
  //   return await apiClient.getData(
  //       '${AppConstants.UPDATE_PRODUCT_STATUS_URI}?id=$productID&status=$status');
  // }

  Future<Response> updateRecommendedProductStatus(
      int productID, int status) async {
    return await apiClient.getData(
        '${AppConstants.UPDATE_PRODUCT_RECOMMENDED_URI}?id=$productID&status=$status');
  }

  // Future<Response> addSchedule(Schedules schedule) async {
  //   return await apiClient.postData(
  //       AppConstants.ADD_SCHEDULE, schedule.toJson());
  // }

  // Future<Response> deleteSchedule(int scheduleID) async {
  //   return await apiClient
  //       .deleteData('${AppConstants.DELETE_SCHEDULE}$scheduleID');
  // }

  Future<Response> getCuisineList() async {
    return await apiClient.getData(AppConstants.CUISINE_URI);
  }
}
