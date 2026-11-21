// import 'package:flutter/material.dart';

// class DailySalesOrderDetails extends StatelessWidget {
//   const DailySalesOrderDetails({Key ? key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Card(
//           elevation: 4,
//           margin: const EdgeInsets.all(16),
//           child: Container(
//             width: 360,
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("#12345678",
//                         style: TextStyle(
//                             color: Colors.green,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold)),
//                     Text("25 Oct 2024 | 20:18",
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700])),
//                     Row(
//                       children: const [
//                         Icon(Icons.print, size: 20, color: Colors.grey),
//                         SizedBox(width: 8),
//                         Icon(Icons.download, size: 20, color: Colors.grey),
//                       ],
//                     )
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Waiter Info
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.orange,
//                       child: Text("T18",
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold)),
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text("Waiter", style: TextStyle(color: Colors.grey)),
//                         Text("Roshan Kale",
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Order Details
//                 const Text("Order Details",
//                     style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14)),
//                 const SizedBox(height: 8),
//                 _itemRow("Absolute Vodka, Small(30ML), Addon Garlic x 1", "₹250.00"),
//                 _itemRow("Banjara Chicken x 1", "₹250.00"),
//                 _itemRow("Food Name Comes Here x 1", "₹250.00"),
//                 const Divider(),
//                 _itemRow("Item Total", "₹750.00"),
//                 _itemRow("Order Packing Charges", "₹25.00"),
//                 _itemRow("Taxes", "₹25.00"),
//                 _itemRow("CGST", "0.05"),
//                 _itemRow("SGST", "0.05"),
//                 const Divider(),
//                 _itemRow("Bill Total", "₹800.00",
//                     isBold: true, fontSize: 16),
//                 const Divider(),
//                 _itemRow("UPI (Transaction ID)", "₹800.00"),
//                 _itemRow("Card (Transaction ID)", "₹800.00"),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _itemRow(String label, String value,
//       {bool isBold = false, double fontSize = 14}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(label,
//                 style: TextStyle(
//                     fontSize: fontSize,
//                     fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//           ),
//           Text(value,
//               style: TextStyle(
//                   fontSize: fontSize,
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
// }

import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';

class DailySalesOrderDetails extends StatelessWidget {
  String? orderId;
  ReportSummeryController? controller;

