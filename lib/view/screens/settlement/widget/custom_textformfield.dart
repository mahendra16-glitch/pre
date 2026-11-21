import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  const CustomTextformField({
    Key? key,
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
  }) : super(key: key);

  @override
  State<CustomTextformField> createState() => _CustomTextformFieldState();
}

class _CustomTextformFieldState extends State<CustomTextformField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        autovalidateMode: widget.autovalidateMode,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        maxLines: 1,
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        keyboardType: widget.keyboardType ?? TextInputType.name,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            labelText: widget.labelText,
            errorStyle: widget.errorStyle,
            labelStyle: TextStyle(color: ColorTheme.hintText, fontSize: 13),
            floatingLabelAlignment: FloatingLabelAlignment.start,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            enabledBorder: widget.formBorder ?? border,
            focusedBorder: widget.formBorder ?? border,
            disabledBorder: widget.formBorder ?? border,
            errorBorder: widget.formBorder ?? widget.errorBorder,
            focusedErrorBorder: widget.formBorder ?? widget.focusedErrorBorder,
            border: widget.formBorder ?? border,
            hintStyle: TextStyle(fontSize: 10),
            filled: true,
            fillColor: widget.fillColor),
        style: AppStyle.txt14FoodValue);
  }

  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Color(0xffDEDEDE)),
  );
}
