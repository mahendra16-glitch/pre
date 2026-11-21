import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class EditWalkInOrderRepo {
  final ApiClient apiClient;
  EditWalkInOrderRepo({required this.apiClient});

  Future<Response> waiterUpdateWalkInOrder(
      Map<String, dynamic> bodyData) async {
    return await apiClient.putData(
        '${AppConstants.WALK_IN_EDIT_ORDER_URI}', bodyData);
  }
}
