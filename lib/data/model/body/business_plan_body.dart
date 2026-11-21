class BusinessPlanBody {
  String? businessPlan;
  String? restaurantId;
  String? packageId;
  String? payment;
  String? type;

  BusinessPlanBody({
    this.businessPlan,
    this.restaurantId,
    this.packageId,
    this.payment,
    this.type,
  });

  factory BusinessPlanBody.fromJson(Map<String, dynamic> json) {
    return BusinessPlanBody(
      businessPlan: json['business_plan'] as String?,
      restaurantId: json['restaurant_id'] as String?,
      packageId: json['package_id'] as String?,
      payment: json['payment'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, String?> toJson() {
    return {
      'business_plan': businessPlan,
      'restaurant_id': restaurantId,
      'package_id': packageId,
      'payment': payment,
      'type': type,
    };
  }
}
