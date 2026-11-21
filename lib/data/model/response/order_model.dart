class PaginatedOrderModel {
  final int totalSize;
  final String limit;
  final String offset;
  final List<OrderModel> orders;

  PaginatedOrderModel({
    required this.totalSize,
    required this.limit,
    required this.offset,
    required this.orders,
  });

  factory PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    return PaginatedOrderModel(
      totalSize: json['total_size'] ?? 0,
      limit: json['limit']?.toString() ?? '',
      offset: json['offset']?.toString() ?? '',
      orders: (json['orders'] as List<dynamic>?)
              ?.map((v) => OrderModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'orders': orders.map((v) => v.toJson()).toList(),
    };
  }
}

class OrderModel {
  final int id;
  final double orderAmount;
  final double couponDiscountAmount;
  final String? couponDiscountTitle;
  final String? paymentStatus;
  final String? orderStatus;
  final double totalTaxAmount;
  final String? paymentMethod;
  final String? orderNote;
  final String? orderType;
  final String? createdAt;
  final String? updatedAt;
  final double deliveryCharge;
  final String? scheduleAt;
  final String? otp;
  final String? pending;
  final String? accepted;
  final String? confirmed;
  final String? processing;
  final String? handover;
  final String? pickedUp;
  final String? delivered;
  final String? canceled;
  final String? refundRequested;
  final String? refunded;
  final DeliveryAddress? deliveryAddress;
  final int? scheduled;
  final double restaurantDiscountAmount;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? restaurantPhone;
  final String? restaurantLat;
  final String? restaurantLng;
  final String? restaurantLogo;
  final int? foodCampaign;
  final int? detailsCount;
  final Customer? customer;
  final double? dmTips;
  final int? processingTime;
  final DeliveryMan? deliveryMan;

  OrderModel({
    required this.id,
    required this.orderAmount,
    required this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    required this.totalTaxAmount,
    this.paymentMethod,
    this.orderNote,
    this.orderType,
    this.createdAt,
    this.updatedAt,
    required this.deliveryCharge,
    this.scheduleAt,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.deliveryAddress,
    this.scheduled,
    required this.restaurantDiscountAmount,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantPhone,
    this.restaurantLat,
    this.restaurantLng,
    this.restaurantLogo,
    this.foodCampaign,
    this.detailsCount,
    this.customer,
    this.dmTips,
    this.processingTime,
    this.deliveryMan,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return OrderModel(
      id: json['id'] ?? 0,
      orderAmount: parseDouble(json['order_amount']),
      couponDiscountAmount: parseDouble(json['coupon_discount_amount']),
      couponDiscountTitle: json['coupon_discount_title'],
      paymentStatus: json['payment_status'],
      orderStatus: json['order_status'],
      totalTaxAmount: parseDouble(json['total_tax_amount']),
      paymentMethod: json['payment_method'],
      orderNote: json['order_note'],
      orderType: json['order_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deliveryCharge: parseDouble(json['delivery_charge']),
      scheduleAt: json['schedule_at'],
      otp: json['otp'],
      pending: json['pending'],
      accepted: json['accepted'],
      confirmed: json['confirmed'],
      processing: json['processing'],
      handover: json['handover'],
      pickedUp: json['picked_up'],
      delivered: json['delivered'],
      canceled: json['canceled'],
      refundRequested: json['refund_requested'],
      refunded: json['refunded'],
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(json['delivery_address'])
          : null,
      scheduled: json['scheduled'],
      restaurantDiscountAmount: parseDouble(json['restaurant_discount_amount']),
      restaurantName: json['restaurant_name'],
      restaurantAddress: json['restaurant_address'],
      restaurantPhone: json['restaurant_phone'],
      restaurantLat: json['restaurant_lat'],
      restaurantLng: json['restaurant_lng'],
      restaurantLogo: json['restaurant_logo'],
      foodCampaign: json['food_campaign'],
      detailsCount: json['details_count'],
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      dmTips: json['dm_tips'] != null ? parseDouble(json['dm_tips']) : null,
      processingTime: json['processing_time'],
      deliveryMan: json['delivery_man'] != null
          ? DeliveryMan.fromJson(json['delivery_man'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_amount': orderAmount,
      'coupon_discount_amount': couponDiscountAmount,
      'coupon_discount_title': couponDiscountTitle,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'total_tax_amount': totalTaxAmount,
      'payment_method': paymentMethod,
      'order_note': orderNote,
      'order_type': orderType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'delivery_charge': deliveryCharge,
      'schedule_at': scheduleAt,
      'otp': otp,
      'pending': pending,
      'accepted': accepted,
      'confirmed': confirmed,
      'processing': processing,
      'handover': handover,
      'picked_up': pickedUp,
      'delivered': delivered,
      'canceled': canceled,
      'refund_requested': refundRequested,
      'refunded': refunded,
      'delivery_address': deliveryAddress?.toJson(),
      'scheduled': scheduled,
      'restaurant_discount_amount': restaurantDiscountAmount,
      'restaurant_name': restaurantName,
      'restaurant_address': restaurantAddress,
      'restaurant_phone': restaurantPhone,
      'restaurant_lat': restaurantLat,
      'restaurant_lng': restaurantLng,
      'restaurant_logo': restaurantLogo,
      'food_campaign': foodCampaign,
      'details_count': detailsCount,
      'customer': customer?.toJson(),
      'dm_tips': dmTips,
      'processing_time': processingTime,
      'delivery_man': deliveryMan?.toJson(),
    };
  }
}

class DeliveryAddress {
  final String? contactPersonName;
  final String? contactPersonNumber;
  final String? addressType;
  final String? address;
  final String? longitude;
  final String? latitude;
  final dynamic streetNumber;
  final dynamic house;
  final dynamic floor;

  DeliveryAddress({
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressType,
    this.address,
    this.longitude,
    this.latitude,
    this.streetNumber,
    this.house,
    this.floor,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      contactPersonName: json['contact_person_name'],
      contactPersonNumber: json['contact_person_number'],
      addressType: json['address_type'],
      address: json['address'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      streetNumber: json['road'],
      house: json['house'],
      floor: json['floor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_person_name': contactPersonName,
      'contact_person_number': contactPersonNumber,
      'address_type': addressType,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'road': streetNumber,
      'house': house,
      'floor': floor,
    };
  }
}

class Customer {
  final int id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    required this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      email: json['email'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'email': email,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class DeliveryMan {
  final int id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? image;
  final int? zoneId;
  final int? active;
  final String? status;

  DeliveryMan({
    required this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.zoneId,
    this.active,
    this.status,
  });

  factory DeliveryMan.fromJson(Map<String, dynamic> json) {
    return DeliveryMan(
      id: json['id'] ?? 0,
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      email: json['email'],
      image: json['image'],
      zoneId: json['zone_id'],
      active: json['active'],
      status: json['application_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'email': email,
      'image': image,
      'zone_id': zoneId,
      'active': active,
      'available': status,
    };
  }
}
