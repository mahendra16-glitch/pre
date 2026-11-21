import 'dart:convert';

import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_bills_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_respone.dart'
    as room;
import 'package:mygenie_restaurant/data/model/response/get_room_list_with_amount_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_view_tab_bill_response.dart';
import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/tap_managment_reesponse_model.dart';
import 'package:mygenie_restaurant/data/repository/pos_repo.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart'
    as paid;
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import '../data/model/response/table_response_model.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';

class PosController extends GetxController implements GetxService {
  final PosRepo posRepo;
  PosController({required this.posRepo});

  TapManagmentCustomerListResponse? _tapManagmentCustomerListResponse;
  GetCollectBillDetailResponse? _getCollectBillDetailResponse;
  GetCollectBillDetailResponse? _getSimpleCollectBillDetail;
  GetViewTabBillsResponseModel? _getViewTabBillsResponseModel;
  List<TableResponseModel> _tableList = [];
  List<room.GetRoomListResponse> _roomList = [];
  List<GetRoomBillsResponseModel> _roomBillsList = [];
  List<RoomListWithAmountResponseModel> _roomListWithAmount = [];
  List<RoomListWithAmountResponseModel> get roomListWithAmount =>
      _roomListWithAmount;
  List<GetRoomBillsResponseModel> get roomBillsList => _roomBillsList;
  List<room.GetRoomListResponse> get roomList => _roomList;

  TableResponseModel? _selectedTable;
  room.GetRoomListResponse? _selectedRoom;
  double _amount = 0.0;
  bool _isShowCustomerData = false;
  bool _isAddServiceCharge = false;
  bool _isApplyLoyalty = false;
  bool _isApplyWallet = false;
  int? _selectedCustomerIndex;
  bool _isLoading = false;
  bool _isEDCLoading = false;
  bool _isEDCCancelLoading = false;

  bool get isEDCLoading => _isEDCLoading;
  bool get isEDCCancelLoading => _isEDCCancelLoading;
  bool get isApplyLoyalty => _isApplyLoyalty;
  bool get isApplyWallet => _isApplyWallet;
  bool get isLoading => _isLoading;
  bool get isAddServiceCharge => _isAddServiceCharge;
  GetCollectBillDetailResponse? get getCollectBillDetailResponse =>
      _getCollectBillDetailResponse;
  GetCollectBillDetailResponse? get getSimpleCollectBillDetail =>
      _getSimpleCollectBillDetail;
  TableResponseModel? get selectedTable => _selectedTable;
  room.GetRoomListResponse? get selectedRoom => _selectedRoom;
  GetViewTabBillsResponseModel? get getViewTabBillsResponseModel =>
      _getViewTabBillsResponseModel;
  bool get isShowCustomerData => _isShowCustomerData;
  int? get selectedCustomerIndex => _selectedCustomerIndex;
  TapManagmentCustomerListResponse? get tapManagmentCustomerListResponse =>
      _tapManagmentCustomerListResponse;
  paid.GetAllPrintRoomBillsResponse? _getAllPrintRoomBillsResponse;
  paid.GetAllPrintRoomBillsResponse? get getAllPrintRoomBillsResponse =>
      _getAllPrintRoomBillsResponse;

  double _subTotal = 0;
  double _itemPrice = 0;
  double _collectItemPrice = 0;
  double _itemDiscountPrice = 0;
  int _selectedPaymentTab = 0;
  String _paymentTab = '';
  String tabCrmCustomerId = '';

  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  double get collectItemPrice => _collectItemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  int get selectedPaymentTab => _selectedPaymentTab;
  String get paymentTab => _paymentTab;

  get selectedCustomerName => null;

  void setPaymentTabIndex(int index) {
    _selectedPaymentTab = index;
    update();
  }

  void setPaymentTabName(String name) {
    _paymentTab = name;
    if (name.isEmpty) tabCrmCustomerId = '';
    update();
  }

  void setcollectItemPrice(double value) {
    _collectItemPrice = value;
    update();
  }

  void changeServeiceChargeValue(bool value) {
    _isAddServiceCharge = value;
    update();
  }

