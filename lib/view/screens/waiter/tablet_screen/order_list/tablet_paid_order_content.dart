// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/kds_controller.dart';
// import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
// import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/helper/printer_config.dart';
// import 'package:mygenie_restaurant/helper/route_helper.dart';
// import 'package:mygenie_restaurant/util/app_constants.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:image/image.dart' as prefix;
// import 'package:intl/intl.dart';

// class TabletPaidOrdersContent extends StatefulWidget {
//   TextEditingController paidSearch;
//   TabletPaidOrdersContent({Key key, this.paidSearch}) : super(key: key);

//   @override
//   State<TabletPaidOrdersContent> createState() =>
//       TabletPaidOrdersContentState();
// }

// class TabletPaidOrdersContentState extends State<TabletPaidOrdersContent> {
//   PrinterManager printerManager = PrinterManager.instance;
//   StreamSubscription<BTStatus> _subscriptionBtStatus;
//   List<int> pendingTask;
//   BTStatus currentStatus = BTStatus.none;

//   @override
//   void initState() {
//     super.initState();
//     // PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//     if (Platform.isAndroid) {
//       _subscriptionBtStatus =
//           PrinterManager.instance.stateBluetooth.listen((status) {
//         log(' -----------------paid status bt $status ------------------ ');

//         currentStatus = status;
//         if (status == BTStatus.connected && pendingTask != null) {
//           if (Platform.isAndroid) {
//             Future.delayed(const Duration(milliseconds: 1000), () async {
//               PrinterManager.instance
//                   .send(type: PrinterType.bluetooth, bytes: pendingTask);
//               Future.delayed(Duration(seconds: 15), () async {
//                 await PrinterManager.instance
//                     .disconnect(type: PrinterType.bluetooth);
//               });
//               pendingTask = null;
//             });
//           } else if (Platform.isIOS) {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask);
//             pendingTask = null;
//           }
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _subscriptionBtStatus?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: widget.paidSearch,
//                   textInputAction: TextInputAction.search,
//                   autofocus: false,
//                   textCapitalization: TextCapitalization.words,
//                   keyboardType: TextInputType.name,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(
//                         horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//                     suffixIcon: Icon(Icons.search, color: ColorTheme.appColor),
//                     hintText: 'Order id or name or mobile',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.RADIUS_LARGE),
//                       borderSide:
//                           BorderSide(color: Color.fromRGBO(229, 229, 229, 1.0)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.RADIUS_LARGE),
//                       borderSide:
//                           BorderSide(color: Color.fromRGBO(229, 229, 229, 1.0)),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.RADIUS_LARGE),
//                       borderSide:
//                           BorderSide(color: Color.fromRGBO(229, 229, 229, 1.0)),
//                     ),
//                     hintStyle: poppinsRegular.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 15
//                             : 16,
//                         color: Theme.of(context).hintColor),
//                     filled: true,
//                     fillColor: Theme.of(context).cardColor,
//                   ),
//                   style: poppinsRegular.copyWith(
//                     color: Theme.of(context).textTheme.bodyLarge.color,
//                     fontSize: Dimensions.FONT_SIZE_LARGE,
//                   ),
//                   onChanged: (value) async {
//                     Get.find<KdsController>().update();
//                   },
//                 ),
//               ),
//               SizedBox(width: 10),
//               InkWell(
//                 onTap: () {
//                   widget.paidSearch.clear();
//                   _selectDate(context);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 5, vertical: 11),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                       border: Border.all(color: Theme.of(context).hintColor)),
//                   child: Text(
//                     selectedDate == null
//                         ? 'Filter by date'
//                         : DateFormat('yyyy-MM-dd').format(selectedDate),
//                     style: poppinsRegular.copyWith(
//                       color: Theme.of(context).hintColor,
//                       fontSize: MediaQuery.of(context).size.shortestSide > 570
//                           ? 15
//                           : 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           // Get.find<KdsController>().getPaidOrders == null
//           //     ? SizedBox.shrink()
//           //     : Wrap(
//           //         direction: Axis.horizontal,
//           //         crossAxisAlignment: WrapCrossAlignment.start,
//           //         runAlignment: WrapAlignment.start,
//           //         alignment: WrapAlignment.start,

