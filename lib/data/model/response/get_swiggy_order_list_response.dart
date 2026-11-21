import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class OrderDetailsOrder {
  final int id;
  final String restaurantOrderId;
  final String userName;
  final String orderStatus;
  final double orderAmount;
  final double itemTotal;
  final String paymentStatus;
  final String orderType;
  final String orderNote;
  final String urbanOrderId;
  final String aggregatorOrderId;
  final String orderPlateform;
  final double? totaTaxAmount;
  final String otp;
  final String createdAt;
  String? readyAt;
  final String? riderName;
  final String? riderPhone;
  String? preparationTime;
  String? scheduleAt;
  String? serveAt;
  String? handover;
  String? cancelReason;
  final double? subTotal;
  final double? gstTax;
  final double? orderDiscount;
  final double? tipAmount;
  final double? charges;
  String? couponCode;
  final double? couponDiscount;
  final double? deliveryCharge;
  final double? packingCharge;
  int fOrderStatus;

  OrderDetailsOrder({
    required this.id,
    required this.restaurantOrderId,
    required this.userName,
    required this.orderStatus,
    required this.orderAmount,
    required this.itemTotal,
    required this.paymentStatus,
    required this.orderType,
    required this.orderNote,
    required this.urbanOrderId,
    required this.aggregatorOrderId,
    required this.orderPlateform,
    required this.totaTaxAmount,
    required this.otp,
    required this.createdAt,
    required this.fOrderStatus,
    this.riderName,
    this.riderPhone,
    this.preparationTime,
    this.scheduleAt,
    this.serveAt,
    this.handover,
    this.cancelReason,
    this.readyAt,
    this.subTotal,
    this.gstTax,
    this.orderDiscount,
    this.tipAmount,
    this.charges,
    this.couponCode,
    this.couponDiscount,
    this.deliveryCharge,
    this.packingCharge,
  });

  factory OrderDetailsOrder.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return OrderDetailsOrder(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      restaurantOrderId: json['restaurant_order_id'] ?? '',
      preparationTime: json['prep_time_mins']?.toString(),
      userName: json['user_name'] ?? '',
      scheduleAt: json['schedule_at']?.toString(),
      serveAt: json['serve_at']?.toString(),
      readyAt: json['ready_at']?.toString(),
      orderStatus: json['order_status'] ?? '',
      orderAmount: _parseDouble(json['order_amount']) ?? 0.0,
      itemTotal: _parseDouble(json['item_total']) ?? 0.0,
      paymentStatus: json['payment_status'] ?? '',
      orderType: json['order_type'] ?? '',
      orderNote: json['order_note'] ?? '',
      cancelReason: json['f_order_reason_code'] ?? '',
      urbanOrderId: json['urban_order_id'] ?? '',
      aggregatorOrderId: json['aggrigator_id'] ?? '',
      orderPlateform: json['order_plateform'] ?? '',
      subTotal: _parseDouble(json['order_subtotal']),
      orderDiscount: _parseDouble(json['order_discount']),
      gstTax: _parseDouble(json['total_gst_tax_amount']),
      charges: _parseDouble(json['total_service_tax_amount']),
      tipAmount: _parseDouble(json['tip_amount']),
      riderName: json['rider_name']?.toString(),
      riderPhone: json['rider_phone_number']?.toString(),
      totaTaxAmount: _parseDouble(json['total_tax_amount']),
      otp: json['otp'] ?? '',
      handover: json['handover'] ?? '',
      createdAt: json['created_at'] ?? '',
      fOrderStatus: json['f_order_status'] is int
          ? json['f_order_status']
          : int.tryParse(json['f_order_status']?.toString() ?? '') ?? 1,
      couponCode: json['coupon_code']?.toString() ?? '',
      couponDiscount: _parseDouble(json['coupon_discount_amount']) ?? 0,
      deliveryCharge: _parseDouble(json['delivery_charge']) ?? 0,
      packingCharge: _parseDouble(json['packing_charge']) ?? 0,
    );
  }
}

class CustomerDetails {
  final String phone;
  final String name;
  final String email;
  final CustomerDetailsAddress address;

  CustomerDetails({
    required this.phone,
    required this.name,
    required this.email,
    required this.address,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: CustomerDetailsAddress.fromJson(json['address'] ?? {}),
    );
  }
}

class OrderFoodDetails {
  final String title;
  final int id;
  final double price;
  final double taxAmount;
  final int quantity;
  final String imageUrl;
  final String foodLevelNotes;
  final String station;
  final List<Variations> variation;
  final List<AggregatorAddon> addOns;
  final String createdAt;

