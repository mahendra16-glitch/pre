import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';

class DailyConsumptionReportScreen extends StatefulWidget {
  const DailyConsumptionReportScreen({Key? key}) : super(key: key);

  @override
  State<DailyConsumptionReportScreen> createState() =>
      _DailyConsumptionReportScreenState();
}

class _DailyConsumptionReportScreenState
    extends State<DailyConsumptionReportScreen> {
  InventoryController? inventoryController;

  @override
  void initState() {
    super.initState();
    inventoryController = Get.find<InventoryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      inventoryController?.getStockCategoryList();
      _fetchConsumptionReport();
    });
  }

  /// Initialize default date range (current date)
  void _initializeDatesAndData() {
    inventoryController?.consumptionStockSummary = [];
    inventoryController?.searchConsumptionReport.clear();
    inventoryController?.setCategoryFilter(null);
    inventoryController?.update();
    final now = DateTime.now();
    inventoryController?.consumptionStartDate =
        DateFormat('dd-MM-yyyy').format(now);
    inventoryController?.consumptionEndDate =
        DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch daily consumption report data
  void _fetchConsumptionReport() async {
    if (inventoryController?.consumptionStartDate != null &&
        inventoryController?.consumptionEndDate != null) {
      await inventoryController?.getDailyConsumptionReport(
        startDate: inventoryController!.consumptionStartDate!,
        endDate: inventoryController!.consumptionEndDate!,
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
            'Daily Consumption Report',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Daily Consumption Report',
          actions: [
            GetBuilder<InventoryController>(
              builder: (c) => IconButton(
                tooltip: 'Download Excel',
                onPressed: c.isConsumptionReportLoading
                    ? null
                    : () {
                        c.exportConsumptionExcel();
                      },
                mouseCursor: c.isConsumptionReportLoading
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.click,
                icon: Icon(
                  Icons.file_download_outlined,
                  color: ColorTheme.greyBE,
                  size: 30,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchConsumptionReport,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
          ],
        ),
        body: GetBuilder<InventoryController>(
          builder: (controller) => Column(
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
                final picked = await pickedDate(
                  inventoryController?.consumptionStartDate,
                );
                if (picked != null) {
                  inventoryController?.consumptionStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  inventoryController?.update();
                  _fetchConsumptionReport();
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
                      inventoryController?.consumptionStartDate ?? 'DD-MM-YYYY',
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
                final picked = await pickedDate(
                  inventoryController?.consumptionEndDate,
                );
                if (picked != null) {
                  inventoryController?.consumptionEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  inventoryController?.update();
                  _fetchConsumptionReport();
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
                      inventoryController?.consumptionEndDate ?? 'DD-MM-YYYY',
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
          // Search Bar
          Expanded(
            flex: 4,
            child: TextField(
              controller: inventoryController?.searchConsumptionReport,
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
                ),
              ),
              style: montserratMedium.copyWith(
                  fontSize: 15, color: ColorTheme.black),
              onChanged: (value) {
                inventoryController?.update();
              },
            ),
          ),
          SizedBox(width: 10),
          // Category Filter Dropdown
          GetBuilder<InventoryController>(
            builder: (controller) => Expanded(
              flex: 2,
              child: DropdownButtonFormField2<String>(
                isExpanded: true,
                style: montserratMedium.copyWith(
                    overflow: TextOverflow.ellipsis,
                    color: ColorTheme.grey8C,
                    fontSize: 12),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: ColorTheme.greyCACACA.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: ColorTheme.greyCACACA.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: ColorTheme.greyCACACA.withOpacity(0.3)),
                  ),
                ),
                value: inventoryController?.categoryFilter ?? 'All Categories',
                items: [
                  'All Categories',
                  if (inventoryController?.categoryStockList != null)
                    ...inventoryController!.categoryStockList
                        .map((category) =>
                            category['category_name']?.toString() ?? '')
                        .where((name) => name.isNotEmpty)
                        .toList()
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: montserratMedium.copyWith(
                          color: ColorTheme.grey8C, fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    inventoryController?.setCategoryFilter(
                        newValue == 'All Categories' ? null : newValue);
                  } else {
                    inventoryController?.setCategoryFilter(null);
                  }
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorTheme.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.filter_list),
                  iconSize: 20,
                  iconEnabledColor: ColorTheme.greyCACACA,
                ),
                dropdownStyleData: DropdownStyleData(
                  width: 150,
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorTheme.greyCACACA.withOpacity(0.3),
                    ),
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 40,
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
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 15),
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
          // Opening Stock Column
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
                'Opening Stock',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Closing Stock Column
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
                'Closing Stock',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Stock Consumed Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text(
                'Stock Consumed',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table data rows
  Widget _buildTableData() {
    if (inventoryController?.isConsumptionReportLoading ?? false) {
      return AppLoader();
    }

    final search = inventoryController?.searchConsumptionReport.text
            .trim()
            .toLowerCase() ??
        '';

    final stockSummary =
        (inventoryController?.consumptionStockSummary ?? []).where((item) {
      // Search Filter
      final name = item['ingredient_name']?.toString().toLowerCase() ?? '';
      final searchMatch = name.contains(search);

      // Category Filter
      final categoryFilter = inventoryController?.categoryFilter;
      bool categoryMatch = true;
      if (categoryFilter != null && categoryFilter != 'All Categories') {
        final itemCategory = item['category_name']?.toString() ?? '';
        categoryMatch = itemCategory == categoryFilter;
      }

      return searchMatch && categoryMatch;
    }).toList();

    if (stockSummary.isEmpty) {
      return Center(
        child: Text(
          'No consumption data found',
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
        itemCount: stockSummary.length,
        itemBuilder: (context, index) {
          final item = stockSummary[index];
          return _buildTableRow(item);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> item) {
    final ingredientName = item['ingredient_name']?.toString() ?? '';
    final displayUnit = item['display_unit']?.toString() ?? '';
    final categoryName = item['category_name']?.toString() ?? '';
    final openingStock = item['opening_stock']?.toString() ?? '0.00';
    final closingStock = item['closing_stock']?.toString() ?? '0.00';
    final totalConsumed = item['total_consumed']?.toString() ?? '0.00';

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
          // Name Column - ingredient_name (display_unit)
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$ingredientName ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: ColorTheme.foodValue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // TextSpan(
                        //   text: '($displayUnit)',
                        //   style: TextStyle(
                        //     fontFamily: 'Montserrat',
                        //     fontSize: 13,
                        //     color: ColorTheme.blue,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                    softWrap: true,
                  ),
                  if (categoryName.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        color: ColorTheme.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Opening Stock Column
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
                openingStock,
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
          // Closing Stock Column
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
                closingStock,
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
          // Stock Consumed Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: totalConsumed,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.foodValue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // TextSpan(
                    //   text: ' ($displayUnit) ',
                    //   style: TextStyle(
                    //     fontFamily: 'Montserrat',
                    //     fontSize: 11,
                    //     color: ColorTheme.blue,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
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
