import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class confirmationDialog extends StatelessWidget {
  String confirmDescriptionText;
  void Function()? onYesTap;
  confirmationDialog(
      {Key? key, required this.confirmDescriptionText, this.onYesTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: ColorTheme.whiteColor),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.support, width: 50, height: 50),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(confirmDescriptionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  )),
            ),
            20.height,
            ButtonRow(onYesTap: onYesTap)
          ]),
        ),
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  void Function()? onYesTap;

  ButtonRow({Key? key, this.onYesTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
              color: ColorTheme.secondGreyColor,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              AppString.no,
              style: TextStyle(
                color: ColorTheme.blackColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
        10.width,
        GestureDetector(
          onTap: onYesTap,
          child: Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
              color: ColorTheme.appColor,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              AppString.yes,
              style: TextStyle(
                color: ColorTheme.whiteColor,
                fontSize: 16,
              ),
            ),
          ),
        )
      ],
    );
  }
}
