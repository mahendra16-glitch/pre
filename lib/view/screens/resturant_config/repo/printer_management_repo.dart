import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';

class PrinterManagementRepo {
  final ApiClient apiClient;

  PrinterManagementRepo({required this.apiClient});

  /// Get printer configuration list
  /// Returns all configured printers for the restaurant
  Future<Response> getPrinterList() async {
    return await apiClient.getData(
      AppConstants.Get_Printer_List,
    );
  }

  /// Get area/station options
  /// Returns available areas/stations for printer assignment
  Future<Response> getAreaOptions() async {
    return await apiClient.getData(
      AppConstants.Get_Printer_Area_Options,
    );
  }

  /// Save printer configuration (Add or Update)
  /// If printerData contains 'id', it updates existing printer
  /// Otherwise, it creates a new printer configuration
  Future<Response> savePrinter(Map<String, dynamic> printerData) async {
    return await apiClient.postData(
      AppConstants.Save_Printer_Config,
      printerData,
    );
  }

  /// Delete printer configuration by ID
  Future<Response> deletePrinter(int id) async {
    return await apiClient.deleteData(
      '${AppConstants.Delete_Printer_Config}$id',
    );
  }

  /// Get current printing option/mode
  /// Returns the current printing option (fixed, waiter, or station)
  Future<Response> getPrintingOption() async {
    return await apiClient.getData(
      AppConstants.Printing_Option,
    );
  }

  /// Update printing option/mode
  /// Updates the printing option for the restaurant
  /// Parameters:
  ///   - restaurantId: The restaurant ID
  ///   - printingOption: The printing mode (fixed, waiter, or station)
  Future<Response> updatePrintingOption(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.Printing_Option,
      data,
    );
  }
}
