import 'dart:io';
import 'package:image/image.dart' as prefix;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller/auth_controller.dart';
import '../data/model/response/get_collect_bill_resoonse_model.dart';
import '../data/model/response/get_paid_order_detail_response.dart';
import '../data/model/response/get_waiter_order_list_response.dart';
import '../data/model/response/profile_model.dart';
import '../helper/logo_helper.dart';
import '../helper/local_print_config_service.dart';
import '../helper/price_converter.dart';
import '../helper/printer_config.dart';
import '../data/model/local/bill_layout_config.dart';
import 'app_constants.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../../data/model/response/get_station_order_list_response.dart'
    as station;

class PrintByteConvert {
  Future<List<int>> byteConvert({
    bool isShowDate = false,
    int paperRoll = 80,
    List<OrderDetails>? kotOrderList,
    List<OrderDetailsBar>? billFoodList,
    List<station.OrderDetailsFood>? stationOrderList,
    List<OrderDetailsFood>? paidFoodList,
    List<OrderFoodDetails>? swiggyOrderList,
    List<CartModel>? cartList,
    String orderId = '',
    String paymentType = '',
    String printType = '',
    String printTitle = '',
    String orderType = '',
    String waiterName = '',
    String stationName = '',
    String date = '',
    String custName = '',
    String custPhone = '',
    String deliveryCustPhone = '',
    String deliveryCustName = '',
    String deliveryCustAddress = '',
    String deliveryCustPincode = '',
    String deliveryAddressType = '',
    String tablename = '',
    String paymentUrl = '',
    String orderNote = '',
    double orderSubTotal = 0,
    double gstAmount = 0,
    double vatAmount = 0,
    double swiggyTax = 0,
    double serviceChargeAmount = 0,
    double discount = 0,
    double tips = 0,
    double charge = 0,
    double roomRemainingPay = 0,
    double roomAdvancePay = 0,
    double grandTotal = 0,
    double deliveryCharge = 0,
    String couponCode = '',
    double couponDiscount = 0,
    double loyaltyUsed = 0,
    double walletUsed = 0,
    double subTotalWithoutTax = 0,
    double packingCharge = 0 ,
  }) async {
    bool isOutOfMenu = false;
    List<int> bytes = [];
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;
    PrintConfigModel printConfig = paperRoll == 80
        ? profileModel.printConfigList!.last
        : profileModel.printConfigList!.first;
    isShowDate =
        profileModel.restaurants!.first.showFoodDate == 'Yes' ? true : false;

    // Load locally saved layout settings (falls back to defaults if none saved).
    final localLayout = await LocalPrintConfigService.instance.load();
    // Helper: get a section from the local layout by id, or null if not found.
    BillSectionConfig? _localSection(String id) {
      for (final s in [
        ...localLayout.billHeader,
        ...localLayout.billFooter,
        ...localLayout.kotSections,
      ]) {
        if (s.id == id) return s;
      }
      return null;
    }
    // Returns PosStyles from local config for a section, with server-config fallback.
    PosStyles _localStyle(String sectionId, {String? serverFallback, PosAlign? fallbackAlign}) {
      final sec = _localSection(sectionId);
      if (sec != null) {
        return LocalPrintConfigService.stylesFromSection(
          sec,
          isPaperSize80: paperRoll == 80,
        );
      }
      return styleFunction(
        name: serverFallback ?? '',
        isPaperSize80: paperRoll == 80,
        align: fallbackAlign ?? PosAlign.center,
      );
    }
    bool _isVisible(String sectionId, {bool defaultValue = true}) {
      final sec = _localSection(sectionId);
      return sec?.visible ?? defaultValue;
    }
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator =
        Generator(paperRoll == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.setGlobalCodeTable('CP1252');

    //////////////  Restaurant Detail ///////////////4
    if (_isVisible('logo') &&
            logoHelper.logoUrlPrint != null &&
            printType != 'kot' &&
            printType != 'swiggy_kot' &&
            printType != 'station_kot'
        //  &&
        // GetPlatform.isAndroid
        ) {
      try {
        bytes += generator.feed(1);
        bytes += generator.image(logoHelper.logoUrlPrint!);
      } catch (e) {
        print(e);
      }
    }

    if (printType == 'bill' ||
        printType == 'billing' ||
        printType == 'swiggy_bill' ||
        printType == 'paid_bill' ||
        profileModel.restaurants!.first.isShowAddressKot == 'Yes') {
      if (profileModel.restaurants != null &&
          profileModel.restaurants!.isNotEmpty) {
        final restaurant = profileModel.restaurants!.first;
        if (_isVisible('restaurant_name'))
          bytes += generator.text(restaurant.name ?? '',
              styles: _localStyle('restaurant_name',
                  serverFallback: printConfig.restaurantTitle ?? ''));
        if (_isVisible('address'))
          bytes += generator.text(restaurant.address ?? '',
              styles: _localStyle('address',
                  serverFallback: printConfig.restaurantAddress1 ?? ''));
        if (_isVisible('phone') && restaurant.phone != null && restaurant.phone != '')
          bytes += generator.text(restaurant.phone ?? '',
              styles: _localStyle('phone',
                  serverFallback: printConfig.restaurantAddress1 ?? ''));
        if (_isVisible('gst') && (restaurant.gstCode ?? '').isNotEmpty)
          bytes += generator.text('GST no. ${restaurant.gstCode ?? ''}',
              styles: _localStyle('gst',
                  serverFallback: printConfig.restaurantGstno ?? ''));
        if (_isVisible('fssai') && (restaurant.fssai ?? '').isNotEmpty)
          bytes += generator.text('FSI no. ${restaurant.fssai ?? ''}',
              styles: _localStyle('fssai',
                  serverFallback: printConfig.restaurantFssaiNo ?? ''));
      }
    }

    if (printType == 'kot' ||
        printType == 'swiggy_kot' ||
        printType == 'station_kot') {
      if (_isVisible('k_station'))
        bytes += generator.text(stationName,
            styles: _localStyle('k_station',
                serverFallback: printConfig.stationName ?? ''));
      if (_isVisible('k_title') && printTitle != '')
        bytes += generator.text(printTitle,
            styles: _localStyle('k_title',
                serverFallback: printConfig.stationName ?? ''));
    }

    ///////////////////  Order Detail /////////////////////

    final _orderIdSec = _id('order_id', 'k_order_id');
    final _dateSec    = _id('date_time', 'k_date');
    final _typeSec    = _id('order_type', 'k_order_type');
    final _waiterSec  = _id('waiter_name', 'k_waiter');
    final _custSec    = _id('customer_name', 'k_customer');
    final _tableSec   = _id('table_number', 'k_table');
    if (_isVisible(_orderIdSec) || _isVisible(_dateSec))
      bytes += generator.row([
        PosColumn(
            text: _isVisible(_orderIdSec)
                ? (printType == 'bill' || printType == 'paid_bill' || printType == 'billing' || printType == 'swiggy_bill'
                    ? 'Bill No : $orderId'
                    : 'Order Id : $orderId')
                : '',
            width: 6,
            styles: _localStyle(_orderIdSec,
                serverFallback: printConfig.resturantOrderId ?? '',
                fallbackAlign: PosAlign.left)),
        PosColumn(
            text: _isVisible(_dateSec) ? '$date' : '',
            width: 6,
            styles: _localStyle(_dateSec,
                serverFallback: printConfig.dateTime ?? '',
                fallbackAlign: PosAlign.right)),
      ]);
    if (orderType != 'delivery' &&
        orderType != 'take_away' &&
        printType != 'swiggy_kot' &&
        printType != 'swiggy_bill' &&
        (_isVisible(_typeSec) || _isVisible(_waiterSec)))
      bytes += generator.row([
        PosColumn(
            text: _isVisible(_typeSec) ? 'Dine In' : '',
            width: 5,
            styles: _localStyle(_typeSec,
                serverFallback: printConfig.orderType ?? '',
                fallbackAlign: PosAlign.left)),
        PosColumn(text: '', width: 1, styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: _isVisible(_waiterSec) ? '$waiterName' : '',
            width: 6,
            styles: _localStyle(_waiterSec,
                serverFallback: printConfig.billerName ?? '',
                fallbackAlign: PosAlign.right)),
      ]);
    if (_isVisible(_custSec) || _isVisible('customer_phone'))
      bytes += generator.row([
        PosColumn(
            text: _isVisible(_custSec) ? '$custName' : '',
            width: 5,
            styles: _localStyle(_custSec,
                serverFallback: printConfig.customerName ?? '',
                fallbackAlign: PosAlign.left)),
        PosColumn(text: '', width: 2, styles: PosStyles(align: PosAlign.center, underline: true)),
        PosColumn(
            text: _isVisible('customer_phone') ? '$custPhone' : '',
            width: 5,
            styles: _localStyle('customer_phone',
                serverFallback: printConfig.resturantOrderId,
                fallbackAlign: PosAlign.right)),
      ]);
    if (_isVisible(_tableSec))
      bytes += generator.row([
        PosColumn(text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '$tablename',
            width: 8,
            styles: _localStyle(_tableSec,
                serverFallback: printConfig.resturantTable ?? '',
                fallbackAlign: PosAlign.center)),
        PosColumn(text: '', width: 2, styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontB)),
      ]);
    bytes += generator.hr(ch: '--');

////////////////////////      food  detail    ////////////////////
///////////////////////       KOT         ///////////////////////
    if (printType == 'kot') {
      bytes += generator.row([
        PosColumn(
            text: 'sl'.tr.toUpperCase(),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader ?? '')),
        PosColumn(
          text: 'item_info'.tr,
          width: 8,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader ?? ''),
        ),
        PosColumn(
          text: 'qty'.tr,
          width: 2,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader ?? ''),
        ),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < kotOrderList!.length; i++) {
        OrderDetails cart = kotOrderList[i];
        String variationText = '';
        String addons = '';

        if ((cart.variation != null && cart.variation!.isNotEmpty) &&
            (profileModel.restaurants?.first.foodWithVariance == 'Yes')) {
          variationText += '(';
          List<String> labelList = [];

          for (int j = 0; j < (cart.variation?.length ?? 0); j++) {
            if (cart.variation?[j].values != null) {
              for (var element in cart.variation![j].values ?? []) {
                labelList.add(element.level ?? '');
              }
            }
          }
          variationText += '${labelList.join(',')}';
          variationText += ')';
        } else if ((cart.variation != null && cart.variation!.isNotEmpty) &&
            (profileModel.restaurants?.first.foodWithVariance != 'Yes')) {
          for (int j = 0; j < (cart.variation?.length ?? 0); j++) {
            variationText +=
                '${variationText.isNotEmpty ? ', ' : ''}${cart.variation![j].name ?? ''} (';

            if (cart.variation?[j].values != null) {
              List<String> labelList = [];
              for (var element in cart.variation![j].values ?? []) {
                labelList.add(element.level ?? '');
              }
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
            }

            variationText += ')';
          }
        }

        for (var i = 0; i < (cart.addOns?.length ?? 0); i++) {
          if (addons != '') {
            addons += ', ';
          }
          addons +=
              '${cart.addOns?[i].name ?? ''} (${formatQuantity(cart.addOns?[i].qty)})';
        }

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}.',
              width: 2,
              styles: _itemStyle('k_items', PosAlign.left,
                  serverFallback: printConfig.restaurantFoodList ?? '',
                  isUnderline: cart.foodStatus == 3)),
          PosColumn(
            text: profileModel.restaurants?.first.foodWithVariance == 'Yes'
                ? '${cart.foodDetails?.name ?? ''} $variationText'
                : '${cart.foodDetails?.name ?? ''}',
            width: 8,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList ?? '',
                isUnderline: cart.foodStatus == 3),
          ),
          PosColumn(
            text:
            // '${cart.quantity}',
            formatQuantity(cart.quantity),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList ?? '',
                isUnderline: cart.foodStatus == 3),
          ),
        ]);

        if (addons != '') {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Add-Ons :$addons',
              width: 8,
              styles: styleFunction(
                  isUnderline: cart.foodStatus == 3,
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList ?? '',
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PrinterConfig().foodStyle(),
            ),
          ]);
        }
        if (variationText != '' &&
            (profileModel.restaurants?.first.foodWithVariance != 'Yes')) {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Variants  :$variationText',
              width: 8,
              styles: styleFunction(
                  isUnderline: cart.foodStatus == 3,
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList ?? '',
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(align: PosAlign.center),
            ),
          ]);
        }

        if (orderNote != '' &&
            (cart.foodDetails?.name?.toLowerCase().contains('out of') ??
                false)) {
          isOutOfMenu = true;
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
                text: 'Notes  :$orderNote',
                width: 8,
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList ?? '',
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
          ]);
        }

        if ((cart.foodLevelNotes ?? '') != '') {
          bytes += generator.row([
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
            PosColumn(
                text: 'Notes  :${cart.foodLevelNotes ?? ''}',
                width: 8,
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList ?? '',
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
          ]);
        }
        bytes += generator.hr(ch: '....');
      }
    }
    if (printType == 'station_kot') {
      bytes += generator.row([
        PosColumn(
            text: 'sl'.tr.toUpperCase(),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        PosColumn(
          text: 'item_info'.tr,
          width: 8,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader!),
        ),
        PosColumn(
          text: 'qty'.tr,
          width: 2,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader!),
        ),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < stationOrderList!.length; i++) {
        station.OrderDetailsFood cart = stationOrderList[i];
        String variationText = '';
        String addons = '';

        if (cart.variation != null &&
            cart.variation!.isNotEmpty &&
            profileModel.restaurants!.first.foodWithVariance == 'Yes') {
          variationText += '(';
          List<String> labelList = [];

          for (int j = 0; j < cart.variation!.length; j++) {
            if (cart.variation![j].values != null) {
              for (var element in cart.variation![j].values!) {
                labelList.add(element.level!);
              }
            }
          }
          variationText += '${labelList.join(',')}';
          variationText += ')';
        } else if (cart.variation != null &&
            cart.variation!.isNotEmpty &&
            profileModel.restaurants!.first.foodWithVariance != 'Yes') {
          for (int j = 0; j < cart.variation!.length; j++) {
            variationText +=
                '${variationText.isNotEmpty ? ', ' : ''}${cart.variation![j].name} (';

            if (cart.variation![j].values != null) {
              List<String> labelList = [];
              for (var element in cart.variation![j].values!) {
                labelList.add(element.level!);
              }
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
            }

            variationText += ')';
          }
        }

        for (var i = 0; i < cart.addOns!.length; i++) {
          if (addons != '') {
            addons += ', ';
          }
          addons += '${cart.addOns![i].name} (${formatQuantity(cart.addOns![i].qty)})';
        }

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}.',
              width: 2,
              styles: _itemStyle('k_items', PosAlign.left,
                  serverFallback: printConfig.restaurantFoodList!,
                  isUnderline: cart.foodStatus == 3)),
          PosColumn(
            text: profileModel.restaurants!.first.foodWithVariance == 'Yes'
                ? '${cart.foodDetails!.name} $variationText'
                : '${cart.foodDetails!.name}',
            width: 8,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList!,
                isUnderline: cart.foodStatus == 3),
          ),
          PosColumn(
            text:
            // '${cart.quantity}',
            formatQuantity(cart.quantity),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList!,
                isUnderline: cart.foodStatus == 3),
          ),
        ]);

        if (addons != '') {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Add-Ons :$addons',
              width: 8,
              styles: styleFunction(
                  isUnderline: cart.foodStatus == 3,
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PrinterConfig().foodStyle(),
            ),
          ]);
        }
        if (variationText != '' &&
            profileModel.restaurants!.first.foodWithVariance != 'Yes') {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Variants  :$variationText',
              width: 8,
              styles: styleFunction(
                  isUnderline: cart.foodStatus == 3,
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(align: PosAlign.center),
            ),
          ]);
        }

        if (orderNote != '' &&
            cart.foodDetails!.name!.toLowerCase().contains('out of')) {
          isOutOfMenu = true;
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
                text: 'Notes  :${orderNote ?? ''}',
                width: 8,
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
          ]);
        }

        if (cart.foodLevelNotes != '') {
          bytes += generator.row([
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
            PosColumn(
                text: 'Notes  :${cart.foodLevelNotes}',
                width: 8,
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
          ]);
        }
        bytes += generator.hr(ch: '....');
      }
    }

