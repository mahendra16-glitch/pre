import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/report_summary_controller.dart';
import '../../../../helper/colors.dart';

class CategoryDetails extends StatelessWidget {
  String? name;
  String? id;
  int? selectedTabIndex;
  CategoryDetails({this.name, this.id, this.selectedTabIndex});

  // final controller = Get.put(ReportSummeryController());
  final controller = Get.find<ReportSummeryController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.topSoldListCategorySelectedDetails.value =
          selectedTabIndex ?? 0;
      // if (!controller.isCategoryCustomDateRange.value) {
      //   controller.setDateRange(controller.reportList[selectedTabIndex ?? 0],
      //       section: 'category_details');
      // }
      // Copy dates from category section to category_details section
      controller.categoryDetailsFromDate.value = controller.categoryFromDate.value;
      controller.categoryDetailsToDate.value = controller.categoryToDate.value;
      controller.isCategoryDetailsCustomDateRange.value = controller.isCategoryCustomDateRange.value;
      // controller.topSoldCategory(selectedTabIndex);
      // controller.topSoldCategoryDetails(
      // controller.stationListSelectedDetails.value, id!);
      controller.topSoldCategoryDetails(selectedTabIndex ?? 0, id!);
    });
    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.redColor,
            size: 22,
          ),
        ),
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "${name} ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.redColor,
              ),
            ),
            Text(
              "Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.greenColor,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: ColorTheme.whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      controller.reportList.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            controller.topSoldListCategorySelectedDetails
                                .value = index;
                            controller.setDateRange(
                                controller.reportList[index],
                                section: 'category_details');
                            controller.topSoldCategoryDetails(index, id!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: controller
                                            .topSoldListCategorySelectedDetails
                                            .value ==
                                        index
                                    ? ColorTheme.blueColor
                                    : ColorTheme.whiteColor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 7),
                              child: Text(
                                controller.reportList[index],
                                style: TextStyle(
                                  color: controller
                                              .topSoldListCategorySelectedDetails
                                              .value ==
                                          index
                                      ? ColorTheme.whiteColor
                                      : ColorTheme.greyColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () {
                    if (controller.isLoadingCategoryDetails.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.topSalesCategoryListDetails.value.isEmpty) {
                      return const Center(
                        child: Text(
                          "No data available",
                          style: TextStyle(
                              fontSize: 16, color: ColorTheme.greyColor),
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 15,
                        dataRowHeight: 55,
                        horizontalMargin: 0,
                        border: TableBorder(
                            verticalInside: BorderSide(
                                color: Colors.grey.withOpacity(0.5))),
                        showBottomBorder: true,
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Item",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.blueColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                "Sold",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorTheme.blueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: controller.topSalesCategoryListDetails.value
                            .map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          AppConstants.networkImage),
                                      radius: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item['food_item'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: ColorTheme.greyColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    item['total_quantity'].toString(),
                                    style: const TextStyle(
                                      color: ColorTheme.greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .resturantType ==
                                            'Restaurant'
                                        ? item['total_sales'].toString()
                                        : '0.00',
                                    style: const TextStyle(
                                      color: ColorTheme.greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
