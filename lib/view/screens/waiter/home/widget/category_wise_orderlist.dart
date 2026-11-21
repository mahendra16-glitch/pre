import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/table_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/base/theme_color_button.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/split_table/split_table_food_item.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_food_item.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:mygenie_restaurant/view/screens/waiter/walkIn/widget/walk_in_add_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../../../data/model/response/get_delivery_man_list_response.dart';
import 'cancel_order_dialog.dart';
import 'record_room_payment_bottom_sheet.dart';
import 'move_room_items_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryWiseOrderList extends StatelessWidget {
  final OrderList order;
  final FlutterTts flutterTit;
  final bool isWaiter;
  int? splitCurrentPrintIndex;
  PrinterManager? printerManager;
  List<bool>? isSplitSelectPrinterList;
  List<bool>? isSplitPrinterProccessingList;
  List<bool>? isSplitPrintedList;
  TextEditingController searchOrder;
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  Function? printSplitBill;

  CategoryWiseOrderList(this.subscriptionBtStatus,
      {required this.order,
      required this.flutterTit,
      this.isWaiter = false,
      this.splitCurrentPrintIndex,
      this.printerManager,
      this.isSplitSelectPrinterList,
      this.isSplitPrinterProccessingList,
      this.isSplitPrintedList,
      this.printSplitBill,
      required this.searchOrder});

  @override
  Widget build(BuildContext context) {
    int cookingFoodItemLenght = 0;
    double roomOrderAmount = 0;
    if ((Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .showOrderStatus ==
                2
            ? order.fOrderStatus! <= 2
            : order.fOrderStatus! < 2) ||
        order.orderType == 'delivery' ||
        order.orderType == 'take_away' ||
        (order.restaurantTable != null &&
            order.restaurantTable!.rtype == 'RM')) {
      for (var element in order.orderDetails!) {
        DateTime foodTime = DateTime.parse(element.updatedAt!);
        var diffTime = DateTime.now().difference(foodTime);
        if ((Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .showOrderStatus ==
                    2 ||
                order.orderType == 'delivery' ||
                order.orderType == 'take_away')
            ? ((element.foodStatus! <= 2 ||
                    order.orderType == 'delivery' ||
                    order.orderType == 'take_away') &&
                diffTime.inMinutes <=
                    Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .cancelOrderTime!)
            : element.foodStatus! < 2) {
          cookingFoodItemLenght = cookingFoodItemLenght + 1;
        }
      }
    }

    if (order.restaurantTable != null && order.restaurantTable!.rtype == 'RM') {
      if (order.roomAssociateOrder != null) {
        for (var room in order.roomAssociateOrder!) {
          roomOrderAmount = roomOrderAmount + room.amount!;
        }
      }
      roomOrderAmount = roomOrderAmount +
          double.parse(order.orderAmount!) +
          (order.roomInfo?.remainingPay ?? 0);
    }
    // // DateTime tempDate = DateTime.parse(order.createdAt);
    return order.isEngage.toString().toLowerCase() == 'engage'
        ? Container(
            decoration: BoxDecoration(
                border: Border.all(color: ColorTheme.appColor),
                borderRadius: BorderRadius.circular(20)),
            height: order.orderDetails!.length * 60,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
                color: order.orderType == 'delivery'
                    ? Color.fromRGBO(253, 237, 237, 1)
                    : order.orderType == 'take_away'
                        ? Color.fromRGBO(220, 244, 192, 1)
                        : order.restaurantTable != null &&
                                order.restaurantTable!.rtype == 'RM'
                            ? ColorTheme.roomCardBgColor
                            : Color.fromRGBO(254, 245, 208, 1)),
            margin: EdgeInsets.only(top: 20),
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
                              order.restaurantTable == null ||
                                      order.restaurantTable!.tableNo == ''
                                  ? order.orderType == 'delivery'
                                      ? 'Delivery'
                                      : order.orderType == 'take_away'
                                          ? 'Take Away'
                                          : order.userName != 'Mygenie' &&
                                                  order.userName != ''
                                              ? order.userName
                                              : 'WC'
                                  : order.restaurantTable?.title == ''
                                      ? '#${order.restaurantTable?.tableNo}'
                                      : '#${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 15, color: Colors.black),
                              maxLines: 2,
                            ),
                            if (Get.find<AuthController>()
                                .profileModel!
                                .role!
                                .contains('Manager'))
                              Text(
                                order.orderType == 'delivery' &&
                                        Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .isDeliveryAssign ==
                                            'Yes' &&
                                        order.deliveryMan != ''
                                    ? '${order.deliveryMan ?? ''}'
                                    : '${order.vendorEmployee?.waiterName ?? ''}',
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
                                    order.parentOrderId != null &&
                                            order.parentOrderId != '' &&
                                            order.parentOrderId != '0' &&
                                            (order.parentOrderId !=
                                                order.restaurantOrderId)
                                        ? '#${order.tablePart}-${order.parentOrderId}'
                                        : Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .settings!
                                                    .useDisplayToken ==
                                                'Yes'
                                            ? '${order.restaurantOrderId} (${order.tokenNo})'
                                            : '${order.restaurantOrderId}',
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
                      SizedBox(width: 3),
                      //Merge Table button
                      if (order.fOrderStatus != 7 &&
                          order.orderType != 'delivery' &&
                          order.orderType != 'take_away' &&
                          ((order.restaurantTable != null &&
                                  order.restaurantTable?.tableNo != '' &&
                                  order.restaurantTable?.rtype != 'RM') ||
                              order.tableId == 0) &&
                          (Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('merge_table')))
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
                              if (order.orderType != 'delivery' &&
                                  order.orderType != 'take_away' &&
                                  ((order.restaurantTable != null &&
                                          order.restaurantTable!.tableNo !=
                                              '' &&
                                          order.restaurantTable!.rtype !=
                                              'RM') ||
                                      order.tableId == 0))
                                Get.bottomSheet(mergeTable(context, order),
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    ignoreSafeArea: false);
                            },
                            child: SvgPicture.asset(
                              Images.ic_show_table,
                            ),
                          ),
                        ),
                      SizedBox(width: 15),
                      //Switch Table button
                      if (order.fOrderStatus == 7 &&
                          (order.scheduleAt == null ||
                              order.scheduleAt == '') &&
                          Get.find<AuthController>()
                              .profileModel!
                              .role!
                              .contains('confirm_order'))
                        InkWell(
                          onTap: () async {
                            Get.find<KdsController>().silentBuzzer();
                          },
                          child: Icon(
                            Icons.notifications_off_outlined,
                            color: ColorTheme.appColor,
                          ),
                        ),
                      if (Get.find<KdsController>().splitOrderList.isEmpty)
                        order.orderType != 'delivery' &&
                                order.orderType != 'take_away' &&
                                (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('transfer_table'))
                            ? order.fOrderStatus == 7
                                ? SizedBox.shrink()
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (order.restaurantTable != null &&
                                              order.restaurantTable!.rtype ==
                                                  'RM') ...[
                                            InkWell(
                                              onTap: () {
                                                searchOrder.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                showMoveRoomItemsDialog(order);
                                              },
                                              child: Icon(
                                                Icons.swap_horiz,
                                                color: ColorTheme.appColor,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          order.callWaiterInfo != null &&
                                              order.callWaiterInfo!.status ==
                                                  'pending'
                                          ? InkWell(
                                              onTap: () async {
                                                searchOrder.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();

                                                Map<String, dynamic> jsonBody =
                                                    {
                                                  'id': order.callWaiterInfo?.id
                                                      .toString(),
                                                };
                                                Get.find<KdsController>()
                                                    .attendTable(
                                                        jsonBody, callback);
                                              },
                                              child: SvgPicture.asset(
                                                height: 30,
                                                width: 30,
                                                Images.ic_attend_table,
                                                color: ColorTheme.appColor,
                                              ))
                                          : InkWell(
                                              onTap: () async {
                                                searchOrder.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();

                                                Get.find<CartController>()
                                                    .clearTableList();

                                                order.restaurantTable != null &&
                                                        order.restaurantTable!
                                                                .rtype ==
                                                            'RM'
                                                    ? await Get.find<
                                                            CartController>()
                                                        .getRoomList(
                                                            isShowLoader: false)
                                                    : await Get.find<
                                                            CartController>()
                                                        .getTableList(
                                                            isShowLoader:
                                                                false);

                                                Get.bottomSheet(
                                                    openTableList(
                                                        context, order),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    ignoreSafeArea: false);
                                              },
                                              child: SvgPicture.asset(
                                                Images.ic_switch_table,
                                              )),
                                        ],
                                      ),
                                      if (roomOrderAmount != 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7),
                                          child: Text(
                                            'Rs. ${roomOrderAmount.toStringAsFixed(2)}',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 11,
                                                color: Colors.black),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  )
                            : order.orderType == 'delivery'
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: InkWell(
                                        onTap: () async {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          showAddressDialog(order);
                                        },
                                        child: Icon(
                                            CupertinoIcons.location_solid,
                                            color: ColorTheme.appColor)),
                                  )
                                : SizedBox(width: 30),
                      if (order.orderType == 'take_away')
                        Text(
                          'Rs. ${double.parse(order.orderAmount!).toStringAsFixed(2)}',
                          style: poppinsMedium.copyWith(
                              fontSize: 11, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      // Expanded(
                      //   flex: 1,
                      //   child: Align(
                      //     alignment: Alignment.centerRight,
                      //     child: Text(
                      //       '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(tempDate)}',
                      //       style: poppinsMedium.copyWith(
                      //           fontSize: 9, color: Color.fromRGBO(193, 30, 30, 1)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                if (order.orderType != 'take_away' &&
                    ((order.restaurantTable == null) ||
                        (order.restaurantTable != null &&
                            order.restaurantTable!.rtype != 'RM')))
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7, right: 15),
                      child: Text(
                        'Rs. ${double.parse(order.orderAmount!).toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                SizedBox(height: 9),
                Divider(color: ColorTheme.hintText, height: 1),
                order.isShowCheckbox || order.isSplitTable
                    ? WaiterSelectOrdeItem(
                        orderItemList: order.orderDetails!, order: order)
                    : WaiterOrderFoodItem(
                        searchController: searchOrder,
                        flutterTts: flutterTit,
                        isWaiter: isWaiter,
                        orderItemList: order.orderDetails!,
                        order: order,
                        isPending: (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('food_transfer') ==
                                false)
                            ? false
                            : order.orderType == 'delivery'
                                ? false
                                : order.orderType == 'take_away'
                                    ? false
                                    : order.restaurantTable != null &&
                                            order.restaurantTable!.rtype == 'RM'
                                        ? false
                                        : true,
                      ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                order.orderNote == null || order.orderNote!.trim() == ''
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Notes  :',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 10,
                                      color: ColorTheme.kdsLeftMenuBlue),
                                ),
                                TextSpan(
                                  text: ' ${order.orderNote}',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 10, color: ColorTheme.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                order.orderNote == null || order.orderNote!.trim() == ''
                    ? const SizedBox.shrink()
                    : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.scheduleAt != null && order.scheduleAt != '')
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 0, left: 15, bottom: 10),
                      child: Text(
                        'Schedule : ${DateFormat('dd MMM, hh:mm a').format(DateTime.parse(order.scheduleAt!))}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                order.isSplitTable &&
                        Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('printer')
                    ? GetBuilder<KdsController>(builder: (kdsController) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: InkWell(
                              onTap: () async {
                                searchOrder.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                                splitCurrentPrintIndex = 0;
                                // if (!Get.find<KdsController>().isProcessing) {
                                splitCurrentPrintIndex =
                                    Get.find<KdsController>()
                                        .splitOrderList
                                        .indexOf(order);
                                isSplitSelectPrinterList!.clear();
                                isSplitPrintedList!.clear();
                                isSplitPrinterProccessingList!.clear();
                                for (var i = 0;
                                    i <
                                        Get.find<KdsController>()
                                            .splitOrderList
                                            .length;
                                    i++) {
                                  isSplitSelectPrinterList!.add(false);

                                  isSplitPrintedList!.add(false);
                                  isSplitPrinterProccessingList!.add(false);
                                  // if (widget.cartProductList[i].isNotEmpty) {
                                  //   printedTotal = printedTotal + 1;
                                  // }
                                }
                                isSplitSelectPrinterList![
                                    splitCurrentPrintIndex!] = true;
                                // kdsController.setProcessing(true);
                                if (printSplitBill != null) {
                                  printSplitBill!('1');
                                }
                                // Future.delayed(Duration(seconds: 8), () {
                                //   kdsController.setProcessing(false);
                                // });
                                // }
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset(
                                  Images.ic_print_kot,
                                  height: 26,
                                ),
                              )
                              // Image.asset(
                              //   Images.printKot,
                              //   alignment: Alignment.centerLeft,
                              //   height: 30,
                              //   color: ColorTheme.appColor,
                              // ),
                              ),
                        );
                      })
                    : (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('order') &&
                                Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('confirm_order')) &&
                            order.fOrderStatus == 7
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('order_cancel'))
                                InkWell(
                                  onTap: () {
                                    searchOrder.clear();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    // Get.bottomSheet(
                                    //   ConfirmationDialog(
                                    //       icon: Images.support,
                                    //       description:
                                    //           'Are you sure you want to cancel the complete order?',
                                    //       isLogOut: true,
                                    //       onYesPressed: () async {
                                    //         Map<String, dynamic> jsonBody = {
                                    //           'order_id': order.id.toString(),
                                    //           'order_status': 'cancelled',
                                    //           'role_name': Get.find<AuthController>()
                                    //               .profileModel
                                    //               .role
                                    //               .first,
                                    //         };
                                    //         Get.back();
                                    //         Get.find<KdsController>()
                                    //             .changeOrderStatus(jsonBody, callback);
                                    //       }),
                                    // );
                                    stopOrderAlert(order.id);

                                    Get.bottomSheet(
                                        CancelOrderDialog(
                                          cancelType: 'order',
                                          orderId: order.id.toString(),
                                          stations: [
                                            ...?order.orderDetails
                                                ?.map((e) => e.station ?? ''),
                                            ...?order.serveOrderDetails
                                                ?.map((e) => e.station ?? ''),
                                          ]
                                              .where((s) => s.isNotEmpty)
                                              .toSet()
                                              .toList(),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        ignoreSafeArea: false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 17),
                                    child: Icon(Icons.close,
                                        size: 35, color: ColorTheme.appColor),
                                  ),
                                ),
                              Spacer(),
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('order_edit'))
                                ThemeColorButton(
                                  onTap: () {
                                    searchOrder.clear();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    stopOrderAlert(order.id);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WalkInAddProduct(
                                                    editOrder: order)));
                                  },
                                  varticalPadding: 8,
                                  horizontalPadding:
                                      order.fOrderStatus == 2 ? 10 : 12,
                                  title: 'Edit',
                                ),
                              // if (order.restaurantTable != null &&
                              //     order.restaurantTable!.rtype == 'RM') ...[
                              //   SizedBox(width: 5),
                              //   ThemeColorButton(
                              //     title: 'Pay',
                              //     varticalPadding: 8,
                              //     horizontalPadding: 16,
                              //     onTap: () {
                              //       searchOrder.clear();
                              //       FocusManager.instance.primaryFocus
                              //           ?.unfocus();
                              //       showRecordRoomPaymentBottomSheet(order);
                              //     },
                              //   ),
                              // ],
                              SizedBox(width: 5),
                              ThemeColorButton(
                                onTap: () async {
                                  searchOrder.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  stopOrderAlert(order.id);

                                  Map<String, dynamic> jsonBody = {
                                    'order_id': order.id.toString(),
                                    'order_status': Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .defOrdStatus ==
                                            0
                                        ? 'new'
                                        : Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .defOrdStatus ==
                                                1
                                            ? 'cooking'
                                            : 'ready',
                                    'role_name': Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .first,
                                  };
                                  await Get.find<KdsController>()
                                      .acceptOrderStatus(jsonBody,
                                          (bool isSuccess,
                                              String message) async {
                                    if (isSuccess) {
                                      // showToast(message);
                                    } else {
                                      // showCustomSnackBar(message);
                                    }
                                  });
                                },
                                varticalPadding: 5,
                                horizontalPadding: 12,
                                title: 'Confirm',
                              ),
                              SizedBox(width: 17),
                            ],
                          )
                        : (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .isDeliveryAssign ==
                                    'Yes' &&
                                order.orderType == 'delivery' &&
                                Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('delivery_man') &&
                                Get.find<AuthController>()
                                        .profileModel!
                                        .empId ==
                                    order.deliveryManId &&
                                order.deliveryMan != '')
                            ? Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (order.deliveryManStatus == 'No')
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: ThemeColorButton(
                                            onTap: () {
                                              searchOrder.clear();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              Map<String, dynamic> jsonData = {
                                                'order_id': order.id,
                                                'delivery_man_id':
                                                    Get.find<AuthController>()
                                                        .profileModel!
                                                        .empId,
                                              };
                                              Get.find<DeliveryManController>()
                                                  .rejectDeliveryMan(jsonData,
                                                      (bool isSucces) {
                                                if (isSucces) {}
                                              });
                                            },
                                            varticalPadding: 8,
                                            horizontalPadding: 12,
                                            editPadding: order.fOrderStatus == 2
                                                ? 25
                                                : 10,
                                            title: 'Reject'),
                                      ),
                                    ThemeColorButton(
                                        onTap: () {
                                          searchOrder.clear();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          if (order.deliveryManStatus == 'No') {
                                            Map<String, dynamic> jsonBody = {
                                              'order_id': order.id.toString(),
                                              'order_status': 'serve',
                                              'delivery_man_status': 'Yes',
                                              'role_name': 'Manager',
                                            };
                                            Get.find<DeliveryManController>()
                                                .changeOrderStatus(
                                                    jsonBody, callback);
                                          } else {
                                            if (order.paymentType ==
                                                'prepaid') {
                                              Map<String, dynamic>
                                                  jsonBodyPrepaid = {
                                                'order_id': order.id.toString(),
                                                'payment_status': 'sucess',
                                              };
                                              Get.find<KdsController>()
                                                  .changePrepaidOrderStatus(
                                                      jsonBodyPrepaid,
                                                      callback);
                                            } else {
                                              Get.toNamed(
                                                RouteHelper
                                                    .getWaiterCollectPaymentRoute(
                                                        order.id.toString()),
                                              );
                                            }
                                          }
                                        },
                                        varticalPadding: 8,
                                        horizontalPadding: 12,
                                        editPadding:
                                            order.fOrderStatus == 2 ? 25 : 10,
                                        title: order.deliveryManStatus == 'No'
                                            ? 'Accept'
                                            : 'Deliver'),
                                    // SizedBox(width: 15),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  (Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('order'))
                                      ? Row(
                                          children: [
                                            Get.find<KdsController>()
                                                            .selectedSubMenu ==
                                                        2 &&
                                                    Get.find<KdsController>()
                                                        .splitOrderList
                                                        .isNotEmpty &&
                                                    Get.find<KdsController>()
                                                            .splitOrderList
                                                            .first
                                                            .id ==
                                                        order.id
                                                ? Get.find<KdsController>()
                                                        .splitOrderList
                                                        .first
                                                        .isShowCheckbox
                                                    ? SizedBox.shrink()
                                                    : Get.find<AuthController>()
                                                            .profileModel!
                                                            .role!
                                                            .contains('printer')
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  searchOrder
                                                                      .clear();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  splitCurrentPrintIndex =
                                                                      0;
                                                                  isSplitSelectPrinterList!
                                                                      .clear();
                                                                  isSplitPrintedList!
                                                                      .clear();
                                                                  isSplitPrinterProccessingList!
                                                                      .clear();
                                                                  for (var i =
                                                                          0;
                                                                      i <
                                                                          Get.find<KdsController>()
                                                                              .splitOrderList
                                                                              .length;
                                                                      i++) {
                                                                    isSplitSelectPrinterList!
                                                                        .add(i ==
                                                                                0
                                                                            ? true
                                                                            : false);
                                                                    isSplitPrintedList!
                                                                        .add(
                                                                            false);
                                                                    isSplitPrinterProccessingList!
                                                                        .add(
                                                                            false);
                                                                  }
                                                                  if (printSplitBill !=
                                                                      null) {
                                                                    printSplitBill!(
                                                                        '2');
                                                                  }
                                                                },
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    Images
                                                                        .ic_print_kot,
                                                                    height: 26,
                                                                  ),
                                                                )),
                                                          )
                                                        : SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Row(
                                                      children: [
                                                        ((Get.find<AuthController>()
                                                                .profileModel!
                                                                .role!
                                                                .contains(
                                                                    'print_icon')))
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  searchOrder
                                                                      .clear();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  List<List<OrderDetails>>
                                                                      cartProductList =
                                                                      [];
                                                                  cartProductList =
                                                                      [];
                                                                  for (var i =
                                                                          0;
                                                                      i <
                                                                          Get.find<AuthController>()
                                                                              .profileModel!
                                                                              .restaurantPrinterNew!
                                                                              .length;
                                                                      i++) {
                                                                    RestaurantPrinterNew
                                                                        printer =
                                                                        Get.find<AuthController>()
                                                                            .profileModel!
                                                                            .restaurantPrinterNew![i];
                                                                    List<OrderDetails>
                                                                        tempCartList =
                                                                        [];
                                                                    for (var e
                                                                        in order
                                                                            .orderDetails!) {
                                                                      if ((printer.areaName!.toUpperCase() == 'MASTER_KOT' || e.station == printer.areaName) &&
                                                                          (e.foodStatus !=
                                                                              3)) {
                                                                        tempCartList
                                                                            .add(e);
                                                                      }
                                                                    }
                                                                    cartProductList
                                                                        .add(
                                                                            tempCartList);
                                                                  }
                                                                  if (cartProductList
                                                                      .isNotEmpty) {
                                                                    await subscriptionBtStatus
                                                                        ?.cancel();
                                                                    if (order.restaurantTable !=
                                                                            null &&
                                                                        order.restaurantTable!.rtype ==
                                                                            'RM') {
                                                                    } else {
                                                                      showToast(
                                                                          'Please wait..');
                                                                      Get.find<
                                                                              LoadingController>()
                                                                          .startLoading(
                                                                              true);
                                                                      await Get.find<
                                                                              PosController>()
                                                                          .getCollectBillDetail({
                                                                        'order_id':
                                                                            '${order.id}'
                                                                      });
                                                                      Get.find<
                                                                              LoadingController>()
                                                                          .startLoading(
                                                                              false);
                                                                      if (Get.isBottomSheetOpen ??
                                                                          false)
                                                                        Get.back();
                                                                    }
                                                                    await Get.bottomSheet(
                                                                        PrintDialog(
                                                                          isBillPrint: order.restaurantTable != null && order.restaurantTable!.rtype == 'RM'
                                                                              ? false
                                                                              : true,
                                                                          collectBillResponse:
                                                                              Get.find<PosController>().getCollectBillDetailResponse,
                                                                          cartProductList:
                                                                              cartProductList,
                                                                          index: Get.find<KdsController>()
                                                                              .getWaiterOrderListResponse!
                                                                              .orders!
                                                                              .indexOf(order),
                                                                        ),
                                                                        backgroundColor: Colors.transparent,
                                                                        isScrollControlled: true,
                                                                        ignoreSafeArea: false);
                                                                  }
                                                                },
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    Images
                                                                        .ic_print_kot,
                                                                    height: 26,
                                                                  ),
                                                                )
                                                                // Image.asset(
                                                                //   Images.printKot,
                                                                //   alignment: Alignment.centerLeft,
                                                                //   height: 30,
                                                                //   color: ColorTheme.appColor,
                                                                // ),
                                                                )
                                                            : SizedBox.shrink(),
                                                        (order.restaurantTable !=
                                                                    null &&
                                                                order.restaurantTable!
                                                                        .rtype ==
                                                                    'RM')
                                                            ? SizedBox.shrink()
                                                            : SizedBox(
                                                                width: 10),
                                                        //WhatsApp button
                                                        (order.restaurantTable !=
                                                                    null &&
                                                                order.restaurantTable!
                                                                        .rtype ==
                                                                    'RM')
                                                            ? SizedBox.shrink()
                                                            : ((Get.find<
                                                                        AuthController>()
                                                                    .profileModel!
                                                                    .role!
                                                                    .contains(
                                                                        'whatsapp_icon')))
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      Get.bottomSheet(
                                                                          whatsAppBottomSheet(
                                                                              context,
                                                                              order:
                                                                                  order),
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          isScrollControlled:
                                                                              true,
                                                                          ignoreSafeArea:
                                                                              false);
                                                                    },
                                                                    child: Icon(
                                                                        FontAwesomeIcons
                                                                            .whatsapp,
                                                                        color: Colors
                                                                            .green,
                                                                        size:
                                                                            30),
                                                                  )
                                                                : SizedBox
                                                                    .shrink()
                                                      ],
                                                    ),
                                                  ),
                                            // if (order.isShowCheckbox)
                                            //   InkWell(
                                            //     onTap: () {
                                            //       searchOrder.clear();
                                            //       FocusManager.instance.primaryFocus
                                            //           ?.unfocus();

                                            //       Get.find<KdsController>()
                                            //           .clearSelectedFoodItem();
                                            //     },
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.only(left: 10),
                                            //       child: Icon(Icons.close,
                                            //           size: 35,
                                            //           color: ColorTheme.appColor),
                                            //     ),
                                            //   ),
                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains('order_cancel') &&
                                                ((((Get.find<AuthController>()
                                                                            .profileModel!
                                                                            .restaurants!
                                                                            .first
                                                                            .showOrderStatus ==
                                                                        2
                                                                    ? order.fOrderStatus! <=
                                                                        2
                                                                    : order.fOrderStatus! <
                                                                        2) ||
                                                                order.orderType ==
                                                                    'delivery' ||
                                                                order.orderType ==
                                                                    'take_away') &&
                                                            (cookingFoodItemLenght ==
                                                                order
                                                                    .orderDetails!
                                                                    .length) ||
                                                        Get.find<AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .showOrderStatus ==
                                                            5) ||
                                                    order.orderType ==
                                                        'delivery' ||
                                                    order.orderType ==
                                                        'take_away' ||
                                                    (order.paymentId == '' &&
                                                        order.paymentType ==
                                                            'prepaid')))
                                              InkWell(
                                                onTap: () {
                                                  searchOrder.clear();
                                                  Get.bottomSheet(
                                                      CancelOrderDialog(
                                                        cancelType: 'order',
                                                        orderId:
                                                            order.id.toString(),
                                                        stations: [
                                                          ...?order.orderDetails
                                                              ?.map((e) =>
                                                                  e.station ??
                                                                  ''),
                                                          ...?order
                                                              .serveOrderDetails
                                                              ?.map((e) =>
                                                                  e.station ??
                                                                  ''),
                                                        ]
                                                            .where((s) =>
                                                                s.isNotEmpty)
                                                            .toSet()
                                                            .toList(),
                                                      ),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      ignoreSafeArea: false);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0),
                                                  child: Icon(Icons.close,
                                                      size: 35,
                                                      color:
                                                          ColorTheme.appColor),
                                                ),
                                              ),
                                          ],
                                        )
                                      : SizedBox.shrink(),
                                  Spacer(),
                                  Row(
                                    children: [
                                      order.paymentType != 'prepaid' &&
                                              order.fOrderStatus == 2 &&
                                              (Get.find<AuthController>()
                                                  .profileModel!
                                                  .role!
                                                  .contains('order_edit')) &&
                                              Get.find<KdsController>()
                                                      .selectedSubMenu ==
                                                  4
                                          ? (order.parentOrderId != null &&
                                                      order.parentOrderId !=
                                                          '' &&
                                                      order.parentOrderId !=
                                                          '0' &&
                                                      (order.parentOrderId !=
                                                          order
                                                              .restaurantOrderId) ||
                                                  order.isPaymentLinkSent ==
                                                      'Yes')
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5),
                                                  child: ThemeColorButton(
                                                    varticalPadding: 8,
                                                    horizontalPadding:
                                                        order.fOrderStatus == 2
                                                            ? 16
                                                            : 35,
                                                    onTap: () async {
                                                      searchOrder.clear();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();

                                                      Get.find<CartController>()
                                                          .clearCartList();
                                                      if (MediaQuery.of(context)
                                                                  .size
                                                                  .shortestSide >
                                                              570 ||
                                                          GetPlatform
                                                              .isWindows) {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    TabletPosScreen(
                                                                        editOrder:
                                                                            order)));
                                                      } else {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WaiterPosScreen(
                                                                        editOrder:
                                                                            order)));
                                                      }
                                                    },
                                                    title: 'Edit',
                                                  ),
                                                )
                                          : SizedBox.shrink(),
                                      if (order.fOrderStatus == 1 &&
                                          Get.find<AuthController>()
                                              .profileModel!
                                              .role!
                                              .contains('Ready'))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 8),
                                          child: ThemeColorButton(
                                            title: 'Ready',
                                            varticalPadding: 8,
                                            horizontalPadding: 12,
                                            onTap: () {
                                              Map<String, dynamic> jsonBody = {
                                                'order_id': order.id.toString(),
                                                'role_name': 'Manager',
                                                'order_status': 'ready'
                                              };
                                              Get.find<KdsController>()
                                                  .changeOrderStatus(
                                                      jsonBody, callback);
                                            },
                                          ),
                                        ),
                                      // if (order.restaurantTable != null &&
                                      //     order.restaurantTable!.rtype == 'RM')
                                      //   Padding(
                                      //     padding: const EdgeInsets.only(
                                      //         left: 5, right: 8),
                                      //     child: ThemeColorButton(
                                      //       title: 'Pay',
                                      //       varticalPadding: 8,
                                      //       horizontalPadding: 16,
                                      //       onTap: () {
                                      //         searchOrder.clear();
                                      //         FocusManager.instance.primaryFocus
                                      //             ?.unfocus();
                                      //         showRecordRoomPaymentBottomSheet(
                                      //             order);
                                      //       },
                                      //     ),
                                      //   ),
                                      order.isShowCheckbox
                                          ? SizedBox.shrink()
                                          : order.fOrderStatus != 2 &&
                                                  (Get.find<KdsController>().selectedSubMenu ==
                                                      4) &&
                                                  order.paymentType == 'prepaid'
                                              ? SizedBox.shrink()
                                              : (Get.find<AuthController>()
                                                          .profileModel!
                                                          .role!
                                                          .contains(order.fOrderStatus ==
                                                                  2
                                                              ? 'order'
                                                              : 'order_edit') &&
                                                      (Get.find<AuthController>()
                                                                      .profileModel!
                                                                      .restaurants!
                                                                      .first
                                                                      .isDeliveryAssign ==
                                                                  'Yes' &&
                                                              order.orderType ==
                                                                  'delivery'
                                                          ? (Get.find<AuthController>()
                                                              .profileModel!
                                                              .role!
                                                              .contains(
                                                                  'assign_online_order'))
                                                          : true))
                                                  ? ((order.parentOrderId != null &&
                                                              order.parentOrderId !=
                                                                  '' &&
                                                              order.parentOrderId !=
                                                                  '0' &&
                                                              (order.parentOrderId !=
                                                                  order.restaurantOrderId)) ||
                                                          (order.fOrderStatus != 2 && order.isPaymentLinkSent == 'Yes'))
                                                      ? SizedBox.shrink()
                                                      : ThemeColorButton(
                                                          color: order.fOrderStatus ==
                                                                      2 &&
                                                                  order.orderType ==
                                                                      'delivery' &&
                                                                  Get.find<AuthController>()
                                                                          .profileModel!
                                                                          .restaurants!
                                                                          .first
                                                                          .isDeliveryAssign ==
                                                                      'Yes' &&
                                                                  order.deliveryManStatus ==
                                                                      'Yes'
                                                              ? ColorTheme.green
                                                              : null,
                                                          onTap: () async {
                                                            print(
                                                                'windows/tablet edit button');
                                                            searchOrder.clear();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();

                                                            if (order
                                                                    .fOrderStatus ==
                                                                2) {
                                                              Map<String,
                                                                      dynamic>
                                                                  jsonBody = {
                                                                'order_id': order
                                                                    .id
                                                                    .toString(),
                                                                'order_status':
                                                                    'serve',
                                                                'role_name': Get
                                                                        .find<
                                                                            AuthController>()
                                                                    .profileModel!
                                                                    .role!
                                                                    .first,
                                                              };

                                                              if (order.orderType ==
                                                                      'delivery' ||
                                                                  order.orderType ==
                                                                      'take_away') {
                                                                subscriptionBtStatus
                                                                    ?.cancel();
                                                                Get.find<
                                                                        KdsController>()
                                                                    .resetSplitBill();
                                                                if (Get.find<AuthController>()
                                                                            .profileModel!
                                                                            .restaurants!
                                                                            .first
                                                                            .isDeliveryAssign ==
                                                                        'Yes' &&
                                                                    order.orderType ==
                                                                        'delivery') {
                                                                  await Get.find<
                                                                          DeliveryManController>()
                                                                      .getDeliveryManList();

                                                                  Get.bottomSheet(
                                                                      assignDeliveryBoy(
                                                                          context,
                                                                          order),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      isScrollControlled:
                                                                          true,
                                                                      ignoreSafeArea:
                                                                          false);
                                                                } else {
                                                                  if (order
                                                                          .paymentType ==
                                                                      'prepaid') {
                                                                    Map<String,
                                                                            dynamic>
                                                                        jsonBodyPrepaid =
                                                                        {
                                                                      'order_id':
                                                                          order
                                                                              .id
                                                                              .toString(),
                                                                      'payment_status':
                                                                          'sucess',
                                                                    };
                                                                    Get.find<
                                                                            KdsController>()
                                                                        .changePrepaidOrderStatus(
                                                                            jsonBodyPrepaid,
                                                                            callback);
                                                                  } else {
                                                                    if (order
                                                                            .orderType ==
                                                                        'delivery') {
                                                                      jsonBody[
                                                                              'order_dispatch_status'] =
                                                                          'Yes';
                                                                      Get.find<KdsController>().changeOrderStatus(
                                                                          jsonBody,
                                                                          callback);
                                                                    } else {
                                                                      Get.toNamed(
                                                                          RouteHelper.getWaiterCollectPaymentRoute(order
                                                                              .id
                                                                              .toString()));
                                                                    }
                                                                  }
                                                                }
                                                              } else if (order
                                                                      .paymentType ==
                                                                  'prepaid') {
                                                                Map<String,
                                                                        dynamic>
                                                                    jsonBodyPrepaid =
                                                                    {
                                                                  'order_id': order
                                                                      .id
                                                                      .toString(),
                                                                  'payment_status':
                                                                      'sucess',
                                                                };
                                                                Get.find<
                                                                        KdsController>()
                                                                    .changePrepaidOrderStatus(
                                                                        jsonBodyPrepaid,
                                                                        callback);
                                                              } else {
                                                                if (Get.find<
                                                                            AuthController>()
                                                                        .profileModel!
                                                                        .restaurants!
                                                                        .first
                                                                        .isComplementry ==
                                                                    'Yes') {
                                                                  showToast(
                                                                      'Please wait..');
                                                                  Get.find<
                                                                          LoadingController>()
                                                                      .startLoading(
                                                                          true);
                                                                  Map<String,
                                                                          dynamic>
                                                                      jsonData =
                                                                      {
                                                                    'waiter_id': Get.find<
                                                                            AuthController>()
                                                                        .profileModel!
                                                                        .empId
                                                                        .toString(),
                                                                    'payment_mode':
                                                                        'cash',
                                                                    'paid_room':
                                                                        '',
                                                                    'payment_status':
                                                                        'sucess',
                                                                    'email': '',
                                                                    'payment_amount':
                                                                        0,
                                                                    'grant_amount':
                                                                        0,
                                                                    'vat_tax':
                                                                        0,
                                                                    'gst_tax':
                                                                        0,
                                                                    'self_discount':
                                                                        0,
                                                                    'comm_discount':
                                                                        0,
                                                                    'tip_amount':
                                                                        '0',
                                                                    'order_discount':
                                                                        0,
                                                                    'mobile':
                                                                        '',
                                                                    'name': '',
                                                                    'restaurant_name': Get.find<
                                                                            AuthController>()
                                                                        .profileModel!
                                                                        .restaurants![
                                                                            0]
                                                                        .name,
                                                                    'service_tax':
                                                                        0,
                                                                    'transaction_id':
                                                                        '',
                                                                    'order_id':
                                                                        order.id
                                                                  };
                                                                  Get.find<PosController>().collectPayment(
                                                                      (bool isSuccess,
                                                                          String
                                                                              msg) async {
                                                                    Get.find<
                                                                            LoadingController>()
                                                                        .startLoading(
                                                                            false);
                                                                    await Get.find<
                                                                            LoadingController>()
                                                                        .changeText(
                                                                            data:
                                                                                msg);
                                                                    await Get.find<
                                                                            LoadingController>()
                                                                        .changeStatus(
                                                                            data:
                                                                                true);
                                                                  },
                                                                      jsonData:
                                                                          jsonData);
                                                                } else {
                                                                  Get.find<
                                                                          KdsController>()
                                                                      .changeOrderStatus(
                                                                          jsonBody,
                                                                          callback);
                                                                }
                                                              }
                                                            } else if (Get.find<
                                                                        KdsController>()
                                                                    .selectedSubMenu ==
                                                                4) {
                                                              Get.find<
                                                                      KdsController>()
                                                                  .resetSplitBill();
                                                              Get.find<
                                                                      CartController>()
                                                                  .clearCartList();
                                                              if (MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .shortestSide >
                                                                      570 ||
                                                                  GetPlatform
                                                                      .isWindows) {
                                                                print(
                                                                    'here it goes on next screen from edit in windows/tablet');
                                                                await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                TabletPosScreen(editOrder: order)));
                                                              } else {
                                                                await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                WaiterPosScreen(editOrder: order)));
                                                              }
                                                            }
                                                          },
                                                          varticalPadding: 8,
                                                          horizontalPadding: order
                                                                      .fOrderStatus ==
                                                                  2
                                                              ? order.orderType ==
                                                                      'delivery'
                                                                  ? 14
                                                                  : 18
                                                              : 12,
                                                          editPadding:
                                                              order.fOrderStatus ==
                                                                      2
                                                                  ? 25
                                                                  : 10,
                                                          title: order.fOrderStatus ==
                                                                  2
                                                              ? order.orderType ==
                                                                      'delivery'
                                                                  ? Get.find<AuthController>()
                                                                              .profileModel!
                                                                              .restaurants!
                                                                              .first
                                                                              .isDeliveryAssign ==
                                                                          'Yes'
                                                                      ? order.deliveryMan ==
                                                                              ''
                                                                          ? 'Assign'
                                                                          : 'Re-Assign'
                                                                      : 'Dispatch'
                                                                  : 'Serve'.tr
                                                              : 'Edit',
                                                        )
                                                  : SizedBox.shrink(),
                                      order.fOrderStatus == 5
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 18),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // SizedBox(width: 5),
                                                  if ((Get.find<AuthController>()
                                                              .profileModel!
                                                              .role!
                                                              .contains(
                                                                  'bill') ||
                                                          Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .role!
                                                              .contains(
                                                                  'clear_payment')) &&
                                                      !order.isShowCheckbox &&
                                                      (Get.find<AuthController>()
                                                                      .profileModel!
                                                                      .restaurants!
                                                                      .first
                                                                      .isDeliveryAssign ==
                                                                  'Yes' &&
                                                              order.orderType ==
                                                                  'delivery'
                                                          ? (Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .role!
                                                              .contains(
                                                                  'assign_online_order'))
                                                          : true))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: ThemeColorButton(
                                                        varticalPadding: 8,
                                                        horizontalPadding: 8,
                                                        onTap: () async {
                                                          searchOrder.clear();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          subscriptionBtStatus
                                                              ?.cancel();
                                                          Get.find<
                                                                  KdsController>()
                                                              .resetSplitBill();
                                                          if (Get.find<AuthController>()
                                                                      .profileModel!
                                                                      .restaurants!
                                                                      .first
                                                                      .isDeliveryAssign ==
                                                                  'Yes' &&
                                                              order.orderType ==
                                                                  'delivery') {
                                                            await Get.find<
                                                                    DeliveryManController>()
                                                                .getDeliveryManList();

                                                            Get.bottomSheet(
                                                                assignDeliveryBoy(
                                                                    context,
                                                                    order),
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isScrollControlled:
                                                                    true,
                                                                ignoreSafeArea:
                                                                    false);
                                                          } else {
                                                            if (order.orderType ==
                                                                    'delivery' &&
                                                                order.deliveryDispatchStatus ==
                                                                    'No') {
                                                              Map<String,
                                                                      dynamic>
                                                                  jsonBody = {
                                                                'order_id': order
                                                                    .id
                                                                    .toString(),
                                                                'order_status':
                                                                    'serve',
                                                                'role_name': Get
                                                                        .find<
                                                                            AuthController>()
                                                                    .profileModel!
                                                                    .role!
                                                                    .first,
                                                              };
                                                              jsonBody[
                                                                      'order_dispatch_status'] =
                                                                  'Yes';
                                                              Get.find<
                                                                      KdsController>()
                                                                  .changeOrderStatus(
                                                                      jsonBody,
                                                                      callback);
                                                            } else {
                                                              if (order
                                                                      .paymentType ==
                                                                  'prepaid') {
                                                                Map<String,
                                                                        dynamic>
                                                                    jsonBodyPrepaid =
                                                                    {
                                                                  'order_id': order
                                                                      .id
                                                                      .toString(),
                                                                  'payment_status':
                                                                      'sucess',
                                                                };
                                                                Get.find<
                                                                        KdsController>()
                                                                    .changePrepaidOrderStatus(
                                                                        jsonBodyPrepaid,
                                                                        callback);
                                                              } else {
                                                                Get.toNamed(RouteHelper
                                                                    .getWaiterCollectPaymentRoute(
                                                                        order.id
                                                                            .toString()));
                                                              }
                                                            }
                                                          }
                                                        },
                                                        color: order.orderType ==
                                                                    'delivery' &&
                                                                Get.find<AuthController>()
                                                                        .profileModel!
                                                                        .restaurants!
                                                                        .first
                                                                        .isDeliveryAssign ==
                                                                    'Yes'
                                                            ? ColorTheme.green
                                                            : null,
                                                        title: order.orderType ==
                                                                'delivery'
                                                            ? Get.find<AuthController>()
                                                                        .profileModel!
                                                                        .restaurants!
                                                                        .first
                                                                        .isDeliveryAssign ==
                                                                    'Yes'
                                                                ? order.deliveryMan ==
                                                                        ''
                                                                    ? 'Assign'
                                                                    : 'Re-Assign'
                                                                // : order.paymentType ==
                                                                //         'prepaid'
                                                                //     ? 'Settle'
                                                                : order.deliveryDispatchStatus ==
                                                                        'No'
                                                                    ? 'Dispatch'
                                                                    : 'Deliver'
                                                            : order.restaurantTable !=
                                                                        null &&
                                                                    order.restaurantTable!
                                                                            .rtype ==
                                                                        'RM'
                                                                ? 'Check-out'
                                                                : order.paymentType ==
                                                                        'prepaid'
                                                                    ? order.orderType ==
                                                                            'take_away'
                                                                        ? 'Handover'
                                                                        : 'Settle'
                                                                    : 'Collect Bill',
                                                      ),
                                                    ),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .role!
                                                          .contains('bill') &&
                                                      order.orderType !=
                                                          'delivery' &&
                                                      order
                                                              .orderType !=
                                                          'take_away' &&
                                                      (order.restaurantTable ==
                                                              null ||
                                                          (order.restaurantTable !=
                                                                  null &&
                                                              order.restaurantTable!
                                                                      .rtype !=
                                                                  'RM')))
                                                    order.parentOrderId !=
                                                                null &&
                                                            order.parentOrderId !=
                                                                '' &&
                                                            order.parentOrderId !=
                                                                '0' &&
                                                            (order.parentOrderId !=
                                                                order
                                                                    .restaurantOrderId)
                                                        ? SizedBox.shrink()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child:
                                                                ThemeColorButton(
                                                              varticalPadding:
                                                                  8,
                                                              horizontalPadding:
                                                                  10,
                                                              onTap: () {
                                                                searchOrder
                                                                    .clear();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();

                                                                if (order
                                                                    .isShowCheckbox) {
                                                                  Get.find<
                                                                          KdsController>()
                                                                      .splitOrder();
                                                                } else {
                                                                  Get.find<
                                                                          KdsController>()
                                                                      .selectSplitOrder(
                                                                          order);
                                                                }
                                                              },
                                                              title: 'Split',
                                                            ),
                                                          ),
                                                  if (order.isShowCheckbox)
                                                    SizedBox(width: 10),
                                                  if (order.isShowCheckbox)
                                                    ThemeColorButton(
                                                      varticalPadding: 8,
                                                      horizontalPadding: 10,
                                                      onTap: () {
                                                        searchOrder.clear();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();

                                                        Get.find<
                                                                KdsController>()
                                                            .resetSplitBill();
                                                      },
                                                      title: 'Reset',
                                                    ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(width: 18),
                                    ],
                                  ),
                                ],
                              ),
              ],
            ),
          );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // showToast(message);
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
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                              'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
                              style: poppinsMedium.copyWith(fontSize: 14)),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () async {
                                Get.back();
                                final phoneNumber = order
                                        .deliveryAddress?.contactPersonNumber ??
                                    '';
                                if (phoneNumber.isNotEmpty) {
                                  final Uri callUri =
                                      Uri(scheme: 'tel', path: phoneNumber);
                                  if (await canLaunchUrl(callUri)) {
                                    await launchUrl(callUri);
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Could not open dialer",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } else {
                                  Get.snackbar(
                                    "No Number",
                                    "Phone number not available",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.phone,
                                color: ColorTheme.appColor,
                                size: 20,
                              ))
                        ],
                      ),
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
                                style: poppinsMedium.copyWith(fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: InkWell(
                              onTap: () async {
                                if (order.deliveryAddress != null &&
                                    order.deliveryAddress!.latitude != null &&
                                    order.deliveryAddress!.longitude != null &&
                                    order.deliveryAddress!.latitude!
                                        .isNotEmpty &&
                                    order.deliveryAddress!.longitude!
                                        .isNotEmpty) {
                                  final latitude = double.tryParse(
                                      order.deliveryAddress!.latitude!);
                                  final longitude = double.tryParse(
                                      order.deliveryAddress!.longitude!);
                                  if (latitude != null && longitude != null) {
                                    final isGoogleAvailable =
                                        await MapLauncher.isMapAvailable(
                                            MapType.google);
                                    if (isGoogleAvailable == true) {
                                      await MapLauncher.showDirections(
                                        mapType: MapType.google,
                                        destination:
                                            Coords(latitude, longitude),
                                      );
                                    } else {
                                      final isAppleAvailable =
                                          await MapLauncher.isMapAvailable(
                                              MapType.apple);
                                      if (isAppleAvailable == true) {
                                        await MapLauncher.showDirections(
                                          mapType: MapType.apple,
                                          destination:
                                              Coords(latitude, longitude),
                                        );
                                      }
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
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                          'House No/Flat No.: ${order.deliveryAddress?.house ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),

                      const SizedBox(height: 5),

                      Text('Pincode: ${order.deliveryAddress?.pincode ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
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

  Widget openTableList(BuildContext context, OrderList order) {
    // List<TableResponseModel> tableList = Get.find<CartController>()
    //     .tableList
    //     .where((element) => element.type == 'TB');
    TextEditingController searchTable = TextEditingController();
    TableResponseModel? tableIdSelect;
    List<TableResponseModel> tableList = [];
    List<TableResponseModel> roomList = [];
    if (order.restaurantTable != null && order.restaurantTable!.rtype == 'RM') {
      roomList = Get.find<CartController>()
          .roomList
          .where((item) => item.type == 'RM')
          .toList();
    } else {
      roomList = Get.find<CartController>()
          .roomList
          .where((item) => item.type == 'RM')
          .toList();
      tableList = Get.find<CartController>()
          .tableList
          .where((item) => item.type == 'TB')
          .toList();
    }
    return SafeArea(
      child: Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        ),
        child: GetBuilder(builder: (RestaurantController restaurantController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      order.restaurantTable != null &&
                              order.restaurantTable!.rtype == 'RM'
                          ? 'Select Room'
                          : 'Select Table',
                      style: poppinsMedium.copyWith(
                          color: Colors.black, fontSize: 18)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        searchOrder.clear();
                        FocusManager.instance.primaryFocus?.unfocus();

                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: ColorTheme.appColor,
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: ColorTheme.borderGrey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 40,
                child: TextField(
                  controller: searchTable,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                    suffixIcon: Icon(
                      Icons.search,
                      color: ColorTheme.appColor,
                      size: 25,
                    ),
                    hintText: 'Search',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                  ),
                  onChanged: (value) async {
                    if (searchTable.text.isNotEmpty) {
                      if (order.restaurantTable != null &&
                          order.restaurantTable!.rtype == 'RM') {
                        roomList = Get.find<CartController>()
                            .roomList
                            .where((item) =>
                                item.type == 'RM' &&
                                (item.title.toLowerCase().contains(
                                        searchTable.text.toLowerCase()) ||
                                    item.tableNo.toLowerCase().contains(
                                        searchTable.text.toLowerCase())))
                            .toList();
                      } else {
                        roomList = Get.find<CartController>()
                            .roomList
                            .where((item) =>
                                item.type == 'RM' &&
                                (item.title.toLowerCase().contains(
                                        searchTable.text.toLowerCase()) ||
                                    item.tableNo.toLowerCase().contains(
                                        searchTable.text.toLowerCase())))
                            .toList();
                        tableList = Get.find<CartController>()
                            .tableList
                            .where((item) =>
                                item.type == 'TB' &&
                                (item.title.toLowerCase().contains(
                                        searchTable.text.toLowerCase()) ||
                                    item.tableNo.toLowerCase().contains(
                                        searchTable.text.toLowerCase())))
                            .toList();
                      }
                      // tableList = tableList
                      //     .where((item) => (item.title
                      //             .toLowerCase()
                      //             .contains(searchTable.text.toLowerCase()) ||
                      //         item.tableNo
                      //             .toLowerCase()
                      //             .contains(searchTable.text.toLowerCase())))
                      //     .toList();
                    } else {
                      if (order.restaurantTable != null &&
                          order.restaurantTable!.rtype == 'RM') {
                        roomList = Get.find<CartController>()
                            .roomList
                            .where((item) => item.type == 'RM')
                            .toList();
                      } else {
                        roomList = Get.find<CartController>()
                            .roomList
                            .where((item) => item.type == 'RM')
                            .toList();
                        tableList = Get.find<CartController>()
                            .tableList
                            .where((item) => item.type == 'TB')
                            .toList();
                      }
                    }
                    restaurantController.update();
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (tableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: tableList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 7,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  searchOrder.clear();
                                  // tableIndex = index;
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  tableIdSelect = tableList[index];
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: tableIdSelect == tableList[index]
                                          ? ColorTheme.appColor
                                          : ColorTheme.tableBoxGrey,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              tableIdSelect == tableList[index]
                                                  ? ColorTheme.appColor
                                                  : ColorTheme.borderGrey)),
                                  child: Center(
                                    child: Text(
                                        '${tableList[index].title} ${tableList[index].tableNo} ',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 10,
                                            color: tableIdSelect ==
                                                    tableList[index]
                                                ? Colors.white
                                                : ColorTheme.hintText)),
                                  ),
                                ));
                          },
                        ),
                      ),
                    if (tableList.isNotEmpty &&
                        roomList.isNotEmpty &&
                        order.restaurantTable != null &&
                        order.restaurantTable!.rtype == 'RM')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Divider(
                          thickness: 1,
                          color: ColorTheme.appColor,
                        ),
                      ),
                    // if (roomList.isNotEmpty &&
                    //   order.restaurantTable != null &&
                    //   order.restaurantTable.rtype == 'RM')
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 10, top: 8),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text('Room List ',
                    //         style: poppinsMedium.copyWith(
                    //             fontSize: 15, color: ColorTheme.appColor)),
                    //   ),
                    // ),
                    if (roomList.isNotEmpty &&
                        order.restaurantTable != null &&
                        order.restaurantTable!.rtype == 'RM')
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: roomList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  mainAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  searchOrder.clear();
                                  // tableIndex = index;
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  tableIdSelect = roomList[index];
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: tableIdSelect == roomList[index]
                                          ? ColorTheme.appColor
                                          : Color(0xFFECECEC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              tableIdSelect == roomList[index]
                                                  ? ColorTheme.appColor
                                                  : Color(0xFFC6C6C6))),
                                  child: Text(
                                      '${roomList[index].title} ${roomList[index].tableNo} ',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color:
                                              tableIdSelect == roomList[index]
                                                  ? Colors.white
                                                  : ColorTheme.hintText)),
                                ));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            CustomButton(
              width: Get.width / 2.0,
              buttonText: 'Done',
              onPressed: () async {
                Map<String, dynamic> jsonData = {
                  'order_id': order.id,
                  'old_table_id':
                      order.tableId == null ? '0' : '${order.tableId}',
                  'new_table_id': tableIdSelect!.id
                };
                Get.find<CartController>().changeTable(
                    tableIdSelect!.type, jsonData, (bool isSucces) async {
                  if (isSucces) {
                    await Get.find<TableController>().setValueOfTableFromSocket(
                        tableId: order.tableId?.toString() ?? '', value: 'No');
                    await Get.find<TableController>().setValueOfTableFromSocket(
                        tableId: tableIdSelect!.id.toString(), value: 'Yes');
                    order.tableId = tableIdSelect!.id;
                    order.restaurantTable = RestaurantTable(
                        id: tableIdSelect!.id,
                        rtype: tableIdSelect!.type,
                        tableNo: tableIdSelect!.tableNo,
                        title: tableIdSelect!.title);
                    if (Get.isBottomSheetOpen ?? false) Get.back();
                    Get.find<KdsController>().update();

                    // order.tableId = tableIdSelect.id;
                    // order.restaurantTable.tableNo = tableIdSelect.tableNo;
                    // order.restaurantTable.title = tableIdSelect.title;
                    // Get.find<KdsController>().update();
                    // showErrorToast(
                    //     tableIdSelect.type == 'RM'
                    //         ? 'Room change successfully'
                    //         : 'Table change successfully',
                    //     isError: false);
                  } else {
                    // showErrorToast(
                    //     tableIdSelect.type == 'RM'
                    //         ? 'Failed room changed'
                    //         : 'Failed table changed',
                    //     isError: false);
                  }
                });
                // Get.back();
              },
            ),
          ]);
        }),
      ),
    );
  }

  Widget mergeTable(BuildContext context, OrderList orderDetail) {
    String? selectedOrderId;
    String? selectedTableName;
    List<OrderList> orderList = [];
    TextEditingController searchTable = TextEditingController();
    bool isSwitchNote = false;
    if (Get.find<KdsController>().getWaiterOrderListResponse != null)
      orderList = Get.find<KdsController>()
          .getWaiterOrderListResponse!
          .orders!
          .where((element) =>
              element.orderType != 'delivery' &&
              element.fOrderStatus != 3 &&
              element.fOrderStatus != 6 &&
              element.orderType != 'take_away' &&
              element.id != order.id &&
              ((element.restaurantTable != null &&
                      element.restaurantTable!.tableNo != '' &&
                      element.restaurantTable!.rtype != 'RM') ||
                  element.tableId == 0))
          .toList();
    return SafeArea(
      child: Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        ),
        child: GetBuilder(builder: (RestaurantController restaurantController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order.restaurantTable == null ||
                              order.restaurantTable!.tableNo == ''
                          ? order.orderType == 'delivery'
                              ? 'Delivery'
                              : order.orderType == 'take_away'
                                  ? 'Take Away'
                                  : order.userName != 'Mygenie' &&
                                          order.userName != ''
                                      ? order.userName
                                      : 'WC'
                          : order.restaurantTable?.title == ''
                              ? '#${order.restaurantTable?.tableNo}'
                              : '#${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Merge Table',
                      style: poppinsMedium.copyWith(
                          fontSize: 11, color: Colors.black),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        searchOrder.clear();
                        FocusManager.instance.primaryFocus?.unfocus();

                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: ColorTheme.appColor,
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: ColorTheme.borderGrey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 40,
                child: TextField(
                  controller: searchTable,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                    suffixIcon: Icon(
                      Icons.search,
                      color: ColorTheme.appColor,
                      size: 25,
                    ),
                    hintText: 'Search',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                  ),
                  onChanged: (value) async {
                    if (searchTable.text.isNotEmpty) {
                      orderList = Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders!
                          .where((item) => (item.id != orderDetail.id &&
                              item.orderType != 'delivery' &&
                              item.orderType != 'take_away' &&
                              item.fOrderStatus != 3 &&
                              item.fOrderStatus != 6 &&
                              (((item.restaurantTable == null ||
                                          item.restaurantTable!.tableNo ==
                                              '') &&
                                      item.userName.toLowerCase().contains(
                                          searchTable.text.toLowerCase())) ||
                                  (item.restaurantTable != null &&
                                      item.restaurantTable!.tableNo != '' &&
                                      item.restaurantTable!.rtype != 'RM' &&
                                      item.restaurantTable!.tableNo!
                                          .toLowerCase()
                                          .contains(searchTable.text
                                              .toLowerCase())))))
                          .toList();
                    } else {
                      orderList = Get.find<KdsController>()
                          .getWaiterOrderListResponse!
                          .orders!
                          .where((element) =>
                              element.orderType != 'delivery' &&
                              element.orderType != 'take_away' &&
                              element.fOrderStatus != 3 &&
                              element.fOrderStatus != 6 &&
                              element.id != orderDetail.id &&
                              ((element.restaurantTable != null &&
                                      element.restaurantTable!.tableNo != '' &&
                                      element.restaurantTable!.rtype != 'RM') ||
                                  element.tableId == 0))
                          .toList();
                    }
                    restaurantController.update();
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderList.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 7,
                            childAspectRatio: 1.8,
                            mainAxisSpacing: 7,
                            crossAxisCount: 3),
                        itemBuilder: (BuildContext context, int index) {
                          OrderList order = orderList[index];
                          return InkWell(
                              onTap: () {
                                searchOrder.clear();
                                // tableIndex = index;
                                FocusManager.instance.primaryFocus?.unfocus();

                                selectedOrderId = order.id!;
                                selectedTableName = order.restaurantTable ==
                                            null ||
                                        order.restaurantTable!.tableNo == ''
                                    ? order.orderType == 'delivery'
                                        ? 'Delivery'
                                        : order.orderType == 'take_away'
                                            ? 'Take Away'
                                            : order.userName != 'Mygenie' &&
                                                    order.userName != ''
                                                ? order.userName
                                                : 'WC'
                                    : order.restaurantTable!.title == ''
                                        ? '${order.restaurantTable!.tableNo}'
                                        : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}';

                                restaurantController.update();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: selectedOrderId == order.id
                                        ? ColorTheme.appColor
                                        : ColorTheme.tableBoxGrey,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: selectedOrderId == order.id
                                            ? ColorTheme.appColor
                                            : ColorTheme.borderGrey)),
                                child: Center(
                                  child: Text(
                                      order.restaurantTable == null ||
                                              order.restaurantTable!.tableNo ==
                                                  ''
                                          ? order.orderType == 'delivery'
                                              ? 'Delivery'
                                              : order.orderType == 'take_away'
                                                  ? 'Take Away'
                                                  : order.userName !=
                                                              'Mygenie' &&
                                                          order.userName != ''
                                                      ? order.userName
                                                      : 'WC'
                                          : order.restaurantTable!.title == ''
                                              ? '${order.restaurantTable!.tableNo}'
                                              : '${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color: selectedOrderId == order.id
                                              ? Colors.white
                                              : ColorTheme.hintText)),
                                  // child: Text('${order.restaurantOrderId}',
                                  //     style: poppinsMedium.copyWith(
                                  //         fontSize: 10,
                                  //         color: selectedOrderId == order.id
                                  //             ? Colors.white
                                  //             : ColorTheme.hintText)),
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .foodLevelNotes !=
                    'Yes')
                  Row(
                    children: [
                      Checkbox(
                        value: isSwitchNote,
                        onChanged: (value) {
                          isSwitchNote = !isSwitchNote;
                          restaurantController.update();
                        },
                      ),
                      Text(
                        'Switch Notes',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                CustomButton(
                  width: Get.width / 2.0,
                  buttonText: 'Transfer To Table',
                  onPressed: () async {
                    Map<String, dynamic> jsonData = {
                      'source_order_id': orderDetail.id,
                      'target_order_id': selectedOrderId,
                      'transfer_note': isSwitchNote ? 'Yes' : 'No'
                    };
                    Get.find<KdsController>().mergeTable(jsonData,
                        (bool isSucces) {
                      if (isSucces) {
                        //   order.tableId = tableIdSelect.id;
                        //   order.restaurantTable = RestaurantTable(
                        //       id: tableIdSelect.id,
                        //       rtype: tableIdSelect.type,
                        //       tableNo: tableIdSelect.tableNo,
                        //       title: tableIdSelect.title);
                        if (Get.isBottomSheetOpen ?? false) Get.back();
                        //   Get.find<KdsController>().update();

                        // } else {
                      }
                    },
                        name:
                            "${order.restaurantTable == null || order.restaurantTable!.tableNo == '' ? order.orderType == 'delivery' ? 'Delivery' : order.orderType == 'take_away' ? 'Take Away' : order.userName != 'Mygenie' && order.userName != '' ? order.userName : 'WC' : order.restaurantTable!.title == '' ? '#${order.restaurantTable!.tableNo}' : '#${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}'} is merged in $selectedTableName successfully");
                    // Get.back();
                  },
                ),
              ],
            ),
          ]);
        }),
      ),
    );
  }

  Widget assignDeliveryBoy(BuildContext context, OrderList orderDetail) {
    int? selectedOrderId;
    String? selectedTableName;
    List<GetDeliveryBoyList> dmList = [];
    // bool isSwitchNote = false;
    TextEditingController searchTable = TextEditingController();
    dmList = Get.find<DeliveryManController>().deliveryManList;
    return SafeArea(
      child: Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
        ),
        child: GetBuilder(builder: (DeliveryManController dmController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Partner',
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        searchOrder.clear();
                        FocusManager.instance.primaryFocus?.unfocus();

                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: ColorTheme.appColor,
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: ColorTheme.borderGrey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 40,
                child: TextField(
                  controller: searchTable,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                    suffixIcon: Icon(
                      Icons.search,
                      color: ColorTheme.appColor,
                      size: 25,
                    ),
                    hintText: 'Search',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                  ),
                  onChanged: (value) async {
                    if (searchTable.text.isNotEmpty) {
                      dmList = dmController.deliveryManList
                          .where((item) => (item.fName
                              .toLowerCase()
                              .contains(searchTable.text.toLowerCase())))
                          .toList();
                    } else {
                      dmList = dmController.deliveryManList;
                    }
                    dmController.update();
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dmList.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 7,
                            childAspectRatio: 1.8,
                            mainAxisSpacing: 7,
                            crossAxisCount: 3),
                        itemBuilder: (BuildContext context, int index) {
                          GetDeliveryBoyList boy = dmList[index];
                          return InkWell(
                              onTap: () {
                                searchOrder.clear();
                                // tableIndex = index;
                                FocusManager.instance.primaryFocus?.unfocus();

                                selectedOrderId = boy.id;
                                selectedTableName = boy.fName;
                                // selectedTableName = order.restaurantTable ==
                                //             null ||
                                //         order.restaurantTable.tableNo == ''
                                //     ? order?.orderType == 'delivery'
                                //         ? 'Delivery'
                                //         : order?.orderType == 'take_away'
                                //             ? 'Take Away'
                                //             : order.userName != 'Mygenie' &&
                                //                     order.userName != ''
                                //                 ? order.userName
                                //                 : 'WC'
                                //     : order.restaurantTable.title == ''
                                //         ? '${order.restaurantTable.tableNo}'
                                //         : '${order.restaurantTable.title}-${order.restaurantTable.tableNo}';

                                dmController.update();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: selectedOrderId == boy.id
                                        ? ColorTheme.appColor
                                        : ColorTheme.tableBoxGrey,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: selectedOrderId == boy.id
                                            ? ColorTheme.appColor
                                            : ColorTheme.borderGrey)),
                                child: Center(
                                  child: Text(boy.fName ?? '',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color: selectedOrderId == boy.id
                                              ? Colors.white
                                              : ColorTheme.hintText)),
                                  // child: Text('${order.restaurantOrderId}',
                                  //     style: poppinsMedium.copyWith(
                                  //         fontSize: 10,
                                  //         color: selectedOrderId == order.id
                                  //             ? Colors.white
                                  //             : ColorTheme.hintText)),
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomButton(
                  width: Get.width / 2.0,
                  buttonText: 'Select Runner',
                  onPressed: () async {
                    Map<String, dynamic> jsonData = {
                      'order_id': orderDetail.id,
                      'delivery_man_id': selectedOrderId,
                    };
                    dmController.assignDeliveryMan(jsonData, (bool isSucces) {
                      if (isSucces) {
                        order.deliveryMan = selectedTableName ?? '';
                        //   order.tableId = tableIdSelect.id;
                        //   order.restaurantTable = RestaurantTable(
                        //       id: tableIdSelect.id,
                        //       rtype: tableIdSelect.type,
                        //       tableNo: tableIdSelect.tableNo,
                        //       title: tableIdSelect.title);
                        Get.find<KdsController>().update();
                        if (Get.isBottomSheetOpen ?? false) Get.back();

                        // } else {
                      }
                    });
                  },
                ),
              ],
            ),
          ]);
        }),
      ),
    );
  }
}
