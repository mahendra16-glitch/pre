class ExpenseBody {
  int? totalSize;
  int? limit;
  String? offset;
  List<Expense>? expense;

  ExpenseBody({this.totalSize, this.limit, this.offset, this.expense});

  factory ExpenseBody.fromJson(Map<String, dynamic> json) {
    return ExpenseBody(
      totalSize: json['total_size'] as int?,
      limit: json['limit'] as int?,
      offset: json['offset'] as String?,
      expense: (json['expense'] as List<dynamic>?)
          ?.map((v) => Expense.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'expense': expense?.map((v) => v.toJson()).toList(),
    };
  }
}

class Expense {
  int? id;
  String? type;
  double? amount;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  int? restaurantId;
  int? orderId;

  Expense({
    this.id,
    this.type,
    this.amount,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.restaurantId,
    this.orderId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      type: json['type'] as String?,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'] as double?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      createdBy: json['created_by'] as String?,
      restaurantId: json['restaurant_id'] as int?,
      orderId: json['order_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'restaurant_id': restaurantId,
      'order_id': orderId,
    };
  }
}
