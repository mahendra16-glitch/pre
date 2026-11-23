// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
// import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/loader_contoller.dart';
// import 'package:mygenie_restaurant/controller/revenue_controller.dart';
// import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
// import 'package:mygenie_restaurant/data/model/response/get_print_report_response.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/helper/logo_helper.dart';
// import 'package:mygenie_restaurant/helper/printer_config.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
// import 'package:printing/printing.dart';

// class PrintReport extends StatefulWidget {
//   @override
//   State<PrintReport> createState() => _PrintReportState();
// }

// class _PrintReportState extends State<PrintReport> {
//   DateTime? selectedDate;
//   final PrinterManager printerManager = PrinterManager.instance;
//   late final StreamSubscription<BTStatus> _subscriptionBtStatus;
//   List<int>? pendingTask;
//   BTStatus currentStatus = BTStatus.none;

//   // String selectedDateRange = '';
//   // DateTime? startDate;
//   // DateTime? endDate;

//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) {
//       _subscriptionBtStatus =
//           PrinterManager.instance.stateBluetooth.listen((status) async {
//         log(' -----------------print report status bt $status ------------------ ');

//         currentStatus = status;
//         if (status == BTStatus.connected) {
//           if (Platform.isAndroid) {
//             Future.delayed(const Duration(milliseconds: 1000), () async {
//               PrinterManager.instance
//                   .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//               Future.delayed(Duration(seconds: 11), () async {
//                 await PrinterManager.instance
//                     .disconnect(type: PrinterType.bluetooth);
//               });
//               pendingTask = null;
//             });
//           } else if (Platform.isIOS) {
//             PrinterManager.instance
//                 .send(type: PrinterType.bluetooth, bytes: pendingTask!);
//             pendingTask = null;
//           }
//         } else if (status == BTStatus.none) {
//           Get.find<LoadingController>().startLoading(false);

//           await Get.find<LoadingController>()
//               .changeText(data: 'Failed to bluetooth connect!!', error: true);
//           await Get.find<LoadingController>().changeStatus(data: true);
//         }
//       });
//     }
//     initData();
//   }

//   initData() async {
//     await Get.find<RevenueController>().getPrintReport({
//       "from": DateFormat('yyyy-MM-dd').format(DateTime.now()),
//       "to": DateFormat('yyyy-MM-dd').format(DateTime.now())
//     });
//   }

//   TextEditingController searchTable = TextEditingController();
//   @override
//   void dispose() {
//     _subscriptionBtStatus.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         // toolbarHeight: Get.height / 10.72,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//             icon: Icon(Icons.chevron_left_outlined,
//                 color: ColorTheme.green, size: 36),
//             color: ColorTheme.appColor,
//             onPressed: () {
//               Get.back();
//             }),
//         titleSpacing: 0,
//         elevation: 0,
//         centerTitle: false,
//         title: MediaQuery.of(context).size.shortestSide > 570
//             ? Image.asset(
//                 logoHelper.appLogo!,
//                 width: Get.width * 0.13,
//               )
//             : Image.asset(
//                 logoHelper.appLogo!,
//                 width: Get.width * 0.3,
//               ),
//       ),
//       body: GetBuilder<RevenueController>(builder: (revenueController) {
//         return revenueController.isLoading
//             ? Center(
//                 child: CircularProgressIndicator(),
//               )
//             : SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 child: Column(children: [
//                   SizedBox(height: 5),
//                   filterbyDateRow(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Divider(height: 1, color: Color(0xFFE6E6E6)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Print Report',
//                         style: poppinsMedium.copyWith(
//                             color: ColorTheme.hintText, fontSize: 14),
//                       ),
//                     ),
//                   ),
//                   // totalSummary(revenueController),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         DateFormat('dd MMM yyyy')
//                             .format(selectedDate ?? DateTime.now()),
//                         style: poppinsSemiBold.copyWith(
//                             color: ColorTheme.appColor, fontSize: 14),
//                       ),
//                     ),
//                   ),
//                   // SizedBox(height: 10),
//                   // revenueList(revenueController),
//                   totalSale(revenueController),
//                   totalRev(revenueController),
//                   totalExpense(revenueController),
//                   todayGala(revenueController),
//                   cashCollected(revenueController),
//                   openingBalance(revenueController),
//                   closingBalance(revenueController),
//                   if (Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .payTab ==
//                           'Yes' ||
//                       Get.find<AuthController>()
//                               .profileModel!
//                               .restaurants!
//                               .first
//                               .showRoom ==
//                           'Yes')
//                     totalUnPaidRev(revenueController),
//                   runningOrder(revenueController),
//                   otherCharges(revenueController),
//                   stationRevenue(revenueController),
//                   cancelOrderRevenue(revenueController),

//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: InkWell(
//                       onTap: () async {
//                         if (GetPlatform.isWindows) {
//                           final printers = await Printing.listPrinters();
//                           for (var element in printers) {
//                             if (element.isAvailable &&
//                                 (element.name.toLowerCase() ==
//                                     Get.find<AuthController>()
//                                         .profileModel!
//                                         .wifiBillPrinterName!
//                                         .toLowerCase())) {
//                               await Printing.directPrintPdf(
//                                   printer: element,
//                                   onLayout: (_) => generateKotPdf());
//                               break;
//                             }
//                           }
//                         } else {
//                           showToast('Please wait..');
//                           Get.find<LoadingController>().startLoading(true);
//                           kdsBytesConvert();
//                         }
//                       },
//                       child: SvgPicture.asset(
//                         Images.ic_print_kot,
//                         height: MediaQuery.of(context).size.shortestSide > 570
//                             ? 37
//                             : 26,
//                         alignment: Alignment.centerLeft,
//                       ),
//                     ),
//                   ),
//                 ]),
//               );
//       }),
//     );
//   }

//   Widget filterbyDateRow() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 _selectDate(context);
//               },
//               child: Container(
//                 height:
//                     MediaQuery.of(context).size.shortestSide > 570 ? 55 : 40,
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(7),
//                     color: Colors.white,
//                     border: Border.all(color: ColorTheme.borderGrey)),
//                 child: Row(
//                   children: [
//                     Icon(Icons.calendar_month_outlined,
//                         color: ColorTheme.appColor),
//                     SizedBox(width: 15),
//                     Text(
//                       selectedDate == null
//                           ? 'Filter by date'
//                           : DateFormat('dd MMM yyyy').format(selectedDate!),
//                       style: poppinsMedium.copyWith(
//                         color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 13
//                             : 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime.now().subtract(const Duration(days: 30)),
//       initialDate: selectedDate ?? DateTime.now(),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       await Get.find<RevenueController>().getPrintReport({
//         "from": DateFormat('yyyy-MM-dd').format(selectedDate!),
//         "to": DateFormat('yyyy-MM-dd').format(selectedDate!)
//       });
//     }
//   }

//   Widget totalSale(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             color: Color(0xFFFFF9E3),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Total Sales',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.totalSales}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget todayGala(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7),
//               color: ColorTheme.roomCardBgColor),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Galla',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.todayGalla}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget totalExpense(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7), color: Colors.green[100]),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Total Expense',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.totalExpense}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),

//               // Expense Cash Drawer
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'CashDrawer',
//                     style: poppinsBold.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseCashDraw}',
//                     style: poppinsBold.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Cash
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Cash',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseCash}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Card
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Card',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseCard}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense UPI
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'UPI',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseUpi}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Store
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Store',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseStore}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Unpaid
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Unpaid',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseUnpaid}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense UPI Drawer
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'UPI Drawer',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseUpiDrawer}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Bank Transfer
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Bank Transfer',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseBankTransfer}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),

//               // Expense Others
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Others',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.expenseOthers}',
//                     style: poppinsMedium.copyWith(
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget cashCollected(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7),
//               color: Color.fromRGBO(253, 237, 237, 1)),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Cash Collected',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.totalTodaySettlement}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget openingBalance(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7), color: Color(0xFFFFF9E3)),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Opening Balance',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.totalOpeningBalance}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget closingBalance(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7), color: Colors.green[100]),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Closing Balance',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.lastDayPending}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.hintText,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget runningOrder(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             color: Color(0xFFFFF9E3),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Running Orders',
//                 style: poppinsBold.copyWith(
//                     // color: ColorTheme.hintText,
//                     fontSize: MediaQuery.of(context).size.shortestSide > 570
//                         ? 14
//                         : 13),
//               ),
//               Text(
//                 '₹${revenueController.getPrintReportResponse!.runningOrder}',
//                 style: poppinsBold.copyWith(
//                     // color: ColorTheme.hintText,
//                     fontSize: MediaQuery.of(context).size.shortestSide > 570
//                         ? 14
//                         : 13),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget totalRev(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7),
//               color: Color.fromRGBO(253, 237, 237, 1)),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Paid Revenue',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     Get.find<AuthController>()
//                                 .profileModel
//                                 ?.restaurants
//                                 ?.first
//                                 .isTotalRound ==
//                             'Yes'
//                         ? '₹${revenueController.getPrintReportResponse!.totalPaidAmount} (${revenueController.getPrintReportResponse!.orderRoundOff})'
//                         : '₹${revenueController.getPrintReportResponse!.totalPaidAmount}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 5),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Paid Cash Revenue',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.totalPaidCashRevenue}',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Cash',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.orderCash}',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Card',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.orderCard}',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'UPI',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.orderUPI}',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .payTab ==
//                   'Yes')
//                 totalTabRev(revenueController),
//               // SizedBox(height: 12),
//               if (Get.find<AuthController>()
//                           .profileModel!
//                           .restaurants!
//                           .first
//                           .showRoom ==
//                       'Yes' &&
//                   revenueController.getPrintReportResponse!.roomOrderRevenue !=
//                       null)
//                 Column(
//                   children: revenueController
//                       .getPrintReportResponse!.roomOrderRevenue!.entries
//                       .map((entry) {
//                     return Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           entry.key,
//                           style: poppinsMedium.copyWith(
//                               fontSize:
//                                   MediaQuery.of(context).size.shortestSide > 570
//                                       ? 14
//                                       : 13),
//                         ),
//                         Text(
//                           '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
//                           style: poppinsMedium.copyWith(
//                               // color: ColorTheme.green,
//                               fontSize:
//                                   MediaQuery.of(context).size.shortestSide > 570
//                                       ? 14
//                                       : 13),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//             ],
//           ),
//         ));
//   }

//   Widget totalUnPaidRev(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7),
//               color: ColorTheme.roomCardBgColor),
//           child: Column(
//             children: [
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //   children: [
//               //     Text(
//               //       'Unpaid Revenue',
//               //       style: poppinsBold.copyWith(
//               //           // color: ColorTheme.appColor,
//               //           fontSize: MediaQuery.of(context).size.shortestSide > 570
//               //               ? 14
//               //               : 13),
//               //     ),
//               //     Text(
//               //       '₹${revenueController.getPrintReportResponse.unpaidRevenue}',
//               //       style: poppinsBold.copyWith(
//               //           // color: ColorTheme.appColor,
//               //           fontSize: MediaQuery.of(context).size.shortestSide > 570
//               //               ? 14
//               //               : 13),
//               //     ),
//               //   ],
//               // ),
//               // SizedBox(height: 12),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .payTab ==
//                   'Yes')
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Credit',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                     Text(
//                       '₹${revenueController.getPrintReportResponse!.orderTAB}',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                   ],
//                 ),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .showRoom ==
//                   'Yes')
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Room',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                     Text(
//                       '₹${revenueController.getPrintReportResponse!.orderRoom}',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ));
//   }

