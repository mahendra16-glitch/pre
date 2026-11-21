class CrmAddressLookupResponse {
  bool? success;
  String? message;
  CrmAddressLookupData? data;

  CrmAddressLookupResponse({this.success, this.message, this.data});

  factory CrmAddressLookupResponse.fromJson(Map<String, dynamic> json) {
    return CrmAddressLookupResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? CrmAddressLookupData.fromJson(json['data'])
          : null,
    );
  }
}

class CrmAddressLookupData {
  String? phone;
  List<CrmAddress>? addresses;

  CrmAddressLookupData({this.phone, this.addresses});

  factory CrmAddressLookupData.fromJson(Map<String, dynamic> json) {
    return CrmAddressLookupData(
      phone: json['phone'],
      addresses: json['addresses'] != null
          ? List<CrmAddress>.from(
              json['addresses'].map((e) => CrmAddress.fromJson(e)))
          : [],
    );
  }
}

class CrmAddress {
  String? id;              // CRM address UUID  "addr_91eab085080b"
  int? posAddressId;       // your backend address ID  7685
  bool? isDefault;
  String? addressType;     // "Home" / "Work" / "Other"
  String? address;
  String? house;
  String? floor;
  String? road;
  String? city;
  String? state;
  String? pincode;
  String? country;
  dynamic latitude;        // can be "", null, or "12.345" — use safeLatLng()
  dynamic longitude;       // same
  String? contactPersonName;
  String? contactPersonNumber;
  String? dialCode;
  int? zoneId;
  String? deliveryInstructions;
  String? createdAt;
  String? updatedAt;
  String? sourceRestaurant;

  CrmAddress({
    this.id,
    this.posAddressId,
    this.isDefault,
    this.addressType,
    this.address,
    this.house,
    this.floor,
    this.road,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.latitude,
    this.longitude,
    this.contactPersonName,
    this.contactPersonNumber,
    this.dialCode,
    this.zoneId,
    this.deliveryInstructions,
    this.createdAt,
    this.updatedAt,
    this.sourceRestaurant,
  });

  // factory CrmAddress.fromJson(Map<String, dynamic> json) {
  //   return CrmAddress(
  //     id:                   json['id'],
  //     posAddressId:         json['pos_address_id'],
  //     isDefault:            json['is_default'],
  //     addressType:          json['address_type'],
  //     address:              json['address'],
  //     house:                json['house'],
  //     floor:                json['floor'],
  //     road:                 json['road'],
  //     city:                 json['city'],
  //     state:                json['state'],
  //     pincode:              json['pincode'],
  //     country:              json['country'],
  //     latitude:             json['latitude'],   // keep as dynamic — don't parse here
  //     longitude:            json['longitude'],  // keep as dynamic — don't parse here
  //     contactPersonName:    json['contact_person_name'],
  //     contactPersonNumber:  json['contact_person_number'],
  //     dialCode:             json['dial_code'],
  //     zoneId:               json['zone_id'],
  //     deliveryInstructions: json['delivery_instructions'],
  //     createdAt:            json['created_at'],
  //     updatedAt:            json['updated_at'],
  //     sourceRestaurant:     json['source_restaurant'],
  //   );
  // }

factory CrmAddress.fromJson(Map<String, dynamic> json) {
  return CrmAddress(
    id:                   json['id']?.toString(),
    
    // Safely handle if pos_address_id is an int, a String ("2917"), or empty ("")
    posAddressId:         json['pos_address_id'] != null && json['pos_address_id'].toString().isNotEmpty
                            ? int.tryParse(json['pos_address_id'].toString()) 
                            : null,
                            
    isDefault:            json['is_default'] ?? false,
    addressType:          json['address_type']?.toString(),
    address:              json['address']?.toString(),
    
    // Safely handle if house/pincode are ints (1) or Strings ("1")
    house:                json['house']?.toString(),
    floor:                json['floor']?.toString(),
    road:                 json['road']?.toString(),
    city:                 json['city']?.toString(),
    state:                json['state']?.toString(),
    pincode:              json['pincode']?.toString(),
    country:              json['country']?.toString(),
    
    latitude:             json['latitude'], 
    longitude:            json['longitude'],
    contactPersonName:    json['contact_person_name']?.toString(),
    contactPersonNumber:  json['contact_person_number']?.toString(),
    dialCode:             json['dial_code']?.toString(),
    
    // Safely handle if zone_id is an int, a String ("6"), or empty ("")
    zoneId:               json['zone_id'] != null && json['zone_id'].toString().isNotEmpty
                            ? int.tryParse(json['zone_id'].toString()) 
                            : null,
                            
    deliveryInstructions: json['delivery_instructions']?.toString(),
    createdAt:            json['created_at']?.toString(),
    updatedAt:            json['updated_at']?.toString(),
    sourceRestaurant:     json['source_restaurant']?.toString(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id':                    id,
      'pos_address_id':        posAddressId,
      'is_default':            isDefault,
      'address_type':          addressType,
      'address':               address,
      'house':                 house,
      'floor':                 floor,
      'road':                  road,
      'city':                  city,
      'state':                 state,
      'pincode':               pincode,
      'country':               country,
      'latitude':              latitude,
      'longitude':             longitude,
      'contact_person_name':   contactPersonName,
      'contact_person_number': contactPersonNumber,
      'dial_code':             dialCode,
      'zone_id':               zoneId,
      'delivery_instructions': deliveryInstructions,
      'created_at':            createdAt,
      'updated_at':            updatedAt,
      'source_restaurant':     sourceRestaurant,
    };
  }

  /// Safe lat/long parser — handles null, "", "12.345"
  double? get safeLatitude {
    if (latitude == null) return null;
    final str = latitude.toString().trim();
    if (str.isEmpty) return null;
    return double.tryParse(str);
  }

  double? get safeLongitude {
    if (longitude == null) return null;
    final str = longitude.toString().trim();
    if (str.isEmpty) return null;
    return double.tryParse(str);
  }

  /// Whether this address has valid coordinates for delivery charge
  bool get hasValidCoordinates =>
      safeLatitude != null && safeLongitude != null;
}