import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class EmployeeManagementRepo {
  final ApiClient apiClient;

  EmployeeManagementRepo({required this.apiClient});

  Future<Response> getEmployeeMngmtList() async {
    return await apiClient.getData(AppConstants.Get_Employee_Management_List);
  }

  Future<Response> getRoleList() async {
    return await apiClient.getData(AppConstants.Get_Role_Management_List);
  }

  Future<Response> getMenuMasterLists() async {
    return await apiClient.getData(AppConstants.menuMasterLists);
  }

  Future<Response> getProductList() async {
    return await apiClient.getData(
        '${AppConstants.WAITER_PRODUCT_LIST_URI}?offset=1&limit=5000&type=all');
  }

  Future<Response> addEmployeeMnmgtList(Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.Add_Employee_Management_List, data);
  }

  Future<Response> updateEmployeeMngmtList(
      int? id, Map<String, dynamic>? data) async {
    return await apiClient.putData(
        '${AppConstants.Update_Employee_Management_List}$id', data);
  }

  Future<Response> deleteEmployeeMngmtList(int? id) async {
    return await apiClient
        .deleteData('${AppConstants.Delete_Employee_Management_List}$id');
  }

  Future<Response> updateEmployeeStatus(
      int? id, Map<String, dynamic> data) async {
    return await apiClient.postData(
        '${AppConstants.Update_employee_status}$id', data);
  }
}
