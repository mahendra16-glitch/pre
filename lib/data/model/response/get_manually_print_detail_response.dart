import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';

class GetManuallyPrintDetailResponse {
  bool? status;
  int? count;
  List<Bill>? bill;

  GetManuallyPrintDetailResponse({this.status, this.count, this.bill});

  GetManuallyPrintDetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    if (json['bill'] != null) {
      bill = <Bill>[];
      json['bill'].forEach((v) {
        bill!.add(new Bill.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    if (this.bill != null) {
      data['bill'] = this.bill!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bill {
  int? id;
  String? orderId;
  String? restaurantOrderId;
  String? printType;
  double? paymentAmount;
  double? grantAmount;
  double? orderSubtotal;
  double? orderItemtotal;
  double? discountAmount;
  String? couponCode;
  double? loyaltyDiscountAmount;
  double? walletUsedAmount;
  String? orderDate;
  String? waiterName;
  String? tableName;
  String? custName;
  String? custPhone;
  String? custGstName;
  String? custGst;
  List<OrderDetailsBar>? billFoodList;
  String? orderNote;
  double? serviceChargeAmount;
  double? roomRemainingPay;
  double? roomAdvancePay;
  String? roomGst;
  String? deliveryCustName;
  String? deliveryAddressType;
  String? deliveryCustAddress;
  String? deliveryCustPincode;
  String? deliveryCustPhone;
  double? tipAmount;
  String? orderType;
  double? gstTax;
  double? vatTax;
  double? deliveryCharge;
  int? isProcessed;
  String? createdAt;
  String? updatedAt;
  String? rType;
  String? paymentMethod;
  String? paymentStatus;
  List<AssociatedOrder>? associatedOrders;

  Bill({
    this.id,
    this.orderId,
    this.printType,
    this.paymentAmount,
    this.grantAmount,
    this.orderSubtotal,
    this.orderItemtotal,
    this.discountAmount,
    this.couponCode,
    this.loyaltyDiscountAmount,
    this.walletUsedAmount,
    this.orderDate,
    this.waiterName,
    this.tableName,
    this.custName,
    this.custPhone,
    this.custGstName,
    this.custGst,
    this.billFoodList,
    this.orderNote,
    this.serviceChargeAmount,
    this.roomRemainingPay,
    this.roomAdvancePay,
    this.roomGst,
    this.deliveryCustName,
    this.deliveryAddressType,
    this.deliveryCustAddress,
    this.deliveryCustPincode,
    this.deliveryCustPhone,
    this.tipAmount,
    this.orderType,
    this.gstTax,
    this.vatTax,
    this.deliveryCharge,
    this.isProcessed,
    this.createdAt,
    this.updatedAt,
    this.associatedOrders,
    this.rType,
    this.paymentMethod,
    this.paymentStatus,
  });

  Bill.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    restaurantOrderId = json['restaurant_order_id'];
    printType = json['print_type'];
    paymentAmount = double.parse('${json['payment_amount'] ?? 0}');
    grantAmount = double.parse('${json['grant_amount'] ?? 0}');
    orderSubtotal = double.parse('${json['order_subtotal'] ?? 0}');
    orderItemtotal = double.parse('${json['order_item_total'] ?? 0}');
    discountAmount = double.parse('${json['discount_amount'] ?? 0}');
    couponCode = json['coupon_code'];
    loyaltyDiscountAmount =
        double.parse('${json['loyalty_discount_amount'] ?? 0}');
    walletUsedAmount = double.parse('${json['wallet_used_amount'] ?? 0}');
    orderDate = json['order_date'];
    waiterName = json['waiter_name'];
    tableName = json['table_name'];
    custName = json['cust_name'];
    custPhone = json['cust_phone'];
    custGstName = json['cust_gst_name'];
    custGst = json['cust_gst'];
    if (json['bill_food_list'] != null) {
      billFoodList = <OrderDetailsBar>[];
      json['bill_food_list'].forEach((v) {
        billFoodList!.add(new OrderDetailsBar.fromJson(v));
      });
    }
    orderNote = json['order_note'];
    serviceChargeAmount = double.parse('${json['service_charge_amount'] ?? 0}');
    roomRemainingPay = double.parse('${json['room_remaining_pay'] ?? 0}');
    roomAdvancePay = double.parse('${json['room_advance_pay'] ?? 0}');
    roomGst = json['room_gst'];
    deliveryCustName = json['delivery_cust_name'];
    deliveryAddressType = json['delivery_address_type'];
    deliveryCustAddress = json['delivery_cust_address'];
    deliveryCustPincode = json['delivery_cust_pincode'];
    deliveryCustPhone = json['delivery_cust_phone'];
    tipAmount = double.parse('${json['tip_amount'] ?? 0}');
    orderType = json['order_type'];
    gstTax = double.parse('${json['gst_tax'] ?? 0}');
    vatTax = double.parse('${json['vat_tax'] ?? 0}');
    deliveryCharge = double.parse('${json['delivery_charge'] ?? 0}');
    isProcessed = json['is_processed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    rType = json['rtype'] ?? '';
    paymentMethod = json['payment_method'] ?? '';
    paymentStatus = json['payment_status'] ?? '';
    if (json['associated_orders'] != null) {
      associatedOrders = <AssociatedOrder>[];
      json['associated_orders'].forEach((v) {
        associatedOrders!.add(AssociatedOrder.fromJson(v));
      });
    } else {
      associatedOrders = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['print_type'] = this.printType;
    data['payment_amount'] = this.paymentAmount;
    data['grant_amount'] = this.grantAmount;
    data['order_subtotal'] = this.orderSubtotal;
    data['discount_amount'] = this.discountAmount;
    data['coupon_code'] = this.couponCode;
    data['loyalty_discount_amount'] = this.loyaltyDiscountAmount;
    data['wallet_used_amount'] = this.walletUsedAmount;
    data['order_date'] = this.orderDate;
    data['waiter_name'] = this.waiterName;
    data['table_name'] = this.tableName;
    data['cust_name'] = this.custName;
    data['cust_phone'] = this.custPhone;
    data['cust_gst_name'] = this.custGstName;
    data['cust_gst'] = this.custGst;
    if (this.billFoodList != null) {
      data['bill_food_list'] =
          this.billFoodList!.map((v) => v.toJson()).toList();
    }
    data['order_note'] = this.orderNote;
    data['service_charge_amount'] = this.serviceChargeAmount;
    data['room_remaining_pay'] = this.roomRemainingPay;
    data['room_advance_pay'] = this.roomAdvancePay;
    data['room_gst'] = this.roomGst;
    data['delivery_cust_name'] = this.deliveryCustName;
    data['delivery_address_type'] = this.deliveryAddressType;
    data['delivery_cust_address'] = this.deliveryCustAddress;
    data['delivery_cust_pincode'] = this.deliveryCustPincode;
    data['delivery_cust_phone'] = this.deliveryCustPhone;
    data['tip_amount'] = this.tipAmount;
    data['order_type'] = this.orderType;
    data['gst_tax'] = this.gstTax;
    data['vat_tax'] = this.vatTax;
    data['delivery_charge'] = this.deliveryCharge;

    data['is_processed'] = this.isProcessed;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['rtype'] = this.rType;
    data['payment_status'] = this.paymentStatus;
    data['payment_method'] = this.paymentMethod;
    if (this.associatedOrders != null) {
      data['associated_orders'] =
          this.associatedOrders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssociatedOrder {
  int? id;
  int? roomId;
  int? orderId;
  String? restaurantOrderId;
  double? orderAmount;
  int? orderStatus;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;

  AssociatedOrder({
    this.id,
    this.roomId,
    this.orderId,
    this.restaurantOrderId,
    this.orderAmount,
    this.orderStatus,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
  });

  AssociatedOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    orderId = json['order_id'];
    restaurantOrderId = json['restaurant_order_id'];
    // ⚠️ order_amount comes as int (71) not double — tryParse handles both
    orderAmount = double.tryParse('${json['order_amount'] ?? 0}') ?? 0.0;
    orderStatus = json['order_status'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['room_id'] = this.roomId;
    data['order_id'] = this.orderId;
    data['restaurant_order_id'] = this.restaurantOrderId;
    data['order_amount'] = this.orderAmount;
    data['order_status'] = this.orderStatus;
    data['restaurant_id'] = this.restaurantId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
