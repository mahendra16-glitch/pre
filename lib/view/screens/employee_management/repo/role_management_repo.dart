import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class RoleManagementRepo {
  final ApiClient apiClient;
  RoleManagementRepo({required this.apiClient});

  Future<Response> getRoleMnmgtList() async {
    return await apiClient.getData(AppConstants.Get_Role_Management_List);
  }

  Future<Response> getAllRole() async {
    return await apiClient.getData(AppConstants.Get_All_Role_Types_Modules);
  }

  Future<Response> getRoleMaster() async {
    return await apiClient.getData(AppConstants.Get_All_Master_Role);
  }

  Future<Response> addRoleMngmt(Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.Add_Role_Management_List, data);
  }

  Future<Response> updaRoleMngmt(int id, Map<String, dynamic> data) async {
    return await apiClient.putData(
        '${AppConstants.Update_Role_Management_List}$id', data);
  }

  Future<Response> updateStatus(int id, Map<String, dynamic> data) async {
    return await apiClient.putData(
        '${AppConstants.ROLE_STATUS_UPDATE}$id', data);
  }
}
