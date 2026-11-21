import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_manually_print_detail_response.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller/auth_controller.dart';
import '../data/model/response/cart_model.dart';
import '../data/model/response/get_collect_bill_resoonse_model.dart';
import '../data/model/response/get_paid_order_detail_response.dart';
import '../data/model/response/get_waiter_order_list_response.dart';
import '../data/model/response/profile_model.dart';
import 'package:pdf/pdf.dart';
import '../helper/price_converter.dart';
import 'app_constants.dart';
import '../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../../data/model/response/get_station_order_list_response.dart'
    as station;

class WindowsPrintByteConvert {
  Future<Uint8List> byteConvert({
    bool isShowDate = false,
    int? paperRoll,
    List<OrderDetails>? kotOrderList,
    List<OrderDetailsBar>? billFoodList,
    List<station.OrderDetailsFood>? stationOrderList,
    List<OrderDetailsFood>? paidFoodList,
    List<OrderFoodDetails>? swiggyOrderList,
    List<CartModel>? cartList,
    String? orderId,
    String paymentType = '',
    String tokenNo = '',
    String? printType,
    String? orderType,
    String? waiterName,
    String? stationName,
    String? date,
    String? custName,
    String? custPhone,
    String? custGST,
    String? custGSTName,
    String? deliveryCustPhone,
    String? deliveryCustName,
    String? deliveryCustAddress,
    String? deliveryCustPincode,
    String? deliveryAddressType,
    String? tablename,
    String? paymentUrl,
    String? orderNote,
    String brandName = '',
    String printTitle = '',
    double? orderSubTotal,
    double? gstAmount,
    double swiggyTax = 0,
    double? vatAmount,
    double serviceChargeAmount = 0,
    double? discount,
    double tips = 0,
    double charge = 0,
    double roomGst = 0,
    double subTotalWithoutTax = 0,
    double roomRemainingPay = 0,
    double roomAdvancePay = 0,
    double couponDiscount = 0,
    double loyaltyUsed = 0,
    double walletUsed = 0,
    double? grandTotal,
    String? gstName,
    String? printEditOrderCount = '',
    String? couponCode = '',
    double? gstNo,
    double deliveryCharge = 0,
    double? paymentAmount,
    String? rType,
    String? paymentStatus,
    double? packingCharge = 0,
    List<AssociatedOrder> associatedOrders = const [],
  }) async {
    ProfileModel? profileModel = Get.find<AuthController>().profileModel;
    PrintConfigModel? printConfig = profileModel?.windowsPrintConfigList?.first;
    bool isShowDate =
        profileModel?.restaurants?.first.showFoodDate == 'Yes' ? true : false;
    Uint8List? feedbackQr;
    if (printType == 'bill' || printType == 'paid_bill')
      feedbackQr = await generateQrCode(
          profileModel?.restaurants?.first.feedbackUrl == ''
              ? '${AppConstants.FEEDBACK_BASE_URL}?orderId=$orderId'
              : '${profileModel?.restaurants?.first.feedbackUrl ?? ''}');
    Uint8List? paymentQr;

    if ((printType == 'bill' ||
            printType == 'paid_bill' ||
            printType == 'billing') &&
        profileModel?.restaurants?.first.upiId != '')
      paymentQr = await generateQrCode(
        profileModel?.restaurants?.first.dynamicUpiValue == 'No'
            ? 'upi://pay?pa=${profileModel?.restaurants?.first.upiId}&pn=&am=0&tn='
            : 'upi://pay?pa=${profileModel?.restaurants?.first.upiId}&pn=&am=${profileModel?.restaurants?.first.isTotalRound == 'Yes' ? getRoundUpValue(value: (grandTotal!)) : (grandTotal!).toStringAsFixed(2)}&tn=',
      );
    var netImage;
    if (profileModel?.restaurants?.first.logoPath != '' &&
        printType != 'swiggy_kot' &&
        (printType == 'bill' ||
            printType == 'paid_bill' ||
            printType == 'billing'))
      netImage =
          await networkImage(profileModel?.restaurants?.first.logoPath ?? '');
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    var font;
    if (profileModel?.restaurants?.first.settings?.language?.toLowerCase() ==
        'English'.toLowerCase()) {
      font = await PdfGoogleFonts.poppinsMedium();
    } else if (profileModel?.restaurants?.first.settings?.language
            ?.toLowerCase() ==
        'Gujarati'.toLowerCase()) {
      font = await PdfGoogleFonts.notoSansGujaratiMedium();
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          profileModel?.billPrinterPaperRoll == 58
              ? 48 * PdfPageFormat.mm
              : (printConfig?.paperWidth)! *
                  PdfPageFormat.mm, //for 80 mm printer
          850,
          marginLeft: printConfig!.margin!,
          marginRight: 0,
          marginBottom: 0,
          marginTop: 0,
        ),
        build: (context) {
          return [
            pw.Padding(
                padding: pw.EdgeInsets.only(left: printConfig.padding!),
                child: pw.Column(
                  children: [
                    if (printType == 'swiggy_kot' && brandName != '')
                      pw.Center(
                        child: pw.Text('$brandName',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.restaurantTitle)),
                      ),

                    if (printType == 'bill' ||
                        printType == 'swiggy_bill' ||
                        printType == 'billing' ||
                        printType == 'paid_bill' ||
                        profileModel?.restaurants?.first.isShowAddressKot ==
                            'Yes')
                      pw.Column(children: [
                        if (netImage != null) pw.Image(netImage, width: 70),
                        pw.Center(
                          child: pw.Text(
                              (brandName != '' && printType == 'swiggy_bill')
                                  ? ('$brandName')
                                  : (profileModel?.restaurants?.first.name ??
                                      ''),
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.restaurantTitle)),
                        ),
                        pw.Center(
                          child: pw.Text(
                              profileModel?.restaurants?.first.address ?? '',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.restaurantAddress1),
                              textAlign: pw.TextAlign.center),
                        ),
                        if (profileModel!.restaurants!.first.phone != null &&
                            profileModel.restaurants!.first.phone != '')
                          pw.Center(
                            child: pw.Text(
                                profileModel.restaurants?.first.phone ?? '',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.restaurantAddress1),
                                textAlign: pw.TextAlign.center),
                          ),
                        if (profileModel?.restaurants?[0].gstCode != '')
                          pw.Text(
                              'GST no. ${profileModel?.restaurants?.first.gstCode}',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.restaurantGstno)),
                        if (profileModel?.restaurants?[0].fssai != '')
                          pw.Text(
                              'FSI no. ${profileModel?.restaurants?.first.fssai}',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.restaurantFssaiNo)),
                      ]),

// ////////////////   ORDER DETAIL    /////////////////

