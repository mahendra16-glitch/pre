import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';

class PriceConverter {
  static String convertPrice(
    double price, {
    bool isHideCurrency = false,
    double? discount,
    String? discountType,
    int? asFixed,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }
    bool _isRightSide = true;
    return '${isHideCurrency ? '' : ' '}'
        '${(price).toStringAsFixed(asFixed ?? 2)}'
        '${isHideCurrency ? '' : ' '}';
  }

  static double convertWithDiscount(
      double price, double discount, String discountType) {
    if (discountType == 'amount') {
      price = price - discount;
    } else if (discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }

  static double subtractPercentage(
      double total, double price, double discount) {
    double value = total - (price * discount / 100);
    return value;
  }

  static double addPercentage(double total, double price, double discount) {
    double value = total + (price * discount / 100);
    return value;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : ''} OFF';
  }
}

convertRoundOff(double amount, {bool isShowWithString = false}) {
  bool isRoundOff = Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .isTotalRound ==
      'Yes';

  var tempValue = isRoundOff ? amount.ceil() : amount;
  return isShowWithString
      ? isRoundOff
          ? '${amount.ceil()} (${amount.toStringAsFixed(2)})'
          : amount.toStringAsFixed(2)
      : tempValue;
}
double twoDecimal(double value) {
  return double.parse(value.toStringAsFixed(2));
}

// double getRoundUpValue({
//   required double value,
//   double threshold = 0.10
// }) {
// bool  isTotalRound=Get.find<AuthController>()
//                   .profileModel
//                   ?.restaurants
//                   ?.first
//                   .isTotalRound ==
//               'Yes';
//   if (!isTotalRound) return 0.0;

//   double decimal =
//       double.parse((value - value.floor()).toStringAsFixed(2));

//   double rounded =
//       decimal >= threshold ? value.ceilToDouble() : value.floorToDouble();

//   double diff = rounded - value;

//   // safety: avoid negative or floating garbage like -0.00
//   return double.parse(diff.toStringAsFixed(2));
// }
int getRoundUpValue({
  required double value,
  double threshold = 0.10,
}) {
  double decimal =
      double.parse((value - value.floor()).toStringAsFixed(2));

  return decimal >= threshold
      ? value.ceil()
      : value.floor();
}

String getRoundUpAmount(
  double orderPay,
{
  double threshold = 0.10,
}) {
  bool isTotalRound = Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes';
  if (!isTotalRound) return '0.00';

  // Fix decimal precision properly
  double decimal =
      double.parse((orderPay - orderPay.floor()).toStringAsFixed(2));

  if (decimal < threshold) return '0.00';

  double roundUp =
      double.parse((orderPay.ceil() - orderPay).toStringAsFixed(2));

  return roundUp.toStringAsFixed(2);
}

bool isTextEmpty(String? tip) {
  return tip == null || tip.trim().isEmpty || tip.trim() == '0';
}