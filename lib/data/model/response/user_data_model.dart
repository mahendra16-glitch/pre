class UserDataModel {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final List<Data>? data;

  UserDataModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.data,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      totalSize: json['total_size'] as int?,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((v) => Data.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class Data {
  final int? id;
  final String? fName;
  final String? lName;
  final String? image;
  final String? phone;
  final String? email;
  final int? userId;
  final int? vendorId;
  final int? deliverymanId;

  Data({
    this.id,
    this.fName,
    this.lName,
    this.image,
    this.phone,
    this.email,
    this.userId,
    this.vendorId,
    this.deliverymanId,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] as int?,
      fName: json['fName'] as String?,
      lName: json['lName'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      userId: json['user_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      deliverymanId: json['deliveryman_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fName': fName,
      'lName': lName,
      'image': image,
      'phone': phone,
      'email': email,
      'user_id': userId,
      'vendor_id': vendorId,
      'deliveryman_id': deliverymanId,
    };
  }
}