                    pw.Row(children: [
                      pw.Expanded(
                          child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                            (printType == 'bill' ||
                                    printType == 'paid_bill' ||
                                    printType == 'swiggy_bill' ||
                                    printType == 'billing')
                                ? 'Bill No. ${orderId}'
                                : 'Order ID. ${orderId}',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.resturantOrderId)),
                      )),
                      if (orderType != 'delivery' &&
                          orderType != 'take_away' &&
                          printType != 'swiggy_kot')
                        pw.SizedBox(width: 5),
                      if (orderType != 'delivery' &&
                          orderType != 'take_away' &&
                          printType != 'swiggy_kot')
                        pw.Expanded(
                            child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text('${waiterName}',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.billerName)),
                        )),
                      pw.SizedBox(width: 5),
                      pw.Expanded(
                          child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(date ?? '',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.dateTime)),
                      ))
                    ]),

                    if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .settings!
                                .useDisplayToken ==
                            'Yes' &&
                        tokenNo != '')
                      pw.Center(
                        child: pw.Text('T-$tokenNo',
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            )),
                      ),

                    if (printType == 'kot' || printType == 'swiggy_kot')
                      pw.Text(stationName ?? '',
                          style: styleFunction(font,
                              isPaperSize80: paperRoll == 80,
                              name: printConfig.stationName)),
                    if ((printType == 'kot' || printType == 'swiggy_kot') &&
                        printTitle != '')
                      pw.Text(printTitle,
                          style: styleFunction(font,
                              isPaperSize80: paperRoll == 80,
                              name: printConfig.stationName)),
                    pw.Row(children: [
                      pw.Expanded(
                          child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(custName ?? '',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.customerName)),
                      )),
                      pw.SizedBox(width: 5),
                      pw.Expanded(
                        child: pw.Center(
                          child: pw.Text(tablename ?? '',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.resturantTable)),
                        ),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Expanded(
                          child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(custPhone ?? '',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.customerNumber)),
                      ))
                    ]),
                    if (gstName != null && gstNo != null)
                      pw.Column(children: [
                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(gstName ?? '',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.customerName)),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(gstNo.toString() ?? '',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.customerNumber)),
                        )
                      ]),
                    if (custGSTName != null && custGSTName != '')
                      pw.SizedBox(height: 2),
                    if (custGSTName != null && custGSTName != '')
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text('GST Name : $custGSTName',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.customerName)),
                      ),
                    if (custGST != null && custGST != '')
                      pw.SizedBox(height: 2),
                    if (custGST != null && custGST != '')
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text('GST No : $custGST',
                            style: styleFunction(font,
                                isPaperSize80: paperRoll == 80,
                                name: printConfig.customerName)),
                      ),

                    pw.Divider(height: 0),

