import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final bool? leadingValue;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leadingWidget;
  final Widget? titleWidget;

  // Constructor

  const CustomAppBar({
    Key? key,
    this.actions,
    this.centerTitle = false,
    required this.titleText,
    this.leadingWidget,
    this.titleWidget,
    this.leadingValue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTheme.whiteColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: centerTitle,
      titleSpacing: 0,
      title: titleWidget != null
          ? titleWidget
          : Text(
              titleText,
              style: AppStyle.stockListStyle
                  .copyWith(color: ColorTheme.blackColor, fontSize: 16),
            ),
      leading: leadingWidget != null
          ? leadingWidget
          : IconButton(
              icon: Icon(Icons.arrow_back_ios, color: ColorTheme.green),
              onPressed: () => Get.back(),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