//           //         // spacing: 10,
//           //         runSpacing: 10,
//           //         children: Get.find<KdsController>()
//           //             .getPaidOrders
//           //             .orders
//           //             .map((order) {
//           //           return widget.paidSearch.text.isEmpty
//           //               ? orderBox(Get.find<KdsController>()
//           //                   .getPaidOrders
//           //                   .orders
//           //                   .indexOf(order))
//           //               : (order.id.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase())) ||
//           //                       (order.email.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase())) ||
//           //                       (order.phone.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase())) ||
//           //                       (order.username.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase())) ||
//           //                       (order.fName.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase())) ||
//           //                       (order.lName.toString().toUpperCase().contains(
//           //                           widget.paidSearch.text.toUpperCase()))
//           //                   ? orderBox(Get.find<KdsController>()
//           //                       .getPaidOrders
//           //                       .orders
//           //                       .indexOf(order))
//           //                   : const SizedBox.shrink();
//           //         }).toList(),
//           //       ),
//           Row(
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   'Order Id',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 flex: MediaQuery.of(context).size.width > 1600 ? 2 : 1,
//                 child: Text(
//                   'Name',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   'Phone',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 flex: 2,
//                 child: Text(
//                   'Email',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   'Order Amount',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Text(
//                   'Payment Method',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.appColor),
//                 ),
//               ),
//               Expanded(
//                 child: SizedBox(),
//               ),
//               Expanded(
//                 child: SizedBox(),
//               ),
//             ],
//           ),
//           ListView.builder(
//               physics: BouncingScrollPhysics(),
//               shrinkWrap: true,
//               // itemCount: 10,
//               itemCount:
//                   Get.find<KdsController>().getPaidOrders?.orders?.length ?? 0,
//               itemBuilder: (BuildContext context, int i) {
//                 var order = Get.find<KdsController>().getPaidOrders.orders[i];
//                 return widget.paidSearch.text.isEmpty
//                     ? tableViewUI(i)
//                     : (order.id.toString().toUpperCase().contains(
//                                 widget.paidSearch.text.toUpperCase())) ||
//                             (order.email.toString().toUpperCase().contains(
//                                 widget.paidSearch.text.toUpperCase())) ||
//                             (order.phone.toString().toUpperCase().contains(
//                                 widget.paidSearch.text.toUpperCase())) ||
//                             (order.username.toString().toUpperCase().contains(
//                                 widget.paidSearch.text.toUpperCase())) ||
//                             (order.fName.toString().toUpperCase().contains(
//                                 widget.paidSearch.text.toUpperCase())) ||
//                             (order.lName
//                                 .toString()
//                                 .toUpperCase()
//                                 .contains(widget.paidSearch.text.toUpperCase()))
//                         ? tableViewUI(i)
//                         : const SizedBox.shrink();
//               }),
//           // ListView.builder(
//           //     physics: BouncingScrollPhysics(),
//           //     shrinkWrap: true,
//           //     // itemCount: 10,
//           //     itemCount:
//           //         Get.find<KdsController>().getPaidOrders?.orders?.length ?? 0,
//           //     itemBuilder: (BuildContext context, int i) {
//           //       var order = Get.find<KdsController>().getPaidOrders.orders[i];
//           //       return widget.paidSearch.text.isEmpty
//           //           ? orderBox(i)
//           //           : (order.id.toString().toUpperCase().contains(
//           //                       widget.paidSearch.text.toUpperCase())) ||
//           //                   (order.email.toString().toUpperCase().contains(
//           //                       widget.paidSearch.text.toUpperCase())) ||
//           //                   (order.phone.toString().toUpperCase().contains(
//           //                       widget.paidSearch.text.toUpperCase())) ||
//           //                   (order.username.toString().toUpperCase().contains(
//           //                       widget.paidSearch.text.toUpperCase())) ||
//           //                   (order.fName.toString().toUpperCase().contains(
//           //                       widget.paidSearch.text.toUpperCase())) ||
//           //                   (order.lName
//           //                       .toString()
//           //                       .toUpperCase()
//           //                       .contains(widget.paidSearch.text.toUpperCase()))
//           //               ? orderBox(i)
//           //               : const SizedBox.shrink();
//           //     }),
//         ],
//       ),
//     );
//   }

