import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomEditableField extends StatefulWidget {
  TextEditingController? controller;
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
  String? totalFund;

  CustomEditableField({
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
    this.totalFund,
    this.keyboardType,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _CustomEditableFieldState createState() => _CustomEditableFieldState();
}

class _CustomEditableFieldState extends State<CustomEditableField> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 3),
          child: Container(
            // height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: ColorTheme.textFieldDEDEDE)),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IgnorePointer(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "₹${widget.totalFund.toString().split(".")[0]} ",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: CustomFonts.poppins,
                              fontWeight: FontWeight.w600,
                              color: ColorTheme.greenColor,
                            ),
                          ),
                          TextSpan(
                            text: "/ ₹ ",
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorTheme.secondGreyColor,
                              fontFamily: CustomFonts.poppins,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: TextFormField(
                    readOnly: widget.readOnly,
                    keyboardType: TextInputType.number,
                    cursorHeight: 15.0,
                    cursorColor: ColorTheme.secondGreyColor,
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    style: TextStyle(
                        color: ColorTheme.secondGreyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(
                            color: ColorTheme.secondGreyColor,
                            fontSize: 13,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none),
                  ))
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 10),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Text(
                widget.labelText,
                style: TextStyle(color: ColorTheme.hintText, fontSize: 9),
              ),
            ),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: Color(0xffDEDEDE)),
  );
}
