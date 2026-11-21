class GetCustomerListResponse {
  final List<CustomerList> customerList;

  GetCustomerListResponse({required this.customerList});

  factory GetCustomerListResponse.fromJson(Map<String, dynamic> json) {
    return GetCustomerListResponse(
      customerList: (json['customer_list'] as List<dynamic>?)
              ?.map((v) => CustomerList.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_list': customerList.map((v) => v.toJson()).toList(),
    };
  }
}

class CustomerList {
  final String customerName;
  final int id;
  final String lName;
  final String phone;
  final String gstNo;
  final String gstName;
  final String dateOfBirth;
  final String dateOfAnniversary;
  final String membershipId;
  double virtualWalletBal;

  CustomerList({
    required this.customerName,
    required this.id,
    required this.lName,
    required this.phone,
    required this.gstNo,
    required this.gstName,
    required this.dateOfBirth,
    required this.dateOfAnniversary,
    required this.membershipId,
    required this.virtualWalletBal,
  });

  factory CustomerList.fromJson(Map<String, dynamic> json) {
    return CustomerList(
      customerName: json['customer_name'] as String? ?? '',
      id: json['id'] as int? ?? 0,
      lName: json['l_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gstNo: json['gst_number'] ?? '',
      gstName: json['gst_name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      dateOfAnniversary: json['date_of_anniversary'] ?? '',
      membershipId: json['membership_id'] ?? '',
      virtualWalletBal: double.parse('${json['wallet_balance'] ?? '0'}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'id': id,
      'l_name': lName,
      'phone': phone,
      'gst_number': gstNo,
    };
  }
}
