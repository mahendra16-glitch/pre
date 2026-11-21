import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCartWidget extends StatelessWidget {
  final String? title;
  final bool? isShowNote;
  final Function? callFunction;
  final Function? callNotesFunction;

  const BottomCartWidget(
      {this.title,
      this.isShowNote = true,
      this.callFunction,
      this.callNotesFunction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          isShowNote! ? Divider() : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions
                  .PADDING_SIZE_EXTRA_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  InkWell(
                    onTap: callFunction != null ? () => callFunction!() : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                          vertical: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                          color: ColorTheme.appColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                      child: Text(
                        '$title',
                        style: poppinsMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  isShowNote!
                      ? InkWell(
                          onTap: callNotesFunction != null
                              ? () => callNotesFunction!()
                              : null,
                          child: Column(
                            children: [
                              Image.asset(
                                Images.add_notes,
                                height: 30,
                              ),
                              Text(
                                'Notes',
                                style: poppinsMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ]),
          ),
        ],
      ),
    );
  }
}
