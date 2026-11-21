import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/repository/check_in_repo.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CheckInController extends GetxController implements GetxService {
  final CheckInRepo checkInRepo;

  CheckInController({required this.checkInRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Document image files (nullable for safety)
  XFile? _frontImg, _backImg;
  XFile? get frontImg => _frontImg;
  XFile? get backImg => _backImg;

  XFile? _frontImgOne, _backImgOne;
  XFile? get frontImgOne => _frontImgOne;
  XFile? get backImgOne => _backImgOne;

  XFile? _frontImgTwo, _backImgTwo;
  XFile? get frontImgTwo => _frontImgTwo;
  XFile? get backImgTwo => _backImgTwo;

  XFile? _frontImgThird, _backImgThird;
  XFile? get frontImgThird => _frontImgThird;
  XFile? get backImgThird => _backImgThird;

  // Drop-down selected values
  String _selectGuestCount = 'Total adults';
  String get selectGuestCount => _selectGuestCount;

  String _selectChildCount = 'Total children';
  String get selectChildCount => _selectChildCount;

  String _selectCategoryDocument = 'Select document type';
  String get selectCategoryDocument => _selectCategoryDocument;
  String _selectCategoryDocumentOne = 'Select document type';
  String get selectCategoryDocumentOne => _selectCategoryDocumentOne;
  String _selectCategoryDocumentTwo = 'Select document type';
  String get selectCategoryDocumentTwo => _selectCategoryDocumentTwo;
  String _selectCategoryDocumentThird = 'Select document type';
  String get selectCategoryDocumentThird => _selectCategoryDocumentThird;

  void setImage(int count, {required bool isFront, required XFile file}) {
    switch (count) {
      case 1:
        isFront ? _frontImg = file : _backImg = file;
        break;
      case 2:
        isFront ? _frontImgOne = file : _backImgOne = file;
        break;
      case 3:
        isFront ? _frontImgTwo = file : _backImgTwo = file;
        break;
      case 4:
        isFront ? _frontImgThird = file : _backImgThird = file;
        break;
    }
    update();
  }

  Future<void> checkIn(
    BuildContext context,
    String email,
    String phone,
    String name, {
    String? secondName,
    String? orderAmount,
    String? comment,
    String? thirdName,
    String? fourthName,
    String? childName,
    String? bookingType,
    String? checkInDateTime,
    String? checkOutDateTime,
    String? advancePay,
    String? balanceDue,
    String? gstName,
    String? gstNo,
    String? bookingFor,
    double gstAmount = 0.0,
    String? paymentMethod,
    String? crmCustomerId,
    bool uploadCrmDocuments = false,
  }) async {
    try {
      _isLoading = true;
      update();

      final jsonData = <String, String>{
        'name': name,
        'phone': phone,
        'email': email,
        'advance_payment': advancePay ?? '0',
        'balance_payment': balanceDue ?? '0',
        'checkin_date': checkInDateTime ?? '',
        'checkout_date': checkOutDateTime ?? '',
        'booking_details': '',
        'booking_type': bookingType ?? '',
        'room_price':
            (orderAmount == null || orderAmount.isEmpty) ? '0' : orderAmount,
        'order_amount':
            (orderAmount == null || orderAmount.isEmpty) ? '0' : orderAmount,
        'order_note': comment ?? '',
        'id_type': selectCategoryDocument,
        // 'room_id': Get.find<CartController>().selectedTable!.id.toString(),
        // 'room_id': Get.find<CartController>().selectedTables.isNotEmpty
        //     ? Get.find<CartController>()
        //         .selectedTables
        //         .map((e) => e.id)
        //         .toList()
        //         .toString()
        //     : '0',
        'total_adult':
            (selectGuestCount == 'Total adults') ? '0' : selectGuestCount,
        'total_children':
            (selectChildCount == 'Total children') ? '0' : selectChildCount,
        'name2': ['2', '3', '4'].contains(selectGuestCount)
            ? (secondName ?? '')
            : '',
        'id_type2': ['2', '3', '4'].contains(selectGuestCount)
            ? selectCategoryDocumentOne
            : '',
        'name3': ['3', '4'].contains(selectGuestCount) ? (thirdName ?? '') : '',
        'id_type3': ['3', '4'].contains(selectGuestCount)
            ? selectCategoryDocumentTwo
            : '',
        'name4': selectGuestCount == '4' ? (fourthName ?? '') : '',
        'id_type4': selectGuestCount == '4' ? selectCategoryDocumentThird : '',
        'children_name': childName ?? '',
        'gst_tax': gstAmount.toStringAsFixed(2),
        'payment_method': paymentMethod ?? '',
        'firm_name': gstName ?? '',
        'firm_gst': gstNo ?? '',
        'booking_for': bookingFor ?? 'Individual',
        'customer_id': crmCustomerId ?? '',
        'cust_membership_id': crmCustomerId ?? '',
      };
      for (int i = 0;
          i < Get.find<CartController>().selectedTables.length;
          i++) {
        jsonData['room_id[$i]'] =
            Get.find<CartController>().selectedTables[i].id.toString();
      }
      // Prepare image files safely
      final imageList = <MultipartBody>[
        if (_frontImg != null)
          MultipartBody('front_image_file', _frontImg!, null),
        if (_backImg != null) MultipartBody('back_image_file', _backImg!, null),
        if (_frontImgOne != null)
          MultipartBody('front_image_file2', _frontImgOne!, null),
        if (_backImgOne != null)
          MultipartBody('back_image_file2', _backImgOne!, null),
        if (_frontImgTwo != null)
          MultipartBody('front_image_file3', _frontImgTwo!, null),
        if (_backImgTwo != null)
          MultipartBody('back_image_file3', _backImgTwo!, null),
        if (_frontImgThird != null)
          MultipartBody('front_image_file4', _frontImgThird!, null),
        if (_backImgThird != null)
          MultipartBody('back_image_file4', _backImgThird!, null),
      ];

      final response = await checkInRepo.checkIn(jsonData, imageList);

      if (response.statusCode == 200) {
        final shouldUploadCrmDocs = uploadCrmDocuments &&
            crmCustomerId != null &&
            crmCustomerId.isNotEmpty;
        final crmId = crmCustomerId;
        final docType = selectCategoryDocument;
        final frontFile = _frontImg;
        final backFile = _backImg;

        _isLoading = false;
        Navigator.pop(context, true);
        clearData();
        showErrorToast('Room check-in successfully', isError: false);

        if (shouldUploadCrmDocs && crmId != null) {
          Get.find<CartController>().uploadCrmCustomerDocuments(
            customerId: crmId,
            docType: docType,
            frontFile: frontFile,
            backFile: backFile,
          );
        }
      } else {
        _isLoading = false;
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      _isLoading = false;
      showErrorToast('Error: ${e.toString()}');
    }

    update();
  }

  void setGuestCount(String val) {
    _selectGuestCount = val;
    update();
  }

  void setChildCount(String val) {
    _selectChildCount = val;
    update();
  }

  void setDocumentType(String val, int type) {
    switch (type) {
      case 1:
        _selectCategoryDocument = val;
        break;
      case 2:
        _selectCategoryDocumentOne = val;
        break;
      case 3:
        _selectCategoryDocumentTwo = val;
        break;
      case 4:
        _selectCategoryDocumentThird = val;
        break;
    }
    update();
  }

  void clearData() {
    _frontImg = null;
    _backImg = null;
    _frontImgOne = null;
    _backImgOne = null;
    _frontImgTwo = null;
    _backImgTwo = null;
    _frontImgThird = null;
    _backImgThird = null;

    _selectCategoryDocument = 'Select document type';
    _selectCategoryDocumentOne = 'Select document type';
    _selectCategoryDocumentTwo = 'Select document type';
    _selectCategoryDocumentThird = 'Select document type';
    _selectChildCount = 'Total children';
    _selectGuestCount = 'Total adults';

    update();
  }
}
