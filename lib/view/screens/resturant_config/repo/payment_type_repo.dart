import 'package:get/get_connect/http/src/response/response.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class PaymentTypeRepo {
  final ApiClient apiClient;

  PaymentTypeRepo({required this.apiClient});

  Future<Response> getPaymentTypes() async {
    return await apiClient.getData(AppConstants.Payment_Types);
  }

  Future<Response> updatePaymentTypes(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.Payment_Types, body);
  }
}