  OrderFoodDetails({
    required this.title,
    required this.id,
    required this.price,
    required this.taxAmount,
    required this.quantity,
    required this.imageUrl,
    required this.foodLevelNotes,
    required this.station,
    required this.variation,
    required this.addOns,
    required this.createdAt,
  });

  factory OrderFoodDetails.fromJson(Map<String, dynamic> json) {
    final foodDetails = json['food_details'] ?? {};
    return OrderFoodDetails(
      title: foodDetails['title'] ?? '',
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      price: (json['price'] != null && foodDetails['json'] is num
              ? json['price']
              : double.tryParse(json['price']?.toString() ?? '') ?? 0.0)
          .toDouble(),
      taxAmount: (json['tax_amount'] != null && json['tax_amount'] is num
              ? json['tax_amount']
              : double.tryParse(json['tax_amount']?.toString() ?? '') ?? 0.0)
          .toDouble(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      imageUrl: foodDetails['image_url'] ?? '',
      foodLevelNotes: json['food_level_notes'] ?? '',
      station: json['station'] ?? '',
      variation: (json['variation'] as List<dynamic>?)
              ?.map((v) => Variations.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      addOns: (foodDetails['options_to_add'] as List<dynamic>?)
              ?.map((v) => AggregatorAddon.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class CustomerDetailsAddress {
  final String city;
  final String line1;
  final String subLocality;
  final String tag;
  final String landmark;
  final String pin;

  CustomerDetailsAddress({
    required this.city,
    required this.line1,
    required this.subLocality,
    required this.tag,
    required this.landmark,
    required this.pin,
  });

  factory CustomerDetailsAddress.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsAddress(
      city: json['city'] ?? '',
      line1: json['line_1'] ?? '',
      subLocality: json['sub_locality'] ?? '',
      tag: json['tag'] ?? '',
      landmark: json['landmark'] ?? '',
      pin: json['pin'] ?? '',
    );
  }
}

class RiderInfo {
  final int id;
  final String phone;
  final String name;
  final String orderReturnOtp;
  final String bagReturnOtp;

  RiderInfo({
    required this.id,
    required this.phone,
    required this.name,
    required this.orderReturnOtp,
    required this.bagReturnOtp,
  });

  factory RiderInfo.fromJson(Map<String, dynamic> json) {
    return RiderInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      phone: json['Phone'] ?? '',
      name: json['name'] ?? '',
      orderReturnOtp: json['order_return_otp'] ?? '',
      bagReturnOtp: json['bag_return_otp'] ?? '',
    );
  }
}

class Order {
  final OrderDetailsOrder orderDetailsOrder;
  final CustomerDetails customerDetails;
  final String? brandName;
  RiderInfo? riderInfo;
  final List<OrderFoodDetails> orderDetailsFood;

  Order({
    required this.orderDetailsOrder,
    required this.customerDetails,
    this.riderInfo,
    this.brandName,
    required this.orderDetailsFood,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      brandName: json['brand_name'] ?? '',
      orderDetailsOrder:
          OrderDetailsOrder.fromJson(json['order_details_order'] ?? {}),
      customerDetails: CustomerDetails.fromJson(json['customer_details'] ?? {}),
      riderInfo: RiderInfo.fromJson(json['rider_info'] ?? {}),
      orderDetailsFood: (json['order_details_food'] as List<dynamic>? ?? [])
          .map((e) => OrderFoodDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AggregatorAddon {
  int? id;
  String? merchantId;
  String? title;
  int? price;
  int? quantity;
  int? totalPrice;
  Group? group;

  AggregatorAddon(
      {this.id,
      this.merchantId,
      this.title,
      this.price,
      this.quantity,
      this.totalPrice,
      this.group});

  AggregatorAddon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchantId = json['merchant_id'];
    title = json['title'];
    price = json['price'];
    quantity = json['quantity'];
    totalPrice = json['total_price'];
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['merchant_id'] = this.merchantId;
    data['title'] = this.title;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['total_price'] = this.totalPrice;
    if (this.group != null) {
      data['group'] = this.group!.toJson();
    }
    return data;
  }
}

class Group {
  int? id;
  String? title;
  bool? isVariant;

  Group({this.id, this.title, this.isVariant});

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    isVariant = json['is_variant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['is_variant'] = this.isVariant;
    return data;
  }
}
