class TapManagmentCustomerListResponse {
  final List<EmployeeTapList> employeeTapList;

  TapManagmentCustomerListResponse({required this.employeeTapList});

  factory TapManagmentCustomerListResponse.fromJson(Map<String, dynamic> json) {
    return TapManagmentCustomerListResponse(
      employeeTapList: (json['employee-tap-list'] as List<dynamic>?)
              ?.map((v) => EmployeeTapList.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee-tap-list': employeeTapList.map((v) => v.toJson()).toList(),
    };
  }
}

class EmployeeTapList {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final String balance;

  EmployeeTapList({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.balance,
  });

  factory EmployeeTapList.fromJson(Map<String, dynamic> json) {
    return EmployeeTapList(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] == null || json['name'] == 'Noname')
          ? ''
          : json['name'].toString(),
      mobile: (json['mobile'] == null || json['mobile'].toString().isEmpty)
          ? ''
          : json['mobile'].toString(),
      balance: json['balance']?.toString() ?? '',
      email: (json['email'] == null || json['email'].toString().isEmpty)
          ? ''
          : json['email'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'balance': balance,
      'email': email,
    };
  }
}
