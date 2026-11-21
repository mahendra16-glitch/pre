import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final bool? isIncrement;
  final bool isFromBottomSheet;
  final VoidCallback? onTap;
  QuantityButton(
      {required this.isIncrement,
      this.isFromBottomSheet = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // height: MediaQuery.of(context).size.shortestSide > 1600
        //     ? isFromBottomSheet
        //         ? 60
        //         : 40
        //     : MediaQuery.of(context).size.shortestSide > 570
        //         ? isFromBottomSheet
        //             ? 40
        //             : 29
        //         : isFromBottomSheet
        //             ? 30
        //             : 25,
        // width: MediaQuery.of(context).size.shortestSide > 1600
        //     ? isFromBottomSheet
        //         ? 60
        //         : 40
        //     : MediaQuery.of(context).size.shortestSide > 570
        //         ? isFromBottomSheet
        //             ? 40
        //             : 29
        //         : isFromBottomSheet
        //             ? 30
        //             : 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 1,
            color: ColorTheme.borderGrey,
          ),
          color: Color(0xFFF9F9F9),
        ),
        alignment: Alignment.center,
        child: Icon(
          isIncrement! ? Icons.add : Icons.remove,
          size: MediaQuery.of(context).size.shortestSide > 570
              ? isFromBottomSheet
                  ? 30
                  : 26
              : isFromBottomSheet
                  ? 30
                  : 20,
          color: ColorTheme.appColor,
        ),
      ),
    );
  }
}