///////////////////////     SWIGGY  KOT         ///////////////////////
    if (printType == 'swiggy_kot') {
      bytes += generator.row([
        PosColumn(
            text: 'sl'.tr.toUpperCase(),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        PosColumn(
          text: 'item_info'.tr,
          width: 8,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader!),
        ),
        PosColumn(
          text: 'qty'.tr,
          width: 2,
          styles: _itemStyle('k_items', PosAlign.center,
              serverFallback: printConfig.resturantFoodListHeader!),
        ),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < swiggyOrderList!.length; i++) {
        OrderFoodDetails cart = swiggyOrderList[i];
        String? addonGroupTitle;
        String? variationGroupTitle;
        String addonText = '';
        String variationText = '';

        for (var addon in cart.addOns) {
          if (addon.group != null) {
            if (addon.group!.isVariant == true) {
              // 🔹 Handle Variation
              variationGroupTitle ??= addon.group!.title ?? '';
              variationText += "${addon.title}(${addon.quantity ?? 0}), ";
            } else {
              // 🔹 Handle Add-on
              addonGroupTitle ??= addon.group!.title ?? '';
              addonText += "${addon.title}(${formatQuantity(addon.quantity)}), ";
            }
          }
        }
        if (addonText.isNotEmpty) {
          addonText = "${addonText.trim().replaceAll(RegExp(r',$'), '')}";
          // addonText =
          //     "$addonGroupTitle (${addonText.trim().replaceAll(RegExp(r',$'), '')})";
        }
        if (variationText.isNotEmpty) {
          variationText =
              "${variationText.trim().replaceAll(RegExp(r',$'), '')}";
          // variationText =
          //     "$variationGroupTitle (${variationText.trim().replaceAll(RegExp(r',$'), '')})";
        }
        // String variationText = '';
        // String addons = '';

        // if (cart.variation.isNotEmpty &&
        //     profileModel.restaurants!.first.foodWithVariance == 'Yes') {

        //   variationText += '(';
        //   List<String> labelList = [];

        //   for (int j = 0; j < cart.variation.length; j++) {
        //     if (cart.variation[j].values != null) {
        //       for (var element in cart.variation[j].values!) {
        //         labelList.add(element.level!);
        //       }
        //     }
        //   }
        //   variationText += '${labelList.join(',')}';
        //   variationText += ')';
        // } else if (cart.variation.isNotEmpty &&
        //     profileModel.restaurants!.first.foodWithVariance != 'Yes') {
        //   for (int j = 0; j < cart.variation.length; j++) {
        //     variationText +=
        //         '${variationText.isNotEmpty ? ', ' : ''}${cart.variation[j].name} (';

        //     if (cart.variation[j].values != null) {
        //       List<String> labelList = [];
        //       for (var element in cart.variation[j].values!) {
        //         labelList.add(element.level!);
        //       }
        //       variationText +=
        //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
        //     }

        //     variationText += ')';
        //   }
        // }

        // for (var i = 0; i < cart.addOns.length; i++) {
        //   if (addons != '') {
        //     addons += ', ';
        //   }
        //   addons += '${cart.addOns[i].name} (${cart.addOns[i].qty})';
        // }

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}.',
              width: 2,
              styles: _itemStyle('k_items', PosAlign.left,
                  serverFallback: printConfig.restaurantFoodList ?? '',
                  isUnderline: printTitle == 'Cancel KOT')),
          PosColumn(
            text: profileModel.restaurants?.first.foodWithVariance == 'Yes'
                ? '${cart.title} $variationText'
                : '${cart.title}',
            width: 8,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList ?? '',
                isUnderline: printTitle == 'Cancel KOT'),
          ),
          PosColumn(
            text:
            // '${cart.quantity}',
            formatQuantity(cart.quantity),
            width: 2,
            styles: _itemStyle('k_items', PosAlign.left,
                serverFallback: printConfig.restaurantFoodList ?? '',
                isUnderline: printTitle == 'Cancel KOT'),
          ),
        ]);

        if (addonText != '') {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Add-Ons :$addonText',
              width: 8,
              styles: styleFunction(
                  isUnderline: printTitle == 'Cancel KOT',
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PrinterConfig().foodStyle(),
            ),
          ]);
        }
        if (variationText != '' &&
            profileModel.restaurants!.first.foodWithVariance != 'Yes') {
          bytes += generator.row([
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: 'Variants  :$variationText',
              width: 8,
              styles: styleFunction(
                  isUnderline: printTitle == 'Cancel KOT',
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 2,
              styles: PosStyles(align: PosAlign.center),
            ),
          ]);
        }

        if (cart.foodLevelNotes != '') {
          bytes += generator.row([
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
            PosColumn(
                text: 'Notes  :${cart.foodLevelNotes}',
                width: 8,
                styles: styleFunction(
                    isUnderline: printTitle == 'Cancel KOT',
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '', width: 2, styles: PosStyles(align: PosAlign.center)),
          ]);
        }
        bytes += generator.hr(ch: '....');
      }
    }
    // Order note at bottom of any KOT type, if visible in layout config.
    if (_isKot() && orderNote != '' && _isVisible('k_note'))
      bytes += generator.text(
        'Note: $orderNote',
        styles: _localStyle('k_note',
            serverFallback: '', fallbackAlign: PosAlign.left),
      );