//   Widget orderBox(int i) {
//     var order = Get.find<KdsController>().getPaidOrders?.orders[i];
//     return Container(
//       width: MediaQuery.of(context).size.width > 1600
//           ? Get.width * 0.27
//           : Get.width * 0.45,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
//           color: Color.fromRGBO(254, 245, 208, 1)),
//       margin: EdgeInsets.only(left: 10),
//       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       child: Column(
//         children: [
//           // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Order Id',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               ),
//               Text(
//                 '${order.id}',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               )
//             ],
//           ),
//           if (order.fName != '' || order.lName != '')
//             SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           if (order.fName != '' || order.lName != '')
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Name',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.kdsLeftMenuBrown),
//                 ),
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       '${order.fName} ${order.lName}',
//                       style: poppinsMedium.copyWith(
//                           fontSize: MediaQuery.of(context).size.width > 1600
//                               ? 20
//                               : 16,
//                           color: ColorTheme.kdsLeftMenuBrown),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           if (order.phone != '')
//             SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           if (order.phone != '')
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Phone',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.kdsLeftMenuBrown),
//                 ),
//                 Text(
//                   '${order.phone}',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.kdsLeftMenuBrown),
//                 )
//               ],
//             ),
//           if (order.email != '')
//             SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           if (order.email != '')
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Email',
//                   style: poppinsMedium.copyWith(
//                       fontSize:
//                           MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                       color: ColorTheme.kdsLeftMenuBrown),
//                 ),
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       '${order.email}',
//                       style: poppinsMedium.copyWith(
//                           fontSize: MediaQuery.of(context).size.width > 1600
//                               ? 20
//                               : 16,
//                           color: ColorTheme.kdsLeftMenuBrown),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Order Amount',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               ),
//               Text(
//                 '${order.orderAmount} ₹',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               )
//             ],
//           ),
//           SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Payment Method',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               ),
//               Text(
//                 '${order.paymentMethod}',
//                 style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                     color: ColorTheme.kdsLeftMenuBrown),
//               )
//             ],
//           ),
//           SizedBox(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Get.find<AuthController>().profileModel.role.contains('bill')
//                   ? Row(
//                       children: [
//                         InkWell(
//                           onTap: () async {
//                             widget.paidSearch.clear();

//                             await Get.find<KdsController>()
//                                 .clearPaidOrderDetail();
//                             // await kdsBytesConvert(order.orderDetailsFood,
//                             //     order.orderDetailsOrder.id.toString());
//                             await Get.find<KdsController>().getPaidOrderDetail(
//                                 '${Get.find<KdsController>().getPaidOrders?.orders[i].id}');
//                             if (Get.find<KdsController>()
//                                     .paidOrderDetailResponse !=
//                                 null) {
//                               kdsBytesConvert();
//                             }
//                           },
//                           child: Image.asset(
//                             Images.printKot,
//                             alignment: Alignment.centerLeft,
//                             height: MediaQuery.of(context).size.width > 1600
//                                 ? 40
//                                 : 30,
//                             color: ColorTheme.appColor,
//                           ),
//                         ),
//                       ],
//                     )
//                   : SizedBox(),
//               InkWell(
//                 splashColor: Colors.transparent,
//                 hoverColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
//                 onTap: () async {
//                   widget.paidSearch.clear();

//                   await Get.find<KdsController>().clearPaidOrderDetail();
//                   Get.toNamed(
//                     RouteHelper.gePaidOrderDetailtRoute(
//                         Get.find<KdsController>()
//                             .getPaidOrders
//                             ?.orders[i]
//                             .id
//                             .toString()),
//                   );
//                   // await Get.find<KdsController>().getPaidOrderDetail(
//                   //     '${Get.find<KdsController>().getPaidOrders?.orders[i].id}');
//                 },
//                 child: Container(
//                   // width: 110,
//                   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.transparent),
//                       color: ColorTheme.appColor,
//                       // border:
//                       //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//                   child: Center(
//                     child: Text(
//                       'Detail',
//                       style: poppinsMedium.copyWith(
//                           fontSize: MediaQuery.of(context).size.width > 1600
//                               ? 20
//                               : 16,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox.shrink()
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   DateTime selectedDate;

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDate ?? DateTime.now(),
//         firstDate: DateTime(2023, 6),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               // dialogBackgroundColor: Colors.yellow, // days/years gridview
//               textTheme: TextTheme(
//                 headline5: poppinsMedium.copyWith(
//                     fontSize: 16), // Selected Date landscape
//                 headline6: poppinsMedium.copyWith(
//                     fontSize: 16), // Selected Date portrait
//                 overline:
//                     poppinsMedium.copyWith(fontSize: 16), // Title - SELECT DATE
//                 bodyText1: poppinsMedium.copyWith(
//                     fontSize: 16), // year gridbview picker
//                 subtitle1: poppinsMedium.copyWith(fontSize: 16), // input
//                 subtitle2:
//                     poppinsMedium.copyWith(fontSize: 18), // month/year picker
//                 caption: poppinsMedium.copyWith(fontSize: 16), // days
//               ),
//               // colorScheme: Theme.of(context).colorScheme.copyWith(
//               //       // Title, selected date and day selection background (dark and light mode)
//               //       surface: Colors.amber,
//               //       primary: Colors.amber,
//               //       // Title, selected date and month/year picker color (dark and light mode)
//               //       onSurface: Colors.black,
//               //       onPrimary: Colors.black,
//               //     ),
//               // Buttons
//               // textButtonTheme: TextButtonThemeData(
//               //   style: TextButton.styleFrom(
//               //     foregroundColor: Colors.yellow,
//               //     backgroundColor: Colors.pink,
//               //     textStyle: GoogleFonts.greatVibes(),
//               //   ),
//               // ),
//               // // Input
//               // inputDecorationTheme: InputDecorationTheme(
//               //   labelStyle: GoogleFonts.greatVibes(), // Input label
//               // ),
//             ),
//             child: child,
//           );
//         },
//         lastDate: DateTime.now());

