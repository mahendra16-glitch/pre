import 'dart:convert';
import 'dart:developer';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';
import 'package:mygenie_restaurant/view/screens/settlement/model/settlement_restaurant_model.dart';
import 'package:mygenie_restaurant/view/screens/settlement/model/waiter_model.dart';
import 'package:mygenie_restaurant/view/screens/settlement/settlement_repo/settlement_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';

import '../../../../data/api/api_checker.dart' show ApiChecker;

class SettlementManagementController extends GetxController
    implements GetxService {
  final SettlementManagementRepo settlementManagementRepo;
  SettlementManagementController({required this.settlementManagementRepo});

  SettlementRestaurantModel? settlementRestaurantModel;
  SettlementRestaurantModel? removeFirstSettlementRestaurantModel;

  showWaiter(SettleMentData? settleMentData) {
    final isCurrentlyVisible = settleMentData?.isShowWaiter ?? false;
    settleMentData?.isShowWaiter = !isCurrentlyVisible;

    update();
  }

  bool isSettlementLoader = false;
  setIsSettlementLoader(bool val) {
    isSettlementLoader = val;
    update();
  }

  List<TextEditingController> settlementFirstIndexWaiterTControllerList = [];

  List<List<TextEditingController>> settlementAfterIndexWaiterTControllerList =
      [];

  List<TextEditingController>
      settlementFirstIndexExpectedBalanceControllerList = [];

  List<List<TextEditingController>>
      settlementAfterIndexExpectedBalanceControllerList = [];

  Future<void> getSettlementRestaurantList() async {
    try {
      setIsSettlementLoader(true);

      Map<String, dynamic> body = {
        "date_from": purchaseFromDate,
        "date_to": purchaseToDate
      };

      log("getSettlementRestaurantList body :$body");

      final response =
          await settlementManagementRepo.settlementRestaurantList(body);

      if (response?.statusCode == 200) {
        var decodedResponse = response?.body is String
            ? jsonDecode(response?.body)
            : response?.body;

        settlementRestaurantModel =
            SettlementRestaurantModel.fromJson(decodedResponse);
        if (settlementRestaurantModel != null) {
          settlementFirstIndexWaiterTControllerList = List.generate(
            (settlementRestaurantModel?.data?.last.waiters?.length ?? 0),
            (index) => TextEditingController(text: ""),
          );
          settlementFirstIndexExpectedBalanceControllerList = List.generate(
            (settlementRestaurantModel?.data?.last.waiters?.length ?? 0),
            (index) => TextEditingController(text: ""),
          );
        }

        removeFirstSettlementRestaurantModel =
            SettlementRestaurantModel.fromJson(decodedResponse);

        if (settlementRestaurantModel?.data != null &&
                settlementRestaurantModel?.data?.isNotEmpty == true ||
            removeFirstSettlementRestaurantModel?.data != null &&
                removeFirstSettlementRestaurantModel?.data?.isNotEmpty ==
                    true) {
          removeFirstSettlementRestaurantModel?.data?.removeLast();

          removeFirstSettlementRestaurantModel?.data?.forEach((restaurant) {
            final waiters = restaurant.waiters ?? [];
            final controllerList = List.generate(
              waiters.length,
              (index) => TextEditingController(text: ""),
            );
            settlementAfterIndexWaiterTControllerList.add(controllerList);
            final expectedBalanceControllerList = List.generate(
              waiters.length,
              (index) => TextEditingController(text: ""),
            );
            settlementAfterIndexExpectedBalanceControllerList
                .add(expectedBalanceControllerList);
          });
        } else {
          log('No data available');
        }
      } else {
        ApiChecker.checkApi(response!);
      }

      update();
    } catch (e) {
      log("getSettlementRestaurantList Error: $e");
    } finally {
      setIsSettlementLoader(false);
    }
  }

  String? purchaseFromDate;
  picFromDate() async {
    DateTime? dateTime = await pickedDate(purchaseFromDate);
    if (dateTime != null) {
      purchaseFromDate = DateFormat('dd-MM-yyyy').format(dateTime);
      await getSettlementRestaurantList();

      update();
    }
  }

  String? purchaseToDate;
  picToDate() async {
    DateTime? minDate = purchaseFromDate != null
        ? DateFormat('dd-MM-yyyy').parse(purchaseFromDate!)
        : DateTime.now();

    DateTime? dateTime = await pickedDate(purchaseToDate,
        minDate: minDate, maxDate: DateTime.now());
    if (dateTime != null) {
      purchaseToDate = DateFormat('dd-MM-yyyy').format(dateTime);

      await getSettlementRestaurantList();

      update();
    }
  }

  bool waiterFullSettlementLoader = false;

  Future<void> waiterFullSettlement({String? date, int? waiterId}) async {
    try {
      waiterFullSettlementLoader = true;
      update();
      Map<String, dynamic> body = {
        "date": date,
        "waiter_id": waiterId,
        "settlement_type": "full"
      };

      log('waiterFullSettlement :$body');
      final response =
          await settlementManagementRepo.waiterFullSettlement(body);

      if (response?.statusCode == 200) {
        await getSettlementRestaurantList();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("waiterFullSettlement Error: $e");
    } finally {
      waiterFullSettlementLoader = false;
      update();
    }
    update();
  }

  Future<void> allWaiterSettlement({String? date}) async {
    try {
      waiterFullSettlementLoader = true;
      update();
      Map<String, dynamic> body = {"date": date, "settlement_type": "full"};

      log('AllwaiterSettlement :$body');
      final response =
          await settlementManagementRepo.waiterFullSettlement(body);

      if (response?.statusCode == 200) {
        await getSettlementRestaurantList();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("AllwaiterSettlement Error: $e");
    } finally {
      waiterFullSettlementLoader = false;
      update();
    }
    update();
  }

  bool waiterPartialSettlementLoader = false;

  Future<void> waiterPartialSettlement(
      {String? date,
      int? waiterId,
      Waiter? waiter,
      required TextEditingController controller,
      TextEditingController? expectedBalanceController}) async {
    try {
      if (controller.text.isNotEmpty) {
        double controllerValue = double.tryParse(controller.text) ?? 0;
        double waiterValue =
            double.tryParse(waiter?.balanceToSettle ?? "0") ?? 0;

        if (controllerValue <= waiterValue) {
          waiterPartialSettlementLoader = true;
          update();

          // Calculate pilferage: balanceToSettle - expectedBalance
          double pilferage = 0;
          if (expectedBalanceController != null &&
              expectedBalanceController.text.isNotEmpty) {
            double balanceToSettle =
                double.tryParse(waiter?.balanceToSettle ?? "0") ?? 0;
            double expectedBalance =
                double.tryParse(expectedBalanceController.text) ?? 0;
            pilferage = expectedBalance - balanceToSettle;
          }

          Map<String, dynamic> body = {
            "date": date,
            "waiter_id": waiterId,
            "amount": int.tryParse(controller.text),
            "settlement_type": "partial",
            "pilferage": pilferage,
          };

          log('body :${body}');

          final response =
              await settlementManagementRepo.waiterPartialSettlement(body);

          if (response?.statusCode == 200) {
            controller.text = "";
            await getSettlementRestaurantList();
            Get.snackbar('${response?.body?["message"]}', '',
                backgroundColor: ColorTheme.greenColor,
                colorText: Colors.white);
          } else {
            ApiChecker.checkApi(response!);
            Get.snackbar('${response.body?["message"]}', '',
                backgroundColor: ColorTheme.redColor, colorText: Colors.white);
          }
        } else {
          appToast("Current Balance Not enough");
        }
      } else {
        appToast("Please Enter Current Balance");
      }
    } catch (e) {
      log("waiterPartialSettlement Error: $e");
    } finally {
      waiterPartialSettlementLoader = false;
      update();
    }
    update();
  }

  bool isAddWaiterOpeningBalanceLoader = false;
  bool isAddWaiterOpeningBalanceSubmitting = false;

  setAddWaiterOpeningBalanceLoader(bool val) {
    isAddWaiterOpeningBalanceLoader = val;
    isAddWaiterOpeningBalanceSubmitting = val;
    update();
  }

  Future<void> addWaiterOpeningBalance(
      {String? date, int? index, Waiter? waiter}) async {
    try {
      if (isAddWaiterOpeningBalanceSubmitting) return;
      setAddWaiterOpeningBalanceLoader(true);

      Map<String, dynamic> body = {
        "openings": waiterModel?.data
            ?.where((element) => element.isChecked == true)
            .map((e) {
          int index = waiterModel?.data?.indexOf(e) ?? 0;
          int todayGiven = getWaiterTextControllerList.length > index
              ? int.tryParse(getWaiterTextControllerList[index].text) ?? 0
              : 0;

          return {
            "waiter_id": e.id,
            "date": date,
            "last_day_pending": 0,
            "today_given": todayGiven,
          };
        }).toList(),
      };

      final response =
          await settlementManagementRepo.addWaiterOpeningBalance(body);

      if (response?.statusCode == 200) {
        // update();

        Get.back();
        await getSettlementRestaurantList();
        // showToast("Opening balances saved successfully");
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("openingBalance Error: $e");
    } finally {
      setAddWaiterOpeningBalanceLoader(false);
    }

    update();
  }

  WaiterModel? waiterModel;

  List<TextEditingController> getWaiterTextControllerList = [];

  Future<void> getWaiterList() async {
    try {
      final response = await settlementManagementRepo.getWaiterList();

      if (response?.statusCode == 200) {
        waiterModel = WaiterModel.fromJson(response?.body);

        if (waiterModel?.data != null) {
          getWaiterTextControllerList = List.generate(
            waiterModel!.data!.length,
            (index) => TextEditingController(text: ""),
          );
        }
      } else {
        ApiChecker.checkApi(response!);
      }
      update();
    } catch (e) {
      log("getWaiterList Error: $e");
    }
    update();
  }

  // Self settle - allows waiter to settle their own balance
  bool isSelfSettleLoader = false;

  // In your settlement controller
  List<dynamic> get restaurantSchedules {
    try {
      return Get.find<AuthController>()
              .profileModel
              ?.restaurants
              ?.first
              .schedules ??
          [];
    } catch (e) {
      log("Error accessing schedules: $e");
      return [];
    }
  }

  /// Get business date based on restaurant closing time
  String getBusinessDate() {
    DateTime now = DateTime.now();

    // Get current day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
    int currentDay = now.weekday % 7;

    // Get today's closing time from schedules
    TimeOfDay closingTime = getClosingTimeForDay(currentDay);

    // Check if closing time indicates overnight operation
    // (e.g., closing at 3 AM means it's less than opening time)
    TimeOfDay openingTime = getOpeningTimeForDay(currentDay);

    bool isOvernightOperation = closingTime.hour < openingTime.hour;

    if (isOvernightOperation) {
      // Restaurant closes after midnight (e.g., 3:00 AM)
      // If current time is between 00:00 and closing time,
      // we're still in yesterday's business day

      if (now.hour < closingTime.hour ||
          (now.hour == closingTime.hour && now.minute < closingTime.minute)) {
        // Current time is in early morning (before closing)
        // Use previous day as business date
        DateTime businessDate = now.subtract(Duration(days: 1));
        log("Business Date: ${DateFormat('yyyy-MM-dd').format(businessDate)} (using previous day)");
        return DateFormat('yyyy-MM-dd').format(businessDate);
      }
    }

    // Normal case: use current date as business date
    log("Business Date: ${DateFormat('yyyy-MM-dd').format(now)} (current day)");
    return DateFormat('yyyy-MM-dd').format(now);
  }

  /// Get closing time for a specific day from restaurant schedules
  TimeOfDay getClosingTimeForDay(int day) {
    try {
      var schedules = Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .schedules ??
          [];

      var schedule = schedules.firstWhere((s) => s.day == day);

      String closingTimeStr = schedule.closingTime ?? "03:00:00";
      List<String> parts = closingTimeStr.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      log("Error getting closing time for day $day: $e");
      return TimeOfDay(hour: 3, minute: 0); // Default
    }
  }

  /// Get opening time for a specific day from restaurant schedules
  TimeOfDay getOpeningTimeForDay(int day) {
    try {
      var schedules = Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .schedules ??
          [];

      var schedule = schedules.firstWhere((s) => s.day == day);

      String openingTimeStr = schedule.openingTime ?? "06:00:00";
      List<String> parts = openingTimeStr.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      log("Error getting opening time for day $day: $e");
      return TimeOfDay(hour: 6, minute: 0); // Default
    }
  }

  Future<void> selfSettle({String? date}) async {
    try {
      isSelfSettleLoader = true;
      update();

      String formattedDate = date ?? "";

      if (formattedDate.isEmpty) {
        // Auto-calculate business date based on restaurant hours
        formattedDate = getBusinessDate();
      } else {
        // Manual date provided - convert from dd-MM-yyyy to yyyy-MM-dd
        try {
          DateTime dateTime = DateFormat('dd-MM-yyyy').parse(formattedDate);
          formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        } catch (e) {
          log("Date parsing error: $e");
          formattedDate = getBusinessDate();
        }
      }

      Map<String, dynamic> body = {"date": formattedDate};

      log('selfSettle body: $body');
      final response =
          await settlementManagementRepo.waiterSelfSettlement(body);

      if (response?.statusCode == 200) {
        var decodedResponse = response?.body is String
            ? jsonDecode(response?.body)
            : response?.body;

        String message = decodedResponse['message'] ??
            "Self settlement completed successfully";
        String date = decodedResponse['date'] ?? "";
        List<dynamic> settledWaiters = decodedResponse['settled_waiters'] ?? [];

        String waitersInfo = "";
        if (settledWaiters.isNotEmpty) {
          List<String> waiterDetails = settledWaiters.map((waiter) {
            int waiterId = waiter['waiter_id'] ?? 0;
            double remainingBalance =
                (waiter['remaining_balance'] ?? 0).toDouble();
            return "Waiter ID: $waiterId, Remaining Balance: ₹${remainingBalance.toStringAsFixed(2)}";
          }).toList();
          waitersInfo = "\n\n" + waiterDetails.join("\n");
        }

        String snackbarMessage = "";
        if (date.isNotEmpty) {
          snackbarMessage += "Date: $date";
        }
        if (waitersInfo.isNotEmpty) {
          snackbarMessage += waitersInfo;
        }

        Get.snackbar(
          message,
          snackbarMessage,
          // snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorTheme.greenColor,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        await getSettlementRestaurantList();
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("selfSettle Error: $e");
      appToast("Error during self settlement");
    } finally {
      isSelfSettleLoader = false;
      update();
    }
  }

  // Settlement Closing Report
  final RxBool isLoadingSettlementReport = false.obs;
  final RxList<Map<String, dynamic>> settlementReportRows =
      <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> settlementReportSummary =
      Rxn<Map<String, dynamic>>();

  Future<void> getSettlementClosingReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      isLoadingSettlementReport.value = true;

      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> requestData = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      log("getSettlementClosingReport body: $requestData");

      final response = await settlementManagementRepo
          .getSettlementClosingReport(requestData);

      if (response?.statusCode == 200) {
        var decodedResponse = response?.body is String
            ? jsonDecode(response?.body)
            : response?.body;

        if (decodedResponse != null && decodedResponse is Map) {
          // Extract data array
          if (decodedResponse['data'] != null &&
              decodedResponse['data'] is List) {
            settlementReportRows.value = List<Map<String, dynamic>>.from(
                decodedResponse['data']
                    .map((item) => Map<String, dynamic>.from(item)));
          } else {
            settlementReportRows.value = [];
          }

          // Extract summary
          if (decodedResponse['summary'] != null &&
              decodedResponse['summary'] is Map) {
            settlementReportSummary.value =
                Map<String, dynamic>.from(decodedResponse['summary']);
          } else {
            settlementReportSummary.value = null;
          }
        } else {
          settlementReportRows.value = [];
          settlementReportSummary.value = null;
        }
      } else {
        ApiChecker.checkApi(response!);
        settlementReportRows.value = [];
        settlementReportSummary.value = null;
      }
    } catch (e) {
      log("getSettlementClosingReport Error: $e");
      settlementReportRows.value = [];
      settlementReportSummary.value = null;
    } finally {
      isLoadingSettlementReport.value = false;
    }
  }

  String _convertDateFormat(String date) {
    try {
      // Convert from dd/MM/yyyy to yyyy-MM-dd
      if (date.isEmpty) return date;
      final parts = date.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return date;
    } catch (e) {
      log("_convertDateFormat Error: $e");
      return date;
    }
  }

  RxBool isLoadingSettlementExport = false.obs;

  // Settlement Closing Report New
  final RxBool isLoadingSettlementReportNew = false.obs;
  final RxList<Map<String, dynamic>> settlementReportRowsNew =
      <Map<String, dynamic>>[].obs;

  Future<void> getSettlementClosingReportNew({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      isLoadingSettlementReportNew.value = true;

      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> requestData = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      log("getSettlementClosingReportNew body: $requestData");

      final response = await settlementManagementRepo
          .getSettlementClosingReportNew(requestData);

      if (response?.statusCode == 200) {
        var decodedResponse = response?.body is String
            ? jsonDecode(response?.body)
            : response?.body;

        if (decodedResponse != null && decodedResponse is Map) {
          // Extract data array
          if (decodedResponse['data'] != null &&
              decodedResponse['data'] is List) {
            settlementReportRowsNew.value = List<Map<String, dynamic>>.from(
                decodedResponse['data']
                    .map((item) => Map<String, dynamic>.from(item)));
          } else {
            settlementReportRowsNew.value = [];
          }
        } else {
          settlementReportRowsNew.value = [];
        }
      } else {
        ApiChecker.checkApi(response!);
        settlementReportRowsNew.value = [];
      }
    } catch (e) {
      log("getSettlementClosingReportNew Error: $e");
      settlementReportRowsNew.value = [];
    } finally {
      isLoadingSettlementReportNew.value = false;
    }
  }

  Future<void> exportSettlementClosingReport({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      isLoadingSettlementExport.value = true;

      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> requestData = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      log("exportSettlementClosingReport body: $requestData");

      final response = await settlementManagementRepo
          .exportSettlementClosingReport(requestData);

      if (response?.statusCode == 200) {
        log("------------: Export settlement_closing_report success");
        final downloadUrl = response?.body["download_url"];
        final message = response?.body["message"];

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
        ApiChecker.checkApi(response!);
        log("API Failed: exportSettlementClosingReport - ${response.statusText}");
        Get.snackbar(
          "Error",
          response.body['message'] ?? "Failed to export settlement report",
          backgroundColor: ColorTheme.redF13,
          colorText: ColorTheme.whiteColor,
        );
      }
    } catch (e) {
      log("Error occurred while exporting settlement report: $e");
      Get.snackbar(
        "Error",
        "Failed to export settlement report: ${e.toString()}",
        backgroundColor: ColorTheme.redF13,
        colorText: ColorTheme.whiteColor,
      );
    } finally {
      isLoadingSettlementExport.value = false;
    }
  }
}
