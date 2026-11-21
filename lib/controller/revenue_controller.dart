import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_print_report_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_revenue_report_model.dart';
import 'package:mygenie_restaurant/data/repository/revenue_repo.dart';
import 'package:get/get.dart';

class RevenueController extends GetxController implements GetxService {
  final RevenueRepo revenueRepo;
  RevenueController({required this.revenueRepo});

  GetRevenueReportResponse? _getRevenueReportResponse;
  GetPrintReportResponse? _getPrintReportResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  GetRevenueReportResponse? get getRevenueReportResponse =>
      _getRevenueReportResponse;
  GetPrintReportResponse? get getPrintReportResponse => _getPrintReportResponse;

  Future<void> getReport(Map<String, dynamic>? date) async {
    _isLoading = true;
    update();
    final response = await revenueRepo.getRevenueReport(date ?? {});
    _isLoading = false;
    if (response.statusCode == 200) {
      _getRevenueReportResponse =
          GetRevenueReportResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getPrintReport(Map<String, dynamic>? date) async {
    _isLoading = true;
    _getPrintReportResponse = null;
    update();
    final response = await revenueRepo.getPrintReport(date ?? {});
    _isLoading = false;
    if (response.statusCode == 200) {
      _getPrintReportResponse = GetPrintReportResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