//   Widget totalTabRev(RevenueController revenueController) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Credit Cash',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//             Text(
//               '₹${revenueController.getPrintReportResponse!.tabInCash}',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Credit Card',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//             Text(
//               '₹${revenueController.getPrintReportResponse!.tabInCard}',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Credit UPI',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//             Text(
//               '₹${revenueController.getPrintReportResponse!.tabInUpi}',
//               style: poppinsMedium.copyWith(
//                   // color: ColorTheme.green,
//                   fontSize:
//                       MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget stationRevenue(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             color: Color(0xFFFFF9E3),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Station Report',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.appColor,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.appColor,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Column(
//                 children: revenueController
//                     .getPrintReportResponse!.stationReport!.entries
//                     .map((entry) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         entry.key,
//                         style: poppinsMedium.copyWith(
//                             fontSize:
//                                 MediaQuery.of(context).size.shortestSide > 570
//                                     ? 14
//                                     : 13),
//                       ),
//                       Text(
//                         '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
//                         style: poppinsMedium.copyWith(
//                             // color: ColorTheme.green,
//                             fontSize:
//                                 MediaQuery.of(context).size.shortestSide > 570
//                                     ? 14
//                                     : 13),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget cancelOrderRevenue(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//             color: Color(0xFFFFF9E3),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Cancel Order Report',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.appColor,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '',
//                     style: poppinsBold.copyWith(
//                         // color: ColorTheme.appColor,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Column(
//                 children: revenueController
//                     .getPrintReportResponse!.cancelOrderReport!.entries
//                     .map((entry) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         entry.key,
//                         style: poppinsMedium.copyWith(
//                             fontSize:
//                                 MediaQuery.of(context).size.shortestSide > 570
//                                     ? 14
//                                     : 13),
//                       ),
//                       Text(
//                         '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
//                         style: poppinsMedium.copyWith(
//                             // color: ColorTheme.green,
//                             fontSize:
//                                 MediaQuery.of(context).size.shortestSide > 570
//                                     ? 14
//                                     : 13),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget otherCharges(RevenueController revenueController) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           margin: EdgeInsets.only(top: 10),
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(7),
//               color: Color.fromRGBO(253, 237, 237, 1)),
//           child: Column(
//             children: [
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .serviceCharge ==
//                   'Yes')
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Service Charge',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                     Text(
//                       '₹${revenueController.getPrintReportResponse!.serviceCharge}',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                   ],
//                 ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Discount',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                   Text(
//                     '₹${revenueController.getPrintReportResponse!.discount}',
//                     style: poppinsMedium.copyWith(
//                         // color: ColorTheme.green,
//                         fontSize: MediaQuery.of(context).size.shortestSide > 570
//                             ? 14
//                             : 13),
//                   ),
//                 ],
//               ),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .isShowTips ==
//                   'Yes')
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Tips',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                     Text(
//                       '₹${revenueController.getPrintReportResponse!.tips}',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                   ],
//                 ),
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .gstStatus ==
//                   'true')
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Tax',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                     Text(
//                       '₹${revenueController.getPrintReportResponse!.tax}',
//                       style: poppinsMedium.copyWith(
//                           // color: ColorTheme.green,
//                           fontSize:
//                               MediaQuery.of(context).size.shortestSide > 570
//                                   ? 14
//                                   : 13),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ));
//   }

//   Future kdsBytesConvert() async {
//     pendingTask = [];
//     List<int> bytes = [];
//     GetPrintReportResponse revenue =
//         Get.find<RevenueController>().getPrintReportResponse!;
//     final profile = await CapabilityProfile.load(name: 'XP-N160I');
//     final generator = Generator(
//         Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
//             ? PaperSize.mm58
//             : PaperSize.mm80,
//         profile);
//     bytes += generator.setGlobalCodeTable('CP1252');

//     if (logoHelper.logoUrlPrint != null) {
//       try {
//         bytes += generator.feed(1);
//         bytes += generator.image(logoHelper.logoUrlPrint!);
//       } catch (e) {
//         print(e);
//       }
//     }
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel!.restaurants![0].name!,
//         styles: PrinterConfig().titleStyle());
//     bytes += generator.text(
//         Get.find<AuthController>().profileModel!.restaurants![0].address!,
//         styles: PrinterConfig().addressStyle());
//     if (Get.find<AuthController>().profileModel!.restaurants![0].gstCode != '')
//       bytes += generator.text(
//           'GST no. ${Get.find<AuthController>().profileModel!.restaurants![0].gstCode}',
//           styles: PrinterConfig().gstStyle());
//     if (Get.find<AuthController>().profileModel!.restaurants![0].fssai != '')
//       bytes += generator.text(
//           'FSI no. ${Get.find<AuthController>().profileModel!.restaurants![0].fssai}',
//           styles: PrinterConfig().gstStyle());
//     bytes += generator.text(
//         'Date : ${DateFormat('dd MMM yyyy').format(selectedDate ?? DateTime.now())}',
//         styles: PrinterConfig().gstStyle());

//     bytes += generator.hr(ch: '--');
//     bytes += generator.row([
//       PosColumn(
//         text: 'Title',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: 'Amount',
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '--');

//     bytes += generator.row([
//       PosColumn(
//         text: 'Total Sales',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.totalSales,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '....');
//     bytes += generator.row([
//       PosColumn(
//         text: 'Paid Revenue',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.totalPaidAmount,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);

//     bytes += generator.row([
//       PosColumn(
//         text: 'Total Expense',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.totalExpense, // ye field already available hai
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
// // bytes += generator.hr(ch: '....');

//     // bytes += generator.hr(ch: '....');
//     bytes += generator.row([
//       PosColumn(
//         text: 'Cash',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.orderCash,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     // bytes += generator.hr(ch: '....');
//     bytes += generator.row([
//       PosColumn(
//         text: 'Card',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.orderCard,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     // bytes += generator.hr(ch: '....');
//     bytes += generator.row([
//       PosColumn(
//         text: 'UPI',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.orderUPI,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab !=
//         'Yes') bytes += generator.hr(ch: '....');
//     if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab ==
//         'Yes') {
//       bytes += generator.row([
//         PosColumn(
//           text: 'Credit Cash',
//           width: 8,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: revenue.tabInCash,
//           width: 4,
//           styles: PrinterConfig().foodStyle(),
//         ),
//       ]);
//       // bytes += generator.hr(ch: '....');
//       bytes += generator.row([
//         PosColumn(
//           text: 'Credit Card',
//           width: 8,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: revenue.tabInCard,
//           width: 4,
//           styles: PrinterConfig().foodStyle(),
//         ),
//       ]);
//       // bytes += generator.hr(ch: '....');
//       bytes += generator.row([
//         PosColumn(
//           text: 'Credit UPI',
//           width: 8,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: revenue.tabInUpi,
//           width: 4,
//           styles: PrinterConfig().foodStyle(),
//         ),
//       ]);
//       bytes += generator.hr(ch: '....');
//     }

//     bytes += generator.row([
//       PosColumn(
//         text: 'Unpaid Revenue',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.unpaidRevenue,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);

//     if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab ==
//         'Yes')
//       bytes += generator.row([
//         PosColumn(
//           text: 'Credit',
//           width: 8,
//           styles: PrinterConfig().foodStyle(),
//         ),
//         PosColumn(
//           text: revenue.orderTAB,
//           width: 4,
//           styles: PrinterConfig().foodStyle(),
//         ),
//       ]);
//     bytes += generator.row([
//       PosColumn(
//         text: 'Room',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.orderRoom,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '....');
//     bytes += generator.row([
//       PosColumn(
//         text: 'Running Order',
//         width: 8,
//         styles: PrinterConfig().foodStyle(),
//       ),
//       PosColumn(
//         text: revenue.runningOrder,
//         width: 4,
//         styles: PrinterConfig().foodStyle(),
//       ),
//     ]);
//     bytes += generator.hr(ch: '....');

//     // bytes += generator.hr(ch: '....');
//     bytes += generator.text('Powered by MyGenie',
//         styles: const PosStyles(
//             align: PosAlign.center,
//             height: PosTextSize.size1,
//             width: PosTextSize.size1,
//             // bold: true,
//             fontType: PosFontType.fontB));
//     bytes += generator.cut();

//     if (Platform.isAndroid) {
//       await _kdsPrintEscPos(bytes, generator); //kitchen
//     } else {
//       await _iosPrintEscPos(bytes, generator); //kitchen
//     }
//   }

//   Future<Uint8List> generateKotPdf() async {
//     ProfileModel? profileModel = Get.find<AuthController>().profileModel;
//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
//     GetPrintReportResponse? revenue =
//         Get.find<RevenueController>().getPrintReportResponse;

