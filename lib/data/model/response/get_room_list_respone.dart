class GetRoomListResponse {
  final Table? table;
  final User? user;

  GetRoomListResponse({this.table, this.user});

  factory GetRoomListResponse.fromJson(Map<String, dynamic> json) {
    return GetRoomListResponse(
      table: json['table'] != null ? Table.fromJson(json['table']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (table != null) {
      data['table'] = table!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class Table {
  final int? id;
  final int? restaurantId;
  final int? waiterId;
  final String title;
  final String tableNo;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String rtype;

  Table({
    this.id,
    this.restaurantId,
    this.waiterId,
    this.title = '',
    this.tableNo = '',
    this.status,
    this.createdAt,
    this.updatedAt,
    this.rtype = 'RM',
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] as int?,
      restaurantId: json['restaurant_id'] as int?,
      waiterId: json['waiter_id'] as int?,
      title: json['title'] as String? ?? '',
      tableNo: json['table_no'] as String? ?? '',
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      rtype: json['rtype'] as String? ?? 'RM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'waiter_id': waiterId,
      'title': title,
      'table_no': tableNo,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'rtype': rtype,
    };
  }
}

class User {
  final int? id;
  final String fName;
  final String? lName;
  final String phone;
  final String? email;

  User({
    this.id,
    this.fName = '',
    this.lName,
    this.phone = '',
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      fName: json['f_name'] as String? ?? '',
      lName: json['l_name'] as String?,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'email': email,
    };
  }
}