//     if (picked != null && picked != selectedDate) {
//       selectedDate = picked;

//       await Get.find<KdsController>()
//           .getPaidOrderList(DateFormat('yyyy-MM-dd').format(selectedDate));
//     }
//   }

//   Widget tableViewUI(int i) {
//     var order = Get.find<KdsController>().getPaidOrders?.orders[i];

//     return Padding(
//       padding: EdgeInsets.only(top: 13),
//       child: Container(
//         padding: EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 6),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
//             color: Color.fromRGBO(248, 248, 248, 1.0)),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Text(
//                 '${order.id}',
//                 style: poppinsMedium.copyWith(
//                   fontSize: MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: MediaQuery.of(context).size.width > 1600 ? 2 : 1,
//               child: Text(
//                 '${order.fName} ${order.lName}',
//                 style: poppinsMedium.copyWith(
//                   fontSize: MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                 ),
//               ),
//             ),
//             SizedBox(width: 5),
//             Expanded(
//               flex: 1,
//               child: Text(
//                 '${order.phone}',
//                 style: poppinsMedium.copyWith(
//                   fontSize: MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                 ),
//               ),
//             ),
//             SizedBox(width: 5),
//             Expanded(
//               flex: 2,
//               child: Text(
//                 '${order.email}',
//                 style: poppinsMedium.copyWith(
//                   fontSize: MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                 ),
//               ),
//             ),
//             SizedBox(width: 5),
//             Expanded(
//               flex: 1,
//               child: Text(
//                 '${order.orderAmount} ₹',
//                 style: poppinsMedium.copyWith(
//                   fontSize: MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 1,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   '${order.paymentMethod}',
//                   style: poppinsMedium.copyWith(
//                     fontSize:
//                         MediaQuery.of(context).size.width > 1600 ? 20 : 16,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: MediaQuery.of(context).size.width > 1600 ? 1 : 2,
//               child: Row(
//                 children: [
//                   InkWell(
//                     splashColor: Colors.transparent,
//                     hoverColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     onTap: () async {
//                       FocusManager.instance.primaryFocus?.unfocus();
//                       await Get.find<KdsController>().clearPaidOrderDetail();
//                       widget.paidSearch.clear();

//                       Get.toNamed(
//                         RouteHelper.gePaidOrderDetailtRoute(
//                             Get.find<KdsController>()
//                                 .getPaidOrders
//                                 ?.orders[i]
//                                 .id
//                                 .toString()),
//                       );
//                     },
//                     child: Container(
//                       margin: EdgeInsets.only(left: 7),
//                       padding: EdgeInsets.symmetric(
//                           vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
//                           horizontal: 13),
//                       decoration: BoxDecoration(
//                           border: Border.all(color: Colors.transparent),
//                           color: ColorTheme.appColor,
//                           // border:
//                           //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
//                           borderRadius:
//                               BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
//                       child: Center(
//                         child: Text(
//                           'Detail',
//                           style: poppinsRegular.copyWith(
//                               fontSize: MediaQuery.of(context).size.width > 1600
//                                   ? 20
//                                   : MediaQuery.of(context).size.shortestSide >
//                                           570
//                                       ? 14
//                                       : Dimensions.FONT_SIZE_EXTRA_SMALL,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Get.find<AuthController>().profileModel.role.contains('bill')
//                       ? InkWell(
//                           onTap: () async {
//                             widget.paidSearch.clear();

//                             await Get.find<KdsController>()
//                                 .clearPaidOrderDetail();
//                             // await kdsBytesConvert(order.orderDetailsFood,
//                             //     order.orderDetailsOrder.id.toString());
//                             await Get.find<KdsController>().getPaidOrderDetail(
//                                 '${Get.find<KdsController>().getPaidOrders?.orders[i].id}');
//                             if (Get.find<KdsController>()
//                                     .paidOrderDetailResponse !=
//                                 null) {
//                               kdsBytesConvert();
//                             }
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 20),
//                             child: Image.asset(
//                               Images.printKot,
//                               alignment: Alignment.centerLeft,
//                               height: MediaQuery.of(context).size.width > 1600
//                                   ? 40
//                                   : 30,
//                               color: ColorTheme.appColor,
//                             ),
//                           ),
//                         )
//                       : SizedBox(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future kdsBytesConvert() async {
//     List<OrderDetailsFood> foodOrderList = [];

