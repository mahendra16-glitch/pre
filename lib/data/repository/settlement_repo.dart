import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class SettlementRepo {
  final ApiClient apiClient;
  SettlementRepo({required this.apiClient});

  Future<Response> getSettlement(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.SETTLEMENT_LIST_URI}', body);
  }

  Future<Response> getSettlementDetail(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.SETTLEMENT_DETAIL_URI}', body);
  }

  Future<Response> settlementAmount(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.SETTLEMENT_AMOUNT_URI}', body);
  }
}
