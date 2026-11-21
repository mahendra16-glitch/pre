import 'dart:async';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/model/body/business_plan_body.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});

  // Future<Response> login(
  //     String deviceToken, String email, String password) async {
  //   return await apiClient.postData(AppConstants.LOGIN_URI,
  //       {"fcm_token": deviceToken, "email": email, "password": password});
  // }

  // Save admin token (from admin login)
  Future<void> saveAdminToken(String token, String email) async {
    await sharedPreferences.setString(AppConstants.ADMIN_TOKEN, token);
    await sharedPreferences.setString(AppConstants.ADMIN_EMAIL, email);
    await sharedPreferences.setBool(AppConstants.IS_ADMIN_SESSION, true);
  }

  // Get admin token
  String? getAdminToken() =>
      sharedPreferences.getString(AppConstants.ADMIN_TOKEN);

  // Check if admin session
  bool isAdminSession() =>
      sharedPreferences.getBool(AppConstants.IS_ADMIN_SESSION) ?? false;

  // Save restaurant token (from admin dashboard login)
  Future<void> saveRestaurantToken(String token) async {
    await sharedPreferences.setString(AppConstants.RESTAURANT_TOKEN, token);
  }

  // Clear restaurant session (back to admin dashboard)
  Future<void> clearRestaurantSession() async {
    await sharedPreferences.remove(AppConstants.RESTAURANT_TOKEN);
    await sharedPreferences.remove(AppConstants.TOKEN);
    // await sharedPreferences.remove(AppConstants.ZONE_WISE_TOPIC);
  }

  // Clear admin session (complete logout)
  Future<void> clearAdminSession() async {
    await sharedPreferences.remove(AppConstants.ADMIN_TOKEN);
    await sharedPreferences.remove(AppConstants.ADMIN_EMAIL);
    await sharedPreferences.remove(AppConstants.IS_ADMIN_SESSION);
    await clearRestaurantSession();
  }

  // Check if admin session is active and valid
  bool isAdminSessionActive() {
    // Check if admin token exists in SharedPreferences
    String? adminToken = sharedPreferences.getString(AppConstants.ADMIN_TOKEN);
    bool isAdminSession =
        sharedPreferences.getBool(AppConstants.IS_ADMIN_SESSION) ?? false;

    // Both should exist for valid admin session
    return adminToken != null && isAdminSession;
  }

  /// Check if admin session exists (alias for compatibility)
  bool isAdminSessionValid() {
    return isAdminSessionActive();
  }

  // API: Get assigned restaurants
  Future<Response> getAssignedRestaurants(String adminToken) async {
    return await apiClient.getData(
      AppConstants.ASSIGNED_RESTAURANTS_URI,
      headers: {
        'Authorization': 'Bearer $adminToken',
        'Content-Type': 'application/json',
      },
    );
  }

  // API: Login as restaurant
  Future<Response> loginAsRestaurant(
      String adminToken, int restaurantId) async {
    return await apiClient.postData(
      AppConstants.LOGIN_AS_RESTAURANT_URI,
      {'restaurant_id': restaurantId},
      headers: {
        'Authorization': 'Bearer $adminToken',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Response> employeeLogin(
      String deviceToken, String email, String password) async {
    return await apiClient.postData(AppConstants.EMPLOYEE_LOGIN_URI,
        {"fcm_token": deviceToken, "email": email, "password": password});
  }

  Future<Response> getProfileInfo() async {
    return await apiClient.getData(AppConstants.WAITER_PROFILE_URI);
  }

  Future<Response> getEmployeeList() async {
    return await apiClient.postData(AppConstants.GET_EMPLOYEE_LIST_URI, {});
  }

  // Future<http.StreamedResponse> updateProfile(
  //     ProfileModel userInfoModel, XFile data, String token) async {
  //   http.MultipartRequest request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(
  //           '${AppConstants.BASE_URL}${AppConstants.UPDATE_PROFILE_URI}'));
  //   request.headers.addAll(<String, String>{'Authorization': 'Bearer $token'});
  //   if (GetPlatform.isMobile && data != null) {
  //     File _file = File(data.path);
  //     request.files.add(http.MultipartFile(
  //         'image', _file.readAsBytes().asStream(), _file.lengthSync(),
  //         filename: _file.path.split('/').last));
  //   } else if (GetPlatform.isWeb && data != null) {
  //     Uint8List _list = await data.readAsBytes();
  //     var part = http.MultipartFile(
  //         'image', data.readAsBytes().asStream(), _list.length,
  //         filename: basename(data.path),
  //         contentType: MediaType('image', 'jpg'));
  //     request.files.add(part);
  //   }
  //   Map<String, String> _fields = Map();
  //   _fields.addAll(<String, String>{
  //     '_method': 'put',
  //     'f_name': userInfoModel.fName,
  //     'l_name': userInfoModel.lName,
  //     'phone': userInfoModel.phone,
  //     'token': getUserToken()
  //   });
  //   request.fields.addAll(_fields);
  //   print(request.fields);
  //   http.StreamedResponse response = await request.send();
  //   return response;
  // }

  // Future<Response> changePassword(
  //     ProfileModel userInfoModel, String password) async {
  //   return await apiClient.postData(AppConstants.UPDATE_PROFILE_URI, {
  //     '_method': 'put',
  //     'f_name': userInfoModel.fName,
  //     'l_name': userInfoModel.lName,
  //     'phone': userInfoModel.phone,
  //     'password': password,
  //     'token': getUserToken()
  //   });
  // }

  // Future<Response> updateToken() async {
  //   String _deviceToken;
  //   if (GetPlatform.isIOS) {
  //     FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //         alert: true, badge: true, sound: true);
  //     NotificationSettings settings =
  //         await FirebaseMessaging.instance.requestPermission(
  //       alert: true,
  //       announcement: false,
  //       badge: true,
  //       carPlay: false,
  //       criticalAlert: false,
  //       provisional: false,
  //       sound: true,
  //     );
  //     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //       _deviceToken = await _saveDeviceToken();
  //     }
  //   } else {
  //     _deviceToken = await _saveDeviceToken();
  //   }
  //   if (!GetPlatform.isWeb) {
  //     FirebaseMessaging.instance.subscribeToTopic(AppConstants.TOPIC);
  //     FirebaseMessaging.instance.subscribeToTopic(
  //         sharedPreferences.getString(AppConstants.ZONE_TOPIC));
  //   }
  //   return await apiClient.postData(AppConstants.TOKEN_URI,
  //       {"_method": "put", "token": getUserToken(), "fcm_token": _deviceToken});
  // }

  // Future<String> _saveDeviceToken() async {
  //   String _deviceToken = '';
  //   if (!GetPlatform.isWeb) {
  //     _deviceToken = await FirebaseMessaging.instance.getToken();
  //   }
  //   if (_deviceToken != null) {
  //     print('--------Device Token---------- ' + _deviceToken);
  //   }
  //   return _deviceToken;
  // }

  Future<Response> forgetPassword(String email, String countryCode) async {
    return await apiClient.postData(AppConstants.FORGET_PASSWORD_URI,
        {"phone": email, "country_code": countryCode});
  }

  // Future<Response> verifyToken(String email, String token) async {
  //   return await apiClient.postData(
  //       AppConstants.VERIFY_TOKEN_URI, {"email": email, "reset_token": token});
  // }

  Future<Response> resetPassword(String resetToken, String email,
      String password, String confirmPassword) async {
    return await apiClient.postData(
      AppConstants.RESET_PASSWORD_URI,
      {
        "_method": "put",
        "email": email,
        "reset_token": resetToken,
        "password": password,
        "confirm_password": confirmPassword
      },
    );
  }

  Future<Response> employeeResetPassword(String resetToken, String oldPassword,
      String password, String confirmPassword) async {
    return await apiClient.putData(AppConstants.EMPLOYEE_RESET_PASSWORD_URI, {
      "old_password": oldPassword,
      "new_password": password,
      "confirm_password": confirmPassword
    }, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $resetToken'
    });
  }

  Future<bool> saveUserToken(String token, String zoneTopic,
      [String? crmToken]) async {
    apiClient.token = token;
    apiClient.updateHeader(
        token, sharedPreferences.getString(AppConstants.LANGUAGE_CODE));
    sharedPreferences.setString(AppConstants.ZONE_TOPIC, zoneTopic);
    if (crmToken != null && crmToken.trim().isNotEmpty) {
      await sharedPreferences.setString(AppConstants.CRM_TOKEN, crmToken.trim());
    } else {
      print('====> CRM Token is null or empty');
      print(
          '====> CRM Token: ${sharedPreferences.getString(AppConstants.CRM_TOKEN)}');
    }
    return await sharedPreferences.setString(AppConstants.TOKEN, token);
  }

  Future<void> saveCrmToken(String crmToken) async {
    final trimmed = crmToken.trim();
    if (trimmed.isEmpty) return;
    await sharedPreferences.setString(AppConstants.CRM_TOKEN, trimmed);
  }

  Future<Response> getRestaurantCrmToken() async {
    return await apiClient.getData(AppConstants.RESTAURANT_CRM_TOKEN_URI);
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.TOKEN) ?? "";
  }

  String? getCrmToken() {
    return sharedPreferences.getString(AppConstants.CRM_TOKEN);
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  Future<bool> clearSharedData() async {
    // if (!GetPlatform.isWeb) {
    //   apiClient.postData(AppConstants.TOKEN_URI,
    //       {"_method": "put", "token": getUserToken(), "fcm_token": '@'});
    //   FirebaseMessaging.instance.unsubscribeFromTopic(
    //       sharedPreferences.getString(AppConstants.ZONE_TOPIC));
    // }
    await sharedPreferences.remove(AppConstants.TOKEN);
    await sharedPreferences.remove(AppConstants.ROLE);
    await sharedPreferences.remove(AppConstants.USER_ADDRESS);
    await sharedPreferences.remove(AppConstants.PRODUCTLIST);
    await sharedPreferences.remove(AppConstants.CATEGORYLIST);
    await sharedPreferences.remove(AppConstants.LASTORDERID);
    await sharedPreferences.remove(AppConstants.EMPLOYEEPROFILE);
    await sharedPreferences.remove(AppConstants.CRM_TOKEN);
    // await sharedPreferences.clear();
    return true;
  }

  Future<void> saveUserNumberAndPassword(String number, String password) async {
    try {
      await sharedPreferences.setString(AppConstants.USER_PASSWORD, password);
      await sharedPreferences.setString(AppConstants.USER_NUMBER, number);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveUserLoginForBioMatric(String number, String password) async {
    try {
      await sharedPreferences.setString(
          AppConstants.USER_PASSWORD_BIOMATRIC, password);
      await sharedPreferences.setString(AppConstants.USER_EMAIL, number);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveUserLoginRole(String role) async {
    try {
      await sharedPreferences.setString(AppConstants.ROLE, role);
    } catch (e) {
      throw e;
    }
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.USER_NUMBER) ?? "";
  }

  String getUserNumberBioMatric() {
    return sharedPreferences.getString(AppConstants.USER_EMAIL) ?? "";
  }

  Future<void> saveProductList(String productList) async {
    try {
      await sharedPreferences.setString(AppConstants.PRODUCTLIST, productList);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveProductCategoryList(String categoryList) async {
    try {
      await sharedPreferences.setString(
          AppConstants.CATEGORYLIST, categoryList);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveEmpleyeeProfile(String profile) async {
    try {
      await sharedPreferences.setString(AppConstants.EMPLOYEEPROFILE, profile);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveEmpleyeeList(String profile) async {
    try {
      await sharedPreferences.setString(AppConstants.EMPLOYEELIST, profile);
    } catch (e) {
      throw e;
    }
  }

  String getProductList() {
    return sharedPreferences.getString(AppConstants.PRODUCTLIST) ?? "";
  }

  String getProfileFromLocal() {
    return sharedPreferences.getString(AppConstants.EMPLOYEEPROFILE) ?? "";
  }

  String getEmployeeListFromLocal() {
    return sharedPreferences.getString(AppConstants.EMPLOYEELIST) ?? "";
  }

  String getProductCategoryList() {
    return sharedPreferences.getString(AppConstants.CATEGORYLIST) ?? "";
  }

  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.USER_PASSWORD) ?? "";
  }

  String getUserPasswordBioMatric() {
    return sharedPreferences.getString(AppConstants.USER_PASSWORD_BIOMATRIC) ??
        "";
  }

  String getUserLoginRole() {
    return sharedPreferences.getString(AppConstants.ROLE) ?? "";
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.NOTIFICATION) ?? true;
  }

  // void setNotificationActive(bool isActive) {
  //   if (isActive) {
  //     updateToken();
  //   } else {
  //     if (!GetPlatform.isWeb) {
  //       FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
  //       FirebaseMessaging.instance.unsubscribeFromTopic(
  //           sharedPreferences.getString(AppConstants.ZONE_TOPIC));
  //     }
  //   }
  //   sharedPreferences.setBool(AppConstants.NOTIFICATION, isActive);
  // }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.USER_PASSWORD);
    return await sharedPreferences.remove(AppConstants.USER_NUMBER);
  }

  // Future<Response> toggleRestaurantClosedStatus() async {
  //   return await apiClient
  //       .postData(AppConstants.UPDATE_RESTAURANT_STATUS_URI, {});
  // }

  // Future<Response> deleteVendor() async {
  //   return await apiClient.deleteData(AppConstants.VENDOR_REMOVE);
  // }

  Future<Response> getZoneList() async {
    return await apiClient.getData(AppConstants.ZONE_LIST_URI);
  }

  Future<Response> searchLocation(String text) async {
    return await apiClient
        .getData('${AppConstants.SEARCH_LOCATION_URI}?search_text=$text');
  }

  Future<Response> getPlaceDetails(String placeID) async {
    return await apiClient
        .getData('${AppConstants.PLACE_DETAILS_URI}?placeid=$placeID');
  }

  Future<Response> getZone(String lat, String lng) async {
    return await apiClient
        .getData('${AppConstants.ZONE_URI}?lat=$lat&lng=$lng');
  }

  Future<bool> saveUserAddress(String address) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.TOKEN) ?? "",
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE),
    );
    return await sharedPreferences.setString(
        AppConstants.USER_ADDRESS, address);
  }

  String getUserAddress() {
    return sharedPreferences.getString(AppConstants.USER_ADDRESS) ?? "";
  }

  Future<Response> getPackageList() async {
    return await apiClient.getData(AppConstants.RESTAURANT_PACKAGES_URI);
  }

  Future<Response> setUpBusinessPlan(BusinessPlanBody businessPlanBody) async {
    return await apiClient.postData(
        AppConstants.BUSINESS_PLAN_URI, businessPlanBody.toJson());
  }

  Future<Response> logout() async {
    return await apiClient.postData(AppConstants.EMPLOYEE_LOGOUT_URI, {} );
  }

  Future<Response> renewBusinessPlan(
      Map<String, String> body, Map<String, String> headers) async {
    return await apiClient.postData(AppConstants.RENEW_BUSINESS_PLAN_URI, body,
        headers: headers);
  }

  Future<Response> getCuisineList() async {
    return await apiClient.getData(AppConstants.CUISINE_URI);
  }
}
