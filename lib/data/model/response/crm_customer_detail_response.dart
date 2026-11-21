class CrmCustomerDetailResponse {
  String? id;
  String? name;
  String? phone;
  String? countryCode;
  String? email;
  String? dob; // key is literally 'dob'
  String? anniversary; // key is literally 'anniversary'
  double walletBalance;
  int? totalPoints;
  String? tier;
  String? gstName;
  String? gstNumber;
  String? posId;
  String? customerType;

  CrmCustomerDetailResponse() : walletBalance = 0;

  CrmCustomerDetailResponse.fromJson(Map<String, dynamic> json)
      : walletBalance = 0 {
    // All fields are under 'data' key
    final d = json['data'] as Map<String, dynamic>? ?? {};

    id = d['id']?.toString();
    name = d['name']?.toString();
    phone = d['phone']?.toString();
    countryCode = d['country_code']?.toString();
    email = d['email']?.toString();
    dob = d['dob']?.toString(); // null in response = empty string
    anniversary =
        d['anniversary']?.toString(); // null in response = empty string
    walletBalance =
        double.tryParse(d['wallet_balance']?.toString() ?? '0') ?? 0;
    totalPoints = d['total_points'] as int?;
    tier = d['tier']?.toString();
    gstName = d['gst_name']?.toString();
    gstNumber = d['gst_number']?.toString();
    posId = d['pos_id']?.toString();
    customerType = d['customer_type']?.toString();
  }
}