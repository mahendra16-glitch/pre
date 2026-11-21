import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart'
    show SettlementManagementController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/settlement_restaurant_model.dart';
import '../screen/settelement_date_screen.dart';

class SettlementDetailsWidget extends StatefulWidget {
  final SettleMentData? settleMentData;
  final Function()? indexUpdateAction;
  final int? index;

  SettlementDetailsWidget(
      {Key? key, this.settleMentData, this.indexUpdateAction, this.index})
      : super(key: key);

  @override
  State<SettlementDetailsWidget> createState() =>
      _SettlementDetailsWidgetState();
}

class _SettlementDetailsWidgetState extends State<SettlementDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ColorTheme.greyDFDFDF)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 7),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Get.to(() => SettlementDateScreen(
                              //     waiters:
                              //         widget.settleMentData?.waiters ?? []));
                            },
                            child: Container(
                              width: 108,
                              child: Row(
                                children: [
                                  Text(
                                      widget.settleMentData?.date
                                              .toString()
                                              .split(" ")[0] ??
                                          "03 Mar 2025",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyTextStyle.grey12W600
                                          .copyWith(fontSize: 13)),
                                  5.width,
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: ColorTheme.blueColor,
                                    size: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                          5.height,
                          Container(
                            width: 120,
                            child: Text("Opening Bal.",
                                overflow: TextOverflow.ellipsis,
                                style: MyTextStyle.blueColor12W500.copyWith(
                                    color: ColorTheme.borderGrey,
                                    fontSize: 11)),
                          ),
                          5.height,
                          Text(
                              "₹${widget.settleMentData?.totals?.totalOpeningBalance}",
                              style: MyTextStyle.greenW60018
                                  .copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(color: ColorTheme.greyDFDFDF)),
                ),
                child: Text("₹${widget.settleMentData?.totals?.lastDayPending}",
                    style: MyTextStyle.greenW60018.copyWith(fontSize: 14)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: ColorTheme.green),
                    child: Icon(
                      Icons.check,
                      color: ColorTheme.whiteColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.indexUpdateAction,
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ColorTheme.whiteColor),
                      child: Icon(
                        widget.settleMentData?.isShowWaiter == true
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down_rounded,
                        color: ColorTheme.blueColor,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
    ;
  }
}
