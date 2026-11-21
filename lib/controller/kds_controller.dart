import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/helper/print_debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_cacel_reason_list_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_cancel_order_list.dart';
import 'package:mygenie_restaurant/data/model/response/get_kds_order_total_food_item_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_manually_print_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart'
    as paid;
import 'package:mygenie_restaurant/data/model/response/get_paid_orders_response.dart'
    as paidList;
import 'package:mygenie_restaurant/data/model/response/get_paid_room_order_detail_respose_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_orders_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_station_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/repository/kds_repo.dart';
import 'package:mygenie_restaurant/helper/notification_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:win_toast/win_toast.dart';

import '../view/base/custom_snackbar.dart';
import '../view/screens/paid_order/view_paid_orders.dart';

class KdsController extends GetxController implements GetxService {
  final KdsRepo kdsRepo;
  KdsController({required this.kdsRepo});

  int _selectedMainMenu = 3;
  bool _isProcessing = false;
  int _selectedSubMenu = 0;
  int _updatedOrderIndex = 0;
  bool _isLoading = false;
  bool _isTableView = false;
  String orderIdFromSocket = '';
  DateTime? _lastOrderDateTime;
  // GetPosOrderListResponseModel? _getOrderListResponse;
  GetWaiterOrderListResponse? _getWaiterOrderListResponse;
  GetWaiterOrderListResponse? _getWaiterScheduleOrderListResponse;
  GetWaiterOrderListResponse? _getUnpaidOnlineOrderListResponse;
  GetStationOrderListResponse? _getStationOrderListResponse;
  // List<Orders> _stationOrderList = [];
  GetKDSTotalFoodItemResponseModel? _getKdsTotalOrderResponse;
  List<GetRoomPaidOrderDetailResponse> _getRoomPaidOrderList = [];
  List<Reasons> _cancelReasonList = [];

  SelectedWaiter? selectedWaiter;
  List<SelectedWaiter> waiterList = [];
  List<int> waiterListId = [];
  Reasons? _selectedReason;
  // Orders? _selectedSplitOrder;
  List<OrderList> _splitOrderList = [];
  // int? _selectedSplitOrderIndex;
  paidList.GetPaidOrdersResponse? _getPaidOrdersResponse;
  GetCancelOrderListResponse? _getCancelledOrdersResponse;
  OrderList? _selectedOrderForTableView;
  paidList.GetPaidOrdersResponse? _getTabOrdersResponse;
  GetRoomOrders? _getPaidRoomOrdersResponse;
  paid.GetPaidOrderDetailResponse? _paidOrderDetailResponse;
  paidList.GetPaidOrdersResponse? get getPaidOrders => _getPaidOrdersResponse;
  GetCancelOrderListResponse? get getCancelledOrders =>
      _getCancelledOrdersResponse;
  OrderList? get selectedOrderForTableView => _selectedOrderForTableView;
  paidList.GetPaidOrdersResponse? get getTabOrdersResponse =>
      _getTabOrdersResponse;
  GetRoomOrders? get getPaidRoomOrdersResponse => _getPaidRoomOrdersResponse;
  paid.GetPaidOrderDetailResponse? get paidOrderDetailResponse =>
      _paidOrderDetailResponse;
  paid.GetAllPrintRoomBillsResponse? _getAllPrintRoomBillsResponse;
  paid.GetAllPrintRoomBillsResponse? get getAllPrintRoomBillsResponse =>
      _getAllPrintRoomBillsResponse;
  int get selectedMainMenu => _selectedMainMenu;
  int get updatedOrderIndex => _updatedOrderIndex;
  int get selectedSubMenu => _selectedSubMenu;
  bool get isProcessing => _isProcessing;
  bool get isTableView => _isTableView;
  bool isSearchEnabled = false;
  List<GetRoomPaidOrderDetailResponse> get getRoomPaidOrderList =>
      _getRoomPaidOrderList;
  // List<Orders> get stationOrderList => _stationOrderList;
  DateTime? get lastOrderDateTime => _lastOrderDateTime;
  // int? get selectedSplitOrderIndex => _selectedSplitOrderIndex;
  // Orders? get selectedSplitOrder => _selectedSplitOrder;
  List<OrderList> get splitOrderList => _splitOrderList;

  Reasons? get selectedReason => _selectedReason;
  bool get isLoading => _isLoading;
  // GetPosOrderListResponseModel? get getOrderListResponse =>
  //     _getOrderListResponse;
  GetWaiterOrderListResponse? get getWaiterOrderListResponse =>
      _getWaiterOrderListResponse;
  GetWaiterOrderListResponse? get getWaiterScheduleOrderListResponse =>
      _getWaiterScheduleOrderListResponse;
  GetWaiterOrderListResponse? get getUnpaidOnlineOrderListResponse =>
      _getUnpaidOnlineOrderListResponse;
  GetStationOrderListResponse? get getStationOrderListResponse =>
      _getStationOrderListResponse;
  GetKDSTotalFoodItemResponseModel? get getKdsTotalOrderResponse =>
      _getKdsTotalOrderResponse;
  List<Reasons> get getCancelReasonList => _cancelReasonList;

  void setMainMenuIndex(int index) {
    _selectedMainMenu = index;
    update();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    update();
  }

  void setSubMenuIndex(int index) {
    _selectedSubMenu = index;
    update();
  }

  void changeOrderTableView(bool value) {
    _isTableView = value;
    update();
  }

  void updateDateTime(DateTime date) {
    _lastOrderDateTime = date;
    update();
  }

  void updateSelectedOrder(OrderList? order) {
    _selectedOrderForTableView = order;
    update();
  }

  void selectSplitOrder(OrderList order) {
    List<OrderDetails> foodList = [];
    for (var e in order.orderDetails!) {
      if (e.splitQuantity! > 0) {
        for (var i = 0; i < e.splitQuantity!; i++) {
          foodList.add(OrderDetails(
            quantity: 1,
            foodDetails: e.foodDetails,
            addOns: e.addOns,
            id: e.id,
            splitQuantity: 1,
            isSelected: false,
            isSplited: false,
            variation: e.variation,
            price: e.unitPrice,
            unitPrice: e.unitPrice,
            foodStatus: e.foodStatus,
          ));
        }
      }
    }
    if (_splitOrderList.isEmpty) {
      _splitOrderList.add(OrderList(
        restaurantOrderId: order.restaurantOrderId,
        id: order.id,
        parentOrderId: order.parentOrderId,
        tablePart: order.tablePart,
        deliveryAddress: order.deliveryAddress,
        employeeId: order.employeeId,
        fOrderStatus: order.fOrderStatus,
        orderAmount: order.orderAmount,
        orderDetails: foodList,
        orderType: order.orderType,
        userName: order.userName,
        isSplitTable: order.isSplitTable,
        isShowCheckbox: order.isShowCheckbox,
        splitCount: order.splitCount,
        restaurantTable: order.restaurantTable,
        orderNote: order.orderNote,
        user: order.user,
        userId: order.userId,
        vendorEmployee: order.vendorEmployee,
        waiterId: order.waiterId,
        tableId: order.tableId,
        createdAt: order.createdAt,
      ));
    }

    showCheckboxInOrder(isShow: true);
    update();
  }

