import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownWidget extends StatefulWidget {
  final String? value, hintText;
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
      this.items})
      : super(key: key);

  @override
  State<CustomDropdownWidget> createState() => _CustomDropdownWidgetState();
}

class _CustomDropdownWidgetState extends State<CustomDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50,
        width: widget.width,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
          border: widget.border ??
              Border.all(color: ColorTheme.whiteDC.withOpacity(.6), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Flexible(
                child: DropdownButton<String>(
                  dropdownColor: ColorTheme.whiteColor,
                  isExpanded: true,
                  underline: SizedBox.shrink(),
                  value: widget.value,
                  items: widget.items,
                  onChanged: widget.onChanged == null ? null : widget.onChanged,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.all(Radius.circular(15)),
                  hint: Text(widget.hintText ?? "",
                      style: AppStyle.txt14FoodValue.copyWith(
                          fontSize: 12,
                          color: ColorTheme.foodValue.withOpacity(.8))),
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.arrow_drop_down_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
