class ErrorResponse {
  final List<Errors> errors;

  ErrorResponse({required this.errors});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => Errors.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((e) => e.toJson()).toList(),
    };
  }
}

class Errors {
  final String code;
  final String message;

  Errors({required this.code, required this.message});

  factory Errors.fromJson(Map<String, dynamic> json) {
    return Errors(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
