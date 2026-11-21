class CouponBody {
  final int? id;
  final String? title;
  final String? code;
  final String? startDate;
  final String? expireDate;
  final int? minPurchase;
  final int? maxDiscount;
  final int? discount;
  final String? discountType;
  final String? couponType;
  final int? limit;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? data;
  final int? totalUses;
  final String? createdBy;
  final List<String>? customerId;
  final String? slug;
  final int? restaurantId;

  const CouponBody({
    this.id,
    this.title,
    this.code,
    this.startDate,
    this.expireDate,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.couponType,
    this.limit,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.totalUses,
    this.createdBy,
    this.customerId,
    this.slug,
    this.restaurantId,
  });

  factory CouponBody.fromJson(Map<String, dynamic> json) {
    return CouponBody(
      id: json['id'] as int?,
      title: json['title'] as String?,
      code: json['code'] as String?,
      startDate: json['start_date'] as String?,
      expireDate: json['expire_date'] as String?,
      minPurchase: json['min_purchase'] as int?,
      maxDiscount: json['max_discount'] as int?,
      discount: json['discount'] as int?,
      discountType: json['discount_type'] as String?,
      couponType: json['coupon_type'] as String?,
      limit: json['limit'] as int?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      data: json['data'] as String?,
      totalUses: json['total_uses'] as int?,
      createdBy: json['created_by'] as String?,
      customerId: (json['customer_id'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      slug: json['slug'] as String?,
      restaurantId: json['restaurant_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'start_date': startDate,
      'expire_date': expireDate,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'discount': discount,
      'discount_type': discountType,
      'coupon_type': couponType,
      'limit': limit,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'data': data,
      'total_uses': totalUses,
      'created_by': createdBy,
      'customer_id': customerId,
      'slug': slug,
      'restaurant_id': restaurantId,
    };
  }
}
