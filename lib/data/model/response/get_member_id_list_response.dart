class GetMemberListResponse {
  final List<MemberList> customerList;

  GetMemberListResponse({required this.customerList});

  factory GetMemberListResponse.fromJson(Map<String, dynamic> json) {
    return GetMemberListResponse(
      customerList: (json['data'] as List<dynamic>?)
              ?.map((v) => MemberList.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': customerList.map((v) => v.toJson()).toList(),
    };
  }
}

class MemberList {
  final String customerName;
  final int id;
  final String phone;
  final String memberId;

  MemberList({
    required this.customerName,
    required this.id,
    required this.phone,
    required this.memberId,
  });

  factory MemberList.fromJson(Map<String, dynamic> json) {
    final fName = json['f_name'] as String? ?? '';
    final lName = json['l_name'] as String? ?? '';
    return MemberList(
      customerName: '$fName $lName'.trim(),
      id: json['id'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      memberId: json['member_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'id': id,
      'phone': phone,
      'member_id': memberId,
    };
  }
}
