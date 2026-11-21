import 'package:mygenie_restaurant/data/model/response/zone_response_model.dart';

class AddressModel {
  String? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  String? userId;
  String? pincode;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? dob; // date of birth
  String? doa; // date of anniversary
  String? membershipId;
  String? road;
  String? house;
  String? floor;
  String? dialCode;
  List<ZoneData>? zoneData;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.userId,
    this.pincode,
    this.zoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.dob,
    this.doa,
    this.membershipId,
    this.road,
    this.house,
    this.floor,
    this.dialCode,
    this.zoneData,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      addressType: json['address_type'],
      contactPersonNumber: json['contact_person_number'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      userId: json['user_id'],
      pincode: json['pincode'],
      zoneId: json['zone_id'],
      zoneIds:
          json['zone_ids'] != null ? List<int>.from(json['zone_ids']) : null,
      method: json['_method'],
      contactPersonName: json['contact_person_name'] ?? '',
      dob: json['date_of_birth'],
      doa: json['date_of_anniversary'],
      membershipId: json['membership_id'],
      road: json['road'],
      house: json['house'] ?? '',
      floor: json['floor'],
      dialCode: json['dial_code'] ?? '+91',
      zoneData: json['zone_data'] != null
          ? List<ZoneData>.from(
              (json['zone_data'] as List).map((v) => ZoneData.fromJson(v)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['user_id'] = userId;
    data['pincode'] = pincode;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['dial_code'] = dialCode;
    data['contact_person_name'] = contactPersonName;
    data['date_of_birth'] = dob;
    data['date_of_anniversary'] = doa;
    data['membership_id'] = membershipId;
    data['road'] = road;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
