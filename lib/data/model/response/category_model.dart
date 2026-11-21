class CategoryModel {
  final int id;
  final String name;
  // final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    // this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString().toUpperCase(),
      // image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'image': image,
    };
  }
}
