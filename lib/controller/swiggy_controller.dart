import 'dart:developer';

import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/helper/print_debug_logger.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import '../data/api/api_checker.dart';
import '../data/model/response/get_swiggy_order_list_response.dart';
import '../data/repository/swiggy_repo.dart';
import '../view/base/custom_snackbar.dart';

class SwiggyController extends GetxController implements GetxService {
  final SwiggyRepo swiggyRepo;
  SwiggyController({required this.swiggyRepo});

  bool _isLoading = false;
  bool isLoadingExport = false;
  String orderIdFromSocket = '';

  bool get isLoading => _isLoading;
  List<Order> order = [];
  String _isSwiggyStoreOpen = 'Yes';
  String _isZommatoStoreOpen = 'Yes';
  String get isSwiggyStoreOpen => _isSwiggyStoreOpen;
  String get isZommatoStoreOpen => _isZommatoStoreOpen;

  List<Order> completedOrderByDate = [];
  List<String> cancelReasonList = [
    'item_out_of_stock',
    'store_closed',
    'store_busy',
    'rider_not_available',
    'out_of_delivery_radius',
    'connectivity_issue',
    'total_missmatch',
    'invalid_item',
    'option_out_of_stock',
    'invalid_option',
    'unspecified'
  ];
  int _updatedOrderIndex = 0;
  int get updatedOrderIndex => _updatedOrderIndex;

