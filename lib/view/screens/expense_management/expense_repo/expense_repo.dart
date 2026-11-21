import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class ExpenseManagementRepo {
  final ApiClient apiClient;
  ExpenseManagementRepo({required this.apiClient});

  Future<Response?> manageExpenses(Map<String, dynamic>? body) async {
    return await apiClient.getData(AppConstants.manageExpenses, query: body);
  }

  Future<Response?> addManageExpense(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.addManageExpense, body);
  }

  // Future<Response?> editManageExpense(int id, Map<String, dynamic> body) async {
  //   return await apiClient.putData(AppConstants.editManageExpense(id), body);
  // }

  Future<Response?> updateDirectExpenses(
      int expId, Map<String, dynamic> body) async {
    return await apiClient.putData(
        AppConstants.updateDirectExpenses(expId), body);
  }

  Future<Response?> deleteManageExpense(
      int id, Map<String, dynamic> body) async {
    return await apiClient.deleteWData(AppConstants.deleteManageExpense(id),
        body: body);
  }

  Future<Response?> masterExpenses() async {
    return await apiClient.getData(AppConstants.masterExpenses);
  }

  Future<Response?> expenseDownloadSample() async {
    return await apiClient.getData(AppConstants.expenseDownloadSample);
  }

  Future<Response?> expenseStockExistingSample(
      Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.expenseStockExistingSampleExport, data);
  }

  Future<Response?> expensePaymentMethod(Map<String, dynamic> body) async {
    return await apiClient.getData(AppConstants.expensePaymentMethod,
        query: body);
  }

  Future<Response?> getUnit() async {
    return await apiClient.getData(AppConstants.getUnit);
  }

  Future<Response?> addMasterExpense(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.addMasterExpense, body);
  }

  Future<Response?> editMasterExpense(int id, Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.editMasterExpense(id), body);
  }

  Future<Response?> deleteMasterExpense(
      int id, Map<String, dynamic> body) async {
    return await apiClient.deleteWData(AppConstants.deleteMasterExpense(id),
        body: body);
  }

  Future<Response?> getCategoryList() async {
    return await apiClient.getData(AppConstants.categoryList);
  }

  Future<Response?> addCategory(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.addCategory, body);
  }

  Future<Response> expenseImportExpense({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.expenseImportExpense,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response> expenseStockImport({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.expenseStockImport,
      data,
      keyFileName,
      fileName,
    );
  }

  Future<Response?> expenseReport(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.expenseReport, body);
  }

  Future<Response?> getStockUnitPrices() async {
    return await apiClient.getData(AppConstants.stockUnitPrices);
  }

  Future<Response?> addStockUnitPrice(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.stockUnitPrice, body);
  }

  Future<Response?> editStockUnitPrice(
      int id, Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.stockUnitPriceEdit(id), body);
  }

  Future<Response?> deleteStockUnitPrice(int id) async {
    return await apiClient.deleteWData(AppConstants.stockUnitPriceDelete(id));
  }

  Future<Response?> getExpensesWithoutUnitPrices() async {
    return await apiClient.getData(AppConstants.expensesWithoutUnitPrices);
  }

   Future<Response> importUnitPriceMaster({
    required Map<String, String> data,
    required String fileName,
    required String keyFileName,
  }) async {
    return await apiClient.postFromData(
      AppConstants.importUnitPriceMaster,
      data,
      keyFileName,
      fileName,
    );
  }

   Future<Response?> exportUnitPriceMaster(
      Map<String, dynamic> data) async {
    return await apiClient.postData(
        AppConstants.exportUnitPriceMaster, data);
  }
}
