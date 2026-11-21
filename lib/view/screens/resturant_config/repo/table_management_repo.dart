import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class TableManagementRepo {
  final ApiClient apiClient;

  TableManagementRepo({required this.apiClient});

  Future<Response> getTableList() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_LIST,
    );
  }

  Future<Response> getAreaOptions() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_AREA_OPTIONS,
    );
  }

  Future<Response> getWaiterList() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_WAITER_LIST,
    );
  }

  /// Save table configuration (Add or Update)
  /// If tableData contains 'id', it updates existing table
  /// Otherwise, it creates a new table configuration
  Future<Response> saveTable(Map<String, dynamic> tableData) async {
    if (tableData.containsKey('id')) {
      // Update existing table
      return await apiClient.postData(
        AppConstants.TABLE_CONFIG_UPDATE,
        tableData,
      );
    } else {
      // Add new table
      return await apiClient.postData(
        AppConstants.TABLE_CONFIG_STORE,
        tableData,
      );
    }
  }

  /// Delete table configuration by ID
  Future<Response> deleteTable(int id) async {
    return await apiClient.deleteData(
      '${AppConstants.TABLE_CONFIG_DELETE}$id',
    );
  }

  /// Export sample template for table configuration
  /// Returns a download URL for the sample Excel file
  Future<Response> exportSampleTemplate() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_EXPORT_SAMPLE,
    );
  }

  /// Export existing table list
  /// Returns a download URL for the current table data in Excel format
  Future<Response> exportExistingData() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_EXPORT_LIST,
    );
  }

  /// Import table configuration from Excel file (bulk upload)
  /// Parameters:
  ///   - fileName: Path to the Excel file to upload
  ///   - keyFileName: Form field name for the file (default: 'table_file')
  Future<Response> importTableConfig({
    required String fileName,
    String keyFileName = 'table_file',
  }) async {
    Map<String, String> data = {
      'button': 'import',
    };

    return await apiClient.postFromData(
      AppConstants.TABLE_CONFIG_IMPORT,
      data,
      keyFileName,
      fileName,
    );
  }

  /// Get table QR codes PDF
  /// Returns a download URL for the QR codes PDF file
  Future<Response> getTableQRCodes() async {
    return await apiClient.getData(
      AppConstants.TABLE_CONFIG_QR_CODES,
    );
  }

  Future<Response> checkQRCodeJobStatus(String jobId) async {
  return await apiClient.getData(
    '${AppConstants.CHECK_QR_PDF_STATUS_URI}/$jobId',
  );
}

}
