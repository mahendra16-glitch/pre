import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownWidget extends StatefulWidget {
  final String? value, hintText, labelText;
  final void Function(String?)? onChanged;
  final List<DropdownMenuItem<String>>? items;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Color? color;
  final double? width;

  const CustomDropdownWidget(
      {Key? key,
      required this.value,
      this.color,
      this.onChanged,
      this.borderRadius,
      this.border,
      this.width,
      required this.hintText,
      this.labelText,
      this.items})
      : super(key: key);

  @override
  State<CustomDropdownWidget> createState() => _CustomDropdownWidgetState();
}

class _CustomDropdownWidgetState extends State<CustomDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField2<String>(
        isExpanded: true,
        value: widget.value,
        items: widget.items,
        onChanged: widget.onChanged == null ? null : widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: AppStyle.txt14FoodValue.copyWith(
            fontSize: 13,
            color: ColorTheme.foodValue.withOpacity(.8),
          ),
          hintText: widget.hintText,
          hintStyle: AppStyle.txt14FoodValue.copyWith(
            fontSize: 12,
            color: ColorTheme.foodValue.withOpacity(.8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
          filled: true,
          fillColor: widget.color,
          border: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
            borderSide: BorderSide(
              color: ColorTheme.whiteDC.withOpacity(.6),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
            borderSide: BorderSide(
              color: ColorTheme.whiteDC.withOpacity(.6),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
            borderSide: BorderSide(
              color: ColorTheme.whiteDC.withOpacity(.6),
              width: 2,
            ),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_drop_down_rounded),
          iconSize: 20,
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius:
                widget.borderRadius ?? BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
