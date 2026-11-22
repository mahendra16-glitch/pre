import 'dart:convert';
import 'dart:developer';

import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/body/business_plan_body.dart';
import 'package:mygenie_restaurant/data/model/response/address_model.dart';
import 'package:mygenie_restaurant/data/model/response/admin_restaurant_model.dart';
import 'package:mygenie_restaurant/data/model/response/category_model.dart';
import 'package:mygenie_restaurant/data/model/response/cuisine_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_employee_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/package_model.dart';
import 'package:mygenie_restaurant/data/model/response/prediction_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/response_model.dart';
import 'package:mygenie_restaurant/data/model/response/restaurant_login_model.dart';
import 'package:mygenie_restaurant/data/repository/auth_repo.dart';
import 'package:mygenie_restaurant/helper/bluetooth_auto_connect.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
    _notification = authRepo.isNotificationActive();
    // Load admin token on init
    _adminToken = authRepo.getAdminToken();
  }
  bool _isLoading = false;
  bool _notification = true;
  ProfileModel? _profileModel;
  GetEmployeeListResponse? _getEmployeeListResponse;
  List<RestaurantEmployeeList> _employeeList = [];
  RestaurantEmployeeList? _selectedEmployee;
  Map<int, bool> restaurantLoginLoading = {};
  XFile? _pickedFile;

  XFile? _pickedLogo;
  XFile? _pickedCover;
  // LatLng? _restaurantLocation;
  int _selectedZoneIndex = 0;
  // List<ZoneModel>? _zoneList;
  List<int>? _zoneIds;
  List<PredictionModel> _predictionList = [];

  // Position _pickPosition = Position(
  //     longitude: 0,
  //     latitude: 0,
  //     timestamp: DateTime.now(),
  //     accuracy: 1,
  //     altitude: 1,
  //     heading: 1,
  //     speed: 1,
  //     speedAccuracy: 1);
  String _pickAddress = '';
  bool _loading = false;
  bool _inZone = false;
  int _zoneID = 0;
  // int _businessIndex = Get.find<SplashController>().configModel.businessPlan !=
  //             null &&
  //         Get.find<SplashController>().configModel.businessPlan.commission == 0
  //     ? 1
  //     : 0;
  PackageModel? _packageModel;
  int _activeSubscriptionIndex = 0;
  String _businessPlanStatus = 'business';
  String loginType = 'Employee';
  List<String> options = ["Employee", "Owner"];

  int _paymentIndex = 0;
  String? _subscribedType;
  bool isFirstTime = true;
  bool _showSubscriptionAlertDialog = true;
  bool? _isActivePackage;
  String _renewStatus = 'packages';
  int _refundPaymentIndex = 0;
  String? _expiredToken;
  CuisineModel? _cuisineModel;
  List<int>? _cuisineIds;
  List<int> _selectedCuisines = [];
  // Admin session variables
  String? _adminToken;
  String? _adminEmail;
  AdminRestaurantModel? _adminRestaurantModel;
  bool _isLoadingRestaurants = false;

  bool get isLoading => _isLoading;
  bool get notification => _notification;
  ProfileModel? get profileModel => _profileModel;
  GetEmployeeListResponse? get getEmployeeListResponse =>
      _getEmployeeListResponse;
  RestaurantEmployeeList? get selectedEmployee => _selectedEmployee;
  XFile? get pickedFile => _pickedFile;

  XFile? get pickedLogo => _pickedLogo;
  XFile? get pickedCover => _pickedCover;
  // LatLng? get restaurantLocation => _restaurantLocation;
  int get selectedZoneIndex => _selectedZoneIndex;
  // List<ZoneModel>? get zoneList => _zoneList;
  List<int>? get zoneIds => _zoneIds;
  List<PredictionModel> get predictionList => _predictionList;
  String get pickAddress => _pickAddress;
  bool get loading => _loading;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  // int get businessIndex => _businessIndex;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;
  String get businessPlanStatus => _businessPlanStatus;
  int get paymentIndex => _paymentIndex;
  PackageModel? get packageModel => _packageModel;
  bool get showSubscriptionAlertDialog => _showSubscriptionAlertDialog;
  bool? get isActivePackage => _isActivePackage;
  String get renewStatus => _renewStatus;
  int get refundPaymentIndex => _refundPaymentIndex;
  CuisineModel? get cuisineModel => _cuisineModel;
  List<int>? get cuisineIds => _cuisineIds;
  List<RestaurantEmployeeList> get employeeList => _employeeList;
  List<int> get selectedCuisines => _selectedCuisines;
  String? get adminToken => _adminToken;
  AdminRestaurantModel? get adminRestaurantModel => _adminRestaurantModel;
  bool get isLoadingRestaurants => _isLoadingRestaurants;
  bool get isAdminSession => authRepo.isAdminSession();

  void initializeRenew() {
    _renewStatus = 'packages';
    _isActivePackage = true;
  }

  void setRefundPaymentIndex(int index) {
    _refundPaymentIndex = index;
    update();
  }

  void activePackage(bool status) {
    _isActivePackage = status;
    update();
  }

  void changeLoginType(String status) {
    loginType = status;
    update();
  }

  void renewChangePackage(String statusPackage) {
    _renewStatus = statusPackage;
    update();
  }

  void closeAlertDialog() {
    if (_showSubscriptionAlertDialog) {
      _showSubscriptionAlertDialog = !_showSubscriptionAlertDialog;
      update();
    }
  }

  void showAlert({bool isUpdate = false}) {
    _showSubscriptionAlertDialog = !_showSubscriptionAlertDialog;
    if (isUpdate) {
      update();
    }
  }

  void showBackPressedDialogue(String title) {
    Get.dialog(
        ConfirmationDialog(
          icon: Images.support,
          title: title,
          description: 'are_you_sure_to_go_back'.tr,
          isLogOut: true,
          onYesPressed: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
        ),
        useSafeArea: false);
  }

  // void resetBusiness() {
  //   _businessIndex = Get.find<SplashController>().configModel.businessPlan !=
  //               null &&
  //           Get.find<SplashController>().configModel.businessPlan.commission ==
  //               0
  //       ? 1
  //       : 0;
  //   _activeSubscriptionIndex = 0;
  //   _businessPlanStatus = 'business';
  //   isFirstTime = true;
  //   _paymentIndex =
  //       Get.find<SplashController>().configModel.freeTrialPeriodStatus == 0
  //           ? 1
  //           : 0;
  // }

  void setPaymentIndex(int index) {
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business) {
    _activeSubscriptionIndex = 0;
    // _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status) {
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index) {
    _activeSubscriptionIndex = index;
    update();
  }

  Future<void> getPackageList() async {
    Response response = await authRepo.getPackageList();
    if (response.statusCode == 200) {
      _packageModel = null;
      _packageModel = PackageModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCuisineList() async {
    _selectedCuisines.clear();
    final response = await authRepo.getCuisineList();
    if (response.statusCode == 200) {
      _cuisineIds = [0];
      _cuisineModel = CuisineModel.fromJson(response.body);
      for (var cuisine in _cuisineModel!.cuisines) {
        _cuisineIds!.add(cuisine.id);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setSelectedCuisineIndex(int index, bool notify) {
    if (!_selectedCuisines.contains(index)) {
      _selectedCuisines.add(index);
      if (notify) {
        update();
      }
    }
  }

  void removeCuisine(int index) {
    _selectedCuisines.removeAt(index);
    update();
  }

  // Future<void> submitBusinessPlan(int _restaurantId) async {
  //   String _businessPlan;
  //   if (businessIndex == 0) {
  //     _businessPlan = 'commission';
  //     if (_restaurantId != null) {
  //       setUpBusinessPlan(BusinessPlanBody(
  //           businessPlan: _businessPlan,
  //           restaurantId: _restaurantId.toString(),
  //           type: _subscribedType));
  //     } else {
  //       showCustomSnackBar('Restaurant id not provider');
  //     }
  //   } else {
  //     _businessPlanStatus = 'payment';
  //     if (!isFirstTime) {
  //       if (_businessPlanStatus == 'payment') {
  //         _businessPlan = 'subscription';
  //         int _packageId = _packageModel.packages[_activeSubscriptionIndex].id;
  //         String _payment = _paymentIndex == 0 ? 'free_trial' : 'paying_now';
  //         if (_restaurantId != null) {
  //           setUpBusinessPlan(BusinessPlanBody(
  //               businessPlan: _businessPlan,
  //               packageId: _packageId.toString(),
  //               restaurantId: _restaurantId.toString(),
  //               payment: _payment,
  //               type: _subscribedType));
  //         } else {
  //           showCustomSnackBar('Restaurant id not provider');
  //         }
  //       } else {
  //         showCustomSnackBar('please_select_any_process'.tr);
  //       }
  //     } else {
  //       isFirstTime = false;
  //     }
  //   }

  //   update();
  // }

  Future<ResponseModel> setUpBusinessPlan(
      BusinessPlanBody businessPlanBody) async {
    _isLoading = true;
    update();
    final response = await authRepo.setUpBusinessPlan(businessPlanBody);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      _businessPlanStatus = 'complete';
      showCustomSnackBar(response.body['message'], isError: false);
      responseModel = ResponseModel(true, response.body.toString());
      Future.delayed(const Duration(seconds: 2),
          () => Get.offAllNamed(RouteHelper.getSignInRoute()));
    } else {
      responseModel = ResponseModel(false, response.statusText ?? '');
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> renewBusinessPlan(String restaurantId) async {
    _isLoading = true;
    update();
    final _packageId = _packageModel?.packages[_activeSubscriptionIndex].id;
    final body = {
      'package_id': _packageId?.toString() ?? '',
      'restaurant_id': restaurantId,
      'type': _isActivePackage == true ? 'renew' : 'null',
      'payment_type': _refundPaymentIndex == 0 ? 'wallet' : 'pay_now',
      'payment_method': '',
    };
    Map<String, String>? _header;
    if (_expiredToken != null) {
      _header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_expiredToken'
      };
    }
    final response = await authRepo.renewBusinessPlan(body, _header!);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      _renewStatus = 'packages';
      await getProfile();
      Get.back();
      showCustomSnackBar(response.body['message'], isError: false);
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      ApiChecker.checkApi(response);
      responseModel = ResponseModel(false, response.statusText ?? '');
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<Response> logout() async {
    _isLoading = true;
    update();

    Response response = await authRepo.logout();
    // ResponseModel responseModel;
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      // await getProfile();
      // Get.back();
      // showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }

    return response;
  }

  Future<ResponseModel> employeeLogin(String deviceToken, String email,
      String password, BuildContext context) async {
    _isLoading = true;
    update();
    Response response =
        await authRepo.employeeLogin(deviceToken, email, password);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      String loginType = response.body['login_type'];

      if (loginType == 'admin') {
        // Admin login
        _adminToken = response.body['token'];
        _adminEmail = email;
        await authRepo.saveAdminToken(_adminToken!, email);

        responseModel = ResponseModel(true, 'admin_login');
      } else if (loginType == 'employee') {
        if (response.body['first_login'] == 'true') {
          responseModel = ResponseModel(true, 'First time login');

          String logo = '';
          if (response.body['permissions'].contains('KDS')) {
            logo = Images.ic_kds_app_logo;
          } else if (response.body['permissions'].contains('BAR')) {
            logo = Images.ic_bar_app_logo;
          } else if (!response.body['permissions'].contains('order') &&
              response.body['permissions'].contains('bill')) {
            logo = Images.ic_cashier_app_logo;
          } else if (response.body['permissions'].contains('report')) {
            logo = Images.ic_owner_app_logo;
          } else if (response.body['permissions'].contains('Manager')) {
            logo = Images.ic_manager_app_logo;
          } else {
            logo = Images.ic_waiter_app_logo;
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => EmployeeResetPassword(
                        resetToken: response.body['token'],
                        email: email,
                        image: logo,
                        password: password,
                        fromPasswordChange: false,
                      ))));
        } else {
          authRepo.saveUserToken(response.body['token'],
              response.body['zone_wise_topic'], response.body['crm_token']);
          await _ensureCrmToken(response.body['crm_token']?.toString());
          // authRepo.saveUserLoginRole(response.body['role_name']);
          // await authRepo.updateToken();
          if (!GetPlatform.isWindows &&
              response.body['firebase_token'] != deviceToken) {
            showErrorToast(
              "Your Device Token is not updated, Please relogin to update it.",
            );
          }
          // responseModel = ResponseModel(true, 'successful');
          responseModel = ResponseModel(true, 'employee_login');
        }
      } else {
        responseModel = ResponseModel(false, 'Invalid login type');
      }
      // }
    }
    // else if (response.statusCode == 426) {
    //   if (Get.find<SplashController>().configModel.businessPlan.subscription ==
    //       1) {
    //     _expiredToken = response.body['token'];
    //     _profileModel = ProfileModel(
    //       restaurants: [Restaurant(id: response.body['restaurant_id'])],
    //       balance: response.body['balance'] != null
    //           ? response.body['balance'].toDouble()
    //           : null,
    //       subscription: Subscription.fromJson(response.body['subscription']),
    //       subscriptionOtherData: SubscriptionOtherData.fromJson(
    //           response.body['subscription_other_data']),
    //     );
    //     Get.toNamed(RouteHelper.getSubscriptionViewRoute());
    //   } else {
    //     responseModel = ResponseModel(
    //         false, 'subscription_not_available_please_contact_with_admin'.tr);
    //   }
    // }
    else {
      responseModel = ResponseModel(false, response.statusText);
    }
    // _isLoading = false;
    // update();
    return responseModel;
  }

  /// If login did not provide a CRM token (null/empty), fetch and store it.
  /// Does not block login on failure.
  Future<void> _ensureCrmToken(String? loginCrmToken) async {
    final existing = loginCrmToken?.trim() ?? '';
    if (existing.isNotEmpty) return;
    await refreshCrmToken();
  }

  /// Always fetch CRM token from restaurant API and save if valid.
  /// Returns true when a non-empty token was saved.
  Future<bool> refreshCrmToken() async {
    try {
      final crmRes = await authRepo.getRestaurantCrmToken();
      final fetched =
          crmRes.body is Map ? crmRes.body['crm_token']?.toString() : null;
      if (crmRes.statusCode == 200 &&
          crmRes.body is Map &&
          crmRes.body['success'] == true &&
          (fetched?.trim().isNotEmpty ?? false)) {
        await authRepo.saveCrmToken(fetched!);
        debugPrint('====> CRM Token fetched and saved');
        return true;
      }
      debugPrint(
          '====> CRM Token fetch failed or empty: ${crmRes.statusCode} ${crmRes.body}');
      return false;
    } catch (e) {
      debugPrint('====> CRM Token fetch error: $e');
      return false;
    }
  }

  // Get assigned restaurants
  Future<bool> getAssignedRestaurants() async {
    if (_adminToken == null) return false;
    print('Admin Token: ${_adminToken}');
    _isLoadingRestaurants = true;
    update();

    Response response = await authRepo.getAssignedRestaurants(_adminToken!);

    if (response.statusCode == 200) {
      _adminRestaurantModel = AdminRestaurantModel.fromJson(response.body);
      _isLoadingRestaurants = false;
      update();
      return true;
    } else {
      _isLoadingRestaurants = false;
      update();
      ApiChecker.checkApi(response);
      return false;
    }
  }

  // Login as restaurant
  Future<ResponseModel> loginAsRestaurant(int restaurantId) async {
    if (_adminToken == null) {
      return ResponseModel(false, 'Admin token not found');
    }

    _isLoading = true;
    update();

    Response response =
        await authRepo.loginAsRestaurant(_adminToken!, restaurantId);

    if (response.statusCode == 200) {
      RestaurantLoginModel loginModel =
          RestaurantLoginModel.fromJson(response.body);

      // Save restaurant token
      await authRepo.saveUserToken(
        loginModel.restaurantToken,
        '', // Zone topic will be fetched from profile
        loginModel.crmToken,
      );
      await _ensureCrmToken(loginModel.crmToken);

      _isLoading = false;
      update();
      return ResponseModel(true, 'success');
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      _isLoading = false;
      ApiChecker.checkApi(response);
      update();
      return ResponseModel(false, response.statusText ?? 'Login failed');
    } else {
      _isLoading = false;
      update();
      return ResponseModel(false, response.statusText ?? 'Login failed');
    }
  }

  // Logout from restaurant (back to admin dashboard)
  Future<void> logoutFromRestaurant() async {
    BluetoothAutoConnect.instance.stop();
    await authRepo.clearRestaurantSession();
    await authRepo.clearSharedData();

    _profileModel = null;
    update();
  }

  // Complete admin logout
  Future<void> logoutFromAdmin() async {
    BluetoothAutoConnect.instance.stop();
    await authRepo.clearAdminSession();
    _adminToken = null;
    _adminEmail = null;
    _adminRestaurantModel = null;
    _profileModel = null;
    update();
  }

  void showLoader() {
    _isLoading = true;
    update();
  }

  void hideLoader() {
    _isLoading = false;
    update();
  }

  Future<Response> getProfile() async {
    // dynamic data = getUserLoginRole();
    Response response = await authRepo.getProfileInfo();
    if (response.statusCode == 200) {
      _profileModel = ProfileModel.fromJson(response.body);
      BluetoothAutoConnect.instance.start();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> getEmployeeList() async {
    Response response = await authRepo.getEmployeeList();
    if (response.statusCode == 200) {
      _getEmployeeListResponse =
          GetEmployeeListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  void getEmployeeListFromLocal(List<RestaurantEmployeeList> employeeList) {
    _employeeList = [];
    _employeeList.addAll(employeeList);
    update();
  }

  void setEmployeeIndex(RestaurantEmployeeList? employee) {
    _selectedEmployee = employee;
    update();
  }

  // Future<bool> updateUserInfo(
  //     ProfileModel updateUserModel, String token) async {
  //   _isLoading = true;
  //   update();
  //   http.StreamedResponse response =
  //       await authRepo.updateProfile(updateUserModel, _pickedFile, token);
  //   _isLoading = false;
  //   bool _isSuccess;
  //   if (response.statusCode == 200) {
  //     _profileModel = updateUserModel;
  //     showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
  //     _isSuccess = true;
  //   } else {
  //     ApiChecker.checkApi(Response(
  //         statusCode: response.statusCode,
  //         statusText: '${response.statusCode} ${response.reasonPhrase}'));
  //     _isSuccess = false;
  //   }
  //   update();
  //   return _isSuccess;
  // }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  void pickImageForReg(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    } else {
      if (isLogo) {
        _pickedLogo =
            await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        _pickedCover =
            await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      update();
    }
  }

  // Future<bool> changePassword(
  //     ProfileModel updatedUserModel, String password) async {
  //   _isLoading = true;
  //   update();
  //   bool _isSuccess;
  //   Response response =
  //       await authRepo.changePassword(updatedUserModel, password);
  //   _isLoading = false;
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     showCustomSnackBar('password_updated_successfully'.tr, isError: false);
  //     _isSuccess = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //     _isSuccess = false;
  //   }
  //   update();
  //   return _isSuccess;
  // }

  Future<ResponseModel> forgetPassword(String email, String countryCode) async {
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassword(email, countryCode);

    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  // Future<void> updateToken() async {
  //   await authRepo.updateToken();
  // }

  // Future<ResponseModel> verifyToken(String email) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await authRepo.verifyToken(email, _verificationCode);
  //   ResponseModel responseModel;
  //   if (response.statusCode == 200) {
  //     responseModel = ResponseModel(true, response.body["message"]);
  //   } else {
  //     responseModel = ResponseModel(false, response.statusText);
  //   }
  //   _isLoading = false;
  //   update();
  //   return responseModel;
  // }

  Future<ResponseModel> resetPassword(String resetToken, String email,
      String password, String confirmPassword) async {
    _isLoading = true;
    update();
    Response response = await authRepo.resetPassword(
        resetToken, email, password, confirmPassword);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> employeeresetPassword(String resetToken,
      String oldPassword, String password, String confirmPassword) async {
    _isLoading = true;
    update();
    Response response = await authRepo.employeeResetPassword(
        resetToken, oldPassword, password, confirmPassword);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  String _verificationCode = '';

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    update();
  }

  bool _isActiveRememberMe = true;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  // bool isLoggedIn() {
  //   return authRepo.isLoggedIn();
  // }

  /// Check if any user is logged in (admin or employee)
  bool isLoggedIn() {
    // Check if admin token exists

    if (authRepo.getAdminToken() != null) {
      print("Admin is logged in");
      return true;
    }

    // Check if employee token exists
    print("Employee is logged in: ${authRepo.isLoggedIn()}");
    return authRepo.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password) {
    authRepo.saveUserNumberAndPassword(number, password);
  }

  void saveUserLoginForBioMatric(String number, String password) {
    authRepo.saveUserLoginForBioMatric(number, password);
  }

  void saveUserRole(String number) {
    authRepo.saveUserLoginRole(number);
  }

  String getUserNumber() {
    return authRepo.getUserNumber() ?? "";
  }

  String getUserNumberBioMatric() {
    return authRepo.getUserNumberBioMatric() ?? "";
  }

  void saveProductList(String productList) {
    authRepo.saveProductList(productList);
  }

  void saveProductCategoryList(String categoryList) {
    authRepo.saveProductCategoryList(categoryList);
  }

  void saveProfileDetail(String profile) {
    authRepo.saveEmpleyeeProfile(profile);
  }

  void saveEmployeeList(String employeeList) {
    authRepo.saveEmpleyeeList(employeeList);
  }

  List<Product> getProductList() {
    var data = authRepo.getProductList() ?? '';
    List<Product> productList = [];

    if (data == '') {
      productList = [];
    } else {
      var tempJsonData = jsonDecode(data);
      for (var element in tempJsonData) {
        productList.add(Product.fromJson(element));
      }
    }
    return productList;
  }

  Future<void> syncProductFromSocket(
    Map<String, dynamic> socketData,
  ) async {
    final foodDetails = socketData['food_details'];

    if (foodDetails == null) return;

    final foodId = int.tryParse('${foodDetails['id']}') ?? 0;

    final products = getProductList();

    final index = products.indexWhere(
      (e) => e.id == foodId,
    );

    if (index != -1) {
      log('Updating existing product');

      products[index].applySocketUpdate(
        foodDetails,
      );
    } else {
      log('Adding new product');

      products.add(
        Product.fromSocketJson(
          foodDetails,
        ),
      );
    }

    final updatedProductsJson = products.map((e) => e.toJson()).toList();

    saveProductList(
      jsonEncode(updatedProductsJson),
    );

    Get.find<RestaurantController>().getProductListFromLocal(
      getProductList(),
    );

    log(
      'Product sync completed',
    );
  }

  Future<void> deleteProductFromSocket(
    Map<String, dynamic> socketData,
  ) async {
    final foodId = int.tryParse(
          '${socketData['food_id']}',
        ) ??
        0;

    final products = getProductList();

    final beforeCount = products.length;

    products.removeWhere(
      (product) => product.id == foodId,
    );

    final afterCount = products.length;

    if (beforeCount == afterCount) {
      log(
        'Delete ignored. Product not found: $foodId',
      );
      return;
    }

    final updatedProductsJson = products.map((e) => e.toJson()).toList();

    saveProductList(
      jsonEncode(updatedProductsJson),
    );

    Get.find<RestaurantController>().getProductListFromLocal(
      getProductList(),
    );

    log(
      'Product deleted successfully. Food ID: $foodId',
    );
  }

  Future<void> getProfileDataFromLocal() async {
    final String? data = authRepo.getProfileFromLocal();

    if (data == null || data.isEmpty) {
      _profileModel = null;
    } else {
      final Map<String, dynamic> tempJsonData = jsonDecode(data);
      _profileModel = ProfileModel.fromJson(tempJsonData);
      BluetoothAutoConnect.instance.start();
    }
  }

  List<RestaurantEmployeeList> convertEmployeeListFromLocal() {
    var data = authRepo.getEmployeeListFromLocal() ?? '';
    List<RestaurantEmployeeList> employees = [];

    if (data == '') {
      employees = [];
    } else {
      var tempJsonData = jsonDecode(data);
      for (var element in tempJsonData['Restaurant-employee-list']) {
        employees.add(RestaurantEmployeeList.fromJson(element));
      }
    }
    return employees;
  }

  List<CategoryModel> getProductCategoryList() {
    var data = authRepo.getProductCategoryList() ?? '';
    // print(data);
    List<CategoryModel> categoryList = [];
    if (data == '') {
      categoryList = [];
    } else {
      var tempJsonData = jsonDecode(data);
      for (var element in tempJsonData) {
        categoryList.add(CategoryModel.fromJson(element));
      }
    }
    return categoryList;
  }

  String getUserPassword() {
    return authRepo.getUserPassword() ?? "";
  }

  String getUserPasswordBioMatric() {
    return authRepo.getUserPasswordBioMatric() ?? "";
  }

  String getUserLoginRole() {
    return authRepo.getUserLoginRole() ?? "";
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  // bool setNotificationActive(bool isActive) {
  //   _notification = isActive;
  //   authRepo.setNotificationActive(isActive);
  //   update();
  //   return _notification;
  // }

  void initData() {
    _pickedFile = null;
  }

  // Future<void> toggleRestaurantClosedStatus() async {
  //   Response response = await authRepo.toggleRestaurantClosedStatus();
  //   if (response.statusCode == 200) {
  //     getProfile();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  // Future removeVendor() async {
  //   _isLoading = true;
  //   update();
  //   Response response = await authRepo.deleteVendor();
  //   _isLoading = false;
  //   if (response.statusCode == 200) {
  //     showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);
  //     Get.find<AuthController>().clearSharedData();
  //     Get.offAllNamed(RouteHelper.getSignInRoute());
  //   } else {
  //     Get.back();
  //     ApiChecker.checkApi(response);
  //   }
  // }

  // Future<void> getZoneList() async {
  //   _pickedLogo = null;
  //   _pickedCover = null;
  //   _selectedZoneIndex = 0;
  //   _restaurantLocation = null;
  //   _zoneIds = null;
  //   Response response = await authRepo.getZoneList();
  //   if (response.statusCode == 200) {
  //     _zoneList = [];
  //     response.body.forEach((zone) => _zoneList.add(ZoneModel.fromJson(zone)));
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  // Future<void> registerRestaurant(RestaurantBody restaurantBody) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await authRepo.registerRestaurant(
  //       restaurantBody, _pickedLogo, _pickedCover);
  //   if (response.statusCode == 200) {
  //     int _restaurantId = response.body['restaurant_id'];
  //     // Get.off(() => BusinessPlanScreen(restaurantId: _restaurantId));
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  // }

  void setZoneIndex(int index) {
    _selectedZoneIndex = index;
    update();
  }

  // void setLocation(LatLng location) async {
  //   ZoneResponseModel _response = await getZone(
  //     location.latitude.toString(),
  //     location.longitude.toString(),
  //     false,
  //   );
  //   if (_response != null &&
  //       _response.isSuccess &&
  //       _response.zoneIds.length > 0) {
  //     _restaurantLocation = location;
  //     _zoneIds = _response.zoneIds;
  //     for (int index = 0; index < _zoneList.length; index++) {
  //       if (_zoneIds.contains(_zoneList[index].id)) {
  //         _selectedZoneIndex = index;
  //         break;
  //       }
  //     }
  //   } else {
  //     _restaurantLocation = null;
  //     _zoneIds = null;
  //   }
  //   update();
  // }

  // Future<void> zoomToFit(GoogleMapController controller, List<LatLng> list,
  //     {double padding = 0.5}) async {
  //   LatLngBounds _bounds = _computeBounds(list);
  //   LatLng _centerBounds = LatLng(
  //     (_bounds.northeast.latitude + _bounds.southwest.latitude) / 2,
  //     (_bounds.northeast.longitude + _bounds.southwest.longitude) / 2,
  //   );

  //   if (controller != null) {
  //     controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: _centerBounds, zoom: GetPlatform.isWeb ? 10 : 16)));
  //   }

  //   bool keepZoomingOut = true;

  //   int _count = 0;
  //   while (keepZoomingOut) {
  //     _count++;
  //     final LatLngBounds screenBounds = await controller.getVisibleRegion();
  //     if (_fits(_bounds, screenBounds) || _count == 200) {
  //       keepZoomingOut = false;
  //       final double zoomLevel = await controller.getZoomLevel() - padding;
  //       controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: _centerBounds,
  //         zoom: zoomLevel,
  //       )));
  //       break;
  //     } else {
  //       // Zooming out by 0.1 zoom level per iteration
  //       final double zoomLevel = await controller.getZoomLevel() - 0.1;
  //       controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: _centerBounds,
  //         zoom: zoomLevel,
  //       )));
  //     }
  //   }
  // }

  // bool _fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
  //   final bool northEastLatitudeCheck =
  //       screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
  //   final bool northEastLongitudeCheck =
  //       screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

  //   final bool southWestLatitudeCheck =
  //       screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
  //   final bool southWestLongitudeCheck =
  //       screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

  //   return northEastLatitudeCheck &&
  //       northEastLongitudeCheck &&
  //       southWestLatitudeCheck &&
  //       southWestLongitudeCheck;
  // }

  // LatLngBounds _computeBounds(List<LatLng> list) {
  //   assert(list.isNotEmpty);
  //   var firstLatLng = list.first;
  //   var s = firstLatLng.latitude,
  //       n = firstLatLng.latitude,
  //       w = firstLatLng.longitude,
  //       e = firstLatLng.longitude;
  //   for (var i = 1; i < list.length; i++) {
  //     var latlng = list[i];
  //     s = min(s, latlng.latitude);
  //     n = max(n, latlng.latitude);
  //     w = min(w, latlng.longitude);
  //     e = max(e, latlng.longitude);
  //   }
  //   return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  // }

  Future<List<PredictionModel>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      Response response = await authRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) =>
            _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(
            response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  // Future<Position> setSuggestedLocation(
  //     String placeID, String address, GoogleMapController mapController) async {
  //   _isLoading = true;
  //   update();

  //   LatLng _latLng = LatLng(0, 0);
  //   Response response = await authRepo.getPlaceDetails(placeID);
  //   if (response.statusCode == 200) {
  //     PlaceDetailsModel _placeDetails =
  //         PlaceDetailsModel.fromJson(response.body);
  //     if (_placeDetails.status == 'OK') {
  //       _latLng = LatLng(_placeDetails.result.geometry.location.lat,
  //           _placeDetails.result.geometry.location.lng);
  //     }
  //   }

  //   _pickPosition = Position(
  //     latitude: _latLng.latitude,
  //     longitude: _latLng.longitude,
  //     timestamp: DateTime.now(),
  //     accuracy: 1,
  //     altitude: 1,
  //     heading: 1,
  //     speed: 1,
  //     speedAccuracy: 1,
  //   );

  //   _pickAddress = address;

  //   if (mapController != null) {
  //     mapController.animateCamera(CameraUpdate.newCameraPosition(
  //         CameraPosition(target: _latLng, zoom: 16)));
  //   }
  //   _isLoading = false;
  //   update();
  //   return _pickPosition;
  // }

  // Future<ZoneResponseModel> getZone(String lat, String long, bool markerLoad,
  //     {bool updateInAddress = false}) async {
  //   if (markerLoad) {
  //     _loading = true;
  //   } else {
  //     _isLoading = true;
  //   }
  //   print('problem start');
  //   if (!updateInAddress) {
  //     update();
  //   }
  //   ZoneResponseModel _responseModel;
  //   Response response = await authRepo.getZone(lat, long);
  //   if (response.statusCode == 200) {
  //     _inZone = true;
  //     _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
  //     List<int> _zoneIds = [];
  //     jsonDecode(response.body['zone_id']).forEach((zoneId) {
  //       _zoneIds.add(int.parse(zoneId.toString()));
  //     });
  //     List<ZoneData> _zoneData = [];
  //     response.body['zone_data']
  //         .forEach((zoneData) => _zoneData.add(ZoneData.fromJson(zoneData)));
  //     _responseModel = ZoneResponseModel(true, '', _zoneIds, _zoneData);
  //     if (updateInAddress) {
  //       print('here problem');
  //       AddressModel _address = getUserAddress();
  //       _address.zoneData = _zoneData;
  //       saveUserAddress(_address);
  //     }
  //   } else {
  //     _inZone = false;
  //     _responseModel = ZoneResponseModel(false, response.statusText, [], []);
  //   }
  //   if (markerLoad) {
  //     _loading = false;
  //   } else {
  //     _isLoading = false;
  //   }
  //   update();
  //   return _responseModel;
  // }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await authRepo.saveUserAddress(userAddress);
  }

  AddressModel? getUserAddress() {
    try {
      final String? data = authRepo.getUserAddress();
      if (data == null || data.isEmpty) return null;

      final Map<String, dynamic> json = jsonDecode(data);
      return AddressModel.fromJson(json);
    } catch (e) {
      // Optionally log the error
      return null;
    }
  }
}