//     foodOrderList.addAll(Get.find<KdsController>()
//         .paidOrderDetailResponse
//         .orders
//         .orderDetailsFood);

//     final profile = await CapabilityProfile.load(name: 'XP-N160I');
//     final generator = Generator(
//         Get.find<AuthController>().profileModel.billPrinterPaperRoll == 58
//             ? PaperSize.mm58
//             : PaperSize.mm80,
//         profile);
//     pendingTask = [];
//     List<int> bytes = [];
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel.restaurants[0].name,
//         styles: PrinterConfig().titleStyle());
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel.restaurants[0].address,
//         styles: PrinterConfig().addressStyle());

//     if (Get.find<AuthController>().profileModel.restaurants[0].gstCode != '')
//       bytes += generator.text(
//           'GST no. ${Get.find<AuthController>().profileModel.restaurants[0].gstCode}',
//           styles: PrinterConfig().gstStyle());
//     if (Get.find<AuthController>().profileModel.restaurants[0].fssai != '')
//       bytes += generator.text(
//           'FSI no. ${Get.find<AuthController>().profileModel.restaurants[0].fssai}',
//           styles: PrinterConfig().gstStyle());
//     bool isShowDate = Get.find<AuthController>()
//                 .profileModel
//                 .restaurants
//                 .first
//                 .showFoodDate ==
//             'Yes'
//         ? true
//         : false;
//     bytes += generator.row([
//       PosColumn(
//           text: 'order_id'.tr +
//               ':' +
//               ' ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId}',
//           width: 6,
//           styles: PrinterConfig().orderIdStyle()),
//       PosColumn(
//           text:
//               '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.createdAt))}',
//           // DateConverter.dateTimeStringToMonthAndTime(
//           //     DateTime.now().toString()),
//           width: 6,
//           styles: PrinterConfig().orderCreateDateStyle()),
//     ]);
//     bytes += generator.row([
//       PosColumn(
//           text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
//       PosColumn(
//         text: '',
//         width: 1,
//         styles: PrinterConfig().dineInStyle(),
//       ),
//       PosColumn(
//           text:
//               '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantWaiterName}',
//           // text:
//           //     '${Get.find<AuthController>().profileModel.empFname} ${Get.find<AuthController>().profileModel.empLname}',
//           width: 6,
//           styles: PrinterConfig().waiterNameStyle()),
//     ]);
//     // bytes += generator.text(
//     //     Get.find<KdsController>()
//     //                 .paidOrderDetailResponse
//     //                 .orders
//     //                 .restaurantDetails
//     //                 .restaurantTableNo ==
//     //             ''
//     //         ? 'WC'
//     //         : '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantTableArea}:${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantTableNo}',
//     //     styles: const PosStyles(
//     //         align: PosAlign.center,
//     //         height: PosTextSize.size3,
//     //         width: PosTextSize.size2,
//     //         bold: true,
//     //         fontType: PosFontType.fontA));
//     if (Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser !=
//         null) {
//       String name =
//           '${Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser.fName} ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderUser.lName}';
//       String phone = Get.find<KdsController>()
//           .paidOrderDetailResponse
//           .orders
//           .orderUser
//           .phone;
//       phone == ''
//           ? bytes += generator.text(
//               '${name ?? ''}',
//               styles: PosStyles(
//                 align: PosAlign.left,
//               ),
//             )
//           : bytes += generator.row([
//               PosColumn(
//                 text: '${name ?? ''}',
//                 width: 5,
//                 styles: PosStyles(
//                   height: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? PosTextSize.size1
//                       : PrinterConfig().fonstSize(Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')
//                           .first),
//                   width: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? PosTextSize.size1
//                       : PrinterConfig().fonstSize(Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')[1]),
//                   bold: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? false
//                       : Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList
//                                   .split(',')
//                                   .last ==
//                               'true'
//                           ? true
//                           : false,
//                   align: PosAlign.left,
//                   // fontType: PosFontType.fontB,
//                 ),
//               ),
//               PosColumn(
//                 text: '',
//                 width: 2,
//                 styles: PosStyles(align: PosAlign.center, underline: true),
//               ),
//               PosColumn(
//                 text: '${phone ?? ''}',
//                 width: 5,
//                 styles: PosStyles(
//                   height: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? PosTextSize.size1
//                       : PrinterConfig().fonstSize(Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')
//                           .first),
//                   width: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? PosTextSize.size1
//                       : PrinterConfig().fonstSize(Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')[1]),
//                   bold: Get.find<AuthController>().profileModel.printConfig ==
//                               null ||
//                           Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList ==
//                               null
//                       ? false
//                       : Get.find<AuthController>()
//                                   .profileModel
//                                   .printConfig
//                                   .restaurantFoodList
//                                   .split(',')
//                                   .last ==
//                               'true'
//                           ? true
//                           : false,
//                   align: PosAlign.right,
//                   fontType: PosFontType.fontB,
//                 ),
//               ),
//             ]);
//     } else if (Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .username !=
//         '') {
//       bytes += generator.text(
//         Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .username,
//         styles: PosStyles(
//           height: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')
//                   .first),
//           width: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? PosTextSize.size1
//               : PrinterConfig().fonstSize(Get.find<AuthController>()
//                   .profileModel
//                   .printConfig
//                   .restaurantFoodList
//                   .split(',')[1]),
//           bold: Get.find<AuthController>().profileModel.printConfig == null ||
//                   Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList ==
//                       null
//               ? false
//               : Get.find<AuthController>()
//                           .profileModel
//                           .printConfig
//                           .restaurantFoodList
//                           .split(',')
//                           .last ==
//                       'true'
//                   ? true
//                   : false,
//           align: PosAlign.left,
//           fontType: PosFontType.fontB,
//         ),
//       );
//     }
//     bytes += generator.hr(ch: '--');

