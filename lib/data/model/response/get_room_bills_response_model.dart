class GetRoomBillsResponseModel {
  final int? id;
  final int? restaurantId;
  final int? roomId;
  final int? orderId;
  final String? orderAmount;
  final String? restaurantOrderId;
  final dynamic orderStatus;
  final String? createdAt;
  final String? updatedAt;

  const GetRoomBillsResponseModel({
    this.id,
    this.restaurantId,
    this.roomId,
    this.orderId,
    this.orderAmount,
    this.restaurantOrderId,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory GetRoomBillsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetRoomBillsResponseModel(
      id: json['id'] as int?,
      restaurantId: json['restaurant_id'] as int?,
      roomId: json['room_id'] as int?,
      orderId: json['order_id'] as int?,
      orderAmount: (json['order_amount'] ?? '0').toString(),
      restaurantOrderId: (json['restaurant_order_id'] == null ||
              json['restaurant_order_id'] == '')
          ? '0'
          : json['restaurant_order_id'].toString(),
      orderStatus: json['order_status'],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Maps [associated_order_list] from collect-order-bill-show to the same
  /// shape as get-room-order-details for UI, print, and payment payloads.
  factory GetRoomBillsResponseModel.fromCollectBillAssociatedOrder({
    required int? orderId,
    String? restaurantOrderId,
    String? orderAmount,
    String? collectBillDate,
    int? roomId,
  }) {
    final displayOrderId = restaurantOrderId?.toString() ?? '';
    return GetRoomBillsResponseModel(
      orderId: orderId,
      roomId: roomId,
      orderAmount: (orderAmount ?? '0').toString(),
      restaurantOrderId: displayOrderId.isEmpty ? '0' : displayOrderId,
      createdAt: collectBillDate ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'room_id': roomId,
      'order_id': orderId,
      'order_amount': orderAmount,
      'restaurant_order_id': restaurantOrderId,
      'order_status': orderStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
