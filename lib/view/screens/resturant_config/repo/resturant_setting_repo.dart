import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class RestaurantSettingsRepo {
  final ApiClient apiClient;

  RestaurantSettingsRepo({required this.apiClient});

  Future<Response> getResturantSetting() async {
    return await apiClient.getData(AppConstants.Get_Resturant_setting);
  }

  Future<Response> updateResturantSetting(
      Map<String, String>? data, XFile? logo , XFile? pdf) async {
    return await apiClient.postRestaurantSetting(
        '${AppConstants.Update_Resturant_Setting}', data!, logo , pdf );
  }
}