//     bytes += generator.row([
//       PosColumn(
//           text: 'SL',
//           width: isShowDate ? 1 : 2,
//           styles: PrinterConfig().foodStyle()),
//       PosColumn(
//         text: 'item_info'.tr,
//         width: isShowDate ? 4 : 5,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'qty'.tr,
//         width: isShowDate ? 3 : 2,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'Price',
//         width: isShowDate ? 2 : 3,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       if (isShowDate)
//         PosColumn(
//           text: 'Date',
//           width: 2,
//           styles: PrinterConfig().foodStyle(),
//         ),
//     ]);
//     bytes += generator.hr(ch: '--');
//     for (var i = 0; i < foodOrderList.length; i++) {
//       OrderDetailsFood food = foodOrderList[i];
//       String variationText = '';
//       String addons = '';

//       int variationTotal = 0;
//       int addonsTotal = 0;

//       if (food.variation != null && food.variation.isNotEmpty) {
//         for (int j = 0; j < food.variation.length; j++) {
//           variationText +=
//               '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

//           if (food.variation[j].values != null) {
//             List<String> labelList = [];
//             for (var element in food.variation[j].values) {
//               labelList.add(element.label);
//               variationTotal +=
//                   (int.parse(element.optionPrice) * food.quantity);
//             }
//             variationText +=
//                 '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
//           }

//           variationText += ')';
//         }
//       }

//       for (var i = 0; i < food.addOns.length; i++) {
//         addons += '${food.addOns[i].name} (${food.addOns[i].quantity})';
//         addonsTotal =
//             addonsTotal + (food.addOns[i].price * food.addOns[i].quantity);
//       }

