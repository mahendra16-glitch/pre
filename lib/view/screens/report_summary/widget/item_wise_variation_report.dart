import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
// import 'package:mygenie_restaurant/view/screens/report_summary/widget/date_filter_widget.dart';

class ItemWiseVariationReport extends StatelessWidget {
  final int? selectedTabIndex;
  final controller = Get.find<ReportSummeryController>();

  ItemWiseVariationReport({Key? key, this.selectedTabIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // controller.topSoldListItemSelected.value = selectedTabIndex;
      // if (!controller.isItemsCustomDateRange.value) {
      //   controller.setDateRange(controller.reportList[selectedTabIndex],
      //       section: 'items');
      // }
      controller.itemWiseVariationReport(
          controller.itemsFromDate.value, controller.itemsToDate.value);
    });

    return Scaffold(
      backgroundColor: ColorTheme.grey200Color,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            // controller.resetFilterTopSoldItems();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.redColor,
            size: 22,
          ),
        ),
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              "Item Wise ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.redColor,
              ),
            ),
            Text(
              "Variation Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorTheme.greenColor,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() => IconButton(
            tooltip: 'Download',
            onPressed: controller.isLoadingVariationSalesReport.value ? null : () {
              controller.downloadVariationReport(
                  controller.itemsFromDate.value, controller.itemsToDate.value);
            },
            mouseCursor: controller.isLoadingVariationSalesReport.value ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            icon: Icon(
              Icons.file_download_outlined,
              color: ColorTheme.greyBE,
              size: 25,
            ),
          )),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              controller.itemWiseVariationReport(
                  controller.itemsFromDate.value, controller.itemsToDate.value);
            },
            icon: Icon(
              Icons.refresh,
              color: ColorTheme.greyBE,
              size: 25,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<ReportSummeryController>(
          builder: (reportSummeryController) {
            return Column(
              children: [
                // DateFilterWidget(
                //   controller: controller,
                //   section: 'items',
                //   onDateChanged: (formattedDate) {
                //     controller.isItemsCustomDateRange.value = true;
                //     controller.itemWiseVariationReport(
                //         controller.itemsFromDate.value,
                //         controller.itemsToDate.value);
                //   },
                // ),
                _buildDateFilterSection(),
                const SizedBox(height: 0),
                // Search Bar Implementation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    onChanged: (query) {
                      controller.filterVariationSalesReport(query);
                      controller.update();
                    },
                    controller: controller.variationSearchController,
                    cursorColor: ColorTheme.greyBE,
                    cursorHeight: 15.0,
                    cursorRadius: Radius.circular(10),
                    cursorWidth: 2.0,
                    decoration: InputDecoration(
                      fillColor: ColorTheme.whiteColor,
                      filled: true,
                      hintText: 'Search by name...',
                      prefixIcon: Icon(Icons.search, color: ColorTheme.greyBE),
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.greyBE,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: ColorTheme.grey8C.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: ColorTheme.grey8C.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: ColorTheme.grey8C.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.black5F6368,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: ColorTheme.whiteColor,
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(15),
                //       child: Obx(
                //         () => Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: List.generate(
                //             controller.reportList.length,
                //             (index) {
                //               return GestureDetector(
                //                 onTap: () {
                //                   controller.topSoldListItemSelected.value =
                //                       index;
                //                   controller.setDateRange(
                //                       controller.reportList[index],
                //                       section: 'items');
                //                   controller.itemWiseVariationReport(
                //                       controller.itemsFromDate.value,
                //                       controller.itemsToDate.value);
                //                 },
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     color: controller.topSoldListItemSelected
                //                                 .value ==
                //                             index
                //                         ? ColorTheme.blueColor
                //                         : ColorTheme.whiteColor,
                //                   ),
                //                   child: Padding(
                //                     padding: const EdgeInsets.symmetric(
                //                         horizontal: 25, vertical: 7),
                //                     child: Text(
                //                       controller.reportList[index],
                //                       style: TextStyle(
                //                         color: controller
                //                                     .topSoldListItemSelected
                //                                     .value ==
                //                                 index
                //                             ? ColorTheme.whiteColor
                //                             : ColorTheme.greyColor,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 12,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               );
                //             },
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
                // Table Headers
                _buildTableHeaders(),
                // Table Data
                Expanded(
                  child: _buildTableData(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 50,
      color: ColorTheme.whiteColor,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          // Name Column
          Expanded(
            flex: 4,
            child: Text(
              'Name',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: ColorTheme.blueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Quantity Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                'Quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Item Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                'Total Amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Variation Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Variation Amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table data rows
  Widget _buildTableData() {
    return Obx(() {
      if (controller.isLoadingVariationSalesReport.value) {
        return AppLoader();
      }

      // Use filtered list if search is active, otherwise use original list
      final variationList = controller.variationSearchController.text.isEmpty
          ? controller.variationSalesReportList
          : controller.filteredVariationSalesReportList;

      if (variationList.isEmpty) {
        return Center(
          child: Text(
            controller.variationSearchController.text.isEmpty
                ? 'No variation sales data found'
                : 'No results found',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: ColorTheme.greyColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      return Container(
        color: ColorTheme.whiteColor,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: variationList.length,
          itemBuilder: (context, index) {
            final item = variationList[index];
            return _buildTableRow(item);
          },
        ),
      );
    });
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> item) {
    final variationGroup = item['variation_group']?.toString() ?? '';
    final variationLabel = item['variation_label']?.toString() ?? '';
    final foodItem = item['food_item']?.toString() ?? '';
    final totalQuantity = item['total_quantity']?.toString() ?? '0';
    final totalVariationAmount =
        item['total_variation_amount']?.toString() ?? '0.00';
    final itemTotalAmount = item['item_total_amount']?.toString() ?? '0.00';
// Clean the string and ensure it uses a period as a decimal separator
    String cleanAmount(String amount) {
      return amount.trim().replaceAll(',', '.');
    }

// Clean the amounts
    final cleanedTotalVariationAmount = cleanAmount(totalVariationAmount);
    final cleanedItemTotalAmount = cleanAmount(itemTotalAmount);

// Convert cleaned amounts to double
    final double totalVariationAmountDouble =
        double.tryParse(cleanedTotalVariationAmount) ?? 0.0;
    final double itemTotalAmountDouble =
        double.tryParse(cleanedItemTotalAmount) ?? 0.0;

// Add the amounts
    final double totalAmount =
        itemTotalAmountDouble + totalVariationAmountDouble;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Column - variation_group: variation_label and food_item
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (foodItem.isNotEmpty && variationLabel.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: foodItem,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' ( $variationLabel )',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  )
                else if (variationGroup.isNotEmpty && variationLabel.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: variationGroup,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ': ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: variationLabel,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  )
                else if (variationGroup.isNotEmpty)
                  Text(
                    variationGroup,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.blueColor,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  )
                else if (variationLabel.isNotEmpty)
                  Text(
                    variationLabel,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.blueColor,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                // if (variationDisplay.isNotEmpty) 4.height,
                // Text(
                //   'Food Item : ${foodItem}',
                //   style: TextStyle(
                //     fontFamily: 'Montserrat',
                //     fontSize: 10,
                //     color: ColorTheme.foodValue,
                //     fontWeight: FontWeight.w600,
                //   ),
                //   softWrap: true,
                // ),
              ],
            ),
          ),
          // Quantity Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                totalQuantity,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.greenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Item Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                totalAmount.toString() ?? '0.00',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.greenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Variation Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                totalVariationAmount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.greenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build date filter section with start and end date pickers
  Widget _buildDateFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: controller.itemsFromDate.value,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: ColorTheme.blueColor,
                          onPrimary: Colors.white,
                          onSurface: ColorTheme.greyColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.itemsFromDate.value = picked;
                  controller.isItemsCustomDateRange.value = true;
                  controller.itemWiseVariationReport(
                      controller.itemsFromDate.value,
                      controller.itemsToDate.value);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.whiteColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          DateFormat('dd-MM-yyyy')
                              .format(controller.itemsFromDate.value),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.black5F6368,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
                    ),
                  ],
                ),
              ),
            ),
          ),
          10.width,
          Text(
            'to',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: ColorTheme.black5F6368,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.width,
          // End Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: controller.itemsToDate.value,
                  firstDate: controller.itemsFromDate.value,
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: ColorTheme.blueColor,
                          onPrimary: Colors.white,
                          onSurface: ColorTheme.greyColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.itemsToDate.value = picked;
                  controller.isItemsCustomDateRange.value = true;
                  controller.itemWiseVariationReport(
                      controller.itemsFromDate.value,
                      controller.itemsToDate.value);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.whiteColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          DateFormat('dd-MM-yyyy')
                              .format(controller.itemsToDate.value),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.black5F6368,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
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
}
