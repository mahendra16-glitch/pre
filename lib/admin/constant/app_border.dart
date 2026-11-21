import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class AppBorder {
  static InputBorder menuSearchBorder = OutlineInputBorder(
    borderSide: BorderSide(color: ColorTheme.transparent),
    borderRadius: BorderRadius.circular(50),
  );

  static InputBorder errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: ColorTheme.red, width: 1),
  );
  static InputBorder stockSearchBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: ColorTheme.transparent, width: 1),
  );

  static InputBorder selectStockNameFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: ColorTheme.grey.withOpacity(.8), width: 1),
  );
  static InputBorder categoryBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: ColorTheme.grey.withOpacity(.5), width: 1),
  );

  static InputBorder greyWidth120 = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: ColorTheme.grey, width: 1),
  );

  static InputBorder whiteDcAddonsBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: ColorTheme.whiteDC, width: 2),
  );
  static InputBorder searchInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: ColorTheme.foodValue),
  );
}
