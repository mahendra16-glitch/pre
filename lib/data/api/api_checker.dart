import 'dart:async';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart';

class ApiChecker {
  static Future<void> checkApi(Response response) async {
    if (response.statusCode == 401) {
      if (Get.find<AuthController>().isAdminSession) {
        await Get.find<AuthController>().logoutFromRestaurant();
        Get.offAllNamed(RouteHelper.getAdminDashboardRoute());

        Get.snackbar('Ooops!', 'Someone logged in with this account',
            backgroundColor: ColorTheme.red,
            colorText: ColorTheme.white,
            snackPosition: SnackPosition.TOP);
      } else {
        await Get.find<AuthController>().clearSharedData();
        homeSocket?.clearListeners();
        homeSocket?.disconnect();
        homeSocket?.dispose();
        homeSocket = null;
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    } else if (response.statusCode == 403) {
      if (Get.find<AuthController>().isAdminSession) {
        await Get.find<AuthController>().clearSharedData();
        homeSocket?.clearListeners();
        homeSocket?.disconnect();
        homeSocket?.dispose();
        homeSocket = null;
        await Get.find<AuthController>().logoutFromAdmin();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
      // Get.offAllNamed(RouteHelper.getSignInRoute());
    } else {
      bool isSheetOpen = Get.isBottomSheetOpen ?? false;
      if (isSheetOpen) {
        await Get.find<LoadingController>()
            .changeText(data: response.statusText!, error: true);
        await Get.find<LoadingController>().changeStatus(data: true);
      } else {
        if (response.statusCode != 1) showErrorToast(response.statusText!);
      }
    }
  }

  // Generic Retry Function
  static Future<T> retry<T>(Future<T> Function() task,
      {int retries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        return await task();
      } on TimeoutException catch (_) {
        if (attempt >= retries) rethrow;
        attempt++;
        showErrorToast('Timeout! Retrying... ($attempt/$retries)');
      } catch (e) {
        if (attempt >= retries) rethrow;
        attempt++;
        showErrorToast('Error! Retrying... ($attempt/$retries)');
      }
      await Future.delayed(Duration(seconds: 2 * attempt)); // backoff
    }
  }
}
