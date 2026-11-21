import 'dart:convert';

List<GetDeliveryBoyList> getDeliveryBoyListResponseFromJson(String str) =>
    List<GetDeliveryBoyList>.from(
        json.decode(str).map((x) => GetDeliveryBoyList.fromJson(x)));

class GetDeliveryBoyList {
  final int? id;
  final String fName;
  final String lName;
  final String phone;
  final String email;
  final dynamic macIpKds;
  final dynamic macIpBar;
  final dynamic macIpBill;
  final dynamic image;
  final int? employeeRoleId;
  final int? vendorId;
  final int? restaurantId;
  final bool? status;
  final dynamic firebaseToken;
  final String? billUserView;
  final dynamic categoryIds;
  final String? defaultUser;
  final String? createdAt;
  final String? updatedAt;

  const GetDeliveryBoyList({
    this.id,
    this.fName = '',
    this.lName = '',
    this.phone = '',
    this.email = '',
    this.macIpKds,
    this.macIpBar,
    this.macIpBill,
    this.image,
    this.employeeRoleId,
    this.vendorId,
    this.restaurantId,
    this.status,
    this.firebaseToken,
    this.billUserView,
    this.categoryIds,
    this.defaultUser,
    this.createdAt,
    this.updatedAt,
  });

  factory GetDeliveryBoyList.fromJson(Map<String, dynamic> json) =>
      GetDeliveryBoyList(
        id: json['id'] as int?,
        fName: json['f_name'] as String? ?? '',
        lName: json['l_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        macIpKds: json['mac_ip_kds'],
        macIpBar: json['mac_ip_bar'],
        macIpBill: json['mac_ip_bill'],
        image: json['image'],
        employeeRoleId: json['employee_role_id'] as int?,
        vendorId: json['vendor_id'] as int?,
        restaurantId: json['restaurant_id'] as int?,
        status: json['status'] is bool
            ? json['status'] as bool
            : (json['status'] == 1),
        firebaseToken: json['firebase_token'],
        billUserView: json['bill_user_view'] as String?,
        categoryIds: json['category_ids'],
        defaultUser: json['default_user'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "f_name": fName,
        "l_name": lName,
        "phone": phone,
        "email": email,
        "mac_ip_kds": macIpKds,
        "mac_ip_bar": macIpBar,
        "mac_ip_bill": macIpBill,
        "image": image,
        "employee_role_id": employeeRoleId,
        "vendor_id": vendorId,
        "restaurant_id": restaurantId,
        "status": status,
        "firebase_token": firebaseToken,
        "bill_user_view": billUserView,
        "category_ids": categoryIds,
        "default_user": defaultUser,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
