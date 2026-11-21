class GetViewTabBillsResponseModel {
  List<CustomerTransactionList>? customerTransactionList;
  List<CustomerTransactionList>? customerTransactionListDebit;

  String? tapStartDate;
  String? lastTapCreditDate;
  String? lastTapCreditAmount;
  String? lastTapDebitDate;
  String? lastTapDebitAmount;

  GetViewTabBillsResponseModel({
    this.customerTransactionList,
    this.customerTransactionListDebit,
    this.tapStartDate,
    this.lastTapCreditDate,
    this.lastTapCreditAmount,
    this.lastTapDebitDate,
    this.lastTapDebitAmount,
  });

  GetViewTabBillsResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['customer-transaction-list'] != null) {
      customerTransactionList = List<CustomerTransactionList>.from(
        (json['customer-transaction-list'] as List)
            .map((v) => CustomerTransactionList.fromJson(v)),
      );
    }

    if (json['customer-transaction-list-debit'] != null) {
      customerTransactionListDebit = List<CustomerTransactionList>.from(
        (json['customer-transaction-list-debit'] as List)
            .map((v) => CustomerTransactionList.fromJson(v)),
      );
    }

    tapStartDate = json['tap_start_date']?.toString();
    lastTapCreditDate = json['last_tap_credit_date']?.toString();
    lastTapCreditAmount = json['last_tap_credit_amount']?.toString();
    lastTapDebitDate = json['last_tap_debit_date']?.toString();
    lastTapDebitAmount = json['last_tap_debit_amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customerTransactionList != null) {
      data['customer-transaction-list'] =
          customerTransactionList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerTransactionList {
  final int? id;
  final int? orderId;
  final String? restaurantOrderId;
  final int? waiterId;
  final int? customerId;
  final String? creditOrderAmount;
  final String? debitOrderAmount;
  final String? transactionId;
  final String? currentBalance;
  final String? paymentStatus;
  final String? comments;
  final String? createdAt;
  final String? updatedAt;
  final String? orderDate;

  CustomerTransactionList({
    this.id,
    this.orderId,
    this.restaurantOrderId,
    this.waiterId,
    this.customerId,
    this.creditOrderAmount,
    this.debitOrderAmount,
    this.transactionId,
    this.currentBalance,
    this.paymentStatus,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.orderDate,
  });

  factory CustomerTransactionList.fromJson(Map<String, dynamic> json) {
    return CustomerTransactionList(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      restaurantOrderId: (json['restaurant_order_id'] ?? '0').toString(),
      waiterId: json['waiter_id'] as int?,
      customerId: json['customer_id'] as int?,
      creditOrderAmount: json['credit_order_amount']?.toString(),
      debitOrderAmount: json['debit_order_amount']?.toString(),
      transactionId: json['transaction_id']?.toString() ?? '',
      currentBalance: json['current_balance']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      comments: json['comments']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      orderDate: json['order_created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'waiter_id': waiterId,
      'customer_id': customerId,
      'credit_order_amount': creditOrderAmount,
      'debit_order_amount': debitOrderAmount,
      'transaction_id': transactionId,
      'current_balance': currentBalance,
      'payment_status': paymentStatus,
      'comments': comments,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_created_at': orderDate,
      'restaurant_order_id': restaurantOrderId,
    };
  }
}
