import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget uploadIconWidget({
  void Function()? onUploadTap,
  void Function()? onDownLoadTap,
  void Function()? onPlusTap,
  bool isPLusShow = false,
  bool isUpNotShow = true,
  bool isDownNotShow = true,
}) {
  return Row(
    children: [
      isDownNotShow == false
          ? SizedBox()
          : InkWell(
              customBorder: CircleBorder(),
              
              // radius: 50,
              onTap: onDownLoadTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(Images.export,
                    width: 25.7, color: ColorTheme.whiteE4),
              )),
      18.width,
      isUpNotShow == false
          ? SizedBox()
          : Container(
              height: 30,
              width: 1,
              color: ColorTheme.whiteDF,
            ),
      18.width,
      isUpNotShow == false
          ? SizedBox()
          : InkWell(
              customBorder: CircleBorder(),
              onTap: onUploadTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(right: 22),
                child: SvgPicture.asset(Images.upArrowIcon,
                    color: ColorTheme.whiteE4, width: 25.7),
              ),
            ),
      isPLusShow == true
          ? Padding(
              padding: const EdgeInsets.only(right: 15),
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: onPlusTap,
                child: SvgPicture.asset(
                  Images.add_icon,
                  width: 31.7,
                ),
              ),
            )
          : SizedBox(),
    ],
  );
}
