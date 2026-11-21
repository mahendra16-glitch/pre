import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class BuffetRepo {
  final ApiClient apiClient;
  BuffetRepo({required this.apiClient});

  Future<Response> orderList() async {
    return await apiClient.getData(AppConstants.BUFFET_WAITER_ORDER_LIST_URI +
        '?role_name=${Get.find<AuthController>().profileModel!.role!.contains('Manager') ? 'Manager' : 'Waiter'}');
  }

  Future<Response> serverOrderList() async {
    return await apiClient.getData(
        AppConstants.BUFFET_SERVER_ORDER_LIST_URI + '/?role_name=Buffet');
  }

  Future<Response> getCancelReasonList() async {
    return await apiClient.getData(AppConstants.GET_CANCEL_REASON_LIST_URI);
  }

  Future<Response> orderStatusUpdate(Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.OREDER_STATUS_UPDATE_URI, body);
  }

  Future<Response> foodOrderStatusUpdate(Map<String, dynamic> body) async {
    return await apiClient.putData(
        Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .restaurantType ==
                'Restaurant buffet'
            ? AppConstants.BUFFET_FOOD_OREDER_STATUS_UPDATE_URI
            : AppConstants.FOOD_OREDER_STATUS_UPDATE_URI,
        body);
  }

  Future<Response> foodOrderStatusUpdateDetail(
      Map<String, dynamic> body) async {
    return await apiClient.putData(
        AppConstants.BUFFET_FOOD_OREDER_DETAIL_STATUS_UPDATE_URI, body);
  }

  Future<Response> cancelFoodItem(Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.CANCEL_FOOD_ITEM, body);
  }
}
