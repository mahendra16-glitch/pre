class GetEmployeeListResponse {
  final List<RestaurantEmployeeList> restaurantEmployeeList;

  GetEmployeeListResponse({required this.restaurantEmployeeList});

  factory GetEmployeeListResponse.fromJson(Map<String, dynamic> json) {
    return GetEmployeeListResponse(
      restaurantEmployeeList: (json['Restaurant-employee-list']
                  as List<dynamic>?)
              ?.map((v) =>
                  RestaurantEmployeeList.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Restaurant-employee-list':
          restaurantEmployeeList.map((v) => v.toJson()).toList(),
    };
  }
}

class RestaurantEmployeeList {
  final int id;
  final String fName;

  RestaurantEmployeeList({required this.id, required this.fName});

  factory RestaurantEmployeeList.fromJson(Map<String, dynamic> json) {
    return RestaurantEmployeeList(
      id: json['id'] as int? ?? 0,
      fName: json['f_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
    };
  }
}
