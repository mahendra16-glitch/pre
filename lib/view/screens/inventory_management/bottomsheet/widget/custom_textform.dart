import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class SheetCustomTextform extends StatelessWidget {
  final TextEditingController controller;
  final String hinText;
  final TextInputType? keyboardType;

  const SheetCustomTextform(
      {Key? key,
      required this.controller,
      required this.hinText,
      this.keyboardType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppStyle.txt14FoodValue,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        hintText: hinText,
        hintStyle: AppStyle.stockListStyle
            .copyWith(color: ColorTheme.grey.withOpacity(.5)),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: AppBorder.categoryBorder,
        enabledBorder: AppBorder.categoryBorder,
        focusedBorder:
            AppBorder.categoryBorder.copyWith(borderSide: BorderSide(width: 2)),
      ),
    );
  }
}
