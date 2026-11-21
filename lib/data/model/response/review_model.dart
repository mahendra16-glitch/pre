import 'package:mygenie_restaurant/data/model/response/order_model.dart';

class ReviewModel {
  final int? id;
  final String? comment;
  final int? rating;
  final String? foodName;
  final String? foodImage;
  final String? customerName;
  final String? createdAt;
  final String? updatedAt;
  final Customer? customer;

  ReviewModel({
    this.id,
    this.comment,
    this.rating,
    this.foodName,
    this.foodImage,
    this.customerName,
    this.createdAt,
    this.updatedAt,
    this.customer,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      comment: json['comment'] as String?,
      rating: json['rating'] as int?,
      foodName: json['food_name'] as String?,
      foodImage: json['food_image'] as String?,
      customerName: json['customer_name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'rating': rating,
      'food_name': foodName,
      'food_image': foodImage,
      'customer_name': customerName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (customer != null) 'customer': customer!.toJson(),
    };
  }
}
