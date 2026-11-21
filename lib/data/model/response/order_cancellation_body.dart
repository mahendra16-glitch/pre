class OrderCancellationBody {
  int? totalSize;
  String? limit;
  String? offset;
  List<CancellationData>? reasons;

  OrderCancellationBody({
    this.totalSize,
    this.limit,
    this.offset,
    this.reasons,
  });

  factory OrderCancellationBody.fromJson(Map<String, dynamic> json) {
    return OrderCancellationBody(
      totalSize: json['total_size'] as int?,
      limit: json['limit'] as String?,
      offset: json['offset'] as String?,
      reasons: (json['reasons'] as List<dynamic>?)
          ?.map((v) => CancellationData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'reasons': reasons?.map((v) => v.toJson()).toList(),
    };
  }
}

class CancellationData {
  int? id;
  String? reason;
  String? userType;
  int? status;
  String? createdAt;
  String? updatedAt;

  CancellationData({
    this.id,
    this.reason,
    this.userType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CancellationData.fromJson(Map<String, dynamic> json) {
    return CancellationData(
      id: json['id'] as int?,
      reason: json['reason'] as String?,
      userType: json['user_type'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'user_type': userType,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
