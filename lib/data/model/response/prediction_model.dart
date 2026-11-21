class PredictionModel {
  final String? description;
  final String? id;
  final int? distanceMeters;
  final String? placeId;
  final String? reference;

  const PredictionModel({
    this.description,
    this.id,
    this.distanceMeters,
    this.placeId,
    this.reference,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      description: json['description'] as String?,
      id: json['id'] as String?,
      distanceMeters: json['distance_meters'] as int?,
      placeId: json['place_id'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'id': id,
      'distance_meters': distanceMeters,
      'place_id': placeId,
      'reference': reference,
    };
  }
}
