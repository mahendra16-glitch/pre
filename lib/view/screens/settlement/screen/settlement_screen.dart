import 'dart:developer';

import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settelement_date_screen.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_divider.dart';
import 'package:mygenie_restaurant/view/screens/settlement/constant/custom_textstyle.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/opening_balance.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/settlement_details_widget.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/waiter_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({Key? key}) : super(key: key);

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiCalling();
    });
    super.initState();
  }

  String selectedDate = 'Today';

  apiCalling() async {
    var controller = Get.find<SettlementManagementController>();
    controller.purchaseFromDate = DateFormat('dd-MM-yyyy').format(
        selectedDate == 'Today'
            ? DateTime.now()
            : DateTime.now().subtract(Duration(days: 1)));
    controller.purchaseToDate = DateFormat('dd-MM-yyyy').format(
        selectedDate == 'Today'
            ? DateTime.now()
            : DateTime.now().subtract(Duration(days: 1)));
    await controller.getSettlementRestaurantList();
    await controller.getWaiterList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettlementManagementController>(
      builder: (controller) => GestureDetector(
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
            title: Text("Settlement", style: MyTextStyle.greenW60018),
            // actions: [
            //   Container(
            //     width: 88,
            //     height: 36,
            //     decoration: BoxDecoration(
            //       color: ColorTheme.green,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     alignment: Alignment.center,
            //     child: Text(
            //       "Settle All",
            //       style: TextStyle(
            //         color: ColorTheme.whiteColor,
            //         fontFamily: "Poppins",
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // 20.width,
            // Image.asset(
            //   "assets/image/export.png",
            //   height: 22,
            //   width: 22,
            //   color: ColorTheme.secondGreyColor,
            // ).paddingOnly(right: 20)
            // ],
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: Icon(Icons.refresh, color: ColorTheme.appColor, size: 28),
                onPressed: () async {
                  await controller.getSettlementRestaurantList();
                },
              ),
              // Self Settlement Button -- 0 for not settled(enable the button - user can do self settlement), 1 for settled(disable the button - already settlement done for this date)

              Builder(
                builder: (context) {
                  bool isEnabled = (controller.settlementRestaurantModel?.totals
                                  ?.settlementStatus ??
                              1) ==
                          0 &&
                      !controller.isSettlementLoader &&
                      !controller.isSelfSettleLoader;
                  return Tooltip(
                    message: 'Sef Settlement',
                    child: MouseRegion(
                      cursor: isEnabled
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.forbidden,
                      child: InkWell(
                        onTap: isEnabled
                            ? () async {
                                // Get the current selected date or use today's date
                                String? selectedDate =
                                    controller.purchaseFromDate;
                                await controller.selfSettle();
                              }
                            : null,
                        mouseCursor: isEnabled
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.forbidden,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.check_circle_outline_outlined,
                              color:
                                  isEnabled ? ColorTheme.appColor : Colors.grey,
                              size: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
              10.width,
            ],
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    height: 1,
                    width: double.infinity,
                    color: ColorTheme.greyDFDFDF),
                // Container(
                //   color: ColorTheme.whiteColor,
                //   child: Row(
                //     children: [
                //       27.width,
                //       GestureDetector(
                //         // onTap: () {
                //         //   controller.picFromDate();
                //         // },
                //         child: Text(controller.purchaseFromDate ?? "DD-MM-YYYY",
                //             style: TextStyle(
                //               fontSize: 11,
                //               color: ColorTheme.black2E,
                //               fontFamily: "Poppins",
                //               fontWeight: FontWeight.w600,
                //             )),
                //       ),
                //       MediaQuery.of(context).size.width < 600
                //           ? 10.width
                //           : 60.width,
                //       Container(width: 0.3, height: 30, color: Colors.grey),
                //       Expanded(
                //         child: GestureDetector(
                //           // onTap: () {
                //           //   controller.picToDate();
                //           // },
                //           child: Container(
                //             alignment: Alignment.center,
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Text(controller.purchaseToDate ?? "DD-MM-YYYY",
                //                     style: TextStyle(
                //                       fontSize: 11,
                //                       color: (controller
                //                                   .purchaseToDate?.isNotEmpty ??
                //                               false)
                //                           ? ColorTheme.black2E
                //                           : ColorTheme.secondGreyColor,
                //                       fontFamily: "Poppins",
                //                       fontWeight: FontWeight.w600,
                //                     )),
                //                 (controller.purchaseToDate?.isEmpty ?? false)
                //                     ? Padding(
                //                         padding: const EdgeInsets.only(top: 8),
                //                         child: Icon(Icons.date_range_rounded,
                //                             size: 15,
                //                             color: ColorTheme.blueColor),
                //                       )
                //                     : SizedBox()
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       Container(width: 0.3, height: 47, color: Colors.grey),
                //       Expanded(
                //         child: Container(
                //           alignment: Alignment.center,
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Expanded(
                //                 child: Container(
                //                     width: double.infinity,
                //                     child: DropdownButton<String>(
                //                       borderRadius: BorderRadius.circular(12),
                //                       dropdownColor: Colors.white,
                //                       alignment: Alignment.center,
                //                       isExpanded: true,
                //                       hint: Text(
                //                         "All Settlement",
                //                         style: TextStyle(
                //                           color: ColorTheme.secondGreyColor,
                //                           fontSize: 10,
                //                           fontFamily: "Poppins",
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                       ),
                //                       icon: Icon(
                //                           Icons.keyboard_arrow_down_outlined,
                //                           size: 22,
                //                           color: Colors.grey),
                //                       underline: SizedBox.shrink(),
                //                       onChanged: (newValue) async {},
                //                       items: [
                //                         ...["hello", "hy"]
                //                             .map<DropdownMenuItem<String>>(
                //                           (value) {
                //                             String purchaseValue =
                //                                 value.toString();
                //                             return DropdownMenuItem<String>(
                //                               value: purchaseValue,
                //                               child: Text(
                //                                       purchaseValue.toString(),
                //                                       style: TextStyle(
                //                                           fontSize: 12,
                //                                           color: Colors.black))
                //                                   .paddingOnly(left: 20),
                //                             );
                //                           },
                //                         ).toList(),
                //                       ],
                //                     )),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       9.width,
                //     ],
                //   ),
                // ),

                Container(
                    height: 1,
                    width: double.infinity,
                    color: ColorTheme.greyDFDFDF),
                25.height,
                controller.isSettlementLoader == true ||
                        controller.waiterFullSettlementLoader == true
                    ? Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 2.7),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : (controller.settlementRestaurantModel?.data?.isNotEmpty ??
                            false)
                        ? Column(
                            children: [
                              ListView.builder(
                                itemCount: 1,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) => Container(
                                  color: ColorTheme.whiteColor,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // GestureDetector(
                                          //   onTap: () {
                                          //     // Get.to(() => SettlementDateScreen(
                                          //     //       waiters: controller
                                          //     //           .settlementRestaurantModel
                                          //     //           ?.data
                                          //     //           ?.last
                                          //     //           .waiters,
                                          //     //     ));
                                          //   },
                                          //   child: Column(
                                          //     crossAxisAlignment:
                                          //         CrossAxisAlignment.start,
                                          //     children: [
                                          //       Text("Today",
                                          //           style: MyTextStyle
                                          //               .blueColor12W500),
                                          //       Row(
                                          //         children: [
                                          //           Text(
                                          //             controller
                                          //                     .settlementRestaurantModel
                                          //                     ?.data
                                          //                     ?.last
                                          //                     .date
                                          //                     .toString()
                                          //                     .split(" ")[0] ??
                                          //                 "",
                                          //             style: MyTextStyle
                                          //                 .blueColor12W500
                                          //                 .copyWith(
                                          //                     color: ColorTheme
                                          //                         .black2E,
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .w600),
                                          //           ),
                                          //           SizedBox(width: 3),
                                          //           Icon(
                                          //               Icons.arrow_forward_ios,
                                          //               color: ColorTheme
                                          //                   .blueColor,
                                          //               size: 15),
                                          //         ],
                                          //       ),
                                          //     ],
                                          //   ).paddingOnly(top: 15),
                                          // ),

                                          PopupMenuButton<String>(
                                            onSelected: (String value) async {
                                              String tempDate = selectedDate;
                                              selectedDate = value;
                                              if (tempDate != value)
                                                await apiCalling();
                                              // You can also trigger navigation or logic here
                                              // if (value == "Today") { ... } else { ... }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              const PopupMenuItem(
                                                value: "Today",
                                                child: Text("Today"),
                                              ),
                                              const PopupMenuItem(
                                                value: "Yesterday",
                                                child: Text("Yesterday"),
                                              ),
                                            ],
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(selectedDate,
                                                    style: MyTextStyle
                                                        .blueColor12W500),
                                                Row(
                                                  children: [
                                                    Text(
                                                      selectedDate == "Today"
                                                          ? (controller
                                                                  .settlementRestaurantModel
                                                                  ?.data
                                                                  ?.last
                                                                  .date
                                                                  .toString()
                                                                  .split(
                                                                      " ")[0] ??
                                                              "")
                                                          : (controller
                                                                  .settlementRestaurantModel
                                                                  ?.data
                                                                  ?.first
                                                                  .date
                                                                  .toString()
                                                                  .split(
                                                                      " ")[0] ??
                                                              ""),
                                                      style: MyTextStyle
                                                          .blueColor12W500
                                                          .copyWith(
                                                        color:
                                                            ColorTheme.black2E,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: ColorTheme
                                                            .blueColor,
                                                        size: 20),
                                                  ],
                                                ),
                                              ],
                                            ).paddingOnly(top: 15),
                                          ),
                                          SizedBox(width: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // Opening and Closing Balance Rows
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  openingClosingBalance(
                                                      openingBalance:
                                                          "₹${controller.settlementRestaurantModel?.totals?.totalOpeningBalance.toString()}",
                                                      text: 'Opening Bal.'),
                                                  SizedBox(width: 15),
                                                  openingClosingBalance(
                                                      openingBalance:
                                                          "₹${controller.settlementRestaurantModel?.totals?.lastDayPending.toString()}",
                                                      text: 'Closing Bal.'),
                                                ],
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  openingClosingBalance(
                                                      openingBalance:
                                                          "₹${controller.settlementRestaurantModel?.totals?.totalBalanceToSettle.toString()}",
                                                      text: 'Current Bal.'),
                                                  SizedBox(width: 15),
                                                  openingClosingBalance(
                                                      openingBalance:
                                                          "₹${controller.settlementRestaurantModel?.totals?.totalTodaySettlement.toString()}",
                                                      text: 'Cash Collected'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ).paddingSymmetric(horizontal: 8),
                                      SizedBox(height: 15),
                                      customDivider(),
                                      SizedBox(height: 5),
                                      // ListView for waiters
                                      ListView.builder(
                                        itemCount: controller
                                                .settlementRestaurantModel
                                                ?.data
                                                ?.last
                                                .waiters
                                                ?.length ??
                                            0,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, innerIndex) {
                                          return WaiterBalanceCard(
                                            controller: controller,
                                            isShowEditIcon: true,
                                            index: innerIndex,
                                            textEditingController: controller
                                                    .settlementFirstIndexWaiterTControllerList[
                                                innerIndex],
                                            expectedBalanceController: controller
                                                    .settlementFirstIndexExpectedBalanceControllerList[
                                                innerIndex],
                                            partBalanceOnPress: () async {
                                              await controller
                                                  .waiterPartialSettlement(
                                                controller: controller
                                                        .settlementFirstIndexWaiterTControllerList[
                                                    innerIndex],
                                                expectedBalanceController:
                                                    controller
                                                            .settlementFirstIndexExpectedBalanceControllerList[
                                                        innerIndex],
                                                waiter: controller
                                                    .settlementRestaurantModel
                                                    ?.data
                                                    ?.last
                                                    .waiters?[innerIndex],
                                                date: controller
                                                    .settlementRestaurantModel
                                                    ?.data
                                                    ?.last
                                                    .waiters?[innerIndex]
                                                    .date
                                                    .toString()
                                                    .split(" ")[0],
                                                waiterId: controller
                                                    .settlementRestaurantModel
                                                    ?.data
                                                    ?.last
                                                    .waiters![innerIndex]
                                                    .waiterId,
                                              );
                                            },
                                            fullBalanceOnPress: () async {
                                              await controller
                                                  .waiterFullSettlement(
                                                date: controller
                                                    .settlementRestaurantModel
                                                    ?.data
                                                    ?.last
                                                    .waiters?[innerIndex]
                                                    .date
                                                    .toString()
                                                    .split(" ")[0],
                                                waiterId: controller
                                                    .settlementRestaurantModel
                                                    ?.data
                                                    ?.last
                                                    .waiters?[innerIndex]
                                                    .waiterId,
                                              );
                                            },
                                            waiter: controller
                                                .settlementRestaurantModel
                                                ?.data
                                                ?.last
                                                .waiters?[innerIndex],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ).paddingSymmetric(horizontal: 18),
                              ),
                              25.height,
                              (controller.removeFirstSettlementRestaurantModel
                                          ?.data?.isNotEmpty ??
                                      false)
                                  ? customDivider()
                                      .paddingSymmetric(horizontal: 18)
                                  : SizedBox(),
                              (controller.removeFirstSettlementRestaurantModel
                                          ?.data?.isNotEmpty ??
                                      false)
                                  ? Container(
                                      height: 40,
                                      child: Row(children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                15.width,
                                                Text("Details",
                                                    style: MyTextStyle
                                                        .blueColor12W500
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color:
                                                        ColorTheme.greyDFDFDF),
                                              ),
                                            ),
                                            child: Text("Closing Bal.",
                                                style: MyTextStyle
                                                    .blueColor12W500
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            child: Text("Action",
                                                style: MyTextStyle
                                                    .blueColor12W500
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                          ),
                                        ),
                                      ]),
                                    ).paddingSymmetric(horizontal: 18)
                                  : SizedBox(),
                              ListView.builder(
                                itemCount: controller
                                        .removeFirstSettlementRestaurantModel
                                        ?.data
                                        ?.length ??
                                    0,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      SettlementDetailsWidget(
                                        index: index,
                                        indexUpdateAction: () {
                                          controller.showWaiter(controller
                                              .removeFirstSettlementRestaurantModel
                                              ?.data?[index]);
                                        },
                                        settleMentData: controller
                                            .removeFirstSettlementRestaurantModel
                                            ?.data?[index],
                                      ),
                                      Visibility(
                                        visible: controller
                                                .removeFirstSettlementRestaurantModel
                                                ?.data?[index]
                                                .isShowWaiter ==
                                            true,
                                        child: Container(
                                            color: ColorTheme.whiteColor,
                                            child: Column(
                                              children: [
                                                customDivider(),
                                                ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: controller
                                                            .removeFirstSettlementRestaurantModel
                                                            ?.data?[index]
                                                            .waiters
                                                            ?.length ??
                                                        0,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, insideIndex) {
                                                      return WaiterBalanceCard(
                                                        controller: controller,
                                                        partBalanceOnPress:
                                                            () async {
                                                          await controller
                                                              .waiterPartialSettlement(
                                                            controller: controller
                                                                    .settlementAfterIndexWaiterTControllerList[
                                                                index][insideIndex],
                                                            expectedBalanceController:
                                                                controller.settlementAfterIndexExpectedBalanceControllerList[
                                                                        index][
                                                                    insideIndex],
                                                            waiter: controller
                                                                    .removeFirstSettlementRestaurantModel
                                                                    ?.data?[index]
                                                                    .waiters?[
                                                                insideIndex],
                                                            date: controller
                                                                .removeFirstSettlementRestaurantModel
                                                                ?.data?[index]
                                                                .waiters?[
                                                                    insideIndex]
                                                                .date
                                                                .toString()
                                                                .split(" ")[0],
                                                            waiterId: controller
                                                                .removeFirstSettlementRestaurantModel
                                                                ?.data?[index]
                                                                .waiters?[
                                                                    insideIndex]
                                                                .waiterId,
                                                          );
                                                        },
                                                        fullBalanceOnPress:
                                                            () async {
                                                          await controller.waiterFullSettlement(
                                                              date: controller
                                                                  .removeFirstSettlementRestaurantModel
                                                                  ?.data?[index]
                                                                  .waiters?[
                                                                      insideIndex]
                                                                  .date
                                                                  .toString()
                                                                  .split(
                                                                      " ")[0],
                                                              waiterId: controller
                                                                  .removeFirstSettlementRestaurantModel
                                                                  ?.data?[index]
                                                                  .waiters?[
                                                                      insideIndex]
                                                                  .waiterId);
                                                        },
                                                        textEditingController:
                                                            controller.settlementAfterIndexWaiterTControllerList[
                                                                    index]
                                                                [insideIndex],
                                                        expectedBalanceController:
                                                            controller.settlementAfterIndexExpectedBalanceControllerList[
                                                                    index]
                                                                [insideIndex],
                                                        waiter: controller
                                                            .removeFirstSettlementRestaurantModel
                                                            ?.data?[index]
                                                            .waiters?[insideIndex],
                                                        index: insideIndex,
                                                      );
                                                    }),
                                              ],
                                            )),
                                      ),
                                    ],
                                  );
                                },
                              ).paddingSymmetric(horizontal: 18)
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 3),
                            child: Center(child: Text("No Data Found")),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