//     final font = await PdfGoogleFonts.poppinsMedium();
//     var netImage;
//     if (Get.find<AuthController>()
//                 .profileModel!
//                 .restaurants!
//                 .first
//                 .isShowAddressKot ==
//             'Yes' &&
//         Get.find<AuthController>().profileModel!.restaurants!.first.logoPath !=
//             '')
//       netImage = await networkImage(Get.find<AuthController>()
//           .profileModel!
//           .restaurants!
//           .first
//           .logoPath!);
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(
//             profileModel!.billPrinterPaperRoll == 58
//                 ? 48 * PdfPageFormat.mm
//                 : 72 * PdfPageFormat.mm,
//             double.infinity,
//             marginLeft: 0,
//             marginRight: 0,
//             marginTop: 0,
//             marginBottom: 0), // 58mm width
//         build: (context) {
//           return pw.Column(
//             children: [
//               if (Get.find<AuthController>()
//                       .profileModel!
//                       .restaurants!
//                       .first
//                       .isShowAddressKot ==
//                   'Yes')
//                 if (netImage != null) pw.Image(netImage),
//               pw.Text(profileModel.restaurants!.first.name!,
//                   style: pw.TextStyle(font: font, fontSize: 10)),
//               pw.Text(profileModel.restaurants!.first.address!,
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants![0].gstCode != '')
//                 pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               if (profileModel.restaurants![0].fssai != '')
//                 pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
//                     style: pw.TextStyle(font: font, fontSize: 8)),
//               pw.Text(
//                   '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Title',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Amount'.tr,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Total Sales',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue!.totalSales,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Paid Revenue',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.totalPaidAmount,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Total Expense',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.totalExpense,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
// // pw.Padding(
// //   padding: pw.EdgeInsets.symmetric(vertical: 1),
// //   child: buildDottedLine(180),
// // ),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Cash',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.orderCash,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Card',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.orderCard,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('UPI',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.orderUPI,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               if (profileModel.restaurants!.first.payTab != 'Yes')
//                 pw.Column(children: [
//                   pw.Row(children: [
//                     pw.Expanded(
//                         flex: 2,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text('Credit Cash',
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                     pw.SizedBox(width: 3),
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text(revenue.tabInCash,
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                   ]),
//                   pw.Row(children: [
//                     pw.Expanded(
//                         flex: 2,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text('Credit Card',
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                     pw.SizedBox(width: 3),
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text(revenue.tabInCard,
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                   ]),
//                   pw.Row(children: [
//                     pw.Expanded(
//                         flex: 2,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text('Credit Upi',
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                     pw.SizedBox(width: 3),
//                     pw.Expanded(
//                         flex: 1,
//                         child: pw.Align(
//                           alignment: pw.Alignment.centerLeft,
//                           child: pw.Text(revenue.tabInUpi,
//                               style: pw.TextStyle(font: font, fontSize: 8)),
//                         )),
//                   ]),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.symmetric(vertical: 1),
//                     child: buildDottedLine(180),
//                   )
//                 ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Unpaid Revenue',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.unpaidRevenue,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               if (profileModel.restaurants!.first.payTab == 'Yes')
//                 pw.Row(children: [
//                   pw.Expanded(
//                       flex: 2,
//                       child: pw.Align(
//                         alignment: pw.Alignment.centerLeft,
//                         child: pw.Text('Credit',
//                             style: pw.TextStyle(font: font, fontSize: 8)),
//                       )),
//                   pw.SizedBox(width: 3),
//                   pw.Expanded(
//                       flex: 1,
//                       child: pw.Align(
//                         alignment: pw.Alignment.centerLeft,
//                         child: pw.Text(revenue.orderTAB,
//                             style: pw.TextStyle(font: font, fontSize: 8)),
//                       )),
//                 ]),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Room',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.orderRoom,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.Row(children: [
//                 pw.Expanded(
//                     flex: 2,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text('Running Order',
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//                 pw.SizedBox(width: 3),
//                 pw.Expanded(
//                     flex: 1,
//                     child: pw.Align(
//                       alignment: pw.Alignment.centerLeft,
//                       child: pw.Text(revenue.runningOrder,
//                           style: pw.TextStyle(font: font, fontSize: 8)),
//                     )),
//               ]),
//               pw.Padding(
//                 padding: pw.EdgeInsets.symmetric(vertical: 1),
//                 child: buildDottedLine(180),
//               ),
//               pw.SizedBox(height: 10),
//               pw.Text('Powered by MyGenie',
//                   style: pw.TextStyle(font: font, fontSize: 8)),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   /// print ticket
//   Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
//     // await printerManager.disconnect(type: PrinterType.bluetooth);
//     BluetoothPrinter bluetoothPrinter = await BluetoothPrinter(
//         // address: 'DC:0D:30:20:3C:D5');
//         address: Get.find<AuthController>().profileModel!.billPrinterIp,
//         deviceName: Get.find<AuthController>()
//             .profileModel!
//             .billPrinterName!); // ip was mandadory
//     await printerManager.connect(
//       type: bluetoothPrinter.typePrinter,
//       model: BluetoothPrinterInput(
//         name: bluetoothPrinter.deviceName,
//         address: bluetoothPrinter.address!,
//       ),
//     );
//     switch (bluetoothPrinter.typePrinter) {
//       case PrinterType.usb:
//         bytes += generator.feed(2);
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
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: BluetoothPrinterInput(
//             name: bluetoothPrinter.deviceName,
//             address: bluetoothPrinter.address!,
//             isBle: bluetoothPrinter.isBle ?? false,
//           ),
//         );
//         pendingTask = null;
//         if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
//         break;
//       case PrinterType.network:
//         bytes += generator.feed(2);
//         await printerManager.connect(
//           type: bluetoothPrinter.typePrinter,
//           model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
//         );
//         break;
//       default:
//     }
//     if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
//       try {
//         await printerManager.send(
//             type: bluetoothPrinter.typePrinter, bytes: bytes);
//         pendingTask = null;
//         Future.delayed(Duration(seconds: 11), () async {
//           Get.find<LoadingController>().startLoading(false);
//           await Get.find<LoadingController>()
//               .changeText(data: 'Successfully printed!!');
//           await Get.find<LoadingController>().changeStatus(data: true);
//           await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
//         });
//       } catch (e) {}
//     } else {
//       printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
//     }
//   }

//   Future _iosPrintEscPos(List<int> bytes, Generator generator) async {
//     bytes += generator.feed(2);
//     await PrintBluetoothThermal.pairedBluetooths;

//     // Future.delayed(Duration(seconds: 5), () async {
//     final bool result = await PrintBluetoothThermal.connect(
//         macPrinterAddress:
//             Get.find<AuthController>().profileModel!.macBillPrinterIp!);

//     Future.delayed(Duration(seconds: 1), () async {
//       if (result) {
//         // List<int> ticket = await testTicket();
//         await PrintBluetoothThermal.writeBytes(bytes);

//         Future.delayed(Duration(seconds: 11), () async {
//           Get.find<LoadingController>().startLoading(false);

//           await Get.find<LoadingController>()
//               .changeText(data: 'Successfully printed!!');
//           await Get.find<LoadingController>().changeStatus(data: true);
//           var isDisconnect = await PrintBluetoothThermal.disconnect;
//           print('is disconnect $isDisconnect');
//         });
//         print("print test result:  $result");
//       } else {
//         //no conectado, reconecte
//         Get.find<LoadingController>().startLoading(false);

//         await Get.find<LoadingController>()
//             .changeText(data: 'Failed to bluetooth connect!!', error: true);
//         await Get.find<LoadingController>().changeStatus(data: true);
//         // showErrorToast('Failed to bluetooth connect');
//       }
//       // });
//     });
//     // });
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_room_orders_model.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/room_orders.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/cancel_order/cancel_order.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/customer_report.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/view/customer_designation_master.dart';
import 'package:mygenie_restaurant/view/screens/customer_management/customer_management.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_report.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/stock_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/unit_price_master.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/daily_consumption_report.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_inventory.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_master.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/wastage_report.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/cancellation%20reason/cancellation_master.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/prep_serve_time_report/perp_serve_time_report.dart';
import 'package:mygenie_restaurant/view/screens/online_unpaid_order/online_unpaid_order.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/cancel_order_wise_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_sales_details_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/item_wise_addon_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/item_wise_variation_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/order_audit_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/order_wise_logs.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/profit_loss_report.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/aggregator_setup/aggregator_setup.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/coupon.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/coupon_report.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/delivery_management/delivery_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/resturant_setting/resturant_setting.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/printer_management.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/table_management/table_management_screen.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:mygenie_restaurant/view/screens/swiggy_zomato/date_wise_orderlist.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_orders.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_report.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/revenue_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_print_report_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';

class PrintReport extends StatefulWidget {
  final bool isadmin;
  PrintReport({super.key, this.isadmin = false});
  @override
  State<PrintReport> createState() => _PrintReportState();
}

class _PrintReportState extends State<PrintReport> {
  DateTime? selectedDate;
  final PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<BTStatus>? _singleSplitBleStatus;
  List<int>? pendingTask;
  BTStatus currentStatus = BTStatus.none;
  PackageInfo? packageInfo;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        log(' -----------------print report status bt $status ------------------ ');

        currentStatus = status;
        if (status == BTStatus.connected) {
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              PrinterManager.instance
                  .send(type: PrinterType.bluetooth, bytes: pendingTask!);
              Future.delayed(Duration(seconds: 11), () async {
                await PrinterManager.instance
                    .disconnect(type: PrinterType.bluetooth);
              });
              pendingTask = null;
            });
          } else if (Platform.isIOS) {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          }
        } else if (status == BTStatus.none) {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Failed to bluetooth connect!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      });
    }
    initData();
  }

  initData() async {
    await Get.find<RevenueController>().getPrintReport({
      "from": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "to": DateFormat('yyyy-MM-dd').format(DateTime.now())
    });
  }

  TextEditingController searchTable = TextEditingController();
  @override
  void dispose() {
    _subscriptionBtStatus?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: widget.isadmin
            ? Padding(
                padding:
                    const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                child: IconButton(
                  icon:
                      SizedBox(width: 20, child: Image.asset(Images.ham_menu)),
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
              )
            : IconButton(
                icon: Icon(Icons.chevron_left_outlined,
                    color: ColorTheme.green, size: 36),
                color: ColorTheme.appColor,
                onPressed: () {
                  Navigator.pop(context);
                }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.13,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      drawer: widget.isadmin
          ? Drawer(
              backgroundColor: const Color(0xFFF8F8F8),
              child: SafeArea(
                child: ListView(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 15),
                        child: Image.asset(
                          Images.brand_logo,
                          height: Get.height * 0.1,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 7),
                        child: Text(
                          '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('bill') &&
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .showRoom ==
                            'Yes')
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          expandedAlignment: Alignment.centerLeft,
                          initiallyExpanded: true,
                          iconColor: ColorTheme.hintText,
                          title: Text(
                            'Rooms',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                await _subscriptionBtStatus?.cancel();
                                await _singleSplitBleStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                var data = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => CheckIn()));
                                if (data != null && data) {
                                  Get.find<KdsController>().setSubMenuIndex(2);
                                }
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Check In',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .settelmentReport ==
                        'Yes')
                      Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                              iconColor: ColorTheme.hintText,
                              initiallyExpanded: true,
                              expandedAlignment: Alignment.centerLeft,
                              title: Text(
                                'Day Closing',
                                style: poppinsMedium.copyWith(
                                    fontSize: 14, color: ColorTheme.hintText),
                              ),
                              children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    scaffoldKey.currentState!.closeDrawer();
                                    // _subscriptionBtStatus!.cancel();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                SettlementScreen()));
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 0),
                                      child: Text(
                                        'Settlement',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 13,
                                            color: ColorTheme.hintText),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    lineThickness: 1.0,
                                    dashLength: 2.5,
                                    dashColor: ColorTheme.hintText,
                                  ),
                                ),
                              ])),
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('report'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          dense: false,
                          minTileHeight: 10,
                          childrenPadding: EdgeInsets.only(left: 5),
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Report',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            // Sales Report
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                dense: false,
                                minTileHeight: 10,
                                childrenPadding: EdgeInsets.only(left: 8),
                                iconColor: ColorTheme.hintText,
                                initiallyExpanded: false,
                                expandedAlignment: Alignment.centerLeft,
                                title: Text(
                                  'Sales Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: ColorTheme.hintText),
                                ),
                                children: <Widget>[
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .settelmentReport ==
                                      'Yes')
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    SettlementDayWiseReport()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Closing Report', //Settlement Report
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .settelmentReport ==
                                      'Yes')
                                    10.height,
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      scaffoldKey.currentState?.closeDrawer();
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  PrintReport()));
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 0),
                                        child: Text(
                                          'Daily report ( summary )',
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        final date =
                                            DateTime.now(); // Current Date
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    DailySalesDetailsReport(
                                                      date:
                                                          DateFormat('d-M-yyyy')
                                                              .format(date),
                                                    )));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Daily Report ( order wise )',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        final date =
                                            DateTime.now(); // Current Date
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    CancelOrderWiseReportScreen()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Cancel Report ( order wise )',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    ReportSummeryPage()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Report Summary',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    ItemWiseVariationReport()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Variation Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report_summery'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    ItemWiseAddonReport()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Addon Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('waiter_revenue_report'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('waiter_revenue_report'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();
                                        // if (Get.find<AuthController>()
                                        //     .profileModel!
                                        //     .role!
                                        //     .contains('waiter_revenue_report'))
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    DailyWaiterSalesDetailsReport()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Report Summary(W)',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 15, left: 15),
                                  //   child: DottedLine(
                                  //     direction: Axis.horizontal,
                                  //     alignment: WrapAlignment.center,
                                  //     lineThickness: 1.0,
                                  //     dashLength: 2.5,
                                  //     dashColor: ColorTheme.hintText,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                            // PLN Report
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                dense: false,
                                minTileHeight: 10,
                                childrenPadding: EdgeInsets.only(left: 8),
                                iconColor: ColorTheme.hintText,
                                initiallyExpanded: false,
                                expandedAlignment: Alignment.centerLeft,
                                title: Text(
                                  'PLN Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: ColorTheme.hintText),
                                ),
                                children: <Widget>[
                                  // if (Get.find<AuthController>()
                                  //     .profileModel!
                                  //     .role!
                                  //     .contains('expence'))
                                  //   10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('expence'))
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    ExpenseReportScreen()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Expense Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('inventory'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('inventory'))
                                    InkWell(
                                      onTap: () async {
                                        scaffoldKey.currentState!.closeDrawer();

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        await Get.to(
                                            () => PurchaseReportScreen());
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Purchase Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  10.height,
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      scaffoldKey.currentState?.closeDrawer();

                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  DailyConsumptionReportScreen()));
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 0),
                                        child: Text(
                                          'Consumption Report',
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('wastage_report'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('wastage_report'))
                                    InkWell(
                                      onTap: () async {
                                        scaffoldKey.currentState!.closeDrawer();

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        await Get.to(
                                            () => WastageReportScreen());
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Wastage Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),

                                  10.height,
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      scaffoldKey.currentState?.closeDrawer();

                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  TabReportScreen()));
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 0),
                                        child: Text(
                                          'Credit Report',
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('pl_report'))
                                    10.height,
                                  if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('pl_report'))
                                    InkWell(
                                      onTap: () async {
                                        scaffoldKey.currentState!.closeDrawer();

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        await Get.to(() => ProfitLossReport());
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Profit Loss Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  10.height,
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      scaffoldKey.currentState?.closeDrawer();

                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  CouponReport()));
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 0),
                                        child: Text(
                                          'Coupon Usage Report',
                                          style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //Audit Report
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                  dense: false,
                                  minTileHeight: 10,
                                  childrenPadding: EdgeInsets.only(left: 8),
                                  iconColor: ColorTheme.hintText,
                                  initiallyExpanded: false,
                                  expandedAlignment: Alignment.centerLeft,
                                  title: Text(
                                    'Audit Report',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 14,
                                        color: ColorTheme.hintText),
                                  ),
                                  children: <Widget>[
                                    // 10.height,
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    OrderAuditReportScreen()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Order Audit Report',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                    10.height,
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    OrderWiseLogsScreen()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Order Logs',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),

                                    10.height,
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        scaffoldKey.currentState?.closeDrawer();

                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    PrepServeTimeReportScreen()));
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 0),
                                          child: Text(
                                            'Prepration & Serve Time',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'Orders',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState?.closeDrawer();
                              _subscriptionBtStatus?.cancel();
                              FocusManager.instance.primaryFocus?.unfocus();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => ViewPaidOrders()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Completed Paid Orders',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CancelledOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Cancelled Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          10.height,

                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState?.closeDrawer();
                              _subscriptionBtStatus?.cancel();
                              FocusManager.instance.primaryFocus?.unfocus();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          OnlineUnpaidOrder()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Online Unpaid Orders',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),

                          // InkWell(
                          //   onTap: () async {
                          //     scaffoldKey.currentState?.closeDrawer();
                          //     _subscriptionBtStatus??.cancel();
                          //     FocusManager.instance.primaryFocus?.unfocus();

                          //     await Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (builder) => ChangePaymentViewOrders()));
                          //   },
                          //   child: Align(
                          //     alignment: Alignment.centerLeft,
                          //     child: Padding(
                          //         padding: const EdgeInsets.only(left: 15, top: 15),
                          //       child: Text(
                          //         'Change Payment Method',
                          //         style: poppinsMedium.copyWith(
                          //             fontSize: 13, color: ColorTheme.hintText),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .showRoom ==
                              'Yes')
                            10.height,

                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .showRoom ==
                              'Yes')
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => RoomOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Room Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),

                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('aggregator'))
                            10.height,

                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('aggregator'))
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            DateWiseSwiggyOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Completed Aggregator Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .payTab ==
                              'Yes')
                            10.height,
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .payTab ==
                              'Yes')
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => TabOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Credit Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('bill') &&
                              Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payTab ==
                                  'Yes')
                            10.height,
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('bill') &&
                              Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .payTab ==
                                  'Yes')
                            InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();

                                scaffoldKey.currentState?.closeDrawer();
                                _subscriptionBtStatus?.cancel();
                                Get.toNamed(
                                    RouteHelper.getTapManagementRoute());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Credit Management',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15),
                            child: DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //customer management
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'Customer Data',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              scaffoldKey.currentState?.closeDrawer();

                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          CustomerReportScreen()));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 0),
                                child: Text(
                                  'Customer Report',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('customer_management'))
                            10.height,
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('customer_management'))
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CustomerManagement()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Wallet Management', //'Customer Management'
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('Loyalty'))
                            10.height,
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('Loyalty'))
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            LoyaltyProgramScreen()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Loyalty Management',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('coupon'))
                            10.height,
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('coupon'))
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CouponManagementScreen()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Coupon Management',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('customer_management'))
                            10.height,
                          if (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('customer_management'))
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            CustomerDesignationMasterScreen()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Additional Fields', //'Customer Designation'
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15),
                            child: DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Employee Management
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('employee'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Employee Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            EmployeeMgmtScreen()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Employee Management',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('menu'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Menu Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => CategoriesScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Category',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => AddonsScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Addons',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();
                                Get.find<ExpenseManagementController>()
                                    .tabValue
                                    .value = 0;
                                await Get.to(() => MenuHomeScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Menu Items',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => CancellationMasterScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Cancellation Reason',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('expence'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Expense Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();
                                Get.find<ExpenseManagementController>()
                                    .tabValue
                                    .value = 0;
                                await Get.to(() => ExpenseManagementScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Add Expenses',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();
                                // Get.find<ExpenseManagementController>().tabValue.value =
                                //     1;

                                // await Get.to(() => ExpenseManagementScreen());

                                Get.to(() => ExpenseStockScreen(
                                      expenseController: Get.find<
                                          ExpenseManagementController>(),
                                      masterList: Get.find<
                                                  ExpenseManagementController>()
                                              .masterList ??
                                          [],
                                      categoryList: Get.find<
                                                  ExpenseManagementController>()
                                              .categoryList ??
                                          [],
                                    ));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Expense List',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();
                                // Get.find<ExpenseManagementController>().tabValue.value =
                                //     1;

                                // await Get.to(() => ExpenseManagementScreen());

                                Get.to(() => UnitPriceMasterScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Unit Price Master',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (Get.find<AuthController>()
                        .profileModel!
                        .role!
                        .contains('inventory'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Inventory Management',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => CurrentStocksScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Add Stock( Purchase )',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => AddIngredientsScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Ingredients',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            // 15.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => ManageVendor());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Vendor',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,

                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => RecipesListScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Recipes',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => WastageMasterScreen());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Wastage Reason',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState!.closeDrawer();

                                FocusManager.instance.primaryFocus?.unfocus();

                                await Get.to(() => ManageInventory());
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Manage Inventory( on /off )',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('coupon') ||
                        Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('Loyalty') ||
                        Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('restaurant_settings'))
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Resturant Configuration',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('restaurant_settings'))
                              InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  scaffoldKey.currentState?.closeDrawer();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              RestaurantSettingsScreen()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: Text(
                                      'Resturant Setting',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('delivery_management'))
                              10.height,
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('delivery_management'))
                              InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  scaffoldKey.currentState?.closeDrawer();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              DeliverySettingsScreen()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: Text(
                                      'Delivery Management',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('printer_management'))
                              10.height,
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('printer_management'))
                              InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  scaffoldKey.currentState?.closeDrawer();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              PrinterManagementScreen()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: Text(
                                      'Printer Management',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('table_management'))
                              10.height,
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('table_management'))
                              InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  scaffoldKey.currentState?.closeDrawer();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              TableManagementScreen()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: Text(
                                      'Table Management',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            10.height,
                            InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            const AggregatorSetupScreen()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Aggregator Setup',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'My Profile',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              scaffoldKey.currentState?.closeDrawer();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          EmployeeResetPassword(
                                            resetToken:
                                                Get.find<AuthController>()
                                                    .getUserToken(),
                                            email: Get.find<AuthController>()
                                                .profileModel!
                                                .empEmail!,
                                            image: Images.ic_kds_app_logo,
                                            password: '',
                                            fromPasswordChange: true,
                                          ))));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, top: GetPlatform.isIOS ? 10 : 0),
                                child: Text(
                                  'Reset Password',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              scaffoldKey.currentState?.closeDrawer();

                              if (Get.find<AuthController>().isAdminSession) {
                                Get.bottomSheet(
                                  ConfirmationDialog(
                                      icon: Images.support,
                                      description:
                                          'You will be redirected to MyGenie Admin Dashboard',
                                      title: 'Logout from Restaurant',
                                      isLogOut: true,
                                      onYesPressed: () async {
                                        try {
                                          Response response =
                                              await Get.find<AuthController>()
                                                  .logout();
                                          if (response.statusCode == 200) {
                                            Get.find<RestaurantController>()
                                                .clearProductList();
                                            Get.find<AuthController>()
                                                .clearSharedData();
                                            // Get.offAllNamed(RouteHelper.getSignInRoute());

                                            await Get.find<AuthController>()
                                                .logoutFromRestaurant();
                                            Get.offAllNamed(RouteHelper
                                                .getAdminDashboardRoute());

                                            showCustomSnackBar(
                                                'Logged out from restaurant successfully',
                                                isError: false);
                                          }
                                        } catch (e) {}
                                      }),
                                );
                              } else {
                                Get.bottomSheet(ConfirmationDialog(
                                    icon: Images.support,
                                    description:
                                        'Are you sure you want to log out from My Genie?',
                                    isLogOut: true,
                                    onYesPressed: () async {
                                      try {
                                        Response response =
                                            await Get.find<AuthController>()
                                                .logout();
                                        if (response.statusCode == 200) {
                                          Get.find<RestaurantController>()
                                              .clearProductList();
                                          Get.find<AuthController>()
                                              .clearSharedData();
                                          Get.offAllNamed(
                                              RouteHelper.getSignInRoute());
                                        }
                                      } catch (e) {}
                                    }));
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  'Logout',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text(
                          'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
                        style: poppinsMedium.copyWith(
                            fontSize: 10, color: Colors.grey),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: GetBuilder<RevenueController>(builder: (revenueController) {
        return revenueController.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  SizedBox(height: 5),
                  filterbyDateRow(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFE6E6E6)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Print Report',
                        style: poppinsMedium.copyWith(
                            color: ColorTheme.hintText, fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd MMM yyyy')
                            .format(selectedDate ?? DateTime.now()),
                        style: poppinsSemiBold.copyWith(
                            color: ColorTheme.appColor, fontSize: 14),
                      ),
                    ),
                  ),
                  if (_isSettleReport)
                    balanceSummaryBox(revenueController),
                  if (_isShowRoom) salesSectionBox(revenueController),
                  foodSalesSectionBox(revenueController),
                  if (_isPayTab) creditSectionBox(revenueController),
                  if (_isShowRoom) roomSalesSectionBox(revenueController),
                  if (_isExpenseRole) totalExpense(revenueController),
                  if (_isAggregatorRole)
                    aggregatorRevenue(revenueController),
                  otherCharges(revenueController),
                  stationRevenue(revenueController),
                  cancelOrderRevenue(revenueController),

                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: () async {
                        if (GetPlatform.isWindows) {
                          final printers = await Printing.listPrinters();
                          for (var element in printers) {
                            if (element.isAvailable &&
                                (element.name.toLowerCase() ==
                                    Get.find<AuthController>()
                                        .profileModel!
                                        .wifiBillPrinterName!
                                        .toLowerCase())) {
                              await Printing.directPrintPdf(
                                  printer: element,
                                  onLayout: (_) => generateKotPdf());
                              break;
                            }
                          }
                        } else {
                          showToast('Please wait..');
                          Get.find<LoadingController>().startLoading(true);
                          kdsBytesConvert();
                        }
                      },
                      child: SvgPicture.asset(
                        Images.ic_print_kot,
                        height: MediaQuery.of(context).size.shortestSide > 570
                            ? 37
                            : 26,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ]),
              );
      }),
    );
  }

  Widget filterbyDateRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                height:
                    MediaQuery.of(context).size.shortestSide > 570 ? 55 : 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: ColorTheme.appColor),
                    SizedBox(width: 15),
                    Text(
                      selectedDate == null
                          ? 'Filter by date'
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      style: poppinsMedium.copyWith(
                        color: ColorTheme.hintText,
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 13
                            : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2023),
      initialDate: selectedDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await Get.find<RevenueController>().getPrintReport({
        "from": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "to": DateFormat('yyyy-MM-dd').format(selectedDate!)
      });
    }
  }

  DailyReportSummary? get _reportSummary =>
      Get.find<RevenueController>().getPrintReportResponse?.reportSummary;

  bool get _isSettleReport =>
      Get.find<AuthController>().profileModel?.role?.contains('sattle_report') ??
      false;

  bool get _isExpenseRole =>
      Get.find<AuthController>().profileModel?.role?.contains('expence') ??
      false;

  bool get _isAggregatorRole =>
      Get.find<AuthController>().profileModel?.role?.contains('aggregator') ??
      false;

  bool get _isShowRoom =>
      Get.find<AuthController>().profileModel?.restaurants?.first.showRoom ==
      'Yes';

  bool get _isPayTab =>
      Get.find<AuthController>().profileModel?.restaurants?.first.payTab ==
      'Yes';

  double get _reportFontSize =>
      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13;

  Widget _reportCard({required Color color, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: color,
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _reportRow(String label, String value,
      {bool bold = false, bool indent = false, bool money = true}) {
    final style = (bold ? poppinsBold : poppinsMedium)
        .copyWith(fontSize: _reportFontSize);
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(money ? '₹$value' : value, style: style),
        ],
      ),
    );
  }

  String _breakdownLabel(String key) {
    if (key.contains('-') || key.contains(' ')) return key;
    return key.split('_').map((part) {
      final lower = part.toLowerCase();
      if (lower == 'upi') return 'UPI';
      if (part.isEmpty) return part;
      return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
    }).join(' ');
  }

  List<Widget> _breakdownRows(Map<String, String> breakdown) {
    return breakdown.entries
        .map((entry) =>
            _reportRow(_breakdownLabel(entry.key), entry.value, indent: true))
        .toList();
  }

  Widget balanceSummaryBox(RevenueController revenueController) {
    final balance = _reportSummary?.balanceSummary ?? BalanceSummary();
    return _reportCard(
      color: Colors.green[100]!,
      children: [
        // _reportRow('BALANCE SUMMARY', '', bold: true, money: false),
        _reportRow('Opening Balance', balance.openingBalance, bold: true),
        _reportRow('Paid Cash Revenue', balance.paidCashRevenue, bold: true),
        _reportRow('Total Purchase', balance.totalPurchase, bold: true),
        _reportRow('Total Expense', balance.totalExpense, bold: true),
        _reportRow('Current Balance (Galla)', balance.currentBalanceGalla,
            bold: true),
        _reportRow('Cash Collected', balance.cashCollected, bold: true),
        _reportRow('Total Pilferage', balance.totalPilferage, bold: true),
        _reportRow('Closing Balance', balance.closingBalance, bold: true),
        _reportRow('Total Profit/Loss', balance.totalProfitLoss, bold: true),
      ],
    );
  }

  Widget salesSectionBox(RevenueController revenueController) {
    final sales = _reportSummary?.salesRevenueSummary?.sales ?? SalesSection();
    return _reportCard(
      color: const Color.fromRGBO(253, 237, 237, 1),
      children: [
        _reportRow('Total Sales', sales.totalSales, bold: true),
        _reportRow('Total Paid Revenue', sales.totalPaidRevenue, bold: true),
        _reportRow('Paid Cash Revenue', sales.paidCashRevenue, bold: true),
        ..._breakdownRows(sales.breakdown),
      ],
    );
  }

  Widget foodSalesSectionBox(RevenueController revenueController) {
    final food =
        _reportSummary?.salesRevenueSummary?.foodSales ?? FoodSalesSection();
    return _reportCard(
      color: const Color.fromRGBO(253, 237, 237, 1),
      children: [
        _reportRow('Food Sales', food.foodSales, bold: true),
        _reportRow('Food Paid Revenue', food.foodPaidRevenue, bold: true),
        _reportRow('Food Paid Cash Revenue', food.foodPaidCashRevenue,
            bold: true),
        ..._breakdownRows(food.breakdown),
        if (food.roomCash != null)
          _reportRow('Room Cash', food.roomCash!, indent: true),
        if (food.roomCard != null)
          _reportRow('Room Card', food.roomCard!, indent: true),
        if (food.roomUpi != null)
          _reportRow('Room UPI', food.roomUpi!, indent: true),
        _reportRow('Running Orders', food.runningOrders,
            bold: true, money: false),
      ],
    );
  }

  Widget creditSectionBox(RevenueController revenueController) {
    final credit =
        _reportSummary?.salesRevenueSummary?.credit ?? CreditSection();
    return _reportCard(
      color: ColorTheme.roomCardBgColor,
      children: [
        _reportRow('Credit', credit.credit, bold: true),
        _reportRow('Credit Paid Revenue', credit.creditPaidRevenue, bold: true),
        ..._breakdownRows(credit.breakdown),
      ],
    );
  }

  Widget roomSalesSectionBox(RevenueController revenueController) {
    final room =
        _reportSummary?.salesRevenueSummary?.roomSales ?? RoomSalesSection();
    return _reportCard(
      color: ColorTheme.roomCardBgColor,
      children: [
        _reportRow('Room Sales', room.roomSales, bold: true),
        _reportRow('Room Paid Revenue', room.roomPaidRevenue, bold: true),
        ..._breakdownRows(room.breakdown),
        _reportRow('Advance Amount', room.advanceAmount, bold: true),
        _reportRow('Checkout Paid Revenue', room.checkoutPaidRevenue, bold: true),
        _reportRow('Running Rooms', room.runningRooms,
            bold: true, money: false),
      ],
    );
  }

  Widget _unusedLegacyBalanceStart() {
    return const SizedBox.shrink();
  }

  Widget _unusedLegacyBalanceTail(RevenueController revenueController) {
    return Column(
      children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid Cash Revenue',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalPaidCashRevenue}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Purchase',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalPurchase}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expense',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalExpense}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),

              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Balance (Galla)',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.todayGalla}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),

              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cash Collected',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalTodaySettlement}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pilferage',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse?.totalPilferage}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Closing Balance',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.lastDayPending}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Profit/Loss',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalProfitLoss}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              // ],
            ],
    );
  }

  // 2. Merged Total Sales and Paid Revenue Box
  Widget mergedSalesAndRevenueBox(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Color.fromRGBO(253, 237, 237, 1)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Sales',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalSales}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid Revenue',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    Get.find<AuthController>()
                                .profileModel
                                ?.restaurants
                                ?.first
                                .isTotalRound ==
                            'Yes'
                        ? '₹${revenueController.getPrintReportResponse!.totalPaidAmount} (${revenueController.getPrintReportResponse!.orderRoundOff})'
                        : '₹${revenueController.getPrintReportResponse!.totalPaidAmount}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid Cash Revenue',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalPaidCashRevenue}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Cash',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //     Text(
              //       '₹${revenueController.getPrintReportResponse!.orderCash}',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Card',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //     Text(
              //       '₹${revenueController.getPrintReportResponse!.orderCard}',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'UPI',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //     Text(
              //       '₹${revenueController.getPrintReportResponse!.orderUPI}',
              //       style: poppinsMedium.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //   ],
              // ),
              totalPaidRevBox(revenueController),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .payTab ==
                  'Yes')
                totalTabRev(revenueController),
              if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .showRoom ==
                      'Yes' &&
                  revenueController.getPrintReportResponse!.roomOrderRevenue !=
                      null)
                Column(
                  children: revenueController
                      .getPrintReportResponse!.roomOrderRevenue!.entries
                      .map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 14
                                      : 13),
                        ),
                        Text(
                          '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                          style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 14
                                      : 13),
                        ),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ));
  }

  Widget totalTabRev(RevenueController revenueController) {
    return (revenueController.getPrintReportResponse!.paidRevenuePaymenetMode !=
                null &&
            revenueController.getPrintReportResponse!.paidRevenuePaymenetMode!
                .containsKey('tab_payment'))
        ? Column(
            children: revenueController.getPrintReportResponse!
                .paidRevenuePaymenetMode!['tab_payment'].entries
                .map<Widget>((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              );
            }).toList(),
          )
        : SizedBox.shrink();

    // Column(
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit Cash',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInCash}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit Card',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInCard}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit UPI',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInUpi}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  Widget totalPaidRevBox(RevenueController revenueController) {
    return (revenueController.getPrintReportResponse!.paidRevenuePaymenetMode !=
                null &&
            revenueController.getPrintReportResponse!.paidRevenuePaymenetMode!
                .containsKey('order_payment'))
        ? Column(
            children: revenueController.getPrintReportResponse!
                .paidRevenuePaymenetMode!['order_payment'].entries
                .map<Widget>((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              );
            }).toList(),
          )
        : SizedBox.shrink();

    // Column(
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit Cash',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInCash}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit Card',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInCard}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           'Credit UPI',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //         Text(
    //           '₹${revenueController.getPrintReportResponse!.tabInUpi}',
    //           style: poppinsMedium.copyWith(
    //               fontSize:
    //                   MediaQuery.of(context).size.shortestSide > 570 ? 14 : 13),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }

  Widget totalExpense(RevenueController revenueController) {
    final expense = _reportSummary?.totalPurchaseAndExpense ??
        TotalPurchaseAndExpenseSummary();
    return _reportCard(
      color: Colors.green[100]!,
      children: [
        // _reportRow('TOTAL EXPENSE & PURCHASE', '', bold: true, money: false),
        _reportRow('Total Expense & Purchase', expense.totalPurchaseAndExpense,
            bold: true),
        _reportRow('CashDrawer', expense.cashDrawer, bold: true),
        _reportRow('Cash', expense.cash, indent: true),
        _reportRow('Card', expense.card, indent: true),
        _reportRow('UPI', expense.upi, indent: true),
        _reportRow('Store', expense.store, indent: true),
        _reportRow('Unpaid', expense.unpaid, indent: true),
        _reportRow('UPI Drawer', expense.upiDrawer, indent: true),
        _reportRow('Bank Transfer', expense.bankTransfer, indent: true),
        _reportRow('Others', expense.others, indent: true),
      ],
    );
  }

  Widget _legacyTotalExpense(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7), color: Colors.green[100]),
          child: Column(
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Total Expense',
              //       style: poppinsBold.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //     Text(
              //       '₹${revenueController.getPrintReportResponse!.totalExpense}',
              //       style: poppinsBold.copyWith(
              //           fontSize: MediaQuery.of(context).size.shortestSide > 570
              //               ? 14
              //               : 13),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expense & Purchase',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.totalPurchaseAndExpense}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CashDrawer',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseCashDraw}',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cash',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseCash}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseCard}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UPI',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseUpi}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Store',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseStore}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unpaid',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseUnpaid}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UPI Drawer',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseUpiDrawer}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bank Transfer',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseBankTransfer}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Others',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.expenseOthers}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget totalUnPaidRev(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: ColorTheme.roomCardBgColor),
          child: Column(
            children: [
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .payTab ==
                  'Yes')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Credit',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                    Text(
                      '₹${revenueController.getPrintReportResponse!.orderTAB}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                  ],
                ),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .showRoom ==
                  'Yes')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                    Text(
                      '₹${revenueController.getPrintReportResponse!.orderRoom}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                  ],
                ),
            ],
          ),
        ));
  }

  Widget runningOrder(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color(0xFFFFF9E3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Running Orders',
                style: poppinsBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 14
                        : 13),
              ),
              Text(
                '₹${revenueController.getPrintReportResponse!.runningOrder}',
                style: poppinsBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 14
                        : 13),
              ),
            ],
          ),
        ));
  }

  Widget stationRevenue(RevenueController revenueController) {
    final stations = _reportSummary?.stationRevenue ?? {};
    final rows = stations.isEmpty
        ? [_reportRow('OTHER', '0.00')]
        : stations.entries
            .map((entry) => _reportRow(entry.key.toUpperCase(), entry.value))
            .toList();
    return _reportCard(
      color: const Color(0xFFFFF9E3),
      children: [
        _reportRow('STATION REPORT', '', bold: true, money: false),
        ...rows,
      ],
    );
  }

  Widget _legacyStationRevenue(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color(0xFFFFF9E3),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Station Report',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Column(
                children: revenueController
                    .getPrintReportResponse!.stationReport!.entries
                    .map((entry) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                      Text(
                        '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }

  Widget aggregatorRevenue(RevenueController revenueController) {
    final aggregator = _reportSummary?.aggregatorOrder ?? {};
    return _reportCard(
      color: const Color.fromRGBO(253, 237, 237, 1),
      children: [
        _reportRow('AGGREGATOR REPORT', '', bold: true, money: false),
        _reportRow('Zomato', aggregator['zomato'] ?? '0.00', bold: false),
        _reportRow('Swiggy', aggregator['swiggy'] ?? '0.00', bold: false),
      ],
    );
  }

  Widget _legacyAggregatorRevenue(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color.fromRGBO(253, 237, 237, 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aggregator Report',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Column(
                children: revenueController
                    .getPrintReportResponse!.aggregatorOrderRevenue!.entries
                    .map((entry) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                      Text(
                        '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }

  Widget cancelOrderRevenue(RevenueController revenueController) {
    final cancel = _reportSummary?.cancelRevenue ?? {};
    return _reportCard(
      color: const Color(0xFFFFF9E3),
      children: [
        _reportRow('CANCEL REPORT', '', bold: true, money: false),
        ...cancel.entries.map((entry) =>
            _reportRow(_breakdownLabel(entry.key), entry.value)),
      ],
    );
  }

  Widget _legacyCancelOrderRevenue(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color(0xFFFFF9E3),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cancel Order Report',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '',
                    style: poppinsBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Column(
                children: revenueController
                    .getPrintReportResponse!.cancelOrderReport!.entries
                    .map((entry) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                      Text(
                        '₹${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 14
                                    : 13),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }

  Widget otherCharges(RevenueController revenueController) {
    final extra = _reportSummary?.additionalSummary ?? AdditionalSummary();
    return _reportCard(
      color: const Color.fromRGBO(253, 237, 237, 1),
      children: [
        // _reportRow('ADDITIONAL SUMMARY', '', bold: true, money: false),
        _reportRow('Service Charge', extra.serviceCharge, bold: true),
        _reportRow('Discount', extra.discount, bold: true),
        _reportRow('Tips', extra.tips, bold: true),
        _reportRow('Tax', extra.tax, bold: true),
      ],
    );
  }

  Widget _legacyOtherCharges(RevenueController revenueController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Color.fromRGBO(253, 237, 237, 1)),
          child: Column(
            children: [
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .serviceCharge ==
                  'Yes')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Charge',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                    Text(
                      '₹${revenueController.getPrintReportResponse!.serviceCharge}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                  Text(
                    '₹${revenueController.getPrintReportResponse!.discount}',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 14
                            : 13),
                  ),
                ],
              ),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .isShowTips ==
                  'Yes')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tips',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                    Text(
                      '₹${revenueController.getPrintReportResponse!.tips}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                  ],
                ),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .gstStatus ==
                  'true')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                    Text(
                      '₹${revenueController.getPrintReportResponse!.tax}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 14
                                  : 13),
                    ),
                  ],
                ),
            ],
          ),
        ));
  }

  List<int> _escPosDottedDivider(Generator generator) {
    return generator.hr(ch: '.');
  }

  List<int> _escPosAmountRow(Generator generator, String label, String value,
      {bool indent = false}) {
    return generator.row([
      PosColumn(
        text: indent ? '    $label' : label,
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: value,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
  }

  List<int> _escPosBreakdown(
      Generator generator, Map<String, String> breakdown) {
    List<int> bytes = [];
    for (final entry in breakdown.entries) {
      bytes += _escPosAmountRow(
          generator, _breakdownLabel(entry.key), entry.value,
          indent: true);
    }
    return bytes;
  }

  List<int> _dailyReportEscPosBytes(Generator generator) {
    final summary = _reportSummary;
    final sales = summary?.salesRevenueSummary?.sales ?? SalesSection();
    final food =
        summary?.salesRevenueSummary?.foodSales ?? FoodSalesSection();
    final credit = summary?.salesRevenueSummary?.credit ?? CreditSection();
    final room =
        summary?.salesRevenueSummary?.roomSales ?? RoomSalesSection();
    final balance = summary?.balanceSummary ?? BalanceSummary();
    final expense = summary?.totalPurchaseAndExpense ??
        TotalPurchaseAndExpenseSummary();
    final extra = summary?.additionalSummary ?? AdditionalSummary();
    final aggregator = summary?.aggregatorOrder ?? {};
    final stations = summary?.stationRevenue ?? {};
    final cancel = summary?.cancelRevenue ?? {};

    List<int> bytes = [];

    if (_isSettleReport) {
      bytes += _escPosDottedDivider(generator);
      bytes += _escPosAmountRow(
          generator, 'Opening Balance', balance.openingBalance);
      bytes += _escPosAmountRow(
          generator, 'Paid Cash Revenue', balance.paidCashRevenue);
      bytes +=
          _escPosAmountRow(generator, 'Total Purchase', balance.totalPurchase);
      bytes +=
          _escPosAmountRow(generator, 'Total Expense', balance.totalExpense);
      bytes += _escPosAmountRow(
          generator, 'Current Balance (Galla)', balance.currentBalanceGalla);
      bytes +=
          _escPosAmountRow(generator, 'Cash Collected', balance.cashCollected);
      bytes += _escPosAmountRow(
          generator, 'Total Pilferage', balance.totalPilferage);
      bytes += _escPosAmountRow(
          generator, 'Closing Balance', balance.closingBalance);
      bytes += _escPosAmountRow(
          generator, 'Total Profit/Loss', balance.totalProfitLoss);
    }

    if (_isShowRoom) {
      bytes += _escPosDottedDivider(generator);
      bytes += _escPosAmountRow(generator, 'Total Sales', sales.totalSales);
      bytes += _escPosAmountRow(
          generator, 'Total Paid Revenue', sales.totalPaidRevenue);
      bytes += _escPosAmountRow(
          generator, 'Paid Cash Revenue', sales.paidCashRevenue);
      bytes += _escPosBreakdown(generator, sales.breakdown);
    }

    bytes += _escPosDottedDivider(generator);
    bytes += _escPosAmountRow(generator, 'Food Sales', food.foodSales);
    bytes +=
        _escPosAmountRow(generator, 'Food Paid Revenue', food.foodPaidRevenue);
    bytes += _escPosAmountRow(
        generator, 'Food Paid Cash Revenue', food.foodPaidCashRevenue);
    bytes += _escPosBreakdown(generator, food.breakdown);
    if (food.roomCash != null) {
      bytes += _escPosAmountRow(generator, 'Room Cash', food.roomCash!,
          indent: true);
    }
    if (food.roomCard != null) {
      bytes += _escPosAmountRow(generator, 'Room Card', food.roomCard!,
          indent: true);
    }
    if (food.roomUpi != null) {
      bytes += _escPosAmountRow(generator, 'Room UPI', food.roomUpi!,
          indent: true);
    }
    bytes +=
        _escPosAmountRow(generator, 'Running Orders', food.runningOrders);

    if (_isPayTab) {
      bytes += _escPosDottedDivider(generator);
      bytes += _escPosAmountRow(generator, 'Credit', credit.credit);
      bytes += _escPosAmountRow(
          generator, 'Credit Paid Revenue', credit.creditPaidRevenue);
      bytes += _escPosBreakdown(generator, credit.breakdown);
    }

    if (_isShowRoom) {
      bytes += _escPosDottedDivider(generator);
      bytes += _escPosAmountRow(generator, 'Room Sales', room.roomSales);
      bytes += _escPosAmountRow(
          generator, 'Room Paid Revenue', room.roomPaidRevenue);
      bytes += _escPosBreakdown(generator, room.breakdown);
      bytes +=
          _escPosAmountRow(generator, 'Advance Amount', room.advanceAmount);
      bytes += _escPosAmountRow(
          generator, 'Checkout Paid Revenue', room.checkoutPaidRevenue);
      bytes +=
          _escPosAmountRow(generator, 'Running Rooms', room.runningRooms);
    }

    if (_isExpenseRole) {
      bytes += _escPosDottedDivider(generator);
      bytes += _escPosAmountRow(generator, 'Total Expense & Purchase',
          expense.totalPurchaseAndExpense);
      bytes +=
          _escPosAmountRow(generator, 'CashDrawer', expense.cashDrawer);
      bytes +=
          _escPosAmountRow(generator, 'Cash', expense.cash, indent: true);
      bytes +=
          _escPosAmountRow(generator, 'Card', expense.card, indent: true);
      bytes +=
          _escPosAmountRow(generator, 'UPI', expense.upi, indent: true);
      bytes +=
          _escPosAmountRow(generator, 'Store', expense.store, indent: true);
      bytes +=
          _escPosAmountRow(generator, 'Unpaid', expense.unpaid, indent: true);
      bytes += _escPosAmountRow(generator, 'UPI Drawer', expense.upiDrawer,
          indent: true);
      bytes += _escPosAmountRow(
          generator, 'Bank Transfer', expense.bankTransfer,
          indent: true);
      bytes +=
          _escPosAmountRow(generator, 'Others', expense.others, indent: true);
    }

    if (_isAggregatorRole) {
      bytes += _escPosDottedDivider(generator);
      bytes +=
          _escPosAmountRow(generator, 'Zomato', aggregator['zomato'] ?? '0.00');
      bytes +=
          _escPosAmountRow(generator, 'Swiggy', aggregator['swiggy'] ?? '0.00');
    }

    bytes += _escPosDottedDivider(generator);
    bytes +=
        _escPosAmountRow(generator, 'Service Charge', extra.serviceCharge);
    bytes += _escPosAmountRow(generator, 'Discount', extra.discount);
    bytes += _escPosAmountRow(generator, 'Tips', extra.tips);
    bytes += _escPosAmountRow(generator, 'Tax', extra.tax);

    bytes += _escPosDottedDivider(generator);
    if (stations.isEmpty) {
      bytes += _escPosAmountRow(generator, 'OTHER', '0.00');
    } else {
      stations.forEach((key, value) {
        bytes += _escPosAmountRow(generator, key.toUpperCase(), value);
      });
    }

    bytes += _escPosDottedDivider(generator);
    bytes += _escPosBreakdown(generator, cancel);

    return bytes;
  }

  //This is for android/ios print
  Future kdsBytesConvert() async {
    pendingTask = [];
    List<int> bytes = [];
    GetPrintReportResponse revenue =
        Get.find<RevenueController>().getPrintReportResponse!;
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
            ? PaperSize.mm58
            : PaperSize.mm80,
        profile);
    bytes += generator.setGlobalCodeTable('CP1252');

    if (logoHelper.logoUrlPrint != null) {
      try {
        bytes += generator.feed(1);
        bytes += generator.image(logoHelper.logoUrlPrint!);
      } catch (e) {
        print(e);
      }
    }
    bytes += generator.text(
        Get.find<AuthController>().profileModel!.restaurants![0].name!,
        styles: PrinterConfig().titleStyle());
    bytes += generator.text(
        Get.find<AuthController>().profileModel!.restaurants![0].address!,
        styles: PrinterConfig().addressStyle());
    if (Get.find<AuthController>().profileModel!.restaurants![0].gstCode != '')
      bytes += generator.text(
          'GST no. ${Get.find<AuthController>().profileModel!.restaurants![0].gstCode}',
          styles: PrinterConfig().gstStyle());
    if (Get.find<AuthController>().profileModel!.restaurants![0].fssai != '')
      bytes += generator.text(
          'FSI no. ${Get.find<AuthController>().profileModel!.restaurants![0].fssai}',
          styles: PrinterConfig().gstStyle());
    bytes += generator.text(
        'Date : ${DateFormat('dd MMM yyyy').format(selectedDate ?? DateTime.now())}',
        styles: PrinterConfig().gstStyle());

    bytes += _dailyReportEscPosBytes(generator);
    if (false) {
    bytes += generator.hr(ch: '--');
    bytes += generator.row([
      PosColumn(
        text: 'Title',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: 'Amount',
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '--');

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total Sales',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.totalSales,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);
    // bytes += generator.hr(ch: '....');
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Paid Revenue',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.totalPaidAmount,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);
    // 2. Balance Section (if permission available)

    bytes += generator.row([
      PosColumn(
        text: 'Opening Balance',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalOpeningBalance,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Paid Cash Revenue',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPaidCashRevenue,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Purchase',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPurchase,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Expense',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalExpense,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Galla',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.todayGalla,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Cash Collected',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalTodaySettlement,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Pilferage',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPilferage,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Closing Balance',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.lastDayPending,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Profit/Loss',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalProfitLoss,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    bytes += generator.hr(ch: '....');

    bytes += generator.row([
      PosColumn(
        text: 'Total Sales',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalSales,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '....');
    bytes += generator.row([
      PosColumn(
        text: 'Paid Revenue',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPaidAmount,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    // // 3. Total Paid Revenue
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total Paid Revenue',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.totalPaidAmount,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);

    // 4. Total Cash Paid Revenue
    bytes += generator.row([
      PosColumn(
        text: 'Cash Paid Revenue',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPaidCashRevenue,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Cash',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.orderCash,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Card',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.orderCard,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'UPI',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.orderUPI,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '....');

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Cash',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.orderCash,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Card',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.orderCard,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'UPI',
    //     width: 8,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: revenue.orderUPI,
    //     width: 4,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    // ]);

    if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab !=
        'Yes') bytes += generator.hr(ch: '....');
    if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab ==
        'Yes') {
      bytes += generator.row([
        PosColumn(
          text: 'Credit Cash',
          width: 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: revenue.tabInCash,
          width: 4,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Credit Card',
          width: 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: revenue.tabInCard,
          width: 4,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Credit UPI',
          width: 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: revenue.tabInUpi,
          width: 4,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);
      bytes += generator.hr(ch: '....');
    }

    bytes += generator.row([
      PosColumn(
        text: 'Total Expense & Purchase',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.totalPurchaseAndExpense,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    // 7. Expense Cash Drawer
    bytes += generator.row([
      PosColumn(
        text: 'Expense CashDrawer',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.expenseCashDraw,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '....');

    bytes += generator.row([
      PosColumn(
        text: 'Unpaid Revenue',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.unpaidRevenue,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);

    if (Get.find<AuthController>().profileModel!.restaurants!.first.payTab ==
        'Yes')
      bytes += generator.row([
        PosColumn(
          text: 'Credit',
          width: 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: revenue.orderTAB,
          width: 4,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);
    bytes += generator.row([
      PosColumn(
        text: 'Room',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.orderRoom,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '....');
    bytes += generator.row([
      PosColumn(
        text: 'Running Order',
        width: 8,
        styles: PrinterConfig().foodStyle(),
      ),
      PosColumn(
        text: revenue.runningOrder,
        width: 4,
        styles: PrinterConfig().foodStyle(),
      ),
    ]);
    bytes += generator.hr(ch: '....');
    }

    bytes += generator.text('Powered by MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            fontType: PosFontType.fontB));
    bytes += generator.cut();

    if (Platform.isAndroid) {
      await _kdsPrintEscPos(bytes, generator);
    } else {
      await _iosPrintEscPos(bytes, generator);
    }
  }

  // Future<Uint8List> generateKotPdf() async {
  //   ProfileModel? profileModel = Get.find<AuthController>().profileModel;
  //   final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  //   GetPrintReportResponse? revenue =
  //       Get.find<RevenueController>().getPrintReportResponse;

  //   final font = await PdfGoogleFonts.poppinsMedium();
  //   var netImage;
  //   if (Get.find<AuthController>()
  //               .profileModel!
  //               .restaurants!
  //               .first
  //               .isShowAddressKot ==
  //           'Yes' &&
  //       Get.find<AuthController>().profileModel!.restaurants!.first.logoPath !=
  //           '')
  //     netImage = await networkImage(Get.find<AuthController>()
  //         .profileModel!
  //         .restaurants!
  //         .first
  //         .logoPath!);
  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat(
  //           profileModel!.billPrinterPaperRoll == 58
  //               ? 48 * PdfPageFormat.mm
  //               : 72 * PdfPageFormat.mm,
  //           850,
  //           marginLeft: profileModel.windowsPrintConfigList?.first.margin ?? 0,
  //           marginRight: 0,
  //           marginTop: 0,
  //           marginBottom: 0),
  //       build: (context) {
  //         return [
  //           pw.Column(children: [
  //             if (Get.find<AuthController>()
  //                     .profileModel!
  //                     .restaurants!
  //                     .first
  //                     .isShowAddressKot ==
  //                 'Yes')
  //               if (netImage != null) pw.Image(netImage),
  //             pw.Text(profileModel.restaurants!.first.name!,
  //                 style: pw.TextStyle(font: font, fontSize: 10)),
  //             pw.Text(profileModel.restaurants!.first.address!,
  //                 style: pw.TextStyle(font: font, fontSize: 8)),
  //             if (profileModel.restaurants![0].gstCode != '')
  //               pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
  //                   style: pw.TextStyle(font: font, fontSize: 8)),
  //             if (profileModel.restaurants![0].fssai != '')
  //               pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
  //                   style: pw.TextStyle(font: font, fontSize: 8)),
  //             pw.Text(
  //                 '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
  //                 style: pw.TextStyle(font: font, fontSize: 8)),
  //             pw.Text(
  //                 '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
  //                 style: pw.TextStyle(font: font, fontSize: 8)),
  //             pw.Padding(
  //               padding: pw.EdgeInsets.symmetric(vertical: 1),
  //               child: buildDottedLine(180),
  //             ),
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Title',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Amount'.tr,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),
  //             pw.Padding(
  //               padding: pw.EdgeInsets.symmetric(vertical: 1),
  //               child: buildDottedLine(180),
  //             ),
  //             // pw.Row(children: [
  //             //   pw.Expanded(
  //             //       flex: 2,
  //             //       child: pw.Align(
  //             //         alignment: pw.Alignment.centerLeft,
  //             //         child: pw.Text('Total Sales',
  //             //             style: pw.TextStyle(font: font, fontSize: 8)),
  //             //       )),
  //             //   pw.SizedBox(width: 3),
  //             //   pw.Expanded(
  //             //       flex: 1,
  //             //       child: pw.Align(
  //             //         alignment: pw.Alignment.centerLeft,
  //             //         child: pw.Text(revenue!.totalSales,
  //             //             style: pw.TextStyle(font: font, fontSize: 8)),
  //             //       )),
  //             // ]),
  //             // pw.Padding(
  //             //   padding: pw.EdgeInsets.symmetric(vertical: 1),
  //             //   child: buildDottedLine(180),
  //             // ),
  //             // 2. Balance Section
  //             // if (Get.find<AuthController>()
  //             //     .profileModel!
  //             //     .role!
  //             //     .contains('sattle_report')) ...[
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Opening Balance',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text(revenue!.totalOpeningBalance,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Closing Balance',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text(revenue.lastDayPending,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Cash Collected',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text(revenue.totalTodaySettlement,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Galla',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text(revenue.todayGalla,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),

  //             pw.Padding(
  //               padding: pw.EdgeInsets.symmetric(vertical: 1),
  //               child: buildDottedLine(180),
  //             ),
  //             pw.Row(children: [
  //               pw.Expanded(
  //                   flex: 2,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Title',
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //               pw.SizedBox(width: 3),
  //               pw.Expanded(
  //                   flex: 1,
  //                   child: pw.Align(
  //                     alignment: pw.Alignment.centerLeft,
  //                     child: pw.Text('Amount'.tr,
  //                         style: pw.TextStyle(font: font, fontSize: 8)),
  //                   )),
  //             ]),
  //             pw.Padding(
  //               padding: pw.EdgeInsets.symmetric(vertical: 1),
  //               child: buildDottedLine(180),
  //             ),
  //             // pw.Row(children: [
  //             //   pw.Expanded(
  //             //       flex: 2,
  //             //       child: pw.Align(
  //             //         alignment: pw.Alignment.centerLeft,
  //             //         child: pw.Text('Total Sales',
  //             //             style: pw.TextStyle(font: font, fontSize: 8)),
  //             //       )),
  //             //   pw.SizedBox(width: 3),
  //             //   pw.Expanded(
  //             //       flex: 1,
  //             //       child: pw.Align(
  //             //         alignment: pw.Alignment.centerLeft,
  //             //         child: pw.Text(revenue!.totalSales,
  //             //             style: pw.TextStyle(font: font, fontSize: 8)),
  //             //       )),
  //             // ]),
  //             // pw.Padding(
  //             //   padding: pw.EdgeInsets.symmetric(vertical: 1),
  //             //   child: buildDottedLine(180),
  //             // ),
  //             // 2. Balance Section
  //             if (Get.find<AuthController>()
  //                 .profileModel!
  //                 .role!
  //                 .contains('sattle_report')) ...[
  //               pw.Row(children: [
  //                 pw.Expanded(
  //                     flex: 2,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text('Opening Balance',
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //                 pw.SizedBox(width: 3),
  //                 pw.Expanded(
  //                     flex: 1,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text(revenue!.totalOpeningBalance,
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //               ]),
  //               pw.Row(children: [
  //                 pw.Expanded(
  //                     flex: 2,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text('Room',
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //                 pw.SizedBox(width: 3),
  //                 pw.Expanded(
  //                     flex: 1,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text(revenue.orderRoom,
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //               ]),
  //               pw.Padding(
  //                 padding: pw.EdgeInsets.symmetric(vertical: 1),
  //                 child: buildDottedLine(180),
  //               ),
  //               pw.Row(children: [
  //                 pw.Expanded(
  //                     flex: 2,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text('Running Order',
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //                 pw.SizedBox(width: 3),
  //                 pw.Expanded(
  //                     flex: 1,
  //                     child: pw.Align(
  //                       alignment: pw.Alignment.centerLeft,
  //                       child: pw.Text(revenue.runningOrder,
  //                           style: pw.TextStyle(font: font, fontSize: 8)),
  //                     )),
  //               ]),
  //               pw.Padding(
  //                 padding: pw.EdgeInsets.symmetric(vertical: 1),
  //                 child: buildDottedLine(180),
  //               ),
  //               pw.SizedBox(height: 10),
  //               pw.Text('Powered by MyGenie',
  //                   style: pw.TextStyle(font: font, fontSize: 8)),
  //               // ]
  //             ]
  //           ])
  //         ];
  //       },
  //     ),
  //   );

  //   return pdf.save();
  // }

  pw.Widget _pdfAmountRow(pw.Font font, String label, String value,
      {bool indent = false}) {
    return pw.Row(children: [
      pw.Expanded(
          flex: 2,
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(indent ? '    $label' : label,
                style: pw.TextStyle(font: font, fontSize: 8)),
          )),
      pw.SizedBox(width: 3),
      pw.Expanded(
          flex: 1,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 8)),
          )),
    ]);
  }

  List<pw.Widget> _pdfBreakdown(pw.Font font, Map<String, String> breakdown) {
    return breakdown.entries
        .map((entry) => _pdfAmountRow(
            font, _breakdownLabel(entry.key), entry.value,
            indent: true))
        .toList();
  }

  pw.Widget _pdfDottedDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: buildDottedLine(180),
    );
  }

  List<pw.Widget> _dailyReportPdfWidgets(pw.Font font) {
    final summary = _reportSummary;
    final sales = summary?.salesRevenueSummary?.sales ?? SalesSection();
    final food =
        summary?.salesRevenueSummary?.foodSales ?? FoodSalesSection();
    final credit = summary?.salesRevenueSummary?.credit ?? CreditSection();
    final room =
        summary?.salesRevenueSummary?.roomSales ?? RoomSalesSection();
    final balance = summary?.balanceSummary ?? BalanceSummary();
    final expense = summary?.totalPurchaseAndExpense ??
        TotalPurchaseAndExpenseSummary();
    final extra = summary?.additionalSummary ?? AdditionalSummary();
    final aggregator = summary?.aggregatorOrder ?? {};
    final stations = summary?.stationRevenue ?? {};
    final cancel = summary?.cancelRevenue ?? {};

    final widgets = <pw.Widget>[];

    if (_isSettleReport) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Opening Balance', balance.openingBalance),
        _pdfAmountRow(font, 'Paid Cash Revenue', balance.paidCashRevenue),
        _pdfAmountRow(font, 'Total Purchase', balance.totalPurchase),
        _pdfAmountRow(font, 'Total Expense', balance.totalExpense),
        _pdfAmountRow(
            font, 'Current Balance (Galla)', balance.currentBalanceGalla),
        _pdfAmountRow(font, 'Cash Collected', balance.cashCollected),
        _pdfAmountRow(font, 'Total Pilferage', balance.totalPilferage),
        _pdfAmountRow(font, 'Closing Balance', balance.closingBalance),
        _pdfAmountRow(font, 'Total Profit/Loss', balance.totalProfitLoss),
      ]);
    }

    if (_isShowRoom) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Total Sales', sales.totalSales),
        _pdfAmountRow(font, 'Total Paid Revenue', sales.totalPaidRevenue),
        _pdfAmountRow(font, 'Paid Cash Revenue', sales.paidCashRevenue),
        ..._pdfBreakdown(font, sales.breakdown),
      ]);
    }

    widgets.addAll([
      _pdfDottedDivider(),
      _pdfAmountRow(font, 'Food Sales', food.foodSales),
      _pdfAmountRow(font, 'Food Paid Revenue', food.foodPaidRevenue),
      _pdfAmountRow(font, 'Food Paid Cash Revenue', food.foodPaidCashRevenue),
      ..._pdfBreakdown(font, food.breakdown),
      if (food.roomCash != null)
        _pdfAmountRow(font, 'Room Cash', food.roomCash!, indent: true),
      if (food.roomCard != null)
        _pdfAmountRow(font, 'Room Card', food.roomCard!, indent: true),
      if (food.roomUpi != null)
        _pdfAmountRow(font, 'Room UPI', food.roomUpi!, indent: true),
      _pdfAmountRow(font, 'Running Orders', food.runningOrders),
    ]);

    if (_isPayTab) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Credit', credit.credit),
        _pdfAmountRow(font, 'Credit Paid Revenue', credit.creditPaidRevenue),
        ..._pdfBreakdown(font, credit.breakdown),
      ]);
    }

    if (_isShowRoom) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Room Sales', room.roomSales),
        _pdfAmountRow(font, 'Room Paid Revenue', room.roomPaidRevenue),
        ..._pdfBreakdown(font, room.breakdown),
        _pdfAmountRow(font, 'Advance Amount', room.advanceAmount),
        _pdfAmountRow(font, 'Checkout Paid Revenue', room.checkoutPaidRevenue),
        _pdfAmountRow(font, 'Running Rooms', room.runningRooms),
      ]);
    }

    if (_isExpenseRole) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Total Expense & Purchase',
            expense.totalPurchaseAndExpense),
        _pdfAmountRow(font, 'CashDrawer', expense.cashDrawer),
        _pdfAmountRow(font, 'Cash', expense.cash, indent: true),
        _pdfAmountRow(font, 'Card', expense.card, indent: true),
        _pdfAmountRow(font, 'UPI', expense.upi, indent: true),
        _pdfAmountRow(font, 'Store', expense.store, indent: true),
        _pdfAmountRow(font, 'Unpaid', expense.unpaid, indent: true),
        _pdfAmountRow(font, 'UPI Drawer', expense.upiDrawer, indent: true),
        _pdfAmountRow(font, 'Bank Transfer', expense.bankTransfer, indent: true),
        _pdfAmountRow(font, 'Others', expense.others, indent: true),
      ]);
    }

    if (_isAggregatorRole) {
      widgets.addAll([
        _pdfDottedDivider(),
        _pdfAmountRow(font, 'Zomato', aggregator['zomato'] ?? '0.00'),
        _pdfAmountRow(font, 'Swiggy', aggregator['swiggy'] ?? '0.00'),
      ]);
    }

    widgets.addAll([
      _pdfDottedDivider(),
      _pdfAmountRow(font, 'Service Charge', extra.serviceCharge),
      _pdfAmountRow(font, 'Discount', extra.discount),
      _pdfAmountRow(font, 'Tips', extra.tips),
      _pdfAmountRow(font, 'Tax', extra.tax),
      _pdfDottedDivider(),
    ]);
    if (stations.isEmpty) {
      widgets.add(_pdfAmountRow(font, 'OTHER', '0.00'));
    } else {
      stations.forEach((key, value) {
        widgets.add(_pdfAmountRow(font, key.toUpperCase(), value));
      });
    }
    widgets.addAll([
      _pdfDottedDivider(),
      ..._pdfBreakdown(font, cancel),
    ]);

    return widgets;
  }

  //This is for windows print
  Future<Uint8List> generateKotPdf() async {
    ProfileModel? profileModel = Get.find<AuthController>().profileModel;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    GetPrintReportResponse? revenue =
        Get.find<RevenueController>().getPrintReportResponse;

    final font = await PdfGoogleFonts.poppinsMedium();
    var netImage;
    if (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .isShowAddressKot ==
            'Yes' &&
        Get.find<AuthController>().profileModel!.restaurants!.first.logoPath !=
            '')
      netImage = await networkImage(Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .logoPath!);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
            profileModel!.billPrinterPaperRoll == 58
                ? 48 * PdfPageFormat.mm
                : 72 * PdfPageFormat.mm,
            850,
            marginLeft: profileModel.windowsPrintConfigList?.first.margin ?? 0,
            marginRight: 0,
            marginTop: 0,
            marginBottom: 0),
        build: (context) {
          return [
            pw.Column(children: [
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .isShowAddressKot ==
                  'Yes')
                if (netImage != null) pw.Image(netImage),
              pw.Text(profileModel.restaurants!.first.name!,
                  style: pw.TextStyle(font: font, fontSize: 10)),
              pw.Text(profileModel.restaurants!.first.address!,
                  style: pw.TextStyle(font: font, fontSize: 8)),
              if (profileModel.restaurants![0].gstCode != '')
                pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
                    style: pw.TextStyle(font: font, fontSize: 8)),
              if (profileModel.restaurants![0].fssai != '')
                pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
                    style: pw.TextStyle(font: font, fontSize: 8)),
              pw.Text(
                  '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                  style: pw.TextStyle(font: font, fontSize: 8)),
              ..._dailyReportPdfWidgets(font),
              if (false) ...[
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Title',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Amount'.tr,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              // pw.Row(children: [
              //   pw.Expanded(
              //       flex: 2,
              //       child: pw.Align(
              //         alignment: pw.Alignment.centerLeft,
              //         child: pw.Text('Total Sales',
              //             style: pw.TextStyle(font: font, fontSize: 8)),
              //       )),
              //   pw.SizedBox(width: 3),
              //   pw.Expanded(
              //       flex: 1,
              //       child: pw.Align(
              //         alignment: pw.Alignment.centerLeft,
              //         child: pw.Text(revenue!.totalSales,
              //             style: pw.TextStyle(font: font, fontSize: 8)),
              //       )),
              // ]),
              // pw.Padding(
              //   padding: pw.EdgeInsets.symmetric(vertical: 1),
              //   child: buildDottedLine(180),
              // ),
              // 2. Balance Section
              // if (Get.find<AuthController>()
              //     .profileModel!
              //     .role!
              //     .contains('sattle_report')) ...[
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Opening Balance',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue!.totalOpeningBalance,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Paid Cash Revenue',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPaidCashRevenue,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Purchase',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPurchase,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Expense',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalExpense,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Galla',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.todayGalla,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Cash Collected',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalTodaySettlement,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),

              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Pilferage',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPilferage,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),

              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Closing Balance',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.lastDayPending,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Profit/Loss',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalProfitLoss,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),

              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Sales',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalSales,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Paid Revenue',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPaidAmount,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              // 4. Total Cash Paid Revenue
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Cash Paid Revenue',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPaidCashRevenue,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Cash',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.orderCash,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Card',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.orderCard,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('UPI',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.orderUPI,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              if (profileModel.restaurants!.first.payTab == 'Yes')
                pw.Column(children: [
                  pw.Row(children: [
                    pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('Credit Cash',
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                    pw.SizedBox(width: 3),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(revenue.tabInCash,
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                  ]),
                  pw.Row(children: [
                    pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('Credit Card',
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                    pw.SizedBox(width: 3),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(revenue.tabInCard,
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                  ]),
                  pw.Row(children: [
                    pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text('Credit Upi',
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                    pw.SizedBox(width: 3),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(revenue.tabInUpi,
                              style: pw.TextStyle(font: font, fontSize: 8)),
                        )),
                  ]),
                  // pw.Padding(
                  //   padding: pw.EdgeInsets.symmetric(vertical: 1),
                  //   child: buildDottedLine(180),
                  // )
                ]),

              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Total Expense & Purchase',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.totalPurchaseAndExpense,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Expense CashDrawer',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.expenseCashDraw,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),

              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),

              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Unpaid Revenue',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.unpaidRevenue,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              if (profileModel.restaurants!.first.payTab == 'Yes')
                pw.Row(children: [
                  pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text('Credit',
                            style: pw.TextStyle(font: font, fontSize: 8)),
                      )),
                  pw.SizedBox(width: 3),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(revenue.orderTAB,
                            style: pw.TextStyle(font: font, fontSize: 8)),
                      )),
                ]),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Room',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.orderRoom,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              pw.Row(children: [
                pw.Expanded(
                    flex: 2,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Running Order',
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
                pw.SizedBox(width: 3),
                pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(revenue.runningOrder,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    )),
              ]),
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 1),
                child: buildDottedLine(180),
              ),
              // Cancel Order Report
              if (revenue?.cancelOrderReport != null &&
                  revenue!.cancelOrderReport!.isNotEmpty) ...[
                pw.Column(
                  children: revenue!.cancelOrderReport!.entries.map((entry) {
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              'Cancel ${entry.key}',
                              style: pw.TextStyle(font: font, fontSize: 8),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 3),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              '${double.parse(entry.value.toString()).toStringAsFixed(2)}',
                              style: pw.TextStyle(font: font, fontSize: 8),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 1),
                  child: buildDottedLine(180),
                ),
              ],

              ],
              pw.SizedBox(height: 10),
              pw.Text('Powered by MyGenie',
                  style: pw.TextStyle(font: font, fontSize: 8)),
              // ]
            ])
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future _kdsPrintEscPos(List<int> bytes, Generator generator) async {
    BluetoothPrinter bluetoothPrinter = await BluetoothPrinter(
        address: Get.find<AuthController>().profileModel!.billPrinterIp,
        deviceName: Get.find<AuthController>().profileModel!.billPrinterName!);
    await printerManager.connect(
      type: bluetoothPrinter.typePrinter,
      model: BluetoothPrinterInput(
        name: bluetoothPrinter.deviceName,
        address: bluetoothPrinter.address!,
      ),
    );
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try {
        await printerManager.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
        Future.delayed(Duration(seconds: 11), () async {
          Get.find<LoadingController>().startLoading(false);
          await Get.find<LoadingController>()
              .changeText(data: 'Successfully printed!!');
          await Get.find<LoadingController>().changeStatus(data: true);
          await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
        });
      } catch (e) {}
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  Future<void> _iosPrintEscPos(List<int> bytes, Generator generator) async {
    print('########## bytes length ${bytes.length}');
    bytes += generator.feed(2);

    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
      macPrinterAddress:
          Get.find<AuthController>().profileModel!.macBillPrinterIp!,
    );

    // Small delay after connect (important on iPad)
    await Future.delayed(const Duration(seconds: 2));

    if (!result) {
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Failed to bluetooth connect!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
      return;
    }

    try {
      // 🔥 iPad-safe chunked write (MOST IMPORTANT PART)
      (Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58 ||
              MediaQuery.of(context).size.shortestSide < 570)
          ? await IosPrintTransport.writeBytes(bytes)
          : await _writeBytesForIPad(bytes);

      // Wait a bit to ensure printer finishes printing
      await Future.delayed(Duration(
          seconds: bytes.length <= 5850
              ? 2
              : bytes.length <= 7890
                  ? 3
                  : bytes.length <= 10195
                      ? 6
                      : bytes.length <= 13100
                          ? 10
                          : bytes.length <= 21150
                              ? 15
                              : 20));

      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Successfully printed!!');
      await Get.find<LoadingController>().changeStatus(data: true);
    } catch (e) {
      print('Print error: $e');
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Printing failed!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    } finally {
      final isDisconnect = await IosPrintTransport.disconnect;
      print('is disconnect $isDisconnect');
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 255; // 🔥 SAFE for all iPads
    const int delayMs = 60; // Required for 80mm stability

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }
}
