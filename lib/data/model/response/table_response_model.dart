import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';

class TableResponseModel {
  final int id;
  final int restaurantId;
  final String title;
  final String tableNo;
  final String type;
  final int status;
  final String createdAt;
  final String updatedAt;
  String isEngage;
  OrderList? order;

  TableResponseModel({
    this.id = 0,
    this.restaurantId = 0,
    this.title = '',
    this.tableNo = '',
    this.type = '',
    this.status = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.isEngage = '',
    this.order,
  });

  factory TableResponseModel.fromJson(Map<String, dynamic> json) {
    return TableResponseModel(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] ?? 0,
      title: json['title'] as String? ?? '',
      tableNo: json['table_no'] as String? ?? '',
      type: json['rtype'] as String? ?? '',
      isEngage: json['engage'] as String? ?? 'No',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'title': title,
      'table_no': tableNo,
      'status': status,
      'rtype': type,
      'engage': isEngage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
