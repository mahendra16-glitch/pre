import 'package:flutter/services.dart';

class PineLabsService {
  static const MethodChannel _channel = MethodChannel('pinelabs_payment');

  /// amountPaise = amount * 100
  static Future<Map<String, dynamic>> startPayment({
    required int amountPaise,
    required String billingRefNo,
  }) async {
    try {
      final result = await _channel.invokeMethod(
        'startPayment',
        {
          'amount': amountPaise,
          'billingRefNo': billingRefNo,
        },
      );

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Pine Labs payment failed');
    }
  }
}