  void clearOrderList() {
    _getWaiterOrderListResponse = null;
    update();
  }

  void setCancelReason(Reasons reason) {
    _selectedReason = reason;
    update();
  }

  Future<void> getPOSOrderList() async {
    Response response;
    response = await kdsRepo.getOrderList();
    if (response.statusCode == 200) {
      _getStationOrderListResponse =
          GetStationOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;

    update();
  }

  Future getPaidRoomOrder(String orderId) async {
    _getRoomPaidOrderList = [];
    _isLoading = true;
    update();
    Response response =
        await kdsRepo.getPaidRoomorderList({'order_id': orderId});
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      _getRoomPaidOrderList = [];
      response.body.forEach((table) => _getRoomPaidOrderList
          .add(GetRoomPaidOrderDetailResponse.fromJson(table)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getPaidOrderDetail(String orderId,
      {bool isShowLoader = true}) async {
    Response response;
    if (isShowLoader) {
      _isLoading = true;
      update();
    } else {
      showToast('Please wait..');
      Get.find<LoadingController>().startLoading(true);
    }
    response = await kdsRepo.getPaidOrderDetail(orderId);
    if (response.statusCode == 200) {
      final tempResponse =
          paid.GetPaidOrderDetailResponse.fromJson(response.body);

      _paidOrderDetailResponse =
          paid.GetPaidOrderDetailResponse.fromJson(response.body);
      final List<paid.OrderDetailsFood> foodOrder =
          List<paid.OrderDetailsFood>.from(
              tempResponse.orders?.orderDetailsFood ?? []);
      final List<paid.OrderDetailsFood> mergeFood = mergeFoodItems(foodOrder);
      final List<paid.OrderDetailsFood> mergeFoodWithDate =
          mergeFoodItems(foodOrder, type: 'date');
      _paidOrderDetailResponse!.orders!.mergeFoodList = mergeFood;
      _paidOrderDetailResponse!.orders!.mergeFoodListWithDate =
          mergeFoodWithDate;
    } else {
      Get.find<LoadingController>().startLoading(false);
      ApiChecker.checkApi(response);
    }
    if (isShowLoader) {
      _isLoading = false;
      update();
    }
  }

  List<paid.OrderDetailsFood> mergeFoodItems(
      List<paid.OrderDetailsFood> foodItems,
      {String? type}) {
    final Map<String, paid.OrderDetailsFood> mergedItems = {};

    for (final item in foodItems) {
      String variationText = '';
      String createDate = DateFormat('dd-MMM-yyyy').format(
        DateTime.parse(item.createdAt ?? DateTime.now().toIso8601String()),
      );
      if (item.variation != null && item.variation!.isNotEmpty) {
        for (int j = 0; j < item.variation!.length; j++) {
          variationText +=
              '${variationText.isNotEmpty ? ', ' : ''}${item.variation![j].name ?? ''} (';

          if (item.variation![j].values != null) {
            final labelList = <String>[];
            for (final element in item.variation![j].values!) {
              labelList.add(element.label ?? '');
            }
            variationText +=
                '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
          }

          variationText += ')';
        }
      }

      String addons = '';
      if (item.addOns != null) {
        for (var i = 0; i < item.addOns!.length; i++) {
          addons +=
              '${item.addOns![i].name ?? ''} (${item.addOns![i].quantity ?? ''})';
        }
      }
      if (item.foodStatus == 3) {
        mergedItems['${item.foodId}, $variationText, $addons, ${item.id}'] =
            item;
      } else {
        if (item.foodDetails != null && item.foodDetails!.price != 1) {
          final key = type == 'date'
              ? '${item.foodId}, $variationText, $addons,${item.isComplementary}, $createDate'
              : '${item.foodId}, $variationText, $addons,${item.isComplementary}';
          if (mergedItems.containsKey(key)) {
            mergedItems[key] = paid.OrderDetailsFood(
              addOns: item.addOns,
              createdAt: item.createdAt,
              foodDetails: item.foodDetails,
              foodId: item.foodId,
              discountType: item.discountType,
              foodStatus: item.foodStatus,
              gstTaxAmount: item.gstTaxAmount,
              id: item.id,
              orderId: item.orderId,
              price: item.price,
              totalAddOnPrice: item.totalAddOnPrice,
              unitPrice: item.unitPrice,
              variation: item.variation,
              itemType: item.itemType,
              quantity:
                  (item.quantity ?? 0) + (mergedItems[key]?.quantity ?? 0),
            );
          } else {
            mergedItems[key] = item;
          }
        } else {
          mergedItems['${item.foodId}, $variationText, $addons, ${item.id}'] =
              item;
        }
      }
    }

    return mergedItems.values.toList();
  }

  clearPaidOrderDetail() {
    _paidOrderDetailResponse = null;
    update();
  }

  Future getOrderDetailFromSocket({
    Socket? socket,
    String? type,
    String? orderId,
    String? foodStatus,
    dynamic socketJson,
    Function? callbackFunction,
  }) async {
    Response? response;
    GetWaiterOrderListResponse jsonData;
    // if (type != 'new-order') {
    //   response = await kdsRepo.getOrderDetailFromSocket('$orderId');
    // }
    if (socketJson == null) {
      response = await kdsRepo.getOrderDetailFromSocket('$orderId');

      if (response.statusCode != 200) {
        ApiChecker.checkApi(
            response); // consistent error handling like rest of your code
        return false;
      }

      jsonData = GetWaiterOrderListResponse.fromJson(
          Map<String, dynamic>.from(response.body));
    } else {
      jsonData = GetWaiterOrderListResponse.fromJson(socketJson);
    }
    // GetWaiterOrderListResponse jsonData = GetWaiterOrderListResponse.fromJson(
    //     type == 'new-order' ? socketJson : response!.body);
    // if (type == 'new-order' ? true : response!.statusCode == 200) {
    ProfileModel? profileModelNullable =
        Get.find<AuthController>().profileModel;
    if (profileModelNullable == null) {
      return false;
    }
    final ProfileModel profileModel = profileModelNullable;
    if (jsonData.orders != null && jsonData.orders!.isNotEmpty) {
      if (type == 'delivery-assign-order' ||
          type == 'update-order' ||
          type == 'update-food-status' ||
          type == 'update-item-status' ||
          type == 'scan-new-order' ||
          type == 'update-order-source' ||
          type == 'update-order-target' ||
          type == 'split-order' ||
          type == 'update-order-paid' ||
          type == 'update-order-status') {
        int? index;
        if (_getWaiterOrderListResponse?.orders != null) {
          for (int i = 0;
              i < _getWaiterOrderListResponse!.orders!.length;
              i++) {
            if (_getWaiterOrderListResponse!.orders![i].id ==
                jsonData.orders![0].id) {
              index = i;
            }
          }
        }

        if (type == 'update-order-status' &&
            index != null &&
            _getWaiterOrderListResponse?.orders?[index].fOrderStatus == 7 &&
            (jsonData.orders?.first.fOrderStatus == 1 ||
                jsonData.orders?.first.fOrderStatus == 2 ||
                jsonData.orders?.first.fOrderStatus == 5 ||
                jsonData.orders?.first.fOrderStatus == 3)) {
          stopOrderAlert(_getWaiterOrderListResponse?.orders?[index].id);
        }

        if (type == 'scan-new-order' &&
            ((jsonData.orders?.first.waiterId == profileModel.empId) ||
                (Get.find<AuthController>()
                        .profileModel
                        ?.role
                        ?.contains('Manager') ??
                    false)) &&
            jsonData.orders!.first.fOrderStatus! != 8) {
          if (orderIdFromSocket != orderId) {
            orderIdFromSocket = orderId!;
            _getWaiterOrderListResponse?.orders?.add(jsonData.orders!.first);
            if (GetPlatform.isWindows) {
              showRichToast(
                  'Confirm this order',
                  jsonData.orders!.first.restaurantOrderId,
                  alertOrderId: jsonData.orders!.first.id);
            }
            final shouldAutoPrint =
                ((profileModel.restaurants!.first.printingOption == 'Fixed' &&
                            profileModel.defaultUser == 'Yes') ||
                        profileModel.restaurants!.first.printingOption ==
                            'Waiter') &&
                    jsonData.orders!.first.isPrintKot == 'Yes';

            final _traceKot = PrintDebugController.generateTraceId();
            PrintDebugLogger.decision(
              traceId: _traceKot,
              orderId: orderId,
              flow: PrintFlowTag.normalPos,
              isAuto: true,
              result: shouldAutoPrint ? 'PRINT_KOT' : 'SKIP',
              reason: 'scan-new-order: shouldAutoPrint=$shouldAutoPrint',
              printingOption: profileModel.restaurants!.first.printingOption,
              defaultUser: profileModel.defaultUser,
              empId: profileModel.empId?.toString(),
              waiterId: jsonData.orders!.first.waiterId?.toString(),
              isPrintKot: jsonData.orders!.first.isPrintKot,
            );

            if (shouldAutoPrint) {
              _updatedOrderIndex = _getWaiterOrderListResponse?.orders
                      ?.indexOf(jsonData.orders!.first) ??
                  0;
              callbackFunction?.call(jsonData.orders!.first);
              update();
              return true;
            }
          }
        }

        if (type == 'update-order-status' &&
            (_getWaiterOrderListResponse?.orders?[index!].fOrderStatus == 7 &&
                (jsonData.orders?.first.fOrderStatus == 1 ||
                    jsonData.orders?.first.fOrderStatus == 2 ||
                    jsonData.orders?.first.fOrderStatus == 5)) &&
            ((jsonData.orders?.first.waiterId == profileModel.empId) ||
                (Get.find<AuthController>()
                        .profileModel
                        ?.role
                        ?.contains('Manager') ??
                    false))) {
          if (_getWaiterOrderListResponse?.orders?[index!].fOrderStatus == 7 &&
              ((jsonData.orders?.first.fOrderStatus == 1) ||
                  (jsonData.orders?.first.fOrderStatus == 2) ||
                  (jsonData.orders?.first.fOrderStatus == 5)) &&
              (jsonData.orders?.first.employeeId == profileModel.empId)) {
            _updatedOrderIndex = index!;
            _getWaiterOrderListResponse?.orders?[index] =
                jsonData.orders!.first;
            // audioPlayer?.stop();

            update();
            return true;
          }
        } else if (type == 'update-order-status' &&
            _getWaiterOrderListResponse?.orders?[index!].fOrderStatus != 7 &&
            (profileModel.restaurants!.first.printingOption == 'Waiter' ||
                (profileModel.restaurants!.first.printingOption == 'Fixed' &&
                    profileModel.defaultUser == 'Yes')) &&
            profileModel.restaurants!.first.printKot == 'Yes') {
          _updatedOrderIndex = index!;
          _getWaiterOrderListResponse?.orders?[index] = jsonData.orders!.first;
          List<OrderDetails> cancelFood = [];
          if (jsonData.orders?.first.fOrderStatus != 3)
            for (var food in jsonData.orders?.first.orderDetails ?? []) {
              if (food.cancelBy != '' &&
                  ((food.cancelBy ==
                              Get.find<AuthController>()
                                  .profileModel!
                                  .empId
                                  .toString() &&
                          Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .printingOption ==
                              'Waiter') ||
                      (Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .printingOption ==
                              'Fixed' &&
                          Get.find<AuthController>()
                                  .profileModel
                                  ?.defaultUser ==
                              'Yes')) &&
                  food.cancelAt == jsonData.orders?.first.updatedAt) {
                cancelFood.add(food);
                break;
              }
            }
          // audioPlayer?.stop();

          update();
          if (jsonData.orders?.first.fOrderStatus == 3 || cancelFood.isNotEmpty)
            return true;
        } else if (type == 'update-order-status' &&
            (jsonData.orders?.first.fOrderStatus != null &&
                jsonData.orders!.first.fOrderStatus! < 2) &&
            ((jsonData.orders?.first.waiterId == profileModel.empId) ||
                (Get.find<AuthController>()
                        .profileModel
                        ?.role
                        ?.contains('Manager') ??
                    false))) {
          if (_getWaiterOrderListResponse?.orders?[index!].fOrderStatus == 7 &&
              ((jsonData.orders?.first.fOrderStatus == 1) ||
                  (jsonData.orders?.first.fOrderStatus == 2) ||
                  (jsonData.orders?.first.fOrderStatus == 5)) &&
              (jsonData.orders?.first.employeeId == profileModel.empId)) {
            _updatedOrderIndex = index!;
            _getWaiterOrderListResponse?.orders?[index] =
                jsonData.orders!.first;
            // audioPlayer?.stop();

            update();
            return true;
          }
        }
        //           if (type == 'update-food-status' &&
        //     ((jsonData.orders?.first.waiterId == profileModel.empId) ||
        //         (Get.find<AuthController>()
        //                 .profileModel
        //                 ?.role
        //                 ?.contains('Manager') ??
        //             false))) {
        //   // No-op
        // }
        if (type != 'scan-new-order' && type != 'delivery-assign-order') {
          if (index != null) {
            _getWaiterOrderListResponse?.orders?[index] =
                jsonData.orders!.first;
            // audioPlayer?.stop();
            if ((jsonData.orders!.first.fOrderStatus == 6 ||
                    jsonData.orders!.first.fOrderStatus == 3) &&
                jsonData.orders!.first.restaurantTable != null &&
                jsonData.orders!.first.restaurantTable != {}) {
              await Get.find<TableController>().setValueOfTableFromSocket(
                  tableId:
                      jsonData.orders!.first.restaurantTable?.id.toString() ??
                          '',
                  value: 'No');
            }
            if (Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('table_view'))
              Get.find<TableController>()
                  .updateTableViewData(jsonData.orders!.first);
          }
          if (type == 'update-order' && GetPlatform.isWindows) {
            showRichToast(
                'Order is edited', jsonData.orders!.first.restaurantOrderId);
          }
          if (((jsonData.orders?.first.employeeId == profileModel.empId) ||
                  ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .printingOption ??
                          '') ==
                      'Fixed')) &&
              type == 'update-order') {
            _updatedOrderIndex = index ?? 0;

            update();
            return true;
          }
        } else if (type == 'delivery-assign-order' &&
            (Get.find<AuthController>()
                    .profileModel
                    ?.role
                    ?.contains('delivery_man') ??
                false)) {
          if (index == null && foodStatus == profileModel.empId.toString()) {
            _getWaiterOrderListResponse?.orders?.add(jsonData.orders!.first);
            // showRichToast('You have new order assi');

            _updatedOrderIndex = _getWaiterOrderListResponse?.orders?.indexOf(
                    _getWaiterOrderListResponse?.orders?.last ??
                        jsonData.orders!.first) ??
                0;
          } else {
            if (foodStatus == profileModel.empId.toString() &&
                (jsonData.orders?.first.deliveryManId != null)) {
              if (index != null) {
                _getWaiterOrderListResponse?.orders?[index] =
                    jsonData.orders!.first;
              }
            } else {
              if (index != null) {
                _getWaiterOrderListResponse?.orders?.removeAt(index);
              }
            }
          }
        }

        Get.find<RestaurantController>().update();
      } else if (type == 'new-order') {
        if (orderIdFromSocket != orderId) {
          orderIdFromSocket = orderId!;

          if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('table_view'))
            Get.find<TableController>()
                .updateTableViewData(jsonData.orders!.first, isAdd: true);

          if (jsonData.orders!.first.waiterId == profileModel.empId ||
              profileModel.role!.contains('Manager')) {
            _getWaiterOrderListResponse!.orders!.add(jsonData.orders!.first);
            _updatedOrderIndex = _getWaiterOrderListResponse!.orders!
                .indexOf(_getWaiterOrderListResponse!.orders!.last);
            if (GetPlatform.isWindows) {
              showRichToast('You have new order',
                  jsonData.orders!.first.restaurantOrderId);
            }

            if (jsonData.orders!.first.restaurantTable != null &&
                jsonData.orders!.first.restaurantTable != {}) {
              await Get.find<TableController>().setValueOfTableFromSocket(
                  tableId:
                      jsonData.orders!.first.restaurantTable?.id.toString() ??
                          '',
                  value: 'Yes');
            }
            Get.find<RestaurantController>().update();
          }
          if (jsonData.orders!.first.waiterId == profileModel.empId ||
              profileModel.restaurants!.first.printingOption == 'Fixed') {
            final _shouldKot =
                (profileModel.restaurants!.first.printingOption == 'Fixed'
                        ? profileModel.defaultUser == 'Yes'
                        : profileModel.restaurants!.first.printingOption ==
                            'Waiter') &&
                    jsonData.orders!.first.isPrintKot == 'Yes';
            final _traceNew = PrintDebugController.generateTraceId();
            PrintDebugLogger.decision(
              traceId: _traceNew,
              orderId: orderId,
              flow: PrintFlowTag.normalPos,
              isAuto: true,
              result: _shouldKot
                  ? 'PRINT_KOT'
                  : 'SKIP (isPrintKot!=Yes or role mismatch)',
              reason:
                  'new-order: waiterMatch=${jsonData.orders!.first.waiterId == profileModel.empId} printingOption=${profileModel.restaurants!.first.printingOption}',
              printingOption: profileModel.restaurants!.first.printingOption,
              defaultUser: profileModel.defaultUser,
              empId: profileModel.empId?.toString(),
              waiterId: jsonData.orders!.first.waiterId?.toString(),
              isPrintKot: jsonData.orders!.first.isPrintKot,
            );
            callbackFunction?.call(_shouldKot ? jsonData.orders!.first : null);
            update();
            return true;
          }
        } else {
          print('Call multiTime socket order id : $orderId');
        }
      }
    }

    // } else {
    //   ApiChecker.checkApi(response);
    //   return false;
    // }
    _isLoading = false;

    update();
  }

  Future<OrderList?> getOrderDetailFromSocketForKot({String? orderId}) async {
    Response? response;
    OrderList? order;
    response = await kdsRepo.getOrderDetailFromSocket('$orderId');
    GetWaiterOrderListResponse jsonData =
        GetWaiterOrderListResponse.fromJson(response.body);
    if (response.statusCode == 200) {
      if (jsonData.orders != null && jsonData.orders!.isNotEmpty) {
        if (_getWaiterOrderListResponse?.orders != null) {
          for (int i = 0;
              i < _getWaiterOrderListResponse!.orders!.length;
              i++) {
            if (_getWaiterOrderListResponse!.orders![i].id ==
                jsonData.orders![0].id) {
              _updatedOrderIndex = i;

              break;
            }
          }
          order = await jsonData.orders!.first;
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
    return order;
  }

  Future<Bill?> getOrderDetailFromSocketForBill({String? orderId}) async {
    Response? response;
    Bill? order;
    response = await kdsRepo.getOrderDetailFromManualBillPrint('$orderId');
    GetManuallyPrintDetailResponse jsonData =
        GetManuallyPrintDetailResponse.fromJson(response.body);
    if (response.statusCode == 200) {
      if (jsonData.bill != null && jsonData.bill!.isNotEmpty) {
        order = jsonData.bill!.first;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
    return order;
  }

  orderEngageFromSocket({
    required String orderId,
    required String status,
  }) {
    List<OrderList> orderList = _getWaiterOrderListResponse?.orders ?? [];
    final index = orderList.indexWhere(
      (order) => order.id.toString() == orderId,
    );

    if (index != -1) {
      orderList[index].isEngage = status;

      // 🔥 Only update that specific item
      update();
    }
  }

  Future getStationOrderDetailFromSocket({
    Socket? socket,
    String? type,
    String? orderId,
    String? foodStatus,
    Function? callBackFunction,
  }) async {
    Response response =
        await kdsRepo.getStationOrderDetailFromSocket('$orderId');
    GetStationOrderListResponse jsonData =
        GetStationOrderListResponse.fromJson(response.body);
    if (response.statusCode == 200) {
      ProfileModel? profileModel = Get.find<AuthController>().profileModel;
      if (profileModel == null) return false;
      if (jsonData.orders != null && jsonData.orders!.isNotEmpty) {
        if (type == 'update-order' ||
            type == 'update-food-status' ||
            type == 'update-item-status' ||
            type == 'scan-new-order' ||
            type == 'update-order-status') {
          int index = 0;
          if (_getStationOrderListResponse?.orders != null) {
            for (int i = 0;
                i < (_getStationOrderListResponse?.orders?.length ?? 0);
                i++) {
              if ((_getStationOrderListResponse
                          ?.orders?[i].orderDetailsOrder?.id ??
                      '') ==
                  (jsonData.orders?[0].orderDetailsOrder?.id ?? '')) {
                index = i;
              }
            }
          }

          int oldOrderStatus = _getStationOrderListResponse
                      ?.orders?[index].orderDetailsOrder?.stationOrderStatus?[
                  '${profileModel.roleName?.toUpperCase()}'] ??
              0;

          List<OrderDetailsFood> foodItem = [];
          List<OrderDetailsFood> readyItem = [];

          if (jsonData.orders?.first.orderDetailsFood != null) {
            for (var element in jsonData.orders!.first.orderDetailsFood!) {
              if ((element.station?.toUpperCase() ?? '') ==
                  '${profileModel.roleName?.toUpperCase()}') {
                foodItem.add(element);
                // Removed unused newFoodItem variable
                if (element.foodStatus == 2) {
                  readyItem.add(element);
                }
              }
            }
          }
          if (jsonData.orders?.first.orderDetailsOrder?.fOrderStatus != 3) {
            jsonData.orders?.first.readyDetails = readyItem;
          }
          if (jsonData.orders?.first.orderDetailsOrder?.fOrderStatus == 3) {
            if (_getStationOrderListResponse
                    ?.orders?[index].orderDetailsOrder !=
                null) {
              _getStationOrderListResponse!
                  .orders![index].orderDetailsOrder!.fOrderStatus = 3;
            }
          }
          if (foodItem.isNotEmpty) {
            if (jsonData.orders?.first != null) {
              jsonData.orders!.first.orderDetailsFood = foodItem;
            }
            int bStatus = _getStationOrderListResponse
                        ?.orders?[index].orderDetailsOrder?.stationOrderStatus?[
                    '${profileModel.roleName?.toUpperCase()}'] ??
                0;
            int newBStatus =
                jsonData.orders?.first.orderDetailsOrder?.stationOrderStatus?[
                        '${profileModel.roleName?.toUpperCase()}'] ??
                    0;
            if (bStatus == 1 || bStatus == 2 || bStatus == 5) {
              if (newBStatus == 0 &&
                  ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants?[0]
                              .showOrderStatus ??
                          0) ==
                      0)) {
                _getStationOrderListResponse?.statusCounts?.newOrder =
                    (_getStationOrderListResponse?.statusCounts?.newOrder ??
                            0) +
                        1;
              }

              if (bStatus == 1) {
                if (newBStatus == 0 || newBStatus == 2 || newBStatus == 5) {
                  if ((_getStationOrderListResponse?.statusCounts?.cooking ??
                          0) >
                      0) {
                    _getStationOrderListResponse?.statusCounts?.cooking =
                        (_getStationOrderListResponse?.statusCounts?.cooking ??
                                0) -
                            1;
                  }
                }
              } else if (bStatus == 2 || bStatus == 5) {
                if (newBStatus == 1) {
                  _getStationOrderListResponse?.statusCounts?.cooking =
                      (_getStationOrderListResponse?.statusCounts?.cooking ??
                              0) +
                          1;
                }
              }
            } else if (bStatus == 0 || bStatus == 2 || bStatus == 5) {
              if (newBStatus == 1) {
                _getStationOrderListResponse?.statusCounts?.cooking =
                    (_getStationOrderListResponse?.statusCounts?.cooking ?? 0) +
                        1;
                if (((profileModel.restaurants?[0].showOrderStatus ?? 0) ==
                        0) &&
                    bStatus == 0) {
                  if ((_getStationOrderListResponse?.statusCounts?.newOrder ??
                          0) >
                      0) {
                    _getStationOrderListResponse?.statusCounts?.newOrder =
                        (_getStationOrderListResponse?.statusCounts?.newOrder ??
                                0) -
                            1;
                  }
                }
              }
            }
            if (_getStationOrderListResponse?.orders != null &&
                jsonData.orders?.first != null) {
              _getStationOrderListResponse!.orders![index] =
                  jsonData.orders!.first;
            }
          }
          if ((jsonData.orders?.first.orderDetailsOrder?.stationOrderStatus?[
                      '${profileModel.roleName?.toUpperCase()}'] ??
                  0) <=
              5) {
            await getTotalKdsOrder();
          }
          int newBStatus =
              jsonData.orders?.first.orderDetailsOrder?.stationOrderStatus?[
                      '${profileModel.roleName?.toUpperCase()}'] ??
                  0;

          if (oldOrderStatus == 7 &&
              (newBStatus == 1 || newBStatus == 2 || newBStatus == 5)) {
            _updatedOrderIndex = index;
            return true;
          }
          if (type == 'update-order') {
            _updatedOrderIndex = index;
            return true;
          }
          if (type == 'update-order-status') {
            final bool isOrderCancel =
                jsonData.orders?.first.orderDetailsOrder?.fOrderStatus == 3;
            final bool hasItemCancel =
                foodItem.any((e) => e.foodStatus == 3);
            if (isOrderCancel || hasItemCancel) {
              _updatedOrderIndex = index;
              return true;
            }
          }
        } else if (type == 'new-order') {
          if (orderIdFromSocket != orderId) {
            orderIdFromSocket = orderId!;
            List<OrderDetailsFood> foodItem = [];
            if (jsonData.orders?.first.orderDetailsFood != null) {
              for (var element in jsonData.orders!.first.orderDetailsFood!) {
                if ((element.station?.toUpperCase() ?? '') ==
                    '${profileModel.roleName?.toUpperCase()}') {
                  foodItem.add(element);
                }
              }
            }

            if (jsonData.orders?.first != null) {
              jsonData.orders!.first.orderDetailsFood = foodItem;
              jsonData.orders!.first.readyDetails =
                  (jsonData.orders!.first.readyDetails ?? [])
                      .where((element) =>
                          (element.station?.toUpperCase() ?? '') ==
                          '${profileModel.roleName?.toUpperCase()}')
                      .toList();
            }
            if ((jsonData.orders?.first.orderDetailsOrder?.stationOrderStatus?[
                        '${profileModel.roleName?.toUpperCase()}'] ??
                    0) ==
                0) {
              if (foodItem.isNotEmpty) {
                _getStationOrderListResponse?.statusCounts?.newOrder =
                    (_getStationOrderListResponse?.statusCounts?.newOrder ??
                            0) +
                        1;
              }
            } else if ((jsonData.orders?.first.orderDetailsOrder
                            ?.stationOrderStatus?[
                        '${profileModel.roleName?.toUpperCase()}'] ??
                    0) ==
                1) {
              if (foodItem.isNotEmpty) {
                _getStationOrderListResponse?.statusCounts?.cooking =
                    (_getStationOrderListResponse?.statusCounts?.cooking ?? 0) +
                        1;
              }
            }
            if (foodItem.isNotEmpty) {
              _getStationOrderListResponse?.orders?.add(jsonData.orders!.first);
              _updatedOrderIndex = _getStationOrderListResponse?.orders
                      ?.lastIndexOf(jsonData.orders!.first) ??
                  0;
              callBackFunction?.call((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .printingOption ==
                          'Station' &&
                      (jsonData.orders?.first.orderDetailsOrder?.isPrintKot ??
                              '') ==
                          'Yes')
                  ? jsonData.orders?.first
                  : null);
              await getTotalKdsOrder();
              return true;
            }
          } else {
            print('Call multitime socket order id : $orderId');
          }
        }
      }
    } else {
      ApiChecker.checkApi(response);
      return false;
    }
    _isLoading = false;
    update();
  }

  updateOrderIndex(int index) {
    _updatedOrderIndex = index;
  }

  Future<Response> getCancelReason() async {
    Response response = await kdsRepo.getCancelReasonList();
    if (response.statusCode == 200) {
      _cancelReasonList = [];
      _cancelReasonList.add(Reasons(id: 0, reason: 'Select the reason'));
      _selectedReason = _cancelReasonList.first;
      CancelReasonListResponseModel responseModel =
          CancelReasonListResponseModel.fromJson(response.body);
      responseModel.reasons!.forEach((reason) => _cancelReasonList.add(reason));
    } else {
      ApiChecker.checkApi(response);
    }

    update();
    return response;
  }

  Future<void> getWaiterPOSOrderList() async {
    Response response = await kdsRepo.getWaiterOrderList();
    _isLoading = false;
    if (response.statusCode == 200) {
      _getWaiterOrderListResponse =
          GetWaiterOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getWaiterScheduleOrderList() async {
    _getWaiterScheduleOrderListResponse = null;
    Response response = await kdsRepo.getWaiterScheduleOrderList();
    _isLoading = false;
    if (response.statusCode == 200) {
      _getWaiterScheduleOrderListResponse =
          GetWaiterOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getOnlineUnpaidOrders() async {
    _isLoading = true;
    update();
    _getUnpaidOnlineOrderListResponse = null;
    Response response = await kdsRepo.getOnlineUnpaidOrders();
    _isLoading = false;
    if (response.statusCode == 200) {
      _getUnpaidOnlineOrderListResponse =
          GetWaiterOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getPaidOrderList(String date) async {
    _getPaidOrdersResponse = null;
    selectedWaiter = null;
    waiterListId = [];
    waiterList = [];
    Response response = await kdsRepo.getPaidOrderList(date);
    _isLoading = false;
    if (response.statusCode == 200) {
      _getPaidOrdersResponse =
          paidList.GetPaidOrdersResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    waiterList.add(SelectedWaiter(id: 0, name: 'All'));
    selectedWaiter = waiterList.first;
    if (_getPaidOrdersResponse!.orders.isNotEmpty) {
      for (var e in _getPaidOrdersResponse!.orders) {
        if (!waiterListId.contains(e.employeeId)) {
          waiterListId.add(e.employeeId!);
          waiterList
              .add(SelectedWaiter(id: e.employeeId!, name: e.waiterName!));
        }
      }
    }
    update();
  }

  Future<void> getPayLaterOrderList(String date) async {
    _getPaidOrdersResponse = null;
    selectedWaiter = null;
    waiterListId = [];
    waiterList = [];
    Response response = await kdsRepo.getPayLaterOrderList(date);
    _isLoading = false;
    if (response.statusCode == 200) {
      _getPaidOrdersResponse =
          paidList.GetPaidOrdersResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getCancelledOrderList(String date) async {
    _getCancelledOrdersResponse = null;
    Response response = await kdsRepo.getCancelledOrderList(date);
    _isLoading = false;
    if (response.statusCode == 200) {
      _getCancelledOrdersResponse =
          GetCancelOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getPaidRoomOrderList(String date) async {
    Response response = await kdsRepo.getRoomPaidOrderList(date);
    _isLoading = false;
    if (response.statusCode == 200) {
      _getPaidRoomOrdersResponse = GetRoomOrders.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getTabOrderList(String date) async {
    Response response = await kdsRepo.getTabOrderList(date);
    _isLoading = false;
    if (response.statusCode == 200) {
      _getTabOrdersResponse =
          paidList.GetPaidOrdersResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getTotalKdsOrder() async {
    Response response;
    // if (Get.find<AuthController>().profileModel.role.contains('BAR')) {
    //   response = await kdsRepo.getTotalBAROrderList();
    // } else {
    response = await kdsRepo.getTotalKDSOrderList();
    // }

    if (response.statusCode == 200) {
      _getKdsTotalOrderResponse =
          GetKDSTotalFoodItemResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> changeOrderStatus(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    if (jsonBody['order_status']?.toString().toLowerCase() == 'cancelled') {
      _attachCancelPrinterAgent(jsonBody, itemCancel: false);
    }

    Response response = await kdsRepo.orderStatusUpdate(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      await orderEngageFromSocket(
        orderId: '${jsonBody['order_id']}',
        status: 'No',
      );
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  /// Attaches printer_agent for cancel using stations from the order/item food.
  void _attachCancelPrinterAgent(Map<String, dynamic> jsonBody,
      {required bool itemCancel}) {
    List<String> stations = [];
    if (jsonBody['stations'] is List) {
      stations = (jsonBody['stations'] as List)
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      jsonBody.remove('stations');
    } else {
      stations = _resolveCancelStations(
        orderId: jsonBody['order_id']?.toString(),
        orderDetailId: jsonBody['item_id']?.toString(),
        itemCancel: itemCancel,
      );
    }
    jsonBody['printer_agent'] = buildPrinterAgentPayload(
      printAgents: Get.find<AuthController>().profileModel?.printAgent,
      cartStations: stations,
    );
  }

  List<String> _resolveCancelStations({
    required String? orderId,
    String? orderDetailId,
    required bool itemCancel,
  }) {
    if (orderId == null || orderId.isEmpty) return [];

    // Waiter / POS order list
    final waiterOrders = _getWaiterOrderListResponse?.orders;
    if (waiterOrders != null) {
      for (final order in waiterOrders) {
        if (order.id?.toString() != orderId) continue;
        final details = <OrderDetails>[
          ...?order.orderDetails,
          ...?order.serveOrderDetails,
        ];
        if (itemCancel) {
          for (final detail in details) {
            if (detail.id?.toString() == orderDetailId) {
              final station = detail.station?.trim();
              if (station != null && station.isNotEmpty) return [station];
            }
          }
        } else {
          return details
              .map((d) => d.station?.trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();
        }
      }
    }

    // KDS / station order list
    final stationOrders = _getStationOrderListResponse?.orders;
    if (stationOrders != null) {
      for (final order in stationOrders) {
        if (order.orderDetailsOrder?.id?.toString() != orderId) continue;
        final details = <OrderDetailsFood>[
          ...?order.orderDetailsFood,
          ...?order.readyDetails,
        ];
        if (itemCancel) {
          for (final detail in details) {
            if (detail.id?.toString() == orderDetailId) {
              final station = detail.station?.trim();
              if (station != null && station.isNotEmpty) return [station];
            }
          }
        } else {
          return details
              .map((d) => d.station?.trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();
        }
      }
    }

    return [];
  }

  Future<void> attendTable(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.attendTable(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> silentBuzzer() async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.silentBuzzerApi();
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> splitOrderFromApi(Map<String, dynamic> jsonBody) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.splitOrderFromApi(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      // String message = response.body['message'];
      // callback(true, message);
      await Get.find<LoadingController>()
          .changeText(data: response.body['message']);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    resetSplitBill();

    update();
  }

  Future<void> changePrepaidOrderStatus(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.prepaidOrderStatusUpdate(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> acceptOrderStatus(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);
    Response response = await kdsRepo.acceptOrder(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void startLoading() {
    _isLoading = true;
    update();
  }

  Future<void> changeFoodOrderStatus(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.foodOrderStatusUpdate(jsonBody);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      await orderEngageFromSocket(
        orderId: '${jsonBody['order_id']}',
        status: 'No',
      );
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);

      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> sendPrintDataFixedUserApi(Map<String, dynamic> jsonBody) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    jsonBody['printer_agent'] = buildPrinterAgentForTempStore(
      printAgents: Get.find<AuthController>().profileModel?.printAgent,
      printType: jsonBody['print_type']?.toString(),
      stationKot: jsonBody['station_kot']?.toString(),
    );

    Response response = await kdsRepo.sendPrintDataFixedUser(jsonBody);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);

      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> cancelFoodItem(Map<String, dynamic> jsonBody, Function callback,
      {bool isQty = false}) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    _attachCancelPrinterAgent(jsonBody, itemCancel: true);

    Response response = await kdsRepo.cancelFoodItem(jsonBody, isQty: isQty);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      await orderEngageFromSocket(
        orderId: '${jsonBody['order_id']}',
        status: 'No',
      );
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);

      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> setBuffetFoodPriority(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.setBuffetFoodPriority(jsonBody);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);

      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void splitOrder() {
    String orderId = '';
    List<Map<String, dynamic>> tempFoodList = [];
    _splitOrderList.first.isShowCheckbox = false;
    if (_splitOrderList.isNotEmpty) orderId = _splitOrderList.first.id ?? '';
    // _splitOrderList.first.splitCount =
    //     (_splitOrderList.first.splitCount ?? 0) + 1;
    for (var i = 0; i < _splitOrderList.first.orderDetails!.length; i++) {
      OrderDetails food = _splitOrderList.first.orderDetails![i];
      double? count = food.splitQuantity;
      for (var element in _splitOrderList.first.orderDetails!) {
        if (food.id == element.id && (element.isSelected ?? false)) {
          count = (count ?? 0) - 1;
        }
      }
      food.splitQuantity = count;
    }
    List<OrderDetails> foodList = [];

    for (var e in _splitOrderList.first.orderDetails!) {
      if (e.isSelected ?? false) {
        foodList.add(e);
        e.isSplited = true;
        tempFoodList.add({'id': e.id, 'qty': 1});
      }
      e.isSelected = false;
    }

    // OrderList order = _splitOrderList.first;

    // _splitOrderList.add(
    //   OrderList(
    //     restaurantOrderId: _splitOrderList.first.restaurantOrderId,
    //     vendorEmployee: _splitOrderList.first.vendorEmployee,
    //     user: _splitOrderList.first.user,
    //     restaurantTable: RestaurantTable(
    //       title: _splitOrderList.first.restaurantTable == null
    //           ? ''
    //           : _splitOrderList.first.restaurantTable!.title ?? '',
    //       rtype: '',
    //       tableNo:
    //           '${_splitOrderList.first.restaurantTable == null ? 'WC' : (_splitOrderList.first.restaurantTable!.tableNo == '' ? 'WC' : _splitOrderList.first.restaurantTable!.tableNo)} #${order.splitCount}',
    //     ),
    //     orderDetails: foodList,
    //     id: order.id,
    //     bOrderStatus: order.bOrderStatus,
    //     deliveryAddress: order.deliveryAddress,
    //     employeeId: order.employeeId,
    //     fOrderStatus: order.fOrderStatus,
    //     kOrderStatus: order.kOrderStatus,
    //     orderAmount: order.orderAmount,
    //     orderType: order.orderType,
    //     userName: order.userName,
    //     restaurantId: order.restaurantId,
    //     orderNote: order.orderNote,
    //     userId: order.userId,
    //     waiterId: order.waiterId,
    //     createdAt: order.createdAt,
    //     isSplitTable: true,
    //     isShowCheckbox: false,
    //     splitCount: 0,
    //     tableId: order.tableId,
    //   ),
    // );

    var jsonData = {
      'order_id': orderId,
      'split_count': _splitOrderList.first.tablePart! + 1,
      'splits': [tempFoodList]
    };
    splitOrderFromApi(jsonData);
    update();
  }

  void showCheckboxInOrder({bool isShow = false}) {
    _splitOrderList.first.isShowCheckbox = isShow;

    update();
  }

  void selectFoodItem({int? index, int? foodIndex}) {
    _splitOrderList.first.orderDetails![foodIndex!].isSelected =
        !_splitOrderList.first.orderDetails![foodIndex].isSelected;
    update();
  }

  void resetSplitBill() {
    if (_splitOrderList.isNotEmpty)
      _splitOrderList.first.isShowCheckbox = false;

    // _getOrderListResponse.orders[index].orderDetailsOrder.isSplitTable = false;
    // _getOrderListResponse.orders[index].orderDetailsOrder.isShowCheckbox =
    //     false;
    // _getOrderListResponse.orders[index].orderDetailsOrder.splitCount = 0;

    // for (var e in _getOrderListResponse.orders[index].orderDetailsFood) {
    //   e.isSplited = false;
    //   e.isSelected = false;
    //   e.splitQuantity = e.quantity;
    // }
    // _getOrderListResponse.orders = _getOrderListResponse.orders
    //     .where((x) => !x.orderDetailsOrder.id.contains(
    //         '${_getOrderListResponse.orders[index].orderDetailsOrder.id}#'))
    //     .toList();
    // _selectedSplitOrderIndex = null;
    // _selectedSplitOrder = null;
    _splitOrderList = [];
    update();
  }

  void clearSelectedFoodItem({int? index}) {
    for (var element in _splitOrderList.first.orderDetails!) {
      element.isSelected = false;
    }

    showCheckboxInOrder(isShow: false);
    // _selectedSplitOrder = null;
    // _selectedSplitOrderIndex = null;
    update();
  }

  Future mergeTable(Map<String, dynamic> body, Function callback,
      {String name = ''}) async {
    showToast('Please wait..', name: name);
    Get.find<LoadingController>().startLoading(true);
    Response response = await kdsRepo.mergeTableList(body);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      await Get.find<LoadingController>().changeText(data: name);
      await Get.find<LoadingController>().changeStatus(data: true);
      Future.delayed(Duration(milliseconds: 500), () {
        callback(true);
      });
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future transferFood(Map<String, dynamic> body, Function callback,
      {String name = ''}) async {
    showToast('Please wait..', name: name);
    Get.find<LoadingController>().startLoading(true);
    Response response = await kdsRepo.transferFood(body);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      await Get.find<LoadingController>().changeText(data: name);
      await Get.find<LoadingController>().changeStatus(data: true);
      callback(true);
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> changePaymentMethod(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await kdsRepo.changeOrderPaymentMethod(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> makeUnpaidOrder(
      int index, Map<String, dynamic> jsonBody, Function callback,
      {String type = 'paid'}) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = type == 'razorpay'
        ? await kdsRepo.makeRazorpayUnpaidOrder(jsonBody)
        : await kdsRepo.makeUnpaidOrder(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      if (type == 'tab') {
        getTabOrdersResponse!.orders.removeAt(index);
      } else if (type == 'room') {
        getPaidRoomOrdersResponse!.orders.removeAt(index);
      } else {
        getPaidOrders!.orders.removeAt(index);
      }
    } else if (response.statusCode == 400 && response.body['message'] != null) {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message'], error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> showRichToast(String? msg, String? orderId,
      {String? alertOrderId}) async {
    var xml = """
<?xml version="1.0" encoding="UTF-8"?>
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>MyGenie Restaurant</text>
      <text>$msg</text>
      <text>Order Id: $orderId</text>
    </binding>
  </visual>
</toast>
""";

    try {
      await WinToast.instance().showCustomToast(xml: xml);

      if (msg == 'You have new swiggy-zommato order' ||
          msg == 'Confirm this order') {
          if (msg == 'Confirm this order') {
          if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .settings
                  ?.confirmOrderTone ==
              'buzzer') {
            await startOrderAlert(alertOrderId ?? orderId);
          } else if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .settings
                  ?.confirmOrderTone ==
              'default') {
            await audioPlayer.setReleaseMode(ReleaseMode.release);
            await audioPlayer.play(AssetSource('sound/confirm_order.mp3'));
          }
        }
        if (msg == 'You have new swiggy-zommato order') {
          if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .settings
                  ?.aggregatorOrderTone ==
              'buzzer') {
            await startOrderAlert(alertOrderId ?? orderId);
          } else if (Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .settings
                  ?.aggregatorOrderTone ==
              'default') {
            await audioPlayer.setReleaseMode(ReleaseMode.release);
            await audioPlayer.play(AssetSource('sound/confirm_order.mp3'));
          }
        }
      }

      // await audioPlayer.resume();
    } catch (error, stacktrace) {
      print('showCustomToast error: $error, $stacktrace');
    }
  }
}

final AudioPlayer audioPlayer = AudioPlayer();

const String orderAlertSilentChannelId = 'order_alert_silent';

final Set<String> _pendingOrderAlerts = <String>{};

bool isLoopingOrderAlertSound(String? sound) {
  switch (sound) {
    // case 'new_order':
    // case 'confirm_order':
    case 'swiggy_new_order':
    case 'five_sec_buzzer':
    case 'ten_sec_buzzer':
    case 'forty_five_sec_buzzer':
      return true;
    default:
      return false;
  }
}

Future<void> startOrderAlert(String? orderId) async {
  final id = orderId?.trim() ?? '';
  if (id.isNotEmpty) {
    _pendingOrderAlerts.add(id);
  }
  if (GetPlatform.isAndroid) {
    await audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));
  }
  await audioPlayer.setReleaseMode(ReleaseMode.loop);
  await audioPlayer.play(AssetSource('sound/swiggy_five_sec_buzzer.mp3'));
}

Future<void> stopOrderAlert(String? orderId) async {
  final id = orderId?.trim() ?? '';
  if (id.isNotEmpty) {
    _pendingOrderAlerts.remove(id);
  }
  if (_pendingOrderAlerts.isEmpty) {
    await audioPlayer.stop();
  }
}
