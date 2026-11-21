import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class TabManagementRepo {
  final ApiClient apiClient;
  TabManagementRepo({required this.apiClient});

  Future<Response> getTapManageMentCustomerList(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.TAP_MANAGEMENT_CUSTOMER_LIST_URI}', body);
  }

  Future<Response> getViewTabBills(String customerId) async {
    return await apiClient
        .getData('${AppConstants.GET_VIEW_TAB_BILLS_URI}$customerId');
  }

  Future<Response> collectTapPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.COLLECT_TAP_PAYMENT_URI}', bodyData);
  }
}
