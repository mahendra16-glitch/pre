import 'dart:io';

import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class DocumentView extends StatelessWidget {
  File img;
  DocumentView(this.img);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Get.height / 10.72,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Image.asset(Images.ic_arrow_back, height: 20),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            MediaQuery.of(context).size.shortestSide > 570
                ? Image.asset(
                    logoHelper.appLogo!,
                    height: Get.height / 10.72,
                  )
                : Image.asset(
                    logoHelper.appLogo!,
                    width: Get.width * 0.5,
                  ),
          ],
        ),
      ),
      body: Container(
          child: PhotoView(
        imageProvider: FileImage(img),
      )),
    );
  }
}
