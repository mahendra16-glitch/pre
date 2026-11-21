class PlaceOrderBody {
  List<Cart> cart;
  String? orderNote;
  int restaurantId;
  double discount;
  String? discountType;
  double tax;
  double paidAmount;
  String? paymentMethod;

  PlaceOrderBody({
    required this.cart,
    this.orderNote,
    required this.restaurantId,
    required this.discount,
    this.discountType,
    required this.tax,
    required this.paidAmount,
    this.paymentMethod,
  });

  factory PlaceOrderBody.fromJson(Map<String, dynamic> json) {
    return PlaceOrderBody(
      cart: (json['cart'] as List<dynamic>?)
              ?.map((v) => Cart.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      orderNote: json['order_note'] as String?,
      restaurantId: json['restaurant_id'] as int,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String?,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart': cart.map((v) => v.toJson()).toList(),
      'order_note': orderNote,
      'restaurant_id': restaurantId,
      'discount': discount,
      'discount_type': discountType,
      'tax': tax,
      'paid_amount': paidAmount,
      'payment_method': paymentMethod,
    };
  }
}

class Cart {
  int foodId;
  int? itemCampaignId;
  double price;
  List<String> variant;
  List<Variation> variation;
  double discountAmount;
  int quantity;
  double taxAmount;
  List<int> addOnIds;
  List<int> addOnQtys;

  Cart({
    required this.foodId,
    this.itemCampaignId,
    required this.price,
    required this.variant,
    required this.variation,
    required this.discountAmount,
    required this.quantity,
    required this.taxAmount,
    required this.addOnIds,
    required this.addOnQtys,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      foodId: json['food_id'] as int,
      itemCampaignId: json['item_campaign_id'] as int?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      variant: (json['variant'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      variation: (json['variation'] as List<dynamic>?)
              ?.map((v) => Variation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      addOnIds: (json['add_on_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      addOnQtys: (json['add_on_qtys'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'item_campaign_id': itemCampaignId,
      'price': price,
      'variant': variant,
      'variation': variation.map((v) => v.toJson()).toList(),
      'discount_amount': discountAmount,
      'quantity': quantity,
      'tax_amount': taxAmount,
      'add_on_ids': addOnIds,
      'add_on_qtys': addOnQtys,
    };
  }
}

class Variation {
  String type;
  double price;

  Variation({
    required this.type,
    required this.price,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      type: json['type'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'price': price,
    };
  }
}
