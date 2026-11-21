import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/table_management_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class TableManagementController extends GetxController {
  final TableManagementRepo tableManagementRepo;

  TableManagementController({required this.tableManagementRepo});

  bool isLoading = false;

  List<Map<String, dynamic>> tableList = [];

  List<Map<String, dynamic>> filteredTableList = [];

  List<String> areaOptions = [];

  List<Map<String, dynamic>> waiterList = [];

  String? restaurantName;

  // Search controller
  final TextEditingController searchCtrl = TextEditingController();

  // Form controllers
  final TextEditingController tableNoCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();

  // Dropdown values
  String? selectedArea;

  int? selectedWaiterId;

  String selectedType = 'TB'; // TB for Table, RM for Room

  // For edit mode
  int? editingTableId;

  // Bulk import/export loaders
  RxBool isImportLoader = false.obs;
  RxBool isExportLoader = false.obs;
  RxBool exportSampleLoader = false.obs;
  RxBool isQRCodesLoader = false.obs;

  // File upload - naming convention must match BulkImportScreen expectations
  String? chooseFilePath;
  TextEditingController ChooseFileController = TextEditingController();
  bool chooseFileLoader = false;

  @override
  void onInit() {
    super.onInit();
    getTableList();
    getAreaOptions();
    getWaiterList();
  }

  void setArea(String? value) {
    selectedArea = value;
    update();
  }

  void setWaiter(int? value) {
    selectedWaiterId = value;
    update();
  }

  void setType(String value) {
    selectedType = value;
    update();
  }

  void setEditingTable(Map<String, dynamic>? table) {
    if (table != null) {
      editingTableId = table['id'];
      selectedArea = table['title'];
      areaCtrl.text = table['title'] ?? '';
      tableNoCtrl.text = table['table_no'] ?? '';
      selectedWaiterId = table['waiter_id'];
      selectedType = table['rtype'] ?? 'TB';
    } else {
      editingTableId = null;
    }
    update();
  }

  void clearForm() {
    editingTableId = null;
    selectedArea = null;
    selectedWaiterId = null;
    selectedType = 'TB';
    tableNoCtrl.clear();
    areaCtrl.clear();
    update();
  }

  void searchTable(String query) {
    if (query.isEmpty) {
      filteredTableList = List.from(tableList);
    } else {
      filteredTableList = tableList.where((table) {
        final title = table['title']?.toString().toLowerCase() ?? '';
        final tableNo = table['table_no']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || tableNo.contains(searchQuery);
      }).toList();
    }
    update();
  }

  Future<void> getTableList() async {
    try {
      isLoading = true;
      update();

      Response response = await tableManagementRepo.getTableList();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true && data['data'] != null) {
          tableList =
              List<Map<String, dynamic>>.from(data['data']['tables'] ?? []);
          filteredTableList = List.from(tableList);
          restaurantName = data['data']['restaurant_name'];
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error getting table list: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getAreaOptions() async {
    try {
      Response response = await tableManagementRepo.getAreaOptions();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> areas = data['data']['areas'] ?? [];
          areaOptions = areas
              .where((area) => area != null && area.toString().isNotEmpty)
              .map((area) => area.toString())
              .toList();
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error getting area options: $e');
    }
    update();
  }

  Future<void> getWaiterList() async {
    try {
      Response response = await tableManagementRepo.getWaiterList();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true && data['data'] != null) {
          waiterList =
              List<Map<String, dynamic>>.from(data['data']['waiters'] ?? []);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error getting waiter list: $e');
    }
    update();
  }

  Future<void> saveTable() async {
    // if (areaCtrl.text.trim().isEmpty) {
    //   Get.snackbar(
    //     'Check Again',
    //     'Please enter or select an area',
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    if (tableNoCtrl.text.isEmpty) {
      Get.snackbar(
        'Check Again',
        'Please enter table number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // if (selectedWaiterId == null) {
    //   Get.snackbar(
    //     'Check Again',
    //     'Please select a waiter',
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    try {
      isLoading = true;
      update();

      Map<String, dynamic> tableData = {
        'title': areaCtrl.text.trim(),
        'table_no': tableNoCtrl.text,
        'vendorName': null,
        'rtype': selectedType,
      };

      // Add id for update
      if (editingTableId != null) {
        tableData['id'] = editingTableId;
      }

      Response response = await tableManagementRepo.saveTable(tableData);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          String message = data['message'] ??
              (editingTableId != null
                  ? 'Table updated successfully'
                  : 'Table added successfully');
          Get.back();
          Get.snackbar(
            'Success',
            message,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await getTableList();
          await getAreaOptions();
          clearForm();
          // return true;
        }
      } else {
        ApiChecker.checkApi(response);

        // Handle HTTP error responses
        if (response.body != null && response.body is Map) {
          String errorMessage =
              response.body['message'] ?? 'Failed to save table';

          if (response.body['errors'] != null) {
            Map<String, dynamic> errors = response.body['errors'];
            List<String> errorMessages = [];

            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          }

          Get.snackbar(
            'Error',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('Error saving table: $e');
      Get.snackbar(
        'Error',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      isLoading = true;
      update();

      Response response = await tableManagementRepo.deleteTable(id);

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            data['message'] ?? 'Table deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await getTableList();
        }
      } else {
        ApiChecker.checkApi(response);
        Get.snackbar(
          'Error',
          'Failed to delete table',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting table: $e');
      Get.snackbar(
        'Error',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // ==================== Bulk Import/Export Methods ====================

  /// Pick Excel file from device storage
  /// Allows user to select .xlsx file for bulk import
  Future<void> pickExcelFile() async {
    try {
      chooseFileLoader = true;
      update();

      // Open file picker for Excel files only
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        chooseFilePath = result.files.single.path;
        log("File selected: $chooseFilePath");

        // Update text field with file name
        ChooseFileController.text = chooseFilePath?.split("/").last ?? "";
        update();
      } else {
        log("No file selected or file path is null.");
      }
    } catch (e) {
      log("Error picking file: $e");
      Get.snackbar(
        'Error',
        'Failed to pick file',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      chooseFileLoader = false;
      update();
    }
  }

  /// Export sample template for table configuration
  /// Downloads an Excel template file that can be filled and imported
  Future<void> exportSampleTemplate() async {
    try {
      exportSampleLoader.value = true;
      update();

      print('Downloading table configuration sample template...');

      Response response = await tableManagementRepo.exportSampleTemplate();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          String? downloadUrl = data['download_url'];
          String message =
              data['message'] ?? 'Sample file generated successfully';

          if (downloadUrl != null && downloadUrl.isNotEmpty) {
            // Launch URL to download the file
            await _launchURL(downloadUrl);

            Get.snackbar(
              'Downloaded Successfully',
              message,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Error',
              'Download URL not found',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error exporting sample template: $e');
      Get.snackbar(
        'Error',
        'Failed to export sample template',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      exportSampleLoader.value = false;
      update();
    }
  }

  /// Export existing table data
  /// Downloads current table list in Excel format
  Future<void> exportExistingData() async {
    try {
      isExportLoader.value = true;
      update();

      print('Exporting existing table data...');

      Response response = await tableManagementRepo.exportExistingData();

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          String? downloadUrl = data['download_url'];
          int totalRecords = data['total_records'] ?? 0;
          String message =
              data['message'] ?? 'Table list exported successfully';

          if (downloadUrl != null && downloadUrl.isNotEmpty) {
            // Launch URL to download the file
            await _launchURL(downloadUrl);

            Get.snackbar(
              'Exported Successfully',
              '$message\nTotal Records: $totalRecords',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
          } else {
            Get.snackbar(
              'Error',
              'Download URL not found',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error exporting existing data: $e');
      Get.snackbar(
        'Error',
        'Failed to export table data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExportLoader.value = false;
      update();
    }
  }

  /// Import table configuration from Excel file (bulk upload)
  /// Processes the uploaded file and imports/updates table records
  Future<void> bulkTableImport() async {
    try {
      isImportLoader.value = true;
      update();

      // Check if file is selected
      if (chooseFilePath == null || chooseFilePath!.isEmpty) {
        Get.snackbar(
          'Check Again',
          AppString.pleaseChooseFile,
          backgroundColor: ColorTheme.appColor,
          colorText: Colors.white,
        );
        return;
      }

      print('Importing table configuration from: $chooseFilePath');

      Response response = await tableManagementRepo.importTableConfig(
        fileName: chooseFilePath!,
        keyFileName: 'table_file',
      );

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          int imported = data['imported'] ?? 0;
          int updated = data['updated'] ?? 0;
          int totalProcessed = data['total_processed'] ?? 0;
          String message = data['message'] ?? 'Tables imported successfully';

          // Clear file selection before going back
          chooseFilePath = null;
          ChooseFileController.clear();

          // Close the bulk import screen
          Get.back();

          // Show success message with details
          Get.snackbar(
            'Imported Successfully',
            '$message\nImported: $imported, Updated: $updated, Total: $totalProcessed',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );

          // Refresh the table list and area options
          await getTableList();
          await getAreaOptions();
        }
      } else {
        ApiChecker.checkApi(response);
        // Clear file selection before going back
        chooseFilePath = null;
        ChooseFileController.clear();

        if (response.body != null && response.body['message'] != null) {
          Get.snackbar(
            'Error',
            response.body['message'].toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error importing table configuration: $e');
    } finally {
      isImportLoader.value = false;
      update();
    }
  }

  /// Helper method to launch URL for downloading files
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      Get.snackbar(
        'Error',
        'Failed to open download link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== End of Bulk Import/Export Methods ====================

  /// Download table QR codes PDF
  /// Generates and downloads a PDF containing all table QR codes
  /// Generates and downloads a PDF containing all table QR codes
  Future<void> downloadTableQRCodes() async {
    try {
      isQRCodesLoader.value = true;
      update();

      print('Starting table QR codes PDF generation...');

      Response response = await tableManagementRepo.getTableQRCodes();

      if ((response.statusCode == 200 || response.statusCode == 202) && response.body != null) {
        var data = response.body;
        if (data['success'] == true) {
          String? status = data['status'];
          String? jobId = data['job_id'];
          String? checkStatusUrl = data['check_status_url'];

          if (status == 'processing' && jobId != null) {
            // Show processing message
            Get.snackbar(
              'Processing',
              'PDF generation started. Please wait...',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
              showProgressIndicator: true,
            );

            // Start polling for job status
            await _pollJobStatus(jobId, checkStatusUrl);
          } else if (status == 'completed' && data['download_url'] != null) {
            // If already completed (edge case)
            await _handleDownload(data['download_url'], data['message']);
          } else {
            Get.snackbar(
              'Error',
              'Unexpected response from server',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to generate QR codes',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error downloading QR codes: $e');
      Get.snackbar(
        'Error',
        'Failed to start PDF generation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isQRCodesLoader.value = false;
      update();
    }
  }

  /// Polls the job status endpoint until completion or failure
  Future<void> _pollJobStatus(String jobId, String? checkStatusUrl) async {
    const int maxAttempts =
        60; // Maximum 60 attempts (5 minutes with 5s interval)
    const Duration pollInterval = Duration(seconds: 5);
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        print('Polling attempt $attempts/$maxAttempts for job: $jobId');

        // Wait before next poll (except first attempt)
        if (attempts > 1) {
          await Future.delayed(pollInterval);
        }

        Response statusResponse =
            await tableManagementRepo.checkQRCodeJobStatus(jobId);

        if (statusResponse.statusCode == 200 && statusResponse.body != null) {
          var statusData = statusResponse.body;

          if (statusData['success'] == true) {
            String status = statusData['status'] ?? '';

            if (status == 'completed') {
              // Job completed successfully
              String? downloadUrl = statusData['download_url'];
              String? fileName = statusData['file_name'];
              String message = 'PDF generated successfully';

              if (downloadUrl != null && downloadUrl.isNotEmpty) {
                await _handleDownload(downloadUrl, message, fileName: fileName);
                return; // Exit polling
              } else {
                Get.snackbar(
                  'Error',
                  'Download URL not found',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
            } else if (status == 'failed') {
              // Job failed
              String errorMessage =
                  statusData['message'] ?? 'PDF generation failed';
              Get.snackbar(
                'Failed',
                errorMessage,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: Duration(seconds: 4),
              );
              return; // Exit polling
            } else if (status == 'processing') {
              // Still processing, continue polling
              print('Job still processing... (attempt $attempts)');

              // Update progress message every 10 attempts
              if (attempts % 10 == 0) {
                Get.snackbar(
                  'Still Processing',
                  'Generating PDF... Please wait.',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              }
            } else {
              // Unknown status
              print('Unknown job status: $status');
            }
          } else {
            // API returned success: false
            String errorMessage =
                statusData['message'] ?? 'Failed to check job status';
            Get.snackbar(
              'Error',
              errorMessage,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        } else {
          print('Failed to check job status: ${statusResponse.statusCode}');

          // Continue polling even if one check fails
          if (attempts >= maxAttempts) {
            Get.snackbar(
              'Error',
              'Failed to check job status',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        }
      } catch (e) {
        print('Error polling job status: $e');

        // Continue polling even if one attempt fails
        if (attempts >= maxAttempts) {
          Get.snackbar(
            'Error',
            'Connection error while checking status',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    // Max attempts reached
    Get.snackbar(
      'Timeout',
      'PDF generation is taking longer than expected. Please try again later.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
  }

  /// Handles the file download and launches the URL
  Future<void> _handleDownload(String downloadUrl, String message,
      {String? fileName}) async {
    try {
      print('Downloading file from: $downloadUrl');

      // Launch URL to download the file
      bool launched = await launchURL(downloadUrl);

      if (launched) {
        Get.snackbar(
          'Success',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => _launchURL(downloadUrl),
            child: Text('Open Again', style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to open download link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error handling download: $e');
      Get.snackbar(
        'Error',
        'Failed to download file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Launches the URL in browser/external app

  Future<bool> launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch $url');
        return false;
      }
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }

  // @override
  // void onClose() {
  //   searchCtrl.dispose();
  //   tableNoCtrl.dispose();
  //   areaCtrl.dispose();
  //   ChooseFileController.dispose();
  //   super.onClose();
  // }
}
