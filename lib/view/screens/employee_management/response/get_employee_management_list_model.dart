class GetEmployeeManagementListModel {
  List<Employee>? employees;

  GetEmployeeManagementListModel({
     this.employees,
  });

  GetEmployeeManagementListModel.fromJson(Map<String, dynamic> json) {
    employees = (json['employees'] as List<dynamic>)
        .map((e) => Employee.fromJson(e))
        .toList();
  }
}

class Employee {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  int? status;
  String? macIpKds;
  String? macIpBill;
  String? macIpBar;
  String? billUserView;
  String? foodFor;
  String? image;
  Role? role;

  Employee({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.status,
    this.macIpKds,
    this.macIpBill,
    this.macIpBar,
    this.billUserView,
    this.foodFor,
    this.image,
    this.role,
  });

  Employee.fromJson(Map<String, dynamic> json) {
    id =   json['id'] ?? 0;
    fName = json['f_name'] as String? ?? '';
    lName = json['l_name'] as String? ?? '';
    phone = json['phone'] as String? ?? '';
    email = json['email'] as String? ?? '';
    status = json['status'] as int? ?? 0;
    macIpKds = json['mac_ip_kds'] as String? ?? '';
    macIpBill = json['mac_ip_bill'] as String? ?? '';
    macIpBar = json['mac_ip_bar'] as String? ?? '';
    billUserView = json['bill_user_view'] as String? ?? '';
    foodFor = json['food_for']?.toString() ?? '';
    image = json['image'] as String? ?? '';
    role = json['role'] != null
        ? Role.fromJson(json['role'] as Map<String, dynamic>)
        : Role(id: 0, name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'f_name': fName ?? '',
      'l_name': lName ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'status': status ?? 0,
      'mac_ip_kds': macIpKds ?? '',
      'mac_ip_bill': macIpBill ?? '',
      'mac_ip_bar': macIpBar ?? '',
      'bill_user_view': billUserView ?? '',
      'food_for': foodFor ?? '',
      'image': image ?? '',
      'role': role?.toJson() ?? Role(id: 0, name: '').toJson(),
    };
  }
}

class Role {
  dynamic id;
  String? name;

  Role({
    this.id,
    this.name,
  });

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString()) ?? 0;
    name = json['name'] as String? ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'name': name ?? '',
    };
  }
}
