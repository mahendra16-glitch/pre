import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/model/response/address_model.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class LocationRepo {
  final ApiClient apiClient;
  LocationRepo({required this.apiClient});

  Future<Response> getAllAddress(String phoneNumber, String dialCode) {
    return apiClient.postData(
      AppConstants.GET_ADDRESS_LIST_URI,
      {'custmer_mobile': phoneNumber, 'dial_code': dialCode},
    );
  }

  Future<Response> crmAddressLookup(String phone) async {
    debugPrint('====> [Repo][CRM AddressLookup] phone: $phone');
    return await apiClient.crmPostData(
      AppConstants.CRM_ADDRESS_LIST_URL,
      {'phone': phone},
    );
  }

  Future<Response> addressDetail(String placeId) {
    return apiClient.getData(
      '${AppConstants.GET_ADDRESS_DETAIL_URI}$placeId',
    );
  }

  Future<Response> getDeliveryCharges(String url) {
    return apiClient.getData(
      '${AppConstants.getDeliveryChargesUri}?$url',
    );
  }

  Future<Response> addAddress(AddressModel addressModel) {
    return apiClient.postData(
      AppConstants.ADD_ADDRESS_URI,
      addressModel.toJson(),
    );
  }

  Future<Response> addCrmAddress(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    debugPrint('====> [CRM AddAddress] customerId: $customerId body: $body');
    return await apiClient.crmPostData(
      '/api/pos/customers/$customerId/addresses',
      body,
    );
  }

  Future<Response> updateAddress(AddressModel addressModel) {
    return apiClient.postData(
      '${AppConstants.UPDATE_ADDRESS_URI}/${addressModel.id}',
      addressModel.toJson(),
    );
  }

  Future<Response> updateCrmAddress(
    String customerId,
    String addressId,
    Map<String, dynamic> body,
  ) async {
    debugPrint(
        '====>[CRM UpdateAddress] customerId: $customerId addressId: $addressId body: $body');
    return await apiClient.crmPutData(
      '/api/pos/customers/$customerId/addresses/$addressId',
      body,
    );
  }

  Future<Response> deleteAddress(int id) {
    return apiClient.deleteData(
      '${AppConstants.DELETE_ADDRESS_URI}/$id',
    );
  }

  Future<Response> deleteCrmAddress(String customerId, String addressId) async {
    debugPrint(
        '====>[CRM DeleteAddress] customerId: $customerId addressId: $addressId');
    return await apiClient.crmDeleteData(
      '/api/pos/customers/$customerId/addresses/$addressId',
    );
  }

  Future<Response> searchLocation(String text) {
    return apiClient.getData(
      '${AppConstants.SEARCH_LOCATION_URI}?search_text=$text',
    );
  }
}
