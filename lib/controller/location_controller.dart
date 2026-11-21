import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/address_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_delivery_charge_response.dart';
import 'package:mygenie_restaurant/data/model/response/crm_address_lookup_response.dart';
import 'package:mygenie_restaurant/data/model/response/prediction_model.dart';
import 'package:mygenie_restaurant/data/model/response/response_model.dart';
import 'package:mygenie_restaurant/data/model/response/search_address_detail_model.dart';
import 'package:mygenie_restaurant/data/repository/location_repo.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({required this.locationRepo});
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  GetDeliveryChargesResponse? _getDeliveryChargesResponse;

  List<AddressModel> _addressList = [];
  List<AddressModel> get addressList => _addressList;
  GetDeliveryChargesResponse? get getDeliveryChargesResponse =>
      _getDeliveryChargesResponse;

  List<PredictionModel> _predictionList = [];
  CrmAddressLookupResponse? crmAddressLookupResponse;
  List<CrmAddress> crmAddressList = [];

  Future<void> getAddressList(String phoneNumber, {String? dialCode}) async {
    _addressList = [];
    Response response =
        await locationRepo.getAllAddress(phoneNumber, dialCode ?? '+91');
    if (response.statusCode == 200) {
      response.body['addresses'].forEach((address) {
        _addressList.add(AddressModel.fromJson(address));
      });
    } else if (response.statusText == 'No user register with this mobile no') {
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCrmAddressByPhone(String phone) async {
    try {
      final response = await locationRepo.crmAddressLookup(phone);

      if (response.statusCode == 200 && response.body['success'] == true) {
        crmAddressLookupResponse =
            CrmAddressLookupResponse.fromJson(response.body);
        crmAddressList = crmAddressLookupResponse?.data?.addresses ?? [];

        crmAddressList.sort((a, b) {
          final aDefault = a.isDefault == true ? 0 : 1;
          final bDefault = b.isDefault == true ? 0 : 1;
          return aDefault.compareTo(bDefault);
        });

        debugPrint('====> CRM Addresses found: ${crmAddressList.length}');
      } else if (response.statusCode == 401) {
        showErrorToast(
          response.body?['message']?.toString() ?? 'Something went wrong',
        );
      } else {
        crmAddressLookupResponse = null;
        crmAddressList = [];
        debugPrint('====> CRM Address Lookup failed or no addresses');
      }
    } catch (e) {
      crmAddressLookupResponse = null;
      crmAddressList = [];
      debugPrint('====> CRM Address Lookup Error: $e');
    }
    update();
  }

  Future<ResponseModel> addCrmAddress(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    debugPrint('[Controller][CRM AddAddress] customerId: $customerId');
    debugPrint('[Controller][CRM AddAddress] body: $body');

    try {
      final response = await locationRepo.addCrmAddress(customerId, body);

      debugPrint('[Controller][CRM AddAddress] status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseModel(true, response.body['message'] ?? 'Address added');
      } else {
        return ResponseModel(
            false, response.body['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      debugPrint('[Controller][CRM AddAddress] ERROR: $e');
      return ResponseModel(false, e.toString());
    }
  }

  Future<ResponseModel> updateCrmAddress(
    String customerId,
    String addressId,
    Map<String, dynamic> body,
  ) async {
    _isLoading = true;
    update();

    try {
      final response = await locationRepo.updateCrmAddress(
        customerId,
        addressId,
        body,
      );

      _isLoading = false;
      update();

      if (response.statusCode == 200) {
        return ResponseModel(
            true, response.body['message'] ?? 'Address updated');
      } else {
        return ResponseModel(
            false, response.body['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      debugPrint('[Controller][CRM UpdateAddress] CAUGHT: $e');
      _isLoading = false;
      update();
      return ResponseModel(false, e.toString());
    }
  }

  Future<ResponseModel> deleteCrmAddress(
      String customerId, String addressId, int index) async {
    _isLoading = true;
    update();

    Response response =
        await locationRepo.deleteCrmAddress(customerId, addressId);

    _isLoading = false;

    if (response.statusCode == 200) {
      crmAddressList.removeAt(index); // remove locally
      update();
      return ResponseModel(true, response.body['message'] ?? 'Deleted');
    } else {
      update();
      return ResponseModel(false, 'Failed to delete');
    }
  }

  Future<SearchAddressDetailModel?> getSearchAddressDetail(
      String placeId) async {
    SearchAddressDetailModel? placeDetail;
    Response response = await locationRepo.addressDetail(placeId);
    if (response.statusCode == 200) {
      placeDetail = SearchAddressDetailModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    return placeDetail;
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout,
      int restaurantZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (fromCheckout &&
          !response.body['zone_ids'].contains(restaurantZoneId)) {
        responseModel = ResponseModel(
            false, 'Your selected location is from different zone');
      } else {
        await getAddressList(Get.find<CartController>().selectedCustomer == null
            ? addressModel.contactPersonNumber!
            : Get.find<CartController>().selectedCustomer!.phone);

        // Get.find<OrderController>().setAddressIndex(0);
        String message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(
          false,
          response.statusText == 'Out of coverage!'
              ? 'service_not_available_in_this_area'.tr
              : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<void> getDeliveryCharges(
      {double? addLat, double? addLong, String? restId}) async {
    Response response = await locationRepo.getDeliveryCharges(
        'destination_lat=$addLat&destination_lng=$addLong&restaurant_id=$restId');
    if (response.statusCode == 200) {
      _getDeliveryChargesResponse =
          GetDeliveryChargesResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<ResponseModel> updateAddress(AddressModel addressModel,
      bool fromCheckout, int restaurantZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.updateAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (fromCheckout &&
          !response.body['zone_ids'].contains(restaurantZoneId)) {
        responseModel = ResponseModel(
            false, 'Your selected location is from different zone');
      } else {
        await getAddressList(Get.find<CartController>().selectedCustomer == null
            ? addressModel.contactPersonNumber!
            : Get.find<CartController>().selectedCustomer!.phone);

        // Get.find<OrderController>().setAddressIndex(0);
        String message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(
          false,
          response.statusText == 'Out of coverage!'
              ? 'service_not_available_in_this_area'.tr
              : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> deleteAddress(int id, int i) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.deleteAddress(id);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      // Get.find<OrderController>().setAddressIndex(0);
      String message = response.body["message"];

      responseModel = ResponseModel(true, message);
      _addressList.removeAt(i);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return responseModel;
  }

  clearAddressList() {
    _addressList = [];
    update();
  }

  Future<List<PredictionModel>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) =>
            _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        // showCustomSnackBar(
        //     response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }
}
