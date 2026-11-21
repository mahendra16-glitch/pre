import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class KdsRepo {
  final ApiClient apiClient;
  KdsRepo({required this.apiClient});

  Future<Response> getOrderList() async {
    return await apiClient.postData(AppConstants.GET_POS_ORDER_LIST_URI, {
      'role_name': Get.find<AuthController>().profileModel!.roleName,
      'def_order_status': Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .defOrdStatus
    });
  }

  // Future<Response> getBarOrderList() async {
  //   return await apiClient.getData(AppConstants.GET_BAR_POS_ORDER_LIST_URI);
  // }

  Future<Response> getOrderDetailFromSocket(String orderId) async {
    return await apiClient.postData(
        AppConstants.GET_ORDER_FROM_SCOKET_URI, {'order_id': orderId});
  }

  Future<Response> getOrderDetailFromManualBillPrint(String orderId) async {
    return await apiClient.getData(
        '${AppConstants.GET_MANUAL_BILL_FROM_SCOKET_URI}?order_id=$orderId');
  }

  Future<Response> getStationOrderDetailFromSocket(String orderId) async {
    return await apiClient.postData(
        AppConstants.GET_STATION_ORDER_FROM_SCOKET_URI, {'order_id': orderId});
  }

  Future<Response> getPaidOrderDetail(String orderId) async {
    return await apiClient
        .getData('${AppConstants.PAID_ORDER_DETAILS_URI}$orderId');
  }

  Future<Response> getWaiterOrderList() async {
    return await apiClient.getData(AppConstants.WAITER_KDS_ORDER_LIST_URI +
        '?role_name=${Get.find<AuthController>().profileModel!.role!.contains('Manager') ? 'Manager' : 'Waiter'}');
  }

  Future<Response> getWaiterScheduleOrderList() async {
    return await apiClient.getData(AppConstants.WAITER_SCHEDULE_ORDER_LIST_URI +
        '?role_name=${Get.find<AuthController>().profileModel!.role!.contains('Manager') ? 'Manager' : 'Waiter'}');
  }

  Future<Response> getOnlineUnpaidOrders() async {
    return await apiClient.getData(AppConstants.ONLINE_UNPAID_ORDER_LIST_URI);
  }

  Future<Response> getPaidOrderList(String date) async {
    return date == ''
        ? await apiClient.getData(AppConstants.PAID_ORDER_LIST_URI)
        : await apiClient
            .getData('${AppConstants.PAID_ORDER_LIST_URI}?search_date=$date');
  }
  Future<Response> getPayLaterOrderList(String date) async {
    return date == ''
        ? await apiClient.getData(AppConstants.PAy_LATER_ORDER_LIST_URI)
        : await apiClient
            .getData('${AppConstants.PAy_LATER_ORDER_LIST_URI}?search_date=$date');
  }

  Future<Response> getCancelledOrderList(String date) async {
    return date == ''
        ? await apiClient.getData(AppConstants.CANCELLED_ORDER_LIST_URI)
        : await apiClient.getData(
            '${AppConstants.CANCELLED_ORDER_LIST_URI}?search_date=$date');
  }

  Future<Response> getRoomPaidOrderList(String date) async {
    return date == ''
        ? await apiClient.getData(AppConstants.ROOM_PAID_ORDER_LIST_URI)
        : await apiClient.getData(
            '${AppConstants.ROOM_PAID_ORDER_LIST_URI}?search_date=$date');
  }

  Future<Response> getTabOrderList(String date) async {
    return date == ''
        ? await apiClient.getData(AppConstants.TAB_ORDER_LIST_URI)
        : await apiClient
            .getData('${AppConstants.TAB_ORDER_LIST_URI}?search_date=$date');
  }

  Future<Response> getTotalKDSOrderList() async {
    return await apiClient.getData(Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .restaurantType ==
            'Restaurant buffet'
        ? AppConstants.GET_BUFFET_STATION_SIDE_MENU_URI
        : AppConstants.GET_TOTAL_KDS_ORDER_LIST_URI);
  }

  Future<Response> setBuffetFoodPriority(Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.SET_BUFFET_FOOD_PRIORITY, body);
  }

  Future<Response> mergeTableList(Map<String, dynamic> json) async {
    return await apiClient.postData(AppConstants.WAITER_MERGE_ORDER_NEW_URI, json);
  }

  Future<Response> transferFood(Map<String, dynamic> json) async {
    return await apiClient.postData(
        AppConstants.WAITER_TRANSFER_FOOD_NEW_URI, json);
  }

  // Future<Response> getTotalBAROrderList() async {
  //   return await apiClient.getData(AppConstants.GET_TOTAL_BAR_ORDER_LIST_URI);
  // }

  Future<Response> getCancelReasonList() async {
    return await apiClient.getData(AppConstants.GET_CANCEL_REASON_LIST_URI);
  }

  Future<Response> orderStatusUpdate(Map<String, dynamic> body) async {
    return await apiClient.putData(AppConstants.OREDER_STATUS_UPDATE_URI, body);
  }

  Future<Response> attendTable(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.ATTEND_TABLE_URI, body);
  }

  Future<Response> splitOrderFromApi(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.SPLIT_ORDER_URL, body);
  }

  Future<Response> silentBuzzerApi() async {
    return await apiClient.getData(AppConstants.SILENT_BUZZER_URI);
  }

  Future<Response> makeUnpaidOrder(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.MAKE_UNPAID_ORDER_URI, body);
  }
  Future<Response> makeRazorpayUnpaidOrder(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.MAKE_RAZORPAY_UNPAID_ORDER_URI, body);
  }

  Future<Response> changeOrderPaymentMethod(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.CHANGE_PAYMENT_METHOD, body);
  }

  Future<Response> prepaidOrderStatusUpdate(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.PREPAID_OREDER_STATUS_UPDATE_URI, body);
  }

  Future<Response> acceptOrder(Map<String, dynamic> body) async {
    return await apiClient.putData(
        AppConstants.WAITER_DINEIN_ORDER_UPDATE_STATUS_NEW_URI, body);
  }

  Future<Response> getPaidRoomorderList(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.GET_PAID_ROOM_ORDER_LIST_URI, body);
  }

  Future<Response> foodOrderStatusUpdate(Map<String, dynamic> body) async {
     print('Resturant Buffet ====> ${Get.find<AuthController>().profileModel!.restaurants!.first.restaurantType == 'Restaurant buffet'}');
    return await apiClient.putData(
      Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .restaurantType ==
                'Restaurant buffet'
            ?  AppConstants.BUFFET_FOOD_OREDER_STATUS_UPDATE_URI :  AppConstants.FOOD_OREDER_STATUS_UPDATE_URI, body);
  }

  Future<Response> sendPrintDataFixedUser(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.SEND_PRINT_MANUAL_URL, body);
  }

  Future<Response> cancelFoodItem(Map<String, dynamic> body,
      {bool isQty = false}) async {
    return await apiClient.putData(
        Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .restaurantType ==
                'Restaurant buffet'
            ? AppConstants.BUFFET_CANCEL_FOOD_ITEM
            : AppConstants.CANCEL_FOOD_NEW_URI,
            // isQty
            //     ? AppConstants.CANCEL_QTY_FOOD_ITEM
            //     : AppConstants.CANCEL_FOOD_ITEM,
        body);
  }
}
