import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class SignInTextField extends StatefulWidget {
  final String hintText;
  final TextCapitalization capitalization;
  final TextEditingController controller;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final bool isPassword;
  final void Function(String)? onSubmit;
  final void Function(String)? onChanged;
  final TextInputAction? inputAction;
  final IconData? icon;

  const SignInTextField({
    Key? key,
    required this.hintText,
    this.capitalization = TextCapitalization.none,
    required this.inputType,
    this.isPassword = false,
    this.focusNode,
    this.nextFocus,
    required this.controller,
    this.onSubmit,
    this.onChanged,
    this.inputAction,
    this.icon,
  }) : super(key: key);

  @override
  State<SignInTextField> createState() => _SignInTextFieldState();
}

class _SignInTextFieldState extends State<SignInTextField> {
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 570;
    final fontSize = isTablet ? 16.0 : 13.0;

    return SizedBox(
      height: 36,
      child: TextField(
        focusNode: widget.focusNode,
        controller: widget.controller,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: widget.inputType,
        textCapitalization: widget.capitalization,
        textInputAction: widget.inputAction,
        obscureText: widget.isPassword ? _obscureText : false,
        cursorColor: ColorTheme.appColor,
        style: poppinsMedium.copyWith(fontSize: fontSize),
        autofillHints: _getAutofillHints(),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: poppinsMedium.copyWith(
            fontSize: fontSize,
            color: ColorTheme.hintText,
          ),
          contentPadding:
              const EdgeInsets.only(left: Dimensions.PADDING_SIZE_LARGE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: ColorTheme.borderGrey,
              width: 1,
            ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: ColorTheme.hintText,
                  ),
                  onPressed: _toggle,
                )
              : (widget.icon != null
                  ? Icon(
                      widget.icon,
                      size: 20,
                      color: const Color(0xFFAFA9A9),
                    )
                  : null),
        ),
        onChanged: widget.onChanged,
        onSubmitted: (text) {
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          } else {
            widget.onSubmit?.call(text);
          }
        },
      ),
    );
  }

  List<String>? _getAutofillHints() {
    if (widget.inputType == TextInputType.emailAddress) {
      return [AutofillHints.email];
    } else if (widget.inputType == TextInputType.visiblePassword) {
      return [AutofillHints.password];
    }
    return null;
  }
}
