import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class CustomSwitchWidget extends StatefulWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final String title;

  const CustomSwitchWidget(
      {Key? key, required this.value, this.onChanged, required this.title})
      : super(key: key);

  @override
  State<CustomSwitchWidget> createState() => _CustomSwitchWidgetState();
}

class _CustomSwitchWidgetState extends State<CustomSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ColorTheme.whiteDC, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Text(
              widget.title,
              style: AppStyle.txt14FoodValue,
            ),
          ),
          Transform.scale(
            alignment: Alignment.centerRight,
            scale: 0.6,
            child: Switch(
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return ColorTheme.greenColor;
                }

                return ColorTheme.greenColor;
              }),
              activeTrackColor: ColorTheme.whiteColor,
              inactiveTrackColor: ColorTheme.whiteColor,
              activeColor: ColorTheme.switchColor,
              inactiveThumbColor: ColorTheme.greenColor,
              value: widget.value,
              onChanged: widget.onChanged,
            ),
          )
        ],
      ),
    );
  }
}
