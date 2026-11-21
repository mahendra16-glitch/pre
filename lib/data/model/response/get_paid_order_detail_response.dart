import 'dart:convert';

class GetPaidOrderDetailResponse {
  Orders? orders;

  GetPaidOrderDetailResponse({this.orders});

  GetPaidOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    orders = json['orders'] != null ? Orders.fromJson(json['orders']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.toJson();
    }
    return data;
  }
}

class GetAllPrintRoomBillsResponse {
  List<Orders>? orders;

  GetAllPrintRoomBillsResponse({this.orders});

  GetAllPrintRoomBillsResponse.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      for (var v in json['orders']) {
        orders!.add(Orders.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  OrderUser? orderUser;
  OrderDetailsOrder? orderDetailsOrder;
  List<OrderDetailsFood>? orderDetailsFood;
  List<OrderDetailsFood>? mergeFoodListWithDate;
  List<OrderDetailsFood>? mergeFoodList;
  RestaurantDetails? restaurantDetails;
  String? serviceTax;
  String? vatTax;
  String? gstTax;
  String? collectPaymentWaiter;
  double? orderTotalAmount;
  double? orderTotalAddonAmt;
  double? orderTotalVariantAmt;

  Orders({
    this.orderUser,
    this.orderDetailsOrder,
    this.orderDetailsFood,
    this.mergeFoodListWithDate,
    this.mergeFoodList,
    this.restaurantDetails,
    this.gstTax,
    this.collectPaymentWaiter,
    this.orderTotalAddonAmt,
    this.orderTotalAmount,
    this.orderTotalVariantAmt,
    this.serviceTax,
    this.vatTax,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    orderDetailsOrder = json['order_details_order'] != null
        ? OrderDetailsOrder.fromJson(json['order_details_order'])
        : null;
    if (json['order_details_bar'] != null) {
      orderDetailsFood = <OrderDetailsFood>[];
      json['order_details_bar'].forEach((v) {
        orderDetailsFood!.add(OrderDetailsFood.fromJson(v));
      });
    }
    mergeFoodListWithDate = [];
    mergeFoodList = [];
    orderUser = json['order_user'] != null
        ? OrderUser.fromJson(json['order_user'])
        : null;
    restaurantDetails = json['restaurant_details'] != null
        ? RestaurantDetails.fromJson(json['restaurant_details'])
        : null;
    serviceTax = (json['service_tax'] == null || json['service_tax'] == '')
        ? '0'
        : json['service_tax'];
    vatTax = (json['vat_tax'] == null || json['vat_tax'] == '')
        ? '0'
        : json['vat_tax'];
    gstTax = json['gst_tax'] ?? '0';
    orderTotalAmount = json['order_total_amt'] != null
        ? double.tryParse(json['order_total_amt'].toString()) ?? 0
        : 0;
    orderTotalAddonAmt = json['order_total_addon_amt'] != null
        ? double.tryParse(json['order_total_addon_amt'].toString()) ?? 0
        : 0;
    collectPaymentWaiter = json['waiter_name'] ?? '';
    orderTotalVariantAmt = json['order_total_vari_amt'] != null
        ? double.tryParse(json['order_total_vari_amt'].toString()) ?? 0
        : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderDetailsOrder != null) {
      data['order_details_order'] = orderDetailsOrder!.toJson();
    }
    if (orderDetailsFood != null) {
      data['order_details_bar'] =
          orderDetailsFood!.map((v) => v.toJson()).toList();
    }
    if (restaurantDetails != null) {
      data['restaurant_details'] = restaurantDetails!.toJson();
    }
    data['service_tax'] = serviceTax;
    data['vat_tax'] = vatTax;
    data['gst_tax'] = gstTax;
    data['waiter_name'] = collectPaymentWaiter;
    data['order_total_amt'] = orderTotalAmount;
    data['order_total_addon_amt'] = orderTotalAddonAmt;
    data['order_total_vari_amt'] = orderTotalVariantAmt;
    if (orderUser != null) {
      data['order_user'] = orderUser!.toJson();
    }
    return data;
  }
}

class OrderDetailsOrder {
  int? id;
  int? userId;
  String? restaurantOrderId;
  String? username;
  int? employeeId;
  double? orderAmount;
  int? couponDiscountAmount;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? transactionReference;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  LoyaltyInfo? loyaltyInfo;
  CouponInfo? couponInfo;
  WalletInfo? walletInfo;
  int? scheduled;
  double? restaurantDiscountAmount;
  double? tipAmount;
  int? originalDeliveryCharge;
  String? adjusment;
  int? edited;
  int? dmTips;

  String? discountOnProductBy;
  int? distance;

  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  int? bOrderStatus;
  int? kOrderStatus;
  String? totalVatTaxAmount;
  String? totalGstTaxAmount;
  String? totalServiceTaxAmount;
  double? orderSubTotalAmount;
  double? orderSubTotalAmountWithoutTax;
  int? bItem;
  int? kItem;
  Restaurant? restaurant;

  OrderDetailsOrder({
    this.id,
    this.userId,
    this.restaurantOrderId,
    this.username,
    this.employeeId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.transactionReference,
    this.orderNote,
    this.orderType,
    this.checked,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.loyaltyInfo,
    this.couponInfo,
    this.walletInfo,
    this.deliveryCharge,
    this.scheduled,
    this.restaurantDiscountAmount,
    this.tipAmount,
    this.originalDeliveryCharge,
    this.adjusment,
    this.edited,
    this.dmTips,
    this.discountOnProductBy,
    this.distance,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.bOrderStatus,
    this.kOrderStatus,
    this.totalVatTaxAmount,
    this.totalGstTaxAmount,
    this.totalServiceTaxAmount,
    this.bItem,
    this.kItem,
    this.restaurant,
    this.orderSubTotalAmount,
    this.orderSubTotalAmountWithoutTax,
  });

  OrderDetailsOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    restaurantOrderId = (json['restaurant_order_id'] == null ||
            json['restaurant_order_id'] == '')
        ? '0'
        : '${json['restaurant_order_id']}';
    username = json['user_name'] ?? '';
    employeeId = json['employee_id'];
    orderAmount = (json['order_amount'] != null)
        ? (json['order_amount'] is double
            ? json['order_amount']
            : double.tryParse(json['order_amount'].toString()) ?? 0)
        : 0;
    couponDiscountAmount = json['coupon_discount_amount'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = (json['total_tax_amount'] != null)
        ? (json['total_tax_amount'] is double
            ? json['total_tax_amount']
            : double.tryParse(json['total_tax_amount'].toString()) ?? 0)
        : 0;
    paymentMethod = json['payment_method'];
    transactionReference = json['transaction_reference'];
    tipAmount = double.tryParse(
            '${json['tip_amount'] == null || json['tip_amount'] == '' ? 0 : json['tip_amount']}')
        ?.toDouble();
    orderNote = json['order_note'] ?? '';
    orderType = json['order_type'];
    checked = json['checked'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = double.tryParse('${json['delivery_charge'] ?? 0}') ?? 0;
    scheduled = json['scheduled'];
    restaurantDiscountAmount = (json['restaurant_discount_amount'] != null)
        ? (json['restaurant_discount_amount'] is double
            ? json['restaurant_discount_amount']
            : double.tryParse(json['restaurant_discount_amount'].toString()) ??
                0)
        : 0;
    originalDeliveryCharge = json['original_delivery_charge'] ?? 0;
    adjusment = json['adjusment'];
    edited = json['edited'];
    dmTips = json['dm_tips'];
    discountOnProductBy = json['discount_on_product_by'];
    distance = json['distance'];
    tableId = json['table_id'];
    waiterId = json['waiter_id'];
    fOrderStatus = json['f_order_status'];
    bOrderStatus = json['b_order_status'];
    kOrderStatus = json['k_order_status'];
    loyaltyInfo = json['loyalty_info'] != null
        ? new LoyaltyInfo.fromJson(json['loyalty_info'])
        : null;
    couponInfo = json['coupon_info'] != null
        ? new CouponInfo.fromJson(json['coupon_info'])
        : null;
    walletInfo = json['wallet_info'] != null
        ? (WalletInfo.fromJson(json['wallet_info']))
        : null;
    totalVatTaxAmount = json['total_vat_tax_amount']?.toString() ?? '0';
    totalGstTaxAmount = json['total_gst_tax_amount']?.toString() ?? '0';
    totalServiceTaxAmount = json['total_service_tax_amount']?.toString() ?? '0';
    bItem = json['b_item'];
    kItem = json['k_item'];
    restaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'])
        : null;
    orderSubTotalAmount =
        double.tryParse(json['order_sub_total_amount'].toString()) ?? 0.0;

    orderSubTotalAmountWithoutTax =
        double.tryParse(json['order_sub_total_without_tax'].toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['employee_id'] = employeeId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['payment_status'] = paymentStatus;
    data['restaurant_order_id'] = restaurantOrderId;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['transaction_reference'] = transactionReference;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['checked'] = checked;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['scheduled'] = scheduled;
    data['restaurant_discount_amount'] = restaurantDiscountAmount;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['adjusment'] = adjusment;
    data['edited'] = edited;
    data['dm_tips'] = dmTips;
    data['discount_on_product_by'] = discountOnProductBy;
    data['distance'] = distance;
    data['table_id'] = tableId;
    data['waiter_id'] = waiterId;
    data['user_name'] = username;
    data['f_order_status'] = fOrderStatus;
    data['b_order_status'] = bOrderStatus;
    data['k_order_status'] = kOrderStatus;
    data['total_vat_tax_amount'] = totalVatTaxAmount;
    data['total_gst_tax_amount'] = totalGstTaxAmount;
    data['total_service_tax_amount'] = totalServiceTaxAmount;
    data['b_item'] = bItem;
    data['k_item'] = kItem;
    data['order_sub_total_without_tax'] = orderSubTotalAmountWithoutTax;
    data['order_sub_total_amount'] = orderSubTotalAmount;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  int? vendorId;
  bool? gstStatus;
  String? gstCode;

  Restaurant({this.id, this.name, this.vendorId, this.gstStatus, this.gstCode});

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    vendorId = json['vendor_id'];
    gstStatus = json['gst_status'] is bool
        ? json['gst_status']
        : json['gst_status'] == 1 || json['gst_status'] == '1';
    gstCode = json['gst_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['vendor_id'] = vendorId;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    return data;
  }
}

class OrderDetailsFood {
  int? id;
  int? foodId;
  int? orderId;
  dynamic price;
  double? unitPrice;
  FoodDetails? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? gstTaxAmount;
  String? createdAt;
  String? updatedAt;
  int? totalAddOnPrice;
  int? foodStatus;
  int? isComplementary;
  String? itemType;

  OrderDetailsFood({
    this.id,
    this.foodId,
    this.orderId,
    this.price,
    this.unitPrice,
    this.foodDetails,
    this.variation,
    this.addOns,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.gstTaxAmount,
    this.createdAt,
    this.updatedAt,
    this.totalAddOnPrice,
    this.isComplementary,
    this.foodStatus,
    this.itemType,
  });

  OrderDetailsFood.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = json['price'];
    unitPrice = double.parse('${json['unit_price'] ?? 0}');
    foodDetails = json['food_details'] != null
        ? FoodDetails.fromJson(json['food_details'])
        : null;
    variation = [];
    if (json['variation'] != null) {
      variation = <Variations>[];
      for (var v in json['variation']) {
        variation!.add(Variations.fromJson(v));
      }
    }
    addOns = [];

    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      for (var v in json['add_ons']) {
        addOns!.add(AddOns.fromJson(v));
      }
    }
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = double.parse('${json['tax_amount'] ?? 0}');
    gstTaxAmount = json['gst_tax_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalAddOnPrice = json['total_add_on_price'];
    foodStatus = json['food_status'];
    isComplementary = json['complementary'] ?? 0;
    itemType = json['item_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (foodDetails != null) {
      data['food_details'] = foodDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['gst_tax_amount'] = gstTaxAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['total_add_on_price'] = totalAddOnPrice;
    data['food_status'] = foodStatus;
    data['item_type'] = itemType;
    return data;
  }
}

class FoodDetails {
  int? id;
  String? name;
  String? description;
  String? image;
  // int? categoryId;
  // List<CategoryIds>? categoryIds;
  // List<Variations>? variations;
  // List<AddOns>? addOns;
  String? attributes;
  String? choiceOptions;
  double? price;
  int? tax;
  String? taxType;
  int? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? veg;
  int? status;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  int? orderCount;
  int? avgRating;
  int? ratingCount;
  int? recommended;
  String? slug;
  int? foodStatus;
  int? foodStock;
  String? restaurantName;
  int? restaurantStatus;
  int? restaurantDiscount;
  bool? scheduleOrder;
  int? freeDelivery;
  int? minDeliveryTime;
  int? maxDeliveryTime;
  List<Cuisines>? cuisines;

  FoodDetails({
    this.id,
    this.name,
    this.description,
    this.image,
    // this.categoryId,
    // this.categoryIds,
    // this.variations,
    // this.addOns,
    this.attributes,
    this.choiceOptions,
    this.price,
    this.tax,
    this.taxType,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.veg,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.orderCount,
    this.avgRating,
    this.ratingCount,
    this.recommended,
    this.slug,
    this.foodStatus,
    this.foodStock,
    this.restaurantName,
    this.restaurantStatus,
    this.restaurantDiscount,
    this.scheduleOrder,
    this.freeDelivery,
    this.minDeliveryTime,
    this.maxDeliveryTime,
    this.cuisines,
  });

  FoodDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    // categoryId = json['category_id'];
    // if (json['category_ids'] != null) {
    //   categoryIds = <CategoryIds>[];
    //   json['category_ids'].forEach((v) {
    //     categoryIds!.add(CategoryIds.fromJson(v));
    //   });
    // }
    // if (json['variations'] != null) {
    //   variations = <Variations>[];
    //   json['variations'].forEach((v) {
    //     variations!.add(Variations.fromJson(v));
    //   });
    // }
    // if (json['add_ons'] != null) {
    //   addOns = <AddOns>[];
    //   json['add_ons'].forEach((v) {
    //     addOns!.add(AddOns.fromJson(v));
    //   });
    // }
    attributes = json['attributes'];
    choiceOptions = json['choice_options'];
    price =
        json['price'] != null ? double.tryParse('${json['price']}') ?? 0 : 0;
    tax = json['tax'];
    taxType = json['tax_type'];
    discount = json['discount'];
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    veg = json['veg'];
    status = json['status'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderCount = json['order_count'];
    avgRating = json['avg_rating'];
    ratingCount = json['rating_count'];
    recommended = json['recommended'];
    slug = json['slug'];
    foodStatus = json['food_status'];
    foodStock = json['food_stock'];
    restaurantName = json['restaurant_name'];
    restaurantStatus = json['restaurant_status'];
    restaurantDiscount = json['restaurant_discount'];
    scheduleOrder = json['schedule_order'] is bool
        ? json['schedule_order']
        : json['schedule_order'] == 1 || json['schedule_order'] == '1';
    freeDelivery = json['free_delivery'];
    minDeliveryTime = json['min_delivery_time'];
    maxDeliveryTime = json['max_delivery_time'];
    if (json['cuisines'] != null) {
      cuisines = <Cuisines>[];
      for (var v in json['cuisines']) {
        cuisines!.add(Cuisines.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    // data['category_id'] = categoryId;
    // if (categoryIds != null) {
    //   data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    // }
    // if (variations != null) {
    //   data['variations'] = variations!.map((v) => v.toJson()).toList();
    // }
    // if (addOns != null) {
    //   data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    // }
    data['attributes'] = attributes;
    data['choice_options'] = choiceOptions;
    data['price'] = price;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['veg'] = veg;
    data['status'] = status;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['order_count'] = orderCount;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['recommended'] = recommended;
    data['slug'] = slug;
    data['food_status'] = foodStatus;
    data['food_stock'] = foodStock;
    data['restaurant_name'] = restaurantName;
    data['restaurant_status'] = restaurantStatus;
    data['restaurant_discount'] = restaurantDiscount;
    data['schedule_order'] = scheduleOrder;
    data['free_delivery'] = freeDelivery;
    data['min_delivery_time'] = minDeliveryTime;
    data['max_delivery_time'] = maxDeliveryTime;
    if (cuisines != null) {
      data['cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryIds {
  String? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    position = json['position'] is int
        ? json['position']
        : int.tryParse(json['position']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class Variations {
  String? name;
  String? type;
  String? min;
  String? max;
  String? required;
  List<Values>? values;

  Variations({
    this.name,
    this.type,
    this.min,
    this.max,
    this.required,
    this.values,
  });

  Variations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    min = "${json['min']}";
    max = "${json['max']}";
    required = json['required'];
    if (json['values'] != null) {
      values = <Values>[];
      for (var v in json['values']) {
        values!.add(Values.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  String? label;
  String? optionPrice;

  Values({this.label, this.optionPrice});

  Values.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    optionPrice = json['optionPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['optionPrice'] = optionPrice;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;
  int? quantity;

  AddOns({this.id, this.name, this.price, this.quantity});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = double.tryParse('${json['price'] ?? 0}') ?? 0;
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class Cuisines {
  int? id;
  String? name;
  String? image;

  Cuisines({this.id, this.name, this.image});

  Cuisines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class RestaurantDetails {
  String? restaurantTableNo;
  String? restaurantTableArea;
  String? restaurantWaiterName;

  RestaurantDetails({
    this.restaurantTableNo,
    this.restaurantTableArea,
    this.restaurantWaiterName,
  });

  RestaurantDetails.fromJson(Map<String, dynamic> json) {
    restaurantTableNo = json['restaurant_table_no'] ?? '';
    restaurantTableArea = json['restaurant_table_area'] ?? '';
    restaurantWaiterName = json['restaurant_waiter_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_table_no'] = restaurantTableNo;
    data['restaurant_table_area'] = restaurantTableArea;
    data['restaurant_waiter_name'] = restaurantWaiterName;
    return data;
  }
}

class OrderUser {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;
  int? isPhoneVerified;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? cmFirebaseToken;
  int? status;
  dynamic orderCount;
  String? loginMedium;
  dynamic socialId;
  dynamic zoneId;
  dynamic walletBalance;
  dynamic loyaltyPoint;
  String? refCode;
  int? refBy;
  String? tempToken;
  double? discount;

  OrderUser({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.isPhoneVerified,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.cmFirebaseToken,
    this.status,
    this.orderCount,
    this.loginMedium,
    this.socialId,
    this.zoneId,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.refBy,
    this.tempToken,
    this.discount,
  });

  OrderUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'] ?? '';
    lName = json['l_name'] ?? '';
    phone = json['phone'] ?? '';
    email = json['email'] == null || json['email'] == 'order@mygenie.com'
        ? ''
        : json['email'];
    image = json['image'];
    isPhoneVerified = json['is_phone_verified'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cmFirebaseToken = json['cm_firebase_token'];
    status = json['status'];
    orderCount = json['order_count'];
    loginMedium = json['login_medium'];
    socialId = json['social_id'];
    zoneId = json['zone_id'];
    walletBalance = json['wallet_balance'];
    loyaltyPoint = json['loyalty_point'];
    refCode = json['ref_code'];
    refBy = json['ref_by'];
    tempToken = json['temp_token'];
    discount = (json['discount'] != null)
        ? (json['discount'] is double
            ? json['discount']
            : double.tryParse(json['discount'].toString()) ?? 0)
        : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image'] = image;
    data['is_phone_verified'] = isPhoneVerified;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['cm_firebase_token'] = cmFirebaseToken;
    data['status'] = status;
    data['order_count'] = orderCount;
    data['login_medium'] = loginMedium;
    data['social_id'] = socialId;
    data['zone_id'] = zoneId;
    data['wallet_balance'] = walletBalance;
    data['loyalty_point'] = loyaltyPoint;
    data['ref_code'] = refCode;
    data['ref_by'] = refBy;
    data['temp_token'] = tempToken;
    data['discount'] = discount;
    return data;
  }
}

class LoyaltyInfo {
  bool? earned;
  bool? redeemed;
  String? appliedAt;
  double? orderSubTotal;
  double? redeemedAmount;

  LoyaltyInfo(
      {this.earned,
      this.redeemed,
      this.appliedAt,
      this.orderSubTotal,
      this.redeemedAmount});

  LoyaltyInfo.fromJson(Map<String, dynamic> json) {
    earned = json['earned'];
    redeemed = json['redeemed'] ?? false;
    appliedAt = json['applied_at'];
    orderSubTotal = double.parse('${json['order_sub_total'] ?? 0}');
    redeemedAmount = double.parse('${json['redeemed_amount'] ?? 0}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['earned'] = this.earned;
    data['redeemed'] = this.redeemed;
    data['applied_at'] = this.appliedAt;
    data['order_sub_total'] = this.orderSubTotal;
    data['redeemed_amount'] = this.redeemedAmount;
    return data;
  }
}

class CouponInfo {
  bool? applied;
  int? usageId;
  String? appliedAt;
  String? couponType;
  String? couponTitle;
  double? couponAmount;
  int? couponCreatedBy;

  CouponInfo(
      {this.applied,
      this.usageId,
      this.appliedAt,
      this.couponType,
      this.couponTitle,
      this.couponAmount,
      this.couponCreatedBy});

  CouponInfo.fromJson(Map<String, dynamic> json) {
    applied = json['applied'] ?? false;
    usageId = json['usage_id'];
    appliedAt = json['applied_at'];
    couponType = json['coupon_type'];
    couponTitle = json['coupon_title'] ?? '';
    couponAmount = double.parse('${json['coupon_amount'] ?? 0}');
    couponCreatedBy = json['coupon_created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applied'] = this.applied;
    data['usage_id'] = this.usageId;
    data['applied_at'] = this.appliedAt;
    data['coupon_type'] = this.couponType;
    data['coupon_title'] = this.couponTitle;
    data['coupon_amount'] = this.couponAmount;
    data['coupon_created_by'] = this.couponCreatedBy;
    return data;
  }
}

class WalletInfo {
  String? note;
  double? amount;
  bool? applied;
  int? walletId;
  String? appliedAt;
  String? balanceAfter;

  WalletInfo(
      {this.note,
      this.amount,
      this.applied,
      this.walletId,
      this.appliedAt,
      this.balanceAfter});

  WalletInfo.fromJson(Map<String, dynamic> json) {
    note = json['note'];
    amount = double.parse('${json['amount'] ?? 0}');
    applied = json['applied'] ?? false;
    walletId = json['wallet_id'];
    appliedAt = json['applied_at'];
    balanceAfter = '${json['balance_after'] ?? 0}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['note'] = this.note;
    data['amount'] = this.amount;
    data['applied'] = this.applied;
    data['wallet_id'] = this.walletId;
    data['applied_at'] = this.appliedAt;
    data['balance_after'] = this.balanceAfter;
    return data;
  }
}
