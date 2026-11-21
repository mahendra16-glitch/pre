class GetPaidOrdersResponse {
  final List<Orders> orders;

  GetPaidOrdersResponse({required this.orders});

  factory GetPaidOrdersResponse.fromJson(Map<String, dynamic> json) {
    return GetPaidOrdersResponse(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((v) => Orders.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((v) => v.toJson()).toList(),
    };
  }
}

class Orders {
  final int? id;
  final int? employeeId;
  final String restaurantOrderId;
  final String transactionNo;
  final double orderAmount;
  final double restaurantDiscountAmount;
  final String? totalVatTaxAmount;
  final String? totalGstTaxAmount;
  final String? totalServiceTaxAmount;
  final String? tokenNo;
  LoyaltyInfo? loyaltyInfo;
  CouponInfo? couponInfo;
  WalletInfo? walletInfo;
  final String? orderStatus;
  final String? paymentStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? collectBillDate;
  String? paymentMethod;
  final String? paymentType;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? username;
  final String? waiterName;
  final String? tableNo;
  final String tipAmount;
    List<OnlinePay>? onlinePay;

  List<PartialPayments>? partialPayments;

  Orders(
      {this.id,
      this.employeeId,
      required this.restaurantOrderId,
      required this.transactionNo,
      required this.orderAmount,
      required this.restaurantDiscountAmount,
      this.totalVatTaxAmount,
      this.totalGstTaxAmount,
      this.totalServiceTaxAmount,
      this.tokenNo,
      this.loyaltyInfo,
      this.couponInfo,
      this.walletInfo,
      this.orderStatus,
      this.paymentStatus,
      this.createdAt,
      this.updatedAt,
      this.collectBillDate,
      this.paymentMethod,
      this.paymentType,
      this.fName,
      this.lName,
      this.phone,
      this.email,
      this.username,
      this.waiterName,
      this.tableNo,
      required this.tipAmount,
            this.onlinePay,

      this.partialPayments});

  factory Orders.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null || value == '') return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Orders(
      id: json['id'] as int?,
      employeeId: json['employee_id'] as int?,
      restaurantOrderId: (json['restaurant_order_id'] == null ||
              json['restaurant_order_id'] == '')
          ? '0'
          : json['restaurant_order_id'].toString(),
      transactionNo: json['transaction_reference']?.toString() ?? '',
      orderAmount: parseDouble(json['order_amount']),
      restaurantDiscountAmount: parseDouble(json['restaurant_discount_amount']),
      totalVatTaxAmount: json['total_vat_tax_amount']?.toString(),
      totalGstTaxAmount: json['total_gst_tax_amount']?.toString(),
          tokenNo :json['daily_token'] ?? '',

      totalServiceTaxAmount: json['total_service_tax_amount']?.toString(),
      loyaltyInfo: json['loyalty_info'] != null
          ? new LoyaltyInfo.fromJson(json['loyalty_info'])
          : null,
      couponInfo: json['coupon_info'] != null
          ? new CouponInfo.fromJson(json['coupon_info'])
          : null,
      walletInfo: json['wallet_info'] != null
          ? new WalletInfo.fromJson(json['wallet_info'])
          : null,
      orderStatus: json['order_status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      collectBillDate: json['collect_bill']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      fName: json['f_name']?.toString() ?? '',
      lName: json['l_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: (json['email'] == null || json['email'] == 'order@mygenie.com')
          ? ''
          : json['email'].toString(),
      username: json['user_name']?.toString() ?? '',
      waiterName: json['waiter_name']?.toString() ?? '',
      tableNo: '${json['table_no'] ?? ''}',
      tipAmount: json['tip_amount']?.toString() ?? '0',
      partialPayments: json['partial_payments'] != null
          ? (json['partial_payments'] as List)
              .map((v) => PartialPayments.fromJson(v))
              .toList()
          : [],
      onlinePay: json['online_pay'] != null
          ? (json['online_pay'] as List)
              .map((v) => OnlinePay.fromJson(v))
              .toList()
          : [],
          
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_amount': orderAmount,
      'restaurant_discount_amount': restaurantDiscountAmount,
      'transaction_reference': transactionNo,
      'total_vat_tax_amount': totalVatTaxAmount,
      'total_gst_tax_amount': totalGstTaxAmount,
      'total_service_tax_amount': totalServiceTaxAmount,
      // 'f_order_status': fOrderStatus,
      // 'b_order_status': bOrderStatus,
      // 'k_order_status': kOrderStatus,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'waiter_name': waiterName,
      'tip_amount': tipAmount,
    };
  }
}

class PartialPayments {
  int? id;
  int? orderId;
  int? waiterId;
  int? restaurantId;
  String? paymentMode;
  String? amount;
  String? paymentStatus;
  String? transactionId;
  String? createdAt;
  String? updatedAt;

  PartialPayments(
      {this.id,
      this.orderId,
      this.waiterId,
      this.restaurantId,
      this.paymentMode,
      this.amount,
      this.paymentStatus,
      this.transactionId,
      this.createdAt,
      this.updatedAt});

  PartialPayments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    waiterId = json['waiter_id'];
    restaurantId = json['restaurant_id'];
    paymentMode = json['payment_mode'] ?? '';
    amount = json['amount'] ?? '0';
    paymentStatus = json['payment_status'];
    transactionId = '${json['transaction_id'] ?? ''}';
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['waiter_id'] = this.waiterId;
    data['restaurant_id'] = this.restaurantId;
    data['payment_mode'] = this.paymentMode;
    data['amount'] = this.amount;
    data['payment_status'] = this.paymentStatus;
    data['transaction_id'] = this.transactionId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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
    couponTitle = json['coupon_title'];
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
class OnlinePay {
  String? type;
  String? gateway;
  String? referenceId;
  String? amount;
  String? status;
  String? createdAt;

  OnlinePay(
      {this.type,
      this.gateway,
      this.referenceId,
      this.amount,
      this.status,
      this.createdAt});

  OnlinePay.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    gateway = json['gateway'];
    referenceId = json['reference_id']??'';
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['gateway'] = this.gateway;
    data['reference_id'] = this.referenceId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
