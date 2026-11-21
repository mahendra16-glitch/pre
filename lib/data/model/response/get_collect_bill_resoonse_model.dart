import 'dart:convert';

import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class GetCollectBillDetailResponse {
  Orders? orders;

  GetCollectBillDetailResponse({this.orders});

  GetCollectBillDetailResponse.fromJson(Map<String, dynamic> json) {
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

class Orders {
  OrderUser? orderUser;
  OrderDiscountJson? orderDiscountJson;
  OrderDetailsOrder? orderDetailsOrder;
  DeliveryAddress? deliveryAddress;
  RoomDetailInfo? roomInfo;
  RestaurantDetails? restaurantDetails;
  List<OrderDetailsBar> orderDetailsBar = [];
  List<OrderDetailsBar> mergeFoodList = [];
  List<OrderDetailsBar> mergeFoodListWithDate = [];
  // dynamic orderTotalBar;
  dynamic barTotalAddonsAmount;
  dynamic foodTotalAddonsAmount;
  dynamic barVariationAmt;
  dynamic foodVariationAmt;
  String paymentUrl = '';
  List<OrderDetailsBar> orderDetailsFood = [];
  dynamic orderTotalFood;
  List<CollectBillAssociatedOrder> associatedOrderList = [];

  Orders({
    this.orderUser,
    this.orderDiscountJson,
    this.orderDetailsOrder,
    this.deliveryAddress,
    this.restaurantDetails,
    this.roomInfo,
    List<OrderDetailsBar>? mergeFoodList,
    List<OrderDetailsBar>? mergeFoodListWithDate,
    List<OrderDetailsBar>? orderDetailsBar,
    // this.orderTotalBar,
    this.barTotalAddonsAmount,
    this.foodTotalAddonsAmount,
    this.barVariationAmt,
    this.foodVariationAmt,
    List<OrderDetailsBar>? orderDetailsFood,
    List<CollectBillAssociatedOrder>? associatedOrderList,
    this.paymentUrl = '',
    this.orderTotalFood,
  })  : orderDetailsBar = orderDetailsBar ?? [],
        mergeFoodList = mergeFoodList ?? [],
        mergeFoodListWithDate = mergeFoodListWithDate ?? [],
        orderDetailsFood = orderDetailsFood ?? [],
        associatedOrderList = associatedOrderList ?? [];

  Orders.fromJson(Map<String, dynamic> json) {
    orderDetailsOrder = json['order_details_order'] != null
        ? new OrderDetailsOrder.fromJson(json['order_details_order'])
        : null;
    if (json['order_details_bar'] != null) {
      orderDetailsBar = <OrderDetailsBar>[];
      json['order_details_bar'].forEach((v) {
        orderDetailsBar.add(new OrderDetailsBar.fromJson(v));
      });
    }
    deliveryAddress = json['delivery_address'] != null
        ? new DeliveryAddress.fromJson(json['delivery_address'])
        : null;
    orderUser = json['order_user'] != null
        ? new OrderUser.fromJson(json['order_user'])
        : null;
    orderDiscountJson = json['order_discount_json'] != null
        ? new OrderDiscountJson.fromJson(json['order_discount_json'])
        : null;
    mergeFoodList = [];
    mergeFoodListWithDate = [];
    // orderTotalBar = json['order_total_bar'];
    paymentUrl = '';
    if (json.containsKey('payment_url')) {
      paymentUrl = json['payment_url'] == null ? '' : json['payment_url'];
    }

    restaurantDetails = json['restaurant_details'] != null
        ? new RestaurantDetails.fromJson(json['restaurant_details'])
        : null;
    roomInfo = json['room_info'] != null
        ? new RoomDetailInfo.fromJson(json['room_info'])
        : null;
    barTotalAddonsAmount = json['order_total_bar_addon_amt'];
    foodTotalAddonsAmount = json['order_total_addon_amt'];
    foodVariationAmt = json['order_total_vari_amt'];
    barVariationAmt = json['order_total_bar_vari_amt'];
    if (json['order_details_food'] != null) {
      orderDetailsFood = <OrderDetailsBar>[];
      json['order_details_food'].forEach((v) {
        orderDetailsFood.add(OrderDetailsBar.fromJson(v));
      });
    }
    orderTotalFood = json['order_total'];
    if (json['associated_order_list'] != null) {
      associatedOrderList = <CollectBillAssociatedOrder>[];
      json['associated_order_list'].forEach((v) {
        associatedOrderList.add(CollectBillAssociatedOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderDetailsOrder != null) {
      data['order_details_order'] = this.orderDetailsOrder?.toJson();
    }
    if (this.deliveryAddress != null) {
      data['delivery_address'] = this.deliveryAddress?.toJson();
    }
    data['order_details_bar'] =
        this.orderDetailsBar.map((v) => v.toJson()).toList();
    data['mergeFoodList'] = this.mergeFoodList.map((v) => v.toJson()).toList();
    data['mergeFoodListWithDate'] =
        this.mergeFoodListWithDate.map((v) => v.toJson()).toList();
    // data['order_total_bar'] = this.orderTotalBar;
    if (this.restaurantDetails != null) {
      data['restaurant_details'] = this.restaurantDetails?.toJson();
    }
    data['order_details_food'] =
        this.orderDetailsFood.map((v) => v.toJson()).toList();
    if (this.orderUser != null) {
      data['order_user'] = this.orderUser?.toJson();
    }
    if (this.orderDiscountJson != null) {
      data['order_discount_json'] = this.orderDiscountJson?.toJson();
    }
    data['order_total_food'] = this.orderTotalFood;
    data['associated_order_list'] =
        associatedOrderList.map((v) => v.toJson()).toList();
    return data;
  }
}

class CollectBillAssociatedOrder {
  final int? id;
  final String? restaurantOrderId;
  final String? orderAmount;
  final String? collectBillDate;

  CollectBillAssociatedOrder({
    this.id,
    this.restaurantOrderId,
    this.orderAmount,
    this.collectBillDate,
  });

  factory CollectBillAssociatedOrder.fromJson(Map<String, dynamic> json) {
    return CollectBillAssociatedOrder(
      id: json['id'] as int?,
      restaurantOrderId: json['restaurant_order_id']?.toString() ?? '',
      orderAmount: (json['order_amount'] ?? '0').toString(),
      collectBillDate: json['collect_bill']?.toString() ??
          json['collect_Bill']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_order_id': restaurantOrderId,
      'order_amount': orderAmount,
      'collect_bill': collectBillDate,
    };
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
  String? userGst;
  String? userGstName;
  String? dateOfBirth;
  String? dateOfAnniversary;
  String? membershipId;
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
    this.userGst,
    this.userGstName,
    this.dateOfBirth,
    this.dateOfAnniversary,
    this.membershipId,
    this.discount,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'],
      fName: json['f_name'] ?? '',
      lName: json['l_name'] ?? '',
      phone: json['phone'] ?? '',
      userGst: json['gst_number'] ?? '',
      userGstName: json['gst_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      dateOfAnniversary: json['date_of_anniversary'] ?? '',
      membershipId: json['membership_id'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      isPhoneVerified: json['is_phone_verified'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      cmFirebaseToken: json['cm_firebase_token'],
      status: json['status'],
      orderCount: json['order_count'],
      loginMedium: json['login_medium'],
      socialId: json['social_id'],
      zoneId: json['zone_id'],
      walletBalance: json['wallet_balance'],
      loyaltyPoint: json['loyalty_point'],
      refCode: json['ref_code'],
      refBy: json['ref_by'],
      tempToken: json['temp_token'],
      discount: (json['discount'] != null)
          ? (json['discount'] is double
              ? json['discount']
              : double.tryParse(json['discount'].toString()) ?? 0)
          : 0,
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
      'is_phone_verified': isPhoneVerified,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cm_firebase_token': cmFirebaseToken,
      'status': status,
      'order_count': orderCount,
      'login_medium': loginMedium,
      'social_id': socialId,
      'zone_id': zoneId,
      'wallet_balance': walletBalance,
      'loyalty_point': loyaltyPoint,
      'ref_code': refCode,
      'ref_by': refBy,
      'temp_token': tempToken,
      'discount': discount,
    };
  }
}

class OrderDiscountJson {
  int? id;
  int? orderId;
  String? discountType;
  String? discountNote;
  double? discountAmount;

  OrderDiscountJson({
    this.id,
    this.orderId,
    this.discountType,
    this.discountNote,
    this.discountAmount,
  });

  factory OrderDiscountJson.fromJson(Map<String, dynamic> json) {
    return OrderDiscountJson(
      id: json['id'],
      orderId: json['order_id'],
      discountType: json['discount_type'] ?? 'percent',
      discountNote: json['discount_note'] ?? '',
      discountAmount: json['discount'] == null
          ? 0
          : double.parse('${json['discount'] ?? 0}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'discount_type': discountType,
      'discount_note': discountNote,
      'discount': discountAmount,
    };
  }
}

class OrderDetailsOrder {
  int? id;
  String? restaurantOrderId;
  String? tokenNo;

  dynamic userId;
  String? custMemberId;
  String? customerCrmId;
  String? username;
  int? employeeId;
  double? orderAmount;
  int? couponDiscountAmount;
  dynamic couponDiscountTitle;
  String? paymentStatus;
  String? orderStatus;
  dynamic totalTaxAmount;
  String? paymentMethod;
  String? paymentType;
  String? transactionReference;
  dynamic deliveryAddressId;
  dynamic deliveryManId;
  dynamic couponCode;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  dynamic scheduleAt;
  dynamic callback;
  dynamic otp;
  dynamic pending;
  dynamic accepted;
  dynamic confirmed;
  dynamic processing;
  dynamic handover;
  dynamic pickedUp;
  dynamic delivered;
  dynamic canceled;
  dynamic refundRequested;
  dynamic refunded;
  dynamic deliveryAddress;
  int? scheduled;
  dynamic restaurantDiscountAmount;
  int? originalDeliveryCharge;
  dynamic failed;
  String? adjusment;
  int? edited;
  dynamic zoneId;
  int? dmTips;
  dynamic processingTime;
  dynamic freeDeliveryBy;
  dynamic refundRequestCanceled;
  dynamic cancellationReason;
  dynamic canceledBy;
  dynamic taxStatus;
  dynamic couponCreatedBy;
  dynamic vehicleId;
  String? discountOnProductBy;
  int? distance;
  dynamic subscriptionId;
  dynamic cancellationNote;
  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  String? totalVatTaxAmount;
  String? totalGstTaxAmount;
  String? appliedCouponCode;
  String? tipAmount;
  String? serviceChargeAmount;
  String? orderDiscountValue;
  String? orderDiscountValueType;
  double? orderSubTotalWithoutTax;
  double? orderSubTotal;
  double? orderDiscount;
  double? loyaltyPoints;
  bool? loyaltyRedeemed;
  double? loyaltyRedeemedAmount;
  double? loyaltyInfoPointsUsed;
  bool? couponInfoApplied;
  String? couponInfoCode;
  String? couponInfoTitle;
  double? couponInfoAmount;
  Restaurant? restaurant;
  String? roundoff;
  String? discountMemberCategory;
  double? tipTaxAmount;

  OrderDetailsOrder({
    this.id,
    this.restaurantOrderId,
    this.tokenNo,
    this.userId,
    this.custMemberId,
    this.customerCrmId,
    this.username,
    this.employeeId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.paymentType,
    this.transactionReference,
    this.deliveryAddressId,
    this.deliveryManId,
    this.couponCode,
    this.orderNote,
    this.orderType,
    this.checked,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.callback,
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
    this.restaurantDiscountAmount,
    this.originalDeliveryCharge,
    this.failed,
    this.adjusment,
    this.edited,
    this.zoneId,
    this.dmTips,
    this.processingTime,
    this.freeDeliveryBy,
    this.refundRequestCanceled,
    this.cancellationReason,
    this.canceledBy,
    this.taxStatus,
    this.couponCreatedBy,
    this.vehicleId,
    this.discountOnProductBy,
    this.distance,
    this.subscriptionId,
    this.cancellationNote,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.totalVatTaxAmount,
    this.totalGstTaxAmount,
    this.appliedCouponCode,
    this.tipAmount,
    this.serviceChargeAmount,
    this.orderDiscountValue,
    this.orderDiscountValueType,
    this.orderSubTotalWithoutTax,
    this.orderSubTotal,
    this.orderDiscount,
    this.loyaltyPoints,
    this.loyaltyRedeemed,
    this.loyaltyRedeemedAmount,
    this.loyaltyInfoPointsUsed,
    this.couponInfoApplied,
    this.couponInfoCode,
    this.couponInfoTitle,
    this.couponInfoAmount,
    this.roundoff,
    this.restaurant,
    this.discountMemberCategory,
    this.tipTaxAmount,
  });

  factory OrderDetailsOrder.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> loyaltyInfo = {};
    final rawLoyalty = json['loyalty_info'];
    if (rawLoyalty is Map) {
      loyaltyInfo = Map<String, dynamic>.from(rawLoyalty);
    } else if (rawLoyalty is String && rawLoyalty.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawLoyalty);
        if (decoded is Map) {
          loyaltyInfo = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    Map<String, dynamic> couponInfo = {};
    final rawCoupon = json['coupon_info'];
    if (rawCoupon is Map) {
      couponInfo = Map<String, dynamic>.from(rawCoupon);
    } else if (rawCoupon is String && rawCoupon.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCoupon);
        if (decoded is Map) {
          couponInfo = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return OrderDetailsOrder(
      id: json['id'],
      restaurantOrderId: '${json['restaurant_order_id'] ?? '0'}',
      userId: json['user_id'],
      custMemberId: json['cust_member_id']?.toString(),
      customerCrmId: json['customer_crm_id']?.toString(),
      employeeId: json['employee_id'],
      username: json['user_name'] ?? '',
      tipAmount: json['tip_amount'] ?? '0',
      orderSubTotalWithoutTax:
          double.parse('${json['order_sub_total_without_tax'] ?? 0}'),
      orderSubTotal: double.parse('${json['order_sub_total_amount'] ?? 0}'),
      orderDiscount: double.parse('${json['order_discount'] ?? 0}'),
      serviceChargeAmount: json['total_service_tax_amount'] ?? '0',
      orderAmount: json['order_amount'] != null
          ? double.tryParse(json['order_amount'].toString()) ?? 0
          : 0,
      couponDiscountAmount: json['coupon_discount_amount'] ??
          (json['coupon_discount'] == null
              ? null
              : int.tryParse('${json['coupon_discount']}')),
      loyaltyPoints: double.tryParse('${json['loyalty_points'] ?? 0}') ?? 0,
      // loyaltyRedeemed: json['loyalty_info'] is Map &&
      //     json['loyalty_info']['redeemed'] == true,
      loyaltyRedeemed: loyaltyInfo['redeemed'] == true,
      // loyaltyRedeemedAmount: json['loyalty_info'] is Map
      //     ? double.tryParse(
      //             '${json['loyalty_info']['redeemed_amount'] ?? 0}') ??
      //         0
      //     : 0,
      loyaltyRedeemedAmount:
          double.tryParse('${loyaltyInfo['redeemed_amount'] ?? 0}') ?? 0,
      // loyaltyInfoPointsUsed: json['loyalty_info'] is Map
      //     ? double.tryParse(
      //             '${json['loyalty_info']['loyalty_points_used'] ?? 0}') ??
      //         0
      //     : 0,
      loyaltyInfoPointsUsed:
          double.tryParse('${loyaltyInfo['loyalty_points_used'] ?? 0}') ?? 0,
      couponInfoApplied: couponInfo['applied'] == true,
      couponInfoCode: '${couponInfo['coupon_code'] ?? ''}',
      couponInfoTitle:
          '${couponInfo['coupon_title'] ?? couponInfo['coupon_code'] ?? ''}',
      couponInfoAmount: double.tryParse(
              '${couponInfo['coupon_amount'] ?? couponInfo['coupon_discount'] ?? 0}') ??
          0,
      tokenNo: '${json['daily_token'] ?? ''}',
      couponDiscountTitle: json['coupon_discount_title'],
      paymentStatus: json['payment_status'],
      orderStatus: json['order_status'],
      totalTaxAmount: json['total_tax_amount'],
      paymentMethod: json['payment_method'],
      paymentType: json['payment_type'] ?? '',
      transactionReference: json['transaction_reference'],
      deliveryAddressId: json['delivery_address_id'],
      deliveryManId: json['delivery_man_id'],
      couponCode: json['coupon_code'],
      orderNote: json['order_note'] ?? '',
      orderDiscountValue: json['discount_value'] ?? '0',
      orderDiscountValueType: json['order_discount_type'] ?? 'Percent',
      orderType: json['order_type'],
      checked: json['checked'],
      restaurantId: json['restaurant_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deliveryCharge: json['delivery_charge'] != null
          ? double.tryParse(json['delivery_charge'].toString()) ?? 0
          : 0,
      scheduleAt: json['schedule_at'],
      callback: json['callback'],
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
      deliveryAddress: json['delivery_address'],
      scheduled: json['scheduled'],
      restaurantDiscountAmount: json['restaurant_discount_amount'],
      originalDeliveryCharge: json['original_delivery_charge'],
      failed: json['failed'],
      adjusment: json['adjusment'],
      edited: json['edited'],
      zoneId: json['zone_id'],
      dmTips: json['dm_tips'],
      processingTime: json['processing_time'],
      freeDeliveryBy: json['free_delivery_by'],
      refundRequestCanceled: json['refund_request_canceled'],
      cancellationReason: json['cancellation_reason'],
      canceledBy: json['canceled_by'],
      taxStatus: json['tax_status'],
      couponCreatedBy: json['coupon_created_by'],
      vehicleId: json['vehicle_id'],
      discountOnProductBy: json['discount_on_product_by'],
      distance: json['distance'],
      subscriptionId: json['subscription_id'],
      cancellationNote: json['cancellation_note'],
      tableId: json['table_id'],
      waiterId: json['waiter_id'],
      fOrderStatus: json['f_order_status'],
      totalVatTaxAmount: json['total_vat_tax_amount'] ?? '0',
      totalGstTaxAmount: json['total_gst_tax_amount'] ?? '0',
      appliedCouponCode: json['discount_coupon']?['code'] ?? '',
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
      roundoff: json['round_up'] ?? 0,
      discountMemberCategory: json['discount_member_category'].toString() ?? '',
      tipTaxAmount: double.tryParse(json['tip_tax_amount'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_order_id'] = restaurantOrderId;
    data['user_name'] = username;
    data['user_id'] = userId;
    data['employee_id'] = employeeId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['transaction_reference'] = transactionReference;
    data['delivery_address_id'] = deliveryAddressId;
    data['delivery_man_id'] = deliveryManId;
    data['coupon_code'] = couponCode;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['checked'] = checked;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['callback'] = callback;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    data['delivery_address'] = deliveryAddress;
    data['scheduled'] = scheduled;
    data['restaurant_discount_amount'] = restaurantDiscountAmount;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['failed'] = failed;
    data['adjusment'] = adjusment;
    data['edited'] = edited;
    data['zone_id'] = zoneId;
    data['dm_tips'] = dmTips;
    data['processing_time'] = processingTime;
    data['free_delivery_by'] = freeDeliveryBy;
    data['refund_request_canceled'] = refundRequestCanceled;
    data['cancellation_reason'] = cancellationReason;
    data['canceled_by'] = canceledBy;
    data['tax_status'] = taxStatus;
    data['coupon_created_by'] = couponCreatedBy;
    data['vehicle_id'] = vehicleId;
    data['discount_on_product_by'] = discountOnProductBy;
    data['distance'] = distance;
    data['subscription_id'] = subscriptionId;
    data['cancellation_note'] = cancellationNote;
    data['table_id'] = tableId;
    data['waiter_id'] = waiterId;
    data['f_order_status'] = fOrderStatus;
    data['total_vat_tax_amount'] = totalVatTaxAmount;
    data['total_gst_tax_amount'] = totalGstTaxAmount;
    data['round_up'] = roundoff;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? latitude;
  String? longitude;
  String? address;
  String? footerText;
  int? minimumOrder;
  int? comission;
  bool? scheduleOrder;
  dynamic openingTime;
  dynamic closeingTime;
  int? status;
  int? vendorId;
  String? createdAt;
  String? updatedAt;
  bool? freeDelivery;
  List<int>? rating;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  bool? foodSection;
  int? tax;
  int? zoneId;
  bool? reviewsSection;
  bool? active;
  String? offDay;
  String? gstTax;
  int? selfDeliverySystem;
  bool? posSystem;
  int? minimumShippingCharge;
  String? deliveryTime;
  int? veg;
  int? nonVeg;
  int? orderCount;
  int? totalOrder;
  int? perKmShippingCharge;
  String? restaurantModel;
  dynamic maximumShippingCharge;
  String? slug;
  bool? orderSubscriptionActive;
  String? businessType;
  bool? gstStatus;
  String? gstCode;

  Restaurant({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logo,
    this.latitude,
    this.longitude,
    this.address,
    this.footerText,
    this.minimumOrder,
    this.comission,
    this.scheduleOrder,
    this.openingTime,
    this.closeingTime,
    this.status,
    this.vendorId,
    this.createdAt,
    this.updatedAt,
    this.freeDelivery,
    this.rating,
    this.coverPhoto,
    this.delivery,
    this.takeAway,
    this.foodSection,
    this.tax,
    this.zoneId,
    this.reviewsSection,
    this.active,
    this.offDay,
    this.gstTax,
    this.selfDeliverySystem,
    this.posSystem,
    this.minimumShippingCharge,
    this.deliveryTime,
    this.veg,
    this.nonVeg,
    this.orderCount,
    this.totalOrder,
    this.perKmShippingCharge,
    this.restaurantModel,
    this.maximumShippingCharge,
    this.slug,
    this.orderSubscriptionActive,
    this.businessType,
    this.gstStatus,
    this.gstCode,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logo = json['logo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    footerText = json['footer_text'];
    minimumOrder = json['minimum_order'];
    comission = json['comission'];
    scheduleOrder = json['schedule_order'];
    openingTime = json['opening_time'];
    closeingTime = json['closeing_time'];
    status = json['status'];
    vendorId = json['vendor_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    freeDelivery = json['free_delivery'];
    rating = (json['rating'] is List)
        ? List<int>.from(
            json['rating'].map((e) => int.tryParse(e.toString()) ?? 0))
        : [];
    coverPhoto = json['cover_photo'];
    delivery = json['delivery'];
    takeAway = json['take_away'];
    foodSection = json['food_section'];
    tax = json['tax'];
    zoneId = json['zone_id'];
    reviewsSection = json['reviews_section'];
    active = json['active'];
    offDay = json['off_day'];
    gstTax = json['gst_tax'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = json['minimum_shipping_charge'];
    deliveryTime = json['delivery_time'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    orderCount = json['order_count'];
    totalOrder = json['total_order'];
    perKmShippingCharge = json['per_km_shipping_charge'];
    restaurantModel = json['restaurant_model'];
    maximumShippingCharge = json['maximum_shipping_charge'];
    slug = json['slug'];
    orderSubscriptionActive = json['order_subscription_active'];
    businessType = json['business_type'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['footer_text'] = footerText;
    data['minimum_order'] = minimumOrder;
    data['comission'] = comission;
    data['schedule_order'] = scheduleOrder;
    data['opening_time'] = openingTime;
    data['closeing_time'] = closeingTime;
    data['status'] = status;
    data['vendor_id'] = vendorId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['free_delivery'] = freeDelivery;
    data['rating'] = rating;
    data['cover_photo'] = coverPhoto;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['food_section'] = foodSection;
    data['tax'] = tax;
    data['zone_id'] = zoneId;
    data['reviews_section'] = reviewsSection;
    data['active'] = active;
    data['off_day'] = offDay;
    data['gst_tax'] = gstTax;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['delivery_time'] = deliveryTime;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    data['order_count'] = orderCount;
    data['total_order'] = totalOrder;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['restaurant_model'] = restaurantModel;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['slug'] = slug;
    data['order_subscription_active'] = orderSubscriptionActive;
    data['business_type'] = businessType;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    return data;
  }
}

class OrderDetailsBar {
  int? id;
  int? foodId;
  int? orderId;
  bool? isComplementary;
  bool? isSelectComplementary;
  double? price;
  double? unitPrice;
  Map<String, dynamic>? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  dynamic discountOnFood;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? gstTaxAmount;
  dynamic variant;
  String? createdAt;
  String? updatedAt;
  dynamic itemCampaignId;
  dynamic totalAddOnPrice;
  dynamic reasonType;
  dynamic reason;
  int? foodStatus;
  int? isComplementaryFromApi;

  OrderDetailsBar({
    this.id,
    this.foodId,
    this.orderId,
    this.isComplementary,
    this.isSelectComplementary,
    this.price,
    this.unitPrice,
    this.foodDetails,
    this.variation,
    this.addOns,
    this.discountOnFood,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.gstTaxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.reasonType,
    this.reason,
    this.foodStatus,
    this.isComplementaryFromApi,
  });

  factory OrderDetailsBar.fromJson(Map<String, dynamic> json) {
    return OrderDetailsBar(
      // isComplementary: false,
      // isSelectComplementary: false,
      isComplementary: (json['complementary'] ?? 0) == 1,
      isSelectComplementary: (json['complementary'] ?? 0) == 1,
      id: json['id'],
      foodId: json['food_id'],
      orderId: json['order_id'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0
          : 0,
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString()) ?? 0
          : 0,
      foodDetails: json['food_details'] is Map<String, dynamic>
          ? json['food_details']
          : <String, dynamic>{},
      variation: json['variation'] != null
          ? List<Variations>.from(
              (json['variation'] as List).map((v) => Variations.fromJson(v)))
          : <Variations>[],
      addOns: json['add_ons'] != null
          ? List<AddOns>.from(
              (json['add_ons'] as List).map((v) => AddOns.fromJson(v)))
          : <AddOns>[],
      discountOnFood: json['discount_on_food'],
      discountType: json['discount_type'],
      quantity: json['quantity'],
      taxAmount: double.parse('${json['tax_amount'] ?? 0}'),
      gstTaxAmount: json['gst_tax_amount'],
      variant: json['variant'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      itemCampaignId: json['item_campaign_id'],
      totalAddOnPrice: json['total_add_on_price'],
      reasonType: json['reason_type'],
      reason: json['reason'],
      foodStatus: json['food_status'],
      isComplementaryFromApi: json['complementary'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    data['unit_price'] = unitPrice;
    data['food_details'] = foodDetails;
    data['variation'] = variation?.map((v) => v.toJson()).toList();
    data['add_ons'] = addOns?.map((v) => v.toJson()).toList();
    data['discount_on_food'] = discountOnFood;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['gst_tax_amount'] = gstTaxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['reason_type'] = reasonType;
    data['reason'] = reason;
    data['food_status'] = foodStatus;
    return data;
  }
}

class AddOns {
  final int? id;
  final String? name;
  final double? price;
  final int? quantity;

  AddOns({this.id, this.name, this.price, this.quantity});

  factory AddOns.fromJson(Map<String, dynamic> json) {
    return AddOns(
      id: json['id'],
      name: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class RestaurantDetails {
  final String tableArea;
  final String tableNo;
  final String waiterName;
  final String restaurantOrderFor;

  RestaurantDetails({
    this.tableArea = '',
    this.tableNo = '',
    this.waiterName = '',
    this.restaurantOrderFor = '',
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      tableArea: json['restaurant_table_area'] ?? '',
      tableNo: json['restaurant_table_no'] ?? '',
      waiterName: json['restaurant_waiter_name'] ?? '',
      restaurantOrderFor: json['restaurant_order_for'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_table_area': tableArea,
      'restaurant_table_no': tableNo,
      'restaurant_waiter_name': waiterName,
      'restaurant_order_for': restaurantOrderFor,
    };
  }
}

class RoomDetailInfo {
  final double roomPrice;
  final double advancePay;
  final double remainingPay;
  final double gstTaxAmount;
  final String gstName;
  final String gstNo;

  RoomDetailInfo({
    this.roomPrice = 0.0,
    this.advancePay = 0.0,
    this.remainingPay = 0.0,
    this.gstTaxAmount = 0.0,
    this.gstName = '',
    this.gstNo = '',
  });

  factory RoomDetailInfo.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return RoomDetailInfo(
      roomPrice: parseDouble(json['room_price']),
      advancePay: parseDouble(json['advance_payment']),
      remainingPay: parseDouble(json['balance_payment']),
      gstTaxAmount: parseDouble(json['gst_tax']),
      gstName: json['firm_name'] ?? '',
      gstNo: json['firm_gst'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_price': roomPrice,
      'advance_payment': advancePay,
      'balance_payment': remainingPay,
      'gst_tax': gstTaxAmount,
      'firm_name': gstName,
      'firm_gst': gstNo,
    };
  }
}

class DeliveryAddress {
  final String name;
  final String phone;
  final String addressType;
  final String address;
  final String pincode;
  final String dob;
  final String doa;
  final String membershipId;
  final String house;
  final String floor;
  final String road;

  DeliveryAddress({
    this.name = '',
    this.phone = '',
    this.addressType = '',
    this.address = '',
    this.pincode = '',
    this.dob = '',
    this.doa = '',
    this.membershipId = '',
    this.house = '',
    this.floor = '',
    this.road = '',
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['contact_person_name'] ?? '',
      phone: json['contact_person_number'] ?? '',
      addressType: json['address_type'] ?? '',
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      dob: json['date_of_birth'] ?? '',
      doa: json['date_of_anniversary'] ?? '',
      membershipId: json['membership_id'] ?? '',
      house: json['house'] ?? '',
      floor: json['floor'] ?? '',
      road: json['road'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_person_name': name,
      'contact_person_number': phone,
      'address_type': addressType,
      'address': address,
      'pincode': pincode,
      'date_of_birth': dob,
      'date_of_anniversary': doa,
      'membership_id': membershipId,
      'house': house,
      'floor': floor,
      'road': road,
    };
  }
}
