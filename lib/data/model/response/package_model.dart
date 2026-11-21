class PackageModel {
  final List<Packages> packages;

  PackageModel({required this.packages});

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      packages: (json['packages'] as List<dynamic>?)
              ?.map((v) => Packages.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packages': packages.map((v) => v.toJson()).toList(),
    };
  }
}

class Packages {
  final int id;
  final String packageName;
  final double price;
  final int validity;
  final String maxOrder;
  final String maxProduct;
  final int pos;
  final int mobileApp;
  final int chat;
  final int review;
  final int selfDelivery;
  final int status;
  final int def;
  final String createdAt;
  final String updatedAt;
  final String color;

  Packages({
    required this.id,
    required this.packageName,
    required this.price,
    required this.validity,
    required this.maxOrder,
    required this.maxProduct,
    required this.pos,
    required this.mobileApp,
    required this.chat,
    required this.review,
    required this.selfDelivery,
    required this.status,
    required this.def,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
  });

  factory Packages.fromJson(Map<String, dynamic> json) {
    return Packages(
      id: json['id'] as int,
      packageName: json['package_name'] as String,
      price: (json['price'] as num).toDouble(),
      validity: json['validity'] as int,
      maxOrder: json['max_order'] as String,
      maxProduct: json['max_product'] as String,
      pos: json['pos'] as int,
      mobileApp: json['mobile_app'] as int,
      chat: json['chat'] as int,
      review: json['review'] as int,
      selfDelivery: json['self_delivery'] as int,
      status: json['status'] as int,
      def: json['default'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      color: json['colour'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_name': packageName,
      'price': price,
      'validity': validity,
      'max_order': maxOrder,
      'max_product': maxProduct,
      'pos': pos,
      'mobile_app': mobileApp,
      'chat': chat,
      'review': review,
      'self_delivery': selfDelivery,
      'status': status,
      'default': def,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'colour': color,
    };
  }
}
