import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_app_bar.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/auth/widget/signin_text_field.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/beach_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeResetPassword extends StatefulWidget {
  final String resetToken;
  final String email;
  final String? password;
  final bool fromPasswordChange;
  final String? image;

  const EmployeeResetPassword({
    super.key,
    required this.resetToken,
    required this.email,
    this.password,
    required this.fromPasswordChange,
    this.image,
  });

  @override
  State<EmployeeResetPassword> createState() => _EmployeeResetPasswordState();
}

class _EmployeeResetPasswordState extends State<EmployeeResetPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  bool isTapButton = false;

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _oldPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String deviceToken = '';

  @override
  void initState() {
    super.initState();
    getDeviceToken();
  }

  Future<void> getDeviceToken() async {
    deviceToken = (await FirebaseMessaging.instance.getToken()) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.fromPasswordChange
            ? 'change_password'.tr
            : 'reset_password'.tr,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Center(
            child: SizedBox(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: widget.image != null
                        ? Image.asset(widget.image!,
                            width: Get.context!.width * 0.5)
                        : const SizedBox(),
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  Text('Choose your password',
                      style: poppinsMedium.copyWith(fontSize: 14)),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 35, left: 16, right: 16),
                    child: DottedLine(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      lineThickness: 1.0,
                      dashLength: 2.5,
                      dashColor: ColorTheme.hintText,
                    ),
                  ),
                  GetBuilder<AuthController>(builder: (authController) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          if (widget.fromPasswordChange)
                            SignInTextField(
                              hintText: 'Old Password'.tr,
                              controller: _oldPasswordController,
                              focusNode: _oldPasswordFocus,
                              inputAction: TextInputAction.done,
                              inputType: TextInputType.visiblePassword,
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              onChanged: (v) {
                                authController.update();
                              },
                              onSubmit: (text) {},
                            ),
                          if (widget.fromPasswordChange &&
                              isTapButton &&
                              _oldPasswordController.text.isEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'Enter your old password'.tr,
                                  style: poppinsRegular.copyWith(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ),
                            ),
                          if (widget.fromPasswordChange &&
                              isTapButton &&
                              _oldPasswordController.text.isNotEmpty &&
                              _oldPasswordController.text.length < 6)
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
                          const SizedBox(height: 10),
                          SignInTextField(
                            hintText: 'new_password'.tr,
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocus,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            icon: Icons.lock_outline_rounded,
                            onChanged: (v) {
                              authController.update();
                            },
                            isPassword: true,
                            onSubmit: (text) {},
                          ),
                          if (isTapButton &&
                              _newPasswordController.text.isEmpty)
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
                              _newPasswordController.text.isNotEmpty &&
                              _newPasswordController.text.length < 6)
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
                          const SizedBox(height: 10),
                          SignInTextField(
                            hintText: 'confirm_password'.tr,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            icon: Icons.lock_outline_rounded,
                            onChanged: (v) {
                              authController.update();
                            },
                            isPassword: true,
                            onSubmit: (text) {},
                          ),
                          if (isTapButton &&
                              _confirmPasswordController.text.isEmpty)
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
                              _confirmPasswordController.text.isNotEmpty &&
                              _confirmPasswordController.text.length < 6)
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
                          if (isTapButton &&
                              _confirmPasswordController.text.isNotEmpty &&
                              _confirmPasswordController.text.length > 5 &&
                              _newPasswordController.text.isNotEmpty &&
                              _newPasswordController.text.trim() !=
                                  _confirmPasswordController.text.trim())
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'password_does_not_matched'.tr,
                                  style: poppinsRegular.copyWith(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                  GetBuilder<AuthController>(builder: (authController) {
                    return !authController.isLoading
                        ? InkWell(
                            onTap: () {
                              _resetPassword(authController);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.1, vertical: 9),
                              decoration: BoxDecoration(
                                  color: ColorTheme.appColor,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Text(
                                'Update Password',
                                style: poppinsMedium.copyWith(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator());
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(AuthController authController) {
    String _oldPassword = !widget.fromPasswordChange
        ? (widget.password ?? '')
        : _oldPasswordController.text.trim();
    String _password = _newPasswordController.text.trim();
    String _confirmPassword = _confirmPasswordController.text.trim();
    isTapButton = true;
    authController.update();
    if (_oldPassword.isEmpty) {
      // showCustomSnackBar('Enter your old password'.tr);
    } else if (_password.isEmpty) {
      // showCustomSnackBar('enter_password'.tr);
    } else if (_password.length < 6) {
      // showCustomSnackBar('password_should_be'.tr);
    } else if (_password != _confirmPassword) {
      // showCustomSnackBar('password_does_not_matched'.tr);
    } else {
      Get.find<AuthController>()
          .employeeresetPassword(
              widget.resetToken, _oldPassword, _password, _confirmPassword)
          .then((value) async {
        if (value.message == 'Password updated successfully') {
          Get.find<AuthController>()
              .saveUserNumberAndPassword(widget.email, _password);
          if (!widget.fromPasswordChange) {
            authController
                .employeeLogin(deviceToken, widget.email, _password, context)
                .then((status) async {
              if (status.isSuccess) {
                authController.showLoader();
                if (authController.isActiveRememberMe) {
                  authController.saveUserNumberAndPassword(
                      widget.email, _password);
                } else {
                  authController.clearUserNumberAndPassword();
                }
                authController.saveUserLoginForBioMatric(
                    widget.email, _password);
                await authController.getProfile();
                if (authController.profileModel!.role!.contains('STATION')) {
                  logoHelper.appLogo = Images.ic_kds_app_logo;

                  authController.hideLoader();
                  Get.offNamed(RouteHelper.getKdsHomeRoute());
                } else if (authController.profileModel!.role!
                    .contains('Delivery')) {
                  Get.offNamed(RouteHelper.getDeliveryDashboardInitialRoute());
                } else {
                  if (authController.profileModel!.role!.contains('Waiter')) {
                    if (!authController.profileModel!.role!.contains('order') &&
                        authController.profileModel!.role!.contains('bill')) {
                      logoHelper.appLogo = Images.ic_cashier_app_logo;
                    }
                    logoHelper.appLogo = Images.ic_waiter_app_logo;
                  } else if (authController.profileModel!.role!
                      .contains('report')) {
                    logoHelper.appLogo = Images.ic_owner_app_logo;
                  } else {
                    logoHelper.appLogo = Images.ic_manager_app_logo;
                  }
                  Get.find<KdsController>().clearOrderList();
                  authController.saveProfileDetail(
                      jsonEncode(authController.profileModel));
                  if (authController.profileModel!.role!.contains('Billing')) {
                    if (authController
                            .profileModel!.restaurants!.first.isShowEmpList ==
                        'Yes') await authController.getEmployeeList();
                    if (authController
                            .profileModel!.restaurants!.first.isShowEmpList ==
                        'Yes') {
                      authController.saveEmployeeList(
                          jsonEncode(authController.getEmployeeListResponse));
                    }
                    await Get.find<RestaurantController>()
                        .getWaiterProductList('1', 'all', loginType: 'Billing');
                  }
                  Get.find<KdsController>().setSubMenuIndex(
                      !authController.profileModel!.role!.contains('order')
                          ? 2
                          : 1);
                  if (!authController.profileModel!.role!.contains('Billing')) {
                    await Get.find<KdsController>().getCancelReason();

                    await Get.find<RestaurantController>()
                        .getWaiterProductList('1', 'all');
                  }
                  authController.saveProductList(
                      jsonEncode(Get.find<RestaurantController>().productList));
                  await Get.find<RestaurantController>()
                      .getPOSFoodCategoryList();
                  authController.saveProductCategoryList(jsonEncode(
                      Get.find<RestaurantController>().categoryList));
                  authController.hideLoader();
                  if (authController.profileModel!.role!.contains('Billing')) {
                    Get.offNamed(RouteHelper.getBillingDashboardInitialRoute());
                  } else {
                    if (Get.find<AuthController>()
                            .profileModel!
                            .billingUserView ==
                        'Yes') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => BeachBellingHomeScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      if (GetPlatform.isWindows ||
                          MediaQuery.of(context).size.shortestSide > 570) {
                        Get.offNamed(RouteHelper.getTableViewHomeRoute());
                      } else {
                        Get.offNamed(RouteHelper.getTableViewHomeRoute());
                      }
                    }
                  }
                }
              } else {
                if (status.message != 'no') {
                  showErrorToast(status.message);
                }
              }
            });
          } else {
            Get.back();
          }
        } else {
          Get.find<AuthController>().hideLoader();
          showErrorToast(value.message);
        }
      });
    }
  }
}
