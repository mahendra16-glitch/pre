enum NotificationType {
  message,
  order,
  general,
}

class NotificationBody {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? deliveryManId;
  int? conversationId;
  String? type;

  NotificationBody({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.deliveryManId,
    this.conversationId,
    this.type,
  });

  factory NotificationBody.fromJson(Map<String, dynamic> json) {
    return NotificationBody(
      notificationType: _convertToEnum(json['order_notification']),
      orderId: json['order_id'],
      customerId: json['customer_id'],
      deliveryManId: json['delivery_man_id'],
      conversationId: json['conversation_id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_notification': notificationType?.name,
      'order_id': orderId,
      'customer_id': customerId,
      'delivery_man_id': deliveryManId,
      'conversation_id': conversationId,
      'type': type,
    };
  }

  static NotificationType _convertToEnum(String? enumString) {
    switch (enumString) {
      case 'general':
        return NotificationType.general;
      case 'order':
        return NotificationType.order;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.general;
    }
  }
}
