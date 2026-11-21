import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_app_bar.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  bool isTapButton = false;
  final TextEditingController _emailController = TextEditingController();
  CountryCode countryCode = CountryCode(dialCode: '+91');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'forgot_password'.tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.06),
                  child: Image.asset(
                    Images.brand_logo,
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Please enter your registered mobile number to help us recover your password',
                    style: poppinsSemiBold.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: 30, bottom: 35, left: 16, right: 16),
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
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTheme.borderGrey),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (CountryCode _countryCode) {
                            setState(() {
                              countryCode = _countryCode;
                            });
                          },
                          initialSelection: 'IN',
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagMain: false,
                          flagWidth: 20,
                          dialogBackgroundColor: Theme.of(context).cardColor,
                          textStyle: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            height: 36,
                            child: TextField(
                              controller: _emailController,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: true),
                              style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 16
                                        : 13,
                              ),
                              cursorColor: ColorTheme.appColor,
                              autofocus: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'Mobile Number',
                                fillColor: Colors.white,
                                hintStyle: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 16
                                          : 13,
                                  color: ColorTheme.hintText,
                                ),
                                filled: true,
                              ),
                              onChanged: (String d) {
                                authController.update();
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isTapButton && _emailController.text.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, left: 30),
                      child: Text(
                        'enter_phone_number'.tr,
                        style: poppinsRegular.copyWith(
                            color: Colors.red, fontSize: 10),
                      ),
                    ),
                  ),
                if (isTapButton &&
                    _emailController.text.isNotEmpty &&
                    !GetUtils.isPhoneNumber(_emailController.text.trim()))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, left: 30),
                      child: Text(
                        'enter_a_valid_phone_number'.tr,
                        style: poppinsRegular.copyWith(
                            color: Colors.red, fontSize: 10),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                GetBuilder<AuthController>(builder: (authController) {
                  return !authController.isLoading
                      ? InkWell(
                          onTap: () {
                            _forgetPass();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.15,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTheme.appColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'Submit'.tr,
                              style: poppinsMedium.copyWith(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator());
                }),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _forgetPass() {
    String _email = _emailController.text.trim();
    setState(() {
      isTapButton = true;
    });
    Get.find<AuthController>().update();
    if (_email.isEmpty) {
      // showCustomSnackBar('enter_phone_number'.tr);
    } else if (!GetUtils.isPhoneNumber(_email)) {
      // showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      Get.find<AuthController>()
          .forgetPassword(_email, countryCode.dialCode ?? '+91')
          .then((status) async {
        if (status.isSuccess) {
          showErrorToast(status.message, isError: false);
          Get.find<AuthController>().clearSharedData();
          Get.offAllNamed(RouteHelper.getSignInRoute());
        } else {
          showErrorToast(status.message);
        }
      });
    }
  }
}
