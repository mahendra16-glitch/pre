import 'dart:convert';
import 'dart:developer';
// import 'package:dio/dio.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/daily_revenue_report_model.dart';
import 'package:mygenie_restaurant/data/model/response/daily_waiter_revenue_report_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_employee_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/repository/auth_repo.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/user_type.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/repo/report_summary_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/screens/report_summary/widget/daily_report_sheet.dart';

class InsightsSalesPoint {
  final String date;
  final double revenue;
  final int orders;
  final double cumulative;

  const InsightsSalesPoint({
    required this.date,
    required this.revenue,
    required this.orders,
    required this.cumulative,
  });
}

class ReportSummeryController extends GetxController implements GetxService {
  final ReportSummaryRepo reportSummaryRepo;
  ReportSummeryController({required this.reportSummaryRepo});

  TextEditingController itemsSearchController = TextEditingController();
  TextEditingController dailySalesItemSearchController =
      TextEditingController();

  String? rollName;
  RxList<dynamic> topSoldItemsList = [].obs;
  RxList<dynamic> filteredTopSoldItemsList = <dynamic>[].obs;
  var topSalesList = {}.obs;
  final stationSales = ''.obs;
  RxList<dynamic> topSalesCategoryList = [].obs;
  RxList<dynamic> topSalesCategoryListDetails = [].obs;
  RxList<dynamic> topCancelledItems = [].obs;
  // RxMap<dynamic, dynamic> dailySalesList = {}.obs;
  Rx<DailySalesResponse?> dailySalesList = Rx<DailySalesResponse?>(null);
  RxList<DailyReport> filteredDailySalesList = <DailyReport>[].obs;
  Rx<DailySalesResponse?> dailySalesListReport = Rx<DailySalesResponse?>(null);
  RxList<DailyReport> filteredDailySalesListReport = <DailyReport>[].obs;
  Rx<DailyWaiterSalesResponse?> dailyWaiterSalesList =
      Rx<DailyWaiterSalesResponse?>(null);
  RxList<DailyWaiterReport> filteredWaiterDailySalesList =
      <DailyWaiterReport>[].obs;
  RxMap<dynamic, dynamic> dailySalesReport = {}.obs;
  RxMap<dynamic, dynamic> dailySalesReportDetails = {}.obs;
  Rx<Color> backgroundColor = Colors.transparent.obs;
  var isLoadingSoldItem = false.obs;
  var isLoadingTopSales = false.obs;
  var isLoadingStationSales = false.obs;
  var isLoadingStationSalesDetails = false.obs;
  var isLoadingCategory = false.obs;
  var isLoadingCategoryDetails = false.obs;
  var isLoadingAverageSales = false.obs;
  var isLoadingTopCancelledItems = false.obs;
  var isLoadingDailySalesListItems = false.obs;
  var isLoadingDailyWaiterSalesListItems = false.obs;
  RxBool prePaid = true.obs;
  RxBool postPaid = true.obs;
  final reportList = ['D', 'W', 'M', '6M', 'FY'];
  final salesChartTabs = ['D', 'W', 'M'];
  final averageSalesList = ['1W', '1M', '3M', 'FY'];
  RxDouble newMaxY = 0.0.obs;
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  RxMap<DateTime, double> averageSalesDate = <DateTime, double>{}.obs;
  final isExpanded1 = false.obs;
  final isExpanded2 = false.obs;
  DateTime firstDay = DateTime.utc(2024, 10, 1);
  DateTime lastDay = DateTime.utc(2025, 12, 31);
  RxInt selected = 0.obs;
  RxInt averageListSelected = 0.obs;
  RxInt stationListSelected = 0.obs;
  RxInt stationListSelectedDetails = 0.obs;
  RxInt topSoldListItemSelected = 0.obs;
  RxInt topSoldListCategorySelected = 0.obs;
  RxInt topSoldListCategorySelectedDetails = 0.obs;
  RxString totalSalesCount = "0.00".obs;
  var isLoadingInsightsSales = false.obs;
  RxString insightsTotalSales = "0.00".obs;
  RxList<InsightsSalesPoint> insightsDailyPoints = <InsightsSalesPoint>[].obs;
  RxInt topCancelledItemsSelect = 0.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  RxList allStationSalesData = [].obs;
  RxList allStationSalesDataDetails = [].obs;
  RxMap<String, int> reasonIdMap = <String, int>{}.obs;

  RxMap<String, dynamic> allStationSalesDataDetail = <String, dynamic>{}.obs;
  RxList<BarChartGroupData> chartData = <BarChartGroupData>[].obs;
  final List<Map<String, dynamic>> chartList = [
    {
      'color': ColorTheme.greenColor,
      'name': 'Paid Revenue',
    },
    {
      'color': ColorTheme.redColor,
      'name': 'Unpaid Revenue',
    },
    {
      'color': ColorTheme.orangeColor,
      'name': 'Running Order',
    },
  ];

  // New variables for filtering
  final isCompItemEnabled = false.obs;
  final fromDate = DateTime.now().obs;
  final toDate = DateTime.now().obs;
  final showFilterPanel = false.obs;
  Map<String, List<String>> orderTypeGroups = {
    'DineIn': ['DineIn', 'POS', 'WalkIn'],
    'Delivery': ['Delivery'],
    'Takeaway': ['Takeaway'],
  };
  // Filter variables
  // RxList<String> paymentTypes = <String>[
  //   'All Payment Types',
  //   'Card',
  //   'Cash',
  //   'UPI',
  //   'Room',
  //   'Credit',
  //   'Unpaid',
  //   'Cancel',
  // ].obs;
  RxList<PaymentModes> paymentTypes = <PaymentModes>[
   
  ].obs;
  RxList<String> orderTypes = <String>[
    'All Order Types',
    'DineIn',
    'Delivery',
    'Takeaway',
    // 'WalkIn',
    // 'POS'
  ].obs;
  RxList<String> reasons = <String>[
    'All Cancellation Stage',
    // 'Post-Serve',
    // 'Pre-Serve',
    'After Serving',
    'Before Serving'
  ].obs;
  RxList<String> orderCollectedType =
      <String>['All Waiter Types', 'Order By', 'Collected By'].obs;
  RxList<Map<String, dynamic>> cancellationReasons =
      <Map<String, dynamic>>[].obs;
  // Rx selectedPaymentType = 'All Payment Types'.obs;
  Rx<PaymentModes?> selectedPaymentType = Rx<PaymentModes?>(null);

  // RxString selectedPaymentType = 'All Payment Types'.obs;
  RxString selectedOrderType = 'All Order Types'.obs;
  RxString selectedReasons = 'All Cancellation Stage'.obs;
  RxString selectedCancelReasons = 'All Reason'.obs;
  RxString selectedWaiter = 'All Waiters'.obs;
  RxString selectedOrderCollectedType = 'All Waiter Types'.obs;

  RxList<dynamic> filteredDailySalesReport = [].obs;
  // RxList<dynamic> filteredDailySalesList = [].obs; // For DailySalesDetailsReport
  RxList<dynamic> filteredTopCancelItemList =
      [].obs; // For DailySalesDetailsReport
  RxList<String> waiters = <String>['All Waiters'].obs;
  RxMap<String, String> waiterIdMap = <String, String>{}.obs;

  final itemsFromDate = DateTime.now().obs;
  final itemsToDate = DateTime.now().obs;
  final categoryFromDate = DateTime.now().obs;
  final categoryToDate = DateTime.now().obs;
  final categoryDetailsFromDate = DateTime.now().obs;
  final categoryDetailsToDate = DateTime.now().obs;
  final cancelledFromDate = DateTime.now().obs;
  final cancelledToDate = DateTime.now().obs;
  final stationFromDate = DateTime.now().obs;
  final stationToDate = DateTime.now().obs;

  // RxBool isCustomDateRange = false.obs;
  final isItemsCustomDateRange = false.obs;
  final isCategoryCustomDateRange = false.obs;
  final isCategoryDetailsCustomDateRange = false.obs;
  final isCancelledCustomDateRange = false.obs;
  final isStationCustomDateRange = false.obs;
  // Order details variables
  final isLoadingOrderDetails = false.obs;
  var orderDetails = {}.obs;

  // Aggregator (Swiggy/Zomato) order details variables
  final isLoadingAggregatorOrderDetails = false.obs;
  var aggregatorOrderDetails = {}.obs;

  initializeAllApis() async {
    focusedDay.value = DateTime.now();
    selectedDay.value = focusedDay.value;
    
    final sharedPreferences = await SharedPreferences.getInstance();

    userdata.token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
    await topSoldItems(fromDate.value, toDate.value); // Pass initial dates
    await topSoldCategory(0); // Default to 'D' for category
    await topCancelItems(0);
    // focusedDay.value =
    //     DateTime.now().isBefore(firstDay) || DateTime.now().isAfter(lastDay)
    //         ? firstDay
    //         : DateTime.now();

    generateDateList();
    await Future.delayed(Duration(seconds: 1));
    stationSalesRevenueReport(stationListSelected.value);
    await Future.delayed(Duration(seconds: 1));

    // totalSalesReport(selected.value);
    fetchInsightsSales(selected.value);
    await Future.delayed(Duration(seconds: 1));
    revenueReport(averageListSelected.value);
    // await Future.delayed(Duration(seconds: 1));
    // topSoldCategory(topSoldListCategorySelected.value);
    // await Future.delayed(Duration(seconds: 1));
    // topCancelItems(topCancelledItemsSelect.value);
  }

