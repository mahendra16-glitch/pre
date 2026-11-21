import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? color;
  final IconData? icon;
  final double radius;

  const CustomButton({
    Key? key,
    required this.buttonText,
    this.onPressed,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.color,
    this.icon,
    this.radius = Dimensions.RADIUS_SMALL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null
          ? Theme.of(context).disabledColor
          : transparent
              ? Colors.transparent
              : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(
        width ?? 1170,
        height ?? (MediaQuery.of(context).size.shortestSide > 570 ? 55 : 45),
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextButton(
        onPressed: onPressed,
        style: flatButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: transparent
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
              ),
            if (icon != null) SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
            Text(
              buttonText,
              textAlign: TextAlign.center,
              style: poppinsMedium.copyWith(
                color: buttonText == 'No' ? Colors.black : Colors.white,
                fontSize: fontSize ??
                    (MediaQuery.of(context).size.shortestSide > 570 ? 17 : 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
