import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class CustomTextformField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? errorStyle;
  final Color? fillColor;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final InputBorder? formBorder;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool? enabled;
  final String? suffixText;
  const CustomTextformField(
      {Key? key,
      this.controller,
      this.onChanged,
      this.validator,
      this.suffixIcon,
      this.fillColor,
      this.focusedErrorBorder,
      this.errorStyle,
      this.errorBorder,
      this.onTap,
      required this.labelText,
      this.inputFormatters,
      this.formBorder,
      this.autovalidateMode,
      this.keyboardType,
      this.readOnly = false,
      this.focusNode,
      this.suffixText,
      this.enabled = true})
      : super(key: key);

  @override
  State<CustomTextformField> createState() => _CustomTextformFieldState();
}

class _CustomTextformFieldState extends State<CustomTextformField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // enabled: widget.enabled,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      keyboardType: widget.keyboardType ?? TextInputType.name,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon,
        suffixText: widget.suffixText,
        labelText: widget.labelText,
        errorStyle: widget.errorStyle,
        labelStyle: AppStyle.txt14FoodValue,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        enabledBorder: widget.formBorder ?? border,
        focusedBorder: widget.formBorder ?? border,
        disabledBorder: widget.formBorder ?? border,
        errorBorder: widget.formBorder ?? widget.errorBorder,
        focusedErrorBorder: widget.formBorder ?? widget.focusedErrorBorder,
        border: widget.formBorder ?? border,
        suffixStyle: montserratMedium.copyWith(
            // fontFamily: "Montserrat",
            fontSize: 12,
            color: ColorTheme.grey74),
        hintStyle: montserratMedium.copyWith(
            // fontFamily: "Montserrat",
            fontSize: MediaQuery.of(context).size.width * 0.018,
            color: ColorTheme.grey74),
        filled: true,
        fillColor: widget.fillColor ?? ColorTheme.whiteColor,
      ),
      style: montserratMedium.copyWith(
        color: ColorTheme.grey74,
        fontSize: 14,
      ),
    );
  }

  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: ColorTheme.whiteDC),
  );
}
