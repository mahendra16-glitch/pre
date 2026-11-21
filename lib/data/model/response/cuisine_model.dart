class CuisineModel {
  final List<Cuisines> cuisines;

  CuisineModel({required this.cuisines});

  factory CuisineModel.fromJson(Map<String, dynamic> json) {
    return CuisineModel(
      cuisines: (json['Cuisines'] as List<dynamic>?)
              ?.map((v) => Cuisines.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Cuisines': cuisines.map((v) => v.toJson()).toList(),
    };
  }
}

class Cuisines {
  final int id;
  final String name;
  final String image;
  final int status;
  final String slug;
  final String createdAt;
  final String updatedAt;

  Cuisines({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cuisines.fromJson(Map<String, dynamic> json) {
    return Cuisines(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 0,
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'status': status,
      'slug': slug,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
