class CampaignModel {
  final int? id;
  final String? title;
  final String? image;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final String? startTime;
  final String? endTime;
  final String? availableDateStarts;
  final String? availableDateEnds;
  final String? vendorStatus;
  final bool? isJoined;

  const CampaignModel({
    this.id,
    this.title,
    this.image,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.startTime,
    this.endTime,
    this.availableDateStarts,
    this.availableDateEnds,
    this.vendorStatus,
    this.isJoined,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      availableDateStarts: json['available_date_starts'] as String?,
      availableDateEnds: json['available_date_ends'] as String?,
      vendorStatus: json['vendor_status'] as String?,
      isJoined: json['is_joined'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'start_time': startTime,
        'end_time': endTime,
        'available_date_starts': availableDateStarts,
        'available_date_ends': availableDateEnds,
        'vendor_status': vendorStatus,
        'is_joined': isJoined,
      };
}
