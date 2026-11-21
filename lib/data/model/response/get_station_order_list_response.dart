import 'package:mygenie_restaurant/data/model/response/product_model.dart';

import 'get_waiter_order_list_response.dart';

class GetStationOrderListResponse {
  List<Orders>? orders;
  Count? statusCounts;

  GetStationOrderListResponse({this.orders, this.statusCounts});

  GetStationOrderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    statusCounts = json['status_counts'] != null
        ? Count.fromJson(json['status_counts'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    if (statusCounts != null) {
      data['status_counts'] = statusCounts!.toJson();
    }
    return data;
  }
}

class Orders {
  OrderDetailsOrder? orderDetailsOrder;
  List<OrderDetailsFood>? orderDetailsFood;
  List<OrderDetailsFood>? readyDetails;
  RestaurantDetails? restaurantTable;
  User? user;
  DeliveryAddress? deliveryAddress;

  Orders({
    this.orderDetailsOrder,
    this.orderDetailsFood,
    this.readyDetails,
    this.restaurantTable,
    this.user,
    this.deliveryAddress,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;

    orderDetailsOrder = json['order_details_order'] != null
        ? OrderDetailsOrder.fromJson(json['order_details_order'])
        : null;
    if (json['order_details_food'] != null) {
      orderDetailsFood = <OrderDetailsFood>[];
      json['order_details_food'].forEach((v) {
        orderDetailsFood!.add(OrderDetailsFood.fromJson(v));
      });
    }
    if (json['ready_order_details'] != null) {
      readyDetails = <OrderDetailsFood>[];
      json['ready_order_details'].forEach((v) {
        readyDetails!.add(OrderDetailsFood.fromJson(v));
      });
    }

    deliveryAddress = json['delivery_address'] != null
        ? DeliveryAddress.fromJson(json['delivery_address'])
        : null;
    restaurantTable = json['restaurant_table'] != null
        ? RestaurantDetails.fromJson(json['restaurant_table'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderDetailsOrder != null) {
      data['order_details_order'] = orderDetailsOrder!.toJson();
    }
    if (orderDetailsFood != null) {
      data['order_details_food'] =
          orderDetailsFood!.map((v) => v.toJson()).toList();
    }
    if (readyDetails != null) {
      data['ready_order_details'] =
          readyDetails!.map((v) => v.toJson()).toList();
    }
    if (restaurantTable != null) {
      data['restaurant_table'] = restaurantTable!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    return data;
  }
}

class OrderDetailsOrder {
  int? id;
  String? restaurantOrderId;
    String? tokenNo;

  int? userId;
  String? username;
  int? employeeId;
  double? orderAmount;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  String? isPrintKot;

  String? orderStatus;
  String? paymentStatus;
  String? audioFile;
  String? createdAt;
  String? updatedAt;
  Restaurant? restaurant;
  Map<String, dynamic>? stationOrderStatus;
  int? editOrderCount;

  OrderDetailsOrder({
    this.id,
    this.restaurantOrderId,
    this.tokenNo,
    this.userId,
    this.username,
    this.employeeId,
    this.orderAmount,
    this.orderNote,
    this.orderType,
    this.checked,
    this.restaurantId,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.isPrintKot,
    this.orderStatus,
    this.paymentStatus,
    this.audioFile,
    this.createdAt,
    this.updatedAt,
    this.restaurant,
    this.stationOrderStatus,
    this.editOrderCount,
  });

  OrderDetailsOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantOrderId = json['restaurant_order_id']??'';
    tokenNo = '${json['daily_token'] ?? ''}';

    userId = json['user_id'];
    username = json['user_name'] ?? '';
    employeeId = json['employee_id'];
    orderAmount = double.tryParse('${json['order_amount'] ?? 0}') ?? 0.0;
    orderNote = json['order_note'];
    orderType = json['order_type'];
    checked = json['checked'];
    restaurantId = json['restaurant_id'];
    tableId = json['table_id'];
    waiterId = json['waiter_id'];
    isPrintKot = json['print_kot'] ?? 'No';
    fOrderStatus = json['f_order_status'];
    if (json.containsKey('station_order_status')) {
      stationOrderStatus = json['station_order_status'] is Map<String, dynamic>
          ? json['station_order_status'] as Map<String, dynamic>
          : {};
    }
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    audioFile = json['audio_file'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    editOrderCount = json['order_edit_count'] ?? 0;
    restaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_order_id'] = restaurantOrderId;
    data['user_id'] = userId;
    data['employee_id'] = employeeId;
    data['order_amount'] = orderAmount;
    data['print_kot'] = isPrintKot;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['checked'] = checked;
    data['restaurant_id'] = restaurantId;
    data['table_id'] = tableId;
    data['order_edit_count'] = editOrderCount;
    data['waiter_id'] = waiterId;
    data['f_order_status'] = fOrderStatus;
    data['order_status'] = orderStatus;
    data['payment_status'] = paymentStatus;
    data['audio_file'] = audioFile;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (stationOrderStatus != null) {
      data['station_order_status'] = stationOrderStatus;
    }
    data['user_name'] = username;
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
        : (json['gst_status'] == 1 || json['gst_status'] == '1');
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
  int? editFoodItemCount;
  String? unitPrice;
  double? price;
  FoodDetails? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  double? quantity;
  int? foodStatus;
  String? station;
  String? itemType;
  String? foodLevelNotes;

  String? readyAt;
  String? serveAt;
  String? cancelAt;
  String? createdAt;
  String? updatedAt;

  OrderDetailsFood({
    this.id,
    this.foodId,
    this.orderId,
    this.editFoodItemCount,
    this.unitPrice,
    this.price,
    this.foodDetails,
    this.variation,
    this.addOns,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.foodStatus,
    this.station,
    this.itemType,
    this.foodLevelNotes,
    this.readyAt,
    this.serveAt,
    this.cancelAt,
  });

  OrderDetailsFood.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    editFoodItemCount = json['item_update_count'] ?? 0;
    foodLevelNotes = json['food_level_notes'] ?? '';
    unitPrice = json['unit_price'];
    price = double.tryParse('${json['price'] ?? 0}') ?? 0.0;
    foodDetails = json['food_details'] != null
        ? FoodDetails.fromJson(json['food_details'])
        : null;
    if (json['variation'] != null) {
      variation = <Variations>[];
      json['variation'].forEach((v) {
        variation!.add(Variations.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
    }
    quantity = (json['quantity'] as num?)?.toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    foodStatus = json['food_status'];
    station = json['station'];
    itemType = json['item_type'];
    readyAt = json['ready_at'];
    serveAt = json['serve_at'];
    cancelAt = json['cancel_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_update_count'] = editFoodItemCount;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['unit_price'] = unitPrice;
    data['food_level_notes'] = foodLevelNotes;
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
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['food_status'] = foodStatus;
    data['station'] = station;
    data['item_type'] = itemType;
    data['ready_at'] = readyAt;
    data['serve_at'] = serveAt;
    data['cancel_at'] = cancelAt;
    return data;
  }
}

class CategoryIds {
  String? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        position = json['position'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class RestaurantDetails {
  String? tableNo;
  String? title;
  String? rtype;
  String? restaurantWaiterName;

  RestaurantDetails({
    this.tableNo,
    this.title,
    this.restaurantWaiterName,
    this.rtype,
  });

  RestaurantDetails.fromJson(Map<String, dynamic> json)
      : tableNo = json['restaurant_table_no'] ?? '',
        title = json['restaurant_table_area'] ?? '',
        rtype = json['restaurant_table_type'] ?? '',
        restaurantWaiterName = json['restaurant_waiter_name'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_table_no'] = tableNo;
    data['restaurant_table_area'] = title;
    data['restaurant_table_type'] = rtype;
    data['restaurant_waiter_name'] = restaurantWaiterName;
    return data;
  }
}

class Count {
  int? newOrder;
  int? cooking;
  int? ready;
  int? cancel;
  int? serve;

  Count({this.newOrder, this.cooking, this.ready, this.cancel, this.serve});

  Count.fromJson(Map<String, dynamic> json)
      : newOrder = json['New'],
        cooking = json['Cooking'],
        ready = json['Ready'],
        cancel = json['Cancel'],
        serve = json['Serve'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['New'] = newOrder;
    data['Cooking'] = cooking;
    data['Ready'] = ready;
    data['Cancel'] = cancel;
    data['Serve'] = serve;
    return data;
  }
}
