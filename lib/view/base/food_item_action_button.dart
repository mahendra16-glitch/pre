import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';

class FoodButton extends StatelessWidget {
  final String title;
  final bool isDisable;
  final VoidCallback? onTap;

  const FoodButton({
    super.key,
    required this.title,
    this.isDisable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: isDisable ? null : onTap,
      child: Container(
        height: 35,
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisable
                ? ColorTheme.disableButtonText
                : title == 'Cancel'
                    ? ColorTheme.borderGrey
                    : Colors.transparent,
          ),
          color: isDisable
              ? Colors.transparent
              : title == 'Cancel'
                  ? Colors.white
                  : ColorTheme.appColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            title,
            style: poppinsMedium.copyWith(
              fontSize: 13,
              color: isDisable
                  ? ColorTheme.disableButtonText
                  : title == 'Cancel'
                      ? ColorTheme.appColor
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
