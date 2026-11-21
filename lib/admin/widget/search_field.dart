import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

import '../constant/app_border.dart';
import '../constant/app_style.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hitText;
  final void Function(String)? onChanged;
  const CustomSearchField(
      {Key? key,
      required this.controller,
      required this.hitText,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      showCursor: true,
      controller: controller,
      cursorColor: ColorTheme.greyBE,
      cursorHeight: 15.0,
      cursorRadius: Radius.circular(10),
      cursorWidth: 2.0,
      decoration: InputDecoration(
        fillColor: ColorTheme.whiteColor,
        filled: true,
        hintText: hitText,
        prefixIcon: Icon(Icons.search, color: ColorTheme.greyBE),
        hintStyle: AppStyle.searchTextStyle,
        border: AppBorder.menuSearchBorder.copyWith(
            borderSide: BorderSide(width: 2, color: ColorTheme.transparent)),
        enabledBorder: AppBorder.menuSearchBorder.copyWith(
            borderSide: BorderSide(width: 2, color: ColorTheme.transparent)),
        focusedBorder: AppBorder.menuSearchBorder
            .copyWith(borderSide: BorderSide(color: ColorTheme.transparent)),
      ),
      style: AppStyle.searchTextStyle,
    );
  }
}
