import 'package:get/get_connect/http/src/response/response.dart';

import '../../util/app_constants.dart';
import '../api/api_client.dart';

class SwiggyRepo {
  final ApiClient apiClient;
  SwiggyRepo({required this.apiClient});

  Future<Response> getOrderList() async {
    return await apiClient.getData(AppConstants.SWIGGY_ZOMATO_ORDER_LIST_URI);
  }

  Future<Response> getStoreStatus() async {
    return await apiClient.getData(AppConstants.GET_SWIGGY_STORE_STATUS_URI);
  }

  Future<Response> changeOrderStatus(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.SWIGGY_CHANGE_ORDER_STATUS, body);
  }

  Future<Response> changeAggregatorStoreStatus(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.CHANGE_AGGREGATOR_STATUS_URI, body);
  }

  Future<Response> getOrderDetailFromSocket(String orderId) async {
    return await apiClient.postData(
        AppConstants.DETAIL_FROM_SOCKET_SWIGGY_URI, {'order_id': orderId});
  }

  Future<Response> getOrderByDate(String date) async {
    return date == ''
        ? await apiClient
            .postData(AppConstants.COMPLETED_SWIGGY_ORDER_BY_DATE_URI, {})
        : await apiClient.postData(
            '${AppConstants.COMPLETED_SWIGGY_ORDER_BY_DATE_URI}',
            {'search_date': '$date'});
  }

  Future<Response> exportAggrOrderReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.EXPORT_AGGR_ORDER_REPORT_URI, data);
  }
}
