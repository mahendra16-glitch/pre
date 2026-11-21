class ZoneResponseModel {
  final bool? isSuccess;
  final List<int>? zoneIds;
  final String? message;
  final List<ZoneData>? zoneData;

  ZoneResponseModel({
    this.isSuccess,
    this.message,
    this.zoneIds,
    this.zoneData,
  });

  factory ZoneResponseModel.fromJson(Map<String, dynamic> json) {
    return ZoneResponseModel(
      isSuccess: json['is_success'] ?? false,
      message: json['message'] ?? '',
      zoneIds: json['zone_ids'] != null ? List<int>.from(json['zone_ids']) : [],
      zoneData: json['zone_data'] != null
          ? List<ZoneData>.from(
              (json['zone_data'] as List).map((e) => ZoneData.fromJson(e)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'zone_ids': zoneIds,
      'zone_data': zoneData!.map((e) => e.toJson()).toList(),
    };
  }
}

class ZoneData {
  final int id;
  final int status;
  final double? minimumShippingCharge;
  final double? perKmShippingCharge;

  ZoneData({
    required this.id,
    required this.status,
    this.minimumShippingCharge,
    this.perKmShippingCharge,
  });

  factory ZoneData.fromJson(Map<String, dynamic> json) {
    return ZoneData(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      minimumShippingCharge: json['minimum_shipping_charge'] != null
          ? (json['minimum_shipping_charge'] as num).toDouble()
          : null,
      perKmShippingCharge: json['per_km_shipping_charge'] != null
          ? (json['per_km_shipping_charge'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'minimum_shipping_charge': minimumShippingCharge,
      'per_km_shipping_charge': perKmShippingCharge,
    };
  }
}
