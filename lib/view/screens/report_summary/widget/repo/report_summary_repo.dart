import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class ReportSummaryRepo {
  final ApiClient apiClient;

  ReportSummaryRepo({required this.apiClient});

  Future<Response> topSoldItems(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.topAllFoodSales, data);
  }

  Future<Response> stationSalesRevenueReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.stationSalesRevenueReport, data);
  }

  Future<Response> exportCancelReasonWiseReport(
      Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.cancelReasonWiseFoodExportReport, data);
  }

  Future<Response> exportDailySalesItemWiseList(
      Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.dailySalesItemWiseExportReport, data);
  }

  Future<Response> stationSalesRevenueReportDetails(
      Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.stationSalesRevenueReportDetails, data);
  }

  Future<Response> revenueReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.revenueReport, data);
  }

  Future<Response> totalSalesReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.totalSales, data);
  }

  Future<Response> insightsSalesReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.insightsSalesReport, data);
  }

  Future<Response> topSoldCategory(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.salesCategoryReport, data);
  }

  Future<Response> topSoldCategoryDetails(Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.salesCategoryReportDetails, data);
  }

  Future<Response> topCancelItems(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.topCancelItemsReport, data);
  }

  Future<Response> dailySalesRevenueReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.dailySalesReport, data);
  }

  Future<Response> dailyWaiterSalesItemsList(Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.dailyWaiterSalesReportDetails, data);
  }

  Future<Response> dailySalesItemsList(Map<String, dynamic>? data) async {
    return await apiClient.postData(AppConstants.dailySalesReportDetails, data);
  }

  Future<Response> dailySalesItemsListReport(Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.dailySalesReportDetailsReport, data);
  }

  Future<Response> fetchWaiters() async {
    return await apiClient.getData(AppConstants.GET_WAITER_LIST);
  }

  Future<Response> fetchOrderDetails(String? orderId) async {
    return await apiClient.getData('${AppConstants.ORDER_DETAILS}$orderId');
  }

  Future<Response> fetchAggregatorOrderDetails(dynamic orderId) async {
    return await apiClient.postData(
        AppConstants.DETAIL_FROM_SOCKET_SWIGGY_URI, {'order_id': orderId});
  }

  //---------------------------------- Profit Loss Report ----------------------------------//
  Future<Response> getProfitLossReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.profitLossReport, data);
  }

// Cancellation Reason
  Future<Response> getCancellationReasons(
      {int offset = 1, int limit = 5000}) async {
    return await apiClient.getData(
      '${AppConstants.GET_CANCEL_REASON_LIST_URI}',
    );
  }

  Future<Response> topFoodVariationSalesReport(
      Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.topFoodVariationSalesReport, data);
  }

  Future<Response> topFoodVariationSalesReportDownload(
      Map<String, dynamic>? data) async {
    return await apiClient.postData(
        AppConstants.topFoodVariationSalesReportDownload, data);
  }

  //---------------------------------- Order Audit Report ----------------------------------//
  Future<Response> getOrderAuditReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.orderAuditReport, data);
  }

  Future<Response> downloadOrderAuditReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.orderAuditReportExcel, data);
  }

  Future<Response> getOrderCancelReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.orderCancelReport, data);
  }

  Future<Response> downloadOrderCancelReport(Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.orderCancelReportDownload, data);
  }

  //---------------------------------- Order Logs Report ----------------------------------//
  Future<Response> getOrderLogsReport(Map<String, dynamic> data) async {
    return await apiClient.postData(AppConstants.orderLogsReport, data);
  }
  //---------------------------------- Order Logs Report ----------------------------------//
}
