import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/buffet_order_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_cacel_reason_list_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/repository/buffet_repo.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../view/base/custom_snackbar.dart';

class BuffetController extends GetxController implements GetxService {
  final BuffetRepo buffetRepo;

  BuffetController({required this.buffetRepo});

  bool _isProcessing = false;
  bool _isLoading = false;

  BuffetOrderListResponse? _getOrderList;
  final List<Reasons> _cancelReasonList = [];
  Reasons? _selectedReason;

  bool get isProcessing => _isProcessing;
  bool get isLoading => _isLoading;
  BuffetOrderListResponse? get orderList => _getOrderList;
  List<Reasons> get cancelReasonList => _cancelReasonList;
  Reasons? get selectedReason => _selectedReason;

  void setProcessing(bool value) {
    _isProcessing = value;
    update();
  }

  void clearOrderList() {
    _getOrderList = null;
    update();
  }

  void setCancelReason(Reasons reason) {
    _selectedReason = reason;
    update();
  }

  /// ---------------- Socket Order Handling ----------------

  Future getOrderDetailFromSocket({
    required String type,
    required String orderId,
    String? foodStatus,
    dynamic socketJson,
  }) async {
    Response? response;
    if (type == 'update-food-status' || type == 'update-item-status' || type == 'update-priority-food-status')
      response = await buffetRepo.foodOrderStatusUpdateDetail(
          {"order_id": orderId, "item_id": foodStatus});

    if (type == 'new-order' ? true : response?.statusCode == 200) {
      ProfileModel profileModel = Get.find<AuthController>().profileModel!;
      BuffetOrderListResponse? jsonData;
      OrderDetails? foodJson;
      if (type == 'new-order')
        jsonData = BuffetOrderListResponse.fromJson(socketJson);
      if (type == 'update-food-status' || type == 'update-item-status' || type == 'update-priority-food-status')
        foodJson = OrderDetails.fromJson(response!.body['order_food']);
      if (jsonData != null) {
        if (type == 'new-order') {
          // _getOrderListResponse.orders.add(jsonData.orders.first);
          // if (orderIdFromSocket != orderId) {
          // orderIdFromSocket = orderId;
          List<OrderDetails> tempOrderDetails = [];
          List<OrderDetails> tempPriorityOrderDetails = [];
          if (profileModel.role!.contains('Buffet')) {
            if (jsonData.orderDetails!.isNotEmpty) {
              for (var i = 0; i < jsonData.orderDetails!.length; i++) {
                if (profileModel.stationRole!
                        .contains(jsonData.orderDetails![i].station) &&
                    jsonData.orderDetails![i].orderUpdateCount ==
                        jsonData.orderDetails![i].itemUpdateCount) {
                  tempOrderDetails.add(jsonData.orderDetails![i]);
                }
              }
            } else if (jsonData.priorityOrderDetails!.isNotEmpty) {
              for (var i = 0; i < jsonData.priorityOrderDetails!.length; i++) {
                if (profileModel.stationRole!
                        .contains(jsonData.priorityOrderDetails![i].station) &&
                    jsonData.priorityOrderDetails![i].orderUpdateCount ==
                        jsonData.priorityOrderDetails![i].itemUpdateCount) {
                  tempPriorityOrderDetails
                      .add(jsonData.priorityOrderDetails![i]);
                }
              }
            }

            _getOrderList!.orderDetails!.addAll(tempOrderDetails);
            _getOrderList!.priorityOrderDetails!
                .addAll(tempPriorityOrderDetails);
          } else {
            /////////////// new order
            List<OrderDetails> tempOrderDetails = [];
            List<OrderDetails> tempPriorityOrderDetails = [];
            if (jsonData.orderDetails!.isNotEmpty &&
                jsonData.orderDetails!.first.orderUpdateCount == 0) {
              _getOrderList!.orderDetails!.addAll(jsonData.orderDetails!);
            } else if (jsonData.orderDetails!.isNotEmpty) {
              for (var element in jsonData.orderDetails!) {
                if (element.orderUpdateCount == element.itemUpdateCount) {
                  tempOrderDetails.add(element);
                }
              }
              _getOrderList!.orderDetails!.addAll(tempOrderDetails);
            }
//
            if (jsonData.priorityOrderDetails!.isNotEmpty &&
                jsonData.priorityOrderDetails!.first.orderUpdateCount == 0) {
              _getOrderList!.priorityOrderDetails!
                  .addAll(jsonData.priorityOrderDetails!);
            } else if (jsonData.priorityOrderDetails!.isNotEmpty) {
              for (var element in jsonData.priorityOrderDetails!) {
                if (element.orderUpdateCount == element.itemUpdateCount) {
                  tempPriorityOrderDetails.add(element);
                }
              }
              _getOrderList!.priorityOrderDetails!
                  .addAll(tempPriorityOrderDetails);
            }
          }

          Get.find<RestaurantController>().update();
          // } else {
          //   print('Call multitime socket order id : $orderId');
          // }
        }
      } else if (foodJson != null) {
        if (type == 'update-priority-food-status') {
          if (profileModel.role!.contains('Buffet')) {
            if (profileModel.stationRole!.contains(foodJson.station)) {
              _getOrderList!.priorityOrderDetails!.add(foodJson);
            }
          } else {
            _getOrderList!.priorityOrderDetails!.add(foodJson);
          }
          for (var i = 0; i < _getOrderList!.orderDetails!.length; i++) {
            if (foodJson.orderId == _getOrderList!.orderDetails![i].orderId &&
                foodJson.id == _getOrderList!.orderDetails![i].id) {
              _getOrderList!.orderDetails!.removeAt(i);
              update();
              break; // Exit loop once the replacement is done
            }
          }
        } else {
          if (foodJson.priority == 'Yes') {
            for (var i = 0;
                i < _getOrderList!.priorityOrderDetails!.length;
                i++) {
              if (foodJson.orderId ==
                      _getOrderList!.priorityOrderDetails![i].orderId &&
                  foodJson.id == _getOrderList!.priorityOrderDetails![i].id) {
                _getOrderList!.priorityOrderDetails![i] = foodJson;
                update();
                break; // Exit loop once the replacement is done
              }
            }
          } else {
            for (var i = 0; i < _getOrderList!.orderDetails!.length; i++) {
              if (foodJson.orderId == _getOrderList!.orderDetails![i].orderId &&
                  foodJson.id == _getOrderList!.orderDetails![i].id) {
                _getOrderList!.orderDetails![i] = foodJson;
                update();
                break; // Exit loop once the replacement is done
              }
            }
          }
        }
      }
    } else {
      ApiChecker.checkApi(response!);
      return false;
    }
    _isLoading = false;

    update();
  }

