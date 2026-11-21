class UpdateStatusBody {
  String token;
  int orderId;
  String status;
  String otp;
  String processingTime;
  String method;
  String? reason;

  UpdateStatusBody({
    required this.token,
    required this.orderId,
    required this.status,
    required this.otp,
    required this.processingTime,
    this.reason,
  }) : method = 'put';

  factory UpdateStatusBody.fromJson(Map<String, dynamic> json) {
    return UpdateStatusBody(
      token: json['token'] as String,
      orderId: json['order_id'] as int,
      status: json['status'] as String,
      otp: json['otp'] as String,
      processingTime: json['processing_time'] as String,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['token'] = token;
    data['order_id'] = orderId;
    data['status'] = status;
    data['otp'] = otp;
    data['processing_time'] = processingTime;
    data['_method'] = method;
    if (reason != null && reason!.isNotEmpty) {
      data['reason'] = reason;
    }
    return data;
  }
}
