import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class AppStyle {
  static TextStyle txW500Red = TextStyle(
    color: ColorTheme.appColor,
    fontFamily: "Poppins",
    // fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
  );

  static TextStyle tx13W500grey = TextStyle(
    fontSize: 13,
    color: ColorTheme.hintText,
    fontFamily: "Poppins",
    // fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
  );

  static TextStyle tx18boldRed = TextStyle(
    color: ColorTheme.appColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: "Poppins",
    // fontFamily: AppFonts.poppins,
  );

  static TextStyle tx18mediumRed = TextStyle(
      color: ColorTheme.grey8C,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: "Montserrat"
      // fontFamily: AppFonts.montserrat,
      );

  static TextStyle manageAmount14Green = TextStyle(
      color: ColorTheme.green, fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle stockHeaderStyle = TextStyle(
      fontSize: 10, fontWeight: FontWeight.w300, color: ColorTheme.grey109);

  static TextStyle stockListStyle =
      TextStyle(fontSize: 14, fontFamily: "Montserrat"
          // fontFamily: AppFonts.montserrat,
          );
  static TextStyle manageListStyle =
      TextStyle(fontSize: 12, fontFamily: "Montserrat"
          // fontFamily: AppFonts.montserrat,
          );

  static TextStyle deleteTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: ColorTheme.grey105,
  );

  static TextStyle addCategoryTextStyle = TextStyle(
      fontSize: 16, color: ColorTheme.whiteColor, fontWeight: FontWeight.bold);

  static TextStyle txt14FoodValue = TextStyle(
    // fontFamily: AppFonts.montserrat,
    fontSize: 14, fontFamily: "Montserrat",
    color: ColorTheme.foodValue,
  );

  static TextStyle orangeButtonStyle = TextStyle(
      // fontFamily: AppFonts.montserrat,
      fontSize: 14,
      color: ColorTheme.whiteColor,
      fontFamily: "Montserrat",
      fontWeight: FontWeight.bold);

  static TextStyle searchTextStyle = TextStyle(
    fontSize: 16,
    // fontFamily: AppFonts.montserrat,
    color: ColorTheme.grey8C, fontFamily: "Montserrat",
    height: 16 / 19,
  );
}
