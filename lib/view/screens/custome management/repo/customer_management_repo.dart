import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

/// Repository class for customer management API calls
class CustomerManagementRepo {
  final ApiClient apiClient;

  CustomerManagementRepo({required this.apiClient});

  /// Fetch restaurant customer list report
  /// Returns list of customers with their details
  Future<Response> getRestaurantCustomerList() async {
    return await apiClient.postData(
      AppConstants.RESTAURANT_CUSTOMER_LIST_REPORT_URI,
      {},
    );
  }

  /// Export customer list to Excel
  /// Returns download URL for the exported Excel file
  Future<Response> exportCustomerListExcel() async {
    return await apiClient.postData(
      AppConstants.EXPORT_CUSTOMER_LIST_EXCEL_URI,
      {},
    );
  }

  Future<Response> getCustomerList(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.RESTAURANT_CUSTOMER_LIST_URI}', body);
  }

  Future<Response> updateCustomerDetail(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.UPDATE_CUSTOMER_DETAIL_URI}', body);
  }
  //====================== Customer Designations ======================//

  Future<Response?> getCustomerDesignationsList() async {
    return await apiClient.getData(AppConstants.customerDesignationsList);
  }

  Future<Response?> addCustomerDesignation(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.customerDesignationsAdd, data);
  }

  Future<Response?> toggleCustomerDesignationStatus(int id) async {
    return await apiClient
        .postData(AppConstants.customerDesignationsToggleStatus(id), {});
  }

  Future<Response?> deleteCustomerDesignation(int id) async {
    return await apiClient
        .deleteData(AppConstants.customerDesignationsDelete(id));
  }

  //====================== Customer Designations ======================//
}
