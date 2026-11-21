import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  CartRepo({required this.apiClient, required this.sharedPreferences});

  // Future<Response> searchProductList(String searchText) async {
  //   return await apiClient
  //       .postData(AppConstants.SEARCH_PRODUCT_LIST_URI, {'name': searchText});
  // }

  // Future<Response> searchCustomerList(String searchText) async {
  //   return await apiClient
  //       .getData('${AppConstants.SEARCH_CUSTOMERS_URI}?search=$searchText');
  // }

  Future<Response> searchWaiterCustomerList(String searchText) async {
    return await apiClient.getData(
        '${AppConstants.WAITER_SEARCH_CUSTOMERS_URI}?search=$searchText');
  }

  Future<Response> getTableList() async {
    return await apiClient.getData('${AppConstants.TABLE_LIST_URI}');
  }

  Future<Response> getBuffetTableList() async {
    return await apiClient
        .postData('${AppConstants.BUFFET_TABLE_LIST_URI}', {});
  }

  Future<Response> changeTable(Map<String, dynamic> body) async {
    return await apiClient.postData('${AppConstants.CHANGE_TABLE_URI}', body);
  }

  Future<Response> updateCustomerDetail(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.UPDATE_CUSTOMER_DETAIL_URI}', body);
  }

  Future<Response> crmCustomerLookup(String phone) async {
    debugPrint('====> [Repo][CRM Lookup] phone: $phone');
    return await apiClient.crmPostData(
      AppConstants.CRM_CUSTOMER_LOOKUP,
      {'phone': phone},
    );
  }

  Future<Response> addCrmCustomer(Map<String, dynamic> body) async {
    debugPrint('====> [Repo][CRM AddCustomer] body: $body');
    return await apiClient.crmPostData(
      AppConstants.CRM_ADD_CUSTOMER,
      body,
    );
  }

  Future<Response> editCrmCustomer(
      String customerId, Map<String, dynamic> body) async {
    debugPrint(
        '====> [Repo][CRM EditCustomer] customerId: $customerId body: $body');
    return await apiClient.crmPutData(
      '${AppConstants.CRM_EDIT_CUSTOMER}/$customerId',
      body,
    );
  }

  Future<Response> getCustomerList(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.RESTAURANT_CUSTOMER_LIST_URI}', body);
  }

  Future<Response> getCustomerListCrm(
      {String search = '', int limit = 10}) async {
    debugPrint('====> [Repo][CRM CustomerList] search: $search limit: $limit');
    return await apiClient.crmGetData(
      AppConstants.CRM_CUSTOMER_LIST_URI,
      query: {'search': search, 'limit': limit},
    );
  }

  Future<Response> getCrmCustomerDetail(String customerId) async {
    debugPrint('====> [Repo][CRM CustomerDetail] customerId: $customerId');
    return await apiClient.crmGetData(
      '${AppConstants.CRM_CUSTOMER_DETAIL_URI}$customerId',
    );
  }

  Future<Response> getCrmCustomerDocuments(String customerId) async {
    debugPrint('====> [Repo][CRM CustomerDocuments] customerId: $customerId');
    return await apiClient.crmGetData(
      '${AppConstants.CRM_CUSTOMER_DETAIL_URI}$customerId/documents',
    );
  }

  Future<Response> uploadCrmCustomerDocument({
    required String customerId,
    required String docType,
    required XFile file,
  }) async {
    debugPrint(
        '====> [Repo][CRM UploadDocument] customerId: $customerId docType: $docType');
    return await apiClient.crmPostMultipartData(
      '${AppConstants.CRM_CUSTOMER_DETAIL_URI}$customerId/documents',
      {'doc_type': docType},
      [MultipartBody('file', file, null)],
    );
  }

  Future<Response> getCustomerListFromMember() async {
    return await apiClient
        .getData('${AppConstants.CUSTOMER_LIST_FROM_MEMBER_ID_URI}');
  }

  Future<Response> getCollectBillDetail(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.GET_COLLECT_BILL_DETTAIL_URI}', body);
  }

  Future<Response> addMoneyWallet(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.ADD_MONEY_WALLET_URL}', body);
  }

  Future<Response> checkWalletBal(String userID) async {
    return await apiClient
        .getData('${AppConstants.CHECK_WALLET_BALANCE_URL}?user_id=$userID');
  }

  // Future<Response> placeOrder(Map<String, dynamic> bodyData) async {
  //   return await apiClient.postData(
  //       '${AppConstants.PLACE_ORDER_URI}', bodyData);
  // }

  Future<Response> collectPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.COLLECT_PAYMENT_URI}', bodyData);
  }

  Future<Response> collectTapPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.COLLECT_TAP_PAYMENT_URI}', bodyData);
  }

  Future<Response> waiterPlaceOrder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.postMultipartData(
        '${AppConstants.EMPLOYEE_PLACE_ORDER_URI}', bodyData, [
      MultipartBody(
          'audiofile', null, audioFile == null ? null : File(audioFile))
    ]);
  }

  Future<Response> buffetPlaceOrder(Map<String, String> bodyData) async {
    return await apiClient.postMultipartData(
        '${AppConstants.BUFFET_PLACE_ORDER_URI}',
        bodyData,
        [MultipartBody('audiofile', null, null)]);
  }

  Future<Response> waiterPlaceAndPayOrder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.postMultipartData(
        '${AppConstants.WAITER_PLACE_ORDER_NEW}', bodyData, [
      MultipartBody(
          'audiofile', null, audioFile == null ? null : File(audioFile))
    ]);
  }
  Future<Response> waiterEditOrder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.putData(
        '${AppConstants.WAITER_EDIT_ORDER_NEW}', bodyData);
  }

  Future<Response> waiterPlaceNewORder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.postMultipartData(
        '${AppConstants.PLACE_AND_PAY_ORDER_URI}', bodyData, [
      MultipartBody(
          'audiofile', null, audioFile == null ? null : File(audioFile))
    ]);
  }

  Future<Response> prepaidOrder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.postMultipartData(
        Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .settings!
                    .autoPaid ==
                'Yes'
            ? '${AppConstants.BUFFET_PREPAID_PLACE_ORDER_URI}'
            : '${AppConstants.PREPAID_ORDER_URI}',
        bodyData,
        [
          MultipartBody(
              'audiofile', null, audioFile == null ? null : File(audioFile))
        ]);
  }

  Future<Response> edcPrepaidOrder(
      Map<String, String> bodyData, String audioFile) async {
    return await apiClient.postMultipartData(
        '${AppConstants.EDC_PREPAID_ORDER_URI}', bodyData, [
      MultipartBody(
          'audiofile', null, audioFile == null ? null : File(audioFile))
    ]);
  }

  Future<Response> waiterUpdatePlaceOrder(Map<String, dynamic> bodyData) async {
    return await apiClient.putData(
        '${AppConstants.EMPLOYEE_UPDATE_PLACE_ORDER_URI}', bodyData);
  }

  Future<Response> billingSyncOrder(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.BILLING_SYNC_ORDER_URI}', bodyData);
  }

  // Future<Response> getPosOrders() async {
  //   return await apiClient.getData('${AppConstants.POS_ORDERS_URI}');
  // }

  Future<void> saveOrderList(List<String> orderList) async {
    try {
      await sharedPreferences.setStringList(AppConstants.ORDERLIST, orderList);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveLastOrderId(String orderId) async {
    try {
      await sharedPreferences.setString(AppConstants.LASTORDERID, orderId);
    } catch (e) {
      throw e;
    }
  }

  List<String> getOrderListFromLocal() {
    print(sharedPreferences.getStringList(AppConstants.ORDERLIST));
    return sharedPreferences.getStringList(AppConstants.ORDERLIST) ?? [];
  }

  String getLastOrderIdFromLocal() {
    return sharedPreferences.getString(AppConstants.LASTORDERID) ?? "";
  }

  Future<Response> whatsappBill(Map<String, dynamic> bodyData) async {
    return await apiClient.postData('${AppConstants.WHATSAPP_BILL}', bodyData);
  }

  Future<Response> sendPaymentLink(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.SEND_PAYMENT_LINK}', bodyData);
  }
}
