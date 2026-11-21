import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/bottom_sheet/update_balance_sheet.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_editable_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/settlement_restaurant_model.dart';
import 'custom_button.dart';
import 'custom_divider.dart';
import 'custom_textformfield.dart';

class UpdateBalanceCard extends StatefulWidget {
  final Waiter? waiter;
  const UpdateBalanceCard({Key? key, this.waiter}) : super(key: key);

  @override
  State<UpdateBalanceCard> createState() => _UpdateBalanceCardState();
}

class _UpdateBalanceCardState extends State<UpdateBalanceCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.waiter?.fullName ?? "",
                    style: MyTextStyle.grey12W600
                        .copyWith(fontSize: 15, color: ColorTheme.hintText)),
                7.width,
                Row(
                  children: [
                    Text("Closed Balance",
                        style: MyTextStyle.blueColor12W500.copyWith(
                            color: ColorTheme.borderGrey, fontSize: 11)),
                    10.width,
                    Text("₹${widget.waiter?.lastDayPending}",
                        style: MyTextStyle.greenW60018
                            .copyWith(fontSize: 14, color: ColorTheme.black2E)),
                  ],
                ),
              ],
            ),
            15.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomTextformField(labelText: 'Opening Balance'),
                ),
                10.width,
                Expanded(
                    child: CustomEditableField(
                        readOnly: widget.waiter?.balanceToSettle == "0.00"
                            ? true
                            : false,
                        totalFund: widget.waiter?.balanceToSettle ?? "",
                        labelText: "Current Balance"))
              ],
            ),
            15.height,
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    onTap: () {},
                    text: "Update Balance",
                    textColor: ColorTheme.borderGrey,
                  ),
                ),
                Expanded(child: Container())
              ],
            ),
          ],
        ).paddingOnly(top: 15, left: 15, right: 15),
        15.height,
        customDivider(),
        15.height,
      ],
    );
  }
}
