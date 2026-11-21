import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';

class PrinterConfig {
  PrintConfigModel? get _printConfig {
    try {
      final list = Get.find<AuthController>().profileModel?.printConfigList;
      if (list != null && list.isNotEmpty) {
        return list.last;
      }
    } catch (_) {}
    return null;
  }

  PosStyles titleStyle() {
    final cfg = _printConfig;
    final title = cfg?.restaurantTitle;
    return PosStyles(
        align: PosAlign.center,
        height: title == null || !title.contains(',')
            ? PosTextSize.size3
            : fonstSize(title.split(',').first),
        width: title == null || !title.contains(',')
            ? PosTextSize.size2
            : fonstSize(title.split(',')[1]),
        bold: title == null
            ? true
            : title.split(',').last == 'true',
        fontType: PosFontType.fontA);
  }

  PosStyles addressStyle() {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: PosAlign.center,
      height: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',').first),
      width: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',')[1]),
      bold: addr == null
          ? false
          : addr.split(',').last == 'true',
    );
  }

  PosStyles gstStyle() {
    final cfg = _printConfig;
    final gst = cfg?.restaurantGstno;
    return PosStyles(
      height: gst == null || !gst.contains(',')
          ? PosTextSize.size1
          : fonstSize(gst.split(',').first),
      width: gst == null || !gst.contains(',')
          ? PosTextSize.size1
          : fonstSize(gst.split(',')[1]),
      bold: gst == null
          ? false
          : gst.split(',').last == 'true',
      align: PosAlign.center,
    );
  }

  PosStyles orderCreateDateStyle() {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: PosAlign.right,
      fontType: PosFontType.fontB,
      height: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',').first),
      width: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',')[1]),
      bold: addr == null
          ? false
          : addr.split(',').last == 'true',
    );
  }

  PosStyles orderIdStyle({bool isBold = false}) {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: PosAlign.left,
      fontType: PosFontType.fontB,
      height: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',').first),
      width: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',')[1]),
      bold: isBold
          ? true
          : addr == null
              ? false
              : addr.split(',').last == 'true',
    );
  }

  PosStyles summryTitleStyle({bool isBold = false}) {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: PosAlign.left,
      fontType: PosFontType.fontA,
      bold: isBold
          ? true
          : addr == null
              ? false
              : addr.split(',').last == 'true',
    );
  }

  PosStyles dineInStyle() {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: PosAlign.left,
      fontType: PosFontType.fontB,
      height: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',').first),
      width: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',')[1]),
      bold: addr == null
          ? false
          : addr.split(',').last == 'true',
    );
  }

  PosStyles waiterNameStyle({PosAlign align = PosAlign.right}) {
    final cfg = _printConfig;
    final addr = cfg?.restaurantAddress;
    return PosStyles(
      align: align,
      fontType: PosFontType.fontB,
      height: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',').first),
      width: addr == null || !addr.contains(',')
          ? PosTextSize.size1
          : fonstSize(addr.split(',')[1]),
      bold: addr == null
          ? false
          : addr.split(',').last == 'true',
    );
  }

  PosStyles tableNoStyle() {
    final cfg = _printConfig;
    final tot = cfg?.restaurantTotalAmount;
    return PosStyles(
        height: tot == null || !tot.contains(',')
            ? PosTextSize.size3
            : fonstSize(tot.split(',').first),
        width: tot == null || !tot.contains(',')
            ? PosTextSize.size2
            : fonstSize(tot.split(',')[1]),
        bold: tot == null
            ? true
            : tot.split(',').last == 'true',
        align: PosAlign.center,
        fontType: PosFontType.fontA);
  }

  PosStyles foodStyle({bool isUnderLine = false}) {
    final cfg = _printConfig;
    final food = cfg?.restaurantFoodList;
    return PosStyles(
        height: food == null || !food.contains(',')
            ? PosTextSize.size1
            : fonstSize(food.split(',').first),
        width: food == null || !food.contains(',')
            ? PosTextSize.size1
            : fonstSize(food.split(',')[1]),
        bold: food == null
            ? false
            : food.split(',').last == 'true',
        align: PosAlign.left,
        fontType: PosFontType.fontB,
        underline: isUnderLine);
  }

  PosStyles subtotalStyle() {
    final cfg = _printConfig;
    final sub = cfg?.restaurantSubTotal;
    return PosStyles(
        height: sub == null || !sub.contains(',')
            ? PosTextSize.size1
            : fonstSize(sub.split(',').first),
        width: sub == null || !sub.contains(',')
            ? PosTextSize.size1
            : fonstSize(sub.split(',')[1]),
        bold: sub == null
            ? false
            : sub.split(',').last == 'true',
        align: PosAlign.center);
  }

  PosStyles totalStyle() {
    final cfg = _printConfig;
    final tot = cfg?.restaurantTotalAmount;
    return PosStyles(
        height: tot == null || !tot.contains(',')
            ? PosTextSize.size3
            : fonstSize(tot.split(',').first),
        width: tot == null || !tot.contains(',')
            ? PosTextSize.size2
            : fonstSize(tot.split(',')[1]),
        bold: tot == null
            ? true
            : tot.split(',').last == 'true',
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
