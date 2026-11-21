class GetRoomOrders {
  final List<RoomOrders> orders;

  GetRoomOrders({required this.orders});

  factory GetRoomOrders.fromJson(Map<String, dynamic> json) {
    return GetRoomOrders(
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((v) => RoomOrders.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((v) => v.toJson()).toList(),
    };
  }
}

class RoomOrders {
  final PrimaryOrder? primaryOrder;
  final List<AssociatedOrders> associatedOrders;
  final double roomGrandTotal;

  RoomOrders({
    this.primaryOrder,
    required this.associatedOrders,
    required this.roomGrandTotal,
  });

  factory RoomOrders.fromJson(Map<String, dynamic> json) {
    return RoomOrders(
      primaryOrder: json['primary_order'] != null
          ? PrimaryOrder.fromJson(json['primary_order'] as Map<String, dynamic>)
          : null,
      associatedOrders: (json['associated_orders'] as List<dynamic>? ?? [])
          .map((v) => AssociatedOrders.fromJson(v as Map<String, dynamic>))
          .toList(),
      roomGrandTotal:
          double.tryParse('${json['room_grand_total'] ?? 0}') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (primaryOrder != null) 'primary_order': primaryOrder!.toJson(),
      'associated_orders': associatedOrders.map((v) => v.toJson()).toList(),
      'room_grand_total': roomGrandTotal,
    };
  }
}

class PrimaryOrder {
  final int? id;
  final String? restaurantOrderId;
  final double? orderAmount;
  final String? userName;
  final double? restaurantDiscountAmount;
  final String? totalVatTaxAmount;
  final String? totalGstTaxAmount;
  final String? totalServiceTaxAmount;
  final int? fOrderStatus;
  final int? bOrderStatus;
  final int? kOrderStatus;
  final String? orderStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final dynamic transactionReference;
  final String? createdAt;
  final String? updatedAt;
  final String? fName;
  final String? lName;
  final String? email;
  final String? phone;
  final String? waiterName;
  final String? roomNumber;
  final String? collectBillDate;
  final double? roomAdvancePayment;
  final double? roomRemainingPayment;
  final double? roomAmount;

  PrimaryOrder({
    this.id,
    this.restaurantOrderId,
    this.orderAmount,
    this.userName,
    this.restaurantDiscountAmount,
    this.totalVatTaxAmount,
    this.totalGstTaxAmount,
    this.totalServiceTaxAmount,
    this.fOrderStatus,
    this.bOrderStatus,
    this.kOrderStatus,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.transactionReference,
    this.createdAt,
    this.updatedAt,
    this.fName,
    this.lName,
    this.email,
    this.phone,
    this.waiterName,
    this.roomNumber,
    this.collectBillDate,
    this.roomAdvancePayment,
    this.roomRemainingPayment,
    this.roomAmount,
  });

  factory PrimaryOrder.fromJson(Map<String, dynamic> json) {
    return PrimaryOrder(
        id: json['id'],
        restaurantOrderId: json['restaurant_order_id'],
        orderAmount: double.tryParse('${json['order_amount'] ?? 0}') ?? 0.0,
        userName: json['user_name'] ?? '',
        restaurantDiscountAmount:
            double.tryParse('${json['restaurant_discount_amount'] ?? 0}') ??
                0.0,
        totalVatTaxAmount: json['total_vat_tax_amount'],
        totalGstTaxAmount: json['total_gst_tax_amount'],
        totalServiceTaxAmount: json['total_service_tax_amount'],
        collectBillDate: json['collect_bill'] ?? '',
        orderStatus: json['order_status'],
        paymentStatus: json['payment_status'],
        paymentMethod: json['payment_method'],
        transactionReference: json['transaction_reference'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        fName: json['f_name'] ?? '',
        lName: json['l_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        roomNumber: json['room_number'] ?? '',
        waiterName: json['waiter_name'] ?? '',
        roomAdvancePayment: double.parse('${json['advance_payment'] ?? 0}'),
        roomAmount: double.parse('${json['room_price'] ?? 0}'),
        roomRemainingPayment: double.parse('${json['balance_payment'] ?? 0}'));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_order_id': restaurantOrderId,
      'order_amount': orderAmount,
      'user_name': userName,
      'restaurant_discount_amount': restaurantDiscountAmount,
      'total_vat_tax_amount': totalVatTaxAmount,
      'total_gst_tax_amount': totalGstTaxAmount,
      'total_service_tax_amount': totalServiceTaxAmount,
      'f_order_status': fOrderStatus,
      'b_order_status': bOrderStatus,
      'k_order_status': kOrderStatus,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'f_name': fName,
      'l_name': lName,
      'email': email,
      'phone': phone,
      'waiter_name': waiterName,
      'room_number': roomNumber,
      'collect_bill': collectBillDate,
    };
  }
}

class AssociatedOrders {
  int? id;
  String? restaurantOrderId;
  double? orderAmount;
  String? userName;
  double? restaurantDiscountAmount;
  String? totalVatTaxAmount;
  String? collectBillDate;
  String? transferOrderDate;
  String? totalGstTaxAmount;
  String? totalServiceTaxAmount;
  int? fOrderStatus;
  int? bOrderStatus;
  int? kOrderStatus;
  String? orderStatus;
  String? paymentStatus;
  String? paymentMethod;
  dynamic transactionReference;
  String? createdAt;
  String? updatedAt;
  String? fName;
  String? lName;
  String? email;
  String? phone;
  String? waiterName;

  AssociatedOrders({
    this.id,
    this.restaurantOrderId,
    this.orderAmount,
    this.userName,
    this.restaurantDiscountAmount,
    this.totalVatTaxAmount,
    this.collectBillDate,
    this.transferOrderDate,
    this.totalGstTaxAmount,
    this.totalServiceTaxAmount,
    this.fOrderStatus,
    this.bOrderStatus,
    this.kOrderStatus,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.transactionReference,
    this.createdAt,
    this.updatedAt,
    this.fName,
    this.lName,
    this.email,
    this.phone,
    this.waiterName,
  });

  AssociatedOrders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantOrderId = json['restaurant_order_id'];
    orderAmount = double.tryParse('${json['order_amount'] ?? 0}') ?? 0.0;
    userName = json['user_name'] ?? '';
    restaurantDiscountAmount =
        double.tryParse('${json['restaurant_discount_amount'] ?? 0}') ?? 0.0;
    totalVatTaxAmount = json['total_vat_tax_amount'];
    totalGstTaxAmount = json['total_gst_tax_amount'];
    totalServiceTaxAmount = json['total_service_tax_amount'];
    collectBillDate = json['collect_bill'] ?? '';
    transferOrderDate = json['transfer_date'] ?? '';
    fOrderStatus = json['f_order_status'];
    bOrderStatus = json['b_order_status'];
    kOrderStatus = json['k_order_status'];
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    transactionReference = json['transaction_reference'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fName = json['f_name'] ?? '';
    lName = json['l_name'] ?? '';
    email = json['email'] ?? '';
    phone = json['phone'] ?? '';
    waiterName = json['waiter_name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_order_id'] = restaurantOrderId;
    data['order_amount'] = orderAmount;
    data['user_name'] = userName;
    data['restaurant_discount_amount'] = restaurantDiscountAmount;
    data['total_vat_tax_amount'] = totalVatTaxAmount;
    data['total_gst_tax_amount'] = totalGstTaxAmount;
    data['total_service_tax_amount'] = totalServiceTaxAmount;
    data['collect_bill'] = collectBillDate;
    data['transfer_date'] = transferOrderDate;
    data['f_order_status'] = fOrderStatus;
    data['b_order_status'] = bOrderStatus;
    data['k_order_status'] = kOrderStatus;
    data['order_status'] = orderStatus;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['transaction_reference'] = transactionReference;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['email'] = email;
    data['phone'] = phone;
    data['waiter_name'] = waiterName;
    return data;
  }
}
