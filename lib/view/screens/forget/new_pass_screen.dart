import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_app_bar.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/custom_text_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPassScreen extends StatefulWidget {
  final String resetToken;
  final String email;
  final bool fromPasswordChange;
  const NewPassScreen({
    super.key,
    required this.resetToken,
    required this.email,
    required this.fromPasswordChange,
  });

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
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
      appBar: CustomAppBar(
        title: widget.fromPasswordChange
            ? 'change_password'.tr
            : 'reset_password'.tr,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: Center(
              child: SizedBox(
                width: 1170,
                child: Column(
                  children: [
                    Text(
                      'enter_new_password'.tr,
                      style: poppinsRegular,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            hintText: 'new_password'.tr,
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocus,
                            nextFocus: _confirmPasswordFocus,
                            inputType: TextInputType.visiblePassword,
                            prefixIcon: Images.lock,
                            isPassword: true,
                            divider: true,
                          ),
                          CustomTextField(
                            hintText: 'confirm_password'.tr,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            prefixIcon: Images.lock,
                            isPassword: true,
                            onSubmit: (text) =>
                                GetPlatform.isWeb ? _resetPassword() : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    GetBuilder<AuthController>(builder: (authController) {
                      return !authController.isLoading
                          ? CustomButton(
                              buttonText: 'done'.tr,
                              onPressed: _resetPassword,
                            )
                          : const Center(child: CircularProgressIndicator());
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      showErrorToast('enter_password'.tr);
    } else if (password.length < 6) {
      showErrorToast('password_should_be'.tr);
    } else if (password != confirmPassword) {
      showErrorToast('password_does_not_matched'.tr);
    } else {
      if (widget.fromPasswordChange) {
        ProfileModel? user = Get.find<AuthController>().profileModel;
        // Get.find<AuthController>().changePassword(user, password);
      } else {
        Get.find<AuthController>()
            .resetPassword(
                widget.resetToken, widget.email, password, confirmPassword)
            .then((value) {
          if (value.isSuccess) {
            // Get.find<AuthController>()
            //     .login(deviceToken, widget.email, password)
            //     .then((value) async {
            //   Get.offAllNamed(RouteHelper.getInitialRoute());
            // });
          } else {
            showErrorToast(value.message);
          }
        });
      }
    }
  }
}