// //////////////////   FOOD DETAIL   ///////////////////
// //////////////////   BILL FOOD DETAIL   ///////////////////

                    if (printType == 'bill' ||
                        printType == 'paid_bill' ||
                        printType == 'swiggy_bill' ||
                        printType == 'billing')
                      pw.Row(children: [
                        // pw.Expanded(
                        //     flex: 1,
                        //     child: pw.Align(
                        //       alignment: pw.Alignment.centerLeft,
                        //       child: pw.Text('SL',
                        //           style: styleFunction(font,
                        //               isPaperSize80: paperRoll == 80,
                        //               name:
                        //                   printConfig.resturantFoodListHeader)),
                        //     )),
                        // pw.SizedBox(width: 2),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('Items',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                        pw.SizedBox(width: 2),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('qty'.tr,
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                        pw.SizedBox(width: 2),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('Price',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                        if (printType != 'swiggy_bill') pw.SizedBox(width: 2),
                        if (printType != 'swiggy_bill')
                          pw.Expanded(
                              flex: 1,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text('Total',
                                    style: styleFunction(font,
                                        isPaperSize80: paperRoll == 80,
                                        name: printConfig
                                            .resturantFoodListHeader)),
                              )),
                        if (isShowDate &&
                            paperRoll == 80 &&
                            printType != 'swiggy_bill')
                          pw.SizedBox(width: 2),
                        if (isShowDate &&
                            paperRoll == 80 &&
                            printType != 'swiggy_bill')
                          pw.Expanded(
                              flex: 1,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text('Date',
                                    style: styleFunction(font,
                                        isPaperSize80: paperRoll == 80,
                                        name: printConfig
                                            .resturantFoodListHeader)),
                              ))
                      ]),

                    if (printType == 'kot' || printType == 'swiggy_kot')
                      pw.Row(children: [
                        pw.Expanded(
                            flex: 1,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('SL',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                        pw.SizedBox(width: 3),
                        pw.Expanded(
                            flex: 4,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('item_info'.tr,
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                        pw.SizedBox(width: 3),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('qty'.tr,
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name:
                                          printConfig.resturantFoodListHeader)),
                            )),
                      ]),
                    pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 1),
                        child: buildDottedLine(180)),
                    if (printType == 'bill')
                      ...List.generate(billFoodList?.length ?? 0, (index) {
                        OrderDetailsBar food = billFoodList![index];
                        String variationText = '';
                        String addons = '';
                        double halfVariationPrice = 0;

                        double variationTotal = 0;
                        double addonsTotal = 0;
                        double variationBasePrice = 0;
                        double addonBasePrice = 0;
                        if (food.variation != null &&
                            food.variation!.isNotEmpty) {
                          variationText += '(';
                          List<String> labelList = [];
                          for (int j = 0; j < food.variation!.length; j++) {
                            // variationText +=
                            //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

                            if (food.variation![j].values != null) {
                              for (var element in food.variation![j].values!) {
                                labelList.add(element.level!);
                                // baseVariation += double.parse(element.optionPrice);
                                // variationTotal +=
                                //     (int.parse(element.optionPrice) * food.quantity);
                                if (food.variation![j].name!.toUpperCase() ==
                                    'HALFNHALF') {
                                  if (halfVariationPrice <
                                      double.parse(element.optionPrice!) *
                                          food.quantity!) {
                                    variationBasePrice =
                                        double.parse(element.optionPrice!);
                                    halfVariationPrice =
                                        double.parse(element.optionPrice!) *
                                            food.quantity!;
                                  }
                                } else {
                                  variationBasePrice = variationBasePrice +
                                      double.parse(element.optionPrice!);

                                  variationTotal = variationTotal +
                                      double.parse(element.optionPrice!) *
                                          food.quantity!;
                                }
                              }
                              // variationText +=
                              //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                            }

                            variationTotal =
                                variationTotal + halfVariationPrice;
                            // variationText += ')';
                          }
                          variationText += '${labelList.join(',')}';
                          variationText += ')';
                        }

                        for (var i = 0; i < food.addOns!.length; i++) {
                          final addOnQty = food.addOns![i].quantity ?? 0;
                          final foodQty = food.quantity ?? 0;
                          final totalAddOnQty = addOnQty * foodQty;
                          // addons +=
                          //     '${food.addOns![i].name} (${food.addOns![i].quantity})';
                          addons += '${food.addOns![i].name} ($totalAddOnQty)';
                          addonBasePrice = addonBasePrice +
                              (food.addOns![i].price! *
                                  food.addOns![i].quantity!);
                          addonsTotal = addonsTotal +
                              ((food.addOns![i].price! *
                                      food.addOns![i].quantity!) *
                                  food.quantity!);
                        }

                        return pw.Column(children: [
                          pw.Row(children: [
                            // pw.Expanded(
                            //     flex: 1,
                            //     child: pw.Align(
                            //       alignment: pw.Alignment.centerLeft,
                            //       child: pw.Text('${index + 1}.',
                            //           style: styleFunction(font,
                            //               isUnderLine: food.foodStatus == 3,
                            //               isPaperSize80: paperRoll == 80,
                            //               name:
                            //                   printConfig.restaurantFoodList)),
                            //     )),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      '${food.foodDetails!['name']} $variationText',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          isUnderLine: food.foodStatus == 3,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    // '${food.quantity}',
                                    formatQuantity(food.quantity),
                                      style: styleFunction(font,
                                          isUnderLine: food.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.SizedBox(width: 2),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      food.isComplementary != null &&
                                              food.isComplementary!
                                          ? '0'
                                          : ((food.foodDetails!['name']
                                                      .toString()
                                                      .toUpperCase() ==
                                                  'CHECK IN')
                                              ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                                              : '${(food.unitPrice! + variationBasePrice).toInt()}'),
                                      style: styleFunction(font,
                                          isUnderLine: food.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.SizedBox(width: 2),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      food.isComplementary != null &&
                                              food.isComplementary!
                                          ? '0'
                                          : ((food.foodDetails!['name']
                                                      .toString()
                                                      .toUpperCase() ==
                                                  'CHECK IN')
                                              ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                                              : '${((food.unitPrice! * food.quantity!) + variationTotal).toInt()}'),
                                      style: styleFunction(font,
                                          isUnderLine: food.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            if (isShowDate && paperRoll == 80)
                              pw.SizedBox(width: 2),
                            if (isShowDate && paperRoll == 80)
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                        '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt!))}',
                                        style: styleFunction(font,
                                            isUnderLine: food.foodStatus == 3,
                                            isPaperSize80: paperRoll == 80,
                                            name: printConfig
                                                .restaurantFoodList)),
                                  ))
                          ]),
                          if (addons != '' && addonsTotal != 0)
                            pw.Column(children: [
                              // pw.Padding(
                              //   padding: pw.EdgeInsets.symmetric(vertical: 1),
                              //   child: buildDottedLine(180),
                              // ),
                              pw.Row(children: [
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Center(
                                //       child: pw.Text('',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name: printConfig
                                //                   .restaurantFoodList)),
                                //     )),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('$addons',
                                          style: styleFunction(font,
                                              isUnderLine: food.foodStatus == 3,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          food.isComplementary != null &&
                                                  food.isComplementary!
                                              ? '0'
                                              : '${addonBasePrice.toInt()}',
                                          style: styleFunction(font,
                                              isUnderLine: food.foodStatus == 3,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          food.isComplementary != null &&
                                                  food.isComplementary!
                                              ? '0'
                                              : '${addonsTotal.toInt()}',
                                          style: styleFunction(font,
                                              isUnderLine: food.foodStatus == 3,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                if (isShowDate && paperRoll == 80)
                                  pw.SizedBox(width: 2),
                                if (isShowDate && paperRoll == 80)
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Center(
                                        child: pw.Text('',
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      ))
                              ]),
                            ]),
                          if (orderNote != '' &&
                              food.foodDetails!['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains('out of'))
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Center(
                                //       child: pw.Text('',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name: printConfig
                                //                   .restaurantFoodList)),
                                //     )),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('Notes  :${orderNote}',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                        ]);
                      }),
                    if (printType == 'swiggy_bill')
                      ...List.generate(swiggyOrderList?.length ?? 0, (index) {
                        OrderFoodDetails food = swiggyOrderList![index];
                        String variationText = '';
                        String addons = '';
                        String? addonGroupTitle;
                        String? variationGroupTitle;

                        double variationTotal = 0;
                        double baseVariation = 0;
                        double baseAddon = 0;
                        double addonsTotal = 0;
                        swiggyTax = swiggyTax + food.taxAmount;
                        // if (food.variation.isNotEmpty) {
                        //   variationText += '(';
                        //   List<String> labelList = [];
                        //   for (int j = 0; j < food.variation.length; j++) {
                        //     // variationText +=
                        //     //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

                        //     if (food.variation[j].values != null) {
                        //       for (var element in food.variation[j].values!) {
                        //         labelList.add(element.level!);
                        //         baseVariation +=
                        //             double.parse(element.optionPrice!);
                        //         variationTotal +=
                        //             (int.parse(element.optionPrice!) *
                        //                 food.quantity);
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
                        //   addons +=
                        //       '${food.addOns[i].name} (${food.addOns[i].qty})';
                        //   baseAddon = baseAddon +
                        //       food.addOns[i].price! * food.addOns[i].qty!;
                        //   addonsTotal = addonsTotal +
                        //       (food.addOns[i].price! * food.addOns[i].qty!);
                        // }
                        for (var addon in food.addOns) {
                          if (addon.group != null) {
                            if (addon.group!.isVariant == true) {
                              // 🔹 Handle Variation
                              variationGroupTitle ??= addon.group!.title ?? '';
                              variationText +=
                                  "${addon.title}(${addon.quantity ?? 0}), ";
                            } else {
                              // 🔹 Handle Add-on
                              addonGroupTitle ??= addon.group!.title ?? '';
                              addons +=
                                  "${addon.title}(${addon.quantity ?? 0}), ";
                            }
                          }
                        }
                        if (addons.isNotEmpty) {
                          addons =
                              "${addons.trim().replaceAll(RegExp(r',$'), '')}";
                          // addonText =
                          //     "$addonGroupTitle (${addonText.trim().replaceAll(RegExp(r',$'), '')})";
                        }
                        if (variationText.isNotEmpty) {
                          variationText =
                              "${variationText.trim().replaceAll(RegExp(r',$'), '')}";
                          // variationText =
                          //     "$variationGroupTitle (${variationText.trim().replaceAll(RegExp(r',$'), '')})";
                        }
                        return pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(children: [
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Align(
                                //       alignment: pw.Alignment.centerLeft,
                                //       child: pw.Text('${index + 1}.',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name: printConfig
                                //                   .restaurantFoodList)),
                                //     )),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          '${food.title} $variationText',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                        // '${food.quantity}',
                                        formatQuantity(food.quantity),
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          '${(food.price).toStringAsFixed(2)}',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                // pw.SizedBox(width: 2),
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Align(
                                //       alignment: pw.Alignment.centerLeft,
                                //       child: pw.Text(
                                //           '${(food.price + variationTotal).toStringAsFixed(2)}',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name:
                                //                   printConfig.restaurantFoodList)),
                                //     )),
                                // if (isShowDate && paperRoll == 80)
                                //   pw.SizedBox(width: 2),
                                // if (isShowDate && paperRoll == 80)
                                //   pw.Expanded(
                                //       flex: 1,
                                //       child: pw.Align(
                                //         alignment: pw.Alignment.centerLeft,
                                //         child: pw.Text(
                                //             '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
                                //             style: styleFunction(font,
                                //                 isPaperSize80: paperRoll == 80,
                                //                 name: printConfig
                                //                     .restaurantFoodList)),
                                //       ))
                              ]),
                              if (addons != '')
                                pw.Column(children: [
                                  pw.Padding(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 1),
                                    child: buildDottedLine(180),
                                  ),
                                  pw.Row(children: [
                                    // pw.Expanded(
                                    //     flex: 1,
                                    //     child: pw.Center(
                                    //       child: pw.Text('',
                                    //           style: styleFunction(font,
                                    //               isPaperSize80:
                                    //                   paperRoll == 80,
                                    //               name: printConfig
                                    //                   .restaurantFoodList)),
                                    //     )),
                                    pw.Expanded(
                                        flex: 2,
                                        child: pw.Align(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text('$addons',
                                              style: styleFunction(font,
                                                  isPaperSize80:
                                                      paperRoll == 80,
                                                  name: printConfig
                                                      .restaurantFoodList)),
                                        )),
                                    pw.Expanded(
                                        flex: 1,
                                        child: pw.Center(
                                          child: pw.Text('',
                                              style: styleFunction(font,
                                                  isPaperSize80:
                                                      paperRoll == 80,
                                                  name: printConfig
                                                      .restaurantFoodList)),
                                        )),
                                    pw.SizedBox(width: 2),
                                    // pw.Expanded(
                                    //     flex: 1,
                                    //     child: pw.Align(
                                    //       alignment: pw.Alignment.centerLeft,
                                    //       child: pw.Text(
                                    //           '${baseAddon.toStringAsFixed(2)}',
                                    //           style: styleFunction(font,
                                    //               isPaperSize80: paperRoll == 80,
                                    //               name: printConfig
                                    //                   .restaurantFoodList)),
                                    //     )),
                                    // pw.SizedBox(width: 2),
                                    pw.Expanded(
                                        flex: 1,
                                        child: pw.Align(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text('',
                                              style: styleFunction(font,
                                                  isPaperSize80:
                                                      paperRoll == 80,
                                                  name: printConfig
                                                      .restaurantFoodList)),
                                        )),
                                    // if (isShowDate && paperRoll == 80)
                                    //   pw.SizedBox(width: 2),
                                    // if (isShowDate && paperRoll == 80)
                                    //   pw.Expanded(
                                    //       flex: 1,
                                    //       child: pw.Center(
                                    //         child: pw.Text('',
                                    //             style: styleFunction(font,
                                    //                 isPaperSize80: paperRoll == 80,
                                    //                 name: printConfig
                                    //                     .restaurantFoodList)),
                                    //       ))
                                  ]),
                                ]),
                              if (food.foodLevelNotes != '')
                                pw.Column(children: [
                                  pw.Padding(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 1),
                                    child: buildDottedLine(180),
                                  ),
                                  pw.Row(children: [
                                    // pw.Expanded(
                                    //     flex: 1,
                                    //     child: pw.Center(
                                    //       child: pw.Text('',
                                    //           style: styleFunction(font,
                                    //               isPaperSize80:
                                    //                   paperRoll == 80,
                                    //               name: printConfig
                                    //                   .restaurantFoodList)),
                                    //     )),
                                    pw.Expanded(
                                        flex: 2,
                                        child: pw.Align(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text(
                                              'Notes  :${food.foodLevelNotes}',
                                              style: styleFunction(font,
                                                  isPaperSize80:
                                                      paperRoll == 80,
                                                  name: printConfig
                                                      .restaurantFoodList)),
                                        )),
                                  ]),
                                ]),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                            ]);
                      }),

                    if (printType == 'paid_bill')
                      ...List.generate(paidFoodList!.length, (index) {
                        print('paid bill');
                        OrderDetailsFood food = paidFoodList[index];
                        String variationText = '';
                        String addons = '';

                        double variationTotal = 0;
                        double baseVariation = 0;
                        // double baseAddon = 0;
                        double addonsTotal = 0;
                        double halfVariationPrice = 0;

                        if (food.variation != null &&
                            food.variation!.isNotEmpty) {
                          variationText += '(';
                          List<String> labelList = [];
                          for (int j = 0; j < food.variation!.length; j++) {
                            // variationText +=
                            //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

                            if (food.variation![j].values != null) {
                              for (var element in food.variation![j].values!) {
                                labelList.add(element.label!);
                                // baseVariation += double.parse(element.optionPrice);
                                // variationTotal +=
                                //     (int.parse(element.optionPrice) * food.quantity);
                                if (food.variation![j].name!.toUpperCase() ==
                                    'HALFNHALF') {
                                  if (halfVariationPrice <
                                      double.parse(element.optionPrice!) *
                                          food.quantity!) {
                                    baseVariation =
                                        double.parse(element.optionPrice!);
                                    halfVariationPrice =
                                        double.parse(element.optionPrice!) *
                                            food.quantity!;
                                  }
                                } else {
                                  baseVariation =
                                      double.parse(element.optionPrice!);

                                  variationTotal = variationTotal +
                                      double.parse(element.optionPrice!) *
                                          food.quantity!;
                                }
                              }
                              // variationText +=
                              //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                            }
                            variationTotal =
                                variationTotal + halfVariationPrice;

                            // variationText += ')';
                          }
                          variationText += '${labelList.join(',')}';
                          variationText += ')';
                        }

                        for (var i = 0; i < food.addOns!.length; i++) {
                          addons +=
                              '${food.addOns![i].name} (${food.addOns![i].quantity})';
                          // baseAddon = baseAddon +
                          //     food.addOns![i].price! *
                          //         food.addOns![i].quantity!;
                          addonsTotal = addonsTotal +
                              (food.addOns![i].price! *
                                  food.addOns![i].quantity!);
                        }

                        return food.foodStatus == 3
                            ? pw.SizedBox.shrink()
                            : pw.Column(children: [
                                pw.Row(children: [
                                  // pw.Expanded(
                                  //     flex: 1,
                                  //     child: pw.Align(
                                  //       alignment: pw.Alignment.centerLeft,
                                  //       child: pw.Text('${index + 1}.',
                                  //           style: styleFunction(font,
                                  //               isPaperSize80: paperRoll == 80,
                                  //               name: printConfig
                                  //                   .restaurantFoodList)),
                                  //     )),
                                  pw.Expanded(
                                      flex: 2,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                            '${food.foodDetails!.name} $variationText',
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                          // '${food.quantity}',
                                          formatQuantity(food.quantity),
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  pw.SizedBox(width: 2),
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                            food.isComplementary == 1
                                                ? '0'
                                                : ((food.foodDetails!.name!
                                                            .toUpperCase() ==
                                                        'CHECK IN')
                                                    ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                                                    : '${(food.unitPrice! + baseVariation).toInt()}'),
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  pw.SizedBox(width: 2),
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                            food.isComplementary == 1
                                                ? '0'
                                                : ((food.foodDetails!.name!
                                                            .toUpperCase() ==
                                                        'CHECK IN')
                                                    ? '${((roomAdvancePay + roomRemainingPay).toInt())}'
                                                    : '${((food.unitPrice! * food.quantity!) + variationTotal).toInt()}'),
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  if (isShowDate && paperRoll == 80)
                                    pw.SizedBox(width: 3),
                                  if (isShowDate && paperRoll == 80)
                                    pw.Expanded(
                                        flex: 1,
                                        child: pw.Align(
                                          alignment: pw.Alignment.centerLeft,
                                          child: pw.Text(
                                              '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt!))}',
                                              style: styleFunction(font,
                                                  isPaperSize80:
                                                      paperRoll == 80,
                                                  name: printConfig
                                                      .restaurantFoodList)),
                                        ))
                                ]),
                                if (addons != '' && addonsTotal != 0)
                                  pw.Column(children: [
                                    // pw.Padding(
                                    //   padding:
                                    //       pw.EdgeInsets.symmetric(vertical: 1),
                                    //   child: buildDottedLine(180),
                                    // ),
                                    pw.Row(children: [
                                      // pw.Expanded(
                                      //     flex: 1,
                                      //     child: pw.Center(
                                      //       child: pw.Text('',
                                      //           style: styleFunction(font,
                                      //               isPaperSize80:
                                      //                   paperRoll == 80,
                                      //               name: printConfig
                                      //                   .restaurantFoodList)),
                                      //     )),
                                      pw.Expanded(
                                          flex: 2,
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerLeft,
                                            child: pw.Text('$addons',
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                          )),
                                      pw.Expanded(
                                          flex: 1,
                                          child: pw.Center(
                                            child: pw.Text('',
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                          )),
                                      pw.SizedBox(width: 2),
                                      pw.Expanded(
                                          flex: 1,
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerLeft,
                                            child: pw.Text(
                                                food.isComplementary == 1
                                                    ? '0'
                                                    : '${addonsTotal.toInt()}',
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                          )),
                                      pw.SizedBox(width: 2),
                                      pw.Expanded(
                                          flex: 1,
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerLeft,
                                            child: pw.Text(
                                                food.isComplementary == 1
                                                    ? '0'
                                                    : '${(addonsTotal * food.quantity!).toInt()}',
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                          )),
                                      if (isShowDate && paperRoll == 80)
                                        pw.SizedBox(width: 3),
                                      if (isShowDate && paperRoll == 80)
                                        pw.Expanded(
                                            flex: 1,
                                            child: pw.Center(
                                              child: pw.Text('',
                                                  style: styleFunction(font,
                                                      isPaperSize80:
                                                          paperRoll == 80,
                                                      name: printConfig
                                                          .restaurantFoodList)),
                                            ))
                                    ]),
                                  ]),
                                if (orderNote != null &&
                                    orderNote != '' &&
                                    food.foodDetails!.name
                                        .toString()
                                        .toLowerCase()
                                        .contains('out of'))
                                  pw.Column(children: [
                                    pw.Padding(
                                      padding:
                                          pw.EdgeInsets.symmetric(vertical: 1),
                                      child: buildDottedLine(180),
                                    ),
                                    pw.Row(children: [
                                      // pw.Expanded(
                                      //     flex: 1,
                                      //     child: pw.Center(
                                      //       child: pw.Text('',
                                      //           style: styleFunction(font,
                                      //               isPaperSize80:
                                      //                   paperRoll == 80,
                                      //               name: printConfig
                                      //                   .restaurantFoodList)),
                                      //     )),
                                      pw.Expanded(
                                          flex: 2,
                                          child: pw.Align(
                                            alignment: pw.Alignment.centerLeft,
                                            child: pw.Text(
                                                'Notes  :${orderNote}',
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                          )),
                                    ]),
                                  ]),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(vertical: 1),
                                  child: buildDottedLine(180),
                                ),
                              ]);
                      }),

                    if (printType == 'billing')
                      ...List.generate(cartList!.length, (index) {
                        CartModel food = cartList[index];
                        String variationText = '';
                        String addons = '';

                        double variationTotal = 0;
                        double addonsTotal = 0;
                        double variationBasePrice = 0;
                        // double addonBasePrice = 0;
                        int index0 = 0;
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
                        //     addonBasePrice = addonsTotal =
                        //         addonsTotal + (addOn.price! * qtys[index0]);
                        //     addonBasePrice = (addOn.price! * qtys[index0]);
                        //     index0 = index0 + 1;
                        //   }
                        // }
                        if (food!.addOns != null) {
                          for (var addOn in food.addOnIds) {
                            if (addOn != null && addOn.quantity != 0) {
                              addons =
                                  '$addons${(index0 == 0) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
                              addonsTotal = addonsTotal +
                                  ((addOn.price ?? 0) * (addOn.quantity ?? 0));
                              // baseAddon = (addOn.price ?? 0) * (addOn.quantity ?? 0);
                              index0 = index0 + 1;
                            }
                          }
                        }
                        if (food.variation.isNotEmpty) {
                          variationText += '(';
                          List<String> labelList = [];
                          for (int index = 0;
                              index < food.variation.length;
                              index++) {
                            if (food.variation[index].isNotEmpty &&
                                food.variation[index].contains(true)) {
                              // variationText +=
                              //     '${variationText.isNotEmpty ? ', ' : ''}${food.product.variations[index].name} (';

                              for (int i = 0;
                                  i < food.variation[index].length;
                                  i++) {
                                if (food.variation[index][i]) {
                                  variationTotal += double.parse(food
                                          .product
                                          .variations![index]
                                          .values![i]
                                          .optionPrice!) *
                                      food.quantity;
                                  variationBasePrice = variationBasePrice +
                                      double.parse(food
                                          .product
                                          .variations![index]
                                          .values![i]
                                          .optionPrice!);
                                  labelList.add(food.product.variations![index]
                                      .values![i].level!);
                                  // print(variationTotal);
                                  // variationText +=
                                  //     '${variationText.endsWith('(') ? '' : ', '}${food.product.variations[index].values[i].level}';
                                }
                              }
                              // variationText += ')';
                            }
                          }
                          variationText += '${labelList.join(',')}';
                          variationText += ')';
                        }
                        double foodbasePrice = ((food.discountedPrice) +
                            (Get.find<TableController>().selectedTable == null
                                ? 0
                                : Get.find<TableController>()
                                            .selectedTable!
                                            .tableNo ==
                                        'Take Away'
                                    ? (food.product.takeAwayFoodPrice!)
                                    : Get.find<TableController>()
                                                .selectedTable!
                                                .tableNo ==
                                            'Delivery'
                                        ? (food.product.deliveryFoodPrice!)
                                        : 0));
                        return pw.Column(children: [
                          pw.Row(children: [
                            // pw.Expanded(
                            //     flex: 1,
                            //     child: pw.Align(
                            //       alignment: pw.Alignment.centerLeft,
                            //       child: pw.Text('${index + 1}.',
                            //           style: styleFunction(font,
                            //               isPaperSize80: paperRoll == 80,
                            //               name:
                            //                   printConfig.restaurantFoodList)),
                            //     )),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      '${food.product.name} $variationText',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    // '${food.quantity}',
                                    formatQuantity(food.quantity),
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.SizedBox(width: 2),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      food.isComplementry
                                          ? '0'
                                          : '${(foodbasePrice - addonsTotal).toInt()}',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.SizedBox(width: 2),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      food.isComplementry
                                          ? '0'
                                          : '${((foodbasePrice * food.quantity) - (addonsTotal * food.quantity)).toInt()}',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            if (isShowDate && paperRoll == 80)
                              pw.SizedBox(width: 2),
                            if (isShowDate && paperRoll == 80)
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                        '${DateFormat('dd-MMM').format(DateTime.now())}',
                                        style: styleFunction(font,
                                            isPaperSize80: paperRoll == 80,
                                            name: printConfig
                                                .restaurantFoodList)),
                                  ))
                          ]),
                          if (addons != '' && addonsTotal != 0)
                            pw.Column(children: [
                              // pw.Padding(
                              //   padding: pw.EdgeInsets.symmetric(vertical: 1),
                              //   child: buildDottedLine(180),
                              // ),
                              pw.Row(children: [
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Center(
                                //       child: pw.Text('',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name: printConfig
                                //                   .restaurantFoodList)),
                                //     )),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('$addons',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          food.isComplementry
                                              ? '0'
                                              : '${addonsTotal.toInt()}',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          food.isComplementry
                                              ? '0'
                                              : '${(addonsTotal * food.quantity).toInt()}',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                if (isShowDate && paperRoll == 80)
                                  pw.SizedBox(width: 2),
                                if (isShowDate && paperRoll == 80)
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Center(
                                        child: pw.Text('',
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      ))
                              ]),
                            ]),
                          if (orderNote != '' &&
                              food.product.name
                                  .toString()
                                  .toLowerCase()
                                  .contains('out of'))
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                // pw.Expanded(
                                //     flex: 1,
                                //     child: pw.Center(
                                //       child: pw.Text('',
                                //           style: styleFunction(font,
                                //               isPaperSize80: paperRoll == 80,
                                //               name: printConfig
                                //                   .restaurantFoodList)),
                                //     )),
                                pw.Expanded(
                                    flex: 2,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('Notes  :${orderNote}',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                        ]);
                      }),

                    if (printType == 'swiggy_kot')
                      ...List.generate(swiggyOrderList!.length, (i) {
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
                              variationText +=
                                  "${addon.title}(${addon.quantity ?? 0}), ";
                            } else {
                              // 🔹 Handle Add-on
                              addonGroupTitle ??= addon.group!.title ?? '';
                              addonText +=
                                  "${addon.title}(${addon.quantity ?? 0}), ";
                            }
                          }
                        }
                        if (addonText.isNotEmpty) {
                          addonText =
                              "${addonText.trim().replaceAll(RegExp(r',$'), '')}";
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
                        //     profileModel!.restaurants!.first.foodWithVariance ==
                        //         'Yes') {
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
                        //     profileModel!.restaurants!.first.foodWithVariance !=
                        //         'Yes') {
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
                        //   addons +=
                        //       '${cart.addOns[i].name} (${cart.addOns[i].qty})';
                        // }

                        return pw.Column(children: [
                          pw.Row(children: [
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text('${i + 1}.',
                                      style: styleFunction(font,
                                          isUnderLine: printTitle == 'Cancel KOT',
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 4,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      profileModel?.restaurants?.first
                                                  .foodWithVariance ==
                                              'Yes'
                                          ? '${cart.title} $variationText'
                                          : '${cart.title}',
                                      style: styleFunction(font,
                                          isUnderLine: printTitle == 'Cancel KOT',
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    // '${cart.quantity}',
                                    formatQuantity(cart.quantity),
                                      style: styleFunction(font,
                                          isUnderLine: printTitle == 'Cancel KOT',
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                          ]),
                          if (addonText != '')
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 4,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('$addonText',
                                          style: styleFunction(font,
                                              isUnderLine: printTitle == 'Cancel KOT',
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          if (variationText != '')
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 4,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          'Variants  :$variationText',
                                          style: styleFunction(font,
                                              isUnderLine: printTitle == 'Cancel KOT',
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          if (cart.foodLevelNotes != '')
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 4,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          'Notes  :${cart.foodLevelNotes}',
                                          style: styleFunction(font,
                                              isUnderLine: printTitle == 'Cancel KOT',
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                        ]);
                      }),
                    if (printType == 'kot')
                      ...List.generate(kotOrderList!.length, (i) {
                        OrderDetails cart = kotOrderList[i];
                        String variationText = '';
                        String addons = '';
                        if (cart.variation != null &&
                            cart.variation!.isNotEmpty) {
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
                          addons +=
                              '${cart.addOns![i].name} (${cart.addOns![i].qty})';
                        }

                        return pw.Column(children: [
                          pw.Row(children: [
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text('${i + 1}.',
                                      style: styleFunction(font,
                                          isUnderLine: cart.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 4,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                      '${cart.foodDetails!.name} $variationText',
                                      style: styleFunction(font,
                                          isUnderLine: cart.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                            pw.Expanded(
                                flex: 1,
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Text(
                                    // '${cart.quantity}',
                                    formatQuantity(cart.quantity),
                                      style: styleFunction(font,
                                          isUnderLine: cart.foodStatus == 3,
                                          isPaperSize80: paperRoll == 80,
                                          name:
                                              printConfig.restaurantFoodList)),
                                )),
                          ]),
                          if (cart.addOns != null && cart.addOns!.isNotEmpty)
                            ...List.generate(cart.addOns!.length, (i) {
                              return pw.Column(children: [
                                // if (i == 0)
                                //   pw.Padding(
                                //     padding:
                                //         pw.EdgeInsets.symmetric(vertical: 1),
                                //     child: buildDottedLine(180),
                                //   ),
                                pw.Row(children: [
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text('',
                                            style: styleFunction(font,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  pw.Expanded(
                                      flex: 4,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child: pw.Text(
                                            '${cart.addOns![i].name}',
                                            style: styleFunction(font,
                                                isUnderLine:
                                                    cart.foodStatus == 3,
                                                isPaperSize80: paperRoll == 80,
                                                name: printConfig
                                                    .restaurantFoodList)),
                                      )),
                                  pw.Expanded(
                                      flex: 1,
                                      child: pw.Align(
                                        alignment: pw.Alignment.centerLeft,
                                        child:
                                            // pw.Text('${cart.addOns![i].qty}',
                                            pw.Text(
                                                formatQuantity((cart.addOns![i].qty ?? 0) * (cart.quantity ?? 0)),
                                                style: styleFunction(font,
                                                    isPaperSize80:
                                                        paperRoll == 80,
                                                    name: printConfig
                                                        .restaurantFoodList)),
                                      )),
                                ]),
                              ]);
                            }),
                          // if (addons != '')
                          // pw.Column(children: [
                          //   pw.Padding(
                          //     padding: pw.EdgeInsets.symmetric(vertical: 1),
                          //     child: buildDottedLine(180),
                          //   ),
                          //   pw.Row(children: [
                          //     pw.Expanded(
                          //         flex: 1,
                          //         child: pw.Align(
                          //           alignment: pw.Alignment.centerLeft,
                          //           child: pw.Text('',
                          //               style: styleFunction(font,
                          //                   isPaperSize80: paperRoll == 80,
                          //                   name: printConfig
                          //                       .restaurantFoodList)),
                          //         )),
                          //     pw.Expanded(
                          //         flex: 4,
                          //         child: pw.Align(
                          //           alignment: pw.Alignment.centerLeft,
                          //           child: pw.Text('$addons',
                          //               style: styleFunction(font,
                          //                   isUnderLine: cart.foodStatus == 3,
                          //                   isPaperSize80: paperRoll == 80,
                          //                   name: printConfig
                          //                       .restaurantFoodList)),
                          //         )),
                          //     pw.Expanded(
                          //         flex: 1,
                          //         child: pw.Align(
                          //           alignment: pw.Alignment.centerLeft,
                          //           child: pw.Text('',
                          //               style: styleFunction(font,
                          //                   isPaperSize80: paperRoll == 80,
                          //                   name: printConfig
                          //                       .restaurantFoodList)),
                          //         )),
                          //   ]),
                          // ]),
                          if (orderNote!.isNotEmpty &&
                              cart.foodDetails?.name
                                      ?.toString()
                                      .toLowerCase()
                                      .contains('out of') ==
                                  true)
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 4,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text('Notes  :${orderNote}',
                                          style: styleFunction(font,
                                              isUnderLine: cart.foodStatus == 3,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          if (cart.foodLevelNotes != '')
                            pw.Column(children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180),
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                    flex: 1,
                                    child: pw.Center(
                                      child: pw.Text('',
                                          style: styleFunction(font,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                                pw.Expanded(
                                    flex: 4,
                                    child: pw.Align(
                                      alignment: pw.Alignment.centerLeft,
                                      child: pw.Text(
                                          'Notes  :${cart.foodLevelNotes}',
                                          style: styleFunction(font,
                                              isUnderLine: cart.foodStatus == 3,
                                              isPaperSize80: paperRoll == 80,
                                              name: printConfig
                                                  .restaurantFoodList)),
                                    )),
                              ]),
                            ]),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                        ]);
                      }),
                    if (orderNote != '')
                      pw.Column(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 1),
                          child: buildDottedLine(180),
                        ),
                        pw.Row(children: [
                          pw.Expanded(
                              flex: 1,
                              child: pw.Center(
                                child: pw.Text('',
                                    style: styleFunction(font,
                                        isPaperSize80: paperRoll == 80,
                                        name: printConfig.restaurantFoodList)),
                              )),
                          pw.Expanded(
                              flex: 4,
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text('Notes  :${orderNote}',
                                    style: styleFunction(font,
                                        isPaperSize80: paperRoll == 80,
                                        name: printConfig.restaurantFoodList)),
                              )),
                        ]),
                      ]),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 1),
                      child: buildDottedLine(180),
                    ),
                    if (printType == 'bill' ||
                        printType == 'paid_bill' ||
                        printType == 'swiggy_bill' ||
                        printType == 'billing')
                      pw.Column(children: [
                        // if (roomAdvancePay != 0 && printType != 'paid_bill')
                        //   pw.Align(
                        //     alignment: pw.Alignment.centerRight,
                        //     child: pw.Text(
                        //         'Room Advance : ${PriceConverter.convertPrice(roomAdvancePay, isHideCurrency: true, asFixed: 2)}',
                        //         style: styleFunction(font,
                        //             isPaperSize80: paperRoll == 80,
                        //             name: printConfig.gstParcent)),
                        //   ),
                        // if (roomRemainingPay != 0 && printType != 'paid_bill')
                        //   pw.Align(
                        //     alignment: pw.Alignment.centerRight,
                        //     child: pw.Text(
                        //         'Room Pending : ${PriceConverter.convertPrice(roomRemainingPay, isHideCurrency: true, asFixed: 2)}',
                        //         style: styleFunction(font,
                        //             isPaperSize80: paperRoll == 80,
                        //             name: printConfig.gstParcent)),
                        //   ),
                        // if (printType != 'swiggy_bill')
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                              'Item Total : ${PriceConverter.convertPrice(orderSubTotal!, isHideCurrency: true, asFixed: 2)}',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.restaurantSubTotal)),
                        ),
                        if (discount != 0 || couponDiscount != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                couponDiscount != 0
                                    ? 'Coupon Discount : ${couponDiscount.toStringAsFixed(2)}'
                                    : '${profileModel?.restaurants?.first.discountText ?? ''} : ${discount!.toStringAsFixed(2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.discount)),
                          ),
                        if (couponCode != '')
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Coupon Code : $couponCode',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.tip)),
                          ),
                        if (loyaltyUsed != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Used Loyalty Point : ${loyaltyUsed.toStringAsFixed(2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.vatParcent)),
                          ),
                        if (tips != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Add Tips : ${PriceConverter.convertPrice(tips!, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.tip)),
                          ),
                        if (serviceChargeAmount != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                '${Get.find<AuthController>().profileModel!.restaurants?.first.settings?.serviceChrgTaxt ?? 'Service Charge'} : ${PriceConverter.convertPrice(serviceChargeAmount!, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.serviceCharge)),
                          ),
                        if (deliveryCharge != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Delivery Charge : ${PriceConverter.convertPrice(deliveryCharge, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryCharge)),
                          ),
                        if (packingCharge != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Packing Charge : ${PriceConverter.convertPrice(packingCharge ?? 0, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryCharge)),
                          ),

                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                              'Sub Total : ${PriceConverter.convertPrice((subTotalWithoutTax), isHideCurrency: true, asFixed: 2)}',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.gstParcent)),
                        ),
                        if (swiggyTax != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Total Tax : ${PriceConverter.convertPrice(swiggyTax, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        if (gstAmount != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'CGST(2.5%) : ${PriceConverter.convertPrice(gstAmount! / 2, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        if (gstAmount != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'SGST(2.5%) : ${PriceConverter.convertPrice(gstAmount! / 2, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        if (roomGst != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Room GST : ${PriceConverter.convertPrice(roomGst, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        if (vatAmount != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'VAT : ${PriceConverter.convertPrice(vatAmount!, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.vatParcent)),
                          ),
                        if (walletUsed != 0)
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Used Wallet Amount : ${walletUsed.toStringAsFixed(2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.vatParcent)),
                          ),
                        // ──────────────────────────────────────────────
                        // PREVIOUS ROOM CHARGES (only for room checkout)
                        // ──────────────────────────────────────────────
                        if (printType == 'bill' &&
                            associatedOrders.isNotEmpty &&
                            rType == 'RM') ...[
                          if (paymentAmount != 0)
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                  'Total : ${PriceConverter.convertPrice(paymentAmount!, isHideCurrency: true, asFixed: 2)}',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name: printConfig.vatParcent)),
                            ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Center(
                              child: pw.Text(
                                '-- Previous Room Bill --',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.resturantFoodListHeader),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                          ...List.generate(associatedOrders.length, (index) {
                            AssociatedOrder assoc = associatedOrders[index];
                            // Edge case: skip zero-amount entries
                            if ((assoc.orderAmount ?? 0) == 0)
                              return pw.SizedBox();

                            return pw.Column(children: [
                              pw.Row(children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerLeft,
                                    child: pw.Text(
                                      // Edge case: fallback to orderId if restaurantOrderId is null
                                      'Order #${assoc.restaurantOrderId ?? assoc.orderId ?? ''}',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name: printConfig.restaurantFoodList),
                                    ),
                                  ),
                                ),
                                // pw.Expanded(
                                //   flex: 1,
                                //   child: pw.Align(
                                //     alignment: pw.Alignment.centerLeft,
                                //     child: pw.Text(
                                //       '1',
                                //       style: styleFunction(font,
                                //           isPaperSize80: paperRoll == 80,
                                //           name: printConfig.restaurantFoodList),
                                //     ),
                                //   ),
                                // ),
                                // pw.SizedBox(width: 2),
                                // pw.Expanded(
                                //   flex: 1,
                                //   child: pw.Align(
                                //     alignment: pw.Alignment.centerLeft,
                                //     child: pw.Text(
                                //       '${assoc.orderAmount?.toInt() ?? 0}',
                                //       style: styleFunction(font,
                                //           isPaperSize80: paperRoll == 80,
                                //           name: printConfig.restaurantFoodList),
                                //     ),
                                //   ),
                                // ),
                                pw.SizedBox(width: 2),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      '${assoc.orderAmount?.toInt() ?? 0}',
                                      style: styleFunction(font,
                                          isPaperSize80: paperRoll == 80,
                                          name: printConfig.restaurantFoodList),
                                    ),
                                  ),
                                ),
                              ]),
                              // pw.Padding(
                              //   padding: pw.EdgeInsets.symmetric(vertical: 1),
                              //   child: buildDottedLine(180),
                              // ),
                            ]);
                          }),
                        ],
                        if ((roomAdvancePay != 0 || roomRemainingPay != 0) &&
                            printType != 'paid_bill' &&
                            rType == "RM")
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(vertical: 1),
                            child: buildDottedLine(180),
                          ),
                        if (roomAdvancePay != 0 &&
                            printType != 'paid_bill' &&
                            rType == "RM")
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Room Advance : ${PriceConverter.convertPrice(roomAdvancePay, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        if (roomRemainingPay != 0 &&
                            printType != 'paid_bill' &&
                            rType == "RM")
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                'Room Pending : ${PriceConverter.convertPrice(roomRemainingPay, isHideCurrency: true, asFixed: 2)}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.gstParcent)),
                          ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 1),
                          child: buildDottedLine(180),
                        ),
                        if ((paymentType != ''))
                          pw.Row(children: [
                            pw.Expanded(
                                child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                  (paymentType == 'pending' ||
                                          paymentStatus == 'unpaid')
                                      ? 'Unpaid'
                                      : 'Paid by : $paymentType',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name: printConfig.restaurantSubTotal)),
                            )),
                            pw.Expanded(
                                child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                  (associatedOrders.isNotEmpty
                                          ? 'Grand Total: '
                                          : 'Total: ') +
                                      (profileModel!.restaurants!.first
                                                  .isTotalRound ==
                                              'Yes'
                                          ? '${getRoundUpValue(value: (grandTotal!))}'
                                          : ('${PriceConverter.convertPrice((grandTotal!), isHideCurrency: true, asFixed: 2)}')),
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name: printConfig.restaurantTotalAmount)),
                            )),
                          ]),
                        if (paymentType == '')
                          pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                (associatedOrders.isNotEmpty
                                        ? 'Grand Total: '
                                        : 'Total: ') +
                                    (profileModel!.restaurants!.first
                                                .isTotalRound ==
                                            'Yes'
                                        ? '${getRoundUpValue(value: (grandTotal!))}'
                                        : ('${PriceConverter.convertPrice((grandTotal!), isHideCurrency: true, asFixed: 2)}')),
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.restaurantTotalAmount)),
                          ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 1),
                          child: buildDottedLine(180),
                        ),
                        if (orderType == 'delivery')
                          pw.Column(children: [
                            pw.Text('Name: ${deliveryCustName ?? ''}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryAddress)),
                            pw.Text('Phone: ${deliveryCustPhone ?? ''}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryAddress)),
                            pw.Text(
                                'Address Type: ${deliveryAddressType ?? ''}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryAddress)),
                            pw.Text('Address: ${deliveryCustAddress ?? ''}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryAddress)),
                            pw.Text('Pincode: ${deliveryCustPincode}',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.deliveryAddress)),
                            pw.Padding(
                                padding: pw.EdgeInsets.symmetric(vertical: 1),
                                child: buildDottedLine(180)),
                          ]),
                        if (paymentQr != null && printType != 'paid_bill')
                          pw.SizedBox(height: 10),
                        if (paymentQr != null && printType != 'paid_bill')
                          pw.Image(pw.MemoryImage(paymentQr),
                              height: 60, width: 60),
                        if (paymentQr != null && printType != 'paid_bill')
                          pw.Padding(
                            padding: pw.EdgeInsets.only(top: 5),
                            child: pw.Text('Scan to pay',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.resturantScanToPay)),
                          ),
                        if (profileModel?.restaurants?.first.feedback ==
                                'Yes' &&
                            feedbackQr != null)
                          pw.SizedBox(height: 20),
                        if (profileModel?.restaurants?.first.feedback ==
                                'Yes' &&
                            feedbackQr != null)
                          pw.Image(pw.MemoryImage(feedbackQr),
                              height: 60, width: 60),
                        if (profileModel?.restaurants?.first.feedback ==
                                'Yes' &&
                            feedbackQr != null)
                          pw.Padding(
                            padding: pw.EdgeInsets.only(top: 5),
                            child: pw.Text('Scan to provide feedback',
                                style: styleFunction(font,
                                    isPaperSize80: paperRoll == 80,
                                    name: printConfig.resturantScanToFeedback)),
                          ),
                        pw.SizedBox(height: 8),
                        if (profileModel?.restaurants?.first.footerTextBill !=
                            '')
                          pw.Text(
                              profileModel?.restaurants?.first.footerTextBill ??
                                  '',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.poweredByMygenie)),
                      ]),
                    if (profileModel!.termsCondition != null &&
                        profileModel.termsCondition!.isNotEmpty &&
                        printType != 'kot' &&
                        printType != 'swiggy_kot')
                      pw.Padding(
                        padding: pw.EdgeInsets.only(top: 5),
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('Terms & Condition',
                              style: styleFunction(font,
                                  isPaperSize80: paperRoll == 80,
                                  name: printConfig.poweredByMygenie)),
                        ),
                      ),
                    if (profileModel.termsCondition != null &&
                        profileModel.termsCondition!.isNotEmpty &&
                        printType != 'kot' &&
                        printType != 'swiggy_kot')
                      ...List.generate(
                        profileModel.termsCondition!.length,
                        (index) {
                          return pw.Padding(
                            padding: pw.EdgeInsets.only(top: 2),
                            child: pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                  '${profileModel.termsCondition?[index] ?? ''}',
                                  style: styleFunction(font,
                                      isPaperSize80: paperRoll == 80,
                                      name: printConfig.poweredByMygenie)),
                            ),
                          );
                        },
                      ),

                    pw.SizedBox(height: 8),
                    pw.Text(
                        ((profileModel.restaurants!.first.id == 644 ||
                                    profileModel.restaurants!.first.id == 1 ||
                                    profileModel.restaurants!.first.id ==
                                        478) &&
                                printType == 'kot' &&
                                printEditOrderCount != null &&
                                printEditOrderCount != '')
                            ? 'Powered by MyGenie ${printEditOrderCount}(${kotOrderList!.first.itemUpdateCount})'
                            : 'Powered by MyGenie',
                        style: styleFunction(font,
                            isPaperSize80: paperRoll == 80,
                            name: printConfig.poweredByMygenie)),
                    pw.SizedBox(height: 15),
                    // pw.Text('', style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                )),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.TextStyle styleFunction(pw.Font font,
      {String? name, bool isPaperSize80 = false, bool isUnderLine = false}) {
    return pw.TextStyle(
      font: font,
      fontWeight: name?.split(',').last == 'true'
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
      decoration:
          isUnderLine ? pw.TextDecoration.lineThrough : pw.TextDecoration.none,
      // fontType: isPaperSize80 ? PosFontType.fontA : PosFontType.fontB,

      // height: fonstSize(name.split(',').first),
      fontSize: double.parse((name?.split(',').first ?? '7') as String),
    );
  }
}

pw.Widget buildDottedLine(double totalWidth) {
  const double dashWidth = 5;
  const double dashSpace = 3;
  double startX = 0;
  List<pw.Widget> dashes = [];

  while (startX < 250) {
    dashes.add(
      pw.Container(
        width: dashWidth,
        height: 1,
        color: PdfColors.black,
      ),
    );
    startX += dashWidth + dashSpace;

    if (startX < 200) {
      dashes.add(pw.SizedBox(width: dashSpace));
    }
  }

  return pw.Row(children: dashes);
}

Future<Uint8List> generateQrCode(String data) async {
  // Generate QR code
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  final qrCode = qrValidationResult.qrCode;
  final painter = QrPainter.withQr(
    qr: qrCode!,
    gapless: true,
    embeddedImageStyle: null,
    embeddedImage: null,
  );

  // Convert to an image for PDF
  final imageData = await painter.toImageData(300);
  return imageData!.buffer.asUint8List();
}

String formatQuantity(num? value) {
  return (value ?? 0)
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'\.?0+$'), '');
}