  void hideLoader(bool value) {
    _isLoading = value;
    update();
  }

  void applyLoyaltyValue(bool value) {
    _isApplyLoyalty = value;
    update();
  }

  void applyWalletBalance(bool value) {
    _isApplyWallet = value;
    update();
  }

  void disableEdcLoader(bool value) {
    _isEDCLoading = value;
    _isEDCCancelLoading = false;
    update();
  }

  void clearTapCustomerData() {
    _selectedCustomerIndex = null;
    _isShowCustomerData = false;
  }

  void setTapCustomerData(int? index, bool? value) {
    _selectedCustomerIndex = index;
    _isShowCustomerData = value ?? false;
    update();
  }

  // Future<List<Product>> searchProduct(String searchText) async {
  //   List<Product> _searchProductList = [];

  //   if (searchText.isNotEmpty) {
  //     Response response = await posRepo.searchProductList(searchText);
  //     if (response.statusCode == 200) {
  //       _searchProductList = [];
  //       response.body
  //           .forEach((food) => _searchProductList.add(Product.fromJson(food)));
  //     } else {
  //       ApiChecker.checkApi(response);
  //     }
  //   }
  //   // update();
  //   return _searchProductList;
  // }

  // Future<List<SearchCustomerResponseModel>> searchPOSCustomer(
  //     String searchText) async {
  //   List<SearchCustomerResponseModel> _searchCustomerList = [];

  //   if (searchText.isNotEmpty) {
  //     Response response = await posRepo.searchCustomerList(searchText);
  //     if (response.statusCode == 200) {
  //       _searchCustomerList = [];
  //       response.body.forEach((food) => _searchCustomerList
  //           .add(SearchCustomerResponseModel.fromJson(food)));
  //     } else {
  //       ApiChecker.checkApi(response);
  //     }
  //   }
  //   // update();
  //   return _searchCustomerList;
  // }

  Future<List<SearchCustomerResponseModel>> searchWaiterPOSCustomer(
      String searchText) async {
    List<SearchCustomerResponseModel> _searchCustomerList = [];

    if (searchText.isNotEmpty) {
      Response response = await posRepo.searchWaiterCustomerList(searchText);
      if (response.statusCode == 200) {
        _searchCustomerList = [];
        response.body.forEach((food) => _searchCustomerList
            .add(SearchCustomerResponseModel.fromJson(food)));
      } else {
        ApiChecker.checkApi(response);
      }
    }
    // update();
    return _searchCustomerList;
  }

