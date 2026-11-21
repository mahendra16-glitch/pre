import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/settlement_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_settlement_list_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settelment_report/settlement_by_employee.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class SettlementReport extends StatefulWidget {
  @override
  State<SettlementReport> createState() => _SettlementReportState();
}

class _SettlementReportState extends State<SettlementReport> {
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await Get.find<SettlementController>().getSettlementList({});
  }

  TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // toolbarHeight: Get.height / 10.72,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined,
                size: 36, color: ColorTheme.green),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.18,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      body: GetBuilder<SettlementController>(builder: (settlementController) {
        return settlementController.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  SizedBox(height: 5),
                  filterbyDateRow(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFE6E6E6)),
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                height:
                    MediaQuery.of(context).size.shortestSide > 570 ? 55 : 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: ColorTheme.appColor),
                    SizedBox(width: 15),
                    Text(
                      selectedDate == null
                          ? 'Filter by month'
                          : DateFormat('MMM yyyy').format(selectedDate!),
                      style: poppinsMedium.copyWith(
                        color: ColorTheme.hintText,
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 13
                            : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      Get.find<SettlementController>().getSettlementList({
        "month": DateFormat('MM').format(selectedDate!),
        "year": DateFormat('yyyy').format(selectedDate!)
      });
    }
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
                  '₹${changeDoubleValue(settlementController.getSettlementReportList!.grandTotalSale)}',
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
                  '₹${changeDoubleValue(settlementController.getSettlementReportList!.grandTotalPaidRevenue)}',
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
                  '₹${changeDoubleValue(settlementController.getSettlementReportList!.grandTotalUnpaidRevenue)}',
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
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: settlementController
                  .getSettlementReportList!.settelmentlist.length ??
              0,
          itemBuilder: (BuildContext context, int i) {
            return DateTime.now().isAfter(DateTime.parse(settlementController
                    .getSettlementReportList!.settelmentlist[i].fromDate!))
                ? revenueCard(settlementController, i)
                : SizedBox.shrink();
          }),
    );
  }

  Widget revenueCard(SettlementController settlementController, int i) {
    Settelmentlist settelment =
        settlementController.getSettlementReportList!.settelmentlist[i];
    return Container(
      margin: EdgeInsets.only(top: i == 0 ? 0 : 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: settelment.totalAmount == 0
            ? ColorTheme.bgSettleCardGreyColor
            : settelment.totalUnpaidAmount != 0
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
              Text(
                DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(settelment.fromDate!)),
                style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 17
                        : 15),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Revenue',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(settelment.totalAmount!)}',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.green,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
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
                      children: [
                        Text(
                          'Unpaid Revenue',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(settelment.totalUnpaidAmount!)}',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
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
                        if (settelment.totalAmount != 0)
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SettlementByEmployee(
                                      date: settelment.fromDate!
                                          .split(' ')
                                          .first)));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: settelment.totalAmount == 0
                                    ? Colors.grey
                                    : settelment.totalUnpaidAmount != 0
                                        ? ColorTheme.appColor
                                        : ColorTheme.green),
                            borderRadius: BorderRadius.circular(6),
                            color: settelment.totalAmount == 0
                                ? ColorTheme.bgSettleCardGreyColor
                                : settelment.totalUnpaidAmount != 0
                                    ? ColorTheme.appColor
                                    : ColorTheme.green),
                        child: Center(
                          child: Text(
                            settelment.totalAmount == 0
                                ? 'N/A'
                                : settelment.settelAmount ==
                                        settelment.totalAmount
                                    ? 'Settled'
                                    : 'View',
                            style: poppinsMedium.copyWith(
                                color: settelment.totalAmount == 0
                                    ? Colors.black
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
            ],
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid Revenue',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(settelment.totalPaidAmount!)}',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
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
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .payTab ==
                      'Yes')
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Credit Revenue',
                            style: poppinsMedium.copyWith(
                                color: ColorTheme.hintText,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 13
                                        : 10),
                          ),
                          Text(
                            '₹${changeDoubleValue(settelment.tabRevenue!)}',
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
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .payTab ==
                      'Yes')
                    Container(
                      color: Color(0xFFDFDFDF),
                      width: 1,
                      height: 30,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Settle Amt.',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(settelment.settelAmount!)}',
                          style: poppinsMedium.copyWith(
                              color: settelment.totalUnpaidAmount != 0
                                  ? ColorTheme.appColor
                                  : ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13),
                        ),
                      ],
                    ),
                  ),
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .payTab !=
                      'Yes')
                    Expanded(child: SizedBox())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String changeDoubleValue(double value) {
    return value == 0 ? '0' : value.toStringAsFixed(2);
  }
}
