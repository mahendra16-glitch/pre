import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class SheetDropDown extends StatefulWidget {
  final String hinText;
  final List<String> list;
  final String? value;
  final void Function(String?)? onChanged;

  const SheetDropDown(
      {Key? key,
      required this.hinText,
      required this.list,
      this.onChanged,
      this.value})
      : super(key: key);

  @override
  State<SheetDropDown> createState() => _SheetDropDownState();
}

class _SheetDropDownState extends State<SheetDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.grey.withOpacity(.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(12),
          dropdownColor: ColorTheme.whiteColor,
          value: widget.value,
          isExpanded: true,
          hint: Text(widget.hinText, style: AppStyle.txt14FoodValue),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorTheme.grey.withOpacity(.5),
          ),
          items: [
            ...widget.list.map<DropdownMenuItem<String>>(
              (e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e.toString(),
                    style: AppStyle.txt14FoodValue
                        .copyWith(color: ColorTheme.foodValue.withOpacity(.8)),
                  ),
                );
              },
            ).toList(),
          ],
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