  Future getRoomList() async {
    _roomList = [];
    _isLoading = true;
    update();
    Response response = await posRepo.getRoomList();
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      _roomList = [];
      _roomList.add(room.GetRoomListResponse(
          table: room.Table(id: 0, tableNo: '--Room Select--', title: '')));
      response.body.forEach(
          (table) => _roomList.add(room.GetRoomListResponse.fromJson(table)));
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> allRoomBillPrint(String orderId) async {
    Response response;
    _isLoading = true;
    update();
    response = await posRepo.printAllBillFromId(orderId);
    if (response.statusCode == 200) {
      _getAllPrintRoomBillsResponse =
          paid.GetAllPrintRoomBillsResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;

    update();
  }

  Future getRoomBillsList(String roomId, Function callback,
      {bool isShowLoader = true}) async {
    _roomBillsList = [];
    if (isShowLoader) {
      _isLoading = true;
      update();
    } else {
      showToast('Please wait..');
      Get.find<LoadingController>().startLoading(true);
    }
    Response response = await posRepo.getRoomBillsList(roomId);
    if (isShowLoader) {
      _isLoading = false;
      update();
    }

    if (response.statusCode == 200) {
      _roomBillsList = [];
      response.body.forEach((room) =>
          _roomBillsList.add(GetRoomBillsResponseModel.fromJson(room)));
      callback(response);
    } else {
      callback(response);
      Get.find<LoadingController>().startLoading(false);
      if (Get.isBottomSheetOpen ?? false) Get.back();
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getRoomListWithAmount() async {
    _roomListWithAmount = [];
    _isLoading = true;
    update();
    Response response = await posRepo.getRoomListWithAmount();
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      _roomListWithAmount = [];
      response.body.forEach((table) => _roomListWithAmount
          .add(RoomListWithAmountResponseModel.fromJson(table)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getTapManageMentCustomerList() async {
    Response response = await posRepo.getTapManageMentCustomerList({});
    if (response.statusCode == 200) {
      _tapManagmentCustomerListResponse =
          TapManagmentCustomerListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getViewTabBills(String id) async {
    _isLoading = true;
    update();
    Response response = await posRepo.getViewTabBills(id);
    _isLoading = false;

    if (response.statusCode == 200) {
      _getViewTabBillsResponseModel =
          GetViewTabBillsResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  // Future<List<EmployeeTapList>> tapManageMentCustomerList(
  //     {String phone}) async {
  //   List<EmployeeTapList> tapList = [];
  //   if (phone == '') {
  //     tapList.addAll(_tapManagmentCustomerListResponse.employeeTapList);
  //   } else {
  //     for (var element in _tapManagmentCustomerListResponse.employeeTapList) {
  //       if (element.mobile.toString().contains(phone.toString())) {
  //         tapList.add(element);
  //       }
  //     }
  //   }
  //   update();
  //   return tapList;
  // }

  Future<void> convertMergeAfterApplyComplement(
      List<OrderDetailsBar> foodOrder) async {
    final List<OrderDetailsBar> mergeFood = mergeFoodItems(foodOrder);
    final List<OrderDetailsBar> mergeOrdiginalOrderFood =
        mergeFoodItemsBasedItemId(foodOrder);
    final List<OrderDetailsBar> mergeFoodWithDate =
        mergeFoodItems(foodOrder, type: 'date');
    _roomBillsList = [];
    getSimpleCollectBillDetail!.orders!.mergeFoodListWithDate =
        mergeFoodWithDate;
    getSimpleCollectBillDetail!.orders!.mergeFoodList = mergeFood;
    getSimpleCollectBillDetail!.orders!.orderDetailsBar = [];
    getSimpleCollectBillDetail!.orders!.orderDetailsFood =
        mergeOrdiginalOrderFood;
    _getCollectBillDetailResponse!.orders!.mergeFoodListWithDate =
        mergeFoodWithDate;
    _getCollectBillDetailResponse!.orders!.mergeFoodList = mergeFood;
    _getCollectBillDetailResponse!.orders!.orderDetailsFood =
        mergeOrdiginalOrderFood;
    // _getCollectBillDetailResponse = GetCollectBillDetailResponse(
    //   orders: Orders(
    //     orderDiscountJson: tempResponse.orders?.orderDiscountJson,
    //     deliveryAddress: tempResponse.orders?.deliveryAddress,
    //     mergeFoodListWithDate: mergeFoodWithDate,
    //     mergeFoodList: mergeFood,
    //     paymentUrl: tempResponse.orders?.paymentUrl ?? '',
    //     orderUser: tempResponse.orders?.orderUser,
    //     orderDetailsOrder: tempResponse.orders?.orderDetailsOrder,
    //     barTotalAddonsAmount: tempResponse.orders?.barTotalAddonsAmount,
    //     foodTotalAddonsAmount: tempResponse.orders?.foodTotalAddonsAmount,
    //     foodVariationAmt: tempResponse.orders?.foodVariationAmt,
    //     barVariationAmt: tempResponse.orders?.barVariationAmt,
    //     orderTotalFood: tempResponse.orders?.orderTotalFood,
    //     orderDetailsBar: tempResponse.orders?.orderDetailsBar ?? [],
    //     orderDetailsFood: foodOrder,
    //     roomInfo: tempResponse.orders?.roomInfo,
    //     restaurantDetails: tempResponse.orders?.restaurantDetails,
    //   ),
    // );

    update();
  }

  Future<List<OrderDetailsBar>> seprateFoodBasedOnFoodQty(
      List<OrderDetailsBar> foodOrder) async {
    List<OrderDetailsBar> seprateFoodList = [];

    for (var element in foodOrder) {
      if (element.quantity == 1) {
        element.isSelectComplementary = element.isComplementary;
        seprateFoodList.add(element);
      } else if (element.quantity != null && element.quantity! > 1) {
        for (var i = 0; i < element.quantity!; i++) {
          OrderDetailsBar temp = OrderDetailsBar(
              isSelectComplementary: element.isComplementary,
              addOns: element.addOns,
              createdAt: element.createdAt,
              foodDetails: element.foodDetails,
              foodId: element.foodId,
              discountOnFood: element.discountOnFood,
              discountType: element.discountType,
              foodStatus: element.foodStatus,
              gstTaxAmount: element.gstTaxAmount,
              id: element.id,
              itemCampaignId: element.itemCampaignId,
              orderId: element.orderId,
              price: element.price,
              totalAddOnPrice: element.totalAddOnPrice,
              unitPrice: element.unitPrice,
              variation: element.variation,
              isComplementary: element.isComplementary,
              quantity: 1);
          seprateFoodList.add(temp);
        }
      }
    }
    update();
    return seprateFoodList;
  }

  Future<void> getCollectBillDetail(
    Map<String, dynamic> body, {
    bool useEmbeddedAssociatedOrders = false,
  }) async {
    _getSimpleCollectBillDetail = null;
    _isLoading = true;
    update();
    final response = await posRepo.getCollectBillDetail(body);

    if (response.statusCode == 200) {
      final tempResponse = GetCollectBillDetailResponse.fromJson(response.body);
      _getSimpleCollectBillDetail =
          GetCollectBillDetailResponse.fromJson(response.body);
      final List<OrderDetailsBar> foodOrder = List<OrderDetailsBar>.from(
          tempResponse.orders?.orderDetailsBar ?? []);
      final List<OrderDetailsBar> mergeFood = mergeFoodItems(foodOrder);
      final List<OrderDetailsBar> mergeFoodWithDate =
          mergeFoodItems(foodOrder, type: 'date');
      _roomBillsList = [];

      _getCollectBillDetailResponse = GetCollectBillDetailResponse(
        orders: Orders(
          orderDiscountJson: tempResponse.orders?.orderDiscountJson,
          deliveryAddress: tempResponse.orders?.deliveryAddress,
          mergeFoodListWithDate: mergeFoodWithDate,
          mergeFoodList: mergeFood,
          paymentUrl: tempResponse.orders?.paymentUrl ?? '',
          orderUser: tempResponse.orders?.orderUser,
          orderDetailsOrder: tempResponse.orders?.orderDetailsOrder,
          barTotalAddonsAmount: tempResponse.orders?.barTotalAddonsAmount,
          foodTotalAddonsAmount: tempResponse.orders?.foodTotalAddonsAmount,
          foodVariationAmt: tempResponse.orders?.foodVariationAmt,
          barVariationAmt: tempResponse.orders?.barVariationAmt,
          orderTotalFood: tempResponse.orders?.orderTotalFood,
          orderDetailsBar: tempResponse.orders?.orderDetailsBar ?? [],
          orderDetailsFood: foodOrder,
          roomInfo: tempResponse.orders?.roomInfo,
          restaurantDetails: tempResponse.orders?.restaurantDetails,
          associatedOrderList: tempResponse.orders?.associatedOrderList ?? [],
        ),
      );

      if (_getCollectBillDetailResponse!
              .orders?.restaurantDetails?.restaurantOrderFor ==
          'ROOM') {
        if (useEmbeddedAssociatedOrders) {
          _roomBillsList = _mapAssociatedOrdersToRoomBills(
            tempResponse.orders?.associatedOrderList ?? [],
            roomId: tempResponse.orders?.orderDetailsOrder?.tableId,
          );
          if (_roomBillsList.isEmpty) {
            await getRoomBillsList(
              _getCollectBillDetailResponse!.orders?.orderDetailsOrder?.tableId
                      ?.toString() ??
                  '',
              (response) {},
            );
          }
        } else {
          await getRoomBillsList(
            _getCollectBillDetailResponse!.orders?.orderDetailsOrder?.tableId
                    ?.toString() ??
                '',
            (response) {},
          );
        }
      }
    } else {
      _isLoading = false;
      update();
      ApiChecker.checkApi(response);
    }
    update();
  }

  List<GetRoomBillsResponseModel> _mapAssociatedOrdersToRoomBills(
    List<CollectBillAssociatedOrder> items, {
    int? roomId,
  }) {
    return items
        .map(
          (item) => GetRoomBillsResponseModel.fromCollectBillAssociatedOrder(
            orderId: item.id,
            restaurantOrderId: item.restaurantOrderId,
            orderAmount: item.orderAmount,
            collectBillDate: item.collectBillDate,
            roomId: roomId,
          ),
        )
        .toList();
  }

  void clearTableList() {
    _selectedTable = null;
    _tableList = [];
    update();
  }

  void setTableIndex(TableResponseModel table) {
    _selectedTable = table;
    update();
  }

  void setRoomIndex(room.GetRoomListResponse? table) {
    _selectedRoom = table;
    update();
  }

  List<OrderDetailsBar> mergeFoodItems(List<OrderDetailsBar> foodItems,
      {String? type}) {
    final Map<String, OrderDetailsBar> mergedItems = {};

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
              labelList.add(element.level ?? '');
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
        if (item.foodDetails != null &&
            double.tryParse('${item.foodDetails?['price'] ?? '1'}') != 1) {
          final key = type == 'date'
              ? '${item.foodId}, $variationText, $addons,${item.isComplementary} ,${item.isComplementaryFromApi} , $createDate'
              : '${item.foodId}, $variationText, $addons,${item.isComplementary},${item.isComplementaryFromApi}';
          if (mergedItems.containsKey(key)) {
            mergedItems[key] = OrderDetailsBar(
              addOns: item.addOns,
              createdAt: item.createdAt,
              foodDetails: item.foodDetails,
              foodId: item.foodId,
              discountOnFood: item.discountOnFood,
              discountType: item.discountType,
              foodStatus: item.foodStatus,
              gstTaxAmount: item.gstTaxAmount,
              id: item.id,
              itemCampaignId: item.itemCampaignId,
              orderId: item.orderId,
              price: item.price,
              totalAddOnPrice: item.totalAddOnPrice,
              unitPrice: item.unitPrice,
              variation: item.variation,
              isComplementary: item.isComplementary,
              isComplementaryFromApi: item.isComplementaryFromApi,
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

  List<OrderDetailsBar> mergeFoodItemsBasedItemId(
    List<OrderDetailsBar> foodItems,
  ) {
    final Map<String, OrderDetailsBar> mergedItems = {};

    for (final item in foodItems) {
      String variationText = '';
      if (item.variation != null && item.variation!.isNotEmpty) {
        for (int j = 0; j < item.variation!.length; j++) {
          variationText +=
              '${variationText.isNotEmpty ? ', ' : ''}${item.variation![j].name ?? ''} (';

          if (item.variation![j].values != null) {
            final labelList = <String>[];
            for (final element in item.variation![j].values!) {
              labelList.add(element.level ?? '');
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
        if (item.foodDetails != null &&
            double.tryParse('${item.foodDetails?['price'] ?? '1'}') != 1) {
          final key =
              '${item.id},${item.foodId}, $variationText, $addons, ${item.isComplementary},${item.isComplementaryFromApi}';
          if (mergedItems.containsKey(key)) {
            mergedItems[key] = OrderDetailsBar(
              addOns: item.addOns,
              createdAt: item.createdAt,
              foodDetails: item.foodDetails,
              foodId: item.foodId,
              discountOnFood: item.discountOnFood,
              discountType: item.discountType,
              foodStatus: item.foodStatus,
              gstTaxAmount: item.gstTaxAmount,
              id: item.id,
              itemCampaignId: item.itemCampaignId,
              orderId: item.orderId,
              price: item.price,
              totalAddOnPrice: item.totalAddOnPrice,
              unitPrice: item.unitPrice,
              variation: item.variation,
              isComplementary: item.isComplementary,
              isComplementaryFromApi: item.isComplementaryFromApi,
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

  Future<void> recordRoomPayment(
    Map<String, dynamic> jsonData,
    Function(bool success, String message) callback,
  ) async {
    Response response = await posRepo.recordRoomPayment(jsonData);
    String message = response.statusText ?? 'Payment failed';
    if (response.body is Map && response.body['message'] != null) {
      message = response.body['message'].toString();
    }
    if (response.statusCode == 200) {
      callback(true, message.isEmpty ? 'Payment recorded' : message);
    } else {
      callback(false, message);
    }
  }

  Future<void> splitRoomOrder(
    Map<String, dynamic> jsonData,
    Function(bool success, String message) callback,
  ) async {
    Response response = await posRepo.splitRoomOrder(jsonData);
    String message = response.statusText ?? 'Failed to move items';
    if (response.body is Map && response.body['message'] != null) {
      message = response.body['message'].toString();
    }
    if (response.statusCode == 200) {
      callback(true, message.isEmpty ? 'Items moved' : message);
    } else {
      callback(false, message);
    }
  }

  Future<void> collectPayment(Function callback,
      {Map<String, dynamic>? jsonData}) async {
    _isLoading = true;
    update();

    Response response;

    response = await posRepo.collectPayment(jsonData!);

    Get.find<LoyaltyController>().hideLoader();
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message);
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText);
    }
    update();
  }

  Future<void> edcCollectPayment(Function callback,
      {Map<String, dynamic>? jsonData}) async {
    _isEDCLoading = true;
    update();
    Response response;

    response = await posRepo.edcCollectPayment(jsonData!);

    Get.find<LoyaltyController>().hideLoader();
    _isEDCLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message);
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText);
    }
    update();
  }

  Future<void> cancelEdcReq({Map<String, dynamic>? jsonData}) async {
    _isEDCCancelLoading = true;
    update();
    Response response;

    response = await posRepo.cancelEdcReq(jsonData!);

    _isEDCCancelLoading = false;
    _isEDCLoading = false;
    if (response.statusCode == 200) {
      // String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);

      showToastSuccess(response.body['message']);
    }
    update();
  }

  Future<void> addBillsInRoom(Function callback,
      {Map<String, dynamic>? jsonData}) async {
    _isLoading = true;
    update();

    Response response;

    response = await posRepo.addBillsInRoom(jsonData!);

    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message);
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText);
    }
    update();
  }

  Future<void> collectTapPayment(Function callback,
      {Map<String, dynamic>? jsonData}) async {
    _isLoading = true;
    update();

    Response response;

    response = await posRepo.collectTapPayment(jsonData!);

    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message);
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText);
    }
    update();
  }

  // Future<void> collectRoomPayment(Function callback,
  //     {Map<String, dynamic>? jsonData}) async {
  //   _isLoading = true;
  //   update();

  //   Response response;

  //   response = await posRepo.collectRoomPayment(jsonData!);

  //   _isLoading = false;
  //   if (response.statusCode == 200) {
  //     String message = response.body['message'];
  //     // orderRepo.sendNotificationRequest(orderID);
  //     callback(true, message);
  //     if (kDebugMode) {
  //       // print('-------- Order placed successfully $orderID ----------');
  //     }
  //   } else {
  //     callback(false, response.statusText);
  //   }
  //   update();
  // }

  Future<void> applyDiscountForRoleBase(
      {Map<String, dynamic>? jsonData}) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await posRepo.applyDiscountForRoleBase(jsonData!);
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message']);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      await Get.find<LoadingController>().changeStatus(data: true);
    }
    update();
  }

  int selectedVariationLength(List<List<bool>> selectedVariations, int index) {
    int length = 0;
    for (bool isSelected in selectedVariations[index]) {
      if (isSelected) {
        length++;
      }
    }
    return length;
  }

  void _showUpperCartSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      backgroundColor: Colors.red,
      message: message,
      duration: const Duration(seconds: 3),
      maxWidth: Get.width,
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      borderRadius: 10,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ));
  }

  //****************************************** TAP CUSTOMER ORDER RECORDS REPORT ******************************************//

  List<Map<String, dynamic>> _tapCustomerOrderRecords = [];
  Map<String, dynamic> _tapCustomerOrderSummary = {};
  bool _isLoadingTapReport = false;

  List<Map<String, dynamic>> get tapCustomerOrderRecords =>
      _tapCustomerOrderRecords;
  Map<String, dynamic> get tapCustomerOrderSummary => _tapCustomerOrderSummary;
  bool get isLoadingTapReport => _isLoadingTapReport;

  Future<void> getTapCustomerOrderRecords({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      _isLoadingTapReport = true;
      update();

      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> requestData = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      Response response;
      try {
        response = await posRepo.getTapCustomerOrderRecords(requestData);
      } catch (e) {
        if (kDebugMode) {
          print("API Call Error: $e");
        }
        _tapCustomerOrderRecords = [];
        _tapCustomerOrderSummary = {};
        _isLoadingTapReport = false;
        update();
        return;
      }

      if (response.statusCode == 200) {
        try {
          if (response.body != null &&
              response.body is Map &&
              (response.body as Map)['success'] == true &&
              (response.body as Map)['data'] != null) {
            final responseData = (response.body as Map)['data'];
            if (responseData is Map) {
              if (responseData['records'] != null &&
                  responseData['records'] is List) {
                _tapCustomerOrderRecords =
                    List<Map<String, dynamic>>.from(responseData['records']);
              } else {
                _tapCustomerOrderRecords = [];
              }
              if (responseData['summary'] != null &&
                  responseData['summary'] is Map) {
                _tapCustomerOrderSummary =
                    Map<String, dynamic>.from(responseData['summary']);
              } else {
                _tapCustomerOrderSummary = {};
              }
            } else {
              _tapCustomerOrderRecords = [];
              _tapCustomerOrderSummary = {};
            }
          } else {
            _tapCustomerOrderRecords = [];
            _tapCustomerOrderSummary = {};
          }
        } catch (e) {
          if (kDebugMode) {
            print("Response Parsing Error: $e");
          }
          _tapCustomerOrderRecords = [];
          _tapCustomerOrderSummary = {};
        }
      } else {
        ApiChecker.checkApi(response);
        _tapCustomerOrderRecords = [];
        _tapCustomerOrderSummary = {};
      }
      update();
    } catch (e) {
      if (kDebugMode) {
        print("getTapCustomerOrderRecords Error: $e");
      }
      _tapCustomerOrderRecords = [];
      _tapCustomerOrderSummary = {};
      update();
    } finally {
      _isLoadingTapReport = false;
      update();
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
      if (kDebugMode) {
        print("_convertDateFormat Error: $e");
      }
      return date;
    }
  }

  Future<void> exportTapCustomerOrderRecords({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      _isLoadingTapReport = true;
      update();
      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      String formattedFromDate = _convertDateFormat(fromDate);
      String formattedToDate = _convertDateFormat(toDate);

      Map<String, dynamic> requestData = {
        "from": formattedFromDate,
        "to": formattedToDate,
      };

      Response response;
      try {
        response = await posRepo.exportTapCustomerOrderRecords(requestData);
      } catch (e) {
        if (kDebugMode) {
          print("Export API Call Error: $e");
        }
        return;
      }

      if (response.statusCode == 200) {
        try {
          if (response.body != null &&
              response.body is Map &&
              (response.body as Map)['success'] == true) {
            final downloadUrl =
                (response.body as Map)['download_url'] as String?;
            if (downloadUrl != null && downloadUrl.isNotEmpty) {
              await appLaunchUrl(downloadUrl);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Export Response Parsing Error: $e");
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print("exportTapCustomerOrderRecords Error: $e");
      }
    } finally {
      _isLoadingTapReport = false;
      update();
    }
  }

  //****************************************** TAP CUSTOMER ORDER RECORDS REPORT ******************************************//
}
