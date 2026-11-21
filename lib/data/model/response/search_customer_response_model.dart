class SearchCustomerResponseModel {
  final String id;
  final String text;
  final String name;
  final String phone;
  final String email;

  const SearchCustomerResponseModel({
    required this.id,
    required this.text,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory SearchCustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchCustomerResponseModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      name: (json['name'] == null || json['name'] == 'Noname')
          ? ''
          : json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
