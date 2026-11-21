import 'package:mygenie_restaurant/data/model/response/cart_model.dart';

class LocalOrderModel {
  List<CartModel> cartList;
  double orderAmount;
  double subTotal;
  double gstTaxAmount;
  double serviceCharge;
  double tips;
  String orderId;
  String createdAt;
  String paymentMethod;
  double discount;
  String name;
  String phoneNumber;
  String notes;
  String employeeName;
  int employeeId;

  LocalOrderModel({
    required this.cartList,
    required this.orderAmount,
    required this.subTotal,
    required this.gstTaxAmount,
    required this.serviceCharge,
    required this.tips,
    required this.orderId,
    required this.createdAt,
    required this.paymentMethod,
    required this.discount,
    required this.name,
    required this.phoneNumber,
    required this.notes,
    required this.employeeName,
    required this.employeeId,
  });

  factory LocalOrderModel.fromJson(Map<String, dynamic> json) {
    return LocalOrderModel(
      cartList: (json['cartList'] as List<dynamic>?)
              ?.map((v) => CartModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0.0,
      gstTaxAmount: (json['gstTaxAmount'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      orderId: json['orderId'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      name: json['name'] as String? ?? '',
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      employeeId: json['waiter_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'subTotal': subTotal,
      'waiter_id': employeeId,
      'employeeName': employeeName,
      'notes': notes,
      'name': name,
      'serviceCharge': serviceCharge,
      'tips': tips,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'discount': discount,
      'orderAmount': orderAmount,
      'gstTaxAmount': gstTaxAmount,
      'paymentMethod': paymentMethod,
      'cartList': cartList.map((v) => v.toJson()).toList(),
    };
  }
}
