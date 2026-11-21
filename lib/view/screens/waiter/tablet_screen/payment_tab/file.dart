// import 'dart:typed_data';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/pos_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/util/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class WindowsBillPrint extends StatelessWidget {
//   const WindowsBillPrint(
//       {this.order,
//       this.name,
//       this.phone,
//       this.tips,
//       this.orderSubTotal,
//       this.orderDiscount,
//       this.serviceValue,
//       this.gstAmount,
//       this.vatAmount,
//       Key key})
//       : super(key: key);
//   final Orders order;
//   final String name;
//   final String phone;
//   final String tips;
//   final double orderSubTotal;
//   final double orderDiscount;
//   final double serviceValue;
//   final double gstAmount;
//   final double vatAmount;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Bill Detail')),
//       body: PdfPreview(
//         build: (format) => _generatePdf(format, 'Bill Detail'),
//       ),
//     );
//   }

//   Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
//     ProfileModel profileModel = Get.find<AuthController>().profileModel;
//     bool isShowDate =
//         profileModel.restaurants.first.showFoodDate == 'Yes' ? true : false;
//     final feedbackQr = await _generateQrCode(
//         '${AppConstants.FEEDBACK_BASE_URL}?orderId=${order.orderDetailsOrder.id}');
//     final paymentQr = await _generateQrCode(
//       'upi://pay?pa=${Get.find<AuthController>().profileModel.restaurants.first.upiId}&pn=&am=${Get.find<PosController>().collectItemPrice + order.orderDetailsOrder.deliveryCharge}&tn=',
//     );
//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
//     final font = await PdfGoogleFonts.poppinsMedium();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(
//           48 * PdfPageFormat.mm,
//           double.infinity,
//           marginLeft: 0,
//           marginRight: 0,
//         ), // 58mm width
//         build: (context) {
//           return pw.Column(
//             children: [
//               pw.Text(profileModel.restaurants.first.name,
//                   style: pw.TextStyle(font: font, fontSize: 10)),
//               pw.SizedBox(height: 5),
//               pw.Text(profileModel.restaurants.first.address,
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants[0].gstCode != '')
//                 pw.SizedBox(height: 5),
//               if (profileModel.restaurants[0].gstCode != '')
//                 pw.Text('GST no. ${profileModel.restaurants.first.gstCode}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants[0].fssai != '')
//                 pw.SizedBox(height: 5),
//               if (profileModel.restaurants[0].fssai != '')
//                 pw.Text('FSI no. ${profileModel.restaurants.first.fssai}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),

// // ////////////////   ORDER DETAIL    /////////////////

//               pw.Row(children: [
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                       'Order ID. ${order.orderDetailsOrder.restaurantOrderId}',
//                       style: pw.TextStyle(font: font, fontSize: 6)),
//                 )),
//                 pw.SizedBox(width: 4),
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
//                       style: pw.TextStyle(font: font, fontSize: 6)),
//                 ))
//               ]),
//               if (order.orderDetailsOrder.orderType != 'delivery' &&
//                   order.orderDetailsOrder.orderType != 'take_away')
//                 pw.Row(children: [
//                   pw.Expanded(
//                       child: pw.Align(
//                     alignment: pw.Alignment.centerLeft,
//                     child: pw.Text('Dine In',
//                         style: pw.TextStyle(font: font, fontSize: 6)),
//                   )),
//                   pw.SizedBox(width: 5),
//                   pw.Expanded(
//                       child: pw.Align(
//                     alignment: pw.Alignment.centerRight,
//                     child: pw.Text('${order.restaurantDetails.waiterName}',
//                         style: pw.TextStyle(font: font, fontSize: 6)),
//                   ))
//                 ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(name ?? '',
//                       style: pw.TextStyle(font: font, fontSize: 6)),
//                 )),
//                 pw.SizedBox(width: 5),
//                 pw.Expanded(
//                     child: pw.Align(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(phone ?? '',
//                       style: pw.TextStyle(font: font, fontSize: 6)),
//                 ))
//               ]),
//               pw.Text(
//                   order.restaurantDetails.tableNo == ''
//                       ? order.orderDetailsOrder?.orderType == 'delivery'
//                           ? 'Delivery'
//                           : order.orderDetailsOrder.orderType == 'take_away'
//                               ? 'Take Away'
//                               : 'WC'
//                       : order.restaurantDetails.tableArea == ''
//                           ? '${order.restaurantDetails.tableNo}'
//                           : '${order.restaurantDetails.tableArea}:${order.restaurantDetails.tableNo}',
//                   style: pw.TextStyle(font: font, fontSize: 6)),
//               pw.Divider(),

// // //////////////////   FOOD DETAIL   ///////////////////

