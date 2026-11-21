import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:get/get.dart';

class PosRepo {
  final ApiClient apiClient;
  PosRepo({required this.apiClient});

  // Future<Response> searchProductList(String searchText) async {
  //   return await apiClient
  //       .postData(AppConstants.SEARCH_PRODUCT_LIST_URI, {'name': searchText});
  // }

  Future<Response> printAllBillFromId(String orderId) async {
    return await apiClient
        .getData('${AppConstants.ALL_ROOM_BILL_PRINT_FROM_ORDERID}$orderId');
  }

  // Future<Response> searchCustomerList(String searchText) async {
  //   return await apiClient
  //       .getData('${AppConstants.SEARCH_CUSTOMERS_URI}?search=$searchText');
  // }

  Future<Response> searchWaiterCustomerList(String searchText) async {
    return await apiClient.getData(
        '${AppConstants.WAITER_SEARCH_CUSTOMERS_URI}?search=$searchText');
  }

  Future<Response> getRoomList() async {
    return await apiClient.getData('${AppConstants.ROOM_LIST_URI}');
  }

  Future<Response> getRoomBillsList(String roomId) async {
    return await apiClient.postData(
        '${AppConstants.ROOM_BILLS_LIST_URI}', {'room_id': '$roomId'});
  }

  Future<Response> getRoomListWithAmount() async {
    return await apiClient.postData(
        '${AppConstants.ROOM_LIST_WITH_AMOUNT_URI}', '');
  }

  Future<Response> getTapManageMentCustomerList(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.TAP_MANAGEMENT_CUSTOMER_LIST_URI}', body);
  }

  Future<Response> getViewTabBills(String customerId) async {
    return await apiClient
        .getData('${AppConstants.GET_VIEW_TAB_BILLS_URI}$customerId');
  }

  Future<Response> getCollectBillDetail(Map<String, dynamic> body) async {
    return await apiClient.postData(
        '${AppConstants.GET_COLLECT_BILL_DETTAIL_URI}', body);
  }

  // Future<Response> placeOrder(Map<String, dynamic> bodyData) async {
  //   return await apiClient.postData(
  //       '${AppConstants.PLACE_ORDER_URI}', bodyData);
  // }

  Future<Response> collectPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.COLLECT_PAYMENT_URI}', bodyData);
  }

  Future<Response> recordRoomPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.ROOM_PAYMENT_URI}', bodyData);
  }

  Future<Response> splitRoomOrder(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.SPLIT_ROOM_ORDER_URI}', bodyData);
  }

  Future<Response> edcCollectPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.EDC_COLLECT_PAYMENT_URI}', bodyData,
        timeout: 360);
  }

  Future<Response> cancelEdcReq(Map<String, dynamic> bodyData) async {
    return await apiClient
        .postData('${AppConstants.CANCEL_EDC_REQ_URI}', bodyData, timeout: 30);
  }

  Future<Response> addBillsInRoom(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.ADD_BILL_IN_ROOM_URI}', bodyData);
  }

  Future<Response> collectTapPayment(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.COLLECT_TAP_PAYMENT_URI}', bodyData);
  }

  // Future<Response> collectRoomPayment(Map<String, dynamic> bodyData) async {
  //   return await apiClient.postData(
  //       '${AppConstants.COLLECT_ROOM_PAYMENT_URI}', bodyData);
  // }

  Future<Response> applyDiscountForRoleBase(
      Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.APPLY_DISCOUNT_FOR_ROLE_BASE_URI}', bodyData);
  }

  Future<Response> waiterPlaceOrder(Map<String, dynamic> bodyData) async {
    return await apiClient.postData(
        '${AppConstants.EMPLOYEE_PLACE_ORDER_URI}', bodyData);
  }

  Future<Response> waiterUpdatePlaceOrder(Map<String, dynamic> bodyData) async {
    return await apiClient.putData(
        '${AppConstants.EMPLOYEE_UPDATE_PLACE_ORDER_URI}', bodyData);
  }

  // Future<Response> getPosOrders() async {
  //   return await apiClient.getData('${AppConstants.POS_ORDERS_URI}');
  // }

  Future<Response> getTapCustomerOrderRecords(Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.TAP_CUSTOMER_ORDER_RECORDS_URI, body);
  }

  Future<Response> exportTapCustomerOrderRecords(
      Map<String, dynamic> body) async {
    return await apiClient.postData(
        AppConstants.TAP_CUSTOMER_ORDER_RECORDS_EXPORT_URI, body);
  }
}