  waiterDailyReportApiCall() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    userdata.token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
  }

  generateDateList() {
    averageSalesDate.value = {};
    Map<String, dynamic> dateMap = getDateRange(averageListSelected.value);
    DateTime startDate = DateTime.parse(dateMap["startDate"]);
    DateTime endDate = DateTime.parse(dateMap["endDate"]);
    for (int i = 0;
        startDate
            .add(Duration(days: i))
            .isBefore(endDate.add(const Duration(days: 1)));
        i++) {
      DateTime date = startDate.add(Duration(days: i));
      averageSalesDate[DateTime(
        date.year,
        date.month,
        date.day,
      )] = 0;
    }
  }

  Map<String, dynamic> getDateRange(int timeframe) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day);

    switch (timeframe) {
      case 0:
        startDate = endDate.subtract(const Duration(days: 7));
        endDate = endDate.subtract(const Duration(days: 1));
        break;
      case 1:
        startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
        break;
      case 2:
        startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
        break;
      case 3:
        int startYear = endDate.month >= 4 ? endDate.year : endDate.year - 1;
        startDate = DateTime(startYear, 4, 1);
        break;
      default:
        startDate = endDate;
    }

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  Map<String, dynamic> getDateRangeForSales(int timeframe) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day);

    switch (timeframe) {
      case 0: // Today
        startDate = endDate;
        break;
      case 1: // Previous week
        startDate = endDate.subtract(const Duration(days: 7));
        endDate = endDate.subtract(const Duration(days: 1));
        break;
      case 2: // Previous month
        startDate = DateTime(endDate.year, endDate.month - 1, 1);
        endDate = DateTime(endDate.year, endDate.month, 1)
            .subtract(const Duration(days: 1));
        break;
      case 3: // Previous 6 months
        startDate = DateTime(endDate.year, endDate.month - 6, 1);
        endDate = DateTime(endDate.year, endDate.month, 1)
            .subtract(const Duration(days: 1));
        break;
      case 4: // Fiscal year beginning on April 1st
        int startYear = endDate.month >= 4 ? endDate.year : endDate.year - 1;
        startDate = DateTime(startYear, 4, 1);
        endDate = DateTime(startYear + 1, 3, 31);
        break;
      default:
        startDate = endDate;
    }

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  Future<void> topSoldItems(DateTime from, DateTime to) async {
    isLoadingSoldItem(true);

    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(from);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(to);

      // final data =
      //     json.encode({"from": formattedStartDate, "to": formattedEndDate});
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.topAllFoodSales}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Response response = await reportSummaryRepo.topSoldItems(data);

      if (response.statusCode == 200) {
        log("------------: Fetch top_food_sales");
        var items =
            response.body['food_sales_report'] ?? []; // Handle null response

        // Ensure topSoldItemsList is cleared before updating
        topSoldItemsList.clear();
        // await Get.find<KdsController>().getWaiterPOSOrderList();

        // final waiterList =
        //     Get.find<KdsController>().getWaiterOrderListResponse?.orders ?? [];

        // final zeroAmountFoodNames = waiterList
        //     .where((order) =>
        //         order.orderAmount == '0' ||
        //         order.orderAmount == '0.0' ||
        //         order.orderAmount == '0.00')
        //     .expand((order) => order.orderDetails ?? [])
        //     .map((detail) => detail.foodDetails?.name?.trim())
        //     .where((name) => name != null && name.isNotEmpty)
        //     .cast<String>()
        //     .toSet();

        // print('Zero amount food names: $zeroAmountFoodNames');

        if (isCompItemEnabled.value) {
          // topSoldItemsList.value = items
          //     .where((item) => zeroAmountFoodNames
          //         .contains(item['food_item']?.toString().trim()))
          //     .toList();
          // print('Matching complementary items: ${topSoldItemsList.value}');
          topSoldItemsList.value = items.where((item) {
            final itemPrice = item['item_price']?.toString() ?? '';
            return itemPrice == '0.00' ||
                itemPrice == '0' ||
                itemPrice == '0.0';
          }).toList();
          print(
              'Complementary items (item_price = 0): ${topSoldItemsList.value}');
        } else {
          topSoldItemsList.value = items;
        }
        filteredTopSoldItemsList.value = topSoldItemsList.value;

        // Force Obx to detect changes
        topSoldItemsList.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: Top Sold Items - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching Top Sold Items API: $e");
    } finally {
      isLoadingSoldItem(false);
    }
  }

  exportFoodCancelReasonWiseList(Map<String, dynamic> jsonData) async {
    try {
      final response =
          await reportSummaryRepo.exportCancelReasonWiseReport(jsonData);
      if (response.statusCode == 200) {
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } catch (e) {
      log("bulkExport :$e");
    }
  }

  void filterTopSoldItems(String query) {
    if (query.isEmpty) {
      filteredTopSoldItemsList.value = topSoldItemsList;
    } else {
      filteredTopSoldItemsList.value = topSoldItemsList.where((item) {
        final foodItem = item['food_item']?.toString().toLowerCase() ?? '';
        // final stationName =
        //     item['station_name']?.toString().toLowerCase() ?? '';
        // final categoryName =
        //     item['category_name']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return foodItem.contains(searchLower);
        // stationName.contains(searchLower) ||
        // categoryName.contains(searchLower);
      }).toList();
      update();
      filteredTopSoldItemsList.refresh();
    }
  }
  // void setDateRange(String range, {required String section}) {
  //   DateTime now = DateTime.now();
  //   DateTime from, to;

  //   switch (range) {
  //     case 'D':
  //       from = now;
  //       to = now;
  //       break;
  //     case 'W':
  //       from = now.subtract(Duration(days: 7));
  //       to = now;
  //       break;
  //     case 'M':
  //       from = DateTime(now.year, now.month - 1, now.day);
  //       to = now;
  //       break;
  //     case '6M':
  //       from = DateTime(now.year, now.month - 6, now.day);
  //       to = now;
  //       break;
  //     case 'FY':
  //       from = DateTime(now.year, 4, 1);
  //       to = now;
  //       break;
  //     default:
  //       from = now;
  //       to = now;
  //   }

  //   // Update specific section's date range
  //   if (section == 'items') {
  //     itemsFromDate.value = from;
  //     itemsToDate.value = to;
  //     isItemsCustomDateRange.value = false;
  //   } else if (section == 'category') {
  //     categoryFromDate.value = from;
  //     categoryToDate.value = to;
  //     isCategoryCustomDateRange.value = false;
  //   } else if (section == 'cancelled') {
  //     cancelledFromDate.value = from;
  //     cancelledToDate.value = to;
  //     isCancelledCustomDateRange.value = false;
  //   } else if (section == 'station') {
  //     stationFromDate.value = from;
  //     stationToDate.value = to;
  //     isStationCustomDateRange.value = false;
  //   }
  // }
  Map<String, dynamic> setDateRange(String range, {required String section}) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day);

    switch (range) {
      case 'D': // Today
        startDate = endDate;
        break;
      case 'W': // Previous week
        startDate = endDate.subtract(const Duration(days: 7));
        endDate = endDate.subtract(const Duration(days: 1));
        break;
      case 'M': // Previous month
        startDate = DateTime(endDate.year, endDate.month - 1, 1);
        endDate = DateTime(endDate.year, endDate.month, 1)
            .subtract(const Duration(days: 1));
        break;
      case '6M': // Previous 6 months
        startDate = DateTime(endDate.year, endDate.month - 6, 1);
        endDate = DateTime(endDate.year, endDate.month, 1)
            .subtract(const Duration(days: 1));
        break;
      case 'FY': // Fiscal year beginning on April 1st
        int startYear = endDate.month >= 4 ? endDate.year : endDate.year - 1;
        startDate = DateTime(startYear, 4, 1);
        endDate = DateTime(startYear + 1, 3, 31);
        break;
      default:
        startDate = endDate;
    }

    // Update specific section's date range
    if (section == 'items') {
      itemsFromDate.value = startDate;
      itemsToDate.value = endDate;
      isItemsCustomDateRange.value = false;
    } else if (section == 'category') {
      categoryFromDate.value = startDate;
      categoryToDate.value = endDate;
      isCategoryCustomDateRange.value = false;
    } else if (section == 'cancelled') {
      cancelledFromDate.value = startDate;
      cancelledToDate.value = endDate;
      isCancelledCustomDateRange.value = false;
    } else if (section == 'category_details') {
      categoryDetailsFromDate.value = startDate;
      categoryDetailsToDate.value = endDate;
      isCategoryDetailsCustomDateRange.value = false;
    } else if (section == 'station') {
      stationFromDate.value = startDate;
      stationToDate.value = endDate;
      isStationCustomDateRange.value = false;
    }

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  // void setDateRange(String range) {
  //   isCustomDateRange.value = false;

  //   int timeframe;
  //   switch (range) {
  //     case 'D':
  //       timeframe = 0;
  //       break;
  //     case 'W':
  //       timeframe = 1;
  //       break;
  //     case 'M':
  //       timeframe = 2;
  //       break;
  //     case '6M':
  //       timeframe = 3;
  //       break;
  //     case 'FY':
  //       timeframe = 4;
  //       break;
  //     default:
  //       timeframe = 0;
  //   }

  //   Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
  //   fromDate.value = DateTime.parse(dateRange['startDate']);
  //   toDate.value = DateTime.parse(dateRange['endDate']);

  //   topSoldItems(fromDate.value, toDate.value);
  //   topCancelItems(-1);
  // }

  Future<void> stationSalesRevenueReport(int timeframe) async {
    isLoadingStationSales(true);

    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      String formattedStartDate = dateRange['startDate'];
      String formattedEndDate = dateRange['endDate'];
      // var data =
      //     json.encode({"from": formattedStartDate, "to": formattedEndDate});
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.stationSalesRevenueReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response =
          await reportSummaryRepo.stationSalesRevenueReport(data);

      if (response.statusCode == 200) {
        log("------------: stationSalesRevenueReport");
        allStationSalesData.value =
            response.body["station_revenue_report"]['station_revenue'];

        stationSales.value =
            response.body["station_revenue_report"]['total_sales'];
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: Station Sales Revenue Report - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching Station Sales Revenue Report API: $e");
    } finally {
      isLoadingStationSales(false);
    }
  }

  Future<void> stationSalesRevenueReportDetails(
      int timeframe, String name) async {
    isLoadingStationSalesDetails(true);
    final sharedPreferences = await SharedPreferences.getInstance();
    userdata.token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      // Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      // String formattedStartDate = dateRange['startDate'];
      // String formattedEndDate = dateRange['endDate'];
      // Use custom date range if set, otherwise use timeframe
      String formattedStartDate;
      String formattedEndDate;
      if (isStationCustomDateRange.value) {
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(stationFromDate.value);
        formattedEndDate = DateFormat('yyyy-MM-dd').format(stationToDate.value);
      } else {
        setDateRange(reportList[timeframe], section: 'station');
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(stationFromDate.value);
        formattedEndDate = DateFormat('yyyy-MM-dd').format(stationToDate.value);
      }
      // var data = json.encode({
      //   "from": formattedStartDate,
      //   "to": formattedEndDate,
      //   "station_name": "$name"
      // });
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.stationSalesRevenueReportDetails}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
        "station_name": "$name"
      };

      Response response =
          await reportSummaryRepo.stationSalesRevenueReportDetails(data);

      if (response.statusCode == 200) {
        log("------------: stationSalesRevenueReportDetails");
        allStationSalesDataDetail.value = response.body;
        allStationSalesDataDetails.value = response.body["item_details"];
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: Station Sales Revenue Report - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching Station Sales Revenue Report API: $e");
    } finally {
      isLoadingStationSalesDetails(false);
    }
  }

  Future<void> revenueReport(int timeframe) async {
    isLoadingAverageSales(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      Map<String, dynamic> dateRange = getDateRange(timeframe);
      String formattedStartDate = dateRange['startDate'];
      String formattedEndDate = dateRange['endDate'];
      // var data =
      //     json.encode({"from": formattedStartDate, "to": formattedEndDate});
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.revenueReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response = await reportSummaryRepo.revenueReport(data);

      if (response.statusCode == 200) {
        log("------------: revenueReport");
        // print("Response Data: ${response.data}");
        response.body["revenue"].forEach((element) {
          DateTime parsedDate = DateTime.parse(element["revenue_date"]);
          averageSalesDate[parsedDate] = element["total_sales"].toDouble();
        });
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: Revenue Report - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching Revenue Report API: $e");
    } finally {
      isLoadingAverageSales(false);
    }
  }

  Future<void> totalSalesReport(int timeframe) async {
    isLoadingTopSales(true);
    topSalesList.value = {};
    totalSalesCount.value = "0";
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      print(userdata.token);
      Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      String formattedStartDate = dateRange['startDate'];
      String formattedEndDate = dateRange['endDate'];
      String reportType = timeframe == 0
          ? "daily"
          : timeframe == 1
              ? "weekly"
              : timeframe == 2
                  ? "monthly"
                  : timeframe == 3
                      ? "6_month"
                      : "fy";
      // var data = json.encode({
      //   "from": formattedStartDate,
      //   "to": formattedEndDate,
      //   "report_type": reportType
      // });
      // print(data);
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.totalSales}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
        "report_type": reportType
      };

      print(data);

      Response response = await reportSummaryRepo.totalSalesReport(data);

      if (response.statusCode == 200) {
        // log("------------: totalSalesReport");
        // log("API DATA: ${response.data}");
        // if (response.data["sales_data"]["original"] != null) {
        //   generateChartData(response.data["sales_data"]["original"]);
        //   topSalesList.value = response.data["sales_data"]["original"];
        //   totalSalesCount.value =
        //       response.data["sales_data"]["original"]["total_sales"] != null
        //           ? response.data["sales_data"]["original"]["total_sales"]
        //               .toString()
        //           : ' 0.00';
        // } else {
        //   log("Original sales data null hai");
        //   totalSalesCount.value = "0.00";
        // }
        log("------------: totalSalesReport");
        log("API DATA: ${response.body}");

        final salesData = response.body["sales_data"];
        final original = salesData?["original"];

        if (original != null) {
          generateChartData(original);
          topSalesList.value = original;

          var totalSales = original["total_sales"];
          if (totalSales == null) {
            totalSalesCount.value = "0.00";
          } else if (totalSales is String) {
            totalSalesCount.value = totalSales;
          } else if (totalSales is num) {
            totalSalesCount.value = totalSales.toStringAsFixed(2);
          } else {
            totalSalesCount.value = "0.00";
          }
        } else {
          log("Original sales data null hai");
          totalSalesCount.value = "0.00";
        }
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: totalSalesReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching totalSalesReport: $e");
    } finally {
      isLoadingTopSales(false);
    }
  }

  Future<void> fetchInsightsSales(int timeframe) async {
    isLoadingInsightsSales(true);
    insightsTotalSales.value = "0.00";
    insightsDailyPoints.clear();
    try {
      final Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      final Map<String, dynamic> data = {
        "from_date": dateRange['startDate'],
        "to_date": dateRange['endDate'],
      };

      final Response response =
          await reportSummaryRepo.insightsSalesReport(data);

      if (response.statusCode == 200) {
        log("------------: insightsSalesReport");
        final raw = response.body;
        final Map<String, dynamic> body = raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
        final Map<String, dynamic> payload = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : <String, dynamic>{};
        final Map<String, dynamic> summary = payload['summary'] is Map
            ? Map<String, dynamic>.from(payload['summary'])
            : <String, dynamic>{};
        insightsTotalSales.value =
            _formatInsightsAmount(summary['total_revenue']);

        final List daily =
            payload['daily'] is List ? payload['daily'] as List : [];
        final Map<String, Map<String, dynamic>> byDate = {};
        for (final row in daily) {
          if (row is Map && row['date'] != null) {
            byDate[row['date'].toString()] = Map<String, dynamic>.from(row);
          }
        }

        final DateTime start = _insightsDate(dateRange['startDate']);
        final DateTime end = _insightsDate(dateRange['endDate']);
        final List<InsightsSalesPoint> points = [];
        double running = 0;
        for (DateTime day = start;
            !day.isAfter(end);
            day = DateTime(day.year, day.month, day.day + 1)) {
          final String key = DateFormat('yyyy-MM-dd').format(day);
          final Map<String, dynamic>? row = byDate[key];
          final double revenue = _parseInsightsDouble(row?['revenue']);
          final int orders = _parseInsightsInt(row?['orders']);
          running += revenue;
          points.add(InsightsSalesPoint(
            date: key,
            revenue: revenue,
            orders: orders,
            cumulative: running,
          ));
        }
        insightsDailyPoints.assignAll(points);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: insightsSalesReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching insightsSalesReport: $e");
    } finally {
      isLoadingInsightsSales(false);
    }
  }

  DateTime _insightsDate(String value) {
    final List<String> parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _formatInsightsAmount(dynamic value) {
    return _parseInsightsDouble(value).toStringAsFixed(2);
  }

  double _parseInsightsDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  int _parseInsightsInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt() ??
        0;
  }

  Future<void> topSoldCategory(int timeframe) async {
    isLoadingCategory(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      String formattedStartDate;
      String formattedEndDate;

      if (isCategoryCustomDateRange.value) {
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(categoryFromDate.value);
        formattedEndDate =
            DateFormat('yyyy-MM-dd').format(categoryToDate.value);
      } else {
        Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
        formattedStartDate = dateRange['startDate'];
        formattedEndDate = dateRange['endDate'];
      }

      // var data =
      //     json.encode({"from": formattedStartDate, "to": formattedEndDate});
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.salesCategoryReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response = await reportSummaryRepo.topSoldCategory(data);

      if (response.statusCode == 200) {
        log("------------: Fetch category_sales");
        topSalesCategoryList.value = response.body['category_sales'] ?? [];
      } else {
        log("API Failed: topSoldCategory - ${response.statusText}");
        ApiChecker.checkApi(response);
        // Get.snackbar(
        //     "Error", "Failed to fetch categories: ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching topSoldCategory: $e");
      Get.snackbar("Error", "Error fetching categories: $e");
    } finally {
      isLoadingCategory(false);
    }
  }

  Future<void> topSoldCategoryDetails(int timeframe, String id) async {
    isLoadingCategoryDetails(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };

      String formattedStartDate;
      String formattedEndDate;

      // if (isCategoryCustomDateRange.value) {
      //   formattedStartDate =
      //       DateFormat('yyyy-MM-dd').format(categoryFromDate.value);
      //   formattedEndDate =
      //       DateFormat('yyyy-MM-dd').format(categoryToDate.value);
      // } else {
      //   // Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      //   // String formattedStartDate = dateRange['startDate'];
      //   // String formattedEndDate = dateRange['endDate'];
      //   Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      //   formattedStartDate = dateRange['startDate'];
      //   formattedEndDate = dateRange['endDate'];
      // }
      if (isCategoryDetailsCustomDateRange.value) {
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(categoryDetailsFromDate.value);
        formattedEndDate =
            DateFormat('yyyy-MM-dd').format(categoryDetailsToDate.value);
      } else {
        // Use the dates from category_details section
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(categoryDetailsFromDate.value);
        formattedEndDate =
            DateFormat('yyyy-MM-dd').format(categoryDetailsToDate.value);
      }
      // print('${AppConstants.BASE_URL}');
      // var data = json.encode(
      //     {"from": formattedStartDate, "to": formattedEndDate, "cat_id": id});
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.salesCategoryReportDetails}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
        "cat_id": id
      };

      Response response = await reportSummaryRepo.topSoldCategoryDetails(data);

      if (response.statusCode == 200) {
        log("------------: Fetch category_sales");
        topSalesCategoryListDetails.value = response.body['food_sales_report'];
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: topSoldCategory - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching topSoldCategory: $e");
    } finally {
      isLoadingCategoryDetails(false);
    }
  }

  // Future<void> topCancelItems(int timeframe) async {
  //   isLoadingTopCancelledItems(true);
  //   try {
  //     var headers = {
  //       'Authorization': 'Bearer ${userdata.token}',
  //       'Content-Type': 'application/json'
  //     };
  //     Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
  //     String formattedStartDate = dateRange['startDate'];
  //     String formattedEndDate = dateRange['endDate'];

  //     var data =
  //         json.encode({"from": formattedStartDate, "to": formattedEndDate});
  //     var dio = Dio();
  //     var response = await dio.request(
  //       '${AppConstants.BASE_URL}${AppConstants.topCancelItemsReport}',
  //       options: Options(
  //         method: 'POST',
  //         headers: headers,
  //       ),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       log("------------: Fetch top_food_sales");
  //       print('${AppConstants.BASE_URL}');
  //       topCancelledItems.value = response.data['top_food_sales'];
  //     } else {
  //       log("API Failed: topCancelItems - ${response.statusMessage}");
  //     }
  //   } catch (e) {
  //     log("Error occurred while fetching topCancelItems: $e");
  //   } finally {
  //     isLoadingTopCancelledItems(false);
  //   }
  // }

  Future<void> topCancelItems(int timeframe) async {
    isLoadingTopCancelledItems(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      String formattedStartDate;
      String formattedEndDate;

      if (isCancelledCustomDateRange.value) {
        formattedStartDate =
            DateFormat('yyyy-MM-dd').format(cancelledFromDate.value);
        formattedEndDate =
            DateFormat('yyyy-MM-dd').format(cancelledToDate.value);
      } else {
        Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
        formattedStartDate = dateRange['startDate'];
        formattedEndDate = dateRange['endDate'];
      }

      Map<String, dynamic> body = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      if (selectedReasons.value != 'All Cancellation Stage') {
        body['cancel_type'] = selectedReasons.value == 'After Serving'
            ? 'Post-Serve'
            : 'Pre-Serve';
      }

      if (selectedWaiter.value != 'All Waiters' &&
          waiterIdMap[selectedWaiter.value] != null) {
        body['waiter_id'] = waiterIdMap[selectedWaiter.value];
      }

      if (selectedCancelReasons.value != 'All Reason') {
        int? reasonId = reasonIdMap[selectedCancelReasons.value];
        if (reasonId != null) {
          body['reason_type'] = reasonId;
        }
      }

      // var data = json.encode(body);
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.topCancelItemsReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Response response = await reportSummaryRepo.topCancelItems(body);

      if (response.statusCode == 200) {
        log("------------: Fetch top_food_sales");
        topCancelledItems.value = response.body['top_food_sales'] ?? [];
        filteredTopCancelItemList.value = topCancelledItems.value;
        await fetchWaiters();
        await fetchCancellationReasons();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: topCancelItems - ${response.statusText}");
        // Get.snackbar(
        //     "Error", "Failed to fetch canceled items: ${response.statusText}");
        topCancelledItems.value = [];
        filteredTopCancelItemList.value = [];
      }
    } catch (e) {
      log("Error occurred while fetching topCancelItems: $e");
      Get.snackbar("Error", "Error fetching canceled items: $e");
      topCancelledItems.value = [];
      filteredTopCancelItemList.value = [];
    } finally {
      isLoadingTopCancelledItems(false);
    }
  }

  // Function to fetch cancellation reasons
  Future<void> fetchCancellationReasons() async {
    try {
      Response response = await reportSummaryRepo.getCancellationReasons();

      if (response.statusCode == 200) {
        log("------------: Fetch cancellation reasons");
        cancellationReasons.value =
            List<Map<String, dynamic>>.from(response.body['reasons'] ?? []);

        // Build the reason ID map for dropdown
        reasonIdMap.clear();
        for (var reason in cancellationReasons) {
          reasonIdMap[reason['reason']] = reason['id'];
        }

        log("Reason ID Map: $reasonIdMap");
        log("Cancellation Reasons: ${cancellationReasons.length}");
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getCancellationReasons - ${response.statusText}");
        cancellationReasons.value = [];
      }
    } catch (e) {
      log("Error occurred while fetching cancellation reasons: $e");
      Get.snackbar("Error", "Error fetching cancellation reasons: $e");
      cancellationReasons.value = [];
    }
  }

  // Future<void> dailySalesRevenueReport(int timeframe) async {
  //   isLoadingCategory(true);
  //   try {
  //     var headers = {
  //       'Authorization': 'Bearer ${userdata?.token}',
  //       'Content-Type': 'application/json'
  //     };
  //     Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
  //     String formattedStartDate = dateRange['startDate'];
  //     String formattedEndDate = dateRange['endDate'];

  //     var data =
  //         json.encode({"from": formattedStartDate, "to": formattedEndDate});
  //     var dio = Dio();
  //     var response = await dio.request(
  //       '${AppConstants.BASE_URL}${AppConstants.dailySalesReport}',
  //       options: Options(
  //         method: 'POST',
  //         headers: headers,
  //       ),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       log("------------: Fetch daily report");
  //       dailySalesReport.value = response.data;
  //     } else {
  //       log("API Failed: dailySalesRevenueReport - ${response.statusMessage}");
  //     }
  //   } catch (e) {
  //     log("Error occurred while fetching dailySalesRevenueReport: $e");
  //   } finally {
  //     isLoadingCategory(false);
  //   }
  // }

  // Future<void> dailySalesItemsList(String date) async {
  //   isLoadingDailySalesListItems(true);
  //   try {
  //     var headers = {
  //       'Authorization': 'Bearer ${userdata?.token}',
  //       'Content-Type': 'application/json'
  //     };
  //     DateFormat originalFormat = DateFormat('d-M-yyyy');
  //     DateTime dateTime = originalFormat.parse(date);
  //     DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  //     String formattedDateString = outputFormat.format(dateTime);

  //     var data =
  //         json.encode({"from": formattedDateString, "to": formattedDateString});
  //     var dio = Dio();
  //     var response = await dio.request(
  //       '${AppConstants.BASE_URL}${AppConstants.dailySalesDetailsReport}',
  //       options: Options(
  //         method: 'POST',
  //         headers: headers,
  //       ),
  //       data: data,
  //     );
  //     print(data);
  //     if (response.statusCode == 200) {
  //       log("------------: Fetch daily sales item report");
  //       dailySalesList.value = response.data;
  //     } else {
  //       log("API Failed: dailySalesItemReport - ${response.statusMessage}");
  //     }
  //   } catch (e) {
  //     log("Error occurred while fetching dailySalesList: $e");
  //   } finally {
  //     isLoadingDailySalesListItems(false);
  //   }
  // }

  // DAILY SALES RELATED

  Future<void> dailySalesRevenueReport(int timeframe) async {
    isLoadingCategory(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      Map<String, dynamic> dateRange = getDateRangeForSales(timeframe);
      String formattedStartDate = dateRange['startDate'];
      String formattedEndDate = dateRange['endDate'];

      // var data = json.encode({
      //   "from": formattedStartDate,
      //   "to": formattedEndDate,
      // });
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
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      Response response = await reportSummaryRepo.dailySalesRevenueReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch daily report");
        dailySalesReport.value = response.body;
        filteredDailySalesReport.value = dailySalesReport.value['report'] ?? [];
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: dailySalesRevenueReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching dailySalesRevenueReport: $e");
    } finally {
      isLoadingCategory(false);
    }
  }

  Future<void> dailyWaiterSalesItemsList(String date) async {
    isLoadingDailyWaiterSalesListItems(true);

    try {
      if (userdata.token == null || userdata.token!.isEmpty) {
        log("No token found");
        // Get.snackbar(
        //   "Authentication Error",
        //   "Please log in again.",
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: ColorTheme.redColor,
        //   colorText: Colors.white,
        // );
        // Get.offAllNamed('/login');
        return;
      }
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      DateFormat originalFormat = DateFormat('d-M-yyyy');
      DateTime dateTime = originalFormat.parse(date);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedStartDate = outputFormat.format(fromDate.value);
      String formattedEndDate = outputFormat.format(toDate.value);

      Map<String, dynamic> body = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      if (selectedPaymentType.value ==null){
        selectedPaymentType.value = paymentTypes.first;
      }else if
      
      (selectedPaymentType.value != 'All Payment Types') {
        body['payment_method'] = selectedPaymentType.value!.name!.toLowerCase();
      }
      if (selectedOrderType.value != 'All Order Types') {
        if (selectedOrderType.value.trim() == 'Takeaway') {
          body['order_type'] = 'take_away';
        } else {
          body['order_type'] = selectedOrderType.value.trim().toLowerCase();
        }
      }

      // if (selectedWaiter.value != 'All Waiters' &&
      //     waiterIdMap[selectedWaiter.value] != null) {
      //   body['waiter_id'] = waiterIdMap[selectedWaiter.value];
      // }

      if (selectedOrderCollectedType.value != 'All Waiter Types') {
        if (selectedOrderCollectedType.value == 'Order By') {
          body['order_filter_by'] = 'order_by';
        } else if (selectedOrderCollectedType.value == 'Collected By') {
          body['order_filter_by'] = 'collect_by';
        }
      }
      // var data = json.encode(body);
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.dailyWaiterSalesReportDetails}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Response response =
          await reportSummaryRepo.dailyWaiterSalesItemsList(body);
      if (response.statusCode == 200) {
        log("------------: Fetch daily Waiter sales item report");
        dailyWaiterSalesList.value =
            DailyWaiterSalesResponse.fromJson(response.body);
        filteredWaiterDailySalesList.value =
            dailyWaiterSalesList.value?.dailyReports ?? [];
        // Fetch waiters list after loading sales data
        // await fetchWaiters();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: dailyWaiterSalesItemReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching dailyWaiterSalesList: $e");
    } finally {
      isLoadingDailyWaiterSalesListItems(false);
    }
  }

  Future<void> dailySalesItemsList(String date) async {
    isLoadingDailySalesListItems(true);
    final sharedPreferences = await SharedPreferences.getInstance();
    userdata.token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
    try {
      print('hello');
      print('${userdata.token}');
      if (userdata.token == null || userdata.token!.isEmpty) {
        log("No token found");
        return;
      }
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      DateFormat originalFormat = DateFormat('d-M-yyyy');
      DateTime dateTime = originalFormat.parse(date);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedStartDate = outputFormat.format(fromDate.value);
      String formattedEndDate = outputFormat.format(toDate.value);

      Map<String, dynamic> body = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      if (selectedPaymentType.value!.name != 'All Payment Types') {
        body['payment_method'] = selectedPaymentType.value!.name!.toLowerCase();
      }
      if (selectedOrderType.value != 'All Order Types') {
        if (selectedOrderType.value.trim() == 'Takeaway') {
          body['order_type'] = 'take_away';
        } else {
          body['order_type'] = selectedOrderType.value.trim().toLowerCase();
        }
      }

      if (selectedWaiter.value != 'All Waiters' &&
          waiterIdMap[selectedWaiter.value] != null) {
        body['waiter_id'] = waiterIdMap[selectedWaiter.value];
      }

      if (selectedOrderCollectedType.value != 'All Waiter Types') {
        if (selectedOrderCollectedType.value == 'Order By') {
          body['order_filter_by'] = 'order_by';
        } else if (selectedOrderCollectedType.value == 'Collected By') {
          body['order_filter_by'] = 'collect_by';
        }
      }

      if (prePaid.value != postPaid.value) {
        if (prePaid.value == false) {
          body['payment_for'] = 'postpaid';
        } else if (postPaid.value == false) {
          body['payment_for'] = 'prepaid';
        }
      }
      print('Pre Paid: ${prePaid.value}');
      print('Post Paid: ${postPaid.value}');

      print("DailySalesRevenueReport Body: $body");

      // var data = json.encode(body);
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.dailySalesReportDetails}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Response response = await reportSummaryRepo.dailySalesItemsList(body);
      if (response.statusCode == 200) {
        log("------------: Fetch daily sales item report");
        dailySalesList.value = DailySalesResponse.fromJson(response.body);
        filteredDailySalesList.value = dailySalesList.value?.dailyReports ?? [];
        // Fetch waiters list after loading sales data
        await fetchWaiters();
        await dailySalesItemsListReport(date);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: dailySalesItemReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching dailySalesList: $e");
    } finally {
      isLoadingDailySalesListItems(false);
    }
  }

  exportDailySalesItemWiseList(Map<String, dynamic> jsonData) async {
    try {
      isLoadingDailySalesListItems(true);
      update();
      final response =
          await reportSummaryRepo.exportDailySalesItemWiseList(jsonData);
      if (response.statusCode == 200) {
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } catch (e) {
      log("bulkExport :$e");
    } finally {
      isLoadingDailySalesListItems(false);
      update();
    }
  }

  void filterDailySaleItems(String query) {
    if (query.isEmpty) {
      filteredDailySalesList.value = dailySalesList.value?.dailyReports ?? [];
    } else {
      final searchLower = query.toLowerCase();

      // Collect all matching reports across all daily items
      List<DailyReport> filtered = [];

      for (var dailyItem in (dailySalesList.value?.dailyReports ?? [])) {
        final matchingReports = dailyItem.report?.where((r) {
              final id = r.restaurantOrderId?.toString().toLowerCase() ?? '';
              return id.contains(searchLower);
            }).toList() ??
            [];

        if (matchingReports.isNotEmpty) {
          // Create new DailyReport with only filtered reports
          filtered.add(DailyReport(
            report: matchingReports,
            // Copy other necessary fields from dailyItem
          ));
        }
      }

      filteredDailySalesList.value = filtered;
    }

    update();
    filteredDailySalesList.refresh();
  }

  Future<void> dailySalesItemsListReport(String date) async {
    isLoadingDailySalesListItems(true);
    print('This is daily sales list report');

    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };
      DateFormat originalFormat = DateFormat('d-M-yyyy');
      DateTime dateTime = originalFormat.parse(date);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedStartDate = outputFormat.format(fromDate.value);
      String formattedEndDate = outputFormat.format(toDate.value);

      Map<String, dynamic> body = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      if (selectedPaymentType.value != 'All Payment Types') {
        body['payment_method'] = selectedPaymentType.value!.name!.toLowerCase();
      }
      if (selectedOrderType.value != 'All Order Types') {
        if (selectedOrderType.value.trim() == 'Takeaway') {
          body['order_type'] = 'take_away';
        } else {
          body['order_type'] = selectedOrderType.value.trim().toLowerCase();
        }
      }

      if (selectedWaiter.value != 'All Waiters' &&
          waiterIdMap[selectedWaiter.value] != null) {
        body['waiter_id'] = waiterIdMap[selectedWaiter.value];
      }

      if (selectedOrderCollectedType.value != 'All Waiter Types') {
        if (selectedOrderCollectedType.value == 'Order By') {
          body['order_filter_by'] = 'order_by';
        } else if (selectedOrderCollectedType.value == 'Collected By') {
          body['order_filter_by'] = 'collect_by';
        }
      }

      if (prePaid.value != postPaid.value) {
        if (prePaid.value == false) {
          body['payment_for'] = 'postpaid';
        } else if (postPaid.value == false) {
          body['payment_for'] = 'prepaid';
        }
      }
      print('Pre Paid: ${prePaid.value}');
      print('Post Paid: ${postPaid.value}');

      print("DailySalesRevenueReport Body: $body");

      // var data = json.encode(body);
      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.dailySalesReportDetailsReport}',
      //   options: Options(
      //     method: 'POST',
      //     headers: headers,
      //   ),
      //   data: data,
      // );
      Response response =
          await reportSummaryRepo.dailySalesItemsListReport(body);
      if (response.statusCode == 200) {
        log("------------: Fetch daily sales item Excel report");
        dailySalesListReport.value = DailySalesResponse.fromJson(response.body);
        filteredDailySalesListReport.value =
            dailySalesListReport.value?.dailyReports ?? [];
        // Fetch waiters list after loading sales data
        await fetchWaiters();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: dailySalesItemExcelReport - ${response.statusText}");
      }
    } catch (e) {
      log("Error occurred while fetching dailySalesListReport: $e");
    } finally {
      isLoadingDailySalesListItems(false);
    }
  }

  Future<void> fetchWaiters() async {
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        // 'Content-Type': 'application/json'
      };
      print("Headers being sent: $headers");

      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.GET_WAITER_LIST}',
      //   options: Options(
      //     method: 'GET',
      //     headers: headers,
      //   ),
      //   // data: json.encode({}),
      // );
      Response response = await reportSummaryRepo.fetchWaiters();

      if (response.statusCode == 200) {
        log("------------: Fetch waiters list");
        var employeeData = response.body;
        waiters.clear();
        waiterIdMap.clear();
        waiters.add('All Waiters');
        waiterIdMap['All Waiters'] = '';
        if (employeeData['data'] != null) {
          var employeeList = employeeData['data'] as List;
          print("Employee List: $employeeList");
          for (var employee in employeeList) {
            String name = employee['name']?.toString() ?? 'Unknown';
            String id = employee['id']?.toString() ?? '';
            waiters.add(name);
            waiterIdMap[name] = id;
          }
        } else {
          print("Restaurant-employee-list key not found in response");
        }
        print(
            "Final Waiters list in ReportSummeryController: ${waiters.value}");
        print("Waiter ID Map: ${waiterIdMap.value}");
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: fetchWaiters - ${response.statusText}");
        // Get.snackbar(
        //     "Error", "Failed to fetch waiters: ${response.statusText}");
        waiters.clear();
        waiters.add('All Waiters');
        waiterIdMap['All Waiters'] = '';
        print("Using fallback waiters list: ${waiters.value}");
      }
    } catch (e) {
      log("Error occurred while fetching waiters: $e");
      Get.snackbar("Error", "Error fetching waiters: $e");
      waiters.clear();
      waiters.add('All Waiters');
      waiterIdMap['All Waiters'] = '';
      print("Using fallback waiters list due to error: ${waiters.value}");
    }
  }

  // Method to apply client-side filtering for DailyReportScreen
  void applyFiltersForDailyReport() {
    List<dynamic> filteredData = dailySalesReport.value['report'] ?? [];
    if (selectedPaymentType.value!.name!.isNotEmpty) {
      filteredData = filteredData
          .where((item) =>
              item['payment_type']?.toString().toLowerCase() ==
              selectedPaymentType.value!.name!.toLowerCase())
          .toList();
    }
    if (selectedOrderType.value.isNotEmpty) {
      filteredData = filteredData
          .where((item) =>
              item['order_type']?.toString().toLowerCase() ==
              selectedOrderType.value.toLowerCase())
          .toList();
    }
    filteredDailySalesReport.value = filteredData;
  }

  // Method to apply client-side filtering for DailySalesDetailsReport
  // void applyFiltersForDailySalesDetails() {
  //   List<dynamic> filteredData = dailySalesList.value['report'] ?? [];
  //   print(
  //       "Applying filters - Payment: ${selectedPaymentType.value}, Order: ${selectedOrderType.value}, Waiter: ${selectedWaiter.value}");
  //   print("Original data: $filteredData");

  //   // Apply payment type filter
  //   if (selectedPaymentType.value.isNotEmpty &&
  //       selectedPaymentType.value != 'All Payment Types') {
  //     filteredData = filteredData.where((item) {
  //       bool matches = item['payment_type']?.toString().toLowerCase() ==
  //           selectedPaymentType.value.toLowerCase();
  //       print(
  //           "Checking payment_type: ${item['payment_type']} against ${selectedPaymentType.value}, Matches: $matches");
  //       return matches;
  //     }).toList();
  //     print("Filtered by payment type: $filteredData");
  //   }

  //   Map<String, List<String>> orderTypeGroups = {
  //     'DineIn': ['DineIn', 'POS', 'WalkIn'],
  //     'Delivery': ['Delivery'],
  //     'Takeaway': ['Takeaway'],
  //   };

  //   // Apply order type filter
  //   // if (selectedOrderType.value.isNotEmpty &&
  //   //     selectedOrderType.value != 'All Order Types') {
  //   //   filteredData = filteredData.where((item) {
  //   //     bool matches = item['order_type']?.toString().toLowerCase() ==
  //   //         selectedOrderType.value.toLowerCase();
  //   //     print(
  //   //         "Checking order_type: ${item['order_type']} against ${selectedOrderType.value}, Matches: $matches");
  //   //     return matches;
  //   //   }).toList();
  //   //   print("Filtered by order type: $filteredData");
  //   // }
  //   if (selectedOrderType.value.isNotEmpty &&
  //       selectedOrderType.value != 'All Order Types') {
  //     List<String> allowedTypes =
  //         orderTypeGroups[selectedOrderType.value] ?? [selectedOrderType.value];

  //     filteredData = filteredData.where((item) {
  //       String itemType = item['order_type']?.toString().toLowerCase() ?? '';
  //       bool matches =
  //           allowedTypes.map((e) => e.toLowerCase()).contains(itemType);
  //       print(
  //           "Checking order_type: $itemType against group ${allowedTypes}, Matches: $matches");
  //       return matches;
  //     }).toList();

  //     print("Filtered by order type: $filteredData");
  //   }

  //   //// Apply waiter filter
  //   if (selectedWaiter.value.isNotEmpty &&
  //       selectedWaiter.value != 'All Waiters') {
  //     filteredData = filteredData.where((item) {
  //       String waiterName =
  //           item['waiter']?.toString().trim().toLowerCase() ?? '';
  //       String collectedBy = item['collected_by']
  //               ?.toString()
  //               .replaceAll(' ', '')
  //               .toLowerCase() ??
  //           '';
  //       String selected =
  //           selectedWaiter.value.replaceAll(' ', '').toLowerCase();

  //       print(
  //           "Waiter: '$waiterName', Collected By (no space): '$collectedBy', Selected: '$selected'");

  //       bool matches = waiterName == selected || collectedBy == selected;

  //       print("Matches waiter or collected_by: $matches");
  //       return matches;
  //     }).toList();

  //     print("Filtered by waiter/collected_by: $filteredData");
  //   }

  //   filteredDailySalesList.value = filteredData;

  //   print("Final filtered data: ${filteredDailySalesList.value}");
  // }

  void applyFiltersForTopCancelItems() {
    if (isCancelledCustomDateRange.value) {
      topCancelItems(-1);
    } else {
      topCancelItems(topCancelledItemsSelect.value);
    }
  }

  void resetFilterStationSales() {
    stationFromDate.value = DateTime.now();
    stationToDate.value = DateTime.now();
    isStationCustomDateRange.value = false;
  }

  void resetFilterCancelItems() {
    cancelledFromDate.value = DateTime.now();
    cancelledToDate.value = DateTime.now();
    isCancelledCustomDateRange.value = false;
    resetFiltersForTopCancelItems();
  }

  void resetFilterTopSoldItems() {
    itemsFromDate.value = DateTime.now();
    itemsToDate.value = DateTime.now();
    isItemsCustomDateRange.value = false;
  }

  void resetFilterTopCategory() {
    categoryFromDate.value = DateTime.now();
    categoryToDate.value = DateTime.now();
    isCategoryCustomDateRange.value = false;
  }

  void resetFilters() {
    fromDate.value = DateTime.now();
    toDate.value = DateTime.now();
    resetFiltersForDailyRevenueReport();
  }

  void resetFiltersForTopCancelItems() {
    cancelledFromDate.value = DateTime.now();
    cancelledToDate.value = DateTime.now();

    selectedReasons.value = 'All Cancellation Stage';
    selectedWaiter.value = 'All Waiters';
    selectedCancelReasons.value = 'All Reason';
    topCancelledItemsSelect.value = 0;
    isCancelledCustomDateRange.value = true;
    showFilterPanel.value = false;

    applyFiltersForTopCancelItems();
  }

  void resetFiltersForDailyRevenueReport() {
    // // Reset date range
    // fromDate.value = DateTime.now();
    // toDate.value = DateTime.now();

    // Reset filters
    selectedOrderType.value = 'All Order Types';
    selectedPaymentType.value = paymentTypes.first;
    selectedWaiter.value = 'All Waiters';
    selectedOrderCollectedType.value = 'All Waiter Types';
    prePaid.value = true;
    postPaid.value = true;

    dailySalesItemsList(DateFormat('d-M-yyyy').format(DateTime.now()));

    // showFilterPanel.value = false;
  }

  void resetFiltersForDailyWaiterRevenueReport() {
    selectedOrderType.value = 'All Order Types';
    selectedPaymentType.value = paymentTypes.first;
    selectedOrderCollectedType.value = 'All Waiter Types';

    dailyWaiterSalesItemsList(DateFormat('d-M-yyyy').format(DateTime.now()));

    showFilterPanel.value = false;
  }

  Future<void> fetchOrderDetails(String? orderId) async {
    orderDetails.value = {};
    isLoadingOrderDetails(true);
    try {
      var headers = {
        'Authorization': 'Bearer ${userdata.token}',
        'Content-Type': 'application/json'
      };

      // var dio = Dio();
      // var response = await dio.request(
      //   '${AppConstants.BASE_URL}${AppConstants.ORDER_DETAILS}$orderId',
      //   options: Options(
      //     method: 'GET',
      //     headers: headers,
      //   ),
      // );
      Response response = await reportSummaryRepo.fetchOrderDetails(orderId);
      print("Order Details API Response Status Code: ${response.statusCode}");
      print("Order Details API Response Data: ${response.body}");

      if (response.statusCode == 200) {
        log("------------: Fetch order details");
        orderDetails.value = response.body;
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: fetchOrderDetails - ${response.statusText}");
        print("Response Body on Failure: ${response.body}");
        // Get.snackbar("Error",
        //     "Failed to fetch order details: ${response.statusText}");
        orderDetails.value = {};
      }
    } catch (e) {
      log("Error occurred while fetching order details: $e");
      Get.snackbar("Error", "Error fetching order details: $e");
      orderDetails.value = {};
    } finally {
      isLoadingOrderDetails(false);
    }
  }

  Future<void> fetchAggregatorOrderDetails(dynamic orderId) async {
    aggregatorOrderDetails.value = {};
    isLoadingAggregatorOrderDetails(true);
    try {
      Response response =
          await reportSummaryRepo.fetchAggregatorOrderDetails(orderId);
      print(
          "Aggregator Order Details API Response Status Code: ${response.statusCode}");
      print("Aggregator Order Details API Response Data: ${response.body}");

      if (response.statusCode == 200) {
        log("------------: Fetch aggregator order details");
        aggregatorOrderDetails.value = response.body;
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: fetchAggregatorOrderDetails - ${response.statusText}");
        aggregatorOrderDetails.value = {};
      }
    } catch (e) {
      log("Error occurred while fetching aggregator order details: $e");
      Get.snackbar("Error", "Error fetching order details: $e");
      aggregatorOrderDetails.value = {};
    } finally {
      isLoadingAggregatorOrderDetails(false);
    }
  }

  void generateChartData(var items) {
    List<BarChartGroupData> data = [];

    newMaxY.value = 0.0;

    final DateTime now = DateTime.now();

    // double parseDouble(String value) {
    //   return double.tryParse(value.replaceAll(",", "") ?? "0.0") ?? 0.0;
    // }
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      String stringValue = value.toString().replaceAll(",", "");
      return double.tryParse(stringValue) ?? 0.0;
    }

    BarChartGroupData createBarGroup(
        int index, double y1, double y2, double y3, double y4, double spacing) {
      newMaxY.value =
          [newMaxY.value, y1, y2, y3].reduce((a, b) => a > b ? a : b);
      return barGroup(index, y1, y2, y3, y4, spacing);
    }

    switch (selected.value) {
      case 0: // Hourly Data
        int currentHour = now.hour;
        for (int i = 0; i < 24; i++) {
          Map<String, dynamic> salesForDate =
              items["hourly_sales"].toString() == "[]"
                  ? {}
                  : items["hourly_sales"]
                          .containsKey('${i.toString().padLeft(2, '0')}')
                      ? items["hourly_sales"][i.toString().padLeft(2, '0')]
                      : {};

          double y1 = parseDouble(salesForDate["paid_revenue"].toString());
          double y2 = parseDouble(salesForDate["running_order"].toString());
          double y3 = parseDouble(salesForDate["unpaid_revenue"].toString());
          double y4 = parseDouble(salesForDate["total_sales"].toString());

          data.add(createBarGroup(i, y1, y2, y3, y4, 8));
        }
        break;

      case 1: // Weekly Data (Last 7 Days)
        List<String> last7Days = List.generate(7, (index) {
          final DateTime day =
              now.subtract(Duration(days: 1)).subtract(Duration(days: index));
          return "${day.year}-${day.month.toString().padLeft(2, "0")}-${day.day.toString().padLeft(2, "0")}";
        }).reversed.toList();
        for (int i = 0; i < last7Days.length; i++) {
          // Map<String, dynamic> salesForDate =
          //     items["weekly_sales"].toString() == '[]'
          //         ? {}
          //         : items["weekly_sales"]?.firstWhere(
          //             (entry) => entry["date"] == last7Days[i],
          //             orElse: () => <String, dynamic>{},
          //           );
          Map<String, dynamic> salesForDate =
              items["weekly_sales"]?.isEmpty ?? true
                  ? {}
                  : items["weekly_sales"]?.firstWhere(
                        (entry) => entry["date"] == last7Days[i],
                        orElse: () => <String, dynamic>{},
                      ) ??
                      {};

          double y1 = parseDouble(salesForDate["paid_revenue"]);
          double y2 = parseDouble(salesForDate["running_order"]);
          double y3 = parseDouble(salesForDate["unpaid_revenue"]);
          double y4 = parseDouble(salesForDate["total_sales"].toString());

          data.add(createBarGroup(i, y1, y2, y3, y4, 25));
        }
        break;

      case 2: // Monthly Data (Up to Today)
        DateTime previousMonth = DateTime(now.year, now.month - 1, 1);
        int daysInMonth =
            DateTime(previousMonth.year, previousMonth.month + 1, 1)
                .subtract(Duration(days: 1))
                .day;
        for (int i = 1; i <= daysInMonth; i++) {
          String dateStr =
              "${previousMonth.year}-${(previousMonth.month).toString().padLeft(2, "0")}-${i.toString().padLeft(2, "0")}";
          // Map<String, dynamic> salesForDate =
          //     items["monthly_sales"].toString() == '[]'
          //         ? {}
          //         : items["monthly_sales"]?.firstWhere(
          //             (entry) => entry["date"] == dateStr,
          //             orElse: () => <String, dynamic>{},
          //           );
          Map<String, dynamic> salesForDate =
              items["monthly_sales"]?.isEmpty ?? true
                  ? {}
                  : items["monthly_sales"]?.firstWhere(
                        (entry) => entry["date"] == dateStr,
                        orElse: () => <String, dynamic>{},
                      ) ??
                      {};

          double y1 = parseDouble(salesForDate["paid_revenue"]);
          double y2 = parseDouble(salesForDate["running_order"]);
          double y3 = parseDouble(salesForDate["unpaid_revenue"]);
          double y4 = parseDouble(salesForDate["total_sales"].toString());

          data.add(createBarGroup(i, y1, y2, y3, y4, 5));
        }
        break;

      case 3: // Last 6 Months Data
        List<String> last6Months = List.generate(6, (index) {
          final DateTime month = DateTime(now.year, now.month - index - 1, 1);
          return "${DateFormat.MMM().format(month)} ${month.year}";
        }).reversed.toList();
        for (int i = 0; i < last6Months.length; i++) {
          Map<String, dynamic> salesForDate =
              items["six_month_sales"].toString() == '[]'
                  ? {}
                  : items["six_month_sales"]?.firstWhere(
                      (entry) => entry["month"] == last6Months[i],
                      orElse: () => <String, dynamic>{},
                    );

          double y1 = parseDouble(salesForDate["paid_revenue"]);
          double y2 = parseDouble(salesForDate["running_order"]);
          double y3 = parseDouble(salesForDate["unpaid_revenue"]);
          double y4 = parseDouble(salesForDate["total_sales"].toString());

          data.add(createBarGroup(i, y1, y2, y3, y4, 25));
        }
        break;

      case 4: // Financial Year Data
        int currentMonth = now.month;
        DateTime startOfFinYear = currentMonth >= 4
            ? DateTime(now.year, 4, 1)
            : DateTime(now.year - 1, 4, 1);

        List<String> finMonths = List.generate(12, (index) {
          DateTime month =
              DateTime(startOfFinYear.year, startOfFinYear.month + index, 1);
          return "${DateFormat.MMM().format(month)} ${month.year}";
        });

        for (int i = 0; i < finMonths.length; i++) {
          Map<String, dynamic> salesForDate =
              items["financial_year_sales"].toString() == '[]'
                  ? {}
                  : items["financial_year_sales"]?.firstWhere(
                      (entry) => entry["month"] == finMonths[i],
                      orElse: () => <String, dynamic>{},
                    );

          double y1 = parseDouble(salesForDate["paid_revenue"]);
          double y2 = parseDouble(salesForDate["running_order"]);
          double y3 = parseDouble(salesForDate["unpaid_revenue"]);
          double y4 = parseDouble(salesForDate["total_sales"].toString());

          data.add(createBarGroup(i, y1, y2, y3, y4, 15));
        }
        break;

      default:
        break;
    }
    chartData.value = data;
  }

  BarChartGroupData barGroup(
      int x, double y1, double y2, double y3, double y4, double width) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          toY: y2,
          color: ColorTheme.orangeColor,
          width: width,
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: y4,
          color: ColorTheme.orangeColor,
          width: width,
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: y3,
          color: ColorTheme.redColor,
          width: width,
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: y1,
          color: ColorTheme.greenColor,
          width: width,
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ColorTheme.greyColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    final List<String> hourlyLabels = List.generate(24, (hour) {
      final suffix = hour >= 12 ? "PM" : "AM";
      final displayHour = hour == 0
          ? 12
          : hour > 12
              ? hour - 12
              : hour;
      return "$displayHour $suffix";
    });

    Widget text;
    switch (selected.value) {
      // case 0: // Daily (12 PM to 12 AM)
      //   if (value.toInt() == 0 || value.toInt() == 23) {
      //     text = const Text('  12 AM', style: style);
      //   } else if (value.toInt() == 12) {
      //     text = const Text('12 PM    ', style: style);
      //   } else {
      //     text = const Text('', style: style);
      //   }
      //   break;
      case 0: // Hourly labels: 12AM, 4AM, 8AM, 12PM, 4PM, 8PM
        final int hour = value.toInt();
        // Show labels only for 0, 4, 8, 12, 16, 20
        if ([0, 4, 8, 12, 16, 20].contains(hour)) {
          text = Text(hourlyLabels[hour], style: style);
        } else {
          text = const Text('');
        }
        break;

      case 1: // Weekly (Last 7 Days)
        final DateTime today = DateTime.now();
        // Generate a list of the last 7 days
        final List<String> last7Days = List.generate(
          7,
          (index) => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][today
                  .subtract(Duration(days: 1))
                  .subtract(Duration(days: index))
                  .weekday %
              7],
        ).reversed.toList(); // Reverse to show in chronological order

        if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
          text = Text(last7Days[value.toInt()], style: style);
        } else {
          text = const Text('', style: style);
        }
        break;

      case 2:
        int lastDate = DateTime(DateTime.now().year, DateTime.now().month, 1)
            .subtract(Duration(days: 1))
            .day;
        int centerDate = (lastDate / 2).round();
        if (value.toInt() == 1 ||
            value.toInt() == centerDate ||
            value.toInt() == lastDate) {
          text = Text('${value.toInt()}', style: style);
        } else {
          text = const Text('', style: style);
        }
        break;

      case 3:
        final DateTime now = DateTime.now();
        final List<String> last6Months = List.generate(
          6,
          (index) {
            final DateTime month = DateTime(now.year, now.month - index - 1, 1);
            return DateFormat.MMM().format(month);
          },
        ).reversed.toList();

        if (value.toInt() >= 0 && value.toInt() < last6Months.length) {
          text = Text(last6Months[value.toInt()], style: style);
        } else {
          text = const Text('', style: style);
        }
        break;

      case 4:
        final DateTime now = DateTime.now();
        final int currentMonth = now.month;

        final DateTime startOfFinYear = currentMonth >= 4
            ? DateTime(now.year, 4, 1)
            : DateTime(now.year - 1, 4, 1);

        final List<String> finMonths = List.generate(
          12,
          (index) {
            final DateTime month =
                DateTime(startOfFinYear.year, startOfFinYear.month + index, 1);
            return DateFormat.MMM().format(month);
          },
        );

        if (value.toInt() >= 0 && value.toInt() < finMonths.length) {
          text = Text(finMonths[value.toInt()], style: style);
        } else {
          text = const Text('', style: style);
        }
        break;

      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      // meta: meta,
      space: 10,
      child: text,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ColorTheme.greyColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text = '${value.toInt()}';
    return Text(text, style: style);
  }

  void showCustomBottomSheet(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBottomSheet(
          selectedDay: selectedDay,
          firstDay: firstDay,
          lastDay: lastDay,
        );
      },
    );
  }

  //---------------------------------- Profit Loss Report ----------------------------------//

  RxList<Map<String, dynamic>> profitLossRows = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> profitLossSummary = <String, dynamic>{}.obs;
  var isLoadingProfitLoss = false.obs;

  Future<void> getProfitLossReport(String fromDate, String toDate) async {
    isLoadingProfitLoss(true);

    try {
      Map<String, dynamic> data = {
        "from": fromDate,
        "to": toDate,
      };

      Response response = await reportSummaryRepo.getProfitLossReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch profit_loss_report success");

        final map = response.body as Map;
        final report = (map['report'] as List?)?.cast<Map>().map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        profitLossRows.value = report ?? [];
        profitLossSummary.value =
            Map<String, dynamic>.from(map['summary'] ?? {});
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getProfitLossReport - ${response.statusText}");
        profitLossRows.clear();
        profitLossSummary.clear();
      }
    } catch (e) {
      log("Error occurred while fetching getProfitLossReport: $e");
      profitLossRows.clear();
      profitLossSummary.clear();
      Get.snackbar("Error", "Error fetching profit loss report: $e",
          colorText: Colors.white, backgroundColor: Colors.red);
    } finally {
      isLoadingProfitLoss(false);
    }
  }
  //---------------------------------- Profit Loss Report ----------------------------------//

  //---------------------------------- Item Wise Variation Report ----------------------------------//
  RxList<dynamic> variationSalesReportList = [].obs;
  RxList<dynamic> filteredVariationSalesReportList = [].obs;
  TextEditingController variationSearchController = TextEditingController();
  var isLoadingVariationSalesReport = false.obs;

  //---------------------------------- Item Wise Addon Report ----------------------------------//
  RxList<dynamic> addonSalesReportList = [].obs;
  RxList<dynamic> filteredAddonSalesReportList = [].obs;
  TextEditingController addonSearchController = TextEditingController();
  var isLoadingAddonSalesReport = false.obs;

  Future<void> itemWiseVariationReport(DateTime from, DateTime to) async {
    isLoadingVariationSalesReport(true);
    try {
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(from);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(to);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response =
          await reportSummaryRepo.topFoodVariationSalesReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch top-food-variation-sales-report");
        var variationReport = response.body['variation_sales_report'] ?? [];
        variationSalesReportList.value = variationReport;
        filteredVariationSalesReportList.value = variationReport;
        variationSalesReportList.refresh();
        filteredVariationSalesReportList.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: top-food-variation-sales-report - ${response.statusText}");
        variationSalesReportList.clear();
        filteredVariationSalesReportList.clear();
      }
    } catch (e) {
      log("Error occurred while fetching top-food-variation-sales-report: $e");
      variationSalesReportList.clear();
      filteredVariationSalesReportList.clear();
    } finally {
      isLoadingVariationSalesReport(false);
    }
  }

  void filterVariationSalesReport(String query) {
    if (query.isEmpty) {
      filteredVariationSalesReportList.value = variationSalesReportList;
    } else {
      filteredVariationSalesReportList.value =
          variationSalesReportList.where((item) {
        final foodItem = item['food_item']?.toString().toLowerCase() ?? '';
        final variationGroup =
            item['variation_group']?.toString().toLowerCase() ?? '';
        final variationLabel =
            item['variation_label']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return foodItem.contains(searchLower) ||
            variationGroup.contains(searchLower) ||
            variationLabel.contains(searchLower);
      }).toList();
      update();
      filteredVariationSalesReportList.refresh();
    }
  }

  Future<void> itemWiseAddonReport(DateTime from, DateTime to) async {
    isLoadingAddonSalesReport(true);
    update();
    try {
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(from);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(to);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response =
          await reportSummaryRepo.topFoodVariationSalesReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch top-food-variation-sales-report for addon");
        var addonReport = response.body['addon_sales_report'] ?? [];
        addonSalesReportList.value = addonReport;
        filteredAddonSalesReportList.value = addonReport;
        addonSalesReportList.refresh();
        filteredAddonSalesReportList.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: top-food-variation-sales-report for addon - ${response.statusText}");
        addonSalesReportList.clear();
        filteredAddonSalesReportList.clear();
      }
    } catch (e) {
      log("Error occurred while fetching top-food-variation-sales-report for addon: $e");
      addonSalesReportList.clear();
      filteredAddonSalesReportList.clear();
    } finally {
      isLoadingAddonSalesReport(false);
      update();
    }
  }

  void filterAddonSalesReport(String query) {
    if (query.isEmpty) {
      filteredAddonSalesReportList.value = addonSalesReportList;
    } else {
      filteredAddonSalesReportList.value = addonSalesReportList.where((item) {
        final addonName = item['addon_name']?.toString().toLowerCase() ?? '';
        final foodItem = item['food_item']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return addonName.contains(searchLower) ||
            foodItem.contains(searchLower);
      }).toList();
      update();
      filteredAddonSalesReportList.refresh();
    }
  }

  Future<void> downloadAddonReport(DateTime from, DateTime to) async {
    try {
      isLoadingAddonSalesReport(true);
      update();
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(from);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(to);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response =
          await reportSummaryRepo.topFoodVariationSalesReportDownload(data);

      if (response.statusCode == 200) {
        log("------------: Download top-food-variation-sales-report");
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: top-food-variation-sales-report-download - ${response.statusText}");
      }
      update();
    } catch (e) {
      log("Error occurred while downloading top-food-variation-sales-report: $e");
      appToast("Error downloading report: $e");
    } finally {
      isLoadingAddonSalesReport(false);
      update();
    }
  }

  Future<void> downloadVariationReport(DateTime from, DateTime to) async {
    try {
      isLoadingVariationSalesReport(true);
      update();
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(from);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(to);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate
      };

      Response response =
          await reportSummaryRepo.topFoodVariationSalesReportDownload(data);

      if (response.statusCode == 200) {
        log("------------: Download top-food-variation-sales-report");
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: top-food-variation-sales-report-download - ${response.statusText}");
      }
      update();
    } catch (e) {
      log("Error occurred while downloading top-food-variation-sales-report: $e");
      appToast("Error downloading report: $e");
    } finally {
      isLoadingVariationSalesReport(false);
      update();
    }
  }
  //---------------------------------- Item Wise Variation Report ----------------------------------//

  //---------------------------------- Order Audit Report ----------------------------------//
  RxList<Map<String, dynamic>> orderAuditReportList =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrderAuditReportList =
      <Map<String, dynamic>>[].obs;
  TextEditingController orderAuditSearchController = TextEditingController();
  var isLoadingOrderAuditReport = false.obs;
  String? orderAuditStartDate;
  String? orderAuditEndDate;

  Future<void> getOrderAuditReport({
    required String startDate,
    required String endDate,
  }) async {
    isLoadingOrderAuditReport(true);
    update();

    try {
      // Convert from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime startDateTime = inputFormat.parse(startDate);
      DateTime endDateTime = inputFormat.parse(endDate);

      String formattedStartDate = outputFormat.format(startDateTime);
      String formattedEndDate = outputFormat.format(endDateTime);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      Response response = await reportSummaryRepo.getOrderAuditReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch order-audit-report success");

        final List<dynamic> orders = response.body['orders'] ?? [];
        orderAuditReportList.value = orders.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();
        filteredOrderAuditReportList.value = orderAuditReportList.value;
        orderAuditReportList.refresh();
        filteredOrderAuditReportList.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getOrderAuditReport - ${response.statusText}");
        orderAuditReportList.clear();
        filteredOrderAuditReportList.clear();
      }
    } catch (e) {
      log("Error occurred while fetching getOrderAuditReport: $e");
      orderAuditReportList.clear();
      filteredOrderAuditReportList.clear();
      Get.snackbar(
        "Error",
        "Error fetching order audit report: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOrderAuditReport(false);
      update();
    }
  }

  void filterOrderAuditReport(String query) {
    if (query.isEmpty) {
      filteredOrderAuditReportList.value = orderAuditReportList.value;
    } else {
      filteredOrderAuditReportList.value =
          orderAuditReportList.value.where((item) {
        final orderId = item['order_id']?.toString().toLowerCase() ?? '';
        final paymentStatus =
            item['payment_status']?.toString().toLowerCase() ?? '';
        final paymentMethod =
            item['payment_method']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return orderId.contains(searchLower) ||
            paymentStatus.contains(searchLower) ||
            paymentMethod.contains(searchLower);
      }).toList();
    }
    update();
    filteredOrderAuditReportList.refresh();
  }

  Future<void> downloadOrderAuditReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      // Convert from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime startDateTime = inputFormat.parse(startDate);
      DateTime endDateTime = inputFormat.parse(endDate);

      String formattedStartDate = outputFormat.format(startDateTime);
      String formattedEndDate = outputFormat.format(endDateTime);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      Response response =
          await reportSummaryRepo.downloadOrderAuditReport(data);

      if (response.statusCode == 200) {
        log("------------: Download order-audit-report-excel success");
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: downloadOrderAuditReport - ${response.statusText}");
      }
      update();
    } catch (e) {
      log("Error occurred while downloading order audit report: $e");
      Get.snackbar(
        "Error",
        "Error downloading order audit report: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  //---------------------------------- Order Audit Report ----------------------------------//

  //---------------------------------- Order Cancel Report ----------------------------------//
  RxList<Map<String, dynamic>> orderCancelReportList =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrderCancelReportList =
      <Map<String, dynamic>>[].obs;
  TextEditingController orderCancelSearchController = TextEditingController();
  var isLoadingOrderCancelReport = false.obs;
  String? orderCancelStartDate;
  String? orderCancelEndDate;

  Future<void> getOrderCancelReport({
    required String startDate,
    required String endDate,
  }) async {
    isLoadingOrderCancelReport(true);
    update();

    try {
      // Convert from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime startDateTime = inputFormat.parse(startDate);
      DateTime endDateTime = inputFormat.parse(endDate);

      String formattedStartDate = outputFormat.format(startDateTime);
      String formattedEndDate = outputFormat.format(endDateTime);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      Response response = await reportSummaryRepo.getOrderCancelReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch order-cancel-report success");

        final List<dynamic> orders = response.body['orders'] ?? [];
        orderCancelReportList.value = orders.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();
        filteredOrderCancelReportList.value = orderCancelReportList.value;
        orderCancelStartDate = startDate;
        orderCancelEndDate = endDate;
        orderCancelReportList.refresh();
        filteredOrderCancelReportList.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getOrderCancelReport - ${response.statusText}");
        orderCancelReportList.clear();
        filteredOrderCancelReportList.clear();
        Get.snackbar(
          "Error",
          "Failed to fetch order cancel report: ${response.statusText}",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log("Error occurred while fetching getOrderCancelReport: $e");
      orderCancelReportList.clear();
      filteredOrderCancelReportList.clear();
      Get.snackbar(
        "Error",
        "Error fetching order cancel report: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOrderCancelReport(false);
      update();
    }
  }

  void filterOrderCancelReport(String query) {
    if (query.isEmpty) {
      filteredOrderCancelReportList.value = orderCancelReportList.value;
    } else {
      filteredOrderCancelReportList.value =
          orderCancelReportList.value.where((item) {
        final orderId = item['order_id']?.toString().toLowerCase() ?? '';
        final cancelledBy =
            item['cancelled_by']?.toString().toLowerCase() ?? '';
        final cancellationReason =
            item['cancellation_reason']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return orderId.contains(searchLower) ||
            cancelledBy.contains(searchLower) ||
            cancellationReason.contains(searchLower);
      }).toList();
    }
    update();
    filteredOrderCancelReportList.refresh();
  }

  Future<void> downloadOrderCancelReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      isLoadingOrderCancelReport(true);
      update();
      // Convert from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime startDateTime = inputFormat.parse(startDate);
      DateTime endDateTime = inputFormat.parse(endDate);

      String formattedStartDate = outputFormat.format(startDateTime);
      String formattedEndDate = outputFormat.format(endDateTime);

      Map<String, dynamic> data = {
        "from": formattedStartDate,
        "to": formattedEndDate,
      };

      Response response =
          await reportSummaryRepo.downloadOrderCancelReport(data);

      if (response.statusCode == 200) {
        log("------------: Download order-cancel-report-excel success");
        appLaunchUrl(response.body?["download_url"]);
        appToast(response.body?["message"]);
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: downloadOrderCancelReport - ${response.statusText}");
        Get.snackbar(
          "Error",
          "Failed to download order cancel report: ${response.statusText}",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      update();
    } catch (e) {
      log("Error occurred while downloading order cancel report: $e");
      Get.snackbar(
        "Error",
        "Error downloading order cancel report: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOrderCancelReport(false);
      update();
    }
  }
  //---------------------------------- Order Cancel Report ----------------------------------//

  //---------------------------------- Order Logs Report ----------------------------------//
  RxList<Map<String, dynamic>> orderLogsList = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> originalOrderLogsList = <Map<String, dynamic>>[];
  RxMap<String, List<Map<String, dynamic>>> groupedOrderLogs =
      <String, List<Map<String, dynamic>>>{}.obs;
  RxList<String> expandedOrderIds = <String>[].obs;
  TextEditingController orderLogsSearchController = TextEditingController();
  var isLoadingOrderLogsReport = false.obs;
  String? orderLogsStartDate;
  String? orderLogsEndDate;

  Future<void> getOrderLogsReport({
    required String startDate,
    required String endDate,
  }) async {
    isLoadingOrderLogsReport(true);
    update();

    try {
      // Convert from dd-MM-yyyy to yyyy-MM-dd for API
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      DateTime startDateTime = inputFormat.parse(startDate);
      DateTime endDateTime = inputFormat.parse(endDate);

      String formattedStartDate = outputFormat.format(startDateTime);
      String formattedEndDate = outputFormat.format(endDateTime);

      Map<String, dynamic> data = {
        "from_date": formattedStartDate,
        "to_date": formattedEndDate,
      };

      Response response = await reportSummaryRepo.getOrderLogsReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch order-logs-report success");

        final List<dynamic> logs = response.body['logs'] ?? [];
        final mappedLogs = logs.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        // Store original data for filtering
        originalOrderLogsList = List<Map<String, dynamic>>.from(mappedLogs);
        orderLogsList.value = mappedLogs;

        // Group logs by restaurant_order_id
        _groupLogsByOrderId();
        orderLogsList.refresh();
        groupedOrderLogs.refresh();
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getOrderLogsReport - ${response.statusText}");
        orderLogsList.clear();
        originalOrderLogsList.clear();
        groupedOrderLogs.clear();
        Get.snackbar(
          "Error",
          "Failed to fetch order logs: ${response.statusText}",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log("Error occurred while fetching getOrderLogsReport: $e");
      orderLogsList.clear();
      originalOrderLogsList.clear();
      groupedOrderLogs.clear();
      Get.snackbar(
        "Error",
        "Error fetching order logs: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingOrderLogsReport(false);
      update();
    }
  }

  void _groupLogsByOrderId() {
    groupedOrderLogs.clear();
    for (var log in orderLogsList) {
      final orderId =
          log['source_order']?['restaurant_order_id']?.toString() ?? 'Unknown';
      if (!groupedOrderLogs.containsKey(orderId)) {
        groupedOrderLogs[orderId] = [];
      }
      groupedOrderLogs[orderId]!.add(log);
    }
    // Sort logs within each group by created_at
    groupedOrderLogs.forEach((key, logs) {
      logs.sort((a, b) {
        final dateA = a['log_info']?['created_at']?.toString() ?? '';
        final dateB = b['log_info']?['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA); // Descending order (newest first)
      });
    });
  }

  void toggleOrderExpansion(String orderId) {
    if (expandedOrderIds.contains(orderId)) {
      expandedOrderIds.remove(orderId);
    } else {
      // Clear all other expanded orders (accordion behavior - only one expanded at a time)
      expandedOrderIds.clear();
      expandedOrderIds.add(orderId);
    }
    update();
  }

  bool isOrderExpanded(String orderId) {
    return expandedOrderIds.contains(orderId);
  }

  void filterOrderLogs(String query) {
    if (query.isEmpty) {
      // Restore original data when search is cleared
      orderLogsList.value =
          List<Map<String, dynamic>>.from(originalOrderLogsList);
      _groupLogsByOrderId();
    } else {
      final searchLower = query.toLowerCase();
      final filteredLogs = originalOrderLogsList.where((log) {
        final orderId = log['source_order']?['restaurant_order_id']
                ?.toString()
                .toLowerCase() ??
            '';
        final operation =
            log['log_info']?['operation']?.toString().toLowerCase() ?? '';
        final performedByName =
            log['performed_by']?['name']?.toString().toLowerCase() ?? '';
        final foodNames = (log['order_items_timing'] as List?)
                ?.map(
                    (item) => item['food_name']?.toString().toLowerCase() ?? '')
                .join(' ') ??
            '';

        return orderId.contains(searchLower) ||
            operation.contains(searchLower) ||
            performedByName.contains(searchLower) ||
            foodNames.contains(searchLower);
      }).toList();

      orderLogsList.value = filteredLogs;
      _groupLogsByOrderId();
    }
    update();
    groupedOrderLogs.refresh();
  }
  //---------------------------------- Order Logs Report ----------------------------------//
}
