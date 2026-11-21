import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/custome management/repo/customer_management_repo.dart';
import 'package:url_launcher/url_launcher.dart';

/// Controller for managing customer report data and state
class CustomerManagementController extends GetxController
    implements GetxService {
  final CustomerManagementRepo customerManagementRepo;

  CustomerManagementController({required this.customerManagementRepo});

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  GetCustomerListResponse? _customerListModel;
  GetCustomerListResponse? get customerListModel => _customerListModel;

  // Customer list data
  List<Map<String, dynamic>> _customerList = [];
  List<Map<String, dynamic>> get customerList => _customerList;

  // Search controller
  TextEditingController searchCustomerController = TextEditingController();

  // @override
  // void onInit() {
  //   super.onInit();
  //   // Fetch customer list on initialization
  //   getRestaurantCustomerList();
  // }

  // @override
  // void onClose() {
  //   searchCustomerController.dispose();
  //   super.onClose();
  // }

  /// Fetch restaurant customer list from API
  Future<void> getRestaurantCustomerList() async {
    _isLoading = true;
    update();

    try {
      Response response =
          await customerManagementRepo.getRestaurantCustomerList();

      if (response.statusCode == 200) {
        if (response.body['customer_list'] != null) {
          _customerList = List<Map<String, dynamic>>.from(
            response.body['customer_list'],
          );
        } else {
          _customerList = [];
        }
        _isLoading = false;
        update();
      } else {
        _isLoading = false;
        update();
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      _isLoading = false;
      update();
      Get.snackbar(
        'Error',
        'Failed to fetch customer list: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Export customer list to Excel
  Future<void> exportCustomerListExcel() async {
    try {
      Response response =
          await customerManagementRepo.exportCustomerListExcel();

      if (response.statusCode == 200) {
        final message =
            response.body['message'] ?? 'Customer List exported successfully!';
        final downloadUrl = response.body['download_url'];

        if (downloadUrl != null) {
          // Launch the download URL
          final uri = Uri.parse(downloadUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            Get.snackbar(
              'Success',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Error',
              'Could not launch download URL',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Success',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export customer list: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Get filtered customer list based on search query
  List<Map<String, dynamic>> getFilteredCustomerList() {
    final searchQuery = searchCustomerController.text.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      return _customerList;
    }

    return _customerList.where((customer) {
      final customerName =
          (customer['customer_name']?.toString() ?? '').toLowerCase();
      final phone = (customer['phone']?.toString() ?? '').toLowerCase();
      final membershipId =
          (customer['membership_id']?.toString() ?? '').toLowerCase();

      return customerName.contains(searchQuery) ||
          phone.contains(searchQuery) ||
          membershipId.contains(searchQuery);
    }).toList();
  }

  Future getCustomerFromApiModel({bool isLoading = false}) async {
    if (isLoading) _isLoading = true;
    if (isLoading) update();
    _customerListModel = null;
    Response response = await customerManagementRepo.getCustomerList({});
    if (isLoading) _isLoading = false;
    if (isLoading) update();
    if (response.statusCode == 200) {
      _customerListModel = GetCustomerListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateTapIndex(int i) {
    _selectedTab = i;
    update();
  }

  Future<String> changeCustomerDetail(
      Map<String, dynamic> body, Function callback) async {
    String userId = '';
    try {
      showToast('Please wait..');
      Get.find<LoadingController>().startLoading(true);

      Response response =
          await customerManagementRepo.updateCustomerDetail(body);
      // _isLoading = false;
      // update();
      Get.find<LoadingController>().startLoading(false);

      if (response.statusCode == 200) {
        await Get.find<LoadingController>()
            .changeText(data: response.body['message']);
        userId = response.body['user_id'].toString();
        await Get.find<LoadingController>().changeStatus(data: true);
        Future.delayed(Duration(milliseconds: 500), () {
          callback(true);
        });
      } else {
        callback(false);
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('error: $e');
    }
    update();
    return userId;
  }
  //====================== Customer Designation Management ======================//

  var customerDesignationList = <Map<String, dynamic>>[].obs;
  TextEditingController customerDesignationSearchController =
      TextEditingController();
  TextEditingController customerDesignationAddController =
      TextEditingController();
  RxBool isCustomerDesignationLoading = false.obs;
  RxBool isCustomerDesignationSubmitting = false.obs;
  RxBool isCustomerDesignationStatusUpdating = false.obs;
  RxBool isCustomerDesignationDeleting = false.obs;
  RxInt updatingDesignationId = (-1).obs;
  RxInt deletingDesignationId = (-1).obs;

  /// Clear customer designation list
  void clearCustomerDesignationList() {
    customerDesignationList.clear();
    update();
  }

  /// Get customer designations list
  Future<void> getCustomerDesignationList() async {
    try {
      isCustomerDesignationLoading.value = true;
      update();

      final response =
          await customerManagementRepo.getCustomerDesignationsList();

      if (response?.statusCode == 200) {
        final responseBody = response?.body;
        if (responseBody != null && responseBody['designations'] != null) {
          final List<dynamic> designations = responseBody['designations'] ?? [];
          // Initialize status to 1 (active) by default since list API doesn't return status
          final List<Map<String, dynamic>> designationsWithStatus =
              designations.map<Map<String, dynamic>>((d) {
            final map = Map<String, dynamic>.from(d);
            if (!map.containsKey('status')) {
              map['status'] = 1; // Default to active
            }
            return map;
          }).toList();
          customerDesignationList.assignAll(designationsWithStatus);
          log('Customer Designation List: ${customerDesignationList.length} items');
        } else {
          customerDesignationList.clear();
        }
      } else {
        ApiChecker.checkApi(response!);
        customerDesignationList.clear();
      }
      update();
    } catch (e) {
      log('getCustomerDesignationList Error: $e');
      customerDesignationList.clear();
      Get.snackbar(
        'Error',
        'Failed to fetch customer designations',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCustomerDesignationLoading.value = false;
      update();
    }
  }

  /// Add new customer designation
  Future<void> addCustomerDesignation() async {
    try {
      if (customerDesignationAddController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Please enter designation name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (isCustomerDesignationSubmitting.value) return;
      isCustomerDesignationSubmitting.value = true;
      update();

      Map<String, dynamic> data = {
        'designation': customerDesignationAddController.text.trim(),
      };

      final response =
          await customerManagementRepo.addCustomerDesignation(data);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        customerDesignationAddController.clear();
        await getCustomerDesignationList(); // Refresh list after adding
        Get.snackbar(
          'Success',
          response?.body?['message'] ??
              'Customer designation added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('addCustomerDesignation Error: $e');
      Get.snackbar(
        'Error',
        'Failed to add customer designation',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCustomerDesignationSubmitting.value = false;
      update();
    }
  }

  /// Toggle customer designation status
  Future<void> toggleCustomerDesignationStatus(int id) async {
    try {
      if (isCustomerDesignationStatusUpdating.value) return;
      isCustomerDesignationStatusUpdating.value = true;
      updatingDesignationId.value = id;
      update();

      final response =
          await customerManagementRepo.toggleCustomerDesignationStatus(id);

      if (response?.statusCode == 200) {
        // Update the status in the list from the response
        final responseBody = response?.body;
        if (responseBody != null && responseBody['data'] != null) {
          final updatedData = responseBody['data'] as Map<String, dynamic>;
          final updatedStatus = updatedData['status'] as int? ?? 1;

          // Update the item in the list
          final index = customerDesignationList.indexWhere(
            (d) => d['id'] == id,
          );
          if (index != -1) {
            customerDesignationList[index]['status'] = updatedStatus;
          }
        }

        update(['designation_item_$id']); // Update only the specific item
        Get.snackbar(
          'Success',
          response?.body?['message'] ?? 'Status updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('toggleCustomerDesignationStatus Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCustomerDesignationStatusUpdating.value = false;
      updatingDesignationId.value = -1;
      update();
    }
  }

  /// Delete customer designation
  Future<void> deleteCustomerDesignation(int id) async {
    try {
      if (isCustomerDesignationDeleting.value) return;
      isCustomerDesignationDeleting.value = true;
      deletingDesignationId.value = id;
      update();

      final response =
          await customerManagementRepo.deleteCustomerDesignation(id);

      if (response?.statusCode == 200) {
        await getCustomerDesignationList(); // Refresh list after deletion
        Get.snackbar(
          'Success',
          response?.body?['message'] ??
              'Customer designation deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log('deleteCustomerDesignation Error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete customer designation',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isCustomerDesignationDeleting.value = false;
      deletingDesignationId.value = -1;
      update();
    }
  }

  /// Get filtered customer designations based on search
  List<Map<String, dynamic>> getFilteredCustomerDesignationList() {
    if (customerDesignationSearchController.text.trim().isEmpty) {
      return customerDesignationList.toList();
    }

    final searchQuery =
        customerDesignationSearchController.text.trim().toLowerCase();
    return customerDesignationList
        .where((designation) =>
            (designation['designation']?.toString().toLowerCase() ?? '')
                .contains(searchQuery))
        .toList();
  }

  //====================== Customer Designation Management ======================//
}