//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Center(
//                       child: pw.Text('SL',
//                           style: pw.TextStyle(font: font, fontSize: 6)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Center(
//                       child: pw.Text('item_info'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 6)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Center(
//                       child: pw.Text('qty'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 6)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Center(
//                       child: pw.Text('Price'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 6)),
//                     )),
//                 if (isShowDate) pw.SizedBox(width: 3),
//                 if (isShowDate)
//                   pw.Expanded(
//                       flex: 1,
//                       child: pw.Center(
//                         child: pw.Text('Date'.tr,
//                             style: pw.TextStyle(font: font, fontSize: 6)),
//                       ))
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 7),
//                 child: buildDottedLine(180),
//               ),
//               ...List.generate(order.mergeFoodListWithDate.length, (index) {
//                 OrderDetailsBar food = order.mergeFoodListWithDate[index];
//                 String variationText = '';
//                 String addons = '';
//                 double variationTotal = 0;
//                 double addonsTotal = 0;

//                 if (food.variation != null && food.variation.isNotEmpty) {
//                   variationText += '(';
//                   List<String> labelList = [];
//                   for (int j = 0; j < food.variation.length; j++) {
//                     if (food.variation[j].values != null) {
//                       for (var element in food.variation[j].values) {
//                         labelList.add(element.level);
//                         variationTotal +=
//                             (int.parse(element.optionPrice) * food.quantity);
//                       }
//                     }
//                   }
//                   variationText += '${labelList.join(',')}';
//                   variationText += ')';
//                 }

//                 for (var i = 0; i < food.addOns.length; i++) {
//                   addons +=
//                       '${food.addOns[i].name} (${food.addOns[i].quantity})';
//                   addonsTotal = addonsTotal +
//                       ((food.addOns[i].price * food.addOns[i].quantity) *
//                           food.quantity);
//                 }
//                 return food.foodStatus == 3
//                     ? pw.SizedBox.shrink()
//                     : pw.Column(children: [
//                         pw.Row(children: [
//                           pw.Expanded(
//                               flex: 1,
//                               child: pw.Center(
//                                 child: pw.Text('${index + 1}.',
//                                     style:
//                                         pw.TextStyle(font: font, fontSize: 6)),
//                               )),
//                           pw.Expanded(
//                               flex: 2,
//                               child: pw.Center(
//                                 child: pw.Text(
//                                     '${food.foodDetails['name']} $variationText',
//                                     style:
//                                         pw.TextStyle(font: font, fontSize: 6)),
//                               )),
//                           pw.Expanded(
//                               flex: 1,
//                               child: pw.Center(
//                                 child: pw.Text('${food.quantity}',
//                                     style:
//                                         pw.TextStyle(font: font, fontSize: 6)),
//                               )),
//                           pw.SizedBox(width: 3),
//                           pw.Expanded(
//                               flex: 1,
//                               child: pw.Center(
//                                 child: pw.Text(
//                                     '${((food.unitPrice * food.quantity) + variationTotal).toStringAsFixed(2)}',
//                                     style:
//                                         pw.TextStyle(font: font, fontSize: 6)),
//                               )),
//                           if (isShowDate) pw.SizedBox(width: 3),
//                           if (isShowDate)
//                             pw.Expanded(
//                                 flex: 1,
//                                 child: pw.Center(
//                                   child: pw.Text(
//                                       '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
//                                       style: pw.TextStyle(
//                                           font: font, fontSize: 6)),
//                                 ))
//                         ]),
//                         if (addons != '' && addonsTotal != 0)
//                           pw.Column(children: [
//                             pw.Padding(
//                               padding: pw.EdgeInsets.symmetric(vertical: 7),
//                               child: buildDottedLine(180),
//                             ),
//                             pw.Row(children: [
//                               pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Center(
//                                     child: pw.Text('',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                               pw.Expanded(
//                                   flex: 2,
//                                   child: pw.Center(
//                                     child: pw.Text('$addons',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                               pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Center(
//                                     child: pw.Text('',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                               pw.SizedBox(width: 3),
//                               pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Center(
//                                     child: pw.Text(
//                                         '${addonsTotal.toStringAsFixed(2)}',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                               if (isShowDate) pw.SizedBox(width: 3),
//                               if (isShowDate)
//                                 pw.Expanded(
//                                     flex: 1,
//                                     child: pw.Center(
//                                       child: pw.Text('',
//                                           style: pw.TextStyle(
//                                               font: font, fontSize: 6)),
//                                     ))
//                             ]),
//                           ]),
//                         if (order.orderDetailsOrder.orderNote != '' &&
//                             food.foodDetails['name']
//                                 .toString()
//                                 .toLowerCase()
//                                 .contains('out of'))
//                           pw.Column(children: [
//                             pw.Padding(
//                               padding: pw.EdgeInsets.symmetric(vertical: 7),
//                               child: buildDottedLine(180),
//                             ),
//                             pw.Row(children: [
//                               pw.Expanded(
//                                   flex: 1,
//                                   child: pw.Center(
//                                     child: pw.Text('',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                               pw.Expanded(
//                                   flex: 2,
//                                   child: pw.Center(
//                                     child: pw.Text(
//                                         'Notes  :${order.orderDetailsOrder.orderNote}',
//                                         style: pw.TextStyle(
//                                             font: font, fontSize: 6)),
//                                   )),
//                             ]),
//                           ]),
//                         pw.Padding(
//                           padding: pw.EdgeInsets.symmetric(vertical: 7),
//                           child: buildDottedLine(180),
//                         ),
//                       ]);
//               }),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 7),
//                 child: buildDottedLine(180),
//               ),

