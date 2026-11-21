class RestaurantLoginModel {
  final String restaurantToken;
  final String? crmToken;
  final int restaurantId;
  final String restaurantName;
  final String ownerEmail;
  final String ownerName;
  final int supportEmployeeId;
  final String supportEmployeeName;
  final String message;

  RestaurantLoginModel({
    required this.restaurantToken,
    this.crmToken,
    required this.restaurantId,
    required this.restaurantName,
    required this.ownerEmail,
    required this.ownerName,
    required this.supportEmployeeId,
    required this.supportEmployeeName,
    required this.message,
  });

  factory RestaurantLoginModel.fromJson(Map<String, dynamic> json) {
    return RestaurantLoginModel(
      restaurantToken: json['restaurant_token'],
      crmToken: json['crm_token'],
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      ownerEmail: json['owner_email'],
      ownerName: json['owner_name'],
      supportEmployeeId: json['support_employee_id'],
      supportEmployeeName: json['support_employee_name'],
      message: json['message'],
    );
  }
}
