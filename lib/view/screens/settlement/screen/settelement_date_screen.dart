import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/update_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/settlement_restaurant_model.dart';

class SettlementDateScreen extends StatefulWidget {
  final List<Waiter>? waiters;
  const SettlementDateScreen({Key? key, this.waiters}) : super(key: key);

  @override
  State<SettlementDateScreen> createState() => _SettlementDateScreenState();
}

class _SettlementDateScreenState extends State<SettlementDateScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorTheme.settlementBgColor,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.chevron_left_outlined,
                  color: ColorTheme.appColor, size: 36),
              color: ColorTheme.appColor,
              onPressed: () {
                Get.back();
              }),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Settlement", style: MyTextStyle.greenW60018),
              Row(
                children: [
                  Text("Today",
                      style: MyTextStyle.blueColor12W500
                          .copyWith(fontWeight: FontWeight.w600)),
                  5.width,
                  Container(color: ColorTheme.greyDFDFDF, width: 2, height: 13),
                  5.width,
                  Text(widget.waiters?.last.date.toString().split(" ")[0] ?? "",
                      style: MyTextStyle.blueColor12W500.copyWith(
                          color: ColorTheme.black2E,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              width: 88,
              height: 36,
              decoration: BoxDecoration(
                color: ColorTheme.green,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Text("Settle All",
                  style: MyTextStyle.greenW60018
                      .copyWith(color: ColorTheme.whiteColor, fontSize: 13)),
            ),
            20.width,
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                "assets/image/export.png",
                height: 22,
                width: 22,
                color: ColorTheme.secondGreyColor,
              ).paddingOnly(right: 20),
            )
          ],
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorTheme.whiteColor,
                  ),
                  child: ListView.builder(
                    itemCount: widget.waiters?.length ?? 0,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => UpdateBalanceCard(
                      waiter: widget.waiters?[index],
                    ),
                  )).paddingSymmetric(horizontal: 20),
            ],
          ).paddingOnly(top: 25),
        ),
      ),
    );
  }
}