//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                     'Sub Total ${PriceConverter.convertPrice(orderSubTotal, isHideCurrency: true, asFixed: 2)}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               ),
//               if (orderDiscount != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       '${profileModel.restaurants.first.discountText} ${PriceConverter.convertPrice(orderDiscount, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (tips != '' && tips != '0')
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'Add Tips ${PriceConverter.convertPrice(double.parse(tips), isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (Get.find<PosController>().isAddServiceCharge &&
//                   serviceValue != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'Service Charge ${PriceConverter.convertPrice(serviceValue, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (order.orderDetailsOrder.deliveryCharge != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'Delivery Charge ${PriceConverter.convertPrice(order.orderDetailsOrder.deliveryCharge, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (gstAmount != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'CGST ${PriceConverter.convertPrice(gstAmount / 2, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (gstAmount != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'SGST ${PriceConverter.convertPrice(gstAmount / 2, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),
//               if (vatAmount != 0)
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                       'VAT ${PriceConverter.convertPrice(vatAmount, isHideCurrency: true, asFixed: 2)}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                 ),

//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 7),
//                 child: buildDottedLine(180),
//               ),
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                     'Total: ${PriceConverter.convertPrice(Get.find<PosController>().collectItemPrice + order.orderDetailsOrder.deliveryCharge, isHideCurrency: true, asFixed: 2)}',
//                     style: pw.TextStyle(font: font, fontSize: 10)),
//               ),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 7),
//                 child: buildDottedLine(180),
//               ),
//               if (order.orderDetailsOrder.orderType == 'delivery')
//                 pw.Column(children: [
//                   pw.Text('Name: ${order.deliveryAddress.name}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                   pw.Text('Phone: ${order.deliveryAddress.phone}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                   pw.Text('Address Type: ${order.deliveryAddress.addressType}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                   pw.Text('Address: ${order.deliveryAddress.address}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                   pw.Text('Pincode: ${order.deliveryAddress.pincode}',
//                       style: pw.TextStyle(font: font, fontSize: 8)),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.symmetric(vertical: 7),
//                     child: buildDottedLine(180),
//                   ),
//                 ]),
//               if (profileModel.restaurants.first.upiId != '')
//                 pw.Image(pw.MemoryImage(paymentQr)),
//               pw.SizedBox(height: 20),
//               if (profileModel.restaurants.first.feedback == 'Yes')
//                 pw.Image(pw.MemoryImage(feedbackQr)),
//               pw.SizedBox(height: 8),
//               pw.Text('Please visit us again',
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//               pw.SizedBox(height: 8),
//               pw.Text('Powered by MyGenie',
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

// // Function to generate QR code as a Uint8List image
//   Future<Uint8List> _generateQrCode(String data) async {
//     // Generate QR code
//     final qrValidationResult = QrValidator.validate(
//       data: data,
//       version: QrVersions.auto,
//       errorCorrectionLevel: QrErrorCorrectLevel.L,
//     );

//     final qrCode = qrValidationResult.qrCode;
//     final painter = QrPainter.withQr(
//       qr: qrCode,
//       gapless: true,
//       embeddedImageStyle: null,
//       embeddedImage: null,
//     );

//     // Convert to an image for PDF
//     final imageData = await painter.toImageData(300);
//     return imageData.buffer.asUint8List();
//   }

//   pw.Widget buildDottedLine(double totalWidth) {
//     const double dashWidth = 5;
//     const double dashSpace = 3;
//     double startX = 0;
//     List<pw.Widget> dashes = [];

//     while (startX < totalWidth) {
//       dashes.add(
//         pw.Container(
//           width: dashWidth,
//           height: 1,
//           color: PdfColors.black,
//         ),
//       );
//       startX += dashWidth + dashSpace;

//       if (startX < totalWidth) {
//         dashes.add(pw.SizedBox(width: dashSpace));
//       }
//     }

//     return pw.Row(children: dashes);
//   }
// }
