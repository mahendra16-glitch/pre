import 'package:get/get_connect/http/src/response/response.dart';

import '../../util/app_constants.dart';
import '../api/api_client.dart';

class TokenDisplayRepo {
  final ApiClient apiClient;
  TokenDisplayRepo({required this.apiClient});

  Future<Response> getOrderList() async {
    return await apiClient
        .getData(AppConstants.GET_TOKEN_DISPLAY_ORDER_LIST_URI);
  }

  Future<Response> getOrderDetailFromSocket(String orderId) async {
    return await apiClient.postData(
        AppConstants.GET_TOKEN_DISPLAY_ORDER_FROM_SCOKET_URI,
        {'order_id': orderId});
  }
}
