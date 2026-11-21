import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class GetWaiterOrderListResponse {
  List<OrderList>? orders;

  GetWaiterOrderListResponse({this.orders});

  GetWaiterOrderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <OrderList>[];
      json['orders'].forEach((v) {
        orders!.add(OrderList.fromJson(v));
      });
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

class OrderList {
  String? id;
  String? isEngage;
  String? restaurantOrderId;
  String? tokenNo;
  int? userId;
  int? employeeId;
  bool isSplitTable;
  bool isShowCheckbox;
  int splitCount;
  String userName;
  String? orderAmount;
  String? isPaymentLinkSent;
  String? orderNote;
  String? orderType;
  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  int? tablePart;
  String? parentOrderId;
  String? orderStatus;
  String? isPrintKot;
  String? paymentStatus;
  String? paymentId;
  String? audioFile;
  String? deliveryMan;
  String? deliveryManStatus;
  String? deliveryDispatchStatus;
  int? deliveryManId;
  DeliveryAddress? deliveryAddress;
  String? createdAt;
  String? updatedAt;
  String? scheduleAt;
  String? paymentType;
  User? user;
  VendorEmployee? vendorEmployee;
  RestaurantTable? restaurantTable;
  RoomDetailInfo? roomInfo;
  CallWaiterInfo? callWaiterInfo;
  int? editOrderCount;
  double? deliveryCharge;
  double? serviceCharge;
  double? tipAmount;
  double? tipTaxAmount;

  List<OrderDetails>? orderDetails;
  List<OrderDetails>? serveOrderDetails;
  List<RoomAssociateOrder>? roomAssociateOrder;

  OrderList({
    this.id,
    this.isEngage,
    this.restaurantOrderId,
    this.tokenNo,
    this.userId,
    this.serviceCharge,
    this.employeeId,
    this.isSplitTable = false,
    this.isShowCheckbox = false,
    this.splitCount = 0,
    this.tipAmount,
    this.tipTaxAmount,
    this.userName = '',
    this.orderAmount,
    this.isPaymentLinkSent,
    this.orderNote,
    this.orderType,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.tablePart,
    this.parentOrderId,
    this.orderStatus,
    this.isPrintKot,
    this.paymentStatus,
    this.paymentId,
    this.audioFile,
    this.deliveryMan,
    this.deliveryManStatus,
    this.deliveryDispatchStatus,
    this.deliveryManId,
    this.deliveryAddress,
    this.createdAt,
    this.updatedAt,
    this.scheduleAt,
    this.paymentType,
    this.user,
    this.vendorEmployee,
    this.restaurantTable,
    this.editOrderCount,
    this.orderDetails,
    this.roomInfo,
    this.callWaiterInfo,
    this.deliveryCharge,
    this.serveOrderDetails,
    this.roomAssociateOrder,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    final order = OrderList(
      id: '${json['id']}',
      isEngage: 'No',
      userId: json['user_id'],
      tablePart: int.parse('${json['tablepart'] ?? 0}'),
      parentOrderId: '${json['parent_order_id'] ?? ''}',
      serviceCharge: json['total_service_tax_amount'] == null
          ? 0.0
          : double.tryParse('${json['total_service_tax_amount']}') ?? 0.0,
      tipAmount: json['tip_amount'] == null
          ? 0.0
          : double.tryParse('${json['tip_amount']}') ?? 0.0,
      tipTaxAmount: json['tip_tax_amount'] == null
          ? 0.0
          : double.tryParse('${json['tip_tax_amount']}') ?? 0.0,
      restaurantOrderId: '${json['restaurant_order_id'] ?? '0'}',
      tokenNo: '${json['daily_token'] ?? ''}',
      employeeId: json['employee_id'],
      isSplitTable: false,
      isShowCheckbox: false,
      splitCount: 0,
      userName: json.containsKey('user_name')
          ? (json['user_name'] == null || json['user_name'] == 'Noname'
              ? ''
              : json['user_name'])
          : '',
      orderAmount: '${json['order_amount'] ?? '0'}',
      deliveryCharge:
          double.tryParse('${json['delivery_charge'] ?? '0'}') ?? 0.0,
      orderNote: json['order_note'] ?? '',
      deliveryMan: json['delivery_man'] ?? '',
      isPaymentLinkSent: json['send_payment_link'] ?? '',
      deliveryManStatus: json['delivery_man_status'] ?? 'No',
      deliveryDispatchStatus: json['order_dispatch_status'] ?? 'No',
      deliveryManId: json['delivery_man_id'],
      orderType: json['order_type'],
      editOrderCount: json['order_edit_count'] ?? 0,
      tableId: json['table_id'],
      paymentType: json['payment_type'],
      waiterId: json['waiter_id'],
      // fOrderStatus: 7,
      fOrderStatus: json['f_order_status'],
      orderStatus: json['order_status'],
      isPrintKot: json['print_kot'] ?? 'No',
      paymentStatus: json['payment_status'],
      paymentId: '${json['payment_id'] ?? ''}',
      audioFile: json['audio_file'],
      deliveryAddress:
          json['delivery_address'] != null && json['delivery_address'] != ''
              ? DeliveryAddress.fromJson(json['delivery_address'])
              : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      scheduleAt: json['schedule_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      vendorEmployee: json['vendorEmployee'] != null
          ? VendorEmployee.fromJson(json['vendorEmployee'])
          : null,
      restaurantTable: json['restaurantTable'] != null
          ? RestaurantTable.fromJson(json['restaurantTable'])
          : null,
      roomInfo: json['room_info'] != null
          ? RoomDetailInfo.fromJson(json['room_info'])
          : null,
      callWaiterInfo: json['waiter_call'] != null
          ? CallWaiterInfo.fromJson(json['waiter_call'])
          : null,
      orderDetails: json['orderDetails'] != null
          ? List<OrderDetails>.from((json['orderDetails'] as List)
              .map((v) => OrderDetails.fromJson(v)))
          : null,
      serveOrderDetails: json['f_order_status'] == 5
          ? []
          : json['serve_order_details'] != null
              ? List<OrderDetails>.from((json['serve_order_details'] as List)
                  .where((v) =>
                      v['food_details']['name'].toString().toUpperCase() !=
                      'CHECK IN')
                  .map((v) => OrderDetails.fromJson(v)))
              : [],
      roomAssociateOrder: json['associated_order_list'] != null
          ? List<RoomAssociateOrder>.from(
              (json['associated_order_list'] as List)
                  .map((v) => RoomAssociateOrder.fromJson(v)))
          : null,
    );

    if (order.deliveryAddress != null && order.user != null) {
      if ((order.deliveryAddress!.contactPersonName ?? '').trim().isEmpty) {
        order.deliveryAddress!.contactPersonName =
            '${order.user!.fName ?? ''} ${order.user!.lName ?? ''}'.trim();
      }
      if ((order.deliveryAddress!.contactPersonNumber ?? '').trim().isEmpty) {
        order.deliveryAddress!.contactPersonNumber = order.user!.phone ?? '';
      }
    }

    return order;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['restaurant_order_id'] = restaurantOrderId;
    data['employee_id'] = employeeId;
    data['user_name'] = userName;
    data['order_amount'] = orderAmount;
    data['print_kot'] = isPrintKot;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['order_edit_count'] = editOrderCount;
    data['table_id'] = tableId;
    data['waiter_id'] = waiterId;
    data['f_order_status'] = fOrderStatus;
    data['order_status'] = orderStatus;
    data['payment_status'] = paymentStatus;
    data['payment_id'] = paymentId;
    data['audio_file'] = audioFile;
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (vendorEmployee != null) {
      data['vendorEmployee'] = vendorEmployee!.toJson();
    }
    if (restaurantTable != null) {
      data['restaurantTable'] = restaurantTable!.toJson();
    }
    if (orderDetails != null) {
      data['orderDetails'] = orderDetails!.map((v) => v.toJson()).toList();
    }
    if (serveOrderDetails != null) {
      data['serve_order_details'] =
          serveOrderDetails!.map((v) => v.toJson()).toList();
    }

    if (roomAssociateOrder != null) {
      data['associated_order_list'] =
          roomAssociateOrder!.map((v) => v.toJson()).toList();
    }
    data['delivery_charge'] = deliveryCharge;
    data['delivery_man'] = deliveryMan;
    data['delivery_man_status'] = deliveryManStatus;
    data['order_dispatch_status'] = deliveryDispatchStatus;
    data['delivery_man_id'] = deliveryManId;
    data['payment_type'] = paymentType;
    if (roomInfo != null) {
      data['room_info'] = roomInfo!.toJson();
    }
    return data;
  }
}

class DeliveryAddress {
  String? contactPersonName;
  String? contactPersonNumber;
  String? addressType;
  String? address;
  String? pincode;
  dynamic floor;
  dynamic road;
  dynamic house;
  String? longitude;
  String? latitude;
  String? dob;
  String? doa;
  String? membershipId;

  DeliveryAddress({
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressType,
    this.address,
    this.pincode,
    this.floor,
    this.road,
    this.house,
    this.longitude,
    this.latitude,
    this.dob,
    this.doa,
    this.membershipId,
  });

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    contactPersonName = json['contact_person_name'] ?? '';
    contactPersonNumber = json['contact_person_number'] ?? '';
    addressType = json['address_type'];
    address = json['address'];
    pincode = json['pincode'];
    floor = json['floor'];
    road = json['road'];
    house = json['house'];
    longitude = '${json['longitude']}';
    latitude = '${json['latitude']}';
    dob = json['date_of_birth'] ?? '';
    doa = json['date_of_anniversary'] ?? '';
    membershipId = json['membership_id'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contact_person_name'] = contactPersonName;
    data['contact_person_number'] = contactPersonNumber;
    data['address_type'] = addressType;
    data['address'] = address;
    data['pincode'] = pincode;
    data['floor'] = floor;
    data['road'] = road;
    data['house'] = house;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['date_of_birth'] = dob;
    data['date_of_anniversary'] = doa;
    data['membership_id'] = membershipId;
    return data;
  }
}

class User {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? dob;
  String? anniversary;
  UserRestaurant? userRestaurant;

  User({this.id, this.fName, this.lName, this.phone, this.email});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'] == null || json['f_name'] == 'Noname'
        ? ''
        : json['f_name'];
    lName = json['l_name'] ?? '';
    phone = json['phone'] ?? '';
    email = json['email'] ?? '';
    dob = json['date_of_birth'] ?? '';
    anniversary = json['date_of_anniversary'] ?? '';
    userRestaurant = json['user_restaurant'] != null
        ? UserRestaurant.fromJson(json['user_restaurant'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    return data;
  }
}

class UserRestaurant {
  int? id;
  String? membershipId;
  UserRestaurant({this.id, this.membershipId});

  UserRestaurant.fromJson(Map<String, dynamic> json) {
    id = json['user_id'];
    membershipId = json['membership_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = id;
    data['membership_id'] = membershipId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = waiterName;
    data['l_name'] = lName;
    return data;
  }
}

class RoomAssociateOrder {
  int? id;
  String? restaurantOrderId;
  String? collectBillDate;
  double? amount;

  RoomAssociateOrder({
    this.id,
    this.restaurantOrderId,
    this.collectBillDate,
    this.amount,
  });

  RoomAssociateOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantOrderId = json['restaurant_order_id'] ?? '';
    collectBillDate = json['collect_Bill'];
    amount = double.tryParse('${json['order_amount'] ?? 0}') ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_order_id'] = restaurantOrderId;
    data['collect_Bill'] = collectBillDate;
    data['order_amount'] = amount;
    return data;
  }
}

class RoomPaymentRecord {
  double amount;
  String paymentMode;
  String paymentType;
  String note;
  String date;
  String transactionId;

  RoomPaymentRecord({
    this.amount = 0,
    this.paymentMode = '',
    this.paymentType = '',
    this.note = '',
    this.date = '',
    this.transactionId = '',
  });

  factory RoomPaymentRecord.fromJson(Map<String, dynamic> json) {
    return RoomPaymentRecord(
      amount: double.tryParse(
              '${json['payment_amount'] ?? json['amount'] ?? 0}') ??
          0,
      paymentMode:
          '${json['payment_mode'] ?? json['payment_method'] ?? ''}',
      paymentType: '${json['payment_type'] ?? ''}',
      note: '${json['payment_note'] ?? json['note'] ?? ''}',
      date: '${json['created_at'] ?? json['date'] ?? ''}',
      transactionId: '${json['transaction_id'] ?? ''}',
    );
  }
}

class RoomDetailInfo {
  double? roomPrice;
  double? advancePay;
  double? remainingPay;
  double? gstTaxAmount;
  String? gstName;
  String? gstNo;
  List<RoomPaymentRecord>? payments;

  RoomDetailInfo({
    this.roomPrice,
    this.advancePay,
    this.remainingPay,
    this.gstTaxAmount,
    this.gstName,
    this.gstNo,
    this.payments,
  });

  RoomDetailInfo.fromJson(Map<String, dynamic> json) {
    roomPrice = double.tryParse(json['room_price']?.toString() ?? '0') ?? 0.0;
    advancePay =
        double.tryParse(json['advance_payment']?.toString() ?? '0') ?? 0.0;
    remainingPay =
        double.tryParse(json['balance_payment']?.toString() ?? '0') ?? 0.0;
    gstTaxAmount =
        double.tryParse(json['gst_tax_amount']?.toString() ?? '0') ?? 0.0;
    gstName = json['gst_name'];
    gstNo = json['gst_no'];
    final rawPayments = json['payments'] ??
        json['payment_history'] ??
        json['room_payments'] ??
        json['advance_payments'];
    if (rawPayments is List) {
      payments = rawPayments
          .whereType<Map>()
          .map((e) => RoomPaymentRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_price'] = roomPrice;
    data['advance_payment'] = advancePay;
    data['balance_payment'] = remainingPay;
    data['gst_tax_amount'] = gstTaxAmount;
    data['gst_name'] = gstName;
    data['gst_no'] = gstNo;
    return data;
  }
}

class CallWaiterInfo {
  int? id;
  String? status;

  CallWaiterInfo({
    this.id,
    this.status,
  });

  CallWaiterInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['title'] = title;
    data['table_no'] = tableNo;
    data['waiter_id'] = waiterId;
    data['rtype'] = rtype;
    return data;
  }
}

class OrderDetails {
  int? id;
  int? orderId;
  bool isSelected;
  bool isSplited;
  double? splitQuantity;
  FoodDetails? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  double? price;
  int? foodStatus;
  String? foodType;
  String? foodLevelNotes;
  String? station;
  String? readyAt;
  String? serveAt;
  String? cancelAt;
  String? updatedAt;
  String? createdAt;
  String? cancelBy;
  double? unitPrice;
  double? quantity;
  int? itemUpdateCount;
  int? orderUpdateCount;
  String? tableIdSeq;
  String? priority;

  OrderDetails({
    this.id,
    this.orderId,
    this.isSelected = false,
    this.isSplited = false,
    this.splitQuantity,
    this.foodDetails,
    this.variation,
    this.price,
    this.foodStatus,
    this.addOns,
    this.foodType,
    this.foodLevelNotes,
    this.station,
    this.readyAt,
    this.serveAt,
    this.cancelAt,
    this.createdAt,
    this.cancelBy,
    this.updatedAt,
    this.unitPrice,
    this.quantity,
    this.itemUpdateCount,
    this.orderUpdateCount,
    this.tableIdSeq,
    this.priority,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      price: json['price'] == null
          ? 0.0
          : double.tryParse('${json['price']}') ?? 0.0,
      orderId: json['order_id'],
      isSelected: false,
      isSplited: false,
      quantity: json['quantity'] == null
          ? 0.0
          : double.tryParse('${json['quantity']}') ?? 0.0,
      foodLevelNotes: json['food_level_notes'] ?? '',
      cancelBy: '${json['cancel_by'] ?? ''}',
      foodStatus: json['food_status'],
      foodDetails: json['food_details'] != null
          ? FoodDetails.fromJson(json['food_details'])
          : null,
      variation: json['variation'] != null
          ? List<Variations>.from(
              (json['variation'] as List).map((v) => Variations.fromJson(v)))
          : null,
      addOns: json['add_ons'] != null
          ? List<AddOns>.from(
              (json['add_ons'] as List).map((v) => AddOns.fromJson(v)))
          : null,
      readyAt: json['ready_at'],
      serveAt: json['serve_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      cancelAt: json['cancel_at'],
      itemUpdateCount: json['item_update_count'],
      orderUpdateCount: json['order_update_count'] ?? 0,
      priority: json['priority'] ?? 'No',
      tableIdSeq: json['table_id_seq'],
      unitPrice: json['unit_price'] == null || json['unit_price'] == ''
          ? 0
          : double.tryParse(json['unit_price'].toString()) ?? 0.0,
      splitQuantity: json['quantity'] == null
          ? 0.0
          : double.tryParse('${json['quantity']}') ?? 0.0,
      foodType: json.containsKey('item_type') ? json['item_type'] ?? '' : null,
      station: json.containsKey('station') ? json['station'] ?? '' : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['food_status'] = foodStatus;
    data['food_level_notes'] = foodLevelNotes;
    data['price'] = price;
    data['item_update_count'] = itemUpdateCount;
    if (foodDetails != null) {
      data['food_details'] = foodDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['item_type'] = foodType;
    data['unit_price'] = unitPrice?.toString();
    data['station'] = station;
    return data;
  }
}

class FoodDetails {
  int? id;
  String? name;
  String? description;
  String? giveDiscount;
  String? taxType;
  String? tax;
  int? categoryId;

  List<Variations>? variations;
  List<AddOns>? addOns;
  String? price;
  double? deliveredFoodPrice;
  double? takeAwayFoodPrice;
  String? availableTimeStarts;
  String? availableTimeEnds;
  String? createdAt;
  String? updatedAt;
  String? foodFor;
  String? restaurantName;

  FoodDetails({
    this.id,
    this.name,
    this.description,
    this.giveDiscount,
    this.taxType,
    this.tax,
    this.categoryId,
    this.variations,
    this.addOns,
    this.price,
    this.deliveredFoodPrice,
    this.takeAwayFoodPrice,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.createdAt,
    this.updatedAt,
    this.foodFor,
    this.restaurantName,
  });

  FoodDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    giveDiscount = json['give_discount'] ?? 'Yes';
    taxType = json['tax_type'] ?? 'GST';
    tax = '${json['tax'] ?? '0'}';
    description = json['description'];

    if (json['variations'] != null) {
      variations = <Variations>[];
      for (var v in json['variations']) {
        variations!.add(Variations.fromJson(v));
      }
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      for (var v in json['add_ons']) {
        addOns!.add(AddOns.fromJson(v));
      }
    }

    price = '${json['price']}';
    takeAwayFoodPrice = json['takeaway_charge'] == null
        ? 0
        : double.parse('${json['takeaway_charge']}');
    deliveredFoodPrice = json['delivery_charge'] == null
        ? 0
        : double.parse('${json['delivery_charge']}');

    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    foodFor = json['food_for'];
    restaurantName = json['restaurant_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['category_id'] = categoryId;

    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;

    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    // data['food_status'] = foodStatus;
    data['food_for'] = foodFor;
    data['restaurant_name'] = restaurantName;

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['New'] = newOrder;
    data['Cooking'] = cooking;
    data['Ready'] = ready;
    data['Cancel'] = cancel;
    data['Serve'] = serve;
    return data;
  }
}