/////////////////////         BILL        /////////////////////
    if (printType == 'bill') {
      bytes += generator.row([
        // PosColumn(
        //   text: 'SL',
        //   width: getOrderTypeValue('sl',
        //       isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
        //   styles: styleFunction(
        //       align: PosAlign.left,
        //       name: printConfig.resturantFoodListHeader!,
        //       isPaperSize80: paperRoll == 80),
        // ),
        PosColumn(
            text: 'item_info'.tr,
            width: getOrderTypeValue('name',
                isHideSl: true,
                isShowDate: isShowDate,
                printerSize80mm: paperRoll == 80),
            styles: _itemStyle('bill_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        PosColumn(
            text: 'qty'.tr,
            width: getOrderTypeValue('qty',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: _itemStyle('bill_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        PosColumn(
            text: 'Price',
            width: getOrderTypeValue('price',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: _itemStyle('bill_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        PosColumn(
            text: 'Total',
            width: getOrderTypeValue('total',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: _itemStyle('bill_items', PosAlign.left,
                serverFallback: printConfig.resturantFoodListHeader!)),
        if (isShowDate && paperRoll == 80)
          PosColumn(
              text: 'Date',
              width: getOrderTypeValue('date',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: _itemStyle('bill_items', PosAlign.left,
                  serverFallback: printConfig.resturantFoodListHeader!)),
      ]);
      bytes += generator.hr(ch: '--');

      for (var i = 0; i < billFoodList!.length; i++) {
        OrderDetailsBar food = billFoodList[i];
        String variationText = '';
        String addons = '';

        double variationTotal = 0;
        double addonsTotal = 0;
        double variationBasePrice = 0;
        double addonBasePrice = 0;
        double halfVariationPrice = 0;

        if (food.variation != null && food.variation!.isNotEmpty) {
          variationText += '(';

          List<String> labelList = [];
          for (int j = 0; j < food.variation!.length; j++) {
            // variationText +=
            //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

            if (food.variation![j].values != null) {
              for (var element in food.variation![j].values!) {
                labelList.add(element.level!);
                // variationBasePrice += double.parse(element.optionPrice);
                // variationTotal +=
                //     (double.parse(element.optionPrice) * food.quantity);
                if ((food.variation?[j].name?.toUpperCase() ?? '') ==
                    'HALFNHALF') {
                  if (halfVariationPrice <
                      ((element.optionPrice != null && food.quantity != null)
                          ? double.parse(element.optionPrice!) * food.quantity!
                          : 0)) {
                    variationBasePrice = (element.optionPrice != null)
                        ? double.parse(element.optionPrice!)
                        : 0;
                    halfVariationPrice = (element.optionPrice != null &&
                            food.quantity != null)
                        ? double.parse(element.optionPrice!) * food.quantity!
                        : 0;
                  }
                } else {
                  variationBasePrice =variationBasePrice+ ((element.optionPrice != null)
                      ? double.parse(element.optionPrice!)
                      : 0);

                  variationTotal = variationTotal +
                      ((element.optionPrice != null && food.quantity != null)
                          ? double.parse(element.optionPrice!) * food.quantity!
                          : 0);
                }
              }
              variationTotal = variationTotal + halfVariationPrice;

              // variationText +=
              //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
            }

            // variationText += ')';
          }
          variationText += '${labelList.join(',')}';
          variationText += ')';
        }

        if (food.addOns != null) {
          for (var i = 0; i < food.addOns!.length; i++) {
            final addOn = food.addOns![i];
            final addOnName = addOn.name ?? '';
            final addOnQuantity = addOn.quantity ?? 0;
            final addOnPrice = addOn.price ?? 0.0;
            final foodQuantity = food.quantity ?? 0;
            addons += '${addOnName} (${addOnQuantity})';
            addonBasePrice = addonBasePrice + (addOnPrice * addOnQuantity);
            addonsTotal =
                addonsTotal + ((addOnPrice * addOnQuantity) * foodQuantity);
          }
        }
        String foodName = ('${food.foodDetails!['name']} $variationText')
            .toString()
            .replaceAll('-', ' ')
            .replaceAll(' – ', ' ');
        if (food.foodStatus != 3)
          bytes += generator.row([
            // PosColumn(
            //     text: '${i + 1}.',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         isUnderline: food.foodStatus == 3,
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList!,
            //         isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: foodName,
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: _itemStyle('bill_items', PosAlign.left,
                    serverFallback: printConfig.restaurantFoodList!,
                    isUnderline: food.foodStatus == 3)),
            PosColumn(
                text:
                // '${food.quantity}',
                formatQuantity(food.quantity),
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: _itemStyle('bill_items', PosAlign.left,
                    serverFallback: printConfig.restaurantFoodList!,
                    isUnderline: food.foodStatus == 3)),
            PosColumn(
                text: food.isComplementary != null && food.isComplementary!
                    ? '0'
                    : ((food.foodDetails!['name'].toString().toUpperCase() ==
                            'CHECK IN')
                        ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                        : '${(food.unitPrice! + variationBasePrice).toInt()}'),
                // '${(food.unitPrice * food.quantity) + (variationTotal) + (addonsTotal)}',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: _itemStyle('bill_items', PosAlign.left,
                    serverFallback: printConfig.restaurantFoodList!,
                    isUnderline: food.foodStatus == 3)),
            PosColumn(
                text: food.isComplementary != null && food.isComplementary!
                    ? '0'
                    : ((food.foodDetails!['name'].toString().toUpperCase() ==
                            'CHECK IN')
                        ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                        : '${((food.unitPrice! * food.quantity!) + variationTotal).toInt()}'),
                // '${(food.unitPrice * food.quantity) + (variationTotal) + (addonsTotal)}',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: _itemStyle('bill_items', PosAlign.right,
                    serverFallback: printConfig.restaurantFoodList!,
                    isUnderline: food.foodStatus == 3)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text:
                      '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt!))}',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: _itemStyle('bill_items', PosAlign.right,
                      serverFallback: printConfig.restaurantFoodList!,
                      isUnderline: food.foodStatus == 3)),
          ]);
        if (food.foodStatus != 3 && addons != '' && addonsTotal != 0) {
          // bytes += generator.hr(ch: '....');
         
// for (var a = 0; a < food.addOns!.length; a++) {
//   bytes += generator.row([
           

//             PosColumn(
//                 text:a==0?'Add-Ons :${food.addOns![a].name}': '${food.addOns![a].name}',
//                 width: getOrderTypeValue('name',
//                     isShowDate: isShowDate,
//                     isHideSl: true,
//                     printerSize80mm: paperRoll == 80),
//                 styles: styleFunction(
//                     align: PosAlign.left,
//                     isUnderline: food.foodStatus == 3,
//                     name: printConfig.restaurantFoodList!,
//                     isPaperSize80: paperRoll == 80)),
//             PosColumn(
//                 text: '${food.addOns![a].quantity}',
//                 width: getOrderTypeValue('qty',
//                     isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
//                 styles: styleFunction(
//                     align: PosAlign.left,
//                     name: printConfig.restaurantFoodList!,
//                     isPaperSize80: paperRoll == 80)),
//             PosColumn(
//                 text: food.isComplementary != null && food.isComplementary!
//                     ? '0'
//                     : '${food.addOns![a].price}',
//                 width: getOrderTypeValue('price',
//                     isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
//                 styles: styleFunction(
//                     align: PosAlign.left,
//                     isUnderline: food.foodStatus == 3,
//                     name: printConfig.restaurantFoodList!,
//                     isPaperSize80: paperRoll == 80)),
//             PosColumn(
//                 text: food.isComplementary != null && food.isComplementary!
//                     ? '0'
//                     : '${food.addOns![a].price!*food.quantity!}',
//                 width: getOrderTypeValue('total',
//                     isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
//                 styles: styleFunction(
//                     align: PosAlign.right,
//                     isUnderline: food.foodStatus == 3,
//                     name: printConfig.restaurantFoodList!,
//                     isPaperSize80: paperRoll == 80)),
//             if (isShowDate && paperRoll == 80)
//               PosColumn(
//                   text: '',
//                   width: getOrderTypeValue('date',
//                       isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
//                   styles: styleFunction(
//                       align: PosAlign.left,
//                       name: printConfig.restaurantFoodList!,
//                       isPaperSize80: paperRoll == 80)),
//           ]);
// }

          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList!,
            //         isPaperSize80: paperRoll == 80)),


            PosColumn(
                text: 'Add-Ons :$addons',
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    isUnderline: food.foodStatus == 3,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: food.isComplementary != null && food.isComplementary!
                    ? '0'
                    : '${addonBasePrice.toInt()}',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    isUnderline: food.foodStatus == 3,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: food.isComplementary != null && food.isComplementary!
                    ? '0'
                    : '${addonsTotal.toInt()}',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.right,
                    isUnderline: food.foodStatus == 3,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: styleFunction(
                      align: PosAlign.left,
                      name: printConfig.restaurantFoodList!,
                      isPaperSize80: paperRoll == 80)),
          ]);
        }

        if (food.foodStatus != 3 &&
            orderNote != '' &&
            food.foodDetails!['name']
                .toString()
                .toLowerCase()
                .contains('out of')) {
          bytes += generator.hr(ch: '....');
          // bytes += generator.row([
          //   PosColumn(
          //     text: '',
          //     width: 2,
          //     styles: PosStyles(
          //       align: PosAlign.center,
          //     ),
          //   ),
          //   PosColumn(
          //       text: 'Notes  :$orderNote',
          //       width: 8,
          //       styles: styleFunction(
          //           align: PosAlign.left,
          //           name: printConfig.restaurantFoodList,
          //           isPaperSize80: paperRoll == 80)),
          //   PosColumn(
          //     text: '',
          //     width: 2,
          //     styles: PosStyles(align: PosAlign.center),
          //   ),
          // ]);
          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList!,
            //         isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: 'Notes  :$orderNote',
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: styleFunction(
                      align: PosAlign.left,
                      name: printConfig.restaurantFoodList!,
                      isPaperSize80: paperRoll == 80)),
          ]);
        }
        if (food.foodStatus != 3) bytes += generator.hr(ch: '....');
      }
    }

