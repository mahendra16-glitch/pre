import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class AddonsBottomTextField extends StatefulWidget {
  final String validatorText, hintText, labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const AddonsBottomTextField(
      {Key? key,
      required this.validatorText,
      this.keyboardType,
      this.controller,
      required this.hintText,
      this.labelText = '',
      this.inputFormatters})
      : super(key: key);

  @override
  State<AddonsBottomTextField> createState() =>
      _CustomAddonsBottomTextformFieldState();
}

class _CustomAddonsBottomTextformFieldState
    extends State<AddonsBottomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextFormField(
        validator: (value) {
          if (widget.validatorText.isNotEmpty &&
              (value == null || value == "")) {
            return widget.validatorText;
          }
          return null;
        },
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: montserratMedium.copyWith(
                fontSize: 14,
                color: ColorTheme.blackColor,
                fontWeight: FontWeight.w400),
            labelText: widget.labelText,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            labelStyle: montserratMedium.copyWith(
              fontSize: 14,
              color: ColorTheme.blackColor,
            ),
            errorBorder: AppBorder.categoryBorder
                .copyWith(borderSide: BorderSide(color: ColorTheme.redColor)),
            focusedErrorBorder: AppBorder.categoryBorder
                .copyWith(borderSide: BorderSide(color: ColorTheme.redColor)),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border: AppBorder.categoryBorder,
            enabledBorder: AppBorder.categoryBorder,
            focusedBorder: AppBorder.categoryBorder.copyWith(
                borderSide:
                    BorderSide(width: 1, color: ColorTheme.greenColor))),
      ),
    );
  }
}