  /// ---------------- Cancel Reasons ----------------
  Future<void> getCancelReason() async {
    final response = await buffetRepo.getCancelReasonList();
    if (response.statusCode == 200) {
      _cancelReasonList.clear();
      _cancelReasonList.add(
        Reasons(id: 0, reason: 'Select the reason'),
      );
      _selectedReason = _cancelReasonList.first;

      final model = CancelReasonListResponseModel.fromJson(response.body);
      _cancelReasonList.addAll(model.reasons ?? []);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  /// ---------------- Order List ----------------
  Future<void> getBuffetOrderList() async {
    _isLoading = true;
    update();

    final response =
        Get.find<AuthController>().profileModel!.role!.contains('Buffet')
            ? await buffetRepo.serverOrderList()
            : await buffetRepo.orderList();

    _isLoading = false;

    if (response.statusCode == 200) {
      _getOrderList = BuffetOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  /// ---------------- Order Actions ----------------
  Future<void> changeOrderStatus(
    Map<String, dynamic> jsonBody,
    void Function(bool success, String message) callback,
  ) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    final response = await buffetRepo.orderStatusUpdate(jsonBody);

    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      final message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> changeFoodOrderStatus(
    Map<String, dynamic> jsonBody,
    void Function(bool success, String message) callback,
  ) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    final response = await buffetRepo.foodOrderStatusUpdate(jsonBody);

    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      final message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> cancelFoodItem(
    Map<String, dynamic> jsonBody,
    void Function(bool success, String message) callback,
  ) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    final response = await buffetRepo.cancelFoodItem(jsonBody);

    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      final message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
