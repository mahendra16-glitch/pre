class RoomListWithAmountResponseModel {
  final int roomId;
  final String roomName;
  final String orderAmount;

  RoomListWithAmountResponseModel({
    required this.roomId,
    required this.roomName,
    required this.orderAmount,
  });

  factory RoomListWithAmountResponseModel.fromJson(Map<String, dynamic> json) {
    return RoomListWithAmountResponseModel(
      roomId: json['room_id'] as int? ?? 0,
      roomName: json['room_name'] as String? ?? '',
      orderAmount: '${json['total_order_amount'] ?? '0'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'room_name': roomName,
      'total_order_amount': orderAmount,
    };
  }
}
