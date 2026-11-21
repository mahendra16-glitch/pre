class CrmCustomerListResponse {
  List<CrmCustomerItem>? customerList;
  int? total;

  CrmCustomerListResponse();

  CrmCustomerListResponse.fromJson(Map<String, dynamic> json) {
    // Structure: { "data": { "customers": [...], "total": 5 } }
    final data = json['data'];
    if (data != null && data is Map<String, dynamic>) {
      total = data['total'];
      final raw = data['customers'];
      if (raw is List) {
        customerList = raw
            .map((e) => CrmCustomerItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    customerList ??= [];
  }
}

class CrmCustomerItem {
  String? id;
  String? name;
  String? phone;
  double? walletBalance;
  int?    totalPoints;
  String? tier;

  CrmCustomerItem();

  CrmCustomerItem.fromJson(Map<String, dynamic> json) {
    id           = json['id']?.toString();
    name         = json['name']?.toString();
    phone        = json['phone']?.toString();
    walletBalance = double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0;
    totalPoints  = json['total_points'] as int?;
    tier         = json['tier']?.toString();
  }
}