  DailySalesOrderDetails({required this.orderId, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ReportSummeryController reportSummeryController =
        controller ?? Get.find<ReportSummeryController>();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // });

    reportSummeryController.fetchOrderDetails(orderId);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: ColorTheme.appColor,
            )),
        titleSpacing: 0,
        title: Obx(
          () => Row(
            children: [
              Text(
                  "#${controller!.orderDetails['orders']?['order_details_order']?['restaurant_order_id'] ?? ''}",
                  style: poppinsSemiBold.copyWith(
                      color: ColorTheme.green, fontSize: 18)),
              SizedBox(width: 10),
              Text(
                  _formatDateTime(controller!.orderDetails['orders']
                      ?['order_details_order']?['created_at']),
                  style: poppinsMedium.copyWith(
                      color: Color(0xFF8C8C8C), fontSize: 9)),
            ],
          ),
        ),
        actions: [
          Icon(Icons.print_outlined, size: 25, color: Color(0xFFC6C6C6)),
          SizedBox(width: 13),
          // SizedBox(
          //     width: 20,
          //     child: SvgPicture.asset(
          //       Images.export,
          //     )),
          // SizedBox(width: 15),
        ],
      ),
      body: Obx(() => controller!.isLoadingOrderDetails.value
          ? const Center(child: CircularProgressIndicator())
          : controller!.orderDetails.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Failed to load order details"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          controller!.fetchOrderDetails(orderId!);
                        },
                        child: const Text("Retry"),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Go Back"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Color(0xFFE4E4E4)))),
                      // width: 360,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //         "#${controller!.orderDetails['orders']?['order_details_order']?['id'] ?? '-'}",
                          //         style: const TextStyle(
                          //             color: Colors.green,
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.bold)),
                          //     Text(
                          //         _formatDateTime(controller!
                          //                 .orderDetails['orders']
                          //             ?['order_details_order']?['created_at']),
                          //         style: TextStyle(
                          //             fontSize: 12, color: Colors.grey[700])),
                          //     Row(
                          //       children: const [
                          //         Icon(Icons.print,
                          //             size: 20, color: Colors.grey),
                          //         SizedBox(width: 8),
                          //         Icon(Icons.download,
                          //             size: 20, color: Colors.grey),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.orange,
                                child: Text(
                                    controller!.orderDetails['orders']
                                                ?['restaurant_details']
                                            ?['restaurant_table_no'] ??
                                        '',
                                    style: montserratSemiBold.copyWith(
                                        color: Colors.white, fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      controller!.orderDetails['orders']
                                                  ?['restaurant_details']
                                              ?['employee_role'] ??
                                          '',
                                      style: poppinsMedium.copyWith(
                                          color: Color(0xFF2E2E2E),
                                          fontSize: 14)),
                                  Text(
                                      controller!.orderDetails['orders']
                                                  ?['restaurant_details']
                                              ?['restaurant_waiter_name'] ??
                                          '',
                                      style: poppinsMedium.copyWith(
                                          color: Color(0xFF2E2E2E),
                                          fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Order Details
                          Text("Order Details",
                              style: poppinsMedium.copyWith(
                                  color: Color(0xFF0090FF), fontSize: 13)),
                          const SizedBox(height: 8),

                          if (controller!.orderDetails['orders']
                                  ?['order_details_bar'] !=
                              null)
                            ...controller!.orderDetails['orders']
                                    ['order_details_bar']
                                .map<Widget>((item) {
                              bool isCancelled = item['food_status'] == 3;

                              //varations
                              // String variations = '';
                              // if (item['variation'] != null &&
                              //     item['variation'].isNotEmpty) {
                              //   variations = item['variation']
                              //       .map((v) =>
                              //           ",${v['name'] ?? ''}(${v['values']?[0]?['label'] ?? ''})")
                              //       .join(", ");
                              // }
                              String variationText = '';
                              double variationTotal = 0;
                              double halfVariationPrice = 0;

                              if (item['variation'] != null &&
                                  item['variation'].isNotEmpty) {
                                for (int j = 0;
                                    j < item['variation'].length;
                                    j++) {
                                  variationText +=
                                      '${variationText.isNotEmpty ? ', ' : ''}${item['variation']![j]['name']} (';

                                  if (item['variation'][j]['values'] != null) {
                                    List<String> labelList = [];
                                    if (item['variation'][j]['values'] !=
                                        null) {
                                      for (var element in item['variation'][j]
                                          ['values']) {
                                        labelList.add(element['label'] ?? '');
                                        // variationTotal += (int.parse(
                                        //         element.optionPrice) *
                                        //     orderDetailsFood.quantity);
                                        final variationName =
                                            item['variation'][j]['name'] ?? '';
                                        final optionPrice = double.tryParse(
                                                element['optionPrice'] ??
                                                    '0') ??
                                            0.0;
                                        final quantity = item['quantity'] ?? 0;
                                        if (variationName.toUpperCase() ==
                                            'HALFNHALF') {
                                          if (halfVariationPrice <
                                              optionPrice * quantity) {
                                            halfVariationPrice =
                                                optionPrice * quantity;
                                          }
                                        } else {
                                          variationTotal = variationTotal +
                                              optionPrice * quantity;
                                        }
                                      }
                                    }
                                    variationText +=
                                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                  }

                                  variationText += ')';
                                  variationTotal =
                                      variationTotal + halfVariationPrice;
                                }
                              }
                              //addons
                              String addOns = '';
                              if (item['add_ons'] != null &&
                                  item['add_ons'].isNotEmpty) {
                                addOns = item['add_ons']
                                    .map((a) => "${a['name'] ?? ''}")
                                    .join(", ");
                              }

                              // combine
                              String extras = [variationText, addOns]
                                  .where((e) => e.isNotEmpty)
                                  .join(", ");
                              String itemLabel =
                             item['food_details']?['name'].toString().toLowerCase()=='check in'?'Room Check-in' :    "${item['food_details']?['name'] ?? 'Unknown Item'}";
                              if (extras.isNotEmpty) {
                                itemLabel += " $extras";
                              }
                              itemLabel += " x ${item['quantity'] ?? 1}";
                              double itemPrice =
                                 item['food_details']?['name'].toString().toLowerCase()=='check in'?   double.parse("${item['unit_price'] ?? '0.00'}"):  double.parse("${item['price'] ?? '0.00'}");
                              double addonPrice = double.parse(
                                  "${item['total_add_on_price'] ?? '0.00'}");
                              return _itemRow(
                                itemLabel,
                                (itemPrice + variationTotal + addonPrice)
                                    .toStringAsFixed(2),
                                isCancelled: isCancelled,
                              );
                            }).toList(),

                          Divider(
                            color: Color(0xFFE6E6E6),
                          ),
                          _itemRow("Item Total",
                              "₹${controller!.orderDetails['orders']?['order_total']?.toString() ?? '0.00'}",
                              fontSize: 12),
                          // _itemRow("Order Packing Charges", "₹0.00",
                          //     fontSize: 12),
                          controller!.orderDetails['orders']
                                      ?['order_details_order']['tip_amount'] ==
                                  '0.00'
                              ? SizedBox.shrink()
                              : _itemRow(
                                  "Tip",
                                  "₹${controller!.orderDetails['orders']?['order_details_order']['tip_amount']?.toString() ?? '0.00'}",
                                  fontSize: 13,
                                ),
                          controller!.orderDetails['orders']
                                          ?['order_details_order']
                                      ['restaurant_discount_amount'] ==
                                  0
                              ? SizedBox.shrink()
                              : _itemRow(
                                  "Discount",
                                  "₹${controller!.orderDetails['orders']?['order_details_order']['restaurant_discount_amount']?.toString() ?? '0.00'}",
                                  fontSize: 13,
                                ),

                          controller!.orderDetails['orders']?['service_tax'] ==
                                  '0.00'
                              ? SizedBox.shrink()
                              : _itemRow("Serive Charge",
                                  "₹${double.parse(controller!.orderDetails['orders']?['service_tax']?.toString() ?? '0.00')}",
                                  fontSize: 12),
                          // controller!.orderDetails['orders']?['vat_tax'] ==
                          //         '0.00'
                          //     ? _itemRow("Taxes",
                          //         "${double.parse(controller!.orderDetails['orders']?['gst_tax']?.toString() ?? '0.00')}",
                          //         fontSize: 12)
                          //     : controller!.orderDetails['orders']
                          //                 ?['gst_tax'] ==
                          //             '0.00'
                          //         ? _itemRow("Taxes",
                          //             "${double.parse(controller!.orderDetails['orders']?['vat_tax']?.toString() ?? '0.00')}",
                          //             fontSize: 12)
                          //         : SizedBox.shrink(),
                          _itemRow("SGST",
                              "${((double.tryParse(controller!.orderDetails['orders']?['gst_tax']?.toString() ?? '0') ?? 0) / 2).toStringAsFixed(2)}",
                              fontSize: 12),
                          _itemRow("CGST",
                              "${((double.tryParse(controller!.orderDetails['orders']?['gst_tax']?.toString() ?? '0') ?? 0) / 2).toStringAsFixed(2)}",
                              fontSize: 12),
                          controller!.orderDetails['orders']?['vat_tax'] ==
                                  '0.00'
                              ? SizedBox.shrink()
                              : _itemRow("VAT",
                                  "${controller!.orderDetails['orders']?['vat_tax']?.toString() ?? '0.00'}",
                                  fontSize: 12),

                          _itemRow("Bill Total",
                              "₹${controller!.orderDetails['orders']?['order_details_order']['order_amount']?.toString() ?? '0.00'}",
                              fontSize: 13, isBold: true),
                          Divider(
                            color: Color(0xFFE6E6E6),
                          ),

                          if (controller!.orderDetails['orders']
                                  ?['order_details_order']?['payment_method'] !=
                              null)
                            _itemRow(
                              'Payment Method',
                              controller!.orderDetails['orders']
                                              ?['order_details_order']
                                          ?['payment_method'] ==
                                      'card'
                                  ? "${controller!.orderDetails['orders']['order_details_order']['payment_method'].toString().toUpperCase()} (Transaction ID : ${controller!.orderDetails['orders']?['order_details_order']?['transaction_id'] ?? ''})"
                                  : controller!.orderDetails['orders']
                                                  ?['order_details_order']
                                              ?['payment_method'] ==
                                          'cash_on_delivery'
                                      ? "UNPAID"
                                      : "${controller!.orderDetails['orders']['order_details_order']['payment_method'].toString().toUpperCase()}",
                            )
                          // "₹${double.parse(controller!.orderDetails['orders']?['order_details_order']?['transaction_reference']?.toString() ?? '0').toStringAsFixed(2)}")
                        ],
                      ),
                    ),
                  ),
                )),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy | HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  Widget _itemRow(String label, String value,
      {bool isBold = false, double fontSize = 13, bool isCancelled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: (isBold ? poppinsSemiBold : poppinsMedium).copyWith(
                color: Color(0xFF828282),
                fontSize: fontSize,
                decoration: isCancelled
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: (isBold ? poppinsSemiBold : poppinsMedium).copyWith(
              color: Color(0xFF828282),
              fontSize: fontSize,
              decoration: isCancelled
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
