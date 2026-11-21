// import 'dart:convert';

// import 'package:mygenie_restaurant/data/model/response/product_model.dart';

// class PlaceOrderBody {
//   List<Cart> _cart;
//   double _orderAmount;
//   String _orderType;
//   String _paymentMethod;
//   String _orderNote;
//   String _couponCode;
//   int _restaurantId;
//   double _distance;
//   String _scheduleAt;
//   double _discountAmount;
//   double _taxAmount;
//   String _address;
//   String _latitude;
//   String _longitude;
//   String _contactPersonName;
//   String _contactPersonNumber;
//   String _addressType;
//   String _road;
//   String _house;
//   String _floor;
//   String _dmTips;

//   PlaceOrderBody({
//     List<Cart> cart,
//     double couponDiscountAmount,
//     String couponDiscountTitle,
//     String couponCode,
//     double orderAmount,
//     String orderType,
//     String paymentMethod,
//     int restaurantId,
//     double distance,
//     String scheduleAt,
//     double discountAmount,
//     double taxAmount,
//     String orderNote,
//     String address,
//     String latitude,
//     String longitude,
//     String contactPersonName,
//     String contactPersonNumber,
//     String addressType,
//     String road,
//     String house,
//     String floor,
//     String dmTips,
//   }) {
//     _cart = cart;
//     _couponDiscountAmount = couponDiscountAmount;
//     _couponDiscountTitle = couponDiscountTitle;
//     _orderAmount = orderAmount;
//     _orderType = orderType;
//     _paymentMethod = paymentMethod;
//     _orderNote = orderNote;
//     _couponCode = couponCode;
//     _restaurantId = restaurantId;
//     _distance = distance;
//     _scheduleAt = scheduleAt;
//     _discountAmount = discountAmount;
//     _taxAmount = taxAmount;
//     _address = address;
//     _latitude = latitude;
//     _longitude = longitude;
//     _contactPersonName = contactPersonName;
//     _contactPersonNumber = contactPersonNumber;
//     _addressType = addressType;
//     _road = road;
//     _house = house;
//     _floor = floor;
//     _dmTips = dmTips;
//   }

//   List<Cart> get cart => _cart;
//   double get couponDiscountAmount => _couponDiscountAmount;
//   String get couponDiscountTitle => _couponDiscountTitle;
//   double get orderAmount => _orderAmount;
//   String get orderType => _orderType;
//   String get paymentMethod => _paymentMethod;
//   String get orderNote => _orderNote;
//   String get couponCode => _couponCode;
//   int get restaurantId => _restaurantId;
//   double get distance => _distance;
//   String get scheduleAt => _scheduleAt;
//   double get discountAmount => _discountAmount;
//   double get taxAmount => _taxAmount;
//   String get address => _address;
//   String get latitude => _latitude;
//   String get longitude => _longitude;
//   String get contactPersonName => _contactPersonName;
//   String get contactPersonNumber => _contactPersonNumber;
//   String get road => _road;
//   String get house => _house;
//   String get floor => _floor;
//   String get dmTips => _dmTips;

//   PlaceOrderBody.fromJson(Map<String, dynamic> json) {
//     if (json['cart'] != null) {
//       _cart = [];
//       json['cart'].forEach((v) {
//         _cart.add(Cart.fromJson(v));
//       });
//     }
//     _couponDiscountAmount = json['coupon_discount_amount'];
//     _couponDiscountTitle = json['coupon_discount_title'];
//     _orderAmount = json['order_amount'];
//     _orderType = json['order_type'];
//     _paymentMethod = json['payment_method'];
//     _orderNote = json['order_note'];
//     _couponCode = json['coupon_code'];
//     _restaurantId = json['restaurant_id'];
//     _distance = json['distance'];
//     _scheduleAt = json['schedule_at'];
//     _discountAmount = json['discount_amount'].toDouble();
//     _taxAmount = json['tax_amount'].toDouble();
//     _address = json['address'];
//     _latitude = json['latitude'];
//     _longitude = json['longitude'];
//     _contactPersonName = json['contact_person_name'];
//     _contactPersonNumber = json['contact_person_number'];
//     _addressType = json['address_type'];
//     _road = json['road'];
//     _house = json['house'];
//     _floor = json['floor'];
//     _dmTips = json['dm_tips'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (_cart != null) {
//       data['cart'] = _cart.map((v) => v.toJson()).toList();
//     }
//     data['coupon_discount_amount'] = _couponDiscountAmount;
//     data['coupon_discount_title'] = _couponDiscountTitle;
//     data['order_amount'] = _orderAmount;
//     data['order_type'] = _orderType;
//     data['payment_method'] = _paymentMethod;
//     data['order_note'] = _orderNote;
//     data['coupon_code'] = _couponCode;
//     data['restaurant_id'] = _restaurantId;
//     data['distance'] = _distance;
//     data['schedule_at'] = _scheduleAt;
//     data['discount_amount'] = _discountAmount;
//     data['tax_amount'] = _taxAmount;
//     data['address'] = _address;
//     data['latitude'] = _latitude;
//     data['longitude'] = _longitude;
//     data['contact_person_name'] = _contactPersonName;
//     data['contact_person_number'] = _contactPersonNumber;
//     data['address_type'] = _addressType;
//     data['road'] = _road;
//     data['house'] = _house;
//     data['floor'] = _floor;
//     data['dm_tips'] = _dmTips;
//   }
// }

// class Cart {
//   int _foodId;
//   int _itemCampaignId;
//   String _price;
//   String _variant;
//   int _quantity;
//   List<int> _addOnIds;
//   List<AddOns> _addOns;
//   List<int> _addOnQtys;

//   Cart(
//       int foodId,
//       int itemCampaignId,
//       String price,
//       String variant,
//       int quantity,
//       List<int> addOnIds,
//       List<AddOns> addOns,
//       List<int> addOnQtys) {
//     _foodId = foodId;
//     _itemCampaignId = itemCampaignId;
//     _price = price;
//     _variant = variant;
//     _quantity = quantity;
//     _addOnIds = addOnIds;
//     _addOns = addOns;
//     _addOnQtys = addOnQtys;
//   }

//   int get foodId => _foodId;
//   int get itemCampaignId => _itemCampaignId;
//   String get price => _price;
//   String get variant => _variant;
//   int get quantity => _quantity;
//   List<int> get addOnIds => _addOnIds;
//   List<AddOns> get addOns => _addOns;
//   List<int> get addOnQtys => _addOnQtys;

//   Cart.fromJson(Map<String, dynamic> json) {
//     _foodId = json['food_id'];
//     _itemCampaignId = json['item_campaign_id'];
//     _price = json['price'];
//     _variant = json['variant'];

//     _quantity = json['quantity'];
//     _addOnIds = json['add_on_ids'].cast<int>();
//     if (json['add_ons'] != null) {
//       _addOns = [];
//       json['add_ons'].forEach((v) {
//         _addOns.add(AddOns.fromJson(v));
//       });
//     }
//     _addOnQtys = json['add_on_qtys'].cast<int>();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['food_id'] = _foodId;
//     data['item_campaign_id'] = _itemCampaignId;
//     data['price'] = _price;
//     data['variant'] = _variant;

//     data['quantity'] = _quantity;
//     data['add_on_ids'] = _addOnIds;
//     if (_addOns != null) {
//       data['add_ons'] = _addOns.map((v) => v.toJson()).toList();
//     }
//     data['add_on_qtys'] = _addOnQtys;
//     return data;
//   }
// }
