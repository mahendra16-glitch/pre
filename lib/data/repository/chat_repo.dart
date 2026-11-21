import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/helper/user_type.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ChatRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getConversationList(int offset) async {
    return await apiClient.getData(
        '${AppConstants.GET_CONVERSATION_LIST}?offset=$offset&limit=10');
  }

  Future<Response> searchConversationList(String name) async {
    return apiClient.getData(
        '${AppConstants.SEARCH_CONVERSATION_LIST_URI}?name=$name&limit=20&offset=1');
  }

  Future<Response> getMessages(
      int offset, int userId, UserType userType, int? conversationID) async {
    final idKey = conversationID != null
        ? 'conversation_id'
        : (userType == UserType.delivery_man ? 'delivery_man_id' : 'user_id');
    final idValue = conversationID ?? userId;
    return await apiClient.getData(
      '${AppConstants.GET_MESSAGE_LIST_URI}?offset=$offset&limit=10&$idKey=$idValue',
    );
  }

  Future<Response> sendMessage(
    String message,
    List<MultipartBody> images,
    int? conversationId,
    int userId,
    UserType userType,
  ) async {
    final receiverKey =
        conversationId != null ? 'conversation_id' : 'receiver_id';
    final receiverValue = conversationId ?? userId;
    return await apiClient.postMultipartData(
      AppConstants.SEND_MESSAGE_URI,
      {
        'message': message,
        'receiver_type': userType.name,
        receiverKey: '$receiverValue',
        'offset': '1',
        'limit': '10',
      },
      images,
    );
  }
}
