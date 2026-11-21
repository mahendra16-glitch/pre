import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_settlement_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_settlement_list_model.dart';
import 'package:mygenie_restaurant/data/repository/settlement_repo.dart';
import 'package:get/get.dart';

class SettlementController extends GetxController implements GetxService {
  final SettlementRepo settlementRepo;
  SettlementController({required this.settlementRepo});

  GetSettlementReportResponse? _getSettlementReportList;
  GetSettlementDetailReportResponse? _getSettlementDetailResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  GetSettlementReportResponse? get getSettlementReportList =>
      _getSettlementReportList;
  GetSettlementDetailReportResponse? get getSettlementDetailResponse =>
      _getSettlementDetailResponse;

  Future<void> getSettlementList(Map<String, dynamic>? date) async {
    _isLoading = true;
    _getSettlementReportList = null;
    update();
    final response = await settlementRepo.getSettlement(date ?? {});
    _isLoading = false;
    if (response.statusCode == 200) {
      _getSettlementReportList =
          GetSettlementReportResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSettlementDetail(String date) async {
    _isLoading = true;
    update();
    _getSettlementDetailResponse = null;
    final response =
        await settlementRepo.getSettlementDetail({'settle_date': date});
    _isLoading = false;

    if (response.statusCode == 200) {
      _getSettlementDetailResponse =
          GetSettlementDetailReportResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> settleAmount(String date,
      {required Map<String, dynamic> data}) async {
    _isLoading = true;
    update();
    final response = await settlementRepo.settlementAmount(data);
    _isLoading = false;

    if (response.statusCode == 200) {
      await getSettlementDetail(date);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
