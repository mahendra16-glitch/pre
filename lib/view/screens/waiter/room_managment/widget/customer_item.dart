import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomCustomerItem extends StatelessWidget {
  final int? i;
  TextEditingController? controller;
  RoomCustomerItem({this.i, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: i == 0 ? 0 : 13),
      child: Container(
        padding: EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
            color: Color.fromRGBO(248, 248, 248, 1.0)),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${Get.find<PosController>().roomListWithAmount[i!].roomName}',
                style: poppinsMedium.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 13
                        : Dimensions.FONT_SIZE_EXTRA_SMALL),
                // maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Expanded(
            //   flex: 3,
            //   child: Text(
            //     '${Get.find<PosController>().tapManagmentCustomerListResponse.employeeTapList[i].email}',
            //     style: poppinsMedium.copyWith(
            //         fontSize: MediaQuery.of(context).size.shortestSide > 570
            //             ? 13
            //             : Dimensions.FONT_SIZE_EXTRA_SMALL),
            //     // maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            // Expanded(
            //   flex: 2,
            //   child: Text(
            //     '${Get.find<PosController>().tapManagmentCustomerListResponse.employeeTapList[i].name}',
            //     style: poppinsMedium.copyWith(
            //         fontSize: MediaQuery.of(context).size.shortestSide > 570
            //             ? 13
            //             : Dimensions.FONT_SIZE_EXTRA_SMALL),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            Expanded(
              child: Text(
                  double.parse(
                          '${Get.find<PosController>().roomListWithAmount[i!].orderAmount}')
                      .toStringAsFixed(2),
                  style: poppinsMedium.copyWith(
                      color: Color.fromRGBO(128, 76, 25, 1.0),
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 14
                          : Dimensions.FONT_SIZE_SMALL)),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                // Get.find<PosController>().setTapCustomerData(i);
                // controller.text = '0';
                MediaQuery.of(context).size.shortestSide > 570
                    ? Get.toNamed(RouteHelper.getTabletViewTabBills(
                        '${Get.find<PosController>().tapManagmentCustomerListResponse?.employeeTapList[i!].id}',
                        '${Get.find<PosController>().tapManagmentCustomerListResponse?.employeeTapList[i!].name ?? ''}',
                        '${Get.find<PosController>().tapManagmentCustomerListResponse?.employeeTapList[i!].mobile ?? ''}'))
                    : Get.toNamed(RouteHelper.getViewRoomBills(
                        '${Get.find<PosController>().roomListWithAmount[i!].roomId}',
                        '${Get.find<PosController>().roomListWithAmount[i!].roomName ?? ''}',
                      ));
              },
              child: Container(
                margin: EdgeInsets.only(left: 7),
                padding: EdgeInsets.symmetric(
                    vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                    horizontal: 13),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Get.find<PosController>().selectedCustomerIndex == i
                        ? Color.fromRGBO(217, 156, 123, 1.0)
                        : ColorTheme.appColor,
                    // border:
                    //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                child: Center(
                  child: Text(
                    'Bills',
                    style: poppinsRegular.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : Dimensions.FONT_SIZE_EXTRA_SMALL,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Get.find<PosController>().setTapCustomerData(i, true);
                controller?.text = '0';
              },
              child: Container(
                margin: EdgeInsets.only(left: 7),
                padding: EdgeInsets.symmetric(
                    vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                    horizontal: 13),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Get.find<PosController>().selectedCustomerIndex == i
                        ? Color.fromRGBO(217, 156, 123, 1.0)
                        : ColorTheme.appColor,
                    // border:
                    //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                child: Center(
                  child: Text(
                    'Pay'.tr,
                    style: poppinsRegular.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : Dimensions.FONT_SIZE_EXTRA_SMALL,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
