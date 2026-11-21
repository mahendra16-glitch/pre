import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/auth/widget/signin_text_field.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/beach_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upgrader/upgrader.dart';

import '../../../controller/product_controller.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? lastApiCall = '';
  String? lastEmail = '';
  String? lastPassword = '';

  String emailBioMatric = '';
  String passwordBioMatric = '';
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticated = false;
  bool isTapButton = false;
  String deviceToken = '';

  final RxString currentApiCall = ''.obs;
  final RxDouble progress = 0.0.obs;
  final RxInt totalSteps = 0.obs;
  final RxInt currentStep = 0.obs;
  // static const int BILLING_TOTAL_STEPS = 6;
  // static const int WAITER_TOTAL_STEPS = 6;

  @override
  void initState() {
    super.initState();
    logoHelper.logoUrlPrint = null;

    getPermission();
    // _checkBiometrics();
  }

  getPermission() async {
    if (!GetPlatform.isWindows)
      deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    if (await Permission.bluetoothConnect.status.isDenied) {
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
    } else if (await Permission.bluetoothConnect.status.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (await Permission.notification.status.isDenied) {
      await Permission.notification.request();
      // We haven't asked for permission yet or the permission has been denied before, but not permanently.
    } else if (await Permission.notification.status.isPermanentlyDenied) {
      openAppSettings();
    }

    if (await Permission.location.status.isDenied) {
      await Permission.location.request();
      await Permission.locationWhenInUse.request();

      await Permission.locationAlways.request();
    } else if (await Permission.location.status.isPermanentlyDenied) {
      openAppSettings();
    }
    // if (await Permission.locationWhenInUse.status.isDenied) {
    // await  Permission.locationWhenInUse.request();
    // } else if (await Permission.locationWhenInUse.status.isPermanentlyDenied) {
    //   openAppSettings();
    // }

    if (await Permission.microphone.status.isDenied) {
      await Permission.microphone.request();
    } else if (await Permission.microphone.status.isPermanentlyDenied) {
      openAppSettings();
    }

    if (await Permission.bluetoothConnect.status.isDenied) {
      Permission.bluetoothConnect.request();
    } else if (await Permission.bluetoothConnect.status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Future<void> _authenticate(AuthController authController) async {
  //   bool authenticated = false;
  //   try {
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'Scan your fingerprint or face to authenticate',
  //       options: const AuthenticationOptions(
  //           useErrorDialogs: true, stickyAuth: true, biometricOnly: true),
  //     );
  //   } catch (e) {
  //     print(e);
  //   }

  //   setState(() {
  //     _isAuthenticated = authenticated;
  //     if (_isAuthenticated) {
  //       _login(authController, isBioMatric: true);
  //     } else {
  //       showErrorToast('Failed to authenticate');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // print(MediaQuery.of(context).size.shortestSide);
    _emailController.text = Get.find<AuthController>().getUserNumber() ?? '';
    _passwordController.text =
        Get.find<AuthController>().getUserPassword() ?? '';
    emailBioMatric = Get.find<AuthController>().getUserNumberBioMatric() ?? '';
    passwordBioMatric =
        Get.find<AuthController>().getUserPasswordBioMatric() ?? '';

    return
        UpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: Duration(seconds: 1)),
          showReleaseNotes: true,
          showIgnore: false,
          showLater: false,
          child:
        Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: GetBuilder<AuthController>(builder: (authController) {
          return Column(children: [
            Padding(
              padding: EdgeInsets.only(top: Get.height * 0.08),
              child: Image.asset(Images.ic_login_brand_logo,
                  width: GetPlatform.isWindows
                      ? Get.width * 0.25
                      : Get.context!.width * 0.5),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 35, left: 16, right: 16),
              child: DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineThickness: 1.0,
                dashLength: 2.5,
                dashColor: ColorTheme.hintText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  SignInTextField(
                    hintText: 'User ID'.tr,
                    focusNode: _emailFocus,
                    controller: _emailController,
                    icon: Icons.email,
                    nextFocus: _passwordFocus,
                    inputType: TextInputType.emailAddress,
                    onChanged: (v) {
                      authController.update();
                    },
                  ),
                  if (isTapButton && _emailController.text.isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'enter_email_address'.tr,
                          style: poppinsRegular.copyWith(
                              color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ),
                  if (isTapButton &&
                      _emailController.text.isNotEmpty &&
                      !GetUtils.isEmail(_emailController.text))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'enter_a_valid_email_address'.tr,
                          style: poppinsRegular.copyWith(
                              color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  SignInTextField(
                    hintText: 'password'.tr,
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    onChanged: (v) {
                      authController.update();
                    },
                    // onSubmit: (text) =>
                    //     GetPlatform.isWeb ? _login(authController) : null,
                  ),
                  if (isTapButton && _passwordController.text.isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'enter_password'.tr,
                          style: poppinsRegular.copyWith(
                              color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ),
                  if (isTapButton &&
                      _passwordController.text.isNotEmpty &&
                      _passwordController.text.length < 6)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'password_should_be'.tr,
                          style: poppinsRegular.copyWith(
                              color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ),
                  SizedBox(height: 5),
                  Row(children: [
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          authController.toggleRememberMe();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 0,
                              child: Checkbox(
                                side: BorderSide(color: ColorTheme.appColor),
                                activeColor: ColorTheme.appColor,
                                value: authController.isActiveRememberMe,
                                onChanged: (bool? isChecked) =>
                                    authController.toggleRememberMe(),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'remember_me'.tr,
                              style: poppinsMedium.copyWith(
                                  fontSize: 10, color: ColorTheme.appColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Get.toNamed(RouteHelper.getForgotPassRoute()),
                      child: Text(
                        '${'forgot_password'.tr}?',
                        style: poppinsMedium.copyWith(
                            color: ColorTheme.appColor, fontSize: 10),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () => Get.toNamed(
                    //       RouteHelper.getEmployeeResetPasswordRoute(
                    //           '', '', '')),
                    //   child: Text(
                    //     '${'reset_password'.tr}?',
                    //     style: TextStyle(color: Color(0xFFF3BD47)),
                    //   ),
                    // ),
                  ]),
                  SizedBox(height: 50),
                  !authController.isLoading
                      ? Row(
                          mainAxisAlignment: GetPlatform.isWindows
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            if (!GetPlatform.isWindows)
                              InkWell(
                                  onTap: () async {
                                    await checkLocalInternet();
                                  },
                                  child: Icon(Icons.wifi,
                                      size: 34, color: ColorTheme.appColor)),
                            if (!GetPlatform.isWindows)
                              InkWell(
                                  onTap: () async {
                                    await isConnectedToInternet(
                                        'https://www.google.com', true);
                                  },
                                  child: Icon(Icons.public,
                                      size: 34, color: ColorTheme.appColor)),
                            InkWell(
                              onTap: () async {
                                // _login(authController, isBioMatric: false);
                                makeApiCalls(authController);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.15, vertical: 9),
                                decoration: BoxDecoration(
                                    color: ColorTheme.appColor,
                                    borderRadius: BorderRadius.circular(7)),
                                child: Text(
                                  'Login',
                                  style: poppinsMedium.copyWith(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                            if (!GetPlatform.isWindows)
                              InkWell(
                                  onTap: () async {
                                    await isConnectedToInternet(
                                        'https://preprod.mygenie.online/api/v1/categories', // live: https://manage.mygenie.online/api/v1/categories
                                        false);
                                  },
                                  child: SvgPicture.asset(
                                      Images.ic_app_logo_svg,
                                      height: 38)),
                          ],
                        )
                      // CustomButton(
                      //     buttonText: 'sign_in'.tr,
                      //     onPressed: () =>
                      //         _login(authController, isBioMatric: false),
                      //     radius: Dimensions.RADIUS_DEFAULT,
                      //   )
                      // : Center(child: CircularProgressIndicator()),
                      : buildLoadingIndicator(),
                  // SizedBox(
                  //     height: Get.find<SplashController>()
                  //             .configModel
                  //             .toggleRestaurantRegistration
                  //         ? Dimensions.PADDING_SIZE_EXTRA_SMALL
                  //         : 0),
                  // if (_isAuthenticated)
                  //   Text('Authenticated')
                  // else
                  //   Text('Not Authenticated'),
                  // SizedBox(height: 20),
                  // if (!authController.isLoading)
                  //   if (emailBioMatric != '')
                  //     if (_canCheckBiometrics)
                  //       ElevatedButton(
                  //         onPressed: () {
                  //           _authenticate(authController);
                  //         },
                  //         child: Text('Login with Biometrics'),
                  //       )
                  //     else
                  //       Text('Biometric authentication is not available'),
                ],
              ),
            ),
          ]);
        }),
      )),
      ),
    );
  }

  Future<void> makeApiCalls(AuthController authController) async {
    logoHelper.logoUrlPrint = null;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    isTapButton = true;
    authController.update();

    if (!_validateLogin(email, password)) return;
    if (lastApiCall == null || lastApiCall == '') {
      _updateProgress('Logging in...', 1, 6);

      final status = await authController.employeeLogin(
        deviceToken,
        email,
        password,
        context,
      );

      if (!status.isSuccess) {
        _resetProgressOnError(authController);
        showErrorToast(status.message);
        return;
      } else if (status.isSuccess && status.message == 'First time login') {
        _resetProgressOnError(authController);

        return;
      }

      Get.find<ProductController>().clearProductList();
      Get.find<SwiggyController>().clearOrderList();
      Get.find<KdsController>().clearOrderList();
      if (status.message == 'admin_login') {
//             // Admin login - navigate to admin dashboard
        bool success = await authController.getAssignedRestaurants();

        if (success) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(
                _emailController.text, _passwordController.text);
          } else {
            authController.clearUserNumberAndPassword();
          }
          Get.offNamed(RouteHelper.getAdminDashboardRoute());
        } else {
          showErrorToast('Failed to load restaurants');
        }
      } else if (status.message == 'employee_login') {
        await _handlePostLogin(authController, email, password);
      }
    } else if (lastApiCall == 'login') {
      Get.find<ProductController>().clearProductList();
      Get.find<SwiggyController>().clearOrderList();
      Get.find<KdsController>().clearOrderList();

      await _handlePostLogin(authController, email, password);
    } else if (lastApiCall == 'billing') {
      _handleBilling(authController, email, password);
    } else if (lastApiCall == 'waiter_profile') {
      _handleWaiter(authController, email, password);
    }
  }

  bool _validateLogin(String email, String password) {
    if (email.isEmpty) return false;
    if (!GetUtils.isEmail(email)) return false;
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }

  Future<void> _handlePostLogin(
      AuthController auth, String email, String password) async {
    try {
      _updateProgress('Fetching profile details...', 2, 6);
      lastApiCall = 'login';
      final profileResponse =
          await ApiChecker.retry(() => auth.getProfile(), retries: 2);
      // final int totalSteps =
      //     _isBillingUser(auth) ? BILLING_TOTAL_STEPS : WAITER_TOTAL_STEPS;

      if (profileResponse.statusCode != 200) {
        _resetProgressOnError(auth);
        showErrorToast('Failed to load profile');
        return;
      }

      final role = auth.profileModel!.role ?? [];

      if (role.contains('STATION')) {
        _handleStation(auth, email, password);
      } else if (role.contains('Delivery')) {
        _handleDelivery(auth, email, password);
      } else if (_isBillingUser(auth)) {
        await _handleBilling(auth, email, password);
      } else {
        await _handleWaiter(auth, email, password);
      }
    } catch (e) {
      _resetProgressOnError(auth);
      print('Login flow error : $e');
      showErrorToast('Login flow error : $e');
    }
  }

  bool _isBillingUser(AuthController auth) {
    return auth.profileModel!.role!.contains('Billing') ||
            auth.profileModel!.billingUserView == 'Yes'
        // ||
        // auth.profileModel!.restaurants!.first.isOrderPaymentType == 'prepaid'
        ;
  }

  void _saveCredentials(AuthController auth, String email, String password) {
    if (auth.isActiveRememberMe) {
      auth.saveUserNumberAndPassword(email, password);
    } else {
      auth.clearUserNumberAndPassword();
    }
    auth.saveUserLoginForBioMatric(email, password);
  }

  void _saveProfile(AuthController auth) {
    auth.saveProfileDetail(jsonEncode(auth.profileModel));
  }

  void _handleStation(AuthController auth, String email, String password) {
    logoHelper.appLogo = Images.ic_kds_app_logo;

    _saveCredentials(auth, email, password);
    _saveProfile(auth);

    _updateProgress('Complete!', 1, 1);
    auth.hideLoader();
    if (Get.find<AuthController>()
        .profileModel!
        .role!
        .contains('token_display')) {
      Get.offNamed(RouteHelper.gettokenDisplayHomeRoute());
    } else {
      Get.offNamed(RouteHelper.getKdsHomeRoute());
    }
  }

  void _handleDelivery(AuthController auth, String email, String password) {
    logoHelper.appLogo = Images.ic_manager_app_logo;

    _saveCredentials(auth, email, password);
    _saveProfile(auth);

    _updateProgress('Complete!', 1, 1);
    auth.hideLoader();
    Get.offNamed(RouteHelper.getDeliveryDashboardInitialRoute());
  }

  Future<void> _handleBilling(
      AuthController auth, String email, String password) async {
    logoHelper.appLogo = Images.ic_cashier_app_logo;
    lastApiCall = 'billing';
    _updateProgress('Loading food categories...', 3, 6);
    final loaded = await _loadFoodAndProduct(loginType: 'Billing');

    if (!loaded) {
      _resetProgressOnError(auth);
      showErrorToast('Failed to load billing data');
      return;
    }

    _updateProgress('Finalizing...', 6, 6);

    _saveCredentials(auth, email, password);
    _saveProfile(auth);

    _updateProgress('Complete!', 6, 6);
    auth.hideLoader();

    Get.offNamed(RouteHelper.getBillingDashboardInitialRoute());
  }

  Future<void> _handleWaiter(
      AuthController auth, String email, String password) async {
    logoHelper.appLogo = Images.ic_waiter_app_logo;

    if (auth.profileModel!.role!.contains('order') &&
        lastApiCall != 'product_load' &&
        lastApiCall != 'cancel_reason_load') {
      lastApiCall = 'waiter_profile';
      _updateProgress('Loading food categories...', 3, 6);
      final loaded = await _loadFoodAndProduct();
      lastApiCall = 'product_load';

      if (!loaded) {
        _resetProgressOnError(auth);
        showErrorToast('Failed to load waiter data');
        return;
      }
    }
    if (lastApiCall != 'cancel_reason_load') {
      _updateProgress('Loading cancel reasons...', 5, 6);
      final cancel = await ApiChecker.retry(
          () => Get.find<KdsController>().getCancelReason());
      lastApiCall = 'cancel_reason_load';
      if (cancel.statusCode != 200) {
        _resetProgressOnError(auth);
        showErrorToast('Cancel reason failed');
        return;
      }
    }

    _updateProgress('Loading table list...', 6, 6);
    final table = await ApiChecker.retry(
        () => Get.find<TableController>().saveTableListLocally());

    if (table.statusCode != 200) {
      _resetProgressOnError(auth);
      showErrorToast('Table load failed');
      return;
    }

    _saveCredentials(auth, email, password);
    _saveProfile(auth);

    _updateProgress('Complete!', 6, 6);
    auth.hideLoader();
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .restaurantType ==
        'Restaurant buffet') {
      Get.offNamed(RouteHelper.getBuffetInitialRoute());
    } else if (!Get.find<AuthController>()
        .profileModel!
        .role!
        .contains('order')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PrintReport(isadmin: true),
        ),
      );
    } else {
      Get.offNamed(RouteHelper.getTableViewHomeRoute());
    }
  }

  Future<bool> _loadFoodAndProduct({String loginType = ''}) async {
    final category = await ApiChecker.retry(
        () => Get.find<RestaurantController>().getPOSFoodCategoryList(),
        retries: 2);

    if (category.statusCode != 200) return false;

    final product = await ApiChecker.retry(
        () => Get.find<RestaurantController>()
            .getWaiterProductList('1', 'all', loginType: loginType),
        retries: 2);

    if (product.statusCode != 200) return false;

    Get.find<AuthController>().saveProductCategoryList(
        jsonEncode(Get.find<RestaurantController>().categoryList));
    Get.find<AuthController>().saveProductList(
        jsonEncode(Get.find<RestaurantController>().productList));

    return true;
  }

  void _resetProgressOnError(AuthController auth) {
    currentApiCall.value = '';
    currentStep.value = 0;
    totalSteps.value = 0;
    progress.value = 0;
    auth.hideLoader();
  }

  Widget buildLoadingIndicator() {
    return Obx(() => Column(
          children: [
            SizedBox(
              width: Get.width * 0.8,
              child: LinearProgressIndicator(
                value: totalSteps.value > 0
                    ? currentStep.value / totalSteps.value
                    : 0,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                color: ColorTheme.appColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentApiCall.value,
              style: poppinsRegular.copyWith(
                fontSize: 12,
                color: ColorTheme.appColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

//   Future<void> makeApiCalls(AuthController authController) async {
//     logoHelper.logoUrlPrint = null;

//     String _email = _emailController.text.trim();
//     String _password = _passwordController.text.trim();

//     // setState(() {
//     isTapButton = true;
//     authController.update();
//     // });

//     if (_email.isEmpty) {
//       // showCustomSnackBar('enter_email_address'.tr);
//     } else if (!GetUtils.isEmail(_email)) {
//       // showCustomSnackBar('enter_a_valid_email_address'.tr);
//     } else if (_password.isEmpty) {
//       // showCustomSnackBar('enter_password'.tr);
//     } else if (_password.length < 6) {
//     } else {
//       /////////////   Login api   /////////////

//       _updateProgress('Logging in...', 1, 6);
//       if (lastEmail != _email && lastPassword != _password) {
//         lastApiCall = '';
//         lastEmail = _email;
//         lastPassword = _password;
//       }
//       authController
//           .employeeLogin(deviceToken, _email, _password, context)
//           .then((status) async {
//         Get.find<ProductController>().clearProductList();
//         Get.find<SwiggyController>().clearOrderList();
//         Get.find<KdsController>().clearOrderList();

//         if (status.isSuccess) {
//           if (status.message == 'admin_login') {
//             // Admin login - navigate to admin dashboard
//             bool success = await authController.getAssignedRestaurants();

//             if (success) {
//               if (authController.isActiveRememberMe) {
//                 authController.saveUserNumberAndPassword(_email, _password);
//               } else {
//                 authController.clearUserNumberAndPassword();
//               }
//               Get.offNamed(RouteHelper.getAdminDashboardRoute());
//             } else {
//               showErrorToast('Failed to load restaurants');
//             }
//           } else if (status.message == 'employee_login') {
//             authController.showLoader();

//             try {
// /////////////   Get Profile Detail api   /////////////
//               _updateProgress('Fetching profile details...', 2, 6);
//               var profileResponse = await ApiChecker.retry(
//                   () => authController.getProfile(),
//                   retries: 2);
//               if (profileResponse.statusCode == 200) {
//                 try {
//                   // List<Future> waiterFuturesApis = [];
//                   // List<Future> billingApis = [];

// ///////////////////      Station   Role     ////////////////
//                   if (authController.profileModel!.role!.contains('STATION')) {
//                     logoHelper.appLogo = Images.ic_kds_app_logo;
//                     if (authController.isActiveRememberMe) {
//                       authController.saveUserNumberAndPassword(
//                           _email, _password);
//                     } else {
//                       authController.clearUserNumberAndPassword();
//                     }
//                     authController.saveUserLoginForBioMatric(_email, _password);
//                     authController.saveProfileDetail(
//                         jsonEncode(authController.profileModel));

//                     authController.hideLoader();

//                     Get.offNamed(RouteHelper.getKdsHomeRoute());
//                   }

// ///////////////////      Delivery   Role     ////////////////

//                   else if (authController.profileModel!.role!
//                       .contains('Delivery')) {
//                     authController.hideLoader();
//                     logoHelper.appLogo = Images.ic_manager_app_logo;
//                     if (authController.isActiveRememberMe) {
//                       authController.saveUserNumberAndPassword(
//                           _email, _password);
//                     } else {
//                       authController.clearUserNumberAndPassword();
//                     }
//                     authController.saveUserLoginForBioMatric(_email, _password);
//                     authController.saveProfileDetail(
//                         jsonEncode(authController.profileModel));

//                     Get.offNamed(
//                         RouteHelper.getDeliveryDashboardInitialRoute());
//                   } else {
//                     // .................    Assign logo based on role   ...............

//                     if (authController.profileModel!.role!.contains('Waiter')) {
//                       if (!authController.profileModel!.role!
//                               .contains('order') &&
//                           authController.profileModel!.role!.contains('bill')) {
//                         logoHelper.appLogo = Images.ic_cashier_app_logo;
//                       }
//                       logoHelper.appLogo = Images.ic_waiter_app_logo;
//                     } else if (authController.profileModel!.role!
//                         .contains('report')) {
//                       logoHelper.appLogo = Images.ic_owner_app_logo;
//                     } else {
//                       logoHelper.appLogo = Images.ic_manager_app_logo;
//                     }
//                     ///////////////////////
//                     ///

//                     if (authController.profileModel!.role!
//                             .contains('Billing') ||
//                         authController.profileModel!.billingUserView == 'Yes' ||
//                         authController.profileModel!.restaurants!.first
//                                 .isOrderPaymentType ==
//                             'prepaid') {
//                       if (authController
//                               .profileModel!.restaurants!.first.isShowEmpList ==
//                           'Yes') {
//                         var getEmployee = await ApiChecker.retry(
//                             () => authController.getEmployeeList(),
//                             retries: 2);
//                         if (getEmployee.statusCode == 200) {
//                           _updateProgress('Loading food categories...', 3, 6);
//                           var getFoodCategory = await ApiChecker.retry(
//                               () => Get.find<RestaurantController>()
//                                   .getPOSFoodCategoryList(),
//                               retries: 2);
//                           if (getFoodCategory.statusCode == 200) {
//                             _updateProgress(
//                                 'Loading product food list...', 4, 6);
//                             var getProductList = await ApiChecker.retry(
//                                 () => Get.find<RestaurantController>()
//                                     .getWaiterProductList('1', 'all',
//                                         loginType: 'Billing'),
//                                 retries: 2);
//                             if (getProductList.statusCode == 200) {
//                               _updateProgress('Finalizing...', 6, 6);
//                               authController.hideLoader();

//                               authController.saveEmployeeList(jsonEncode(
//                                   authController.getEmployeeListResponse));

//                               authController.saveProductCategoryList(jsonEncode(
//                                   Get.find<RestaurantController>()
//                                       .categoryList));
//                               authController.saveProductList(jsonEncode(
//                                   Get.find<RestaurantController>()
//                                       .productList));
//                               if (authController.isActiveRememberMe) {
//                                 authController.saveUserNumberAndPassword(
//                                     _email, _password);
//                               } else {
//                                 authController.clearUserNumberAndPassword();
//                               }
//                               authController.saveUserLoginForBioMatric(
//                                   _email, _password);
//                               authController.saveProfileDetail(
//                                   jsonEncode(authController.profileModel));

//                               if (authController.profileModel!.role!
//                                   .contains('Billing')) {
//                                 Get.offNamed(RouteHelper
//                                     .getBillingDashboardInitialRoute());
//                               } else {
//                                 if (authController
//                                             .profileModel!.billingUserView ==
//                                         'Yes' ||
//                                     authController.profileModel!.restaurants!
//                                             .first.isOrderPaymentType ==
//                                         'prepaid') {
//                                   Navigator.of(context).pushAndRemoveUntil(
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           BeachBellingHomeScreen(),
//                                     ),
//                                     (Route<dynamic> route) => false,
//                                   );
//                                 }
//                               }
//                             } else {
//                               authController.hideLoader();

//                               showErrorToast(
//                                   'Get Food list :${getProductList.statusText}');
//                             }
//                           } else {
//                             authController.hideLoader();

//                             showErrorToast(
//                                 'Get Food category :${getFoodCategory.statusText}');
//                           }
//                         } else {
//                           authController.hideLoader();

//                           showErrorToast(
//                               'Get Employee reason :${getEmployee.statusText}');
//                         }
//                         // billingApis.add(ApiChecker().retry(
//                         //     () => authController.getEmployeeList(),
//                         //     retries: 2));
//                       } else {
//                         _updateProgress('Loading food categories...', 3, 7);
//                         var getFoodCategory = await ApiChecker.retry(
//                             () => Get.find<RestaurantController>()
//                                 .getPOSFoodCategoryList(),
//                             retries: 2);
//                         if (getFoodCategory.statusCode == 200) {
//                           _updateProgress('Loading product food list...', 4, 7);
//                           var getProductList = await ApiChecker.retry(
//                               () => Get.find<RestaurantController>()
//                                   .getWaiterProductList('1', 'all',
//                                       loginType: 'Billing'),
//                               retries: 2);
//                           if (getProductList.statusCode == 200) {
//                             authController.hideLoader();

//                             // authController.saveEmployeeList(jsonEncode(
//                             //     authController.getEmployeeListResponse));

//                             authController.saveProductCategoryList(jsonEncode(
//                                 Get.find<RestaurantController>().categoryList));
//                             authController.saveProductList(jsonEncode(
//                                 Get.find<RestaurantController>().productList));
//                             if (authController.isActiveRememberMe) {
//                               authController.saveUserNumberAndPassword(
//                                   _email, _password);
//                             } else {
//                               authController.clearUserNumberAndPassword();
//                             }
//                             authController.saveUserLoginForBioMatric(
//                                 _email, _password);
//                             authController.saveProfileDetail(
//                                 jsonEncode(authController.profileModel));

//                             if (authController.profileModel!.role!
//                                 .contains('Billing')) {
//                               Get.offNamed(RouteHelper
//                                   .getBillingDashboardInitialRoute());
//                             } else {
//                               if (authController
//                                           .profileModel!.billingUserView ==
//                                       'Yes' ||
//                                   authController.profileModel!.restaurants!
//                                           .first.isOrderPaymentType ==
//                                       'prepaid') {
//                                 Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         BeachBellingHomeScreen(),
//                                   ),
//                                   (Route<dynamic> route) => false,
//                                 );
//                               }
//                             }
//                           } else {
//                             authController.hideLoader();
//                             showErrorToast(
//                                 'Get Food list :${getProductList.statusText}');
//                           }
//                         } else {
//                           authController.hideLoader();

//                           showErrorToast(
//                               'Get Food category :${getFoodCategory.statusText}');
//                         }
//                       }

//                       // billingApis.add(ApiChecker().retry(() =>
//                       //     Get.find<RestaurantController>()
//                       //         .getPOSFoodCategoryList()));
//                       // billingApis.add(ApiChecker().retry(
//                       //     () => Get.find<RestaurantController>()
//                       //         .getWaiterProductList('1', 'all',
//                       //             loginType: 'Billing'),
//                       //     retries: 2));
//                     } else {
//                       Get.find<KdsController>().setSubMenuIndex(
//                           !authController.profileModel!.role!.contains('order')
//                               ? 2
//                               : 1);
//                       _updateProgress('Loading food categories...', 3, 7);
//                       var getFoodCategory = await ApiChecker.retry(
//                           () => Get.find<RestaurantController>()
//                               .getPOSFoodCategoryList(),
//                           retries: 2);
//                       if (getFoodCategory.statusCode == 200) {
//                         _updateProgress('Loading product food list...', 4, 7);
//                         var getProductList = await ApiChecker.retry(
//                             () => Get.find<RestaurantController>()
//                                 .getWaiterProductList('1', 'all'),
//                             retries: 2);
//                         if (getProductList.statusCode == 200) {
//                           _updateProgress('Loading cancel reasons...', 5, 7);
//                           var getCancelReason = await ApiChecker.retry(
//                               () => Get.find<KdsController>().getCancelReason(),
//                               retries: 2);
//                           if (getCancelReason.statusCode == 200) {
//                             _updateProgress('Loading table list...', 6, 7);
//                             var getTableList = await ApiChecker.retry(
//                                 () => Get.find<TableController>()
//                                     .saveTableListLocally(),
//                                 retries: 2);
//                             if (getTableList.statusCode == 200) {
//                               _updateProgress('Complete!', 7, 7);
//                               authController.hideLoader();

//                               if (authController.isActiveRememberMe) {
//                                 authController.saveUserNumberAndPassword(
//                                     _email, _password);
//                               } else {
//                                 authController.clearUserNumberAndPassword();
//                               }
//                               authController.saveUserLoginForBioMatric(
//                                   _email, _password);
//                               authController.saveProfileDetail(
//                                   jsonEncode(authController.profileModel));
//                               authController.saveProductCategoryList(jsonEncode(
//                                   Get.find<RestaurantController>()
//                                       .categoryList));
//                               authController.saveProductList(jsonEncode(
//                                   Get.find<RestaurantController>()
//                                       .productList));
//                               Get.offNamed(RouteHelper.getTableViewHomeRoute());

//                               // if (GetPlatform.isWindows ||
//                               //     MediaQuery.of(context).size.shortestSide >
//                               //         570) {
//                               //   Get.offNamed(RouteHelper
//                               //       .getTablateWaiterDashboardInitialRoute());
//                               // } else {
//                               //   Get.offNamed(
//                               //       RouteHelper.getWaiterDashboardInitialRoute());
//                               // }
//                             } else {
//                               authController.hideLoader();

//                               showErrorToast(
//                                   'Table List reason :${getTableList.statusText}');
//                             }
//                           } else {
//                             authController.hideLoader();

//                             showErrorToast(
//                                 'cancel reason :${getCancelReason.statusText}');
//                           }
//                         } else {
//                           authController.hideLoader();

//                           showErrorToast(
//                               'Product List :${getProductList.statusText}');
//                         }
//                       } else {
//                         authController.hideLoader();

//                         showErrorToast(
//                             'Product category :${getFoodCategory.statusText}');
//                       }
//                       // waiterFuturesApis.add(ApiChecker().retry(() =>
//                       //     Get.find<RestaurantController>()
//                       //         .getPOSFoodCategoryList()));
//                       // waiterFuturesApis.add(ApiChecker().retry(() =>
//                       //     Get.find<RestaurantController>()
//                       //         .getWaiterProductList('1', 'all')));
//                       // waiterFuturesApis.add(ApiChecker().retry(
//                       //     () => Get.find<KdsController>().getCancelReason()));
//                       // waiterFuturesApis.add(ApiChecker().retry(() =>
//                       //     Get.find<TableController>().saveTableListLocally()));
//                     }

//                     // var billingResponse;
//                     // var waiterResponse;
//                     // if (authController.profileModel.role.contains('Billing') ||
//                     //     authController.profileModel.billingUserView == 'Yes') {
//                     //   billingResponse = await Future.wait(billingApis);
//                     //   authController.hideLoader();
//                     //   if (billingResponse.isNotEmpty) {
//                     //     if (authController
//                     //             .profileModel.restaurants.first.isShowEmpList ==
//                     //         'Yes') {
//                     //       if (billingResponse[0].statusCode == 200) {
//                     //         authController.saveEmployeeList(jsonEncode(
//                     //             authController.getEmployeeListResponse));

//                     //         if (billingResponse[1].statusCode == 200) {
//                     //           authController.saveProductCategoryList(jsonEncode(
//                     //               Get.find<RestaurantController>().categoryList));
//                     //           if (billingResponse[2].statusCode == 200) {
//                     //             authController.saveProductList(jsonEncode(
//                     //                 Get.find<RestaurantController>()
//                     //                     .productList));
//                     //             if (authController.isActiveRememberMe) {
//                     //               authController.saveUserNumberAndPassword(
//                     //                   _email, _password);
//                     //             } else {
//                     //               authController.clearUserNumberAndPassword();
//                     //             }
//                     //             authController.saveUserLoginForBioMatric(
//                     //                 _email, _password);
//                     //             authController.saveProfileDetail(
//                     //                 jsonEncode(authController.profileModel));

//                     //             if (authController.profileModel.role
//                     //                 .contains('Billing')) {
//                     //               Get.offNamed(RouteHelper
//                     //                   .getBillingDashboardInitialRoute());
//                     //             } else {
//                     //               if (authController
//                     //                       .profileModel.billingUserView ==
//                     //                   'Yes') {
//                     //                 Navigator.of(context).pushAndRemoveUntil(
//                     //                   MaterialPageRoute(
//                     //                     builder: (context) =>
//                     //                         BeachBellingHomeScreen(),
//                     //                   ),
//                     //                   (Route<dynamic> route) => false,
//                     //                 );
//                     //               }
//                     //             }
//                     //           } else {
//                     //             showErrorToast(
//                     //                 'Product List :${billingResponse[2].statusText}');
//                     //           }
//                     //         } else {
//                     //           showErrorToast(
//                     //               'Category List :${billingResponse[1].statusText}');
//                     //         }
//                     //       } else {
//                     //         showErrorToast(
//                     //             'Employee List :${billingResponse[0].statusText}');
//                     //       }
//                     //     } else {
//                     //       if (billingResponse[0].statusCode == 200) {
//                     //         authController.saveProductCategoryList(jsonEncode(
//                     //             Get.find<RestaurantController>().categoryList));
//                     //         if (billingResponse[1].statusCode == 200) {
//                     //           authController.saveProductList(jsonEncode(
//                     //               Get.find<RestaurantController>().productList));
//                     //           if (authController.profileModel.role
//                     //               .contains('Billing')) {
//                     //             Get.offNamed(RouteHelper
//                     //                 .getBillingDashboardInitialRoute());
//                     //           } else {
//                     //             if (authController.profileModel.billingUserView ==
//                     //                 'Yes') {
//                     //               if (authController.isActiveRememberMe) {
//                     //                 authController.saveUserNumberAndPassword(
//                     //                     _email, _password);
//                     //               } else {
//                     //                 authController.clearUserNumberAndPassword();
//                     //               }
//                     //               authController.saveUserLoginForBioMatric(
//                     //                   _email, _password);
//                     //               authController.saveProfileDetail(
//                     //                   jsonEncode(authController.profileModel));

//                     //               Navigator.of(context).pushAndRemoveUntil(
//                     //                 MaterialPageRoute(
//                     //                   builder: (context) =>
//                     //                       BeachBellingHomeScreen(),
//                     //                 ),
//                     //                 (Route<dynamic> route) => false,
//                     //               );
//                     //             }
//                     //           }
//                     //         } else {
//                     //           showErrorToast(
//                     //               'Product List :${billingResponse[1].statusText}');
//                     //         }
//                     //       } else {
//                     //         showErrorToast(
//                     //             'Category List :${billingResponse[0].statusText}');
//                     //       }
//                     //     }
//                     //   }
//                     // } else {
//                     // waiterResponse = await Future.wait(waiterFuturesApis);
//                     // authController.hideLoader();
//                     // if (waiterFuturesApis.isNotEmpty) {
//                     //   if (waiterResponse[0].statusCode == 200) {
//                     //     // ,,,,,,,,,,,,,,,     Product category .............
//                     //     authController.saveProductCategoryList(jsonEncode(
//                     //         Get.find<RestaurantController>().categoryList));
//                     //     if (waiterResponse[1].statusCode == 200) {
//                     //       // ,,,,,,,,,,,,,,,     Product list .............
//                     //       authController.saveProductList(jsonEncode(
//                     //           Get.find<RestaurantController>().productList));

//                     //       if (waiterResponse[2].statusCode == 200) {
//                     //         // ,,,,,,,,,,,,,,,     cancel reason list .............

//                     //         if (waiterResponse[3].statusCode == 200) {
//                     //           // ,,,,,,,,,,,,,,,     Get Table list .............
//                     //           if (authController.isActiveRememberMe) {
//                     //             authController.saveUserNumberAndPassword(
//                     //                 _email, _password);
//                     //           } else {
//                     //             authController.clearUserNumberAndPassword();
//                     //           }
//                     //           authController.saveUserLoginForBioMatric(
//                     //               _email, _password);
//                     //           authController.saveProfileDetail(
//                     //               jsonEncode(authController.profileModel));

//                     //           if (MediaQuery.of(context).size.shortestSide >
//                     //               570) {
//                     //             Get.offNamed(RouteHelper
//                     //                 .getTablateWaiterDashboardInitialRoute());
//                     //           } else {
//                     //             Get.offNamed(RouteHelper
//                     //                 .getWaiterDashboardInitialRoute());
//                     //           }
//                     //         } else {
//                     //           showErrorToast(
//                     //               'Table List :${waiterResponse[3].statusText}');
//                     //         }
//                     //       } else {
//                     //         showErrorToast(
//                     //             'cancel reason :${waiterResponse[2].statusText}');
//                     //       }
//                     //     } else {
//                     //       showErrorToast(
//                     //           'Product List :${waiterResponse[1].statusText}');
//                     //     }
//                     //   } else {
//                     //     showErrorToast(
//                     //         'Product category :${waiterResponse[0].statusText}');
//                     //   }
//                     // }
//                     // }
//                   }

//                   // If all succeed
//                   // print("All APIs successful!");
//                   // showErrorToast('All APIs successful', isError: false);
//                   // print(
//                   //     responses); // Use this to view responses or do something with them
//                 } catch (e) {
//                   // If even after retrying, any API fails
//                   // print("API call failed after retries: $e");
//                   showErrorToast('$e');
//                   // Show user a retry option or error page
//                 }
//               }
//             } catch (e) {
//               // If even after retrying, any API fails
//               // print("API call failed after retries: $e");
//               showErrorToast('Profile Detail catch error : $e');
//               // Show user a retry option or error page
//             }
//           }
//         } else {
//           if (status.message != 'no') {
//             showErrorToast(status.message);
//           }
//         }
//       });
//     }
//   }

  Future isConnectedToInternet(String url, bool isGoogle) async {
    // var connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   return false;
    // }

    // Optional: Check actual internet access
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        showErrorToast(
            isGoogle
                ? 'Google api response success'
                : 'Mygenie api response success',
            isError: false);
      } else {
        showErrorToast(
            isGoogle
                ? 'Google api status code ${response.statusCode}'
                : 'Mygenie api status code ${response.statusCode}',
            isError: false);
      }
    } catch (e) {
      showErrorToast(isGoogle
          ? 'Google catch response  $e'
          : 'Mygenie catch response  $e');
    }
  }

  checkLocalInternet() async {
    var connectivityResults = await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      print("Connected to Wi-Fi");
      showErrorToast('Connected to the internet via Wi-Fi', isError: false);
    } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
      showErrorToast('Connected to the internet via Mobile Network',
          isError: false);
    } else if (connectivityResults.contains(ConnectivityResult.none)) {
      showErrorToast("No Network Connection locally");
    }
  }

  void _updateProgress(String apiName, int step, int total) {
    currentApiCall.value = apiName;
    currentStep.value = step;
    totalSteps.value = total;
    progress.value = step / total;
  }

  // Widget buildLoadingIndicator() {
  //   return Obx(() => Column(
  //         children: [
  //           SizedBox(
  //             width: Get.width * 0.8,
  //             child: LinearProgressIndicator(
  //               value: totalSteps.value > 0
  //                   ? currentStep.value / totalSteps.value
  //                   : 0,
  //               backgroundColor: Colors.grey[300],
  //               color: ColorTheme.appColor,
  //               minHeight: 6,
  //             ),
  //           ),
  //           SizedBox(height: 12),
  //           Text(
  //             currentApiCall.value,
  //             style: poppinsRegular.copyWith(
  //               fontSize: 12,
  //               color: ColorTheme.appColor,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ));
  // }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Color color1 = Color(0xFF00ACB3);
    Color color2 = Color(0xFF044042);
    var paint = Paint()
      // ..color = Colors.teal
      ..shader = RadialGradient(
        colors: [
          color1,
          color2,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(0, 0),
        radius: 10,
      ));
    // ..shader = ui.Gradient.linear(
    //   Offset(0,0),
    //   Offset(1,1),
    //   [
    //     color1,
    //     color2,
    //   ],
    // );

    // ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9,
        size.width * 1.0, size.height * 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
