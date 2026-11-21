class AdminRestaurantModel {
  final List<AssignedRestaurant> assignedRestaurants;
  final int totalCount;

  AdminRestaurantModel({
    required this.assignedRestaurants,
    required this.totalCount,
  });

  factory AdminRestaurantModel.fromJson(Map<String, dynamic> json) {
    return AdminRestaurantModel(
      assignedRestaurants: (json['assigned_restaurants'] as List)
          .map((restaurant) => AssignedRestaurant.fromJson(restaurant))
          .toList(),
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class AssignedRestaurant {
  final int assignmentId;
  final int restaurantId;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantPhone;
  final String restaurantEmail;
  final String? restaurantLogo;
  final int restaurantStatus;
  final String assignedAt;
  final String? notes;

  final String ownerFirstName;
  final String? ownerLastName;
  final String ownerPhone;
  final String ownerEmail;

  AssignedRestaurant({
    required this.assignmentId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantPhone,
    required this.restaurantEmail,
    this.restaurantLogo,
    required this.restaurantStatus,
    required this.assignedAt,
    this.notes,
    required this.ownerFirstName,
    this.ownerLastName,
    required this.ownerPhone,
    required this.ownerEmail,
  });

  factory AssignedRestaurant.fromJson(Map<String, dynamic> json) {
    return AssignedRestaurant(
      assignmentId: json['assignment_id'],
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      restaurantAddress: json['restaurant_address'],
      restaurantPhone: json['restaurant_phone'],
      restaurantEmail: json['restaurant_email'],
      restaurantLogo: json['restaurant_logo'],
      restaurantStatus: json['restaurant_status'],
      assignedAt: json['assigned_at'],
      notes: json['notes'],
      ownerFirstName: json['owner_first_name'],
      ownerLastName: json['owner_last_name'],
      ownerPhone: json['owner_phone'],
      ownerEmail: json['owner_email'],
    );
  }
}


