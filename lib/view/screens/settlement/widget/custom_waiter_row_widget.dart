import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:flutter/material.dart';
import '../model/waiter_model.dart';
import 'custom_textformfield.dart';

class CustomWaiterRowWidget extends StatefulWidget {
  final WaiterData? waiterData;
  final Function(bool val)? onChange;
  final TextEditingController? controller;
  const CustomWaiterRowWidget({
    Key? key,
    this.controller,
    this.waiterData,
    this.onChange,
  }) : super(key: key);

  @override
  State<CustomWaiterRowWidget> createState() => _CustomWaiterRowWidgetState();
}

class _CustomWaiterRowWidgetState extends State<CustomWaiterRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 184,
          child: Row(
            children: [
              Checkbox(
                value: widget.waiterData?.isChecked,
                onChanged: (bool? value) {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                side: WidgetStateBorderSide.resolveWith(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return BorderSide(color: ColorTheme.blueColor, width: 2.5);
                  }
                  return BorderSide(color: ColorTheme.borderGrey, width: 2.5);
                }),
                fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return ColorTheme.transparent;
                  }
                  return ColorTheme.whiteColor;
                }),
                checkColor: widget.waiterData?.isChecked == true
                    ? ColorTheme.blueColor
                    : ColorTheme.whiteColor,
              ),
              Expanded(
                child: Text(
                    widget.waiterData?.name == null
                        ? "-"
                        : widget.waiterData?.name ?? "",
                    maxLines: 1,
                    style: MyTextStyle.grey12W600.copyWith(fontSize: 14)),
              ),
            ],
          ),
        ),
        5.width,
        Flexible(
          flex: 2,
          child: CustomTextformField(
            keyboardType: TextInputType.number,
            onChanged: (p0) {
              if (p0 == "") {
                widget.onChange!(false);
              } else {
                widget.onChange!(true);
              }

              setState(() {});
            },
            labelText: 'Opening Balance',
            controller: widget.controller,
          ),
        )
      ],
    );
  }
}
