import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class LoyaltyRepo {
  final ApiClient apiClient;

  LoyaltyRepo({required this.apiClient});

  //..................  Conversion Rate ..................//

  Future<Response> getConversionRateList() async {
    return await apiClient.getData(AppConstants.Get_Conversion_Rate_List);
  }

  Future<Response> addConversionRate({required String rate}) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Add_Conversion_Rate,
        {
          'rate': rate,
        },
        null);
  }

  Future<Response> updateConversionRate(
      {required String rate, required int id}) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Update_Conversion_Rate,
        {
          'rate': rate,
          'id': id.toString(),
        },
        null);
  }

  Future<Response> deleteConversionRate(int id) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Delete_Conversion_Rate,
        {
          'id': id.toString(),
        },
        null);
  }

  //.................. Redemption Rate ..................//

  Future<Response> getRedemptionRateList() async {
    return await apiClient.getData(AppConstants.Get_Redemption_Rate_List);
  }

  Future<Response> addRedemptionRate(
      {required String maxPercentage, required String maxAmount}) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Add_Redemption_Rate,
        {
          'max_percentage': maxPercentage,
          'max_amount': maxAmount,
        },
        null);
  }

  Future<Response> updateRedemptionRate(
      {required String maxPercentage,
      required String maxAmount,
      required int id}) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Update_Redemption_Rate,
        {
          'id': id.toString(),
          'max_percentage': maxPercentage,
          'max_amount': maxAmount,
        },
        null);
  }

  Future<Response> deleteRedemptionRate({required int id}) async {
    return await apiClient.postFoodInfoWithImage(
        AppConstants.Delete_Redemption_Rate,
        {
          'id': id.toString(),
        },
        null);
  }

  //.................. Coupon ..................//

  Future<Response> getCouponList() async {
    return await apiClient.getData(AppConstants.Get_Coupon_List);
  }

  Future<Response> addCoupon(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.Create_Coupon, data);
  }

  Future<Response> checkValidCoupon(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.checkValidCouponUri, data);
  }

  Future<Response> checkValidLoyaltyPoint(Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.checkValidLoyaltyPointUri, data);
  }

  Future<Response> redeemCoupon(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.redeemCouponUri, data);
  }

  Future<Response> crmMaxRedeemable(Map<String, dynamic> data) async {
    return await apiClient.crmPostData(AppConstants.CRM_MAX_REDEEMABLE, data);
  }

  Future<Response> crmCouponsAvailable({
    required String customerId,
    required double orderTotal,
    required String channel,
  }) async {
    return await apiClient.crmGetData(
      AppConstants.CRM_COUPONS_AVAILABLE,
      query: {
        'customer_id': customerId,
        'order_total': orderTotal,
        'channel': channel,
      },
    );
  }

  Future<Response> crmValidateCoupon(Map<String, dynamic> data) async {
    return await apiClient.crmPostData(AppConstants.CRM_COUPONS_VALIDATE, data);
  }

  Future<Response> updateCoupon(int id, Map<String, dynamic> data) async {
    return await apiClient.postData('${AppConstants.Update_Coupon}$id', data);
  }

  Future<Response> deleteCoupon(int id) async {
    return await apiClient.deleteData('${AppConstants.Delete_Coupon}$id');
  }

  Future<Response> getCustomerList(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.RESTAURANT_CUSTOMER_LIST_URI}', body);
  }

  //.................. Coupon Usage Report ..................//
  Future<Response> getCouponUsageReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.couponUsageReport, data);
  }

  Future<Response> exportCouponUsageReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.couponUsageReportExport, data);
  }
}
