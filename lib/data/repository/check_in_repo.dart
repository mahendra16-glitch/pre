import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CheckInRepo {
  final ApiClient apiClient;
  CheckInRepo({required this.apiClient});

  Future<Response> checkIn(
      Map<String, String> data, List<MultipartBody> documentList) async {
    return apiClient.postMultipartData(
      AppConstants.CHECKIN_URI,
      data,
      documentList,
    );
  }
}
