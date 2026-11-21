// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:intl/intl.dart';

// class DateFilterWidget extends StatelessWidget {
//   final ReportSummeryController controller;
//   final Function(String) onDateChanged;

//   const DateFilterWidget({
//     required this.controller,
//     required this.onDateChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: Colors.white),
//           bottom: BorderSide(color: Color(0xFFE4E4E4)),
//         ),
//       ),
//       child: LayoutBuilder(builder: (context, constraints) {
//         return Row(
//           children: [
//             // From Date
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.only(right: 15),
//                 child: GestureDetector(
//                   onTap: () async {
//                     DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: controller.fromDate.value,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                       builder: (context, child) {
//                         return Theme(
//                           data: ThemeData.light().copyWith(
//                             colorScheme: ColorScheme.light(
//                               primary: ColorTheme.appColor,
//                               onPrimary: Colors.white,
//                               onSurface: ColorTheme.greyColor,
//                             ),
//                             textButtonTheme: TextButtonThemeData(
//                               style: TextButton.styleFrom(
//                                 foregroundColor: ColorTheme.appColor,
//                               ),
//                             ),
//                           ),
//                           child: child!,
//                         );
//                       },
//                     );
//                     if (picked != null) {
//                       controller.fromDate.value = picked;
//                       controller.isCustomDateRange.value = true; // Mark as custom
//                       onDateChanged(DateFormat('d-M-yyyy').format(picked));
//                     }
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: Obx(() => Text(
//                               DateFormat('dd/MM/yyyy')
//                                   .format(controller.fromDate.value),
//                               overflow: TextOverflow.ellipsis,
//                               style: poppinsMedium.copyWith(
//                                 color: ColorTheme.greyColor,
//                                 fontSize: 14,
//                               ),
//                             )),
//                       ),
//                       const SizedBox(width: 6),
//                       const Icon(Icons.calendar_today_outlined,
//                           size: 18, color: Colors.black38),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 48,
//               color: Color(0xFFE4E4E4),
//             ),
//             // To Date
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.only(right: 15),
//                 child: GestureDetector(
//                   onTap: () async {
//                     DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: controller.toDate.value,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                       builder: (context, child) {
//                         return Theme(
//                           data: ThemeData.light().copyWith(
//                             colorScheme: ColorScheme.light(
//                               primary: ColorTheme.appColor,
//                               onPrimary: Colors.white,
//                               onSurface: ColorTheme.greyColor,
//                             ),
//                             textButtonTheme: TextButtonThemeData(
//                               style: TextButton.styleFrom(
//                                 foregroundColor: ColorTheme.appColor,
//                               ),
//                             ),
//                           ),
//                           child: child!,
//                         );
//                       },
//                     );
//                     if (picked != null) {
//                       controller.toDate.value = picked;
//                       controller.isCustomDateRange.value = true; // Mark as custom
//                       onDateChanged(DateFormat('d-M-yyyy').format(picked));
//                     }
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: Obx(() => Text(
//                               DateFormat('dd/MM/yyyy')
//                                   .format(controller.toDate.value),
//                               overflow: TextOverflow.ellipsis,
//                               style: poppinsMedium.copyWith(
//                                 color: ColorTheme.greyColor,
//                                 fontSize: 14,
//                               ),
//                             )),
//                       ),
//                       const SizedBox(width: 6),
//                       const Icon(Icons.calendar_today_outlined,
//                           size: 18, color: Colors.black38),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatelessWidget {
  final ReportSummeryController controller;
  final String section; // 'items', 'category', 'cancelled', or 'station'
  final Function(String) onDateChanged;
  final bool isFilterIcon;

  const DateFilterWidget({
    required this.controller,
    required this.section,
    required this.onDateChanged,
    this.isFilterIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    DateTime fromDateChecker = DateTime.now();
    DateTime? toDateChecker;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white),
          bottom: BorderSide(color: Color(0xFFE4E4E4)),
        ),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // From Date
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () async {
                    DateTime toDateChecker = section == 'items'
                        ? controller.itemsToDate.value
                        : section == 'category'
                            ? controller.categoryToDate.value
                            : section == 'cancelled'
                                ? controller.cancelledToDate.value
                                : section == 'station'
                                    ? controller.stationToDate.value
                                    : DateTime.now();
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: section == 'items'
                          ? controller.itemsFromDate.value
                          : section == 'category'
                              ? controller.categoryFromDate.value
                              : section == 'cancelled'
                                  ? controller.cancelledFromDate.value
                                  : section == 'station'
                                      ? controller.stationFromDate.value
                                      : DateTime.now(),
                      // firstDate: DateTime(2000),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1460)),

                      // lastDate: DateTime(2100),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: ColorTheme.appColor,
                              onPrimary: Colors.white,
                              onSurface: ColorTheme.greyColor,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: ColorTheme.appColor,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null &&
                        (picked.isBefore(toDateChecker) ||
                            picked.isAtSameMomentAs(toDateChecker))) {
                      if (section == 'items') {
                        controller.itemsFromDate.value = picked;
                        controller.isItemsCustomDateRange.value = true;
                      } else if (section == 'category') {
                        controller.categoryFromDate.value = picked;
                        controller.isCategoryCustomDateRange.value = true;
                      } else if (section == 'cancelled') {
                        controller.cancelledFromDate.value = picked;
                        controller.isCancelledCustomDateRange.value = true;
                      } else if (section == 'station') {
                        controller.stationFromDate.value = picked;
                        controller.isStationCustomDateRange.value = true;
                      }
                      onDateChanged(DateFormat('d-M-yyyy').format(picked));
                    } else {
                      Get.snackbar(
                        'Select valid Date',
                        "Select a date which lower than and equal to ${DateFormat('dd-MM-yyyy').format(toDateChecker)}",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Obx(() => Text(
                              DateFormat('dd/MM/yyyy').format(section == 'items'
                                  ? controller.itemsFromDate.value
                                  : section == 'category'
                                      ? controller.categoryFromDate.value
                                      : section == 'cancelled'
                                          ? controller.cancelledFromDate.value
                                          : section == 'station'
                                              ? controller.stationFromDate.value
                                              : DateTime.now()),
                              overflow: TextOverflow.ellipsis,
                              style: poppinsMedium.copyWith(
                                color: ColorTheme.greyColor,
                                fontSize: 14,
                              ),
                            )),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: Colors.black38),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Color(0xFFE4E4E4),
            ),
            // To Date
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () async {
                    DateTime fromDateChecker = section == 'items'
                        ? controller.itemsFromDate.value
                        : section == 'category'
                            ? controller.categoryFromDate.value
                            : section == 'cancelled'
                                ? controller.cancelledFromDate.value
                                : section == 'station'
                                    ? controller.stationFromDate.value
                                    : DateTime.now();

                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: section == 'items'
                          ? controller.itemsToDate.value
                          : section == 'category'
                              ? controller.categoryToDate.value
                              : section == 'cancelled'
                                  ? controller.cancelledToDate.value
                                  : section == 'station'
                                      ? controller.stationToDate.value
                                      : DateTime.now(),
                      // firstDate: DateTime(2000),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: ColorTheme.appColor,
                              onPrimary: Colors.white,
                              onSurface: ColorTheme.greyColor,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: ColorTheme.appColor,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null &&
                        (picked.isAfter(fromDateChecker) ||
                            picked.isAtSameMomentAs(fromDateChecker))) {
                      if (section == 'items') {
                        controller.itemsToDate.value = picked;
                        controller.isItemsCustomDateRange.value = true;
                      } else if (section == 'category') {
                        controller.categoryToDate.value = picked;
                        controller.isCategoryCustomDateRange.value = true;
                      } else if (section == 'cancelled') {
                        controller.cancelledToDate.value = picked;
                        controller.isCancelledCustomDateRange.value = true;
                      } else if (section == 'station') {
                        controller.stationToDate.value = picked;
                        controller.isStationCustomDateRange.value = true;
                      }
                      onDateChanged(DateFormat('d-M-yyyy').format(picked));
                    } else {
                      Get.snackbar(
                        'Select valid Date',
                        "Select a date which greater than and equal to ${DateFormat('dd-MM-yyyy').format(fromDateChecker)}",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Obx(() => Text(
                              DateFormat('dd/MM/yyyy').format(section == 'items'
                                  ? controller.itemsToDate.value
                                  : section == 'category'
                                      ? controller.categoryToDate.value
                                      : section == 'cancelled'
                                          ? controller.cancelledToDate.value
                                          : section == 'station'
                                              ? controller.stationToDate.value
                                              : DateTime.now()),
                              overflow: TextOverflow.ellipsis,
                              style: poppinsMedium.copyWith(
                                color: ColorTheme.greyColor,
                                fontSize: 14,
                              ),
                            )),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: Colors.black38),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: Color(0xFFE4E4E4),
            ),
            isFilterIcon
                ? Container(
                    decoration: BoxDecoration(
                      border:
                          Border(left: BorderSide(color: Color(0xFFE4E4E4))),
                    ),
                    child: Obx(() => IconButton(
                          icon: Icon(
                            Icons.filter_alt,
                            color: controller.showFilterPanel.value
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (controller.showFilterPanel.value) {
                              // If panel is open → closing it, so reset filters
                              controller.showFilterPanel.value = false;
                              section == 'cancelled'
                                  ? controller.resetFiltersForTopCancelItems()
                                  : controller
                                      .resetFiltersForDailyRevenueReport();
                            } else {
                              // Opening the panel → no reset
                              controller.showFilterPanel.value = true;
                            }
                          },
                        )),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(Icons.print_outlined,
                        size: 28, color: Color(0xFFC6C6C6)),
                  ),
          ],
        );
      }),
    );
  }
}
