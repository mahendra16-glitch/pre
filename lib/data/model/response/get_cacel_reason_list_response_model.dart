class CancelReasonListResponseModel {
  final int? totalSize;
  final String? limit;
  final String? offset;
  List<Reasons>? reasons;

  CancelReasonListResponseModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.reasons,
  });

  factory CancelReasonListResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelReasonListResponseModel(
      totalSize: json['total_size'] as int?,
      limit: json['limit'] as String?,
      offset: json['offset'] as String?,
      reasons: (json['reasons'] as List<dynamic>?)
          ?.map((v) => Reasons.fromJson(v as Map<String, dynamic>))
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

class Reasons {
  final int? id;
  final String? reason;
  final String? userType;
  final String? itemType;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  Reasons({
    this.id,
    this.reason,
    this.userType,
    this.itemType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Reasons.fromJson(Map<String, dynamic> json) {
    return Reasons(
      id: json['id'] as int?,
      reason: json['reason'] as String?,
      userType: json['user_type'] as String?,
      itemType: json['item_type'] as String?,
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
      'item_type': itemType,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
