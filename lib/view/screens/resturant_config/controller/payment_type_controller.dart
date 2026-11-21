import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/payment_type_repo.dart';

class PaymentTypeItem {
  final String code;
  final String displayName;
  bool enabled;

  PaymentTypeItem({
    required this.code,
    required this.displayName,
    required this.enabled,
  });
}

class PaymentTypeController extends GetxController implements GetxService {
  final PaymentTypeRepo paymentTypeRepo;
  PaymentTypeController({required this.paymentTypeRepo});

  bool isLoading = false;
  bool isSubmitting = false;

  List<PaymentTypeItem> paymentTypes = <PaymentTypeItem>[];
  bool razorpayEnabled = false;
  final GlobalKey<FormState> razorpayFormKey = GlobalKey<FormState>();
  final TextEditingController razorpayKeyController = TextEditingController();
  final TextEditingController razorpayTokenController = TextEditingController();

  Future<void> getPaymentTypes({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      update();
    }
    Response response = await paymentTypeRepo.getPaymentTypes();
    if (response.statusCode == 200 && response.body != null) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.body['data'] ?? {});
      final List<dynamic> types = data['payment_types'] is List
          ? data['payment_types'] as List
          : <dynamic>[];

      paymentTypes = types.map((item) {
        final Map<String, dynamic> type = Map<String, dynamic>.from(item);
        final String code = type['code']?.toString() ?? '';
        final String displayName = (type['display_name']?.toString() ?? '')
                .trim()
                .isNotEmpty
            ? type['display_name'].toString()
            : ((type['name']?.toString() ?? '').trim().isNotEmpty
                ? type['name'].toString()
                : code);
        return PaymentTypeItem(
          code: code,
          displayName: displayName,
          enabled: _asBool(type['enabled']),
        );
      }).toList();

      final Map<String, dynamic> razorpay = data['razorpay'] is Map
          ? Map<String, dynamic>.from(data['razorpay'])
          : <String, dynamic>{};
      razorpayEnabled = _asBool(razorpay['enabled']);
      razorpayKeyController.text = razorpay['razorpay_key']?.toString() ?? '';
      razorpayTokenController.text =
          razorpay['razorpay_token']?.toString() ?? '';
    } else {
      ApiChecker.checkApi(response);
      showMessage(
        'Error',
        response.body?['message']?.toString() ?? 'Something went wrong',
        isSuccess: false,
      );
    }
    isLoading = false;
    update();
  }

  void togglePaymentType(int index, bool value) {
    if (index < 0 || index >= paymentTypes.length) return;
    paymentTypes[index].enabled = value;
    update();
  }

  void toggleRazorpay(bool value) {
    razorpayEnabled = value;
    update();
  }

  Future<void> submit() async {
    if (isSubmitting) return;
    if (razorpayEnabled &&
        !(razorpayFormKey.currentState?.validate() ?? false)) {
      return;
    }
    isSubmitting = true;
    update();

    final Map<String, String> types = <String, String>{};
    for (final PaymentTypeItem type in paymentTypes) {
      if (type.code.trim().isEmpty) continue;
      types[type.code] = type.enabled ? 'Yes' : 'No';
    }

    final Map<String, dynamic> body = {
      'payment_types': types,
      'razorpay': {
        'enabled': razorpayEnabled ? 'Yes' : 'No',
        'razorpay_key': razorpayKeyController.text.trim(),
        'razorpay_token': razorpayTokenController.text.trim(),
      },
    };

    Response response = await paymentTypeRepo.updatePaymentTypes(body);
    if (response.statusCode == 200) {
      showMessage(
        'Success',
        response.body?['message']?.toString() ?? 'Updated successfully',
      );
      await getPaymentTypes(showLoader: false);
    } else {
      ApiChecker.checkApi(response);
      showMessage(
        'Error',
        response.body?['message']?.toString() ?? 'Something went wrong',
        isSuccess: false,
      );
    }
    isSubmitting = false;
    update();
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final String text = value?.toString().toLowerCase() ?? '';
    return text == 'yes' || text == 'true' || text == '1';
  }

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
