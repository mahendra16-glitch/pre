import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TableRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  TableRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getTableList() async {
    return Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .settings!
                .autoPaid ==
            'Yes'
        ? await apiClient.postData('${AppConstants.BUFFET_TABLE_LIST_URI}', {})
        : await apiClient.getData('${AppConstants.ALL_TABLE_LIST_URI}');
  }

  Future<Response> changeTable(Map<String, dynamic> body) async {
    return await apiClient.postData('${AppConstants.CHANGE_TABLE_URI}', body);
  }

  Future<void> saveTableLocal(List<String> tableList) async {
    try {
      await sharedPreferences.setStringList(AppConstants.TABLELIST, tableList);
    } catch (e) {
      throw e;
    }
  }

  List<String> getTableListFromLocal() {
    return sharedPreferences.getStringList(AppConstants.TABLELIST) ?? [];
  }
}
