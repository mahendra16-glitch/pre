// delivery_settings_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/delivery_management_repo.dart';

class DeliveryManagementController extends GetxController
    implements GetxService {
  final DeliveryManagementRepo deliveryManagementRepo;
  DeliveryManagementController({required this.deliveryManagementRepo});

  // Loading states
  bool isLoading = false;
  bool isAdding = false;

  // Basic settings controllers and variables
  bool deliveryFee = false;
  bool surcharge = false;
  bool validateAddressFromGoogle = false;
  bool showRealStatusToCustomer = false;
  bool deliveryAssign = false;
  TextEditingController zoneIdController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController deliveryPersonNameController = TextEditingController();
  TextEditingController deliveryContactNoController = TextEditingController();

  // Controllers for adding new delivery charge
  TextEditingController minDistanceController = TextEditingController();
  TextEditingController maxDistanceController = TextEditingController();
  TextEditingController minOrderValueController = TextEditingController();
  TextEditingController chargeController = TextEditingController();

  // Delivery charges list
  List<Map<String, dynamic>> deliveryCharges = <Map<String, dynamic>>[];

  // .................. Get Settings ..................//
  Future<void> getSettings() async {
    isLoading = true;
    update();
    Response response = await deliveryManagementRepo.getDeliveryConfig();
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.body['data'];
      final Map<String, dynamic> restaurant = data['restaurant'];

      // Set basic settings
      zoneIdController.text = restaurant['zone_id'].toString();
      latitudeController.text = restaurant['latitude'];
      longitudeController.text = restaurant['longitude'];
      deliveryFee = restaurant['delivery_fee'] == 'Yes';
      surcharge = restaurant['surcharge'] == 'Yes';
      validateAddressFromGoogle =
          restaurant['validate_address_from_google'] == 'Yes';
      deliveryPersonNameController.text =
          restaurant['delivery_person_name'] ?? '';
      deliveryContactNoController.text =
          restaurant['delivery_contact_no'] ?? '';
      showRealStatusToCustomer =
          restaurant['show_real_status_to_customer'] == 'Yes';
      deliveryAssign = restaurant['delivery_assign'] == 'Yes';

      // Set delivery charges
      deliveryCharges =
          List<Map<String, dynamic>>.from(data['delivery_charges']);
    } else {
      ApiChecker.checkApi(response);

      showMessage('Error', response.body['message'] ?? 'Something went wrong',
          isSuccess: false);
    }
    isLoading = false;
    update();
  }

  // .................. Update Basic Settings ..................//
  Future<void> updateBasicSettings() async {
    isLoading = true;
    update();
    Map<String, dynamic> body = {
      'zone_id': int.parse(zoneIdController.text.trim()),
      'latitude': latitudeController.text.trim(),
      'longitude': longitudeController.text.trim(),
      'delivery_fee': deliveryFee ? 'Yes' : 'No',
      'surcharge': surcharge ? 'Yes' : 'No',
      'validate_address_from_google': validateAddressFromGoogle ? 'Yes' : 'No',
      'delivery_person_name': deliveryPersonNameController.text.trim(),
      'delivery_contact_no': deliveryContactNoController.text.trim(),
      'show_real_status_to_customer': showRealStatusToCustomer ? 'Yes' : 'No',
      'delivery_assign': deliveryAssign ? 'Yes' : 'No',
    };
    Response response = await deliveryManagementRepo.updateDeliveryConfig(body);
    if (response.statusCode == 200) {
      await getSettings();
      showMessage(
          'Success', response.body['message'] ?? 'Updated successfully');
    } else {
      ApiChecker.checkApi(response);

      showMessage('Error', response.body['message'] ?? 'Something went wrong',
          isSuccess: false);
    }
    isLoading = false;
    update();
  }

  // .................. Add Delivery Charge ..................//
  Future<void> addDeliveryCharge() async {
    isAdding = true;
    update();
    Map<String, dynamic> body = {
      'min_distance_km': [minDistanceController.text.trim()],
      'max_distance_km': [maxDistanceController.text.trim()],
      'min_order_value': [minOrderValueController.text.trim()],
      'charge': [chargeController.text.trim()],
    };
    Response response = await deliveryManagementRepo.addDeliveryCharge(body);
    if (response.statusCode == 201) {
      clearDeliveryCharge();
      await getSettings();

      showMessage('Success', response.body['message'] ?? 'Added successfully');
    } else {
      ApiChecker.checkApi(response);

      showMessage('Error', response.body['errors'] ?? 'Something went wrong',
          isSuccess: false);
    }
    isAdding = false;
    update();
  }

  // .................. Delete Delivery Charge ..................//
  Future<void> deleteDeliveryCharge(int id) async {
    isLoading = true;
    update();
    Response response = await deliveryManagementRepo.deleteDeliveryCharge(id);
    if (response.statusCode == 200) {
      await getSettings();
      showMessage(
          'Success', response.body['message'] ?? 'Deleted successfully');
    } else {
      ApiChecker.checkApi(response);

      showMessage('Error', response.body['message'] ?? 'Something went wrong',
          isSuccess: false);
    }
    isLoading = false;
    update();
  }

  // Clear basic settings fields
  void clearBasicSettings() {
    zoneIdController.clear();
    latitudeController.clear();
    longitudeController.clear();
    deliveryFee = false;
    surcharge = false;
    validateAddressFromGoogle = false;
    deliveryPersonNameController.clear();
    deliveryContactNoController.clear();
    showRealStatusToCustomer = false;
    deliveryAssign = false;
    update();
  }

  // Clear delivery charge add fields
  void clearDeliveryCharge() {
    minDistanceController.clear();
    maxDistanceController.clear();
    minOrderValueController.clear();
    chargeController.clear();
    update();
  }

  // Helper to show toast/snackbar
  void showMessage(String title, String message, {bool isSuccess = true}) {
    if (Platform.isAndroid || Platform.isIOS) {
      appToast(isSuccess ? 'Update Successful' : 'Something Went Wrong');
    } else {
      Get.snackbar(
        title,
        message,
        backgroundColor: isSuccess ? ColorTheme.green : ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
  }
}
