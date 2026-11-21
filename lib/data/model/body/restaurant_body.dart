import 'dart:convert';

class RestaurantBody {
  String? restaurantName;
  String? restaurantAddress;
  String? vat;
  String? minDeliveryTime;
  String? maxDeliveryTime;
  String? lat;
  String? lng;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? password;
  String? zoneId;
  List<String>? cuisineId;

  RestaurantBody({
    this.restaurantName,
    this.restaurantAddress,
    this.vat,
    this.minDeliveryTime,
    this.maxDeliveryTime,
    this.lat,
    this.lng,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.password,
    this.zoneId,
    this.cuisineId,
  });

  factory RestaurantBody.fromJson(Map<String, dynamic> json) {
    return RestaurantBody(
      restaurantName: json['restaurant_name'] as String?,
      restaurantAddress: json['restaurant_address'] as String?,
      vat: json['vat'] as String?,
      minDeliveryTime: json['min_delivery_time'] as String?,
      maxDeliveryTime: json['max_delivery_time'] as String?,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      fName: json['fName'] as String?,
      lName: json['lName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      zoneId: json['zone_id'] as String?,
      cuisineId: (json['cuisine_ids'] is List)
          ? List<String>.from(json['cuisine_ids'])
          : (json['cuisine_ids'] is String)
              ? List<String>.from(jsonDecode(json['cuisine_ids']))
              : null,
    );
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    if (restaurantName != null) data['restaurant_name'] = restaurantName!;
    if (restaurantAddress != null)
      data['restaurant_address'] = restaurantAddress!;
    if (vat != null) data['vat'] = vat!;
    if (minDeliveryTime != null) data['min_delivery_time'] = minDeliveryTime!;
    if (maxDeliveryTime != null) data['max_delivery_time'] = maxDeliveryTime!;
    if (lat != null) data['lat'] = lat!;
    if (lng != null) data['lng'] = lng!;
    if (fName != null) data['fName'] = fName!;
    if (lName != null) data['lName'] = lName!;
    if (phone != null) data['phone'] = phone!;
    if (email != null) data['email'] = email!;
    if (password != null) data['password'] = password!;
    if (zoneId != null) data['zone_id'] = zoneId!;
    if (cuisineId != null) data['cuisine_ids'] = jsonEncode(cuisineId);
    return data;
  }
}
