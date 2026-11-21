import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';

class GetCancelOrderListResponse {
  List<GetCancelOrderList>? orders;

  GetCancelOrderListResponse({this.orders});

  GetCancelOrderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <GetCancelOrderList>[];
      json['orders'].forEach((v) {
        orders!.add(GetCancelOrderList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetCancelOrderList {
  int? id;
  String? restaurantOrderId;
  dynamic? userId;
  String? userName;
  int? employeeId;
  String? orderStatus;
  int? orderAmount;
  int? couponDiscountAmount;
  String? paymentStatus;
  int? totalTaxAmount;
  String? roundUp;
  String? paymentMethod;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  int? deliveryCharge;

  String? paymentType;
  dynamic? cancelAt;
  Null? deliveryAddress;
  int? scheduled;
  int? restaurantDiscountAmount;
  String? orderDiscount;
  String? comunityDiscount;
  int? originalDeliveryCharge;
  String? adjusment;
  int? edited;
  int? dmTips;
  dynamic? cancellationReason;
  dynamic? transactionId;
  dynamic? canceledBy;
  dynamic? taxStatus;
  dynamic? vehicleId;
  String? discountOnProductBy;
  int? distance;
  String? cancellationNote;
  dynamic tablepart;
  int? tableId;
  int? waiterId;
  String? deliveryManStatus;
  String? stationOrderStatus;
  int? fOrderStatus;
  int? bOrderStatus;
  String? tipAmount;
  String? totalVatTaxAmount;
  int? kOrderStatus;
  String? totalGstTaxAmount;
  String? totalServiceTaxAmount;
  String? audioFile;
  int? orderEditCount;  String? printKot;
  String? printBillStatus;
  String? orderDispatchStatus;
  String? tipTaxAmount;
  String? serviceGstTaxAmount;

  dynamic? fName;
  dynamic? lName;
  dynamic? email;
  String? phone;
  String? waiterName;
  String? tableNo;
  List<OrderDetails>? orderDetails;

  GetCancelOrderList(
      {this.id,
      this.restaurantOrderId,
      this.userId,
      this.userName,
      this.employeeId,
      this.orderStatus,
      this.orderAmount,
      this.couponDiscountAmount,
      this.paymentStatus,
      this.totalTaxAmount,
      this.roundUp,
      this.paymentMethod,
      this.orderNote,
      this.orderType,
      this.checked,
      this.restaurantId,
      this.createdAt,
      this.updatedAt,
      this.deliveryCharge,
      this.paymentType,
      this.cancelAt,
      this.deliveryAddress,
      this.scheduled,
      this.restaurantDiscountAmount,
      this.orderDiscount,
      this.comunityDiscount,
      this.originalDeliveryCharge,
      this.adjusment,
      this.edited,
      this.dmTips,
      this.cancellationReason,
      this.transactionId,
      this.canceledBy,
      this.taxStatus,
      this.vehicleId,
      this.discountOnProductBy,
      this.distance,
      this.cancellationNote,
      this.tablepart,
      this.tableId,
      this.waiterId,
      this.deliveryManStatus,
      this.stationOrderStatus,
      this.fOrderStatus,
      this.bOrderStatus,
      this.tipAmount,
      this.totalVatTaxAmount,
      this.kOrderStatus,
      this.totalGstTaxAmount,
      this.totalServiceTaxAmount,
    
      this.audioFile,
      this.orderEditCount,
      this.printKot,
      this.printBillStatus,
    
      this.orderDispatchStatus,
      this.tipTaxAmount,
      this.serviceGstTaxAmount,

      this.fName,
      this.lName,
      this.email,
      this.phone,
      this.waiterName,
      this.tableNo,
      this.orderDetails,
   });

  GetCancelOrderList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantOrderId = json['restaurant_order_id'];
    userId = json['user_id'];
    userName = json['user_name']??'';
    employeeId = json['employee_id'];
    orderStatus = json['order_status'];
    orderAmount = json['order_amount'];
    couponDiscountAmount = json['coupon_discount_amount'];
    paymentStatus = json['payment_status'];
    totalTaxAmount = json['total_tax_amount'];
    roundUp = json['round_up'];
    paymentMethod = json['payment_method'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    checked = json['checked'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge'];
    paymentType = json['payment_type'];
    cancelAt = json['cancel_at'];
    deliveryAddress = json['delivery_address'];
    scheduled = json['scheduled'];
    restaurantDiscountAmount = json['restaurant_discount_amount'];
    orderDiscount = json['order_discount'];
    comunityDiscount = json['comunity_discount'];
    originalDeliveryCharge = json['original_delivery_charge'];
    adjusment = json['adjusment'];
    edited = json['edited'];
    dmTips = json['dm_tips'];
    cancellationReason = json['cancellation_reason'];
    transactionId = json['transaction_id'];
    canceledBy = json['canceled_by'];
    taxStatus = json['tax_status'];
    vehicleId = json['vehicle_id'];
    discountOnProductBy = json['discount_on_product_by'];
    distance = json['distance'];
    cancellationNote = json['cancellation_note'];
    tablepart = json['tablepart'];
    tableId = json['table_id'];
    waiterId = json['waiter_id'];
    deliveryManStatus = json['delivery_man_status'];
    stationOrderStatus = json['station_order_status'];
    fOrderStatus = json['f_order_status'];
    bOrderStatus = json['b_order_status'];
    tipAmount = json['tip_amount'];
    totalVatTaxAmount = json['total_vat_tax_amount'];
    kOrderStatus = json['k_order_status'];
    totalGstTaxAmount = json['total_gst_tax_amount'];
    totalServiceTaxAmount = json['total_service_tax_amount'];
    audioFile = json['audio_file'];
    orderEditCount = json['order_edit_count'];
    printKot = json['print_kot'];
    printBillStatus = json['print_bill_status'];
  
    orderDispatchStatus = json['order_dispatch_status'];
    tipTaxAmount = json['tip_tax_amount'];
    serviceGstTaxAmount = json['service_gst_tax_amount'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    phone = json['phone']??'';
    waiterName = json['waiter_name'];
    tableNo = json['table_no'];
    if (json['order_details'] != null) {
      orderDetails = <OrderDetails>[];
      json['order_details'].forEach((v) {
        orderDetails!.add(new OrderDetails.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['restaurant_order_id'] = this.restaurantOrderId;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['employee_id'] = this.employeeId;
    data['order_status'] = this.orderStatus;
    data['order_amount'] = this.orderAmount;
    data['coupon_discount_amount'] = this.couponDiscountAmount;
    data['payment_status'] = this.paymentStatus;
    data['total_tax_amount'] = this.totalTaxAmount;
    data['round_up'] = this.roundUp;
    data['payment_method'] = this.paymentMethod;
    data['order_note'] = this.orderNote;
    data['order_type'] = this.orderType;
    data['checked'] = this.checked;
    data['restaurant_id'] = this.restaurantId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['delivery_charge'] = this.deliveryCharge;
    data['payment_type'] = this.paymentType;
    data['cancel_at'] = this.cancelAt;
    data['delivery_address'] = this.deliveryAddress;
    data['scheduled'] = this.scheduled;
    data['restaurant_discount_amount'] = this.restaurantDiscountAmount;
    data['order_discount'] = this.orderDiscount;
    data['comunity_discount'] = this.comunityDiscount;
    data['original_delivery_charge'] = this.originalDeliveryCharge;
    data['adjusment'] = this.adjusment;
    data['edited'] = this.edited;
    data['dm_tips'] = this.dmTips;
    data['cancellation_reason'] = this.cancellationReason;
    data['transaction_id'] = this.transactionId;
    data['canceled_by'] = this.canceledBy;
    data['tax_status'] = this.taxStatus;
    data['vehicle_id'] = this.vehicleId;
    data['discount_on_product_by'] = this.discountOnProductBy;
    data['distance'] = this.distance;
    data['cancellation_note'] = this.cancellationNote;
    data['tablepart'] = this.tablepart;
    data['table_id'] = this.tableId;
    data['waiter_id'] = this.waiterId;
    data['delivery_man_status'] = this.deliveryManStatus;
    data['station_order_status'] = this.stationOrderStatus;
    data['f_order_status'] = this.fOrderStatus;
    data['b_order_status'] = this.bOrderStatus;
    data['tip_amount'] = this.tipAmount;
    data['total_vat_tax_amount'] = this.totalVatTaxAmount;
    data['k_order_status'] = this.kOrderStatus;
    data['total_gst_tax_amount'] = this.totalGstTaxAmount;
    data['total_service_tax_amount'] = this.totalServiceTaxAmount;
    data['audio_file'] = this.audioFile;
    data['order_edit_count'] = this.orderEditCount;
    data['print_kot'] = this.printKot;
    data['print_bill_status'] = this.printBillStatus;

    data['order_dispatch_status'] = this.orderDispatchStatus;
    data['tip_tax_amount'] = this.tipTaxAmount;
    data['service_gst_tax_amount'] = this.serviceGstTaxAmount;

    data['f_name'] = this.fName;
    data['l_name'] = this.lName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['waiter_name'] = this.waiterName;
    data['table_no'] = this.tableNo;
    if (this.orderDetails != null) {
      data['order_details'] =
          this.orderDetails!.map((v) => v.toJson()).toList();
    }
  
    return data;
  }
}



class CategoryIds {
  String? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['position'] = this.position;
    return data;
  }
}