  Future<void> fetchOrders() async {
    _isLoading = true;
    update();
    try {
      final response = await swiggyRepo.getOrderList();
      final responseData = response.body;
      order = [];
      _isLoading = false;
      update();
      if (response.statusCode == 200) {
        print(
            "Response Data: $responseData"); // Debug the response to check the structure
        if (responseData['orders'] != null) {
          order = (responseData['orders'] as List)
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();
        } else {
          order = [];
        }
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      update(); // Notify UI if using GetX
    }
  }

  Future<void> fetchStoreStatus() async {
    _isLoading = true;
    update();
    try {
      final response = await swiggyRepo.getStoreStatus();

      _isLoading = false;
      update();
      if (response.statusCode == 200) {
        setStoreOpenVal(response.body['swiggy'], isSwiggy: true);
        setStoreOpenVal(response.body['zomato']);
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      update(); // Notify UI if using GetX
    }
  }

  clearOrderList() {
    order.clear();
    update();
  }

  Future<void> changeOrderStatus(Map<String, dynamic> jsonBody,
      {String type = ''}) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    Response response = await swiggyRepo.changeOrderStatus(jsonBody);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      if (type == 'preparation') {
        if (Get.isBottomSheetOpen ?? false) Get.back();
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSwiggyOrderByDate(String date) async {
    Response response = await swiggyRepo.getOrderByDate(date);
    _isLoading = false;
    completedOrderByDate = [];
    if (response.statusCode == 200) {
      if (response.body['orders'] != null) {
        completedOrderByDate = (response.body['orders'] as List)
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      } else {
        completedOrderByDate = [];
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getOrderDetailFromSocket(
      {
      // Socket socket,
      String? type,
      String? orderId,
      String? foodStatus,
      dynamic socketJson,
      Function? callbackFunction}) async {
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;
    late Order jsonData;

    if (socketJson == null) {
      Response response = await swiggyRepo.getOrderDetailFromSocket('$orderId');
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response);
        return false;
      }
      jsonData =
          Order.fromJson(Map<String, dynamic>.from(response.body['orders']));
    } else {
      final Map<String, dynamic> socketMap =
          Map<String, dynamic>.from(socketJson as Map);
      jsonData = Order.fromJson(
          Map<String, dynamic>.from(socketMap['orders'] as Map));
    }

      if (type == 'aggrigator-order-update') {
        int? index;
        for (int i = 0; i < order.length; i++) {
          if (order[i].orderDetailsOrder.id == jsonData.orderDetailsOrder.id) {
            index = i;
          }
        }
        if (type == 'aggrigator-order-update' && index != null) {
          final previousStatus = order[index].orderDetailsOrder.fOrderStatus;
          if (previousStatus == 0 &&
              jsonData.orderDetailsOrder.fOrderStatus != 0) {
            stopOrderAlert('${jsonData.orderDetailsOrder.id}');
          }
          order[index].orderDetailsOrder.fOrderStatus =
              jsonData.orderDetailsOrder.fOrderStatus;

          order[index].orderDetailsOrder.preparationTime =
              jsonData.orderDetailsOrder.preparationTime;
          order[index].orderDetailsOrder.scheduleAt =
              jsonData.orderDetailsOrder.scheduleAt;
          order[index].orderDetailsOrder.readyAt =
              jsonData.orderDetailsOrder.readyAt;

          _updatedOrderIndex = index;
          if (foodStatus == 'Assigned' && jsonData.riderInfo != null) {
            order[index].riderInfo = jsonData.riderInfo;
          }
          if (foodStatus == 'At store' &&
              jsonData.orderDetailsOrder.handover != null &&
              jsonData.orderDetailsOrder.handover != '') {
            order[index].orderDetailsOrder.handover =
                jsonData.orderDetailsOrder.handover;
          }
          update();
          print("foodStatus = $foodStatus");
          print(
              "aggregatorAutoKot = ${profileModel.restaurants!.first.settings!.aggregatorAutoKot}");
          print("empId = ${profileModel.empId}");
          print("aggregatorAutoKotId = ${profileModel.aggregatorAutoKotId}");

          final _traceAgg = PrintDebugController.generateTraceId(isAggregator: true);
          final _autoKotId = profileModel.aggregatorAutoKotId!.contains(profileModel.empId);
          final _autoKot = profileModel.restaurants!.first.settings!.aggregatorAutoKot == 'Yes';
          final _autoBill = profileModel.restaurants!.first.settings!.aggregatorAutoBill == 'Yes';
          final _billStage = profileModel.restaurants!.first.settings!.aggregatorAutoBillStage ?? '';

          PrintDebugLogger.decision(
            traceId: _traceAgg,
            orderId: orderId,
            flow: PrintFlowTag.aggregator,
            isAuto: true,
            result: 'evaluating',
            reason: 'aggrigator-order-update foodStatus=$foodStatus fOrderStatus=${jsonData.orderDetailsOrder.fOrderStatus}',
            empId: profileModel.empId?.toString(),
            aggregatorAutoKot: _autoKot,
            aggregatorAutoBill: _autoBill,
            aggregatorAutoBillStage: _billStage,
            aggregatorAutoKotIdContainsEmp: _autoKotId,
            isAggregator: true,
            details: {
              'foodStatus': foodStatus ?? '',
              'fOrderStatus': jsonData.orderDetailsOrder.fOrderStatus,
            },
          );

          if (callbackFunction != null &&
              foodStatus == 'Acknowledged' &&
              profileModel.aggregatorAutoKotId!.contains(profileModel.empId) &&
              jsonData.orderDetailsOrder.fOrderStatus == 1) {
            if (profileModel
                        .restaurants!.first.settings!.aggregatorAutoBillStage ==
                    'Acknowledged' &&
                profileModel.restaurants!.first.settings!.aggregatorAutoKot ==
                    'Yes' &&
                profileModel.restaurants!.first.settings!.aggregatorAutoBill ==
                    'Yes') {
              PrintDebugLogger.decision(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                result: 'PRINT_BOTH (KOT + BILL)',
                reason: 'Acknowledged + autoKot=Yes + autoBill=Yes + billStage=Acknowledged',
                aggregatorAutoKot: _autoKot,
                aggregatorAutoBill: _autoBill,
                aggregatorAutoBillStage: _billStage,
                aggregatorAutoKotIdContainsEmp: _autoKotId,
              );
              callbackFunction('both');
            } else if (profileModel
                    .restaurants!.first.settings!.aggregatorAutoKot ==
                'Yes') {
              PrintDebugLogger.decision(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                result: 'PRINT_KOT',
                reason: 'Acknowledged + autoKot=Yes',
                aggregatorAutoKot: _autoKot,
                aggregatorAutoBill: _autoBill,
                aggregatorAutoKotIdContainsEmp: _autoKotId,
              );
              callbackFunction('kot');
            } else if (profileModel
                        .restaurants!.first.settings!.aggregatorAutoBillStage ==
                    'Acknowledged' &&
                profileModel.restaurants!.first.settings!.aggregatorAutoBill ==
                    'Yes') {
              PrintDebugLogger.decision(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                result: 'PRINT_BILL',
                reason: 'Acknowledged + billStage=Acknowledged + autoBill=Yes',
                aggregatorAutoKot: _autoKot,
                aggregatorAutoBill: _autoBill,
                aggregatorAutoBillStage: _billStage,
                aggregatorAutoKotIdContainsEmp: _autoKotId,
              );
              callbackFunction('bill');
            } else {
              PrintDebugLogger.skip(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                reason: 'Acknowledged but no matching autoKot/autoBill setting',
                details: {'autoKot': _autoKot, 'autoBill': _autoBill, 'billStage': _billStage},
              );
            }
          } else if (callbackFunction != null &&
              foodStatus == 'Food Ready' &&
              profileModel.aggregatorAutoKotId!.contains(profileModel.empId) &&
              jsonData.orderDetailsOrder.fOrderStatus == 2) {
            if (profileModel
                        .restaurants!.first.settings!.aggregatorAutoBillStage ==
                    'Ready' &&
                profileModel.restaurants!.first.settings!.aggregatorAutoBill ==
                    'Yes') {
              PrintDebugLogger.decision(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                result: 'PRINT_BILL',
                reason: 'FoodReady + billStage=Ready + autoBill=Yes',
                aggregatorAutoKot: _autoKot,
                aggregatorAutoBill: _autoBill,
                aggregatorAutoBillStage: _billStage,
                aggregatorAutoKotIdContainsEmp: _autoKotId,
              );
              callbackFunction('bill');
            } else {
              PrintDebugLogger.skip(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                reason: 'FoodReady but billStage!=Ready or autoBill!=Yes',
                details: {'billStage': _billStage, 'autoBill': _autoBill},
              );
            }
          } else if (callbackFunction != null &&
              foodStatus == 'Cancelled' &&
              profileModel.aggregatorAutoKotId!.contains(profileModel.empId) &&
              jsonData.orderDetailsOrder.fOrderStatus == 3) {
            if (profileModel
                    .restaurants!.first.settings!.aggregatorAutoKot ==
                'Yes') {
              PrintDebugLogger.decision(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                result: 'PRINT_CANCEL_KOT',
                reason: 'Cancelled + fOrderStatus=3 + autoKot=Yes',
                aggregatorAutoKot: _autoKot,
                aggregatorAutoBill: _autoBill,
                aggregatorAutoKotIdContainsEmp: _autoKotId,
              );
              callbackFunction('cancel_kot');
            } else {
              PrintDebugLogger.skip(
                traceId: _traceAgg,
                orderId: orderId,
                flow: PrintFlowTag.aggregator,
                isAuto: true,
                reason: 'Cancelled but autoKot!=Yes',
                details: {'autoKot': _autoKot},
              );
            }
          } else {
            PrintDebugLogger.skip(
              traceId: _traceAgg,
              orderId: orderId,
              flow: PrintFlowTag.aggregator,
              isAuto: true,
              reason: 'Conditions not met: autoKotIdContainsEmp=$_autoKotId foodStatus=$foodStatus fOrderStatus=${jsonData.orderDetailsOrder.fOrderStatus}',
            );
          }
          // audioPlayer?.stop();
        }
      } else if (type == 'aggrigator-order') {
        if (orderIdFromSocket != orderId) {
          orderIdFromSocket = orderId!;
          order.add(jsonData);
          _updatedOrderIndex = order.indexOf(order.last);

          if (GetPlatform.isWindows &&
                  jsonData.orderDetailsOrder.fOrderStatus == 0
              //  &&
              // (!Get.find<AuthController>()
              //     .profileModel!
              //     .role!
              //     .contains('STATION'))
              )
            Get.find<KdsController>().showRichToast(
                'You have new swiggy-zommato order',
                jsonData.orderDetailsOrder.aggregatorOrderId,
                alertOrderId: '${jsonData.orderDetailsOrder.id}');
          update();
        }
      }
    _isLoading = false;

    update();
  }

  void setStoreOpenVal(String val,
      {bool isSwiggy = false, bool isLoading = false}) async {
    if (isSwiggy) {
      if (!isLoading) _isSwiggyStoreOpen = val;
      if (isLoading)
        await setAggregatorStoreValue('swiggy', val, isLoading: true);
    }
    if (!isSwiggy) {
      if (!isLoading) _isZommatoStoreOpen = val;
      if (isLoading)
        await setAggregatorStoreValue('zomato', val, isLoading: true);
    }

    update();
  }

  Future<void> setAggregatorStoreValue(String key, String val,
      {bool isLoading = false}) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);
    try {
      final response = await swiggyRepo.changeAggregatorStoreStatus({
        'platform': [key]
      });

      Get.find<LoadingController>().startLoading(false);
      if (response.statusCode == 200) {
        await Get.find<LoadingController>()
            .changeText(data: response.body.first['message']);
        if (key == 'zomato') {
          setStoreOpenVal(val, isSwiggy: false);
        }
        if (key == 'swiggy') {
          setStoreOpenVal(val, isSwiggy: true);
        }
        Future.delayed(Duration(milliseconds: 500), () {
          if (Get.isBottomSheetOpen ?? false) Get.back();
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  //Donwload report
  Future<void> exportAggregatorOrderReport(String date) async {
    isLoadingExport = true;
    try {
      // print(date);
      Map<String, dynamic> data = {
        "from": date,
        "to": date,
      };

      Response response = await swiggyRepo.exportAggrOrderReport(data);

      if (response.statusCode == 200) {
        log("------------: Export aggregator order report success");
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
      isLoadingExport = false;
    }
  }
}
