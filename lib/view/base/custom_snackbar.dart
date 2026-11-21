import 'dart:async';

import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showCustomSnackBar(String message,
    {bool isError = true, bool isCart = false}) {
  Get.snackbar(
    '',
    '',
    backgroundColor: isError ? Colors.red : ColorTheme.appColor,
    messageText: Text(
      message,
      style: poppinsRegular.copyWith(
        color: Colors.white,
        fontSize: Dimensions.FONT_SIZE_SMALL,
      ),
    ),
    duration: Duration(seconds: 2),
    snackStyle: SnackStyle.FLOATING,
    margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
    borderRadius: 10,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  );
}

void showToast(String msg, {String name = ''}) {
  Get.bottomSheet(Container(
    width: Get.width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        color: Colors.white),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: 25,
            end: 25,
            top: 30,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        child: GetBuilder<LoadingController>(builder: (loadingController) {
          if (loadingController.isSuccess) {
            Future.delayed(Duration(seconds: loadingController.isError ? 3 : 1),
                () async {
              if (Get.isBottomSheetOpen ?? false) Get.back();
              await loadingController.changeStatus(data: false);
            });
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            loadingController.isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: ColorTheme.appColor,
                    size: 50,
                  )
                : loadingController.isError
                    ? Icon(
                        Icons.error_outline,
                        size: 45,
                        color: ColorTheme.appColor,
                      )
                    : SvgPicture.asset(Images.ic_success,
                        width: 50, height: 50),
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              child: Text(
                  loadingController.isLoading
                      ? 'Please wait..'
                      : loadingController.text,
                  style: poppinsMedium.copyWith(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          ]);
        }),
      ),
    ),
  ));
}

void showToastSuccess(String msg) {
  Get.bottomSheet(Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        color: Colors.white),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: 25,
            end: 25,
            top: 30,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        child: GetBuilder<LoadingController>(builder: (loadingController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.close,
                  color: ColorTheme.appColor,
                  size: 24,
                ),
              ),
            ),
            loadingController.isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: ColorTheme.appColor,
                    size: 50,
                  )
                : loadingController.isError
                    ? Icon(
                        Icons.error_outline,
                        size: 45,
                        color: ColorTheme.appColor,
                      )
                    : SvgPicture.asset(Images.ic_success,
                        width: 50, height: 50),
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              child: Text(msg,
                  style: poppinsMedium.copyWith(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          ]);
        }),
      ),
    ),
  ));
}

void showErrorToast(String msg, {bool isError = true}) {
  Get.bottomSheet(Container(
    width: Get.width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        color: Colors.white),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: 25,
            end: 25,
            top: 30,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        child: GetBuilder<LoadingController>(builder: (loadingController) {
          Future.delayed(Duration(seconds: 3), () async {
            if (Get.isBottomSheetOpen ?? false) Get.back();
          });
          return Column(mainAxisSize: MainAxisSize.min, children: [
            !isError
                ? SvgPicture.asset(Images.ic_success, width: 50, height: 50)
                : Icon(
                    Icons.error_outline,
                    size: 45,
                    color: ColorTheme.appColor,
                  ),
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              child: Text(msg,
                  style: poppinsMedium.copyWith(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          ]);
        }),
      ),
    ),
  ));
}
