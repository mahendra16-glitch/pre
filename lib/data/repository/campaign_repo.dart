import 'package:mygenie_restaurant/data/api/api_client.dart';

class CampaignRepo {
  final ApiClient apiClient;
  CampaignRepo({required this.apiClient});

  // Future<Response> getCampaignList() async {
  //   return await apiClient.getData(AppConstants.BASIC_CAMPAIGN_URI);
  // }

  // Future<Response> joinCampaign(int campaignID) async {
  //   return await apiClient.putData(AppConstants.JOIN_CAMPAIGN_URI, {'campaign_id': campaignID});
  // }

  // Future<Response> leaveCampaign(int campaignID) async {
  //   return await apiClient.putData(AppConstants.LEAVE_CAMPAIGN_URI, {'campaign_id': campaignID});
  // }
}
