import 'package:mygenie_restaurant/data/api/api_client.dart';

class BankRepo {
  final ApiClient apiClient;
  BankRepo({required this.apiClient});

  // Future<Response> updateBankInfo(BankInfoBody bankInfoBody) async {
  //   return await apiClient.putData(
  //       AppConstants.UPDATE_BANK_INFO_URI, bankInfoBody.toJson());
  // }

  // Future<Response> getWithdrawList() async {
  //   return await apiClient.getData(AppConstants.WITHDRAW_LIST_URI);
  // }

  // Future<Response> requestWithdraw(String amount) async {
  //   return await apiClient
  //       .postData(AppConstants.WITHDRAW_REQUEST_URI, {'amount': amount});
  // }
}
