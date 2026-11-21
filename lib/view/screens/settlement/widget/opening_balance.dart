import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

openingClosingBalance({Color? color, String? text, String? openingBalance}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text ?? "Opening Balance",
          style: MyTextStyle.blueColor12W500
              .copyWith(color: ColorTheme.borderGrey, fontSize: 11)),
      Text(openingBalance ?? "₹1000",
          style: MyTextStyle.greenW60018
              .copyWith(fontSize: 14, color: color ?? ColorTheme.green)),
    ],
  ).paddingOnly(top: 15);
}
