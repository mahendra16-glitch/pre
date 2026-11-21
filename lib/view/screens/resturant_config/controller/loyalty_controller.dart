import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
import 'package:mygenie_restaurant/data/repository/cart_repo.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/loyalty_repo.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';

class LoyaltyController extends GetxController implements GetxService {
  final LoyaltyRepo loyaltyRepo;

  LoyaltyController({required this.loyaltyRepo});

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isLoading1 = false;
  bool addMultipleUsers = false;

  double maxPercentage = 00.0;
  double maxAmount = 000.0;

  int? conversionRateId;
  int? redemptionRateId;

  DateTime? startDate;
  DateTime? endDate;

  String discountType = '';

  List<String> selectedUsers = [];
  List<String> selectedChannels = [];
  List<String> discountTypeList = ['flat', 'percentage'];
  List<String> allUsers = [];
  List<String> allChannels = ['delivery', 'takeaway', 'dine in'];

  List<Map<String, dynamic>> coupons = [];
  Map<String, dynamic>? allUsersIdMap = {};
  Map<int, dynamic>? allUsersNameMap = {};

  // Coupon Usage Report
  RxBool isLoadingCouponReport = false.obs;
  RxBool isLoadingCouponExport = false.obs;
  RxList<Map<String, dynamic>> couponReportOrders =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> couponBreakdown = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> couponReportSummary = <String, dynamic>{}.obs;

  final TextEditingController conversionRateController =
      TextEditingController();
  final TextEditingController redemptionMaxPercentageController =
      TextEditingController();
  final TextEditingController redemptionMaxAmountController =
      TextEditingController();
  final TextEditingController CouponCodeController = TextEditingController();
  final TextEditingController discountValueController = TextEditingController();
  final TextEditingController usageLimitController = TextEditingController();
  final TextEditingController perUserLimitController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  //..................  Get Conversion Rate ..................//

