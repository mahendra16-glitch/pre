class DeliveryManModel {
  final int? id;
  final String? fName;
  final String? lName;
  final String? phone;
  final String? email;
  final String? identityNumber;
  final String? identityType;
  final List<String>? identityImage;
  final String? image;
  final bool? status;
  final int? active;
  final int? earning;
  final String? type;
  final int? ordersCount;
  final double? avgRating;
  final int? ratingCount;
  final double? cashInHands;

  const DeliveryManModel({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.identityNumber,
    this.identityType,
    this.identityImage,
    this.image,
    this.status,
    this.active,
    this.earning,
    this.type,
    this.ordersCount,
    this.avgRating,
    this.ratingCount,
    this.cashInHands,
  });

  factory DeliveryManModel.fromJson(Map<String, dynamic> json) {
    return DeliveryManModel(
      id: json['id'] as int?,
      fName: json['f_name'] as String?,
      lName: json['l_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      identityNumber: json['identity_number'] as String?,
      identityType: json['identity_type'] as String?,
      identityImage: (json['identity_image'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      image: json['image'] as String?,
      status: json['status'] is bool
          ? json['status'] as bool
          : (json['status'] == 1),
      active: json['active'] as int?,
      earning: json['earning'] as int?,
      type: json['type'] as String?,
      ordersCount: json['orders_count'] as int?,
      avgRating: (json['avg_rating'] != null)
          ? (json['avg_rating'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'] as int?,
      cashInHands: (json['cash_in_hands'] != null)
          ? (json['cash_in_hands'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'email': email,
      'identity_number': identityNumber,
      'identity_type': identityType,
      'identity_image': identityImage,
      'image': image,
      'status': status,
      'active': active,
      'earning': earning,
      'type': type,
      'orders_count': ordersCount,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'cash_in_hands': cashInHands,
    };
  }
}
