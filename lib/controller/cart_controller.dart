import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/location_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_documents_response.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_list_response.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
import '../util/common_import_file.dart';

class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});
  List<CartModel> _cartList = [];

  List<CartModel> get cartList => _cartList;
  bool _isApplyWallet = false;
  bool get isApplyWallet => _isApplyWallet;

  double _subTotal = 0;
  double _itemPrice = 0;
  // double _itemDiscountPrice = 0;
  double _addOns = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  final Map<int, double> _productQtyMap = {};

  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  // double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  double _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<int> _addOnQtyList = [];
  double get quantity => _quantity;
  List<bool> get addOnActiveList => _addOnActiveList;
  List<int> get addOnQtyList => _addOnQtyList;
  SearchCustomerResponseModel? _selectedCustomer;
  CrmCustomerDetailResponse? _selectedCrmCustomer;
  List<TableResponseModel> _tableList = [];
  List<TableResponseModel> _searchTableList = [];
  List<TableResponseModel> _roomList = [];
  TableResponseModel? _selectedTable;
  List<TableResponseModel> _selectedTables = [];
  GetCustomerListResponse? _customerList;
  CrmCustomerListResponse? _crmCustomerList;
  GetMemberListResponse? _memberList;

  bool _isLoading = false;
  bool _isEDCLoading = false;
  bool get isLoading => _isLoading;
  bool get isEDCLoading => _isEDCLoading;
  List<TableResponseModel> get tableList => _tableList;
  List<TableResponseModel> get searchTableList => _searchTableList;
  List<TableResponseModel> get roomList => _roomList;

  TableResponseModel? get selectedTable => _selectedTable;
  List<TableResponseModel> get selectedTables => _selectedTables;
  GetCustomerListResponse? get customerList => _customerList;
  CrmCustomerListResponse? get crmCustomerList => _crmCustomerList;
  GetMemberListResponse? get memberList => _memberList;
  SearchCustomerResponseModel? get selectedCustomer => _selectedCustomer;
  CrmCustomerDetailResponse? get selectedCrmCustomer => _selectedCrmCustomer;

  List<List<bool>>? _selectedVariations = [];
  List<List<bool>>? get selectedVariations => _selectedVariations;
  bool _isApplyLoyalty = false;
  bool get isApplyLoyalty => _isApplyLoyalty;

  bool isPrinterBusy = false;

  void applyLoyaltyValue(bool value) {
    _isApplyLoyalty = value;
    update();
  }

  List<Map<String, dynamic>> _buildPrinterAgentForCart() {
    return buildPrinterAgentPayload(
      printAgents: Get.find<AuthController>().profileModel?.printAgent,
      cartStations: cartList.map((c) => c.product.stationName),
    );
  }

  void initData(Product product, CartModel? cart) {
    _selectedVariations = [];
    _addOnQtyList = [];
    _addOnActiveList = [];

    if (cart != null) {
      _quantity = cart.quantity ?? 1;
      _selectedVariations
          ?.addAll(cart.variation.map((e) => List<bool>.from(e)));
    }
    List<int> addOnIdList = [];
    if (cart != null)
      addOnIdList = cart.addOnIds.map((addOnId) => addOnId.id).toList();
    for (var addOn in product.addOns!) {
      int idx = addOnIdList.indexOf(addOn.id!);
      if (idx != -1 && cart != null) {
        _addOnActiveList.add(true);
        _addOnQtyList.add(cart.addOnIds[idx].quantity);
      } else {
        _addOnActiveList.add(false);
        _addOnQtyList.add(0);
      }
    }
    if (cart == null) {
      _quantity = 1;
      if (product.variations != null) {
        for (int index = 0; index < product.variations!.length; index++) {
          _selectedVariations!.add([]);
          for (int i = 0; i < product.variations![index].values!.length; i++) {
            _selectedVariations![index].add(false);
          }
        }
      }
    }
  }

  double calculationCart() {
    _itemPrice = 0;
    _subTotal = 0;
    _addOns = 0;
    _availableList.clear();
    _addOnsList.clear();
    for (var cartModel in _cartList) {
      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds) {
        for (AddOns addOns in cartModel.product.addOns!) {
          if (addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(
          cartModel.product.availableTimeStarts!,
          cartModel.product.availableTimeEnds!));

      for (int index = 0; index < addOnList.length; index++) {
        _addOns += addOnList[index].price! * cartModel.addOnIds[index].quantity;
      }

      if (Get.find<TableController>().selectedTable != null &&
          Get.find<TableController>().selectedTable!.tableNo == 'Take Away') {
        _itemPrice += cartModel.isComplementry
            ? 0
            : ((cartModel.product.takeAwayFoodPrice! + cartModel.price) *
                cartModel.quantity);
      } else if (Get.find<TableController>().selectedTable != null &&
          Get.find<TableController>().selectedTable!.tableNo == 'Delivery') {
        _itemPrice += (cartModel.product.deliveryFoodPrice! + cartModel.price) *
            cartModel.quantity;
      } else {
        _itemPrice += cartModel.isComplementry
            ? 0
            : ((cartModel.price) * cartModel.quantity);
      }
      // _itemPrice += (cartModel.price) * cartModel.quantity;
    }
    _subTotal = _itemPrice;
    return _subTotal;
  }

  Future<List<SearchCustomerResponseModel>> searchWaiterPOSCustomer(
      String searchText) async {
    List<SearchCustomerResponseModel> _searchCustomerList = [];

    if (searchText.isNotEmpty) {
      Response response = await cartRepo.searchWaiterCustomerList(searchText);
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

  showLoader(bool val) {
    _isLoading = val;
    update();
  }

  Future<void> getTableList({bool isShowLoader = true}) async {
    if (isShowLoader) {
      _isLoading = true;
      update();
    } else {
      showToast('Please wait');
      Get.find<LoadingController>().startLoading(true);
    }
    Response response = Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .restaurantType ==
            'Restaurant buffet'
        ? await cartRepo.getBuffetTableList()
        : await cartRepo.getTableList();
    if (response.statusCode == 200) {
      Restaurant restaurant =
          Get.find<AuthController>().profileModel!.restaurants!.first;
      _tableList.clear();
      if (restaurant.isDineIn == 'Yes')
        _tableList
            .add(TableResponseModel(id: 0, tableNo: 'Select Table', title: ''));
      if (restaurant.takeAway!) {
        _tableList
            .add(TableResponseModel(id: 0, tableNo: 'Take Away', title: ''));
      }
      if (restaurant.delivery!) {
        _tableList
            .add(TableResponseModel(id: 0, tableNo: 'Delivery', title: ''));
      }

      for (final table in response.body) {
        if (table['rtype'] == 'TB') {
          _tableList.add(TableResponseModel.fromJson(table));
        }
      }
      if (isShowLoader) {
        _isLoading = false;
        update();
      } else {
        Get.find<LoadingController>().startLoading(false);
        Get.back();
      }
    } else {
      if (isShowLoader) {
        _isLoading = false;
        update();
      } else {
        Get.find<LoadingController>().startLoading(false);
      }
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getRoomList({bool isShowLoader = true}) async {
    if (isShowLoader) {
      _isLoading = true;
      update();
    } else {
      showToast('Please wait');
      Get.find<LoadingController>().startLoading(true);
    }
    Response response = await cartRepo.getTableList();
    if (response.statusCode == 200) {
      _roomList = [];
      // _roomList.add(
      //     TableResponseModel(id: 0, tableNo: '--Room Select--', title: ''));
      response.body.forEach((table) {
        if (table['rtype'] == 'RM')
          _roomList.add(TableResponseModel.fromJson(table));
      });

      if (isShowLoader) {
        _isLoading = false;
        update();
      } else {
        Get.find<LoadingController>().startLoading(false);
        Get.back();
      }
    } else {
      if (isShowLoader) {
        _isLoading = false;
        update();
      } else {
        Get.find<LoadingController>().startLoading(false);
      }
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future changeTable(
      String type, Map<String, dynamic> body, Function callback) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    Response response = await cartRepo.changeTable(body);
    // _isLoading = false;
    // update();
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      callback(true);
      await Get.find<LoadingController>().changeText(
          data: type == 'RM'
              ? 'Room change successfully'
              : 'Table change successfully');
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<String> changeCustomerDetail(
      Map<String, dynamic> body, Function callback,
      {bool showLoader = true}) async {
    String userId = '';
    try {
      if (showLoader) {
        showToast('Please wait..');
        Get.find<LoadingController>().startLoading(true);
      }

      Response response = await cartRepo.updateCustomerDetail(body);
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

  Future<String?> lookupAndSyncCrmCustomer({
    required String phone,
    required String name,
    String? email,
    String? dob,
    String? anniversary,
    String? posId,
    String? countryCode,
    String? customerType,
    bool backToPrevious = true,
    // bool skip = false,
  }) async {
    final restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    final restaurantId = restaurant.id?.toString() ?? '';

    final body = {
      'pos_id': posId ?? '',
      'restaurant_id': restaurantId,
      'phone': phone,
      'name': name,
      'email': email ?? '',
      'dob': dob ?? '',
      'anniversary': anniversary ?? '',
      'country_code': countryCode ?? '',
      'customer_type': customerType ?? '',
    };

    try {
      // Step 1 — Lookup
      final lookupResponse = await cartRepo.crmCustomerLookup(phone);

      if (lookupResponse.statusCode == 200) {
        final isRegistered = lookupResponse.body['data']['registered'] == true;

        if (isRegistered) {
          // Step 2a — Customer found → Edit
          final customerId = lookupResponse.body['data']['customer_id'];
          debugPrint('====> CRM: Customer found → editing $customerId');

          final editResponse = await cartRepo.editCrmCustomer(customerId, body);
          if (editResponse.statusCode == 200) {
            if (backToPrevious) Get.back();
            return customerId;
          } else if (editResponse.statusCode == 401) {
            showErrorToast(
              editResponse.body?['message']?.toString() ??
                  'Something went wrong',
            );
          } else {
            ApiChecker.checkApi(editResponse);
            return null;
          }
        } else {
          // Step 2b — Customer not found → Add
          debugPrint('====> CRM: Customer not found → adding new');

          final addResponse = await cartRepo.addCrmCustomer(body);
          if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
            final newId = addResponse.body['data']?['id'] ??
                addResponse.body['data']?['customer_id'];
            if (backToPrevious) Get.back();
            return newId?.toString();
          } else if (addResponse.statusCode == 401) {
            showErrorToast(
              addResponse.body?['message']?.toString() ??
                  'Something went wrong',
            );
          } else {
            ApiChecker.checkApi(addResponse);
            return null;
          }
        }
      } else if (lookupResponse.statusCode == 401) {
        showErrorToast(
          lookupResponse.body?['message']?.toString() ?? 'Something went wrong',
        );
      } else {
        ApiChecker.checkApi(lookupResponse);
        return null;
      }
    } catch (e) {
      debugPrint('====> CRM lookupAndSync Error: $e');
      return null;
    }
    return null;
  }

  Future editTableList(TableResponseModel table) async {
    _tableList.add(table);
    update();
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    if (!isAdd) {
      _addOnQtyList[index] = 0;
    }
    update();
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _addOnQtyList[index] = _addOnQtyList[index] + 1;
    } else {
      _addOnQtyList[index] = _addOnQtyList[index] - 1;
    }
    update();
  }

  // void addToCart(CartModel cartModel, int index) {
  //   if (index != null) {
  //     _amount = _amount -
  //         (_cartList[index].discountedPrice * _cartList[index].quantity);
  //     _cartList.replaceRange(index, index + 1, [cartModel]);
  //   } else {
  //     _cartList.add(cartModel);
  //   }
  //   _amount = _amount + (cartModel.discountedPrice * cartModel.quantity);
  //   update();
  // }

  void saveOrderList(List<String> orderList) {
    cartRepo.saveOrderList(orderList);
  }

  void saveLastOrderId(String orderList) {
    cartRepo.saveLastOrderId(orderList);
  }

  Future<List<LocalOrderModel>> getOrderListFromLocally() async {
    // Retrieve the List<String> from cartRepo
    List<String> orderListJson = cartRepo.getOrderListFromLocal();

    if (orderListJson.isNotEmpty) {
      // Convert each JSON string in the list back to LocalOrderModel objects
      return orderListJson
          .map((jsonString) => LocalOrderModel.fromJson(jsonDecode(jsonString)))
          .toList();
    }

    return []; // Return an empty list if no data is found
  }

  Future<String?> getLastOrderIdFromLocal() async {
    // Retrieve the last order ID from cartRepo
    String? orderId = cartRepo.getLastOrderIdFromLocal();

    if (orderId.isNotEmpty) {
      return orderId; // Return the retrieved orderId as a String
    }

    return null;
  }

  Future getCustomerFromApi({bool isLoading = false}) async {
    if (isLoading) _isLoading = true;
    if (isLoading) update();
    _customerList = null;
    Response response = await cartRepo.getCustomerList({});
    if (isLoading) _isLoading = false;
    if (isLoading) update();
    if (response.statusCode == 200) {
      _customerList = GetCustomerListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getCustomerFromApiCrm({
    bool isLoading = false,
    String search = '',
    int limit = 10,
    bool isRetry = false,
  }) async {
    if (isLoading) _isLoading = true;
    if (isLoading) update();
    _customerList = null;

    // Pass search & limit instead of empty Map
    Response response =
        await cartRepo.getCustomerListCrm(search: search, limit: limit);

    if (isLoading) _isLoading = false;
    if (isLoading) update();

    if (response.statusCode == 200) {
      _crmCustomerList = CrmCustomerListResponse.fromJson(response.body);
    } else if (response.statusCode == 401) {
      // showErrorToast(
      //   response.body?['message']?.toString() ?? 'Something went wrong',
      // );
      _crmCustomerList = null;
      // Invalid/empty CRM key — refresh token once and retry search
      if (!isRetry) {
        final refreshed = await Get.find<AuthController>().refreshCrmToken();
        if (refreshed) {
          return getCustomerFromApiCrm(
            isLoading: isLoading,
            search: search,
            limit: limit,
            isRetry: true,
          );
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future getCrmCustomerDetail(
    String customerId, {
    bool isLoading = false,
    bool isRetry = false,
  }) async {
    debugPrint('====> Detail API called with ID: $customerId');
    if (isLoading) _isLoading = true;
    if (isLoading) update();

    _selectedCrmCustomer = null;
    Response response = await cartRepo.getCrmCustomerDetail(customerId);

    if (isLoading) _isLoading = false;
    if (isLoading) update();

    if (response.statusCode == 200) {
      try {
        _selectedCrmCustomer =
            CrmCustomerDetailResponse.fromJson(response.body);
        debugPrint('====> Parse SUCCESS: ${selectedCrmCustomer?.name}');
        update();
        return selectedCrmCustomer;
      } catch (e, stack) {
        debugPrint('====> PARSE ERROR: $e');
        debugPrint('====> STACK: $stack');
        update();
        return null;
      }
    } else if (response.statusCode == 401) {
      if (!isRetry) {
        final refreshed = await Get.find<AuthController>().refreshCrmToken();
        if (refreshed) {
          return getCrmCustomerDetail(
            customerId,
            isLoading: isLoading,
            isRetry: true,
          );
        }
      }
      // Avoid showErrorToast — bottom sheet can disrupt TypeAhead / selection
    } else {
      debugPrint(
          '====> Detail FAILED: ${response.statusCode} ${response.body}');
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<List<CrmCustomerDocument>> getCrmCustomerDocuments(
    String customerId, {
    bool isRetry = false,
  }) async {
    debugPrint('====> Documents API called with ID: $customerId');
    Response response = await cartRepo.getCrmCustomerDocuments(customerId);

    if (response.statusCode == 200) {
      try {
        return CrmCustomerDocumentsResponse.fromJson(response.body).documents;
      } catch (e, stack) {
        debugPrint('====> DOCUMENTS PARSE ERROR: $e');
        debugPrint('====> STACK: $stack');
        return [];
      }
    } else if (response.statusCode == 401) {
      if (!isRetry) {
        final refreshed = await Get.find<AuthController>().refreshCrmToken();
        if (refreshed) {
          return getCrmCustomerDocuments(customerId, isRetry: true);
        }
      }
    } else {
      debugPrint(
          '====> Documents FAILED: ${response.statusCode} ${response.body}');
    }
    return [];
  }

  String mapCrmDocType(String uiLabel) {
    switch (uiLabel.trim().toLowerCase()) {
      case 'aadhar card':
      case 'aadhaar card':
      case 'aadhaar':
        return 'aadhaar';
      case 'passport':
        return 'passport';
      case 'pan card':
      case 'pan':
        return 'pan';
      case 'license':
        return 'license';
      case 'other':
        return 'other';
      default:
        return uiLabel.trim().toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<void> uploadCrmCustomerDocuments({
    required String customerId,
    required String docType,
    XFile? frontFile,
    XFile? backFile,
  }) async {
    if (customerId.isEmpty ||
        docType.isEmpty ||
        docType == 'Select document type') {
      return;
    }
    final crmDocType = mapCrmDocType(docType);
    if (frontFile != null) {
      await uploadCrmCustomerDocument(
        customerId: customerId,
        docType: crmDocType,
        file: frontFile,
      );
    }
    if (backFile != null) {
      await uploadCrmCustomerDocument(
        customerId: customerId,
        docType: crmDocType,
        file: backFile,
      );
    }
  }

  Future<bool> uploadCrmCustomerDocument({
    required String customerId,
    required String docType,
    required XFile file,
    bool isRetry = false,
  }) async {
    try {
      final response = await cartRepo.uploadCrmCustomerDocument(
        customerId: customerId,
        docType: docType,
        file: file,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      if (response.statusCode == 401 && !isRetry) {
        final refreshed = await Get.find<AuthController>().refreshCrmToken();
        if (refreshed) {
          return uploadCrmCustomerDocument(
            customerId: customerId,
            docType: docType,
            file: file,
            isRetry: true,
          );
        }
      }
      debugPrint(
          '====> CRM document upload failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('====> CRM document upload error: $e');
    }
    return false;
  }

  // Future getMemberFromApi() async {
  //   _memberList = null;
  //   Response response = await cartRepo.getCustomerListFromMember();
  //   if (response.statusCode == 200) {
  //     _memberList = GetMemberListResponse.fromJson(response.body);
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }
  Future addMoneyWallet(
      Map<String, dynamic> jsonData, CustomerList? csutomer) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await cartRepo.addMoneyWallet(jsonData);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      if (response.body.containsKey('message') &&
          response.body['message'] == 'Amount credited successfully') {
        if (csutomer != null)
          csutomer.virtualWalletBal =
              double.parse('${response.body['balance'] ?? 0}');
        await Get.find<LoadingController>()
            .changeText(data: response.body['message']);
        await Get.find<LoadingController>().changeStatus(data: true);
      } else {
        showErrorToast(response.body['message'], isError: true);
      }
    } else {
      showErrorToast(response.body['message'], isError: true);
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<Map<String, dynamic>> getWalletBalanceOfCustomer(String userID) async {
    Map<String, dynamic> jsonResponse = {};
    Response response = await cartRepo.checkWalletBal(userID);
    jsonResponse = response.body;
    if (response.statusCode == 200) {
    } else {}
    update();
    return jsonResponse;
  }

  void addToCart(CartModel cartModel, int? index) {
    if (index != null && index != -1) {
      _cartList.replaceRange(index, index + 1, [cartModel]);
    } else {
      _cartList.add(cartModel);
    }
    calculationCart();
//
    update();
  }

  // void setQuantity(bool isIncrement, CartModel cart) {
  //   int index = _cartList.indexOf(cart);
  //   if (isIncrement) {
  //     _cartList[index].quantity = _cartList[index].quantity + 1;
  //   } else {
  //     _cartList[index].quantity = _cartList[index].quantity - 1;
  //   }

  //   calculationCart();
  //   update();
  // }

// ==============================
  // ENTRY POINT FROM UI (ADD / +)
  // ==============================
  void onAddProduct(Product product,
      {int? qty, bool? isAddComplementry = false}) {
    final hasVariation = product.variations?.isNotEmpty == true;
    final hasAddOns = product.addOns?.isNotEmpty == true;

    if (!hasVariation &&
        !hasAddOns &&
        product.price != 1 &&
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .foodLevelNotes ==
            'No') {
      _addSimpleProduct(product,
          qty: qty ?? 1, isAddComplementry: isAddComplementry);
      return;
    }

    final existingItems =
        _cartList.where((e) => e.product.id == product.id).toList();

    if (existingItems.isEmpty) {
      openCustomization(product);
    } else {
      _showRepeatDialog(product, existingItems.last);
    }
  }

  void addPRoductAfterComplement(CartModel? cart, Product product, {int? qty}) {
    CartModel _cartModel = CartModel(
        foodNote: cart?.foodNote ?? '',
        isInventory: product.isInventory,
        adjustPrice: cart?.adjustPrice ?? 1,
        price: 0,
        discountedPrice: 0,
        quantity: (qty ?? 1).toDouble(),
        addOnIds: cart!.addOnIds,
        addOns: cart.addOns,
        product: product,
        variation: cart.variation,
        isComplementry: true);
    final match = _cartList.firstWhereOrNull(
      (e) => _isSameCartItem(e, _cartModel),
    );

    if (match != null) {
      match.quantity++;
    } else {
      _cartList.insert(0, _cartModel);
    }

    _rebuildProductQtyMap();
    calculationCart();
    update(['qty', 'cart']);
    update();
  }

  // ==============================
  // SIMPLE PRODUCT (NO VARIANT)
  // ==============================
  void _addSimpleProduct(Product product,
      {int? qty, bool? isAddComplementry = false}) {
    final existing = _cartList.firstWhereOrNull(
      (e) => e.product.id == product.id,
    );

    if (existing != null) {
      existing.quantity++;
    } else {
      _cartList.add(
        CartModel(
          product: product,
          variation: [],
          addOnIds: [],
          addOns: [],
          quantity: (qty ?? 1).toDouble(),
          isComplementry: isAddComplementry ?? false,
          price: product.price ?? 0,
          discountedPrice: product.price ?? 0,
          adjustPrice: 1,
          // discountAmount: 0,
          isInventory: product.isInventory,
        ),
      );
    }

    _rebuildProductQtyMap();
    calculationCart();
    update(['qty', 'cart']);
    update();
  }

  // ==============================
  // REPEAT / CUSTOMIZE POPUP
  // ==============================
  void _showRepeatDialog(Product product, CartModel lastItem) {
    Get.dialog(
      AlertDialog(
        title: const Text('Repeat last item?'),
        content: Text(
          'You already added ${product.name}. '
          'Do you want the same customizations?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openCustomization(product);
            },
            child: const Text('CUSTOMIZE'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setQuantity(true, lastItem);
            },
            child: const Text('REPEAT'),
          ),
        ],
      ),
    );
  }

  // ==============================
  // AFTER CUSTOMIZATION DONE
  // ==============================
  void addCustomizedItem({
    required Product product,
    required List<List<bool>> variation,
    required List<AddOn> addOnIds,
    required double finalPrice,
    String? note,
    double quantity = 1,
    double adjustPrice = 1,
  }) {
    final newItem = CartModel(
      product: product,
      variation: variation,
      addOnIds: addOnIds,
      addOns: [],
      quantity: quantity.toDouble(),
      price: finalPrice,
      discountedPrice: finalPrice,
      adjustPrice: adjustPrice,
      // discountAmount: 0,
      foodNote: note,
      isInventory: product.isInventory,
    );

    _addToCartSmart(newItem);
  }

  // ==============================
  // SMART ADD (MATCH CONFIG)
  // ==============================
  void _addToCartSmart(CartModel newItem) {
    final match = _cartList.firstWhereOrNull(
      (e) => _isSameCartItem(e, newItem),
    );

    if (match != null) {
      // match.quantity++;
      match.quantity += newItem.quantity;
    } else {
      _cartList.add(newItem);
    }

    _rebuildProductQtyMap();
    calculationCart();
    update(['qty', 'cart']);
    update();
  }

  // ==============================
  // STORE QTY
  // ==============================
  double getProductQty(int productId) {
    return _productQtyMap[productId] ?? 0;
  }

  void _rebuildProductQtyMap() {
    _productQtyMap.clear();

    for (final cart in _cartList) {
      final id = cart.product.id;
      if (id == null) continue;

      _productQtyMap[id] = (_productQtyMap[id] ?? 0) + cart.quantity;
    }
  }

  // ==============================
  // INCREASE / DECREASE QTY
  // ==============================
  void setQuantity(bool isIncrement, CartModel cart,
      {int? qty, bool? removeFromCart}) {
    final index = _cartList.indexOf(cart);
    if (index == -1) return;

    if (isIncrement) {
      _cartList[index].quantity++;
    } else {
      if (_cartList[index].quantity > 1) {
        if (qty == null) {
          _cartList[index].quantity--;
        } else {
          if (removeFromCart!) {
            _cartList.removeAt(index);
          } else {
            _cartList[index].quantity = qty.toDouble();
          }
        }
      } else {
        _cartList.removeAt(index);
      }
    }

    _rebuildProductQtyMap();
    calculationCart();
    update(['qty', 'cart']);
    update();
  }

  void decreaseProductQty(int productId) {
    final items = _cartList.where((e) => e.product.id == productId).toList();

    if (items.isEmpty) return;

    // 🚫 Multiple customizations exist
    if (items.length > 1) {
      showErrorToast(
          'This item has multiple customizations added. Remove the correct item from the cart.');

      return;
    }

    // ✅ Only ONE customization exists → safe to remove
    setQuantity(false, items.first);
  }

  // ==============================
  // CART ITEM COMPARISON
  // ==============================
  bool _isSameCartItem(CartModel a, CartModel b) {
    return a.product.id == b.product.id &&
        a.adjustPrice == b.adjustPrice &&
        _sameVariation(a.variation, b.variation) &&
        _sameAddOns(a.addOnIds, b.addOnIds) &&
        (a.isComplementry == b.isComplementry) &&
        (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .foodLevelNotes ==
                'Yes'
            ? a.foodNote == b.foodNote
            : false);
  }

  bool _sameVariation(List<List<bool>> a, List<List<bool>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) return false;
    }
    return true;
  }

  bool _sameAddOns(List<AddOn> a, List<AddOn> b) {
    if (a.length != b.length) return false;
    for (final addOn in a) {
      final match = b.firstWhereOrNull((e) => e.id == addOn.id);
      if (match == null || match.quantity != addOn.quantity) return false;
    }
    return true;
  }

  // ==============================
  // OPEN CUSTOMIZATION UI
  // ==============================
  void openCustomization(Product product) {
    initData(product, null);

    Get.bottomSheet(
        ProductBottomSheet(
            onIncrease: (data) {}, product: product, isCampaign: false),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  void modifyCartQtyTextField(double qty, CartModel cart) {
    int index = _cartList.indexOf(cart);

    _cartList[index].quantity = qty;
    calculationCart();
    update();
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds.removeAt(addOnIndex);
    calculationCart();
    update();
  }

  void reorderAddToCart(List<CartModel> cartList) {
    clearCartList();
    _cartList.addAll(cartList);
    calculationCart();

    update();
  }

  void clearCartList() {
    _cartList.clear();
    _productQtyMap.clear();

    _itemPrice = 0;
    _addOns = 0;
    _subTotal = 0;

    calculationCart();
    update(['qty', 'cart']);

    update();
  }

  bool existAnotherRestaurantProduct(int restaurantID) {
    for (CartModel cartModel in _cartList) {
      if (cartModel.product.restaurantId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  void removeAllAndAddToCart(CartModel cartModel) {
    _cartList = [];
    _cartList.add(cartModel);
    calculationCart();
    update();
  }

  void removeFromCart(int index) {
    _cartList.removeAt(index);
    calculationCart();
    update();
  }

  void clearTableList() {
    _selectedTable = null;
    _selectedTables = [];
    _tableList = [];
    _roomList = [];
    _selectedCustomer = null;
    update();
  }

  void setTableIndex(TableResponseModel? table) {
    _selectedTable = table;
    update();
  }

  void setSelectedRooms(List<TableResponseModel> tables) {
    _selectedTables = tables;
    update();
  }

  void setSearchUserData(SearchCustomerResponseModel customer) {
    _selectedCustomer = customer;
    update();
  }

  void setProductQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = _quantity + 1;
    } else {
      _quantity = _quantity - 1;
    }
    update();
  }

  void textUpdateProductQuantity(double qty) {
    _quantity = qty;

    update();
  }

  void setCartVariationIndex(
      int index, int i, Product product, bool isMultiSelect) {
    if (!isMultiSelect &&
        _selectedVariations != null &&
        _selectedVariations!.isNotEmpty) {
      for (int j = 0; j < _selectedVariations![index].length; j++) {
        if (product.variations![index].required == 'on') {
          _selectedVariations![index][j] = j == i;
        } else {
          if (_selectedVariations![index][j]) {
            _selectedVariations?[index][j] = false;
          } else {
            _selectedVariations?[index][j] = j == i;
          }
        }
      }
    } else {
      int maxSelection =
          int.tryParse(product.variations![index].max ?? '0') ?? 0;
      if (_selectedVariations != null &&
          _selectedVariations!.isNotEmpty &&
          !_selectedVariations![index][i] &&
          selectedVariationLength(_selectedVariations!, index) >=
              maxSelection &&
          maxSelection > 0) {
        _showUpperCartSnackBar(
            '${'maximum_variation_for'.tr} ${product.variations![index].name} ${'is'.tr} ${product.variations![index].max}');
      } else if (_selectedVariations != null) {
        _selectedVariations![index][i] = !_selectedVariations![index][i];
      }
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

  Future<void> buffetPlaceOrder(
      double deliveryCharge,
      String phone,
      String name,
      String note,
      String orderAmount,
      String type,
      Function callback,
      {String? addressId,
      bool isUpdate = false,
      String? orderId,
      String? audioFile}) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());

    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    List<Map<String, dynamic>> jsonModifyProductNameCartList = [];
    for (var cart in cartList) {
      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<OrderVariation> variations = [];
      if (cart.product.variations != null) {
        for (int i = 0; i < cart.product.variations!.length; i++) {
          if (cart.variation[i].contains(true)) {
            variations.add(OrderVariation(
                name: cart.product.variations![i].name,
                values: OrderVariationValue(label: [])));
            for (int j = 0;
                j < cart.product.variations![i].values!.length;
                j++) {
              if (cart.variation[i][j]) {
                variations[variations.length - 1]
                    .values!
                    .label!
                    .add(cart.product.variations![i].values![j].level!);
              }
            }
          }
        }
      }
      for (var addOn in cart.addOnIds) {
        addOnIdList.add(addOn.id);

        addOnQtyList.add(addOn.quantity);
      }
      // if (cart.updateFoodName != null &&
      //     cart.updateFoodName != '' &&
      //     cart.product.name.toLowerCase().contains('out of')) {
      //   var jsonData = {
      //     "food_id": cart.product.id,
      //     "food_category_id": cart.product.categoryId.toString(),
      //     "new_food_name": cart.updateFoodName,
      //     "quantity": cart.quantity,
      //     "price":
      //         cart.product.price > 1 ? cart.product.price : cart.adjustPrice,
      //   };
      //   jsonModifyProductNameCartList.add(jsonData);
      // } else {
      var jsonData = {
        "priority": Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .restaurantType ==
                    'Restaurant buffet' &&
                Get.find<RestaurantController>().isPriority == 'Yes'
            ? 'Yes'
            : 'No',
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variant": "",
        "add_on_ids": addOnIdList,
        "add_on_qtys": addOnQtyList,
        "variations": variations,
        "add_ons": cart.addOns,
        "food_level_notes": cart.foodNote,
        "price":
            cart.product.price! > 1 ? cart.product.price : cart.adjustPrice,
      };
      jsonCartList.add(jsonData);
      // }
    }
    Map<String, dynamic> jsonData = {
      "payment_method": "cash_on_delivery",
      if (isUpdate) "order_id": orderId,
      "order_amount": orderAmount,
      "delivery_charge": '$deliveryCharge',
      'address_id': addressId ?? '',
      "restaurant_id": Get.find<AuthController>()
          .profileModel!
          .restaurants![0]
          .id
          .toString(),
      "user_id": '',
      "order_note": note,
      'order_type': selectedTable == null
          ? 'pos'
          : (selectedTable!.id == 0 && selectedTable!.tableNo == 'Delivery')
              ? 'delivery'
              : (selectedTable!.id == 0 &&
                      selectedTable!.tableNo == 'Take Away')
                  ? 'take_away'
                  : 'pos',
      "table_id": selectedTable == null || selectedTable!.id == 0
          ? ''
          : selectedTable!.id.toString(),
      'cust_mobile': phone == '' ? '' : phone,
      'cust_email': '',
      'cust_name': name == '' ? '' : name,
      if (isUpdate) "cart-update": jsonCartList,
      if (!isUpdate) "cart": jsonCartList,
      // if (!isUpdate) "edit_food": jsonModifyProductNameCartList
    };
    Response response;

    response = await cartRepo.buffetPlaceOrder({'data': jsonEncode(jsonData)});

    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      String orderID = response.body['order_id'].toString();
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message, orderID, '');
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1', '');
    }
    update();
  }

  Future<List<TableResponseModel>> searchTable(
      BuildContext context, String text) async {
    _searchTableList = [];
    if (text.isNotEmpty) {
      _tableList.forEach((prediction) {
        if (prediction.tableNo.toLowerCase().contains(text.toLowerCase())) {
          _searchTableList.add(prediction);
        }
      });
    }
    return _searchTableList.isEmpty ? _tableList : _searchTableList;
  }

  Future<void> placeOrder(
    double deliveryCharge,
    DateTime? selectedDateTime,
    String phone,
    String name,
    String dob,
    String anniversary,
    String membershipId,
    String note,
    double orderAmount,
    String type,
    Function callback, {
    String? addressId,
    bool isUpdate = false,
    String? orderId,
    String? audioFile,
    String? uuid,
    bool isPrintKot = false,
  }) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());
    final seleTable = Get.find<TableController>().selectedTable;

    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    for (var cart in cartList) {
      // List<int> addOnIdList = [];
      // List<int> addOnQtyList = [];
      List<AddOns> addOns = [];
      double foodAddonTotal = 0;
      double foodVariationTotal = 0;

      List<OrderVariation> variations = [];
      List<Variations> modifyVariation = [];
      final productVariations = cart.product.variations;
      if (productVariations != null) {
        for (int i = 0; i < productVariations.length; i++) {
          if (cart.variation[i].contains(true)) {
            final variation = productVariations[i];
            variations.add(OrderVariation(
                name: variation.name, values: OrderVariationValue(label: [])));

            modifyVariation.add(Variations(
                name: variation.name,
                type: variation.type,
                max: variation.max,
                min: variation.min,
                required: variation.required,
                values: []));

            final values = variation.values;
            if (values != null) {
              for (int j = 0; j < values.length; j++) {
                if (cart.variation[i][j]) {
                  final value = values[j];
                  final label = value.level ?? '';
                  variations[variations.length - 1].values!.label!.add(label);
                  modifyVariation[modifyVariation.length - 1].values!.add(
                      VariationOption(
                          level: value.level ?? '',
                          optionPrice: value.optionPrice ?? '0'));
                  foodVariationTotal +=
                      (double.tryParse(value.optionPrice ?? '0') ?? 0) *
                          cart.quantity;
                }
              }
            }
          }
        }
      }

      for (var i = 0; i < cart.addOnIds.length; i++) {
        // addOnIdList.add(cart.addOnIds[i].id);
        // addOnQtyList.add(cart.addOnIds[i].quantity);
        if (cart.addOnIds[i].quantity != 0) {
          final addOnPrice = cart.addOnIds[i].price ?? 0;
          foodAddonTotal = foodAddonTotal +
              ((addOnPrice * cart.addOnIds[i].quantity) * cart.quantity);

          addOns.add(AddOns(
            id: cart.addOnIds[i].id,
            name: cart.addOnIds[i].name,
            qty: cart.addOnIds[i].quantity,
            price: cart.addOnIds[i].price,
          ));
        }
      }

      var jsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variations": modifyVariation,
        "variation_total": foodVariationTotal,
        "addons_total": foodAddonTotal,
        "add_ons": addOns,
        'station': cart.product.stationName,
        "food_level_notes": cart.foodNote,
        "is_inventory": cart.isInventory,
        "is_complementoy": cart.isComplementry == true ? 'Yes' : 'No',
        "price": (cart.product.price ?? 0) > 1
            ? (seleTable == null
                ? cart.product.price!
                : seleTable.tableNo == 'Take Away'
                    ? (cart.product.price! + cart.product.takeAwayFoodPrice!)
                    : seleTable.tableNo == 'Delivery'
                        ? (cart.product.price! +
                            cart.product.deliveryFoodPrice!)
                        : cart.product.price)
            : cart.adjustPrice,
      };
      jsonCartList.add(jsonData);
      // }
    }
    debugPrint(jsonEncode(jsonCartList));
    final profileModel = Get.find<AuthController>().profileModel;
    final restaurants = profileModel?.restaurants;
    final restaurantId = (restaurants != null && restaurants.isNotEmpty)
        ? restaurants[0].id?.toString() ?? ''
        : '';
    final defOrdStatus = (restaurants != null && restaurants.isNotEmpty)
        ? restaurants.first.defOrdStatus
        : null;
    final isShowInventory = (restaurants != null && restaurants.isNotEmpty)
        ? restaurants.first.isShowInventory
        : null;
    final isNegativeInventory = (restaurants != null && restaurants.isNotEmpty)
        ? restaurants.first.isNegativeInventory
        : null;

    final orderType = (seleTable == null)
        ? 'pos'
        : (seleTable.id == 0 && seleTable.tableNo == 'Delivery')
            ? 'delivery'
            : (seleTable.id == 0 && seleTable.tableNo == 'Take Away')
                ? 'take_away'
                : 'pos';
    final tableId = (seleTable == null || seleTable.id == 0)
        ? '0'
        : seleTable.id.toString();

    Map<String, dynamic> jsonData = {
      "payment_method": "cash_on_delivery",
      if (isUpdate) "order_id": orderId,
      // if (!isUpdate)
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .restaurantType !=
          'Restaurant buffet')
        "request_uuid": uuid ?? '',
      "order_amount": orderAmount,
      "delivery_charge": '$deliveryCharge',
      'address_id': addressId ?? '',
      "restaurant_id": restaurantId,
      "user_id":
          Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
              ? Get.find<LocationController>().addressList.first.userId ?? ''
              : '',
      "order_note": note,
      'gst_tax': "0",
      'vat_tax': "0",
      'tip_amount': '0',
      'order_type': orderType,
      if (selectedDateTime != null)
        "schedule_at":
            DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime),
      if (selectedDateTime != null) "scheduled": 1,
      "table_id": tableId,
      'cust_mobile': phone == '' ? '' : phone,
      'print_kot': isPrintKot ? 'Yes' : 'No',
      'cust_email': '',
      'cust_name': name == '' ? '' : name,
      'cust_dob': dob == '' ? '' : dob,
      'cust_anniversary': anniversary == '' ? '' : anniversary,
      'cust_membership_id': membershipId == '' ? '' : membershipId,
      'auto_dispatch': Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .settings
              ?.autoDispatch ??
          'No',
      if (defOrdStatus != null) 'def_order_status': defOrdStatus,
      if (isShowInventory != null) 'inventory': isShowInventory,
      if (isNegativeInventory != null)
        'inventory_negative': isNegativeInventory,
      if (isUpdate) "cart-update": jsonCartList,
      if (!isUpdate) "cart": jsonCartList,
      'printer_agent': _buildPrinterAgentForCart(),
      // if (!isUpdate) "edit_food": jsonModifyProductNameCartList
    };
    Response response;

    response = isUpdate
        ? await cartRepo.waiterUpdatePlaceOrder(jsonData)
        : await cartRepo.waiterPlaceOrder({
            'data': jsonEncode(jsonData),
          }, audioFile ?? '');
    debugPrint(jsonEncode(jsonData), wrapWidth: 1024);
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      String orderID = response.body['order_id'].toString();
      // orderRepo.sendNotificationRequest(orderID);
      callback(
        true,
        message,
        orderID,
      );
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1');
    }
    update();
  }

  Future<void> placeAndPayOrder(Function callback,
      {String? audioFile, Map<String, dynamic>? jsonBody}) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());

    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    List<Map<String, dynamic>> jsonModifyProductNameCartList = [];
    for (var cart in cartList) {
      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<OrderVariation> variations = [];
      if (cart.product.variations != null) {
        if (cart.product.variations != null) {
          for (int i = 0; i < cart.product.variations!.length; i++) {
            if (cart.variation[i].contains(true)) {
              variations.add(OrderVariation(
                  name: cart.product.variations![i].name,
                  values: OrderVariationValue(label: [])));
              final values = cart.product.variations![i].values;
              if (values != null) {
                for (int j = 0; j < values.length; j++) {
                  if (cart.variation[i][j]) {
                    final labelList =
                        variations[variations.length - 1].values?.label;
                    if (labelList != null) {
                      labelList.add(values[j].level ?? '');
                    }
                  }
                }
              }
            }
          }
        }
      }

      for (var addOn in cart.addOnIds) {
        addOnIdList.add(addOn.id);

        addOnQtyList.add(addOn.quantity);
      }

      var tempJsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variant": "",
        "add_on_ids": addOnIdList,
        "add_on_qtys": addOnQtyList,
        "variations": variations,
        "add_ons": cart.addOns,
        'station': cart.product.stationName,
        "is_inventory": cart.isInventory,
        "price":
            cart.product.price! > 1 ? cart.product.price : cart.adjustPrice,
      };
      jsonCartList.add(tempJsonData);
      // }
    }
    Map<String, dynamic> jsonData = {
      "payment_method": "cash_on_delivery",
      "restaurant_id": Get.find<AuthController>()
          .profileModel!
          .restaurants![0]
          .id
          .toString(),
      "user_id": '',
      'order_type': selectedTable == null
          ? 'pos'
          : (selectedTable!.id == 0 && selectedTable!.tableNo == 'Delivery')
              ? 'delivery'
              : (selectedTable!.id == 0 &&
                      selectedTable!.tableNo == 'Take Away')
                  ? 'take_away'
                  : 'pos',
      "table_id": '',
      "cart": jsonCartList,
    };
    Response response;
    jsonData.addAll(jsonBody!);
    jsonData['printer_agent'] = _buildPrinterAgentForCart();
    response = await cartRepo.waiterPlaceAndPayOrder(
        {'data': jsonEncode(jsonData)}, audioFile ?? '');

    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // String orderID = response.body['order_id'].toString();
      // orderRepo.sendNotificationRequest(orderID);
      callback(
        true,
        message,
        '${response.body['restaurant_order_id']}',
      );
      if (kDebugMode) {
        print('-------- Order placed successfully orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1');
    }
    update();
  }

  Future<void> prepaidOrder(
    Function callback, {
    String? audioFile,
    Map<String, dynamic>? jsonBody,
    List<Map<String, dynamic>>? jsonFoodList,
  }) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());
    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    for (int i = 0; i < cartList.length; i++) {
      CartModel cart = cartList[i];

      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<OrderVariation> variations = [];
      if (cart.product.variations != null) {
        for (int i = 0; i < cart.product.variations!.length; i++) {
          if (cart.variation[i].contains(true)) {
            variations.add(OrderVariation(
                name: cart.product.variations![i].name,
                values: OrderVariationValue(label: [])));
            for (int j = 0;
                j < cart.product.variations![i].values!.length;
                j++) {
              if (cart.variation[i][j]) {
                variations[variations.length - 1]
                    .values!
                    .label!
                    .add(cart.product.variations![i].values![j].level ?? '');
              }
            }
          }
        }
      }
      for (var addOn in cart.addOnIds) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }

      var tempJsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variant": "",
        "add_on_ids": addOnIdList,
        'food_level_notes': cart.foodNote,
        "add_on_qtys": addOnQtyList,
        "variations": variations,
        "add_ons": cart.addOns,
        'station': cart.product.stationName,
        "price": cart.isComplementry
            ? 0
            : ((cart.product.price ?? 0) > 1
                ? (Get.find<TableController>().selectedTable == null
                    ? cart.product.price!
                    : Get.find<TableController>().selectedTable!.tableNo ==
                            'Take Away'
                        ? (cart.product.price! +
                            cart.product.takeAwayFoodPrice!)
                        : Get.find<TableController>().selectedTable!.tableNo ==
                                'Delivery'
                            ? (cart.product.price! +
                                cart.product.deliveryFoodPrice!)
                            : cart.product.price)
                : cart.adjustPrice),
      };
      tempJsonData.addAll(jsonFoodList![i]);

      jsonCartList.add(tempJsonData);
    }
    Map<String, dynamic> jsonData = {
      "restaurant_id": Get.find<AuthController>()
              .profileModel
              ?.restaurants?[0]
              .id
              .toString() ??
          '',
      "user_id":
          Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
              ? Get.find<LocationController>().addressList.first.userId ?? ''
              : '',
      "cart": jsonCartList,
    };
    if (jsonBody != null) {
      jsonData.addAll(jsonBody);
    }
    jsonData['printer_agent'] = _buildPrinterAgentForCart();
    Response response = await cartRepo
        .prepaidOrder({'data': jsonEncode(jsonData)}, audioFile ?? '');
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(
        true,
        message,
        '${response.body['restaurant_order_id']}',
      );
      if (kDebugMode) {
        print('-------- Order placed successfully orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1');
    }
    update();
  }

  Future<void> newPlaceOrder(
    Function callback, {
    Map<String, dynamic>? jsonBody,
    bool isUpdate = false,
    List<Map<String, dynamic>>? jsonFoodList,
  }) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());
    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    for (int i = 0; i < cartList.length; i++) {
      CartModel cart = cartList[i];

      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<OrderVariation> variations = [];
      if (cart.product.variations != null) {
        for (int i = 0; i < cart.product.variations!.length; i++) {
          if (cart.variation[i].contains(true)) {
            variations.add(OrderVariation(
                name: cart.product.variations![i].name,
                values: OrderVariationValue(label: [])));
            for (int j = 0;
                j < cart.product.variations![i].values!.length;
                j++) {
              if (cart.variation[i][j]) {
                variations[variations.length - 1]
                    .values!
                    .label!
                    .add(cart.product.variations![i].values![j].level ?? '');
              }
            }
          }
        }
      }
      for (var addOn in cart.addOnIds) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }

      var tempJsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variant": "",
        "add_on_ids": addOnIdList,
        'food_level_notes': cart.foodNote,
        "add_on_qtys": addOnQtyList,
        "variations": variations,
        "add_ons": cart.addOns,
        'station': cart.product.stationName,
        "price": cart.isComplementry
            ? 0
            : ((cart.product.price ?? 0) > 1
                ? (Get.find<TableController>().selectedTable == null
                    ? cart.product.price!
                    : Get.find<TableController>().selectedTable!.tableNo ==
                            'Take Away'
                        ? (cart.product.price! +
                            cart.product.takeAwayFoodPrice!)
                        : Get.find<TableController>().selectedTable!.tableNo ==
                                'Delivery'
                            ? (cart.product.price! +
                                cart.product.deliveryFoodPrice!)
                            : cart.product.price)
                : cart.adjustPrice),
      };
      tempJsonData.addAll(jsonFoodList![i]);

      jsonCartList.add(tempJsonData);
    }
    Map<String, dynamic> jsonData = {
      if (!isUpdate) "cart": jsonCartList,
      if (isUpdate) "cart-update": jsonCartList,
    };
    if (jsonBody != null) {
      jsonData.addAll(jsonBody);
    }
    jsonData['printer_agent'] = _buildPrinterAgentForCart();
    Response response = isUpdate
        ? await cartRepo.waiterEditOrder({'data': jsonEncode(jsonData)}, '')
        : await cartRepo
            .waiterPlaceAndPayOrder({'data': jsonEncode(jsonData)}, '');
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];

      callback(
        true,
        message,
        '${response.body['restaurant_order_id']}',
        '${response.body['daily_token']}',
      );
      if (isUpdate) {
        await Get.find<KdsController>().orderEngageFromSocket(
          orderId: '${response.body['order_id']}',
          status: 'No',
        );
      }
      if (kDebugMode) {
        print('-------- Order placed successfully orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1', '');
    }
    update();
  }

  Future<void> edcPrepaidOrder(
    Function callback, {
    String? audioFile,
    Map<String, dynamic>? jsonBody,
    List<Map<String, dynamic>>? jsonFoodList,
  }) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());

    _isEDCLoading = true;
    update();

    List<Map<String, dynamic>> jsonCartList = [];
    for (int i = 0; i < cartList.length; i++) {
      CartModel cart = cartList[i];

      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<OrderVariation> variations = [];
      if (cart.product.variations != null) {
        for (int i = 0; i < cart.product.variations!.length; i++) {
          if (cart.variation[i].contains(true)) {
            variations.add(OrderVariation(
                name: cart.product.variations![i].name,
                values: OrderVariationValue(label: [])));
            for (int j = 0;
                j < cart.product.variations![i].values!.length;
                j++) {
              if (cart.variation[i][j]) {
                variations[variations.length - 1]
                    .values!
                    .label!
                    .add(cart.product.variations![i].values![j].level ?? '');
              }
            }
          }
        }
      }
      for (var addOn in cart.addOnIds) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }

      var tempJsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variant": "",
        "add_on_ids": addOnIdList,
        'food_level_notes': cart.foodNote,
        "add_on_qtys": addOnQtyList,
        "variations": variations,
        "add_ons": cart.addOns,
        'station': cart.product.stationName,
        "price": (cart.product.price ?? 0) > 1
            ? (Get.find<TableController>().selectedTable == null
                ? cart.product.price!
                : Get.find<TableController>().selectedTable!.tableNo ==
                        'Take Away'
                    ? (cart.product.price! + cart.product.takeAwayFoodPrice!)
                    : Get.find<TableController>().selectedTable!.tableNo ==
                            'Delivery'
                        ? (cart.product.price! +
                            cart.product.deliveryFoodPrice!)
                        : cart.product.price)
            : cart.adjustPrice,
      };
      tempJsonData.addAll(jsonFoodList![i]);
      jsonCartList.add(tempJsonData);
    }
    Map<String, dynamic> jsonData = {
      "restaurant_id": Get.find<AuthController>()
              .profileModel
              ?.restaurants?[0]
              .id
              .toString() ??
          '',
      "user_id":
          Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
              ? Get.find<LocationController>().addressList.first.userId ?? ''
              : '',
      "cart": jsonCartList,
    };
    if (jsonBody != null) {
      jsonData.addAll(jsonBody);
    }
    jsonData['printer_agent'] = _buildPrinterAgentForCart();
    Response response = await cartRepo
        .edcPrepaidOrder({'data': jsonEncode(jsonData)}, audioFile ?? '');
    _isEDCLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(
        true,
        message,
        '${response.body['restaurant_order_id']}',
      );
      if (kDebugMode) {
        print('-------- Order placed successfully orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1');
    }
    update();
  }

  Future<void> billingSyncOrder(List<LocalOrderModel> orderList) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);

    List<Map<String, dynamic>> orderListJson = [];
    for (var order = 0; order < orderList.length; order++) {
      List<Map<String, dynamic>> jsonCartList = [];
      for (var cart in orderList[order].cartList) {
        List<int> addOnIdList = [];
        List<int> addOnQtyList = [];
        List<OrderVariation> variations = [];
        if (cart.product.variations != null) {
          for (int i = 0; i < cart.product.variations!.length; i++) {
            if (cart.variation[i].contains(true)) {
              variations.add(OrderVariation(
                  name: cart.product.variations![i].name,
                  values: OrderVariationValue(label: [])));
              for (int j = 0;
                  j < (cart.product.variations![i].values?.length ?? 0);
                  j++) {
                if (cart.variation[i][j]) {
                  variations[variations.length - 1]
                      .values
                      ?.label
                      ?.add(cart.product.variations![i].values![j].level ?? '');
                }
              }
            }
          }
        }
        for (var addOn in cart.addOnIds) {
          addOnIdList.add(addOn.id);
          addOnQtyList.add(addOn.quantity);
        }
        var jsonData = {
          "food_id": cart.product.id,
          "quantity": cart.quantity,
          "variant": "",
          "add_on_ids": addOnIdList,
          "add_on_qtys": addOnQtyList,
          "variations": variations,
          "add_ons": cart.addOns,
          "price": (cart.product.price ?? 0) > 1
              ? cart.product.price
              : cart.adjustPrice,
        };
        jsonCartList.add(jsonData);
      }

      Map<String, dynamic> jsonData = {
        "restaurant_order_id": orderList[order].orderId,
        "subTotal": orderList[order].subTotal,
        "employeeName": orderList[order].employeeName,
        "notes": orderList[order].notes,
        "name": orderList[order].name,
        "phoneNumber": orderList[order].phoneNumber,
        "serviceCharge": orderList[order].serviceCharge,
        "tips": orderList[order].tips,
        "createdAt": orderList[order].createdAt,
        "discount": orderList[order].discount,
        "orderAmount": orderList[order].orderAmount,
        "gstTaxAmount": orderList[order].gstTaxAmount,
        "paymentMethod": orderList[order].paymentMethod,
        "waiter_id": orderList[order].employeeId,
        "vat_tax": 0,
        "cart": jsonCartList
      };

      orderListJson.add(jsonData);
    }
    Response response =
        await cartRepo.billingSyncOrder({"orders": orderListJson});
    Get.find<LoadingController>().startLoading(false);

    if (response.statusCode == 200) {
      String message = response.body['message'];
      Get.find<CartController>().saveOrderList([]);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      await Get.find<LoadingController>()
          .changeText(data: response.statusText ?? '', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
    update();
  }

  int isExistInCart(int productID, int cartIndex) {
    for (int index = 0; index < _cartList.length; index++) {
      if (_cartList[index].product.id == productID) {
        if ((index == cartIndex)) {
          return -1;
        } else {
          return index;
        }
      }
    }
    return -1;
  }

  //...............................whatsapp bill .................................//
  Future<void> whatsappBill(Map<String, dynamic> data) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.whatsappBill(data);
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      print('whatsapp bill response: $message');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<String?> sendWhatsappPaymentLink(Map<String, dynamic> data) async {
    _isLoading = true;
    update();
    Response response = await cartRepo.sendPaymentLink(data);
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      return response.body['payment_link'];
    } else {
      ApiChecker.checkApi(response);
      return null;
    }
  }

  void applyWalletBalance(bool value) {
    _isApplyWallet = value;
    update();
  }
}
