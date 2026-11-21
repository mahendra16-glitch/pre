import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class RevenueRepo {
  final ApiClient apiClient;
  RevenueRepo({required this.apiClient});

  Future<Response> getRevenueReport(Map<String, dynamic> body) async {
    return await apiClient.postData('${AppConstants.REVENUE_REPORT_URI}', body);
  }

  Future<Response> getPrintReport(Map<String, dynamic> body) async {
    return await apiClient.postData('${AppConstants.dailySalesReport}', body);
  }
}
