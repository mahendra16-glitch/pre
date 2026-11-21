import 'dart:async';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/theme_color_button.dart';
import 'package:mygenie_restaurant/view/screens/deliveryman/widget/delivery_food_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../../controller/kds_controller.dart';

class DeliveryOrderList extends StatelessWidget {
  final OrderList order;
  final FlutterTts flutterTit;
  final bool isWaiter;
  final TextEditingController? searchTable;
  final TextEditingController searchOrder;

  final int? splitCurrentPrintIndex;
  final PrinterManager? printerManager;
  final List<bool>? isSplitSelectPrinterList;
  final List<bool>? isSplitPrinterProccessingList;
  final List<bool>? isSplitPrintedList;
  final StreamSubscription<BTStatus>? subscriptionBtStatus;
  final Function? printSplitBill;

  DeliveryOrderList({
    Key? key,
    required this.order,
    this.subscriptionBtStatus,
    required this.flutterTit,
    this.isWaiter = false,
    this.searchTable,
    required this.searchOrder,
    this.splitCurrentPrintIndex,
    this.printerManager,
    this.isSplitSelectPrinterList,
    this.isSplitPrinterProccessingList,
    this.isSplitPrintedList,
    this.printSplitBill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.shortestSide <= 570
          ? null
          : Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .listServeItem ==
                  'Fixed'
              ? MediaQuery.of(context).orientation == Orientation.landscape
                  ? Get.height * 0.55
                  : Get.height * 0.4
              : null,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: Color.fromRGBO(253, 237, 237, 1)),
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 15, color: Colors.black),
                        maxLines: 2,
                      ),
                      Text(
                        '${order.vendorEmployee?.waiterName ?? ''}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // flex: 2,
                  child: Row(
                    children: [
                      if (order.paymentType == 'prepaid')
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: ColorTheme.appColor,
                            size: 20,
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.restaurantOrderId}',
                              style: poppinsBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                  color: Colors.black),
                            ),
                            if (order.userName != 'Mygenie' &&
                                order.userName != '')
                              Text(
                                '${order.userName ?? ''}',
                                style: poppinsMedium.copyWith(
                                    fontSize: 11, color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(width: 8),

                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();

                        showAddressDialog(order);
                      },
                      child: Icon(CupertinoIcons.location_solid,
                          color: ColorTheme.appColor)),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 7, right: 15),
              child: Text(
                'Rs. ${order.orderAmount != null ? double.parse(order.orderAmount!).toStringAsFixed(2) : '0.00'}',
                style:
                    poppinsMedium.copyWith(fontSize: 11, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 9),
          Divider(color: ColorTheme.hintText, height: 1),
          DeliveryFoodItem(
            searchOrder: searchOrder,
            flutterTts: flutterTit,
            isWaiter: isWaiter,
            orderItemList: order.orderDetails!,
            order: order,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          order.orderNote == null || order.orderNote!.trim() == ''
              ? SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Notes  :',
                          style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.width > 1600
                                  ? 17
                                  : 12,
                              color: ColorTheme.kdsLeftMenuBlue),
                        ),
                        TextSpan(
                          text: ' ${order.orderNote}',
                          style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.width > 1600
                                  ? 17
                                  : 11,
                              color: ColorTheme.green),
                        ),
                      ],
                    ),
                  ),
                ),
          order.orderNote == null || order.orderNote!.trim() == ''
              ? const SizedBox.shrink()
              : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.deliveryManStatus == 'No')
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ThemeColorButton(
                        onTap: () {
                          searchOrder.clear();
                          FocusManager.instance.primaryFocus?.unfocus();
                          Map<String, dynamic> jsonData = {
                            'order_id': order.id,
                            'delivery_man_id':
                                Get.find<AuthController>().profileModel!.empId,
                          };
                          Get.find<DeliveryManController>()
                              .rejectDeliveryMan(jsonData, (bool isSucces) {
                            if (isSucces) {
                              // order.deliveryMan = selectedTableName ?? '';
                              //   order.tableId = tableIdSelect.id;
                              //   order.restaurantTable = RestaurantTable(
                              //       id: tableIdSelect.id,
                              //       rtype: tableIdSelect.type,
                              //       tableNo: tableIdSelect.tableNo,
                              //       title: tableIdSelect.title);
                              // Get.find<KdsController>().update();
                              // if (Get.isBottomSheetOpen ?? false) Get.back();

                              // } else {
                            }
                          });
                        },
                        varticalPadding: 8,
                        horizontalPadding: 12,
                        editPadding: order.fOrderStatus == 2 ? 25 : 10,
                        title: 'Reject'),
                  ),
                ThemeColorButton(
                    onTap: () {
                      searchOrder.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (order.deliveryManStatus == 'No') {
                        Map<String, dynamic> jsonBody = {
                          'order_id': order.id.toString(),
                          'order_status': 'serve',
                          'delivery_man_status': 'Yes',
                          'role_name': 'Manager',
                        };
                        Get.find<DeliveryManController>()
                            .changeOrderStatus(jsonBody, callback);
                      } else {
                        if (order.paymentType == 'prepaid') {
                          Map<String, dynamic> jsonBodyPrepaid = {
                            'order_id': order.id.toString(),
                            'payment_status': 'sucess',
                          };
                          Get.find<KdsController>().changePrepaidOrderStatus(
                              jsonBodyPrepaid, callback);
                        } else {
                          Get.toNamed(
                            RouteHelper.getWaiterCollectPaymentRoute(
                                order.id.toString()),
                          );
                        }
                      }
                    },
                    varticalPadding: 8,
                    horizontalPadding: 12,
                    editPadding: order.fOrderStatus == 2 ? 25 : 10,
                    title:
                        order.deliveryManStatus == 'No' ? 'Accept' : 'Deliver'),
                // SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // showCustomSnackBar(message, isError: false);
    } else {
      // showCustomSnackBar(message);
    }
  }

  void showAddressDialog(OrderList order) {
    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(),
                    Text('Address #${order.deliveryAddress?.addressType}',
                        style: poppinsMedium.copyWith(
                            fontSize: 18, color: Colors.black)),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close, color: ColorTheme.appColor))
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Name: ${order.deliveryAddress?.contactPersonName ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(
                          'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 16)),
                      const SizedBox(height: 5),
                      // Text(
                      //     'Address type: ${order.deliveryAddress?.addressType ?? ''}',
                      //     style: poppinsMedium.copyWith(fontSize: 14)),
                      // const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                                'Address: ${order.deliveryAddress?.address ?? ''}',
                                style: poppinsMedium.copyWith(fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: InkWell(
                              onTap: () async {
                                final address = order.deliveryAddress;
                                final latStr = address?.latitude;
                                final lngStr = address?.longitude;
                                if (latStr != null && lngStr != null) {
                                  final lat = double.tryParse(latStr);
                                  final lng = double.tryParse(lngStr);
                                  if (lat != null && lng != null) {
                                    final googleAvailable =
                                        await MapLauncher.isMapAvailable(
                                                MapType.google) ??
                                            false;
                                    final appleAvailable =
                                        await MapLauncher.isMapAvailable(
                                                MapType.apple) ??
                                            false;
                                    if (googleAvailable) {
                                      await MapLauncher.showDirections(
                                        mapType: MapType.google,
                                        destination: Coords(lat, lng),
                                      );
                                    } else if (appleAvailable) {
                                      await MapLauncher.showDirections(
                                        mapType: MapType.apple,
                                        destination: Coords(lat, lng),
                                      );
                                    }
                                  }
                                }
                                // String googleUrl =
                                //     'https://www.google.com/maps/search/?api=1&query=15.00952529999999995879989000968635082244873046875,74.0489457999999984849637257866561412811279296875';
                                // try {
                                //   if (await canLaunchUrl(Uri.parse(googleUrl))) {
                                //     await launchUrl(Uri.parse(googleUrl));
                                //   } else {
                                //     throw 'Could not open the map.';
                                //   }
                                // } catch (e) {
                                //   print('$e ---------Error');
                                // }
                              },
                              child: Icon(
                                CupertinoIcons.map_pin_ellipse,
                                color: ColorTheme.appColor,
                                size: 45,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                          'House No/Flat No.: ${order.deliveryAddress?.house ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 16)),

                      const SizedBox(height: 5),

                      Text('Pincode: ${order.deliveryAddress?.pincode ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 16)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }
}