//       bytes += generator.row([
//         PosColumn(
//             text: '${i + 1}.',
//             width: isShowDate ? 1 : 2,
//             styles: PrinterConfig().foodStyle()),
//         PosColumn(
//           text: '${food.foodDetails.name}',
//           width: 5,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: '${food.quantity}',
//           width: isShowDate ? 1 : 2,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: '${(food.price) + (variationTotal) + (addonsTotal)}',
//           width: 3,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         if (isShowDate)
//           PosColumn(
//             text:
//                 '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
//             width: 2,
//             styles: PrinterConfig().foodStyle(),
//           ),
//       ]);
//       if (addons != '') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Add-Ons :$addons',
//             width: 5,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           PosColumn(
//             text: '',
//             width: 3,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           if (isShowDate)
//             PosColumn(
//               text: '',
//               width: 2,
//               styles: PosStyles(align: PosAlign.center),
//             ),
//         ]);
//       }
//       if (variationText != '') {
//         bytes += generator.row([
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(
//               align: PosAlign.center,
//             ),
//           ),
//           PosColumn(
//             text: 'Variants  :$variationText',
//             width: 5,
//             styles: PrinterConfig().foodStyle(),
//           ),
//           PosColumn(
//             text: '',
//             width: isShowDate ? 1 : 2,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           PosColumn(
//             text: '',
//             width: 3,
//             styles: PosStyles(align: PosAlign.center),
//           ),
//           if (isShowDate)
//             PosColumn(
//               text: '',
//               width: 2,
//               styles: PosStyles(align: PosAlign.center),
//             ),
//         ]);
//       }

//       bytes += generator.hr(ch: '....');
//     }

//     bytes += generator.hr(ch: '....');

//     bytes += generator.row([
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PosStyles(
//           align: PosAlign.center,
//         ),
//       ),
//       PosColumn(
//         text: 'Sub Total ',
//         width: 5,
//         styles: PrinterConfig().subtotalStyle(),
//       ),
//       PosColumn(
//         text: '',
//         width: 2,
//         styles: PrinterConfig().subtotalStyle(),
//       ),
//       PosColumn(
//         text: PriceConverter.convertPrice(
//             Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderTotalAmount +
//                 Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderTotalAddonAmt +
//                 Get.find<KdsController>()
//                     .paidOrderDetailResponse
//                     .orders
//                     .orderTotalVariantAmt,
//             isHideCurrency: true,
//             asFixed: 2),
//         width: 3,
//         styles: PrinterConfig().subtotalStyle(),
//       ),
//     ]);
//     if (Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .restaurantDiscountAmount !=
//         0)
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//           text: 'Add Discount ',
//           width: 5,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//           text: PriceConverter.convertPrice(
//               Get.find<KdsController>()
//                   .paidOrderDetailResponse
//                   .orders
//                   .orderDetailsOrder
//                   .restaurantDiscountAmount,
//               isHideCurrency: true,
//               asFixed: 2),
//           width: 3,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//       ]);
//     // if (tipsController.text.isNotEmpty && tipsController.text != '0')
//     //   bytes += generator.row([
//     //     PosColumn(
//     //       text: '',
//     //       width: 2,
//     //       styles: PosStyles(
//     //         align: PosAlign.center,
//     //       ),
//     //     ),
//     //     PosColumn(
//     //       text: 'Add Tips ',
//     //       width: 5,
//     //       styles: PosStyles(align: PosAlign.center),
//     //     ),
//     //     PosColumn(
//     //       text: '',
//     //       width: 2,
//     //       styles: PosStyles(align: PosAlign.center),
//     //     ),
//     //     PosColumn(
//     //       text: PriceConverter.convertPrice(double.parse(tipsController.text),
//     //           isHideCurrency: true, asFixed: 2),
//     //       width: 3,
//     //       styles: PosStyles(align: PosAlign.center),
//     //     ),
//     //   ]);
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalServiceTaxAmount) !=
//         0)
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//           text: 'Service Charge',
//           width: 5,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//           text: PriceConverter.convertPrice(
//               double.parse(Get.find<KdsController>()
//                   .paidOrderDetailResponse
//                   .orders
//                   .orderDetailsOrder
//                   .totalServiceTaxAmount),
//               isHideCurrency: true,
//               asFixed: 2),
//           width: 3,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//       ]);
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalGstTaxAmount) !=
//         0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//           text: 'CGST ',
//           width: 5,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//           text: PriceConverter.convertPrice(
//               double.parse(Get.find<KdsController>()
//                       .paidOrderDetailResponse
//                       .orders
//                       .orderDetailsOrder
//                       .totalGstTaxAmount) /
//                   2,
//               isHideCurrency: true,
//               asFixed: 2),
//           width: 3,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//       ]);
//     }
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalGstTaxAmount) !=
//         0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//           text: 'SGST ',
//           width: 5,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//           text: PriceConverter.convertPrice(
//               double.parse(Get.find<KdsController>()
//                       .paidOrderDetailResponse
//                       .orders
//                       .orderDetailsOrder
//                       .totalGstTaxAmount) /
//                   2,
//               isHideCurrency: true,
//               asFixed: 2),
//           width: 3,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//       ]);
//     }
//     if (double.parse(Get.find<KdsController>()
//             .paidOrderDetailResponse
//             .orders
//             .orderDetailsOrder
//             .totalVatTaxAmount) !=
//         0) {
//       bytes += generator.row([
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(
//             align: PosAlign.center,
//           ),
//         ),
//         PosColumn(
//           text: 'VAT ',
//           width: 5,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//         PosColumn(
//           text: '',
//           width: 2,
//           styles: PosStyles(align: PosAlign.center),
//         ),
//         PosColumn(
//           text: PriceConverter.convertPrice(
//               double.parse(Get.find<KdsController>()
//                   .paidOrderDetailResponse
//                   .orders
//                   .orderDetailsOrder
//                   .totalVatTaxAmount),
//               isHideCurrency: true,
//               asFixed: 2),
//           width: 3,
//           styles: PrinterConfig().subtotalStyle(),
//         ),
//       ]);
//     }

//     bytes += generator.hr(ch: '....');
//     bytes += generator.text(
//       'Total: ' +
//           PriceConverter.convertPrice(
//               Get.find<KdsController>()
//                   .paidOrderDetailResponse
//                   .orders
//                   .orderDetailsOrder
//                   .orderAmount,
//               isHideCurrency: true,
//               asFixed: 2) +
//           ' ${Get.find<AuthController>().profileModel?.restaurants?.first?.currency ?? ''}',
//       styles: PrinterConfig().totalStyle(),
//     );
//     bytes += generator.hr(ch: '....');

//     if (Get.find<AuthController>().profileModel.restaurants.first.feedback ==
//         'Yes') {
//       try {
//         const double qrSize = 170;
//         final uiImg = await QrPainter(
//           data:
//               '${AppConstants.FEEDBACK_BASE_URL}?orderId=${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id}',
//           version: QrVersions.auto,
//           gapless: false,
//         ).toImageData(qrSize);
//         final dir = await getTemporaryDirectory();
//         final pathName = '${dir.path}/qr_tmp.png';
//         final qrFile = File(pathName);
//         final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
//         final img = prefix.decodeImage(imgFile.readAsBytesSync());
//         bytes += generator.text('Scan to provide feedback',
//             styles: const PosStyles(
//                 align: PosAlign.center,
//                 height: PosTextSize.size1,
//                 width: PosTextSize.size1,
//                 bold: true,
//                 fontType: PosFontType.fontA));

//         bytes += generator.feed(1);
//         bytes += generator.image(img);
//         bytes += generator.feed(1);
//       } catch (e) {
//         print(e);
//       }
//     }
//     bytes += generator.text('Powered by MyGenie',
//         styles: const PosStyles(
//             align: PosAlign.center,
//             height: PosTextSize.size1,
//             width: PosTextSize.size1,
//             // bold: true,
//             fontType: PosFontType.fontB));

//     if (Platform.isAndroid) {
//       await _kdsPrintEscPos(bytes, generator); //kitchen
//     } else {
//       await _iosPrintEscPos(bytes, generator); //kitchen
//     }
//   }

//   /// print ticket
//   Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
//     // await printerManager.disconnect(type: PrinterType.bluetooth);
//     BluetoothPrinter bluetoothPrinter = await BluetoothPrinter(
//         // address: 'DC:0D:30:20:3C:D5');
//         address: Get.find<AuthController>().profileModel.billPrinterIp,
//         deviceName: Get.find<AuthController>()
//             .profileModel
//             .billPrinterName); // ip was mandadory
//     await printerManager.connect(
//       type: bluetoothPrinter.typePrinter,
//       model: BluetoothPrinterInput(
//         name: bluetoothPrinter.deviceName,
//         address: bluetoothPrinter.address,
//       ),
//     );
//     switch (bluetoothPrinter.typePrinter) {
//       case PrinterType.usb:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: UsbPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             productId: bluetoothPrinter.productId,
//             vendorId: bluetoothPrinter.vendorId,
//           ),
//         );
//         break;
//       case PrinterType.bluetooth:
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: BluetoothPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             address: bluetoothPrinter.address,
//             isBle: bluetoothPrinter.isBle ?? false,
//           ),
//         );
//         pendingTask = null;
//         if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
//         break;
//       case PrinterType.network:
//         bytes += generator.feed(2);
//         bytes += generator.cut();
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: TcpPrinterInput(ipAddress: bluetoothPrinter.address),
//         );
//         break;
//       default:
//     }
//     if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//       try {
//         await printerManager.send(
//             type: bluetoothPrinter.typePrinter, bytes: bytes);
//         pendingTask = null;
//         Future.delayed(Duration(seconds: 15), () async {
//           await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//         });
//       } catch (e) {}
//     } else {
//       printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//     }
//   }

//   Future _iosPrintEscPos(List<int> bytes, Generator generator) async {
//     bytes += generator.feed(2);
//     bytes += generator.cut();
//     await PrintBluetoothThermal.pairedBluetooths;

//     // Future.delayed(Duration(seconds: 5), () async {
//     final bool result = await PrintBluetoothThermal.connect(
//         macPrinterAddress:
//             Get.find<AuthController>().profileModel.macBillPrinterIp);

//     Future.delayed(Duration(seconds: 4), () async {
//       if (result) {
//         // List<int> ticket = await testTicket();
//         await PrintBluetoothThermal.writeBytes(bytes);
//         Future.delayed(Duration(seconds: 24), () async {
//           var isDisconnect = await PrintBluetoothThermal.disconnect;
//           print('is disconnect $isDisconnect');
//         });
//         print("print test result:  $result");
//       } else {
//         //no conectado, reconecte
//         showCustomSnackBar('Failed to bluetooth connect');
//       }
//     });
//     // });
//   }
// }
