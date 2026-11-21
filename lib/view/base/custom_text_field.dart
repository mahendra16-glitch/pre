import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final String? prefixIcon;
  final bool divider;
  final bool showTitle;
  final bool isAmount;
  final bool isNumber;
  final bool showShadow;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;

  const CustomTextField({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.divider = false,
    this.showTitle = false,
    this.isAmount = false,
    this.isNumber = false,
    this.showShadow = false,
    this.textStyle,
    this.hintTextStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Text(
            widget.hintText,
            style:
                poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
          ),
        if (widget.showTitle)
          const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        Container(
          decoration: widget.showShadow
              ? BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    )
                  ],
                )
              : null,
          child: TextField(
            maxLines: widget.maxLines,
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: widget.textStyle,
            textInputAction: widget.inputAction,
            keyboardType:
                widget.isAmount ? TextInputType.number : widget.inputType,
            cursorColor: Theme.of(context).primaryColor,
            textCapitalization: widget.capitalization,
            enabled: widget.isEnabled,
            autofocus: false,
            autofillHints: _getAutofillHints(widget.inputType),
            obscureText: widget.isPassword ? _obscureText : false,
            inputFormatters: _getInputFormatters(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              hintText: widget.hintText,
              fillColor: Theme.of(context).cardColor,
              hintStyle: widget.hintTextStyle,
              filled: true,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_SMALL),
                      child: Image.asset(widget.prefixIcon!,
                          height: 20, width: 20),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).hintColor.withOpacity(0.3),
                      ),
                      onPressed: _toggle,
                    )
                  : null,
            ),
            onSubmitted: (text) {
              if (widget.nextFocus != null) {
                FocusScope.of(context).requestFocus(widget.nextFocus);
              } else {
                widget.onSubmit?.call(text);
              }
            },
            onChanged: widget.onChanged,
          ),
        ),
        if (widget.divider)
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Divider(),
          ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  List<String>? _getAutofillHints(TextInputType type) {
    switch (type) {
      case TextInputType.name:
        return [AutofillHints.name];
      case TextInputType.emailAddress:
        return [AutofillHints.email];
      case TextInputType.phone:
        return [AutofillHints.telephoneNumber];
      case TextInputType.streetAddress:
        return [AutofillHints.fullStreetAddress];
      case TextInputType.url:
        return [AutofillHints.url];
      case TextInputType.visiblePassword:
        return [AutofillHints.password];
      default:
        return null;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputType == TextInputType.phone) {
      return [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))];
    } else if (widget.isAmount) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    } else if (widget.isNumber) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
    }
    return null;
  }
}
