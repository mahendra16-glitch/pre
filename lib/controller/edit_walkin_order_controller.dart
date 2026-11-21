import 'dart:convert';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/body/cart_variation_body.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
import 'package:mygenie_restaurant/data/repository/cart_repo.dart';
import 'package:mygenie_restaurant/data/repository/edit_walkin_order_repo.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/model/response/get_waiter_order_list_response.dart';
import '../data/model/response/table_response_model.dart';

class EditWalkInOrderController extends GetxController implements GetxService {
  final EditWalkInOrderRepo cartRepo;
  EditWalkInOrderController({required this.cartRepo});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  String _orderType = '';
  double _itemPrice = 0;
  double _itemDiscountPrice = 0;
  double _addOns = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  double get subTotal => _subTotal;
  String get orderType => _orderType;
  double get itemPrice => _itemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  double _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<int> _addOnQtyList = [];
  double get quantity => _quantity;
  List<bool> get addOnActiveList => _addOnActiveList;
  List<int> get addOnQtyList => _addOnQtyList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<List<bool>> _selectedVariations = [];
  List<List<bool>> get selectedVariations => _selectedVariations;
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
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOns = 0;
    _availableList = [];
    _addOnsList = [];
    for (var cartModel in _cartList) {
      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds) {
        if (cartModel.product.addOns != null) {
          for (AddOns addOns in cartModel.product.addOns!) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(
          cartModel.product.availableTimeStarts ?? '',
          cartModel.product.availableTimeEnds ?? ''));

      for (int index = 0; index < addOnList.length; index++) {
        _addOns = _addOns +
            ((addOnList[index].price ?? 0) *
                cartModel.addOnIds[index].quantity);
      }
      if (orderType == 'take_away') {
        _itemPrice = _itemPrice +
            ((cartModel.price + cartModel.product.takeAwayFoodPrice!) *
                cartModel.quantity);
      } else if (orderType == 'delivery') {
        _itemPrice = _itemPrice +
            ((cartModel.price + cartModel.product.deliveryFoodPrice!) *
                cartModel.quantity);
      } else {
        _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
      }
    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns;

    return _subTotal;
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    update();
  }

  void setOrderType(String orderType) {
    _orderType = orderType;
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

  void setQuantity(bool isIncrement, CartModel? cart) {
    int index = _cartList.indexOf(cart!);
    if (isIncrement) {
      _cartList[index].quantity = _cartList[index].quantity + 1;
    } else {
      _cartList[index].quantity = _cartList[index].quantity - 1;
    }

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
    _cartList = [];
    calculationCart();
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

  void removeFromCart(int? index) {
    _cartList.removeAt(index!);
    calculationCart();
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

  Future<void> placeOrder(
    String phone,
    String name,
    String note,
    String orderAmount,
    String type,
    Function callback, {
    bool isUpdate = false,
    bool isPrintKot = false,
    String? orderId,
    String? tableId,
    double? gstTax,
    double? vatTax,
    OrderList? order,
  }) async {
    Get.find<KdsController>().updateDateTime(DateTime.now().toLocal());
    _isLoading = true;
    update();
    List<Map<String, dynamic>> jsonCartList = [];
    for (var cart in cartList) {
      List<int> addOnIdList = [];
      List<int> addOnQtyList = [];
      List<AddOns> addOns = [];

      List<OrderVariation> variations = [];
      List<Variations> modifyVariation = [];
      if (cart.product.variations != null) {
        for (int i = 0; i < (cart.product.variations?.length ?? 0); i++) {
          if (cart.variation[i].contains(true)) {
            variations.add(OrderVariation(
                name: cart.product.variations?[i].name ?? '',
                values: OrderVariationValue(label: [])));

            modifyVariation.add(Variations(
                name: cart.product.variations?[i].name ?? '',
                type: cart.product.variations?[i].type,
                max: cart.product.variations?[i].max,
                min: cart.product.variations?[i].min,
                required: cart.product.variations?[i].required,
                values: []));

            for (int j = 0;
                j < (cart.product.variations?[i].values?.length ?? 0);
                j++) {
              if (cart.variation[i][j]) {
                (variations[variations.length - 1].values!.label)
                    ?.add(cart.product.variations?[i].values?[j].level ?? '');
                modifyVariation[modifyVariation.length - 1].values?.add(
                    VariationOption(
                        level:
                            cart.product.variations?[i].values?[j].level ?? '',
                        optionPrice: cart
                            .product.variations?[i].values?[j].optionPrice));
              }
            }
          }
        }
      }

      for (var i = 0; i < cart.addOnIds.length; i++) {
        addOnIdList.add(cart.addOnIds[i].id);
        addOnQtyList.add(cart.addOnIds[i].quantity);
        addOns.add(AddOns(
          id: cart.addOns[i].id,
          name: cart.addOns[i].name,
          qty: cart.addOnIds[i].quantity,
          price: cart.addOns[i].price,
        ));
      }

      var jsonData = {
        "food_id": cart.product.id,
        "quantity": cart.quantity,
        "variations": modifyVariation,
        "variation_total": 0,
        "addons_total": 0,
        "add_ons": addOns,
        'station': cart.product.stationName,
        "food_level_notes": cart.foodNote,
        "price": (cart.product.price ?? 0) > 1
            ? (order?.orderType == null
                ? cart.product.price!
                : order?.orderType == 'take_away'
                    ? (cart.product.price! + cart.product.takeAwayFoodPrice!)
                    : order?.orderType == 'delivery'
                        ? (cart.product.price! +
                            cart.product.deliveryFoodPrice!)
                        : cart.product.price)
            : (cart.adjustPrice ?? 0),
      };
      jsonCartList.add(jsonData);
    }
    Map<String, dynamic> jsonData = {
      "payment_method": "cash_on_delivery",
      "order_id": orderId,
      "order_amount": orderAmount,
      "restaurant_id": Get.find<AuthController>()
              .profileModel!
              .restaurants?[0]
              .id
              ?.toString() ??
          '',
      "user_id": '',
      "order_note": note,
      'order_type': order?.orderType,
      "table_id": tableId ?? '0',
      'cust_mobile': phone == '' ? '' : phone,
      'print_kot': isPrintKot ? 'Yes' : 'No',
      'cust_email': '',
      'cust_name': name == '' ? '' : name,
      'delivery_charge': order?.deliveryCharge,
      'gst_tax': gstTax,
      'vat_tax': vatTax,
      'tip_amount': '0',
      'def_order_status': Get.find<AuthController>()
              .profileModel
              ?.restaurants
              ?.first
              .defOrdStatus ??
          '',
      'inventory': Get.find<AuthController>()
              .profileModel
              ?.restaurants
              ?.first
              .isShowInventory ??
          false,
      'inventory_negative': Get.find<AuthController>()
              .profileModel
              ?.restaurants
              ?.first
              .isNegativeInventory ??
          false,
      "cart-update": jsonCartList,
      'printer_agent': buildPrinterAgentPayload(
        printAgents: Get.find<AuthController>().profileModel?.printAgent,
        cartStations: cartList.map((c) => c.product.stationName),
      ),
    };
    Response response = await cartRepo.waiterUpdateWalkInOrder(jsonData);
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      String orderID = response.body['order_id'].toString();
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
}
