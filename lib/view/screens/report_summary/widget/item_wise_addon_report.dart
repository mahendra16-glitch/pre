import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
// import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';

class ItemWiseAddonReport extends StatefulWidget {
  const ItemWiseAddonReport({Key? key}) : super(key: key);

  @override
  State<ItemWiseAddonReport> createState() => _ItemWiseAddonReportState();
}

class _ItemWiseAddonReportState extends State<ItemWiseAddonReport> {
  final controller = Get.find<ReportSummeryController>();
  String? addonStartDate;
  String? addonEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchAddonReport();
    });
  }

  /// Initialize default date range (current date)
  void _initializeDatesAndData() {
    final now = DateTime.now();
    addonStartDate = DateFormat('dd-MM-yyyy').format(now);
    addonEndDate = DateFormat('dd-MM-yyyy').format(now);
    controller.update();
  }

  /// Fetch addon report data
  void _fetchAddonReport() async {
    if (addonStartDate != null && addonEndDate != null) {
      // Parse the date strings to DateTime
      DateFormat format = DateFormat('dd-MM-yyyy');
      DateTime fromDate = format.parse(addonStartDate!);
      DateTime toDate = format.parse(addonEndDate!);

      await controller.itemWiseAddonReport(fromDate, toDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
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
                "Addon Report",
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
              onPressed: controller.isLoadingAddonSalesReport.value ? null : () {
                if (addonStartDate != null && addonEndDate != null) {
                  DateFormat format = DateFormat('dd-MM-yyyy');
                  DateTime fromDate = format.parse(addonStartDate!);
                  DateTime toDate = format.parse(addonEndDate!);
                  controller.downloadAddonReport(fromDate, toDate);
                }
              },
              mouseCursor: controller.isLoadingAddonSalesReport.value ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
              icon: Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            )),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchAddonReport,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: GetBuilder<ReportSummeryController>(
          builder: (reportController) => Column(
            children: [
              SizedBox(height: 10),
              // Date Filter Section
              _buildDateFilterSection(),
              // Search Bar
              _buildSearchBar(),
              // Table Headers
              _buildTableHeaders(),
              // Table Data
              Expanded(
                child: _buildTableData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build date filter section with start and end date pickers
  Widget _buildDateFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(addonStartDate);
                if (picked != null) {
                  addonStartDate = DateFormat('dd-MM-yyyy').format(picked);
                  controller.update();
                  _fetchAddonReport();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addonStartDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                final picked = await pickedDate(addonEndDate);
                if (picked != null) {
                  addonEndDate = DateFormat('dd-MM-yyyy').format(picked);
                  controller.update();
                  _fetchAddonReport();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addonEndDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

  /// Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: TextField(
              controller: controller.addonSearchController,
              onChanged: (query) {
                controller.filterAddonSalesReport(query);
                controller.update();
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Search by name...",
                hintStyle: montserratMedium.copyWith(
                    fontSize: 15, color: ColorTheme.grey8C),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorTheme.grey8C.withOpacity(0.3),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 45,
      color: ColorTheme.whiteColor,
      child: Row(
        children: [
          // Name Column
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
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
          // Addon Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Amount',
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
    if (controller.isLoadingAddonSalesReport.value) {
      return AppLoader();
    }

    // Use filtered list if search is active, otherwise use original list
    final addonList = controller.addonSearchController.text.isEmpty
        ? controller.addonSalesReportList
        : controller.filteredAddonSalesReportList;

    if (addonList.isEmpty) {
      return Center(
        child: Text(
          controller.addonSearchController.text.isEmpty
              ? 'No addon sales data found'
              : 'No results found',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ColorTheme.black5F6368.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      color: ColorTheme.whiteColor,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: addonList.length,
        itemBuilder: (context, index) {
          final item = addonList[index];
          return _buildTableRow(item);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> item) {
    final addonName = item['addon_name']?.toString() ?? '';
    final foodItem = item['food_item']?.toString() ?? '';
    final totalQuantity = item['total_quantity']?.toString() ?? '0';
    final totalAmount = item['total_amount']?.toString() ?? '0.00';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Column - addon_name and food_item
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addonName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  if (foodItem.isNotEmpty) ...[
                    4.height,
                    Text(
                      'Food Item : $foodItem',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: ColorTheme.blueColor,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                    ),
                  ],
                ],
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
          // Addon Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                totalAmount,
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
}
