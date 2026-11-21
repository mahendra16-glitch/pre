import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/model/response/delivery_man_model.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DeliveryManRepo {
  final ApiClient apiClient;
  DeliveryManRepo({required this.apiClient});

  Future<Response> getDeliveryManList() async {
    return await apiClient.postData(AppConstants.DELIVERY_BOY_LIST_URI, {});
  }

  Future<Response> assignDeliveryMan(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.ASSIGN_DELIVERY_MAN, body);
  }

  Future<Response> rejectDeliveryMan(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.REJECT_DELIVERY_MAN, body);
  }

  Future<Response> getOrderList() async {
    return await apiClient.postData(AppConstants.DELIVERY_ORDER_LIST_URI, {});
  }

  Future<Response> getOrderDetailFromSocket(String orderId) async {
    return await apiClient.postData(
        AppConstants.GET_ORDER_FROM_SCOKET_URI, {'order_id': orderId});
  }
  // Future<Response> getDeliveryManList() async {
  //   return await apiClient.getData(AppConstants.DM_LIST_URI);
  // }

  Future<Response> orderStatusUpdate(Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.OREDER_STATUS_UPDATE_URI, body);
  }

  // Future<Response> addDeliveryMan(
  //   DeliveryManModel deliveryMan,
  //   String pass,
  //   XFile? image,
  //   List<XFile>? identities,
  //   String token,
  //   bool isAdd,
  // ) async {
  //   final uri = Uri.parse(
  //     '${AppConstants.BASE_URL}${isAdd ? AppConstants.ADD_DM_URI : '${AppConstants.UPDATE_DM_URI}${deliveryMan.id}'}',
  //   );
  //   final request = http.MultipartRequest('POST', uri)
  //     ..headers['Authorization'] = 'Bearer $token';

  //   if (GetPlatform.isMobile && image != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'image',
  //         image.path,
  //       ),
  //     );
  //   }

  //   if (GetPlatform.isMobile && identities != null && identities.isNotEmpty) {
  //     for (final identity in identities) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'identity_image[]',
  //           identity.path,
  //         ),
  //       );
  //     }
  //   }

  //   final fields = <String, String>{
  //     'f_name': deliveryMan.fName!,
  //     'l_name': deliveryMan.lName!,
  //     'email': deliveryMan.email!,
  //     'password': pass,
  //     'phone': deliveryMan.phone!,
  //     'identity_type': deliveryMan.identityType!,
  //     'identity_number': deliveryMan.identityNumber!,
  //   };
  //   request.fields.addAll(fields);

  //   debugPrint('=====> ${request.url.path}\n${request.fields}');

  //   final streamedResponse = await request.send();
  //   final responseBody = await streamedResponse.stream.bytesToString();

  //   return Response(
  //     body: responseBody,
  //     statusCode: streamedResponse.statusCode,
  //     statusText: streamedResponse.reasonPhrase,
  //   );
  // }

  // Future<Response> updateDeliveryMan(DeliveryManModel deliveryManModel) async {
  //   return await apiClient.postData(
  //       '${AppConstants.UPDATE_DM_URI}${deliveryManModel.id}',
  //       deliveryManModel.toJson());
  // }

  // Future<Response> deleteDeliveryMan(int deliveryManID) async {
  //   return await apiClient.postData(AppConstants.DELETE_DM_URI,
  //       {'_method': 'delete', 'delivery_man_id': deliveryManID});
  // }

  // Future<Response> updateDeliveryManStatus(
  //     int deliveryManID, int status) async {
  //   return await apiClient.getData(
  //       '${AppConstants.UPDATE_DM_STATUS_URI}?delivery_man_id=$deliveryManID&status=$status');
  // }

  // Future<Response> getDeliveryManReviews(int deliveryManID) async {
  //   return await apiClient.getData(
  //       '${AppConstants.DM_REVIEW_URI}?delivery_man_id=$deliveryManID');
  // }
}
