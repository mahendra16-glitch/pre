import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
            backgroundColor: ColorTheme.whiteColor,
            color: ColorTheme.greenColor));
  }
}
