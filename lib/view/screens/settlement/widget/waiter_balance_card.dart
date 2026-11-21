import 'dart:developer';

import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settlement/bottom_sheet/update_balance_sheet.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/model/settlement_restaurant_model.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_editable_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'custom_button.dart';
import 'custom_divider.dart';
import 'opening_balance.dart';

class WaiterBalanceCard extends StatefulWidget {
  final bool? isShowEditIcon;
  final Waiter? waiter;
  final int? index;
  final TextEditingController? textEditingController;
  final TextEditingController? expectedBalanceController;
  final SettlementManagementController controller;

  final void Function()? fullBalanceOnPress, partBalanceOnPress;
  const WaiterBalanceCard(
      {Key? key,
      this.isShowEditIcon = false,
      this.index,
      this.waiter,
      required this.controller,
      this.textEditingController,
      this.expectedBalanceController,
      this.fullBalanceOnPress,
      this.partBalanceOnPress})
      : super(key: key);

  @override
  State<WaiterBalanceCard> createState() => _WaiterBalanceCardState();
}

class _WaiterBalanceCardState extends State<WaiterBalanceCard> {
  List<String> paymentModeList = [
    AppString.cashTips,
    AppString.uPITips,
    AppString.cardTips,
    AppString.serviceCharge,
    AppString.deliveryCharges
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.waiter?.isShowRevenue =
                      !(widget.waiter!.isShowRevenue ?? false);

                  setState(() {});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // width: 60,
                      child: Text(widget.waiter?.fullName ?? "Waiter Name...",
                          style:
                              MyTextStyle.grey12W600.copyWith(fontSize: 11.5)),
                    ),
                    Row(
                      children: [
                        Text('Revenue',
                            style: MyTextStyle.blueColor12W500.copyWith(
                                color: ColorTheme.borderGrey, fontSize: 12)),
                        5.width,
                        Icon(
                          widget.waiter?.isShowRevenue == true
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down_rounded,
                          color: ColorTheme.blueColor,
                          size: 20,
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(AppString.tips,
                            style: MyTextStyle.blueColor12W500.copyWith(
                                color: ColorTheme.borderGrey, fontSize: 10)),
                        5.width,
                        Text("₹${widget.waiter?.todayTips}",
                            style: MyTextStyle.blueColor12W500.copyWith(
                                color: ColorTheme.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10)),
                        Icon(
                          widget.waiter?.isShowPaymentMode == true
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down_rounded,
                          color: ColorTheme.blueColor,
                          size: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            7.width,
            widget.isShowEditIcon == true
                ? Builder(
                    builder: (context) {
                      bool isEnabled = (widget
                                      .controller
                                      .settlementRestaurantModel
                                      ?.totals
                                      ?.settlementStatus ??
                                  0) ==
                              0 &&
                          !widget.controller.isSettlementLoader &&
                          !widget.controller.isSelfSettleLoader &&
                          !widget
                              .controller.isAddWaiterOpeningBalanceSubmitting;
                      return MouseRegion(
                        cursor: isEnabled
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.forbidden,
                        child: GestureDetector(
                          onTap: isEnabled
                              ? () {
                                  updateBalanceSheet(
                                    context,
                                    waiter: widget.waiter,
                                    controller: widget.controller,
                                    onTap: () async {
                                      await widget.controller
                                          .addWaiterOpeningBalance(
                                              date: widget.waiter?.date
                                                  .toString()
                                                  .split(' ')[0],
                                              waiter: widget.waiter,
                                              index: widget.index);
                                    },
                                  );
                                }
                              : null,
                          child: Opacity(
                            opacity: isEnabled ? 1.0 : 0.5,
                            child: SvgPicture.asset(
                              Images.edit_icon,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : SizedBox(),
            7.width,
            openingClosingBalance(
                color: ColorTheme.black2E,
                text: "Opening Bal.",
                openingBalance: "₹${widget.waiter?.openingBalance}"),
            7.width,
            openingClosingBalance(
                color: ColorTheme.black2E,
                text: "Closing Bal.",
                openingBalance: "₹${widget.waiter?.lastDayPending}"),
            7.width,
            openingClosingBalance(
                color: ColorTheme.black2E,
                text: "Cash Collected",
                openingBalance: "₹${widget.waiter?.todaySettlement}")
          ],
        ).paddingSymmetric(horizontal: 10),
        Visibility(
          visible: widget.waiter?.isShowPaymentMode == true,
          child: Container(
            color: ColorTheme.settlementBgColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Text(
                  AppString.tipsByPaymentMode,
                  style: TextStyle(
                    color: ColorTheme.hintText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                10.height,
                myDivider(),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        15.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              paymentModeList[index].toString(),
                              style: MyTextStyle.greenW60018.copyWith(
                                  fontSize: 14, color: ColorTheme.blackColor),
                            ),
                            Text(
                              "₹${tipsValue(paymentModeList[index].toString(), widget.waiter?.tipsByMode, widget.waiter)}",
                              style: MyTextStyle.greenW60018
                                  .copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                        15.height,
                        index != 4 ? myDivider() : SizedBox(),
                      ],
                    );
                  },
                ),
                10.height,
              ],
            ).paddingSymmetric(horizontal: 13),
          ),
        ).paddingOnly(bottom: 15),
        Visibility(
          visible: widget.waiter?.isShowRevenue == true,
          child: Container(
            color: ColorTheme.settlementBgColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Text(
                  'Revenue',
                  style: TextStyle(
                    color: ColorTheme.hintText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                10.height,
                myDivider(),
                Column(
                  children: [
                    15.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // 'Total Sale',
                          'Total Paid Revenue',

                          style: MyTextStyle.greenW60018.copyWith(
                              fontSize: 14, color: ColorTheme.blackColor),
                        ),
                        Text(
                          "₹${widget.waiter?.totalSale ?? "0"}",
                          style: MyTextStyle.greenW60018.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // 'Total Paid Revenue',
                          'Total Cash Paid Revenue',

                          style: MyTextStyle.greenW60018.copyWith(
                              fontSize: 14, color: ColorTheme.blackColor),
                        ),
                        Text(
                          // "₹${widget.waiter?.totalPaid ?? "0"}",
                          "₹${widget.waiter?.todayCollection ?? "0"}",

                          style: MyTextStyle.greenW60018.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // 'Total Paid Revenue',
                          'Total Expense(Cash Drawer)',

                          style: MyTextStyle.greenW60018.copyWith(
                              fontSize: 14, color: ColorTheme.blackColor),
                        ),
                        Text(
                          // "₹${widget.waiter?.totalPaid ?? "0"}",
                          "₹${widget.waiter?.cashDrawer ?? "0"}",

                          style: MyTextStyle.greenW60018.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    // 15.height,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       'Total Unpaid Revenue',
                    //       style: MyTextStyle.greenW60018.copyWith(
                    //           fontSize: 14, color: ColorTheme.blackColor),
                    //     ),
                    //     Text(
                    //       "₹${widget.waiter?.totalUnPaid ?? "0"}",
                    //       style: MyTextStyle.greenW60018.copyWith(fontSize: 15),
                    //     ),
                    //   ],
                    // ),
                    15.height,

                    myDivider(),
                  ],
                ),
                10.height,
              ],
            ).paddingSymmetric(horizontal: 13),
          ),
        ).paddingOnly(bottom: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomEditableField(
                // labelText: AppString.currentBalance,
                labelText: 'Expected Balance',
                readOnly:
                    widget.waiter?.balanceToSettle == "0.00" ? true : false,
                controller: widget.textEditingController,
                totalFund: widget.waiter?.balanceToSettle ?? "",
              ),
            ),
            5.width,
            Expanded(
              child: CustomEditableField(
                labelText: "Actual Balance",
                readOnly: false,
                controller: widget.expectedBalanceController,
                totalFund: "",
                onChanged: (value) {
                  print("Expected Balance onChanged: $value");
                  print(
                      "Controller text: ${widget.expectedBalanceController?.text}");
                },
              ),
            ),
            5.width,
            // Then use with null-aware operator:
            ValueListenableBuilder(
              valueListenable: widget.expectedBalanceController!,
              builder: (context, value, child) {
                final text = value.text.trim(); // real-time text

                // ✅ show nothing until user enters something
                if (text.isEmpty) return const SizedBox.shrink();
                double balanceToSettle = double.tryParse(
                        widget.waiter?.balanceToSettle?.toString() ?? "0") ??
                    0;
                double expectedBalance = double.tryParse(
                        widget.expectedBalanceController?.text ?? "0") ??
                    0;
                double pilferage = expectedBalance - balanceToSettle;

                if (pilferage == 0) return SizedBox.shrink();

                return Text(
                  'Pilferage: ${pilferage}',
                  style: montserratMedium.copyWith(
                    fontSize: 12,
                    color: pilferage < 0 ? Colors.red : Colors.green,
                  ),
                );
              },
            ),

            5.width,
            Row(
              children: [
                Builder(
                  builder: (context) {
                    bool isEnabled = (widget
                                    .controller
                                    .settlementRestaurantModel
                                    ?.totals
                                    ?.settlementStatus ??
                                1) ==
                            0 &&
                        !widget.controller.isSettlementLoader &&
                        !widget.controller.isSelfSettleLoader &&
                        widget.waiter?.balanceToSettle != "0.00";
                    return MouseRegion(
                        cursor: isEnabled
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.forbidden,
                        child: MyButton(
                          // text: 'Part',
                          text: 'Settle',
                          width: 80,
                          loaderColor: ColorTheme.greenColor,
                          textColor: isEnabled
                              ? ColorTheme.greenColor
                              : ColorTheme.borderGrey,
                          onTap: isEnabled ? widget.partBalanceOnPress : null,
                          isLoader:
                              widget.controller.waiterPartialSettlementLoader,
                        ));
                  },
                ),
                // 5.width,
                // MyButton(
                //     loaderColor: ColorTheme.whiteColor,
                //     onTap: widget.waiter?.balanceToSettle == "0.00"
                //         ? null
                //         : widget.fullBalanceOnPress,
                //     text: 'Full',
                //     width: 80,
                //     isLoader: widget.controller.waiterFullSettlementLoader,
                //     textColor: widget.waiter?.balanceToSettle == "0.00"
                //         ? ColorTheme.borderGrey
                //         : ColorTheme.whiteColor,
                //     boxColor: widget.waiter?.balanceToSettle == "0.00"
                //         ? ColorTheme.whiteEFEFEF
                //         : ColorTheme.green)
              ],
            ),
          ],
        ).paddingSymmetric(horizontal: 10),
        15.height,
        customDivider()
      ],
    );
  }

  String? tipsValue(String tipsName, TipsByMode? tipsByMode, Waiter? waiter) {
    switch (tipsName) {
      case "Cash Tips":
        return tipsByMode?.cash ?? "";
      case "UPI Tips":
        return tipsByMode?.upi ?? "";
      case "Card Tips":
        return tipsByMode?.card ?? "";
      case "Service Charge":
        return waiter?.todayServiceCharge ?? "";
      case "Delivery Charges":
        return waiter?.todayDeliveryCharge ?? "";
    }
    return null;
  }

  Widget myDivider() {
    return Container(
      width: double.infinity,
      color: ColorTheme.hintText,
      height: .20,
    );
  }

  // Add this method in your State class
  Widget? _buildPilferageText() {
    double balanceToSettle =
        double.tryParse(widget.waiter?.balanceToSettle?.toString() ?? "0") ?? 0;
    double expectedBalance =
        double.tryParse(widget.expectedBalanceController?.text ?? "0") ?? 0;
    double pilferage = balanceToSettle - expectedBalance;

    if (pilferage == 0) return null; // or return SizedBox.shrink();

    return Text(
      'Pilferage: ${pilferage.toStringAsFixed(2)}',
      style: montserratMedium.copyWith(
        fontSize: 12,
        color: pilferage < 0 ? Colors.red : Colors.green,
      ),
    );
  }
}
