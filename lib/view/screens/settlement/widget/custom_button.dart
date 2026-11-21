import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final Color? boxColor, textColor, loaderColor;
  final double? width;
  final Function()? onTap;
  final bool? isLoader;
  const MyButton(
      {Key? key,
      required this.text,
      this.boxColor,
      this.loaderColor,
      this.width,
      this.textColor,
      this.isLoader = false,
      this.onTap})
      : super(key: key);

  @override
  State<MyButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<MyButton> {
  bool isCreate = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.onTap == null) {
          return;
        }
        isCreate = true;
        await widget.onTap!();
        isCreate = false;
      },
      child: Container(
        height: 45,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          color: widget.boxColor ?? ColorTheme.whiteEFEFEF,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: isCreate == true
            ? Center(
                child: CircularProgressIndicator(color: widget.loaderColor))
            : Text(widget.text ?? "",
                style: MyTextStyle.greenW60018.copyWith(
                    color: widget.textColor ?? ColorTheme.secondGreyColor,
                    fontSize: 13)),
      ),
    );
  }
}
