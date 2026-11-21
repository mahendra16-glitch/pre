import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/printer_management_repo.dart';

class PrinterManagementController extends GetxController {
  final PrinterManagementRepo printerManagementRepo;

  PrinterManagementController({required this.printerManagementRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdatingPrintingOption = false;
  bool get isUpdatingPrintingOption => _isUpdatingPrintingOption;

  List<Map<String, dynamic>> _printerList = [];
  List<Map<String, dynamic>> get printerList => _printerList;

  List<String> _areaOptions = [];
  List<String> get areaOptions => _areaOptions;

  // Form controllers
  final TextEditingController printerNameCtrl = TextEditingController();
  // final TextEditingController printerIpCtrl = TextEditingController();
  final TextEditingController androidIpCtrl = TextEditingController();
  final TextEditingController vendorIdCtrl = TextEditingController();
  final TextEditingController productIdCtrl = TextEditingController();
  final TextEditingController wifiPrinterNameCtrl = TextEditingController();
  final TextEditingController wifiPrinterIpCtrl = TextEditingController();
  final TextEditingController stationGstCtrl = TextEditingController();
  // final TextEditingController macPrinterIpCtrl = TextEditingController();

  // Dropdown values
  String? _selectedMode;
  String? get selectedMode => _selectedMode;

  String? _selectedArea;
  String? get selectedArea => _selectedArea;

  String? _selectedPrinterType;
  String? get selectedPrinterType => _selectedPrinterType;

  int? _selectedPaperRoll;
  int? get selectedPaperRoll => _selectedPaperRoll;

  String? _selectedDefault;
  String? get selectedDefault => _selectedDefault;

  bool _autoServe = false;
  bool get autoServe => _autoServe;

  bool get showStationGst {
    final restaurants = Get.find<AuthController>().profileModel?.restaurants;
    if (restaurants == null || restaurants.isEmpty) return false;
    final restaurantFor = restaurants.first.settings?.restaurantFor;
    return restaurantFor?.toString().toLowerCase() == 'food_court';
  }

  // For edit mode
  int? _editingPrinterId;
  int? get editingPrinterId => _editingPrinterId;

  final List<String> modeOptions = ['Fixed', 'Waiter', 'Station'];
  final List<String> printerTypeOptions = ['bluetooth', 'usb', 'wifi'];
  final List<int> paperRollOptions = [58, 80];
  final List<String> defaultOptions = ['Select', 'Ready', 'Serve', 'Delivered'];

  @override
  void onInit() {
    super.onInit();
    getPrinterList();
    getAreaOptions();
    getPrintingOption(); // Fetch current printing option
  }

  void setMode(String? value) {
    _selectedMode = value;
    update();
  }

  void setArea(String? value) {
    _selectedArea = value;
    update();
  }

  void setPrinterType(String? value) {
    _selectedPrinterType = value;
    update();
  }

  void setPaperRoll(int? value) {
    _selectedPaperRoll = value;
    update();
  }

  void setDefault(String? value) {
    // If "Select" is chosen, set to null
    _selectedDefault = (value == 'Select' || value == null) ? null : value;
    update();
  }

  void setAutoServe(bool value) {
    _autoServe = value;
    update();
  }

  void setEditingPrinter(Map<String, dynamic>? printer) {
    if (printer != null) {
      _editingPrinterId = printer['id'];
      // Note: mode is fetched separately via getPrintingOption() API
      _selectedArea = printer['area_name'];
      // printerNameCtrl.text = printer['printer_name'] ?? '';
      androidIpCtrl.text = printer['printer_ip'] ?? '';

      String? printerType = printer['printer_name'];
      _selectedPrinterType = printerType;

      _selectedPaperRoll = printer['printer_paper_roll'];
      // macPrinterIpCtrl.text = printer['mac_printer_ip'] ?? '';
      vendorIdCtrl.text = printer['vendor_id'] ?? '';
      productIdCtrl.text = printer['product_id'] ?? '';
       // Handle default value - convert to int if it's a string
      final defaultValue = printer['default'];
      final defaultInt = defaultValue is int
          ? defaultValue
          : (defaultValue is String ? int.tryParse(defaultValue) : null);
      _selectedDefault = defaultInt == 1
          ? 'Ready'
          : defaultInt == 2
              ? 'Serve'
              : defaultInt == 5
                  ? 'Delivered'
                  : null;
      wifiPrinterIpCtrl.text = printer['wifi_printer_ip'] ?? '';
      wifiPrinterNameCtrl.text = printer['wifi_printer_name'] ?? '';
      _autoServe =
          (printer['auto_serve'] ?? '').toString().toLowerCase() == 'yes';
      stationGstCtrl.text = printer['station_gst']?.toString() ?? '';
    } else {
      _editingPrinterId = null;
    }
    update();
  }

  void clearForm() {
    _editingPrinterId = null;
    _selectedArea = null;
    _selectedPrinterType = null;
    _selectedPaperRoll = null;
    _selectedDefault = null;
    _autoServe = false;
    printerNameCtrl.clear();
    // printerIpCtrl.clear();
    androidIpCtrl.clear();
    vendorIdCtrl.clear();
    productIdCtrl.clear();
    wifiPrinterNameCtrl.clear();
    wifiPrinterIpCtrl.clear();
    stationGstCtrl.clear();
    // macPrinterIpCtrl.clear();
    update();
  }

  Future<void> getPrinterList() async {
    try {
      _isLoading = true;
      update();

      Response response = await printerManagementRepo.getPrinterList();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true && data['data'] != null) {
          _printerList =
              List<Map<String, dynamic>>.from(data['data']['printers'] ?? []);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error getting printer list: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> getAreaOptions() async {
    try {
      Response response = await printerManagementRepo.getAreaOptions();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true && data['data'] != null) {
          _areaOptions = List<String>.from(data['data']['options'] ?? []);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error getting area options: $e');
    }
    update();
  }

  Future<bool> savePrinter() async {
    // Note: mode is handled separately via updatePrintingOption() API

    if (_selectedArea == null || _selectedArea!.isEmpty) {
      showCustomSnackBar('Please select an area', isError: true);
      return false;
    }

    if (_selectedPrinterType == null || _selectedPrinterType!.isEmpty) {
      showCustomSnackBar('Please select printer type', isError: true);
      return false;
    }

    if (_selectedPaperRoll == null) {
      showCustomSnackBar('Please select paper roll size', isError: true);
      return false;
    }

    try {
      _isLoading = true;
      update();

      String printerType =
          _selectedPrinterType == 'wifi/lan' ? 'online' : _selectedPrinterType!;

      // Note: mode is NOT included here as it's handled separately via updatePrintingOption() API
      Map<String, dynamic> printerData = {
        'area_name': _selectedArea,
        'printer_name': printerType,
        'printer_type': 'online',
        'printer_ip': androidIpCtrl.text.isNotEmpty ? androidIpCtrl.text : null,
        'printer_paper_roll': _selectedPaperRoll,
        // 'mac_printer_ip':macPrinterIpCtrl.text.isNotEmpty ? macPrinterIpCtrl.text : null,
        'vendor_id': vendorIdCtrl.text.isNotEmpty ? vendorIdCtrl.text : null,
        'product_id': productIdCtrl.text.isNotEmpty ? productIdCtrl.text : null,
         'default': _selectedDefault == null
            ? null
            : _selectedDefault == 'Ready'
                ? 1
                : _selectedDefault == 'Serve'
                    ? 2
                    : _selectedDefault == 'Delivered'
                        ? 5
                        : null,
        'wifi_printer_ip':
            wifiPrinterIpCtrl.text.isNotEmpty ? wifiPrinterIpCtrl.text : null,
        'wifi_printer_name': wifiPrinterNameCtrl.text.isNotEmpty
            ? wifiPrinterNameCtrl.text
            : null,
        'auto_serve': _autoServe ? 'Yes' : 'No',
        'station_gst': showStationGst && stationGstCtrl.text.trim().isNotEmpty
            ? stationGstCtrl.text.trim()
            : null,
      };

      // Add id for update
      if (_editingPrinterId != null) {
        printerData['id'] = _editingPrinterId;
      }

      Response response = await printerManagementRepo.savePrinter(printerData);

      // Accept both 200 (OK) and 201 (Created) status codes
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          String message = data['message'] ??
              (_editingPrinterId != null
                  ? 'Printer updated successfully'
                  : 'Printer added successfully');
          Get.back();
          showCustomSnackBar(message, isError: false);
          await getPrinterList();
          clearForm();
          return true;
        }
      } else {
        ApiChecker.checkApi(response);
      }

      showCustomSnackBar('Failed to save printer', isError: true);
      print('Failed to save printer: ${response.body['message']}');
      return false;
    } catch (e) {
      print('Error saving printer: $e');
      showCustomSnackBar('Error: $e', isError: true);
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> deletePrinter(int id) async {
    try {
      _isLoading = true;
      update();

      Response response = await printerManagementRepo.deletePrinter(id);

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          showCustomSnackBar(data['message'] ?? 'Printer deleted successfully',
              isError: false);
          await getPrinterList();
        }
      } else {
        ApiChecker.checkApi(response);

        showCustomSnackBar('Failed to delete printer', isError: true);
      }
    } catch (e) {
      print('Error deleting printer: $e');
      showCustomSnackBar('Error: $e', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ==================== Printing Option Management ====================

  /// Current printing option (fixed, waiter, or station)
  String? _printingOption;
  String? get printingOption => _printingOption;

  /// Fetches the current printing option from the API
  /// Sets the printing option value and updates the UI
  /// This determines whether printing is fixed, per waiter, or per station
  Future<void> getPrintingOption() async {
    try {
      Response response = await printerManagementRepo.getPrintingOption();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          _printingOption = data['printing_option'];
          // Also set the selected mode in the dropdown
          _selectedMode = data['printing_option'];
          update();
        }
      } else {
        ApiChecker.checkApi(response);
        print('Failed to get printing option: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting printing option: $e');
    }
  }

  /// Updates the printing option for the restaurant
  ///
  /// Parameters:
  ///   - restaurantId: The ID of the restaurant
  ///   - printingOption: The new printing mode (fixed, waiter, or station)
  ///
  /// Shows success/error snackbar and refreshes the printing option
  Future<bool> updatePrintingOption(
      int restaurantId, String printingOption) async {
    try {
      _isUpdatingPrintingOption = true;
      update();

      Map<String, dynamic> data = {
        'restaurant_id': restaurantId,
        'printing_option': printingOption,
      };

      Response response =
          await printerManagementRepo.updatePrintingOption(data);

      if (response.statusCode == 200 && response.body != null) {
        var responseData = response.body;
        if (responseData['success'] == true) {
          String message =
              responseData['message'] ?? 'Printing option updated successfully';
          showCustomSnackBar(message, isError: false);
          getPrintingOption();

          update();

          return true;
        }
      } else {
        ApiChecker.checkApi(response);
        showCustomSnackBar('Failed to update printing option', isError: true);
      }

      return false;
    } catch (e) {
      print('Error updating printing option: $e');
      showCustomSnackBar('Error: $e', isError: true);
      return false;
    } finally {
      _isUpdatingPrintingOption = false;
      update();
    }
  }

  // ==================== End of Printing Option Management ====================

  @override
  void onClose() {
    printerNameCtrl.dispose();
    // printerIpCtrl.dispose();
    androidIpCtrl.dispose();
    vendorIdCtrl.dispose();
    productIdCtrl.dispose();
    wifiPrinterNameCtrl.dispose();
    wifiPrinterIpCtrl.dispose();
    stationGstCtrl.dispose();
    // macPrinterIpCtrl.dispose();
    super.onClose();
  }
}
