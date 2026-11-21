import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/settlement_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_settlement_detail_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettlementByEmployee extends StatefulWidget {
  final String? date;
  const SettlementByEmployee({this.date});

  @override
  State<SettlementByEmployee> createState() => _SettlementByEmployeeState();
}

class _SettlementByEmployeeState extends State<SettlementByEmployee> {
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<SettlementController>().getSettlementDetail(widget.date!);
    });
  }

  TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.chevron_left, size: 36),
              color: ColorTheme.green,
              onPressed: () {
                Get.back();
              }),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Text(
            widget.date!,
            style: poppinsSemiBold.copyWith(
                color: Colors.black,
                fontSize:
                    MediaQuery.of(context).size.shortestSide > 570 ? 18 : 16),
          )),
      body: GetBuilder<SettlementController>(builder: (settlementController) {
        return settlementController.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  Divider(height: 1, color: Color(0xFFE6E6E6)),
                  SizedBox(height: 10),
                  // filterbyDateRow(),
                  // Divider(color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settlement Report',
                        style: poppinsMedium.copyWith(
                            color: ColorTheme.hintText,
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 11),
                      ),
                    ),
                  ),
                  totalSummary(settlementController),
                  SizedBox(height: 20),
                  revenueList(settlementController),
                ]),
              );
      }),
    );
  }

  Widget filterbyDateRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          value: 'Sort by Settlement Amount',
          items: <String>['Sort by Settlement Amount'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                '$value',
                maxLines: 1,
                style: poppinsMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_SMALL,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {},
          underline: SizedBox(),
        ),
      ),
    );
  }

  Widget totalSummary(SettlementController settlementController) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
          border: Border.all(color: ColorTheme.borderGrey)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Rev',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 13
                          : 10),
                ),
                Text(
                  settlementController.getSettlementDetailResponse == null
                      ? '₹0'
                      : '₹${changeDoubleValue(settlementController.getSettlementDetailResponse!.grandTotalSale)}',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13),
                ),
              ],
            ),
          ),
          Container(
            color: Color(0xFFDFDFDF),
            width: 1,
            height: 30,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Paid Rev',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 13
                          : 10),
                ),
                Text(
                  settlementController.getSettlementDetailResponse == null
                      ? '₹0'
                      : '₹${changeDoubleValue(settlementController.getSettlementDetailResponse!.grandTotalPaidRevenue)}',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.green,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13),
                ),
              ],
            ),
          ),
          Container(
            color: Color(0xFFDFDFDF),
            width: 1,
            height: 30,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Unpaid Rev',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 13
                          : 10),
                ),
                Text(
                  settlementController.getSettlementDetailResponse == null
                      ? '₹0'
                      : '₹${changeDoubleValue(settlementController.getSettlementDetailResponse!.grandTotalUnpaidRevenue)}',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.appColor,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget revenueList(SettlementController settlementController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: settlementController
                  .getSettlementDetailResponse?.settelmentdetails?.length ??
              0,
          itemBuilder: (BuildContext context, int i) {
            return revenueCard(
                settlementController
                    .getSettlementDetailResponse!.settelmentdetails[i],
                i);
          }),
    );
  }

  Widget revenueCard(Settelmentdetails settelmentdetails, int i) {
    List<SettelemetData> settlementDataList = [];
    // settlementDataList.add(SettelemetData(
    //     title: 'Total Revenue',
    //     amount:
    //         '₹${Get.find<SettlementController>().getSettlementDetailResponse.grandTotalSale.toInt()}'));
    settlementDataList.add(SettelemetData(
        title: 'Paid Revenue',
        amount:
            '₹${changeDoubleValue(settelmentdetails.totalRevenue ?? 0.0)}'));

    final restaurants = Get.find<AuthController>().profileModel!.restaurants;
    final firstRestaurant = (restaurants != null && restaurants.isNotEmpty)
        ? restaurants.first
        : null;

    if (firstRestaurant?.payTab == 'Yes')
      settlementDataList.add(SettelemetData(
          title: 'Credit Revenue',
          amount:
              '₹${changeDoubleValue(settelmentdetails.totTabRevenue ?? 0.0)}'));
    settlementDataList.add(SettelemetData(
        title: 'Settle Amt.',
        amount:
            '₹${changeDoubleValue(settelmentdetails.totSettleAmt ?? 0.0)}'));

    if (firstRestaurant?.payCash == 'Yes')
      settlementDataList.add(SettelemetData(
          title: 'Cash',
          amount: '₹${changeDoubleValue(settelmentdetails.totCash ?? 0.0)}'));
    if (firstRestaurant?.payUpi == 'Yes')
      settlementDataList.add(SettelemetData(
          title: 'UPI',
          amount: '₹${changeDoubleValue(settelmentdetails.totUpi ?? 0.0)}'));
    if (firstRestaurant?.payCC == 'Yes')
      settlementDataList.add(SettelemetData(
          title: 'CC',
          amount: '₹${changeDoubleValue(settelmentdetails.totCc ?? 0.0)}'));
    if (firstRestaurant?.payTab == 'Yes') {
      if (firstRestaurant?.payCash == 'Yes')
        settlementDataList.add(SettelemetData(
            title: 'Credit cash',
            amount: '₹${changeDoubleValue(settelmentdetails.tabCash ?? 0.0)}'));
      if (firstRestaurant?.payUpi == 'Yes')
        settlementDataList.add(SettelemetData(
            title: 'Credit UPI',
            amount: '₹${changeDoubleValue(settelmentdetails.tabUpi ?? 0.0)}'));
      if (firstRestaurant?.payCC == 'Yes')
        settlementDataList.add(SettelemetData(
            title: 'Credit CC',
            amount: '₹${changeDoubleValue(settelmentdetails.tabCc ?? 0.0)}'));
    }
    settlementDataList.add(SettelemetData(
        title: 'Unpaid Table',
        amount:
            '₹${changeDoubleValue(settelmentdetails.totUnpaidTable ?? 0.0)}'));
    if (firstRestaurant?.showRoom == 'Yes')
      settlementDataList.add(SettelemetData(
          title: 'Unpaid Room',
          amount:
              '₹${changeDoubleValue(settelmentdetails.totUnpaidRoom ?? 0.0)}'));
    settlementDataList.add(SettelemetData(
        title: 'Total Sale',
        amount: '₹${changeDoubleValue(settelmentdetails.totalSales ?? 0.0)}'));

    return Container(
      margin: EdgeInsets.only(top: i == 0 ? 0 : 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: settelmentdetails.totalSales == 0 &&
                settelmentdetails.totalRevenue == 0
            ? ColorTheme.bgSettleCardGreyColor
            : settelmentdetails.totalSales != 0 &&
                    settelmentdetails.totalRevenue != 0 &&
                    settelmentdetails.totUnpaid != 0
                ? ColorTheme.bgSettleCardSaffronColor
                : ColorTheme.bgSettleCardYellowColor,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RichText(
                    text: TextSpan(
                      text:
                          '${settelmentdetails.waiterName ?? ''}', // Default style (inherits from Theme)
                      style: poppinsSemiBold.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 17
                                  : 15),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              '  Tip - ${changeDoubleValue(settelmentdetails.tipAmount! + settelmentdetails.serviceTax! + settelmentdetails.deliveryCharge!)}',
                          style: poppinsRegular.copyWith(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 14
                                      : 11),
                        ),
                      ],
                    ),
                  )

                  // Text(
                  //   // (settelmentdetails.tipAmount +
                  //   //             settelmentdetails.serviceTax +
                  //   //             settelmentdetails.deliveryCharge) ==
                  //   //         0
                  //   //     ? '${settelmentdetails.waiterName ?? ''}'
                  //   // :
                  //   '${settelmentdetails.waiterName ?? ''} - #${(30).toStringAsFixed(2)}',
                  //   style: poppinsSemiBold.copyWith(
                  //       fontSize: MediaQuery.of(context).size.shortestSide > 570
                  //           ? 17
                  //           : 15),
                  // ),

                  ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unpaid Revenue',
                            style: poppinsMedium.copyWith(
                                color: ColorTheme.hintText,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 13
                                        : 10),
                          ),
                          Text(
                            '₹${changeDoubleValue(settelmentdetails.totUnpaid!)}',
                            style: poppinsMedium.copyWith(
                                color: ColorTheme.appColor,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        color: Color(0xFFDFDFDF),
                        width: 1,
                        height: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash to be collect',
                            style: poppinsMedium.copyWith(
                                color: ColorTheme.hintText,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 13
                                        : 10),
                          ),
                          Text(
                            '₹${(settelmentdetails.totalRevenue! - settelmentdetails.totSettleAmt! == 0) ? '0' : (settelmentdetails.totalRevenue! - settelmentdetails.totSettleAmt!).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                color: ColorTheme.appColor,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Color(0xFFDFDFDF),
                      width: 1,
                      height: 30,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (settelmentdetails.totalRevenue !=
                              settelmentdetails.totSettleAmt) {
                            Get.find<SettlementController>()
                                .settleAmount(widget.date!, data: {
                              "from": widget.date,
                              "to": widget.date,
                              "waiter_id": '${settelmentdetails.waiterID}',
                              "sattle_amount":
                                  '${settelmentdetails.totalRevenue! - settelmentdetails.totSettleAmt!}'
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: settelmentdetails.totalSales == 0 &&
                                          settelmentdetails.totalRevenue == 0
                                      ? Colors.grey
                                      : settelmentdetails.totUnpaid != 0 &&
                                              settelmentdetails.totalSales != 0
                                          ? Colors.transparent
                                          : settelmentdetails.totalRevenue ==
                                                  settelmentdetails.totSettleAmt
                                              ? ColorTheme.green
                                              : Colors.transparent),
                              color: settelmentdetails.totUnpaid != 0 &&
                                      settelmentdetails.totalSales != 0
                                  ? ColorTheme.appColor
                                  : settelmentdetails.totalSales == 0 &&
                                          settelmentdetails.totalRevenue == 0
                                      ? ColorTheme.bgSettleCardGreyColor
                                      : settelmentdetails.totalRevenue ==
                                              settelmentdetails.totSettleAmt
                                          ? ColorTheme.bgSettleCardYellowColor
                                          : ColorTheme.green),
                          child: Center(
                            child: Text(
                              settelmentdetails.totalSales == 0 &&
                                      settelmentdetails.totalRevenue == 0
                                  ? 'N/A'
                                  : settelmentdetails.totUnpaid != 0 &&
                                          settelmentdetails.totalSales != 0
                                      ? 'Settle'
                                      : settelmentdetails.totalRevenue !=
                                              settelmentdetails.totSettleAmt
                                          ? 'Settle'
                                          : 'Settle',
                              style: poppinsMedium.copyWith(
                                  color: settelmentdetails.totalSales == 0 &&
                                          settelmentdetails.totalRevenue == 0
                                      ? Colors.black
                                      : settelmentdetails.totUnpaid != 0 &&
                                              settelmentdetails.totalSales != 0
                                          ? Colors.white
                                          : settelmentdetails.totalRevenue ==
                                                  settelmentdetails.totSettleAmt
                                              ? ColorTheme.green
                                              : Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 15
                                          : 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 50, top: 15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: settlementDataList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 7,
                    childAspectRatio:
                        MediaQuery.of(context).size.shortestSide > 570
                            ? 4.5
                            : 1.7,
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settlementDataList[index].title ?? '',
                              // 'Cash',
                              style: poppinsMedium.copyWith(
                                  color: ColorTheme.hintText,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 13
                                          : 10),
                            ),
                            Text(
                              // '₹1027',
                              settlementDataList[index].amount ?? '',
                              style: poppinsMedium.copyWith(
                                  color: ColorTheme.hintText,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 15
                                          : 13),
                            ),
                          ],
                        ),
                      ),
                      if (index != 2 &&
                          index != 5 &&
                          index != 8 &&
                          index != settlementDataList.length - 1)
                        Container(
                          color: Color(0xFFDFDFDF),
                          width: 1,
                          height: 30,
                        ),
                    ],
                  );
                },
              ),
            ),

            //       expandShowAmount(
            //         firstTitle: 'Paid Revenue',
            //         amount1: '₹${settelmentdetails.totalRevenue}',
            //         secondTitle: 'Unpaid Revenue',
            //         amount2: '₹${settelmentdetails.totUnpaid}',
            //         thirdTitle: 'Tab Revenue',
            //         amount3: '₹${settelmentdetails.totTabRevenue}',
            //       ),
            //       ////////////////////
            //       expandShowAmount(
            //         firstTitle: 'Cash',
            //         amount1: '₹${settelmentdetails.totCash.toInt()}',
            //         secondTitle: 'UPI',
            //         amount2: '₹${settelmentdetails.totUpi.toInt()}',
            //         thirdTitle: 'CC',
            //         amount3: '₹${settelmentdetails.totCc.toInt()}',
            //       ),
            //       //////// ///////////////////
            //       expandShowAmount(
            //         firstTitle: 'Tab cash',
            //         amount1: '₹${settelmentdetails.tabCash.toInt()}',
            //         secondTitle: 'Tab UPI',
            //         amount2: '₹${settelmentdetails.tabUpi.toInt()}',
            //         thirdTitle: 'Tab CC',
            //         amount3: '₹${settelmentdetails.tabCc.toInt()}',
            //       ),

            // /////////////////////////
            //       expandShowAmount(
            //         firstTitle: 'Unpaid Table',
            //         amount1: '₹${settelmentdetails.totUnpaidTable.toInt()}',
            //         secondTitle: 'Unpaid Room',
            //         amount2: '₹${settelmentdetails.totUnpaidRoom.toInt()}',
            //         thirdTitle: 'Total Sale',
            //         amount3: '₹${settelmentdetails.totalSales.toInt()}',
            //       ),
          ],
        ),
      ),
    );
  }

  Widget expandShowAmount({
    String? firstTitle,
    String? secondTitle,
    String? thirdTitle,
    String? amount1,
    String? amount2,
    String? amount3,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstTitle ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 12),
                ),
                Text(
                  amount1 ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).hintColor,
            width: 1,
            height: 25,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  secondTitle ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 12),
                ),
                Text(
                  amount2 ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).hintColor,
            width: 1,
            height: 25,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  thirdTitle ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 12),
                ),
                Text(
                  amount3 ?? '',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String changeDoubleValue(double value) {
    return value == 0 ? '0' : value.toStringAsFixed(2);
  }
}

class SettelemetData {
  String? title;
  String? amount;

  SettelemetData({this.title, this.amount});
}
