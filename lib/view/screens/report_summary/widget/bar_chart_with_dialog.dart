import 'dart:math';

import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controller/report_summary_controller.dart';

class BarChartWithDialog extends StatelessWidget {
  ReportSummeryController? controller;

  BarChartWithDialog({this.controller});

  var isLoadingDaily = false.obs;
  RxMap<dynamic, dynamic> dailySalesReport = {}.obs;

  @override
  Widget build(BuildContext context) {
    OverlayEntry? overlayEntry;

    void showOverlay(BuildContext context, Offset position, double total,
        double paid, double unpaid, double running) {
      overlayEntry?.remove();
      overlayEntry = null;

      // Get screen dimensions
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // Pop-up dimensions
      const popupWidth = 240.0;
      const popupHeight = 150.0;

      // Adjust position to prevent overflow
      double left = position.dx - popupWidth / 2;
      double top = position.dy - popupHeight - 10;

      // Ensure the pop-up stays within screen bounds
      if (left < 0) {
        left = 10; // Add some padding
      } else if (left + popupWidth > screenWidth) {
        left = screenWidth - popupWidth - 10; // Add some padding
      }

      if (top < 0) {
        top = position.dy + 10; // Place below the bar if above is not possible
      } else if (top + popupHeight > screenHeight) {
        top = screenHeight - popupHeight - 10; // Add some padding
      }

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            // Fullscreen GestureDetector to detect taps outside the dialog
            GestureDetector(
              onTap: () {
                overlayEntry?.remove();
                overlayEntry = null;
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),

            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  // Prevent tap on dialog itself from closing it
                  child: Obx(
                    () => Container(
                      width: popupWidth,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTheme.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: ColorTheme.blackColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isLoadingDaily.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Total Sales",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorTheme.blueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹$total",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: ColorTheme.blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Paid Revenue",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorTheme.blueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹$paid",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: ColorTheme.blackColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Unpaid Revenue",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: ColorTheme.blueColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹$unpaid",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: ColorTheme.blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Running Revenue",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: ColorTheme.blueColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "₹$running",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: ColorTheme.blackColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry!);
    }

    void dismissOverlay() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    return Obx(
      () => GestureDetector(
        onTap: dismissOverlay,
        child: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              dismissOverlay();
            }
          },
          child: BarChart(
            // duration: const Duration(seconds: 0),
            BarChartData(
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions &&
                      response?.spot != null) {
                    final spot = response!.spot;
                    final renderBox = context.findRenderObject() as RenderBox;
                    final globalPosition =
                        renderBox.localToGlobal(event.localPosition!);
                    String reportType = controller!.selected.value == 0
                        ? "hourly_sales"
                        : controller!.selected.value == 1
                            ? "weekly_sales"
                            : controller!.selected.value == 2
                                ? "monthly_sales"
                                : controller!.selected.value == 3
                                    ? "six_month_sales"
                                    : "financial_year_sales";
                    String fieldName = controller!.selected.value == 0
                        ? "date"
                        : controller!.selected.value == 1
                            ? "date"
                            : controller!.selected.value == 2
                                ? "date"
                                : controller!.selected.value == 3
                                    ? "month"
                                    : "month";

                    String date = getDateRangeForSales(
                        controller!.selected.value,
                        response.spot!.touchedBarGroupIndex +
                            (controller!.selected.value == 2 ? 1 : 0));
                    Map<String, dynamic> salesForDate =
                        controller!.selected.value == 0
                            ? controller!.topSalesList[reportType].toString() ==
                                    "[]"
                                ? {}
                                : controller!.topSalesList[reportType]
                                    [date.toString().padLeft(2, '0')]
                            : controller!.topSalesList[reportType]?.firstWhere(
                                (entry) {
                                  return entry[fieldName] == date;
                                },
                                orElse: () => <String, dynamic>{},
                              );
                    double parseDouble(String value) {
                      return double.tryParse(
                              value.replaceAll(",", "") ?? "0.0") ??
                          0.0;
                    }

                    double total =
                        parseDouble(salesForDate["total_sales"].toString());
                    double paid =
                        parseDouble(salesForDate["paid_revenue"].toString());
                    double unpaid =
                        parseDouble(salesForDate["unpaid_revenue"].toString());
                    double running =
                        parseDouble(salesForDate["running_order"].toString());
                    showOverlay(
                        context, globalPosition, total, paid, unpaid, running);
                  }
                },
              ),
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: controller!.bottomTitles,
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: controller!.getLeftTitles,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: controller!.chartData.value,
            ),
          ),
        ),
      ),
    );
  }

  String getDateRangeForSales(int timeframe, int currentIndex) {
    DateTime now = DateTime.now();

    switch (timeframe) {
      case 0:
        return "$currentIndex";

      case 1:
        List<String> last7Days = List.generate(7, (index) {
          final DateTime day =
              now.subtract(Duration(days: 1)).subtract(Duration(days: index));
          return DateFormat('yyyy-MM-dd').format(day);
        }).reversed.toList();

        return last7Days[currentIndex];

      case 2:
        DateTime prevMonth = DateTime(now.year, now.month - 1, 1);
        return "${prevMonth.year}-${prevMonth.month.toString().padLeft(2, '0')}-${(currentIndex + 1).toString().padLeft(2, '0')}";
      // return "${now.year}-${(now.month - 1).toString().padLeft(2, '0')}-${currentIndex.toString().padLeft(2, '0')}";

      case 3:
        List<String> last6Months = List.generate(6, (index) {
          final DateTime month = DateTime(now.year, now.month - index - 1, 1);
          return "${DateFormat.MMM().format(month)} ${month.year}";
        }).reversed.toList();
        return last6Months[currentIndex];

      case 4:
        int currentMonth = now.month;
        DateTime startOfFinYear = currentMonth >= 4
            ? DateTime(now.year, 4, 1)
            : DateTime(now.year - 1, 4, 1);

        List<String> finMonths = List.generate(12, (index) {
          DateTime month =
              DateTime(startOfFinYear.year, startOfFinYear.month + index, 1);
          return "${DateFormat.MMM().format(month)} ${month.year}";
        });
        return finMonths[currentIndex];

      default:
        return "";
    }
  }
}
