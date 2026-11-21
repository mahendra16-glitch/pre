class GetRoomPaidOrderDetailResponse {
  final int id;
  final int roomId;
  final int restaurantId;
  final int orderId;
  final String orderAmount;
  final String restaurantOrderId;
  final int orderStatus;
  final String createdAt;
  final String updatedAt;

  const GetRoomPaidOrderDetailResponse({
    required this.id,
    required this.roomId,
    required this.restaurantId,
    required this.orderId,
    required this.orderAmount,
    required this.restaurantOrderId,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GetRoomPaidOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return GetRoomPaidOrderDetailResponse(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      restaurantId: json['restaurant_id'] as int,
      orderId: json['order_id'] as int,
      orderAmount: '${json['order_amount'] ?? '0'}',
      orderStatus: json['order_status'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      restaurantOrderId: json['restaurant_order_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'restaurant_id': restaurantId,
      'restaurant_order_id': restaurantOrderId,
      'order_id': orderId,
      'order_amount': orderAmount,
      'order_status': orderStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
