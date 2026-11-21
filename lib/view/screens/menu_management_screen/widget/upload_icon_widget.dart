import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget uploadIconWidget(
    {void Function()? onUploadTap,
    void Function()? onDownLoadTap,
    void Function()? onPlusTap,
    bool isPLusShow = false,
    bool isUpNotShow = true}) {
  return Row(
    children: [
      GestureDetector(
        onTap: onDownLoadTap,
        child: SvgPicture.asset(Images.export,
            color: ColorTheme.whiteE4, width: 25.7),
      ),
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
          : GestureDetector(
              onTap: onUploadTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 22),
                child: SvgPicture.asset(Images.import,
                    color: ColorTheme.whiteE4, width: 25.7),
              ),
            ),
      isPLusShow == true
          ? Padding(
              padding: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: onPlusTap,
                child: SvgPicture.asset(
                  Images.add_icon,
                  color: Colors.deepOrangeAccent,
                  width: 31.7,
                ),
              ),
            )
          : SizedBox(),
    ],
  );
}