// /////////////////       PAID BILL DETAIL  ////////////////
    if (printType == 'paid_bill') {
      bytes += generator.row([
        // PosColumn(
        //     text: 'SL',
        //     width: getOrderTypeValue('sl',
        //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
        //     styles: styleFunction(
        //         align: PosAlign.left,
        //         name: printConfig.resturantFoodListHeader!,
        //         isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'item_info'.tr,
            width: getOrderTypeValue('name',
                isShowDate: isShowDate,
                isHideSl: true,
                printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'qty'.tr,
            width: getOrderTypeValue('qty',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Price',
            width: getOrderTypeValue('price',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.right,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Total',
            width: getOrderTypeValue('total',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.right,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        if (isShowDate && paperRoll == 80)
          PosColumn(
              text: 'Date',
              width: getOrderTypeValue('date',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.resturantFoodListHeader!,
                  isPaperSize80: paperRoll == 80)),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < paidFoodList!.length; i++) {
        OrderDetailsFood food = paidFoodList[i];
        String variationText = '';
        String addons = '';

        double variationTotal = 0;
        double halfVariationPrice = 0;
        double baseVariation = 0;
        // double baseAddon = 0;
        double addonsTotal = 0;

        if (food.variation != null && food.variation!.isNotEmpty) {
          variationText += '(';
          List<String> labelList = [];
          for (int j = 0; j < (food.variation?.length ?? 0); j++) {
            final variation = food.variation![j];
            final variationName = variation.name ?? '';
            final variationValues = variation.values;
            if (variationValues != null) {
              for (var element in variationValues) {
                labelList.add(element.label ?? '');
                final optionPriceStr = element.optionPrice ?? '0';
                final foodQty = food.quantity ?? 0;
                if ((variationName).toUpperCase() == 'HALFNHALF') {
                  final optionPrice = double.tryParse(optionPriceStr) ?? 0.0;
                  if (halfVariationPrice < optionPrice * foodQty) {
                    baseVariation = optionPrice;
                    halfVariationPrice = optionPrice * foodQty;
                  }
                } else {
                  final optionPrice = double.tryParse(optionPriceStr) ?? 0.0;
                  baseVariation = optionPrice;
                  variationTotal = variationTotal + (optionPrice * foodQty);
                }
              }
              variationTotal = variationTotal + halfVariationPrice;
            }
          }
          variationText += '${labelList.join(',')}';
          variationText += ')';
        }

        if (food.addOns != null) {
          for (var i = 0; i < (food.addOns?.length ?? 0); i++) {
            final addOn = food.addOns![i];
            final addOnName = addOn.name ?? '';
            final addOnQuantity = addOn.quantity ?? 0;
            final addOnPrice = addOn.price ?? 0.0;
            addons += '${addOnName} (${addOnQuantity})';
            // baseAddon = baseAddon + (addOnPrice * addOnQuantity);
            addonsTotal = addonsTotal + (addOnPrice * addOnQuantity);
          }
        }
        String foodName = ('${food.foodDetails!.name} $variationText')
            .toString()
            .replaceAll('-', ' ')
            .replaceAll(' – ', ' ');
        bytes += generator.row([
          // PosColumn(
          //     text: '${i + 1}.',
          //     width: getOrderTypeValue('sl',
          //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
          //     styles: styleFunction(
          //         align: PosAlign.left,
          //         name: printConfig.restaurantFoodList!,
          //         isPaperSize80: paperRoll == 80)),
          PosColumn(
            text: '${foodName}',
            width: getOrderTypeValue('name',
                isShowDate: isShowDate,
                isHideSl: true,
                printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: 
            // '${food.quantity}',
            formatQuantity(food.quantity),
            width: getOrderTypeValue('qty',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: food.isComplementary == 1
                ? '0'
                : '${(food.unitPrice! + baseVariation).toInt()}',
            // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
            width: getOrderTypeValue('price',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: food.isComplementary == 1
                ? '0'
                : '${((food.unitPrice! * food.quantity!) + variationTotal).toInt()}',
            // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
            width: getOrderTypeValue('total',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.right,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          if (isShowDate && paperRoll == 80)
            PosColumn(
              text:
                  '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt!))}',
              width: getOrderTypeValue('date',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
        ]);
        if (addons != '' && addonsTotal != 0) {
          // bytes += generator.hr(ch: '....');
          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: PrinterConfig().foodStyle()),
            PosColumn(
              text: 'Add-Ons :$addons',
              width: getOrderTypeValue('name',
                  isShowDate: isShowDate,
                  isHideSl: true,
                  printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: PrinterConfig().foodStyle()),
            PosColumn(
              text: food.isComplementary == 1
                  ? '0'
                  : '${(addonsTotal * food.quantity!).toInt()}',
              width: getOrderTypeValue('price',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: food.isComplementary == 1 ? '0' : '${addonsTotal.toInt()}',
              width: getOrderTypeValue('total',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80),
            ),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: PrinterConfig().foodStyle()),
          ]);
        }
        if (food.foodStatus != 3 &&
            orderNote != '' &&
            food.foodDetails!.name
                .toString()
                .toLowerCase()
                .contains('out of')) {
          bytes += generator.hr(ch: '....');
          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList!,
            //         isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: 'Notes  :$orderNote',
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: styleFunction(
                      align: PosAlign.left,
                      name: printConfig.restaurantFoodList!,
                      isPaperSize80: paperRoll == 80)),
          ]);
        }

        bytes += generator.hr(ch: '....');
      }
    }
// /////////////////       PREPAID BILL DETAIL  ////////////////
    if (printType == 'billing') {
      bytes += generator.row([
        // PosColumn(
        //     text: 'SL',
        //     width: getOrderTypeValue('sl',
        //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
        //     styles: styleFunction(
        //         align: PosAlign.left,
        //         name: printConfig.resturantFoodListHeader,
        //         isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'item_info'.tr,
            width: getOrderTypeValue('name',
                isHideSl: true,
                isShowDate: isShowDate,
                printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'qty'.tr,
            width: getOrderTypeValue('qty',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Price',
            width: getOrderTypeValue('price',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Total',
            width: getOrderTypeValue('total',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.right,
                name: printConfig.resturantFoodListHeader,
                isPaperSize80: paperRoll == 80)),
        if (isShowDate && paperRoll == 80)
          PosColumn(
              text: 'Date',
              width: getOrderTypeValue('date',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.resturantFoodListHeader,
                  isPaperSize80: paperRoll == 80)),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < cartList!.length; i++) {
        CartModel food = cartList[i];
        String variationText = '';
        String addons = '';

        double variationTotal = 0;
        double halfVariationPrice = 0;
        double baseVariation = 0;
        // double baseAddon = 0;
        double addonsTotal = 0;

        if (food.variation.isNotEmpty) {
          for (int index = 0; index < food.variation.length; index++) {
            if (food.variation[index].isNotEmpty &&
                food.variation[index].contains(true)) {
              variationText +=
                  '${variationText.isNotEmpty ? ', ' : ''}${food.product.variations![index].name} (';

              for (int i = 0; i < food.variation[index].length; i++) {
                if (food.variation[index][i]) {
                  if (food.product.variations![index].name!.toUpperCase() ==
                      'HALFNHALF') {
                    if (halfVariationPrice <
                        (double.parse(food.product.variations![index].values![i]
                                .optionPrice!) *
                            food.quantity)) {
                      baseVariation = double.parse(food
                          .product.variations![index].values![i].optionPrice!);
                      halfVariationPrice = (double.parse(food.product
                              .variations![index].values![i].optionPrice!) *
                          food.quantity);
                    }
                  } else {
                    variationTotal += (double.parse(food.product
                            .variations![index].values![i].optionPrice!) *
                        food.quantity);
                    baseVariation = baseVariation +
                        double.parse(food.product.variations![index].values![i]
                            .optionPrice!);
                  }
                  // print(variationTotal);
                  variationText +=
                      '${variationText.endsWith('(') ? '' : ', '}${food.product.variations![index].values![i].level}';
                }
              }
              variationText += ')';
              variationTotal = variationTotal + halfVariationPrice;
            }
          }
        }
        int index0 = 0;
        double baseAddon=0;
        // List<int> ids = [];
        // List<int> qtys = [];
        // for (var addOn in food.addOnIds) {
        //   ids.add(addOn.id);
        //   qtys.add(addOn.quantity);
        // }
        // for (var addOn in food.product.addOns!) {
        //   if (ids.contains(addOn.id)) {
        //     addons =
        //         '$addons${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        //     baseAddon =
        //         addonsTotal = addonsTotal + (addOn.price! * qtys[index0]);
        //     baseAddon = (addOn.price! * qtys[index0]);
        //     index0 = index0 + 1;
        //   }
        // }
        if (food!.addOns != null) {
          for (var addOn in food.addOnIds) {
            if (addOn != null && addOn.quantity != 0) {
              addons =
                  '$addons${(index0 == 0) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
              addonsTotal =
                  addonsTotal + ((addOn.price ?? 0) * (addOn.quantity ?? 0));
              baseAddon =baseAddon+ ((addOn.price ?? 0) * (addOn.quantity ?? 0));
              index0 = index0 + 1;
            }
          }
        }
        String foodName = ('${food.product.name} $variationText')
            .toString()
            .replaceAll('-', ' ')
            .replaceAll(' – ', ' ');
        bytes += generator.row([
          // PosColumn(
          //     text: '${i + 1}.',
          //     width: getOrderTypeValue('sl',
          //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
          //     styles: styleFunction(
          //         align: PosAlign.left,
          //         name: printConfig.restaurantFoodList,
          //         isPaperSize80: paperRoll == 80)),
          PosColumn(
            text: '${foodName}',
            width: getOrderTypeValue('name',
                isShowDate: isShowDate,
                isHideSl: true,
                printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: 
            // '${food.quantity}',
            formatQuantity(food.quantity),
            width: getOrderTypeValue('qty',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: food.isComplementry
                ? '0'
                : '${((((food.discountedPrice -baseAddon)) + (Get.find<TableController>().selectedTable == null ? 0 : Get.find<TableController>().selectedTable!.tableNo == 'Take Away' ? (food.product.takeAwayFoodPrice!) : Get.find<TableController>().selectedTable!.tableNo == 'Delivery' ? (food.product.deliveryFoodPrice!) : 0)) ).toInt()}',
            // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
            width: getOrderTypeValue('price',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: food.isComplementry
                ? '0'
                : '${(((
                  (food.discountedPrice -  baseAddon) + 
                  (Get.find<TableController>().selectedTable == null ? 0 : Get.find<TableController>().selectedTable!.tableNo == 'Take Away' ? (food.product.takeAwayFoodPrice! * food.quantity) : Get.find<TableController>().selectedTable!.tableNo == 'Delivery' ? (food.product.deliveryFoodPrice! * food.quantity) : 0))
                   * food.quantity) ).toInt()}',

            // text: '${(food.price) + (variationTotal) + (addonsTotal)}',
            width: getOrderTypeValue('total',
                isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            styles: styleFunction(
                align: PosAlign.right,
                name: printConfig.restaurantFoodList,
                isPaperSize80: paperRoll == 80),
          ),
          if (isShowDate && paperRoll == 80)
            PosColumn(
              text: '${DateFormat('dd-MMM').format(DateTime.now())}',
              width: getOrderTypeValue('date',
                  isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.restaurantFoodList,
                  isPaperSize80: paperRoll == 80),
            ),
        ]);
        if (addons != '' && addonsTotal != 0) {
          // bytes += generator.hr(ch: '....');
          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList!,
            //         isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: 'Add-Ons :$addons',
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: food.isComplementry ? '0' : '${addonsTotal.toInt()}',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: food.isComplementry
                    ? '0'
                    : '${(addonsTotal * food.quantity).toInt()}',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.right,
                    name: printConfig.restaurantFoodList!,
                    isPaperSize80: paperRoll == 80)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: styleFunction(
                      align: PosAlign.left,
                      name: printConfig.restaurantFoodList!,
                      isPaperSize80: paperRoll == 80)),
          ]);
        }
        if (orderNote != '' &&
            food.product.name.toString().toLowerCase().contains('out of')) {
          bytes += generator.hr(ch: '....');
          bytes += generator.row([
            // PosColumn(
            //     text: '',
            //     width: getOrderTypeValue('sl',
            //         isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
            //     styles: styleFunction(
            //         align: PosAlign.left,
            //         name: printConfig.restaurantFoodList,
            //         isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: 'Notes  :$orderNote',
                width: getOrderTypeValue('name',
                    isShowDate: isShowDate,
                    isHideSl: true,
                    printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('qty',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('price',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList,
                    isPaperSize80: paperRoll == 80)),
            PosColumn(
                text: '',
                width: getOrderTypeValue('total',
                    isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                styles: styleFunction(
                    align: PosAlign.left,
                    name: printConfig.restaurantFoodList,
                    isPaperSize80: paperRoll == 80)),
            if (isShowDate && paperRoll == 80)
              PosColumn(
                  text: '',
                  width: getOrderTypeValue('date',
                      isShowDate: isShowDate, printerSize80mm: paperRoll == 80),
                  styles: styleFunction(
                      align: PosAlign.left,
                      name: printConfig.restaurantFoodList,
                      isPaperSize80: paperRoll == 80)),
          ]);
        }

        bytes += generator.hr(ch: '....');
      }
    }

// /////////////////       SWIGGY BILL DETAIL  ////////////////

    if (printType == 'swiggy_bill') {
      bytes += generator.row([
        PosColumn(
            text: 'SL',
            width: 2,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Items',
            width: 6,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'qty'.tr,
            width: 1,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
        PosColumn(
            text: 'Price',
            width: 3,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.resturantFoodListHeader!,
                isPaperSize80: paperRoll == 80)),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0; i < swiggyOrderList!.length; i++) {
        OrderFoodDetails food = swiggyOrderList[i];
        String? addonGroupTitle;
        String? variationGroupTitle;
        String addonText = '';
        String variationText = '';

        for (var addon in food.addOns) {
          if (addon.group != null) {
            if (addon.group!.isVariant == true) {
              // 🔹 Handle Variation
              variationGroupTitle ??= addon.group!.title ?? '';
              variationText += "${addon.title}(${addon.quantity ?? 0}), ";
            } else {
              // 🔹 Handle Add-on
              addonGroupTitle ??= addon.group!.title ?? '';
              addonText += "${addon.title}(${addon.quantity ?? 0}), ";
            }
          }
        }
        if (addonText.isNotEmpty) {
          addonText = "${addonText.trim().replaceAll(RegExp(r',$'), '')}";
          // addonText =
          //     "$addonGroupTitle (${addonText.trim().replaceAll(RegExp(r',$'), '')})";
        }
        if (variationText.isNotEmpty) {
          variationText =
              "${variationText.trim().replaceAll(RegExp(r',$'), '')}";
          // variationText =
          //     "$variationGroupTitle (${variationText.trim().replaceAll(RegExp(r',$'), '')})";
        }
        // if (food.variation.isNotEmpty) {
        //   variationText += '(';
        //   List<String> labelList = [];
        //   for (int j = 0; j < food.variation.length; j++) {
        //     // variationText +=
        //     //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

        //     if (food.variation[j].values != null) {
        //       for (var element in food.variation[j].values!) {
        //         labelList.add(element.level!);
        //         baseVariation += double.parse(element.optionPrice!);
        //         variationTotal +=
        //             (int.parse(element.optionPrice!) * food.quantity);
        //       }
        //       // variationText +=
        //       //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
        //     }

        //     // variationText += ')';
        //   }
        //   variationText += '${labelList.join(',')}';
        //   variationText += ')';
        // }

        // for (var i = 0; i < food.addOns.length; i++) {
        //   addons += '${food.addOns[i].name} (${food.addOns[i].qty})';
        //   baseAddon = baseAddon + food.addOns[i].price! * food.addOns[i].qty!;
        //   addonsTotal =
        //       addonsTotal + (food.addOns[i].price! * food.addOns[i].qty!);
        // }

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}.',
              width: 2,
              styles: styleFunction(
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList!,
                  isPaperSize80: paperRoll == 80)),
          PosColumn(
            text: '${food.title} $variationText',
            width: 6,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: 
            // '${food.quantity}',
            formatQuantity(food.quantity),
            width: 1,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList!,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: '${(food.price).toStringAsFixed(2)}',
            width: 3,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.restaurantFoodList,
                isPaperSize80: paperRoll == 80),
          ),
        ]);
        if (addonText != '') {
          // bytes += generator.hr(ch: '....');
          bytes += generator.row([
            PosColumn(
              text: 'Add-Ons :$addonText',
              width: 8,
              styles: styleFunction(
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 4,
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.restaurantFoodList,
                  isPaperSize80: paperRoll == 80),
            ),
          ]);
        }
        if (food.foodLevelNotes != '') {
          bytes += generator.hr(ch: '....');
          bytes += generator.row([
            PosColumn(
              text: 'Note :${food.foodLevelNotes}',
              width: 8,
              styles: styleFunction(
                  align: PosAlign.left,
                  name: printConfig.restaurantFoodList,
                  isPaperSize80: paperRoll == 80),
            ),
            PosColumn(
              text: '',
              width: 4,
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.restaurantFoodList,
                  isPaperSize80: paperRoll == 80),
            ),
          ]);
        }

        bytes += generator.hr(ch: '....');
      }
    }
    if (orderNote != '') {
      bytes += generator.text('${'Notes'.tr}:  $orderNote',
          styles: styleFunction(
              align: PosAlign.left,
              name: printConfig.restaurantFoodList,
              isPaperSize80: paperRoll == 80));
      bytes += generator.hr(ch: '....');
    }
////////////////////////      Bill amount detail    //////////////
    // Label-value row using local config size+bold; label=left, value=right.
    PosStyles _footerLabel(String sectionId, {String? serverFallback}) {
      final sec = _localSection(sectionId);
      return sec != null
          ? LocalPrintConfigService.labelStyleFromSection(sec, isPaperSize80: paperRoll == 80)
          : styleFunction(align: PosAlign.left, name: serverFallback ?? '', isPaperSize80: paperRoll == 80);
    }
    PosStyles _footerValue(String sectionId, {String? serverFallback}) {
      final sec = _localSection(sectionId);
      return sec != null
          ? LocalPrintConfigService.valueStyleFromSection(sec, isPaperSize80: paperRoll == 80)
          : styleFunction(align: PosAlign.right, name: serverFallback ?? '', isPaperSize80: paperRoll == 80);
    }
    // Returns true when the current print is any KOT type.
    bool _isKot() => printType == 'kot' || printType == 'swiggy_kot' || printType == 'station_kot';
    // Picks the KOT section id when printing a KOT, otherwise the bill section id.
    String _id(String billId, String kotId) => _isKot() ? kotId : billId;

    // For item/qty rows: section's size+bold, caller's per-column alignment.
    PosStyles _itemStyle(String sectionId, PosAlign align,
        {String? serverFallback, bool isUnderline = false}) {
      final sec = _localSection(sectionId);
      return sec != null
          ? LocalPrintConfigService.stylesFromSectionWithAlign(sec, align,
              isPaperSize80: paperRoll == 80, isUnderline: isUnderline)
          : styleFunction(
              align: align,
              name: serverFallback ?? '',
              isPaperSize80: paperRoll == 80,
              isUnderline: isUnderline);
    }

    List<int> _footerRow(String sectionId, String label, String value,
        {String? serverFallback}) =>
        generator.row([
          PosColumn(text: label, width: 8, styles: _footerLabel(sectionId, serverFallback: serverFallback)),
          PosColumn(text: value, width: 4, styles: _footerValue(sectionId, serverFallback: serverFallback)),
        ]);

    if (printType == 'bill' ||
        printType == 'billing' ||
        printType == 'paid_bill' ||
        printType == 'swiggy_bill') {
      if (printType != 'swiggy_bill' && _isVisible('item_total'))
        bytes += _footerRow(
          'item_total', 'Item Total',
          PriceConverter.convertPrice(orderSubTotal, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.restaurantSubTotal,
        );

      if (roomAdvancePay != 0)
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 1,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Room Advance',
            width: 7,
            styles: styleFunction(
                name: printConfig.gstParcent, isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: '',
            width: 1,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
              text:
                  '${PriceConverter.convertPrice(roomAdvancePay, isHideCurrency: true, asFixed: 2)}',
              width: 3,
              styles: styleFunction(
                  name: printConfig.gstParcent,
                  isPaperSize80: paperRoll == 80)),
        ]);
      if (roomRemainingPay != 0)
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 1,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Room Pending',
            width: 7,
            styles: styleFunction(
                name: printConfig.gstParcent, isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
            text: '',
            width: 1,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
              text:
                  '${PriceConverter.convertPrice(roomRemainingPay, isHideCurrency: true, asFixed: 2)}',
              width: 3,
              styles: styleFunction(
                  name: printConfig.gstParcent,
                  isPaperSize80: paperRoll == 80)),
        ]);
      if (discount != 0 && _isVisible('discount'))
        bytes += _footerRow(
          'discount',
          couponCode != '' ? 'Coupon Discount' : '${profileModel.restaurants!.first.discountText}',
          PriceConverter.convertPrice(discount, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.discount,
        );
      if (couponDiscount != 0 && _isVisible('coupon_discount'))
        bytes += _footerRow(
          'coupon_discount', 'Coupon Discount',
          PriceConverter.convertPrice(couponDiscount, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.discount,
        );
      if (couponCode != '' && _isVisible('coupon_discount'))
        bytes += generator.row([
          PosColumn(text: 'Coupon Code', width: 5, styles: _footerLabel('coupon_discount', serverFallback: printConfig.discount)),
          PosColumn(text: couponCode, width: 7, styles: _footerValue('coupon_discount', serverFallback: printConfig.discount)),
        ]);
      if (loyaltyUsed != 0 && _isVisible('loyalty'))
        bytes += _footerRow(
          'loyalty', 'Used Loyalty Point',
          PriceConverter.convertPrice(loyaltyUsed, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.discount,
        );
      if (tips != 0 && _isVisible('tips'))
        bytes += _footerRow(
          'tips', 'Add Tips',
          PriceConverter.convertPrice(tips, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.tip,
        );
      if (serviceChargeAmount != 0 && _isVisible('service_charge'))
        bytes += _footerRow(
          'service_charge',
          '${Get.find<AuthController>().profileModel!.restaurants!.first.settings!.serviceChrgTaxt ?? 'Service Charge'}',
          PriceConverter.convertPrice(serviceChargeAmount, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.serviceCharge,
        );
      if (deliveryCharge != 0 && _isVisible('delivery_charge'))
        bytes += _footerRow(
          'delivery_charge', 'Delivery Charge',
          PriceConverter.convertPrice(deliveryCharge, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.deliveryCharge,
        );
      if (packingCharge != 0 && _isVisible('packing_charge'))
        bytes += _footerRow(
          'packing_charge', 'Packing Charge',
          PriceConverter.convertPrice(packingCharge, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.deliveryCharge,
        );

      if (charge != 0)
        bytes += generator.row([
          PosColumn(
            text: 'Delivery & other charges',
            width: 8,
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.deliveryCharge,
                isPaperSize80: paperRoll == 80),
          ),
          PosColumn(
              text: PriceConverter.convertPrice(charge,
                  isHideCurrency: true, asFixed: 2),
              width: 4,
              styles: styleFunction(
                  align: PosAlign.right,
                  name: printConfig.deliveryCharge,
                  isPaperSize80: paperRoll == 80)),
        ]);
      if (_isVisible('subtotal'))
        bytes += _footerRow(
          'subtotal', 'Sub Total',
          PriceConverter.convertPrice(subTotalWithoutTax, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.restaurantSubTotal,
        );
      if (swiggyTax != 0)
        bytes += _footerRow(
          'cgst', 'Total Tax',
          PriceConverter.convertPrice(swiggyTax, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.gstParcent,
        );
      if (gstAmount != 0 && _isVisible('cgst'))
        bytes += _footerRow(
          'cgst', 'CGST(2.5%)',
          PriceConverter.convertPrice(gstAmount / 2, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.gstParcent,
        );
      if (gstAmount != 0 && _isVisible('sgst'))
        bytes += _footerRow(
          'sgst', 'SGST(2.5%)',
          PriceConverter.convertPrice(gstAmount / 2, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.gstParcent,
        );
      if (vatAmount != 0 && _isVisible('vat'))
        bytes += _footerRow(
          'vat', 'VAT',
          PriceConverter.convertPrice(vatAmount, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.vatParcent,
        );
      if (walletUsed != 0 && _isVisible('wallet'))
        bytes += _footerRow(
          'wallet', 'Used Wallet Amount',
          PriceConverter.convertPrice(walletUsed, isHideCurrency: true, asFixed: 2),
          serverFallback: printConfig.discount,
        );

      bytes += generator.hr(ch: '....');
      final _grandTotalText = profileModel.restaurants!.first.isTotalRound == 'Yes'
          ? '${getRoundUpValue(value: grandTotal)}'
          : PriceConverter.convertPrice(grandTotal, isHideCurrency: true, asFixed: 2);
      if (paymentType != '' && _isVisible('payment_type') && _isVisible('grand_total'))
        bytes += generator.row([
          PosColumn(
            text: 'Payment: $paymentType',
            width: 6,
            styles: _footerLabel('payment_type', serverFallback: printConfig.restaurantSubTotal),
          ),
          PosColumn(
            text: 'Total: $_grandTotalText',
            width: 6,
            styles: _footerValue('grand_total', serverFallback: printConfig.restaurantTotalAmount),
          ),
        ]);
      if (paymentType != '' && _isVisible('payment_type') && !_isVisible('grand_total'))
        bytes += _footerRow(
          'payment_type', 'Payment by', paymentType,
          serverFallback: printConfig.restaurantSubTotal,
        );
      if (_isVisible('grand_total') && (paymentType == '' || !_isVisible('payment_type')))
        bytes += generator.row([
          PosColumn(text: 'Total:', width: 6, styles: _footerLabel('grand_total', serverFallback: printConfig.restaurantTotalAmount)),
          PosColumn(text: _grandTotalText, width: 6, styles: _footerValue('grand_total', serverFallback: printConfig.restaurantTotalAmount)),
        ]);
      if (printType == 'swiggy_bill' ||
          (orderType == 'delivery' && printType != 'paid_bill')) {
        bytes += generator.hr(ch: '....');

        bytes += generator.text('Name: $deliveryCustName',
            styles: styleFunction(
                name: printConfig.deliveryAddress,
                isPaperSize80: paperRoll == 80));
        bytes += generator.text('Phone: $deliveryCustPhone',
            styles: styleFunction(
                name: printConfig.deliveryAddress,
                isPaperSize80: paperRoll == 80));
        bytes += generator.text('Address Type: $deliveryAddressType',
            styles: styleFunction(
                name: printConfig.deliveryAddress,
                isPaperSize80: paperRoll == 80));
        bytes += generator.text('Address: $deliveryCustAddress',
            styles: styleFunction(
                name: printConfig.deliveryAddress,
                isPaperSize80: paperRoll == 80));
        bytes += generator.text('Pincode: $deliveryCustPincode',
            styles: styleFunction(
                name: printConfig.deliveryAddress,
                isPaperSize80: paperRoll == 80));
        // bytes += generator.hr(ch: '....');
      }
      bytes += generator.hr(ch: '....');
      if ((printType == 'bill' || printType == 'billing') &&
          profileModel.restaurants!.first.upiId != null &&
          profileModel.restaurants!.first.upiId != '' &&
          GetPlatform.isAndroid) {
        const double qrSize = 170;
        try {
          final uiImg = await QrPainter(
            data: profileModel.restaurants!.first.dynamicUpiValue == 'No'
                ? 'upi://pay?pa=${profileModel.restaurants!.first.upiId}&pn=&am=0&tn='
                : 'upi://pay?pa=${profileModel.restaurants!.first.upiId}&pn=&am=${profileModel.restaurants!.first.isTotalRound == 'Yes' ? (getRoundUpValue( value: (grandTotal))) : (grandTotal).toStringAsFixed(2)}&tn=',
            version: QrVersions.auto,
            gapless: false,
          ).toImageData(qrSize);
          final dir = await getTemporaryDirectory();
          final pathName = '${dir.path}/qr_tmp.png';
          final qrFile = File(pathName);
          final imgFile =
              await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
          final img = prefix.decodeImage(imgFile.readAsBytesSync());

          bytes += generator.text(
            'Scan to pay',
            styles: styleFunction(
                name: printConfig.resturantScanToPay,
                isPaperSize80: paperRoll == 80),
          );

          bytes += generator.feed(1);
          bytes += generator.image(img!);
          bytes += generator.feed(1);

          // bytes += generator.feed(1);
        } catch (e) {
          print(e);
        }
      }

      if (profileModel.restaurants!.first.feedback == 'Yes' &&
          printType != 'swiggy_bill' &&
          GetPlatform.isAndroid) {
        try {
          const double qrSize = 170;
          final uiImg = await QrPainter(
            data: profileModel.restaurants?.first.feedbackUrl == ''
                ? '${AppConstants.FEEDBACK_BASE_URL}?orderId=$orderId'
                : '${profileModel.restaurants?.first.feedbackUrl ?? ''}',
            version: QrVersions.auto,
            gapless: false,
          ).toImageData(qrSize);
          final dir = await getTemporaryDirectory();
          final pathName = '${dir.path}/qr_tmp.png';
          final qrFile = File(pathName);
          final imgFile =
              await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
          final img = prefix.decodeImage(imgFile.readAsBytesSync());

          bytes += generator.text('Scan to provide feedback',
              styles: styleFunction(
                  name: printConfig.resturantScanToFeedback,
                  isPaperSize80: paperRoll == 80));

          bytes += generator.feed(1);
          bytes += generator.image(img!);
          bytes += generator.feed(1);
        } catch (e) {
          print(e);
        }
      }
      if (profileModel.termsCondition != null &&
          profileModel.termsCondition!.isNotEmpty) {
        bytes += generator.text(
          'Terms & Condition',
          styles: styleFunction(
              align: PosAlign.left,
              name: printConfig.poweredByMygenie,
              isPaperSize80: paperRoll == 80),
        );
        for (var i = 0; i < profileModel.termsCondition!.length; i++) {
          bytes += generator.text(
            '${profileModel.termsCondition?[i] ?? ''}',
            styles: styleFunction(
                align: PosAlign.left,
                name: printConfig.poweredByMygenie,
                isPaperSize80: paperRoll == 80),
          );
        }
      }
      if (profileModel.restaurants!.first.footerTextBill != '') {
        bytes += generator.text(
          profileModel.restaurants!.first.footerTextBill!,
          styles: styleFunction(
              name: printConfig.poweredByMygenie,
              isPaperSize80: paperRoll == 80),
        );
      }
    }
    if (_isVisible('powered_by'))
      bytes += generator.text(
        'Powered by MyGenie',
        styles: _localStyle('powered_by',
            serverFallback: printConfig.poweredByMygenie,
            fallbackAlign: PosAlign.center),
      );
    bytes += generator.cut();
    bytes += generator.beep(n: 3, duration: PosBeepDuration.beep200ms);

    return bytes;
  }

  int getOrderTypeValue(String field,
      {bool isShowDate = false,
      bool printerSize80mm = false,
      bool isHideSl = false}) {
    switch (field) {
      case 'sl':
        return 1;
      case 'name':
        return printerSize80mm && isShowDate
            ? isHideSl
                ? 5
                : 4
            : isHideSl
                ? 6
                : 5;
      case 'qty':
        return 1;
      case 'price':
        return 2;
      case 'total':
        return printerSize80mm && isShowDate ? 2 : 3;
      case 'date':
        return 2;
      default:
        return 2;
    }
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

  PosStyles styleFunction(
      {String? name,
      bool isPaperSize80 = false,
      bool isUnderline = false,
      PosAlign align = PosAlign.center}) {
    return PosStyles(
      align: align,
      underline: isUnderline,
      fontType: isPaperSize80 ? PosFontType.fontA : PosFontType.fontB,
      bold: name!.split(',').last == 'true',
      height: fonstSize(name.split(',').first),
      width: fonstSize(name.split(',')[1]),
    );
  }
}

String formatQuantity(num? value) {
  return (value ?? 0)
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'\.?0+$'), '');
}