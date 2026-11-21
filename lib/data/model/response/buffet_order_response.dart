import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class BuffetOrderListResponse {
  List<OrderDetails>? orderDetails;
  List<OrderDetails>? priorityOrderDetails;

  BuffetOrderListResponse({this.orderDetails, this.priorityOrderDetails});

  BuffetOrderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['normal_order_food'] != null) {
      orderDetails = <OrderDetails>[];
      json['normal_order_food'].forEach((v) {
        orderDetails!.add(new OrderDetails.fromJson(v));
      });
    }
    if (json['priority_order_food'] != null) {
      priorityOrderDetails = <OrderDetails>[];
      json['priority_order_food'].forEach((v) {
        priorityOrderDetails!.add(new OrderDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderDetails != null) {
      data['normal_order_food'] =
          this.orderDetails!.map((v) => v.toJson()).toList();
    }
    if (this.priorityOrderDetails != null) {
      data['priority_order_food'] =
          this.priorityOrderDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetOrderListResponse {
  List<OrderList>? orders;
  Count? count;

  GetOrderListResponse({this.orders, this.count});

  GetOrderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <OrderList>[];
      json['orders'].forEach((v) {
        orders!.add(OrderList.fromJson(v));
      });
    }
    count = json['status_counts'] != null
        ? new Count.fromJson(json['status_counts'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    if (this.count != null) {
      data['status_counts'] = this.count!.toJson();
    }
    return data;
  }
}

class OrderList {
  String? restaurantOrderId;
  String? id;
  int? userId;
  int? employeeId;
  bool? isSplitTable;
  bool? isShowCheckbox;
  int? splitCount;
  String? userName;
  String? orderAmount;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  int? bOrderStatus;
  int? kOrderStatus;
  String? orderStatus;
  String? paymentStatus;
  String? audioFile;
  String? createdAt;
  String? updatedAt;
  User? user;
  VendorEmployee? vendorEmployee;
  RestaurantTable? restaurantTable;
  int? editOrderCount;
  List<OrderDetails>? orderDetails;
  List<OrderDetails>? serveOrderDetails;
  List<OrderDetails>? readyDetails;

  OrderList({
    this.id,
    this.restaurantOrderId,
    this.userId,
    this.employeeId,
    this.isSplitTable,
    this.isShowCheckbox,
    this.splitCount,
    this.userName,
    this.orderAmount,
    this.orderNote,
    this.orderType,
    this.checked,
    this.restaurantId,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.bOrderStatus,
    this.kOrderStatus,
    this.orderStatus,
    this.paymentStatus,
    this.audioFile,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.vendorEmployee,
    this.restaurantTable,
    this.editOrderCount,
    this.orderDetails,
    this.serveOrderDetails,
    this.readyDetails,
  });

  OrderList.fromJson(Map<String, dynamic> json) {
    id = '${json['id']}';
    userId = json['user_id'];
    restaurantOrderId = '${json['restaurant_order_id'] ?? '0'}';
    employeeId = json['employee_id'];
    isSplitTable = false;
    isShowCheckbox = false;
    splitCount = 0;
    userName = '';
    if (json.containsKey('user_name')) {
      userName = json['user_name'] ?? '';
    }
    orderAmount = '${json['order_amount'] ?? '0'}';
    orderNote = json['order_note'] ?? '';
    orderType = json['order_type'];
    editOrderCount = json['order_edit_count'] ?? 0;
    checked = json['checked'];
    restaurantId = json['restaurant_id'];
    tableId = json['table_id'];
    waiterId = json['waiter_id'];
    fOrderStatus = json['f_order_status'];
    bOrderStatus = json['b_order_status'];
    kOrderStatus = json['k_order_status'];

    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    audioFile = json['audio_file'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    vendorEmployee = json['vendorEmployee'] != null
        ? new VendorEmployee.fromJson(json['vendorEmployee'])
        : null;
    restaurantTable = json['restaurantTable'] != null
        ? new RestaurantTable.fromJson(json['restaurantTable'])
        : null;
    if (json['orderDetails'] != null) {
      orderDetails = <OrderDetails>[];
      json['orderDetails'].forEach((v) {
        orderDetails!.add(new OrderDetails.fromJson(v));
      });
    }
    if (json['serve_order_details'] != null) {
      serveOrderDetails = <OrderDetails>[];
      json['serve_order_details'].forEach((v) {
        if (v['food_details']['name'].toString().toUpperCase() != 'CHECK IN')
          serveOrderDetails!.add(new OrderDetails.fromJson(v));
      });
    }
    if (json['ready_order_details'] != null) {
      readyDetails = <OrderDetails>[];
      json['ready_order_details'].forEach((v) {
        if (v['food_details']['name'].toString().toUpperCase() != 'CHECK IN')
          readyDetails!.add(new OrderDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['restaurant_order_id'] = this.restaurantOrderId;
    data['employee_id'] = this.employeeId;
    data['user_name'] = this.userName;
    data['order_amount'] = this.orderAmount;
    data['order_note'] = this.orderNote;
    data['order_type'] = this.orderType;
    data['order_edit_count'] = this.editOrderCount;
    data['checked'] = this.checked;
    data['restaurant_id'] = this.restaurantId;
    data['table_id'] = this.tableId;
    data['waiter_id'] = this.waiterId;
    data['f_order_status'] = this.fOrderStatus;
    data['b_order_status'] = this.bOrderStatus;
    data['k_order_status'] = this.kOrderStatus;
    data['order_status'] = this.orderStatus;
    data['payment_status'] = this.paymentStatus;
    data['audio_file'] = this.audioFile;

    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.vendorEmployee != null) {
      data['vendorEmployee'] = this.vendorEmployee!.toJson();
    }
    if (this.restaurantTable != null) {
      data['restaurantTable'] = this.restaurantTable!.toJson();
    }
    if (this.orderDetails != null) {
      data['orderDetails'] = this.orderDetails!.map((v) => v.toJson()).toList();
    }
    if (this.serveOrderDetails != null) {
      data['serve_order_details'] =
          this.serveOrderDetails!.map((v) => v.toJson()).toList();
    }
    if (this.readyDetails != null) {
      data['ready_order_details'] =
          this.readyDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;

  User({this.id, this.fName, this.lName, this.phone, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'] ?? '';
    lName = json['l_name'] ?? '';
    phone = json['phone'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['f_name'] = this.fName;
    data['l_name'] = this.lName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}

class VendorEmployee {
  int? id;
  String? waiterName;
  String? lName;

  VendorEmployee({this.id, this.waiterName, this.lName});

  VendorEmployee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    waiterName = json['f_name'] ?? '';
    lName = json['l_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['f_name'] = this.waiterName;
    data['l_name'] = this.lName;
    return data;
  }
}

class RestaurantTable {
  int? id;
  int? restaurantId;
  String? title;
  String? tableNo;
  int? waiterId;
  String? rtype;

  RestaurantTable({
    this.id,
    this.restaurantId,
    this.title,
    this.tableNo,
    this.waiterId,
    this.rtype,
  });

  RestaurantTable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    title = json['title'] ?? '';
    tableNo = json['table_no'] ?? '';
    waiterId = json['waiter_id'];
    rtype = json['rtype'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['restaurant_id'] = this.restaurantId;
    data['title'] = this.title;
    data['table_no'] = this.tableNo;
    data['waiter_id'] = this.waiterId;
    data['rtype'] = this.rtype;

    return data;
  }
}

class OrderDetails {
  int? id;
  int? orderId;
  bool? isSelected;
  bool? isSplited;
  int? splitQuantity;
  FoodDetails? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  double? price;
  int? foodStatus;
  String? foodType;
  String? waiterName;
  String? foodNote;
  String? station;
  String? readyAt;
  String? serveAt;
  String? cancelAt;
  String? createdAt;
  String? updatedAt;
  double? unitPrice;
  int? quantity;
  int? itemUpdateCount;
  int? orderUpdateCount;
  String? tableIdSeq;
  String? priority;

  OrderDetails({
    this.id,
    this.orderId,
    this.isSelected,
    this.isSplited,
    this.splitQuantity,
    this.foodDetails,
    this.variation,
    this.price,
    this.foodStatus,
    this.addOns,
    this.foodType,
    this.waiterName,
    this.foodNote,
    this.station,
    this.readyAt,
    this.serveAt,
    this.cancelAt,
    this.createdAt,
    this.updatedAt,
    this.unitPrice,
    this.quantity,
    this.itemUpdateCount,
    this.orderUpdateCount,
    this.tableIdSeq,
    this.priority,
  });

  OrderDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'] == null ? 0.0 : double.parse('${json['price']}');
    orderId = json['order_id'];
    isSelected = false;
    isSplited = false;
    quantity = json['quantity'];
    waiterName = json['waiter_name'] ?? '';
    foodStatus = json['food_status'];
    foodDetails = json['food_details'] != null
        ? new FoodDetails.fromJson(json['food_details'])
        : null;
    if (json['variation'] != null) {
      variation = <Variations>[];
      json['variation'].forEach((v) {
        variation!.add(new Variations.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      json['add_ons'].forEach((v) {
        addOns!.add(new AddOns.fromJson(v));
      });
    }
    readyAt = json['ready_at'];
    serveAt = json['serve_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cancelAt = json['cancel_at'];
    tableIdSeq = json['table_id_seq'];
    foodNote = json['food_level_notes'] ?? '';
    priority = json['priority'] ?? 'No';
    itemUpdateCount = json['item_update_count'] ?? 0;
    orderUpdateCount = json['order_update_count'] ?? 0;
    unitPrice = json['unit_price'] == null || json['unit_price'] == ''
        ? 0
        : double.parse(json['unit_price']);
    splitQuantity = quantity;

    if (json.containsKey('item_type')) {
      foodType = json['item_type'] ?? '';
    }
    if (json.containsKey('station')) {
      station = json['station'] ?? '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['table_id_seq'] = this.tableIdSeq;

    data['food_status'] = this.foodStatus;
    data['price'] = this.price;
    data['priority'] = this.priority;
    data['item_update_count'] = this.itemUpdateCount;
    data['order_update_count'] = this.orderUpdateCount;
    if (this.foodDetails != null) {
      data['food_details'] = this.foodDetails!.toJson();
    }
    if (this.variation != null) {
      data['variation'] = this.variation!.map((v) => v.toJson()).toList();
    }
    if (this.addOns != null) {
      data['add_ons'] = this.addOns!.map((v) => v.toJson()).toList();
    }
    data['item_type'] = this.foodType;
    data['unit_price'] = this.unitPrice.toString();
    data['station'] = this.station;
    return data;
  }
}

class FoodDetails {
  int? id;
  String? name;
  String? description;
  String? image;
  int? categoryId;

  List<CategoryIds>? categoryIds;
  List<String>? mainCategoryId;
  List<Variations>? variations;
  List<AddOns>? addOns;
  String? attributes;
  String? choiceOptions;
  String? price;
  double? tax;
  String? taxType;
  String? taxCalc;
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
  // int foodStatus;
  int? foodStock;
  String? foodFor;
  String? restaurantName;
  int? restaurantStatus;
  int? restaurantDiscount;

  bool? scheduleOrder;
  int? freeDelivery;
  int? minDeliveryTime;
  int? maxDeliveryTime;

  FoodDetails({
    this.id,
    this.name,
    this.description,
    this.image,
    this.categoryId,
    this.categoryIds,
    this.mainCategoryId,
    this.variations,
    this.addOns,
    this.attributes,
    this.choiceOptions,
    this.price,
    this.tax,
    this.taxType,
    this.taxCalc,
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
    // this.foodStatus,
    this.foodStock,
    this.foodFor,
    this.restaurantName,
    this.restaurantStatus,
    this.restaurantDiscount,
    this.scheduleOrder,
    this.freeDelivery,
    this.minDeliveryTime,
    this.maxDeliveryTime,
  });

  FoodDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    categoryId = json['category_id'];
    if (json['category_ids'] != null) {
      categoryIds = [];
      mainCategoryId = [];

      categoryIds = <CategoryIds>[];
      json['category_ids'].forEach((v) {
        mainCategoryId!.add(v['id'].toString());

        categoryIds!.add(new CategoryIds.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(new Variations.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      json['add_ons'].forEach((v) {
        addOns!.add(new AddOns.fromJson(v));
      });
    }
    attributes = json['attributes'];
    choiceOptions = json['choice_options'];
    price = '${json['price']}';
    tax = double.parse('${json['tax'] ?? 0}');
    taxType = json['tax_type'] ?? '';
    taxCalc = json['tax_calc'] ?? '';
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
    // foodStatus = json['food_status'];
    foodStock = json['food_stock'];
    foodFor = json['food_for'];
    restaurantName = json['restaurant_name'];
    restaurantStatus = json['restaurant_status'];
    restaurantDiscount = json['restaurant_discount'];
    scheduleOrder = json['schedule_order'];
    freeDelivery = json['free_delivery'];
    minDeliveryTime = json['min_delivery_time'];
    maxDeliveryTime = json['max_delivery_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['category_id'] = this.categoryId;
    if (this.categoryIds != null) {
      data['category_ids'] = this.categoryIds!.map((v) => v.toJson()).toList();
    }
    if (this.variations != null) {
      data['variations'] = this.variations!.map((v) => v.toJson()).toList();
    }
    if (this.addOns != null) {
      data['add_ons'] = this.addOns!.map((v) => v.toJson()).toList();
    }
    data['attributes'] = this.attributes;
    data['choice_options'] = this.choiceOptions;
    data['price'] = this.price;
    data['tax'] = this.tax;
    data['tax_type'] = this.taxType;
    data['tax_calc'] = this.taxCalc;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['available_time_starts'] = this.availableTimeStarts;
    data['available_time_ends'] = this.availableTimeEnds;
    data['veg'] = this.veg;
    data['status'] = this.status;
    data['restaurant_id'] = this.restaurantId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['order_count'] = this.orderCount;
    data['avg_rating'] = this.avgRating;
    data['rating_count'] = this.ratingCount;
    data['recommended'] = this.recommended;
    data['slug'] = this.slug;
    // data['food_status'] = this.foodStatus;
    data['food_stock'] = this.foodStock;
    data['food_for'] = this.foodFor;
    data['restaurant_name'] = this.restaurantName;
    data['restaurant_status'] = this.restaurantStatus;
    data['restaurant_discount'] = this.restaurantDiscount;
    data['schedule_order'] = this.scheduleOrder;
    data['free_delivery'] = this.freeDelivery;
    data['min_delivery_time'] = this.minDeliveryTime;
    data['max_delivery_time'] = this.maxDeliveryTime;

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

  Count.fromJson(Map<String, dynamic> json) {
    newOrder = json['New'];
    cooking = json['Cooking'];
    ready = json['Ready'];
    cancel = json['Cancel'];
    serve = json['Serve'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['New'] = this.newOrder;
    data['Cooking'] = this.cooking;
    data['Ready'] = this.ready;
    data['Cancel'] = this.cancel;
    data['Serve'] = this.serve;
    return data;
  }
}