  Future<void> getConversionRateList() async {
    isLoading = false;
    update();
    Response response = await loyaltyRepo.getConversionRateList();
    if (response.statusCode == 200) {
      conversionRateController.clear();
      if (response.body.isEmpty) {
        conversionRateController.text = '';
        conversionRateId = null;
        print('No Conversion Rate Found');
        // Get.snackbar(
        //   "No Conversion Rate Found",
        //   "Please add a conversion rate first.",
        //   backgroundColor: ColorTheme.redF13,
        //   colorText: ColorTheme.whiteColor,
        // );
        return;
      }
      final Map<String, dynamic> data = response.body[0];
      conversionRateController.text = data['rate'].toString();
      conversionRateId = data['id'];
      print('Conversion Rate: ${conversionRateController.text}');
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> addConversionRate() async {
    isLoading = true;
    update();
    print('Conversion Rate Going to Update: ${conversionRateController.text}');
    Response response = await loyaltyRepo.addConversionRate(
        rate: conversionRateController.text.trim());
    if (response.statusCode == 200) {
      await getConversionRateList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  hideLoader() {
    isLoading = false;
    update();
  }

  Future<void> updateConversionRate() async {
    isLoading = true;
    update();
    Response response = await loyaltyRepo.updateConversionRate(
        rate: conversionRateController.text.trim(), id: conversionRateId!);
    if (response.statusCode == 200) {
      getConversionRateList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> deleteConversionRate() async {
    isLoading1 = true;
    update();
    print('This ${conversionRateController.text} is going to delete');

    Response response =
        await loyaltyRepo.deleteConversionRate(conversionRateId!);
    if (response.statusCode == 200) {
      getConversionRateList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading1 = false;
    update();
  }

  //..................  Get Redemption Rate ..................//

  Future<void> getRedemptionRateList() async {
    isLoading = false;
    update();
    Response response = await loyaltyRepo.getRedemptionRateList();
    if (response.statusCode == 200) {
      // if (response.body.isEmpty) {
      //   maxAmount = 000.0;
      //   maxPercentage = 00.0;
      //   redemptionMaxPercentageController.text = maxAmount.toString();
      //   redemptionMaxAmountController.text = maxPercentage.toString();
      //   redemptionRateId = null;
      //   print('No Redemption Rate Found');
      //   return;
      // }
      final Map<String, dynamic> data = response.body[0];
      // redemptionMaxPercentageController.text = data['max_percentage'].toString();
      // redemptionMaxAmountController.text = data['max_amount'].toString();
      maxAmount = double.parse(data['max_amount'].toString());
      maxPercentage = double.parse(data['max_percentage'].toString());
      redemptionMaxPercentageController.text = maxPercentage.toStringAsFixed(1);
      redemptionMaxAmountController.text = maxAmount.toStringAsFixed(2);
      redemptionRateId = data['id'];
      print(
          'Redemption Rate: MaxAmount-${redemptionMaxAmountController.text} , MaxPercentage-${redemptionMaxPercentageController.text} & id-${redemptionRateId}');
    } else if (response.statusCode == 404) {
      maxAmount = 000.0;
      maxPercentage = 00.0;
      redemptionMaxPercentageController.text = maxAmount.toString();
      redemptionMaxAmountController.text = maxPercentage.toString();
      redemptionRateId = null;
      print('No Redemption Rate Found');
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> addRedemptionRate() async {
    isLoading = true;
    update();
    Response response = await loyaltyRepo.addRedemptionRate(
        maxPercentage: redemptionMaxPercentageController.text.trim(),
        maxAmount: redemptionMaxAmountController.text.trim());
    if (response.statusCode == 200) {
      await getRedemptionRateList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> updateRedemptionRate() async {
    isLoading = true;
    update();
    print(
        'This ${redemptionMaxAmountController.text} & ${redemptionMaxPercentageController.text} is going to Updated');

    Response response = await loyaltyRepo.updateRedemptionRate(
        id: redemptionRateId!,
        maxPercentage: redemptionMaxPercentageController.text.trim(),
        maxAmount: redemptionMaxAmountController.text.trim());
    if (response.statusCode == 200) {
      await getRedemptionRateList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> deleteRedemptionRate() async {
    isLoading1 = true;
    update();
    print(
        'This MaxAmount-${redemptionMaxAmountController.text} & MaxPercentage-${redemptionMaxPercentageController.text} & id-${redemptionRateId} is going to delete');
    Response response =
        await loyaltyRepo.deleteRedemptionRate(id: redemptionRateId!);
    if (response.statusCode == 200) {
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
      await getRedemptionRateList();
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading1 = false;
    update();
  }

  //.................................... Coupon ......................................//

  void initializeCouponData(bool isEdit, Map<String, dynamic> coupon) {
    getCustomerFromApi().then((_) {
      if (isEdit) {
        CouponCodeController.text = coupon['code'] ?? '';
        discountType =
            coupon['discount_type'].toString().toLowerCase().trim() ?? '';
        discountValueController.text = coupon['discount_value'].toString();
        startDateController.text = coupon['start_date'] != null
            ? DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(coupon['start_date']))
            : '';
        endDateController.text = coupon['end_date'] != null
            ? DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(coupon['end_date']))
            : '';
        usageLimitController.text = coupon['usage_limit'].toString();
        perUserLimitController.text =
            coupon['per_user_limit']?.toString() ?? '1';

        final selectedUser = coupon['allowed_users'] ?? [];
        if (selectedUser.isNotEmpty) {
          addMultipleUsers = true;
          selectedUsers = selectedUser.isEmpty
              ? []
              : selectedUser
                  .map((e) => allUsersNameMap?[e])
                  .whereType<String>()
                  .toList();
          print('selectedUsers: $selectedUsers');
          Future.microtask(() => update());
        } else {
          selectedUsers = [];
          addMultipleUsers = false;
        }

        selectedChannels =
            List<String>.from(coupon['applicable_channels'] ?? []);
      } else {
        clearCouponData();
      }
    });
  }

  Future<void> getCouponList() async {
    isLoading = true;
    coupons.clear();
    update();
    Response response = await loyaltyRepo.getCouponList();
    if (response.statusCode == 200) {
      coupons = List<Map<String, dynamic>>.from(response.body ?? []);
      // print('Coupon List: ${response.body}');
    } else if (response.statusCode == 404) {
      print('${response.statusCode}......${response.body['message']}');
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> addCoupon(Map<String, dynamic> data) async {
    isLoading = true;
    update();
    Response response = await loyaltyRepo.addCoupon(data);
    if (response.statusCode == 200) {
      Get.back();
      await getCouponList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
      clearCouponData();
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<Map<String, dynamic>> checkValidCoupon(
      String couponCode, String orderType, String userID, double amount) async {
    Map<String, dynamic> jsonResponse = {};
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Map<String, dynamic> data = {
      'code': couponCode,
      'restaurant_id':
          Get.find<AuthController>().profileModel!.restaurants!.first.id,
      'channel': orderType,
      'user_id': userID,
      'amount': amount
    };
    Response response = await loyaltyRepo.checkValidCoupon(data);
    Get.find<LoadingController>().startLoading(false);
    jsonResponse = response.body;

    if (response.statusCode == 200 &&
        response.body.containsKey('message') &&
        response.body['message'] == 'Coupon is valid') {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message']);
      await Get.find<LoadingController>().changeStatus(data: true);

      // showErrorToast(response.body['message'], isError: false);
    } else {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message'], error: true);
      await Get.find<LoadingController>().changeStatus(data: true);

      // showErrorToast(response.body['message'], isError: true);
    }
    update();
    return jsonResponse;
  }

  Future<Map<String, dynamic>> checkValidLoyaltyPoint(
      String userID, double amount,
      {bool isLoading = true}) async {
    Map<String, dynamic> jsonResponse = {};
    if (isLoading) showToast('Loading');
    if (isLoading) Get.find<LoadingController>().startLoading(true);

    Map<String, dynamic> data = {
      'restaurant_id':
          Get.find<AuthController>().profileModel!.restaurants!.first.id,
      'user_id': userID,
      'amount': amount
    };
    Response response = await loyaltyRepo.checkValidLoyaltyPoint(data);
    if (isLoading) Get.find<LoadingController>().startLoading(false);
    jsonResponse = response.body;

    if (response.statusCode == 200) {
      if (isLoading)
        await Get.find<LoadingController>()
            .changeText(data: 'Applied loyalty points successfully');
      if (isLoading)
        await Get.find<LoadingController>().changeStatus(data: true);

      // showErrorToast(response.body['message'], isError: false);
    } else {
      if (isLoading)
        await Get.find<LoadingController>().changeStatus(data: true);

      // showErrorToast(response.body['message'], isError: true);
    }
    update();
    return jsonResponse;
  }

  Future<Map<String, dynamic>> redeemCoupon(
      String couponCode, String userID) async {
    isLoading = true;
    update();
    Map<String, dynamic> jsonResponse = {};
    // Get.find<LoadingController>().startLoading(true);

    Map<String, dynamic> data = {'code': couponCode, 'user_id': userID};
    Response response = await loyaltyRepo.redeemCoupon(data);
    // Get.find<LoadingController>().startLoading(false);
    jsonResponse = response.body;

    if (response.statusCode == 200 &&
        response.body.containsKey('message') &&
        response.body['message'] == 'Coupon redeemed successfully') {
      // await Get.find<LoadingController>()
      //     .changeText(data: response.body['message']);
      // await Get.find<LoadingController>().changeStatus(data: true);

      // showErrorToast(response.body['message'], isError: false);
    } else {
      // await Get.find<LoadingController>()
      //     .changeText(data: response.body['message'], error: true);
      // await Get.find<LoadingController>().changeStatus(data: true);
      isLoading = false;
      update();
      showErrorToast(response.body['message'], isError: true);
    }
    update();
    return jsonResponse;
  }

  Future<void> updateCoupon(int id, Map<String, dynamic> data) async {
    isLoading = true;
    update();
    Response response = await loyaltyRepo.updateCoupon(id, data);
    if (response.statusCode == 200) {
      Get.back();
      await getCouponList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
      clearCouponData();
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  Future<void> deleteCoupon(int id) async {
    isLoading = true;
    update();
    Response response = await loyaltyRepo.deleteCoupon(id);
    if (response.statusCode == 200) {
      await getCouponList();
      Get.snackbar(
        "Success",
        response.body['message'],
        backgroundColor: ColorTheme.green,
        colorText: ColorTheme.whiteColor,
      );
    } else {
      Get.snackbar(
        "Something went wrong",
        response.body['message'],
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    }
    isLoading = false;
    update();
  }

  void saveCoupon(int id, {required isEdit}) {
    if (formKey.currentState!.validate()) {
      final data = {
        'code': CouponCodeController.text,
        'discount_type': discountType.toLowerCase(),
        'discount_value': double.parse(discountValueController.text),
        'start_date': startDateController.text,
        'end_date': endDateController.text,
        'usage_limit': int.parse(usageLimitController.text),
        'allowed_users': addMultipleUsers
            ? selectedUsers.map((e) => allUsersIdMap?[e]).toList()
            : [],
        'per_user_limit': perUserLimitController.text.isEmpty
            ? 1
            : int.parse(perUserLimitController.text),
        'applicable_channels': selectedChannels,
      };
      if (isEdit) {
        updateCoupon(id, data);
      } else {
        addCoupon(data);
      }
    }
  }

  void clearCouponData() {
    // formKey.currentState?.reset();
    CouponCodeController.clear();
    discountValueController.clear();
    usageLimitController.clear();
    perUserLimitController.clear();
    discountType = '';
    addMultipleUsers = false;
    allUsers = [];
    allUsersIdMap = {};
    selectedUsers.clear();
    selectedChannels.clear();
    startDateController.clear();
    endDateController.clear();
    update();
  }

  void toggleUserSelection(String user) {
    selectedUsers.contains(user)
        ? selectedUsers.remove(user)
        : selectedUsers.add(user);
    update();
  }

  void toggleChannelSelection(String channel) {
    selectedChannels.contains(channel)
        ? selectedChannels.remove(channel)
        : selectedChannels.add(channel);
    update();
  }

  Future<void> pickDate(
      {required bool isStart, required BuildContext context}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2029),
    );

    if (picked != null) {
      if (isStart) {
        startDate = picked;
        startDateController.text =
            '${picked.day}-${picked.month}-${picked.year}';
      } else {
        endDate = picked;
        endDateController.text = '${picked.day}-${picked.month}-${picked.year}';
      }
      update();
    }
  }

  Future getCustomerFromApi({bool isLoading = false}) async {
    allUsers = [];
    allUsersIdMap = {};
    Response response = await loyaltyRepo.getCustomerList({});
    update();
    if (response.statusCode == 200) {
      final data = response.body['customer_list'];
      allUsers = data
          .map<String>((customer) => customer['customer_name'].toString())
          .toList();
      for (var customer in data) {
        final customerName = customer['customer_name']?.toString().trim() ?? '';
        final customerId = customer['id'];
        if (customerName.isNotEmpty && customerId != null) {
          allUsersIdMap?[customerName] = customerId;
          allUsersNameMap?[customerId] = customerName;
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  //.................................... Coupon Usage Report ......................................//

  Future<void> getCouponUsageReport(
      String fromDate, String toDate, String couponCode) async {
    isLoadingCouponReport.value = true;
    try {
      Map<String, dynamic> data = {
        "from": fromDate,
        "to": toDate,
        "coupon_code": couponCode,
      };

      Response response = await loyaltyRepo.getCouponUsageReport(data);

      if (response.statusCode == 200) {
        log("------------: Fetch coupon_usage_report success");

        final map = response.body as Map;
        final orders = (map['orders'] as List?)?.cast<Map>().map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        final breakdown =
            (map['coupon_breakdown'] as List?)?.cast<Map>().map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        couponReportOrders.value = orders ?? [];
        couponBreakdown.value = breakdown ?? [];
        couponReportSummary.value =
            Map<String, dynamic>.from(map['summary'] ?? {});
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: getCouponUsageReport - ${response.statusText}");
        couponReportOrders.clear();
        couponBreakdown.clear();
        couponReportSummary.clear();
      }
    } catch (e) {
      log("Error occurred while fetching getCouponUsageReport: $e");
      couponReportOrders.clear();
      couponBreakdown.clear();
      couponReportSummary.clear();
      Get.snackbar(
        "Error",
        "Failed to fetch coupon report: ${e.toString()}",
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    } finally {
      isLoadingCouponReport.value = false;
    }
  }

  Future<void> exportCouponUsageReport(
      String fromDate, String toDate, String couponCode) async {
    isLoadingCouponExport.value = true;
    try {
      Map<String, dynamic> data = {
        "from": fromDate,
        "to": toDate,
      };
      if (couponCode.trim().isNotEmpty) {
        data["coupon_code"] = couponCode;
      }

      Response response = await loyaltyRepo.exportCouponUsageReport(data);

      if (response.statusCode == 200) {
        log("------------: Export coupon_usage_report success");
        final downloadUrl = response.body["download_url"];
        final message = response.body["message"];

        if (downloadUrl != null) {
          await appLaunchUrl(downloadUrl);
        }

        if (message != null) {
          Get.snackbar(
            "Success",
            message,
            backgroundColor: ColorTheme.green,
            colorText: ColorTheme.whiteColor,
          );
        }
      } else {
        ApiChecker.checkApi(response);
        log("API Failed: exportCouponUsageReport - ${response.statusText}");
        Get.snackbar(
          "Error",
          response.body['message'] ?? "Failed to export coupon report",
          backgroundColor: ColorTheme.redF13,
          colorText: ColorTheme.whiteColor,
        );
      }
    } catch (e) {
      log("Error occurred while exporting coupon report: $e");
      Get.snackbar(
        "Error",
        "Failed to export coupon report: ${e.toString()}",
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    } finally {
      isLoadingCouponExport.value = false;
    }
  }

  /// dine-in, walk-in, and room service map to dine_in. Never "pos".
  static String crmOrderChannel(String raw) {
    final value = raw.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (value.contains('take')) return 'takeaway';
    if (value.contains('deliver')) return 'delivery';
    return 'dine_in';
  }

  static double crmNum(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? 0}') ?? 0;
  }

  String? _crmErrorCode(Map<String, dynamic>? data) {
    if (data == null) return null;
    final error = data['error'];
    if (error is Map && error['code'] != null) return error['code'].toString();
    return null;
  }

  String _crmErrorText(Map<String, dynamic>? data) {
    if (data == null) return 'Unable to calculate loyalty discount';
    final instruction = data['pos_instruction']?.toString();
    if (instruction != null && instruction.isNotEmpty) return instruction;
    final error = data['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    return data['message']?.toString() ?? 'Unable to calculate loyalty discount';
  }

  Map<String, dynamic>? _crmPayload(Response response) {
    if (response.body is! Map) return null;
    final body = Map<String, dynamic>.from(response.body as Map);
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return body;
  }

  Future<Response> _retryCrm(
    Future<Response> Function() call,
  ) async {
    final first = await call();
    if (first.statusCode == 401) {
      final refreshed = await Get.find<AuthController>().refreshCrmToken();
      if (refreshed) return call();
    }
    return first;
  }

  String get _crmRestaurantId =>
      Get.find<AuthController>()
          .profileModel
          ?.restaurants
          ?.first
          .id
          ?.toString() ??
      '';

  /// Preview only. Does not redeem points.
  Future<Map<String, dynamic>> fetchCrmMaxRedeemable({
    String? customerId,
    String? phone,
    required double billAmount,
  }) async {
    final hidden = {
      'ok': false,
      'hidden': true,
      'belowMin': false,
      'message': '',
      'maxPoints': 0.0,
      'maxDiscount': 0.0,
      'availablePoints': 0.0,
      'minPoints': 0.0,
      'tier': '',
      'earnPoints': 0,
      'enabled': false,
    };
    final id = customerId?.trim() ?? '';
    final mobile = phone?.trim() ?? '';
    if (billAmount <= 0 || (id.isEmpty && mobile.isEmpty)) return hidden;
    try {
      final body = <String, dynamic>{
        'pos_id': 'mygenie',
        'restaurant_id': _crmRestaurantId,
        'bill_amount': billAmount,
      };
      if (id.isNotEmpty) {
        body['customer_id'] = id;
      } else {
        body['cust_mobile'] = mobile;
      }
      final response = await _retryCrm(() => loyaltyRepo.crmMaxRedeemable(body));
      if (response.statusCode != 200) {
        return {
          ...hidden,
          'hidden': false,
          'message': 'Unable to calculate loyalty discount',
        };
      }
      final data = _crmPayload(response);
      final code = _crmErrorCode(data);
      const hideCodes = {
        'LOYALTY_DISABLED',
        'SETTINGS_MISSING',
        'CUSTOMER_NOT_FOUND',
        'INVALID_REQUEST',
      };
      if (hideCodes.contains(code)) return hidden;
      if (code == 'BELOW_MIN_REDEMPTION') {
        final minPoints = crmNum(data?['min_redemption_points']);
        return {
          ...hidden,
          'ok': true,
          'hidden': false,
          'belowMin': true,
          'message': 'Minimum ${minPoints.toStringAsFixed(0)} points required',
          'availablePoints': crmNum(data?['available_points']),
          'minPoints': minPoints,
          'tier': data?['tier']?.toString() ?? '',
          'earnPoints': crmNum(data?['projected_points_earned']).round(),
          'enabled': data?['loyalty_enabled'] == true,
        };
      }
      if (code != null || data?['loyalty_enabled'] == false) {
        return {
          ...hidden,
          'hidden': false,
          'message': 'Unable to calculate loyalty discount',
        };
      }
      return {
        'ok': true,
        'hidden': false,
        'belowMin': false,
        'message': '',
        'maxPoints': crmNum(data?['max_points_redeemable']),
        'maxDiscount': crmNum(data?['max_discount_value']),
        'availablePoints': crmNum(data?['available_points']),
        'minPoints': crmNum(data?['min_redemption_points']),
        'tier': data?['tier']?.toString() ?? '',
        'earnPoints': crmNum(data?['projected_points_earned']).round(),
        'enabled': data?['loyalty_enabled'] != false,
      };
    } catch (e) {
      return {
        ...hidden,
        'hidden': false,
        'message': 'Unable to calculate loyalty discount',
      };
    }
  }

  Future<Map<String, dynamic>> validateCrmCoupon({
    required String code,
    required String customerId,
    required double orderTotal,
    required String channel,
    int loyaltyPointsUsed = 0,
    List<Map<String, dynamic>>? items,
  }) async {
    final failed = {
      'valid': false,
      'message': 'Invalid coupon code',
      'code': code.trim().toUpperCase(),
      'title': '',
      'discount': 0.0,
      'couponType': '',
      'benefit': '',
      'stackable': true,
      'benefitItems': null,
    };
    if (customerId.trim().isEmpty || code.trim().isEmpty) {
      return {...failed, 'message': 'Please select customer for applying coupon'};
    }
    try {
      final body = <String, dynamic>{
        'code': code.trim().toUpperCase(),
        'customer_id': customerId.trim(),
        'order_total': orderTotal,
        'channel': channel,
        'loyalty_points_used': loyaltyPointsUsed,
        'items': (items == null || items.isEmpty) ? null : items,
        'order_time': DateTime.now().toUtc().toIso8601String(),
      };
      final response = await _retryCrm(() => loyaltyRepo.crmValidateCoupon(body));
      if (response.statusCode != 200) {
        return {...failed, 'message': 'Unable to validate coupon'};
      }
      final data = _crmPayload(response);
      if (data?['valid'] == true) {
        final scope = data?['discount_scope']?.toString() ??
            data?['coupon_type']?.toString() ??
            'order';
        final normalizedScope = scope == 'item' || scope == 'category'
            ? scope
            : 'order';
        return {
          'valid': true,
          'message': '',
          'code': data?['code']?.toString() ?? code.trim().toUpperCase(),
          'title': data?['title']?.toString() ?? code.trim().toUpperCase(),
          'discount': crmNum(data?['computed_discount']),
          'couponType': normalizedScope,
          'benefit': crmBenefitLine(data?['benefit_items']),
          'stackable': data?['stackable_with_loyalty'] != false,
          'benefitItems': data?['benefit_items'],
        };
      }
      return {
        ...failed,
        'message': _crmErrorText(data),
        'stackable': data?['stackable_with_loyalty'] != false,
      };
    } catch (e) {
      return {...failed, 'message': 'Unable to validate coupon'};
    }
  }

  /// Best in-window order coupon that does not need the cart. Null when none.
  Future<Map<String, dynamic>?> fetchBestCrmOrderCoupon({
    required String customerId,
    required double orderTotal,
    required String channel,
  }) async {
    if (customerId.trim().isEmpty || orderTotal <= 0) return null;
    try {
      final response = await _retryCrm(() => loyaltyRepo.crmCouponsAvailable(
            customerId: customerId.trim(),
            orderTotal: orderTotal,
            channel: channel,
          ));
      if (response.statusCode != 200) return null;
      final data = _crmPayload(response);
      final raw = data?['coupons'] ?? data?['items'] ?? data;
      if (raw is! List) return null;
      final coupons = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((coupon) {
        final window = coupon['time_window'];
        final inWindow = window is! Map || window['within_window_now'] != false;
        final needsCart = coupon['requires_cart_validation'] == true;
        final scope = coupon['discount_scope']?.toString() ?? 'order';
        final offer = coupon['offer_type']?.toString() ?? 'simple';
        return inWindow &&
            !needsCart &&
            scope == 'order' &&
            offer == 'simple';
      }).toList();
      if (coupons.isEmpty) return null;
      coupons.sort((a, b) => crmNum(b['expected_discount']).compareTo(crmNum(a['expected_discount'])));
      return coupons.first;
    } catch (e) {
      return null;
    }
  }

  static String crmBenefitLine(dynamic benefitItems) {
    if (benefitItems is! List) return '';
    final parts = <String>[];
    for (final item in benefitItems) {
      if (item is! Map) continue;
      final name = item['name']?.toString() ?? item['item_name']?.toString() ?? '';
      final qty = item['quantity'] ?? item['qty'] ?? 1;
      final note = item['label']?.toString() ?? item['benefit']?.toString() ?? '';
      if (name.isEmpty && note.isEmpty) continue;
      parts.add(note.isNotEmpty ? note : '${qty}× $name');
    }
    return parts.join(', ');
  }

  static bool crmBenefitBlocked(
    dynamic benefitItems,
    bool Function(String foodId) lineRejectsDiscount,
  ) {
    final ids = <String>{};
    void walk(dynamic node) {
      if (node is Map) {
        for (final key in ['food_id', 'item_id', 'id']) {
          final value = node[key]?.toString() ?? '';
          if (value.isNotEmpty) ids.add(value);
        }
        node.values.forEach(walk);
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(benefitItems);
    for (final id in ids) {
      if (lineRejectsDiscount(id)) return true;
    }
    return false;
  }
}
