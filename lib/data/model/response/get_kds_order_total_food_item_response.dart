class GetKDSTotalFoodItemResponseModel {
  final List<OrderedCategories> orderedCategories;

  GetKDSTotalFoodItemResponseModel({required this.orderedCategories});

  factory GetKDSTotalFoodItemResponseModel.fromJson(Map<String, dynamic> json) {
    return GetKDSTotalFoodItemResponseModel(
      orderedCategories: (json['ordered_categories'] as List<dynamic>? ?? [])
          .map((v) => OrderedCategories.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ordered_categories': orderedCategories.map((v) => v.toJson()).toList(),
    };
  }
}

class OrderedCategories {
  final String categoryName;
  final List<String> foodCounts;

  OrderedCategories({required this.categoryName, required this.foodCounts});

  factory OrderedCategories.fromJson(Map<String, dynamic> json) {
    return OrderedCategories(
      categoryName: json['category_name'] as String? ?? '',
      foodCounts: (json['food_counts'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'food_counts': foodCounts,
    };
  }
}
