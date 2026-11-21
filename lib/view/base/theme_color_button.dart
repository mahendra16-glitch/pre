import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';

class ThemeColorButton extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback? onTap;
  final double? horizontalPadding;
  final double? editPadding;
  final double? varticalPadding;

  const ThemeColorButton({
    super.key,
    required this.title,
    this.color,
    this.onTap,
    this.horizontalPadding,
    this.editPadding,
    this.varticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: 35,
        padding: EdgeInsets.symmetric(
          horizontal:
              title == 'Edit' ? (editPadding ?? 25) : (horizontalPadding ?? 0),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: title == 'Edit' ? ColorTheme.borderGrey : Colors.transparent,
          ),
          color:
              color ?? (title == 'Edit' ? Colors.white : ColorTheme.appColor),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            title,
            style: poppinsMedium.copyWith(
              fontSize: 13,
              color: title == 'Edit' ? ColorTheme.appColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
