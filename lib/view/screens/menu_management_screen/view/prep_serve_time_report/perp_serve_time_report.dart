import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';

class PrepServeTimeReportScreen extends StatefulWidget {
  const PrepServeTimeReportScreen({Key? key}) : super(key: key);

  @override
  State<PrepServeTimeReportScreen> createState() =>
      _PrepServeTimeReportScreenState();
}

class _PrepServeTimeReportScreenState extends State<PrepServeTimeReportScreen> {
  MenuManagementController? menuManagementController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    menuManagementController = Get.find<MenuManagementController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchPrepServeTimeReport();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Initialize default date range (current month)
  void _initializeDatesAndData() {
    menuManagementController?.prepServeTimeReportList = [];
    menuManagementController?.update();
    final now = DateTime.now();
    menuManagementController?.prepServeTimeStartDate =
        DateFormat('dd-MM-yyyy').format(now);
    menuManagementController?.prepServeTimeEndDate =
        DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch prep serve time report data
  void _fetchPrepServeTimeReport() async {
    if (menuManagementController?.prepServeTimeStartDate != null &&
        menuManagementController?.prepServeTimeEndDate != null) {
      await menuManagementController?.getPrepServeTimeReport(
        fromDate: menuManagementController!.prepServeTimeStartDate!,
        toDate: menuManagementController!.prepServeTimeEndDate!,
      );
    }
  }

  /// Export prep serve time report
  void _exportPrepServeTimeReport() async {
    if (menuManagementController?.prepServeTimeStartDate != null &&
        menuManagementController?.prepServeTimeEndDate != null) {
      await menuManagementController?.exportPrepServeTimeReport(
        fromDate: menuManagementController!.prepServeTimeStartDate!,
        toDate: menuManagementController!.prepServeTimeEndDate!,
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select date range',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleWidget: Text(
            'Prepration-Serve Time Report',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Prep Serve Time Report',
          actions: [
            Obx(() {
              final isLoading =
                  menuManagementController!.isPrepServeTimeExportLoading.value;
              return IconButton(
                tooltip: 'Download',
                onPressed: isLoading ? null : _exportPrepServeTimeReport,
                mouseCursor: isLoading
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.click,
                icon: Icon(
                  Icons.file_download_outlined,
                  color: ColorTheme.greyBE,
                  size: 30,
                ),
              );
            }),
            Center(
              child: IconButton(
                tooltip: 'Refresh',
                onPressed: _fetchPrepServeTimeReport,
                icon: Icon(
                  Icons.refresh,
                  color: ColorTheme.greyBE,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
        body: GetBuilder<MenuManagementController>(
          builder: (controller) => Column(
            children: [
              // SizedBox(height: 10),
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
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  menuManagementController?.prepServeTimeStartDate,
                );
                if (picked != null) {
                  menuManagementController?.prepServeTimeStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  menuManagementController?.update();
                  _fetchPrepServeTimeReport();
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
                    Flexible(
                      child: Text(
                        menuManagementController?.prepServeTimeStartDate ??
                            'DD-MM-YYYY',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: ColorTheme.black5F6368,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                final picked = await pickedDate(
                  menuManagementController?.prepServeTimeEndDate,
                );
                if (picked != null) {
                  menuManagementController?.prepServeTimeEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  menuManagementController?.update();
                  _fetchPrepServeTimeReport();
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
                    Flexible(
                      child: Text(
                        menuManagementController?.prepServeTimeEndDate ??
                            'DD-MM-YYYY',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: ColorTheme.black5F6368,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
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
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Search by food name...",
          hintStyle:
              montserratMedium.copyWith(fontSize: 15, color: ColorTheme.grey8C),
          prefixIcon: Icon(
            Icons.search,
            color: ColorTheme.grey8C.withOpacity(0.3),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
        ),
        style: montserratMedium.copyWith(fontSize: 15, color: ColorTheme.black),
        onChanged: (value) {
          // The StatefulBuilder will handle the rebuild
          // We just need to trigger it through the controller update
          menuManagementController?.update();
        },
      ),
    );
  }

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 45,
      color: ColorTheme.whiteColor,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Name Column
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Min Time Column
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
                'Min Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Max Time Column
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
                'Max Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Avg Time Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 5),
              alignment: Alignment.center,
              child: Text(
                'Avg Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
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
    if (menuManagementController?.isPrepServeTimeReportLoading.value ?? false) {
      return AppLoader();
    }

    final reportList = menuManagementController?.prepServeTimeReportList ?? [];
    final search = searchController.text.trim().toLowerCase();

    // Filter report list based on search query
    final filteredList = reportList.where((item) {
      if (search.isEmpty) return true;
      final foodName = item['food_name']?.toString().toLowerCase() ?? '';
      return foodName.contains(search);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          search.isEmpty ? 'No data found' : 'No results found',
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
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final record = filteredList[index];
          return _buildTableRow(record);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> record) {
    final foodName = record['food_name']?.toString() ?? '';
    final totalQuantity = record['total_quantity']?.toString() ?? '0';
    final minTime = record['min_time'];
    final maxTime = record['max_time'];
    final avgTime = record['avg_time_minutes'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Column - food_name with total_quantity in bracket
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 5),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$foodName ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '(Qty - $totalQuantity)',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: ColorTheme.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                softWrap: true,
              ),
            ),
          ),
          // Min Time Column
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
                minTime != null
                    ? minTime is num
                        ? '${minTime} min'
                        : '$minTime min'
                    : '-',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.foodValue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Max Time Column
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
                maxTime != null
                    ? maxTime is num
                        ? '${maxTime} min'
                        : '$maxTime min'
                    : '-',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.foodValue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Avg Time Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 5),
              alignment: Alignment.center,
              child: Text(
                avgTime != null
                    ? avgTime is num
                        ? '${avgTime} min'
                        : '$avgTime min'
                    : '-',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.foodValue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
