import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class DeliveryManagementRepo {
  final ApiClient apiClient;

  DeliveryManagementRepo({required this.apiClient});

  // .................. Get Delivery Config ..................//
  Future<Response> getDeliveryConfig() async {
    return await apiClient.getData(AppConstants.Get_Delivery_Config);
  }

  // .................. Update Delivery Config ..................//
  Future<Response> updateDeliveryConfig(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.Update_Delivery_Config, body);
  }

  // .................. Add Delivery Charge ..................//
  Future<Response> addDeliveryCharge(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.Add_Delivery_Charge, body);
  }

  // .................. Delete Delivery Charge ..................//
  Future<Response> deleteDeliveryCharge(int id) async {
    return await apiClient.deleteData('${AppConstants.Delete_Delivery_Charge}$id');
  }
}