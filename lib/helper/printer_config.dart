import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';

class PrinterConfig {
  PrintConfigModel printConfig =
      Get.find<AuthController>().profileModel!.printConfigList!.last;
  PosStyles titleStyle() {
    return PosStyles(
        align: PosAlign.center,
        height: printConfig.restaurantTitle == null
            ? PosTextSize.size3
            : fonstSize(printConfig.restaurantTitle!.split(',').first),
        width: printConfig.restaurantTitle == null
            ? PosTextSize.size2
            : fonstSize(printConfig.restaurantTitle!.split(',')[1]),
        bold: printConfig.restaurantTitle == null
            ? true
            : printConfig.restaurantTitle!.split(',').last == 'true'
                ? true
                : false,
        fontType: PosFontType.fontA);
  }

  PosStyles addressStyle() {
    return PosStyles(
      align: PosAlign.center,
      height: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',').first),
      width: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',')[1]),
      bold: printConfig.restaurantAddress == null
          ? false
          : printConfig.restaurantAddress!.split(',').last == 'true'
              ? true
              : false,
    );
  }

  PosStyles gstStyle() {
    return PosStyles(
      height: printConfig.restaurantGstno == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantGstno!.split(',').first),
      width: printConfig.restaurantGstno == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantGstno!.split(',')[1]),
      bold: printConfig.restaurantGstno == null
          ? false
          : printConfig.restaurantGstno!.split(',').last == 'true'
              ? true
              : false,
      align: PosAlign.center,
    );
  }

  PosStyles orderCreateDateStyle() {
    return PosStyles(
      align: PosAlign.right,
      fontType: PosFontType.fontB,
      height: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',').first),
      width: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',')[1]),
      bold: printConfig.restaurantAddress == null
          ? false
          : printConfig.restaurantAddress!.split(',').last == 'true'
              ? true
              : false,
    );
  }

  PosStyles orderIdStyle({bool isBold = false}) {
    return PosStyles(
      align: PosAlign.left,
      fontType: PosFontType.fontB,
      height: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',').first),
      width: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',')[1]),
      bold: isBold
          ? true
          : printConfig.restaurantAddress == null
              ? false
              : printConfig.restaurantAddress!.split(',').last == 'true'
                  ? true
                  : false,
    );
  }

  PosStyles summryTitleStyle({bool isBold = false}) {
    return PosStyles(
      align: PosAlign.left,
      // height: PosTextSize.size2,
      // width: PosTextSize.size2,
      fontType: PosFontType.fontA,
      // height: printConfig == null || printConfig.restaurantAddress == null
      //     ? PosTextSize.size1
      //     : fonstSize(printConfig.restaurantAddress.split(',').first),
      // width: printConfig == null || printConfig.restaurantAddress == null
      //     ? PosTextSize.size1
      //     : fonstSize(printConfig.restaurantAddress.split(',')[1]),
      bold: isBold
          ? true
          : printConfig.restaurantAddress == null
              ? false
              : printConfig.restaurantAddress!.split(',').last == 'true'
                  ? true
                  : false,
    );
  }

  PosStyles dineInStyle() {
    return PosStyles(
      align: PosAlign.left,
      fontType: PosFontType.fontB,
      height: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',').first),
      width: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',')[1]),
      bold: printConfig.restaurantAddress == null
          ? false
          : printConfig.restaurantAddress!.split(',').last == 'true'
              ? true
              : false,
    );
  }

  PosStyles waiterNameStyle({PosAlign align = PosAlign.right}) {
    return PosStyles(
      align: align,
      fontType: PosFontType.fontB,
      height: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',').first),
      width: printConfig.restaurantAddress == null
          ? PosTextSize.size1
          : fonstSize(printConfig.restaurantAddress!.split(',')[1]),
      bold: printConfig.restaurantAddress == null
          ? false
          : printConfig.restaurantAddress!.split(',').last == 'true'
              ? true
              : false,
    );
  }

  PosStyles tableNoStyle() {
    return PosStyles(
        height: printConfig.restaurantTotalAmount == null
            ? PosTextSize.size3
            : fonstSize(printConfig.restaurantTotalAmount!.split(',').first),
        width: printConfig.restaurantTotalAmount == null
            ? PosTextSize.size2
            : fonstSize(printConfig.restaurantTotalAmount!.split(',')[1]),
        bold: printConfig.restaurantTotalAmount == null
            ? true
            : printConfig.restaurantTotalAmount!.split(',').last == 'true'
                ? true
                : false,
        align: PosAlign.center,
        fontType: PosFontType.fontA);
  }

  PosStyles foodStyle({bool isUnderLine = false}) {
    return PosStyles(
        height: printConfig.restaurantFoodList == null
            ? PosTextSize.size1
            : fonstSize(printConfig.restaurantFoodList!.split(',').first),
        width: printConfig.restaurantFoodList == null
            ? PosTextSize.size1
            : fonstSize(printConfig.restaurantFoodList!.split(',')[1]),
        bold: printConfig.restaurantFoodList == null
            ? false
            : printConfig.restaurantFoodList!.split(',').last == 'true'
                ? true
                : false,
        align: PosAlign.left,
        fontType: PosFontType.fontB,
        underline: isUnderLine);
  }

  PosStyles subtotalStyle() {
    return PosStyles(
        height: printConfig.restaurantSubTotal == null
            ? PosTextSize.size1
            : fonstSize(printConfig.restaurantSubTotal!.split(',').first),
        width: printConfig.restaurantSubTotal == null
            ? PosTextSize.size1
            : fonstSize(printConfig.restaurantSubTotal!.split(',')[1]),
        bold: printConfig.restaurantSubTotal == null
            ? false
            : printConfig.restaurantSubTotal!.split(',').last == 'true'
                ? true
                : false,
        align: PosAlign.center);
  }

  PosStyles totalStyle() {
    return PosStyles(
        height: printConfig.restaurantTotalAmount == null
            ? PosTextSize.size3
            : fonstSize(printConfig.restaurantTotalAmount!.split(',').first),
        width: printConfig.restaurantTotalAmount == null
            ? PosTextSize.size2
            : fonstSize(printConfig.restaurantTotalAmount!.split(',')[1]),
        bold: printConfig.restaurantTotalAmount == null
            ? true
            : printConfig.restaurantTotalAmount!.split(',').last == 'true'
                ? true
                : false,
        align: PosAlign.center,
        fontType: PosFontType.fontA);
  }

  PosTextSize fonstSize(String size) {
    switch (size) {
      case '1':
        return PosTextSize.size1;
      case '2':
        return PosTextSize.size2;
      case '3':
        return PosTextSize.size3;
      case '4':
        return PosTextSize.size4;
      case '5':
        return PosTextSize.size5;
      case '6':
        return PosTextSize.size6;
      case '7':
        return PosTextSize.size7;
      case '8':
        return PosTextSize.size8;
      default:
        return PosTextSize.size1;
    }
  }
}
