import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/revenue_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_revenue_report_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RevenueReport extends StatefulWidget {
  const RevenueReport({Key? key}) : super(key: key);

  @override
  State<RevenueReport> createState() => _RevenueReportState();
}

class _RevenueReportState extends State<RevenueReport> {
  String selectedDateRange = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await Get.find<RevenueController>().getReport({
      "from": DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 6))),
      "to": DateFormat('yyyy-MM-dd').format(DateTime.now())
    });
    if (!mounted) return;
    setState(() {});
  }

  final TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.chevron_left_outlined,
                color: ColorTheme.green, size: 36),
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
      body: GetBuilder<RevenueController>(builder: (revenueController) {
        return revenueController.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  const SizedBox(height: 5),
                  filterbyDateRow(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFE6E6E6)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Revenue Report',
                        style: poppinsMedium.copyWith(
                            color: ColorTheme.hintText,
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 11),
                      ),
                    ),
                  ),
                  totalSummary(revenueController),
                  const SizedBox(height: 20),
                  revenueList(revenueController),
                ]),
              );
      }),
    );
  }

  Widget filterbyDateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                showDateDialog();
              },
              child: Container(
                height:
                    MediaQuery.of(context).size.shortestSide > 570 ? 55 : 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: ColorTheme.appColor),
                    const SizedBox(width: 15),
                    Text(
                      selectedDateRange == ''
                          ? 'Filter by date'
                          : selectedDateRange,
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

  void showDateDialog() {
    DateTime? tempStartDate;
    DateTime? tempEndDate;
    String? tempdateRange;
    Get.dialog(StatefulBuilder(builder: (context, setState) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE)),
        insetPadding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Text('Select date',
                  style: poppinsMedium.copyWith(
                      fontSize: 18, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                child: SfDateRangePicker(
                  maxDate: DateTime.now(),
                  onSelectionChanged: (d) {
                    setState(() {
                      if (d.value is PickerDateRange) {
                        tempdateRange =
                            '${DateFormat('dd/MM/yyyy').format(d.value.startDate)} -'
                            ' ${DateFormat('dd/MM/yyyy').format(d.value.endDate ?? d.value.startDate)}';
                        tempStartDate = d.value.startDate;
                        tempEndDate = d.value.endDate ?? d.value.startDate;
                      }
                    });
                  },
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(
                      startDate ??
                          DateTime.now().subtract(const Duration(days: 6)),
                      endDate ?? DateTime.now()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: ColorTheme.appColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: poppinsMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      setState(() {
                        startDate = tempStartDate ??
                            DateTime.now().subtract(const Duration(days: 6));
                        endDate = tempEndDate ?? DateTime.now();
                        selectedDateRange = tempdateRange ??
                            '${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 6)))} -'
                                ' ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
                      });
                      Get.back();
                      await Get.find<RevenueController>().getReport({
                        "from": DateFormat('yyyy-MM-dd').format(startDate!),
                        "to": DateFormat('yyyy-MM-dd').format(endDate!)
                      });
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: ColorTheme.appColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                      child: Center(
                        child: Text(
                          'Apply',
                          style: poppinsMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }), barrierDismissible: false);
  }

  Widget totalSummary(RevenueController revenueController) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                  '₹${changeDoubleValue(revenueController.getRevenueReportResponse!.grandTotalSale)}',
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
            color: const Color(0xFFDFDFDF),
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
                  '₹${changeDoubleValue(revenueController.getRevenueReportResponse!.grandTotalPaidRevenue)}',
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
            color: const Color(0xFFDFDFDF),
            width: 1,
            height: 30,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Running Order',
                  style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 13
                          : 10),
                ),
                Text(
                  '₹${changeDoubleValue(revenueController.getRevenueReportResponse!.grandTotalUnpaidRevenue)}',
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

  Widget revenueList(RevenueController revenueController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: revenueController.getRevenueReportResponse!.revenue.length,
          itemBuilder: (BuildContext context, int i) {
            return revenueCard(revenueController, i);
          }),
    );
  }

  Widget revenueCard(RevenueController revenueController, int i) {
    Revenue revenue = revenueController.getRevenueReportResponse!.revenue[i];
    return Container(
      margin: EdgeInsets.only(top: i == 0 ? 0 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: revenue.totalUnpaidAmount == 0
            ? const Color(0xFFF9F9F9)
            : const Color(0xFFFFF9E3),
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
                    .format(DateTime.parse(revenue.revenueDate!)),
                style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 17
                        : 15),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Sale',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(revenue.totalSales)}',
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
                    color: const Color(0xFFDFDFDF),
                    width: 1,
                    height: 30,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Running Order',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(revenue.totalUnpaidAmount)}',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.appColor,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const Color(0xFFDFDFDF),
                    width: 1,
                    height: 30,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Total Rev',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.hintText,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 13
                                      : 10),
                        ),
                        Text(
                          '₹${changeDoubleValue(revenue.totalAmount)}',
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
                          '₹${changeDoubleValue(revenue.totalPaidAmount)}',
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
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .payTab ==
                      'Yes')
                    Container(
                      color: const Color(0xFFDFDFDF),
                      width: 1,
                      height: 30,
                    ),
                  Expanded(
                    child: Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .payTab ==
                            'Yes'
                        ? Column(
                            children: [
                              Text(
                                'Credit Revenue',
                                style: poppinsMedium.copyWith(
                                    color: ColorTheme.hintText,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 13
                                        : 10),
                              ),
                              Text(
                                '₹${changeDoubleValue(revenue.tabRevenue)}',
                                style: poppinsMedium.copyWith(
                                    color: ColorTheme.hintText,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 15
                                        : 13),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                  Expanded(child: const SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String changeDoubleValue(double? value) {
    return value == null || value == 0 ? '0' : value.toStringAsFixed(2);
  }
}
