import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyCustomButton extends StatelessWidget {
  final String text;
  final Color? color;
  final double? width, vertical, horizontal, height;
  final TextStyle? style;
  final void Function()? onTap;
  final bool? isLoader;

  const MyCustomButton(
      {Key? key,
      this.onTap,
      required this.text,
      this.height,
      this.horizontal,
      this.color,
      this.isLoader = false,
      this.vertical,
      this.width,
      this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(
            vertical: vertical ?? 10, horizontal: horizontal ?? 0),
        decoration: BoxDecoration(
            color: color ?? ColorTheme.orangeFF7E27,
            borderRadius: BorderRadius.circular(30)),
        alignment: Alignment.center,
        child: isLoader == true
            ? Center(
                // child: CircularProgressIndicator.adaptive(
                //     backgroundColor: ColorTheme.whiteColor)
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 20.0,
                ),
              )
            : Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: style ?? AppStyle.orangeButtonStyle,
              ),
      ),
    );
  }
}
