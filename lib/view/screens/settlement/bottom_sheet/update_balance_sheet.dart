import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/model/settlement_restaurant_model.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_button.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_waiter_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void updateBalanceSheet(BuildContext context,
    {Waiter? waiter,
    void Function()? onTap,
    SettlementManagementController? controller}) {
  controller?.getWaiterTextControllerList.clear();
  controller?.getWaiterTextControllerList = List.generate(
    (controller.waiterModel?.data?.length ?? 0),
    (index) => TextEditingController(text: ""),
  );
  controller?.waiterModel?.data?.any(
    (element) => element.isChecked = false,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    builder: (context) {
      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today", style: MyTextStyle.blueColor12W500),
                        IconButton(
                          icon: Icon(Icons.close, color: ColorTheme.grey),
                          onPressed: () {
                            // Get.back();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20),
                  ),
                  Row(
                    children: [
                      Text(waiter?.date.toString().split(' ')[0] ?? "",
                          style: MyTextStyle.blueColor12W500.copyWith(
                              color: ColorTheme.black5F6368,
                              fontWeight: FontWeight.w600)),
                      3.width,
                      Icon(Icons.arrow_forward_ios,
                          color: ColorTheme.blueColor, size: 15)
                    ],
                  ).paddingSymmetric(horizontal: 20),
                  15.height,
                  Container(height: 0.5, color: ColorTheme.grey),
                  15.height,
                  Container(
                    // height: 350,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller?.waiterModel?.data?.length ?? 0,
                      itemBuilder: (context, index) =>
                          controller?.waiterModel?.data?[index].id ==
                                  waiter?.waiterId
                              ? CustomWaiterRowWidget(
                                      onChange: (val) {
                                        controller?.waiterModel?.data?[index]
                                            .isChecked = val;
                                        controller?.update();
                                      },
                                      controller: controller
                                          ?.getWaiterTextControllerList[index],
                                      waiterData:
                                          controller?.waiterModel?.data?[index])
                                  .paddingSymmetric(horizontal: 10)
                              : SizedBox.shrink(),
                      separatorBuilder: (BuildContext context, int index) {
                        return 0.height;
                      },
                    ),
                  ),
                  12.height,
                  GetBuilder<SettlementManagementController>(
                    builder: (controller) {
                      bool isAnyChecked = controller.waiterModel?.data
                              ?.any((element) => element.isChecked == true) ??
                          false;

                      return MyButton(
                        loaderColor: ColorTheme.whiteColor,
                        textColor: isAnyChecked
                            ? ColorTheme.whiteColor
                            : ColorTheme.secondGreyColor,
                        text: 'Update Balance',
                        onTap: onTap,
                        isLoader: controller.isAddWaiterOpeningBalanceLoader,
                        boxColor: isAnyChecked
                            ? ColorTheme.greenColor
                            : ColorTheme.whiteE7,
                      ).paddingSymmetric(horizontal: 25);
                    },
                  ),
                  12.height,
                ],
              ).paddingOnly(top: 15),
            ),
          ),
        ),
      );
    },
  );
}
