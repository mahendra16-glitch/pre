import 'dart:convert';
import 'dart:developer';

// import 'package:dio/dio.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_details_report.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/report_summary_controller.dart';
import '../../../../helper/user_type.dart';

class StatefulBottomSheet extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime? firstDay;
  final DateTime? lastDay;

  const StatefulBottomSheet({
    this.selectedDay,
    this.firstDay,
    this.lastDay,
  });

  @override
  _StatefulBottomSheetState createState() => _StatefulBottomSheetState();
}

class _StatefulBottomSheetState extends State<StatefulBottomSheet> {
  DateTime? selectedDay;
  // final controller = Get.put(ReportSummeryController());
  final controller = Get.find<ReportSummeryController>();

  Color backgroundColor = ColorTheme.redColor;
  RxMap<dynamic, dynamic> dailySalesReport = {}.obs;
  var isLoadingDaily = false.obs;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay;
    manageColor();
    dailySalesRevenueReport(
        "${selectedDay!.day}-${selectedDay!.month}-${selectedDay!.year}");
  }

  void manageColor() {
    double averageSales = controller.averageSalesDate.isEmpty
        ? 0.0
        : controller.averageSalesDate.values.reduce((a, b) => a + b) /
            controller.averageSalesDate.length;

    final totalSales = controller.averageSalesDate[DateTime(
            selectedDay!.year, selectedDay!.month, selectedDay!.day)] ??
        0;

    if (controller.averageSalesDate.containsKey(
        DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day))) {
      backgroundColor = totalSales <= averageSales
          ? ColorTheme.redColor
          : ColorTheme.greenColor;
    }
  }

  void updateSelectedDay(DateTime newSelectedDay) {
    setState(() {
      selectedDay = newSelectedDay;
    });
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${selectedDay!.day}-${selectedDay!.month}-${selectedDay!.year}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: backgroundColor,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () {
                  DateTime previousDay =
                      selectedDay!.subtract(const Duration(days: 1));
                  if (previousDay.isAfter(widget.firstDay!) ||
                      isSameDay(previousDay, widget.firstDay!)) {
                    updateSelectedDay(previousDay);
                    backgroundColor = ColorTheme.redColor;
                    manageColor();
                    dailySalesRevenueReport(
                        "${selectedDay!.day}-${selectedDay!.month}-${selectedDay!.year}");
                  }
                },
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ColorTheme.blackColor,
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (!isSameDay(selectedDay!, DateTime.now())) {
                    DateTime nextDay =
                        selectedDay!.add(const Duration(days: 1));
                    if (nextDay.isBefore(widget.lastDay!) ||
                        isSameDay(nextDay, widget.lastDay!)) {
                      updateSelectedDay(nextDay);
                      backgroundColor = ColorTheme.redColor;
                      manageColor();
                      dailySalesRevenueReport(
                          "${selectedDay!.day}-${selectedDay!.month}-${selectedDay!.year}");
                    }
                  }
                },
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: ColorTheme.blackColor,
                  size: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (Get.isBottomSheetOpen ?? false) Get.back();
                  Get.to(() => DailySalesDetailsReport(
                        date:
                            "${selectedDay!.day}-${selectedDay!.month}-${selectedDay!.year}",
                        controller: controller,
                      ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorTheme.blueColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: Text(
                      "Paid Revenue",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.whiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: ColorTheme.greyColor,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 10),
          Obx(
            () => isLoadingDaily.value
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        color: ColorTheme.greyColor.withOpacity(0.4),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total Sales",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹${dailySalesReport["total_sales"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: backgroundColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 70,
                            width: 1,
                            color: ColorTheme.greyColor.withOpacity(0.4),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Running Order",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹${dailySalesReport["running_order"]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blackColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 1,
                        color: ColorTheme.greyColor.withOpacity(0.4),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Unpaid Revenue",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹${dailySalesReport["unpaid_revenue"]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blackColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 70,
                            width: 1,
                            color: ColorTheme.greyColor.withOpacity(0.4),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Paid Revenue",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹${dailySalesReport["paid_revenue"]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorTheme.blackColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 1,
                        color: ColorTheme.greyColor.withOpacity(0.4),
                        thickness: 1,
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Future<void> dailySalesRevenueReport(String date) async {
    isLoadingDaily(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };

      // var data = json.encode({"from": date, "to": date});
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.dailySalesReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": date,
        "to": date
      };
       Response response =
          await controller.reportSummaryRepo.dailySalesRevenueReport(data);
      log("dailySalesRevenueReport response :${response.body}");
      if (response.statusCode == 200) {
        log("Fetch daily report sheet successful");
        dailySalesReport.value = response.body;
      } else {
        ApiChecker.checkApi(response);
        log("Error: ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching daily sales: $e");
    } finally {
      isLoadingDaily(false);
    }
  }
}
