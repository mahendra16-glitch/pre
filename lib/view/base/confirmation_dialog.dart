import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/controller/order_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final String? adminText;
  final VoidCallback onYesPressed;
  final VoidCallback? onNoPressed;
  final bool isLogOut;

  const ConfirmationDialog({
    Key? key,
    required this.icon,
    this.title,
    required this.description,
    this.adminText,
    required this.onYesPressed,
    this.onNoPressed,
    this.isLogOut = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
          color: Colors.white),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(icon,
                width: 50, height: 50, color: ColorTheme.appColor),
            title != null
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_LARGE),
                    child: Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: poppinsMedium.copyWith(
                          fontSize: 14, color: Colors.red),
                    ),
                  )
                : SizedBox(),
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              child: Text(description,
                  style: poppinsMedium.copyWith(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
            adminText != null && adminText!.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Text('[$adminText]',
                        style: poppinsMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE),
                        textAlign: TextAlign.center),
                  )
                : SizedBox(),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            GetBuilder<DeliveryManController>(builder: (dmController) {
              return GetBuilder<RestaurantController>(
                  builder: (restController) {
                return GetBuilder<AuthController>(builder: (authController) {
                  return GetBuilder<OrderController>(
                      builder: (orderController) {
                    return (authController.isLoading ||
                            restController.isLoading)
                        ? Center(
                            child: CircularProgressIndicator(
                                color: ColorTheme.appColor))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CustomButton(
                                  width: 100,
                                  color: Color(0xFFC6C6C6),
                                  buttonText: isLogOut ? 'no'.tr : 'yes'.tr,
                                  onPressed: () =>
                                      isLogOut ? Get.back() : onYesPressed(),
                                  height: 30,
                                ),
                                SizedBox(width: 15),

                                CustomButton(
                                  width: 100,
                                  color: ColorTheme.appColor,
                                  buttonText: isLogOut ? 'yes'.tr : 'no'.tr,
                                  onPressed: () => isLogOut
                                      ? onYesPressed()
                                      : onNoPressed != null
                                          ? onNoPressed!()
                                          : Get.back(),
                                  height: 30,
                                ),
                                // Container(
                                //   width: 100,
                                //   height: 30,
                                //   child: TextButton(

                                //     onPressed: () => isLogOut
                                //     ? onYesPressed()
                                //     : onNoPressed != null
                                //         ? onNoPressed()
                                //         : Get.back(),
                                //     style: TextButton.styleFrom(
                                //   backgroundColor: Theme.of(context)
                                //       .disabledColor
                                //       .withOpacity(0.3),
                                //   minimumSize: Size(1170, 40),
                                //   padding: EdgeInsets.zero,
                                //   shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(
                                //           Dimensions.RADIUS_SMALL)),
                                //     ),
                                //     child: Text(
                                //   isLogOut ? 'yes'.tr : 'no'.tr,
                                //   textAlign: TextAlign.center,
                                //   style: poppinsBold.copyWith(
                                //       color: Theme.of(context)
                                //           .textTheme
                                //           .bodyLarge
                                //           .color),
                                //     ),
                                //   ),
                                // ),
                              ]);
                  });
                });
              });
            }),
          ]),
        ),
      ),
    );
  }
}
