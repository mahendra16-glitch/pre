import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class SettlementManagementRepo {
  final ApiClient apiClient;
  SettlementManagementRepo({required this.apiClient});

  Future<Response?> settlementRestaurantList(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.SETTLEMENT_RESTAURANT_LIST, body);
  }

  Future<Response?> waiterFullSettlement(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.WAITER_FULL_SETTLEMENT, body);
  }

  Future<Response?> waiterPartialSettlement(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.WAITER_PARTIAL_SETTLEMENT, body);
  }

  Future<Response?> addWaiterOpeningBalance(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.ADD_WAITER_OPENING_BALANCE, body);
  }

  Future<Response?> getWaiterList() async {
    return await apiClient.getData(AppConstants.GET_WAITER_LIST);
  }

  Future<Response?> waiterSelfSettlement(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.WAITER_SELF_SETTLEMENT, body);
  }

  Future<Response?> getSettlementClosingReport(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.SETTLEMENT_CLOSING_REPORT_URI, body);
  }

  Future<Response?> exportSettlementClosingReport(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.SETTLEMENT_CLOSING_REPORT_EXPORT_URI, body);
  }

  Future<Response?> getSettlementClosingReportNew(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.SETTLEMENT_CLOSING_REPORT_NEW_URI, body);
  }
}
