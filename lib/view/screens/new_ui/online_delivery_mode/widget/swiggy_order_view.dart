import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_swiggy_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/swiggy_order_print_dialog.dart';
import 'package:mygenie_restaurant/view/screens/waiter/pos_view_mobile/swiggy_zomatao_ui/countdown_timer.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class SwiggyOrderView extends StatefulWidget {
  const SwiggyOrderView({super.key});

  @override
  State<SwiggyOrderView> createState() => _SwiggyOrderViewState();
}

class _SwiggyOrderViewState extends State<SwiggyOrderView> {
  TextEditingController searchOrder = TextEditingController();
  PrinterManager individualPrinter = PrinterManager.instance;
  StreamSubscription<BTStatus>? _singlePrintBtStatus;
  List<int>? pendingTask;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KdsController>(builder: (kdsController) {
      return GetBuilder<SwiggyController>(builder: (swiggyController) {
        return swiggyController.order.isEmpty
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: StaggeredGrid.count(
                  crossAxisCount: isMobile(context)
                      ? 1
                      : isTablet(context)
                          ? 2
                          : 3,
                  crossAxisSpacing: isMobile(context) ? 0 : 15,
                  mainAxisSpacing: isMobile(context) ? 0 : 10,
                  children: swiggyController.order.where((order) {
                    if ((kdsController.selectedSubMenu == 4) &&
                        (order.orderDetailsOrder.fOrderStatus == 0 ||
                            order.orderDetailsOrder.fOrderStatus == 1 ||
                            order.orderDetailsOrder.fOrderStatus == 2 ||
                            order.orderDetailsOrder.fOrderStatus == 5) &&
                        (searchOrder.text.isEmpty
                            ? true
                            : order.orderDetailsOrder.aggregatorOrderId
                                .toString()
                                .toLowerCase()
                                .contains(searchOrder.text.toLowerCase()))) {
                      return true;
                    } else if ((kdsController.selectedSubMenu == 0 &&
                            order.orderDetailsOrder.fOrderStatus == 0) &&
                        (searchOrder.text.isEmpty
                            ? true
                            : order.orderDetailsOrder.aggregatorOrderId
                                .toString()
                                .toLowerCase()
                                .contains(searchOrder.text.toLowerCase()))) {
                      return true;
                    } else if ((kdsController.selectedSubMenu == 1 &&
                            order.orderDetailsOrder.fOrderStatus == 2) &&
                        (searchOrder.text.isEmpty
                            ? true
                            : order.orderDetailsOrder.aggregatorOrderId
                                .toString()
                                .toLowerCase()
                                .contains(searchOrder.text.toLowerCase()))) {
                      return true;
                    } else if ((kdsController.selectedSubMenu == 3 &&
                            order.orderDetailsOrder.fOrderStatus == 1) &&
                        (searchOrder.text.isEmpty
                            ? true
                            : order.orderDetailsOrder.aggregatorOrderId
                                .toString()
                                .toLowerCase()
                                .contains(searchOrder.text.toLowerCase()))) {
                      return true;
                    } else if ((kdsController.selectedSubMenu == 2 &&
                            order.orderDetailsOrder.fOrderStatus == 5) &&
                        (searchOrder.text.isEmpty
                            ? true
                            : order.orderDetailsOrder.aggregatorOrderId
                                .toString()
                                .toLowerCase()
                                .contains(searchOrder.text.toLowerCase()))) {
                      return true;
                    }

                    return false;
                  }).map((order) {
                    // itemCount: 5,
                    // itemBuilder: (context, index) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  order.orderDetailsOrder.orderPlateform ==
                                          'zomato'
                                      ? Images.zomato
                                      : Images.swiggy,
                                  height: Get.height * 0.045,
                                  width: Get.width * 0.045,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // SizedBox(
                                      //   height: 3,
                                      // ),
                                      if (order.brandName != null &&
                                          order.brandName != '')
                                        Text(
                                          '${order.brandName}',
                                          style: montserratMedium.copyWith(
                                              fontSize: 16,
                                              color: ColorTheme.greenColor),
                                        ),
                                      Text(
                                        '#${order.orderDetailsOrder.aggregatorOrderId ?? ''}',
                                        style: montserratMedium.copyWith(
                                            fontSize: 16,
                                            color: order.orderDetailsOrder
                                                        .orderPlateform ==
                                                    'zomato'
                                                ? Color(0xFFE23744)
                                                : Color(0xFFF08520)),
                                      ),
                                      Text(
                                        Jiffy.parse(order
                                                .orderDetailsOrder.createdAt)
                                            .fromNow(),
                                        style: montserratSemiBold.copyWith(
                                            fontSize: 11.5,
                                            color: Color(0xFF2E2E2E)),
                                      ),
                                    ],
                                  ),
                                ),
                                // Spacer(),
                                order.orderDetailsOrder.fOrderStatus == 1
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              order.orderDetailsOrder
                                                              .fOrderStatus ==
                                                          1 &&
                                                      Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .defOrdStatus ==
                                                          1
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .borderGrey)),
                                                      child: Icon(Icons.done,
                                                          color: ColorTheme
                                                              .borderGrey),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        Map<String, dynamic>
                                                            jsonBody = {
                                                          'order_id': order
                                                              .orderDetailsOrder
                                                              .id,
                                                          "urban_order_id": order
                                                              .orderDetailsOrder
                                                              .urbanOrderId,
                                                          'new_status':
                                                              'Food Ready',
                                                          'message': 'Success'
                                                        };
                                                        await swiggyController
                                                            .changeOrderStatus(
                                                                jsonBody);
                                                      },
                                                      child: SvgPicture.asset(
                                                        Images.correct_button,
                                                        height:
                                                            Get.height * 0.047,
                                                        // width: 40,
                                                      ),
                                                    ),
                                              SizedBox(height: 5),
                                              Text(
                                                  Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .defOrdStatus ==
                                                          1
                                                      ? 'Cooking'
                                                      : 'READY',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFF8C8C8C))),
                                            ],
                                          ),
                                        ],
                                      )
                                    : order.orderDetailsOrder.fOrderStatus == 2
                                        ? Flexible(
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Waiting for dispatch',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF8C8C8C)),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                InkWell(
                                                  onTap: () async {
                                                    // Map<String, dynamic> jsonBody =
                                                    //     {
                                                    //   'order_id': order
                                                    //       .orderDetailsOrder.id,
                                                    //   "urban_order_id": order
                                                    //       .orderDetailsOrder
                                                    //       .urbanOrderId,
                                                    //   'new_status': 'Dispatched',
                                                    //   'message': 'Success'
                                                    // };
                                                    // await swiggyController
                                                    //     .changeOrderStatus(
                                                    //         jsonBody);
                                                    // // print(jsonBody);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[350],
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey)),
                                                    child: Icon(Icons.check,
                                                        color: Colors.white),
                                                  ),
                                                  // SvgPicture.asset(
                                                  //   Images.correct_button,
                                                  //   height: Get.height * 0.047,
                                                  //   // width: 40,
                                                  // ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : order.orderDetailsOrder
                                                    .fOrderStatus ==
                                                0
                                            ? Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (order.orderDetailsOrder
                                                          .orderPlateform ==
                                                      'zomato')
                                                    InkWell(
                                                      onTap: () {
                                                        searchOrder.clear();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        Get.bottomSheet(
                                                            cancelOrder(order),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isScrollControlled:
                                                                true,
                                                            ignoreSafeArea:
                                                                false);
                                                      },
                                                      child: SvgPicture.asset(
                                                          Images.cancel_button,
                                                          height: Get.height *
                                                              0.047),
                                                    ),
                                                  SizedBox(width: 10),
                                                  Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          searchOrder.clear();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          stopOrderAlert(
                                                              '${order.orderDetailsOrder.id}');
                                                          Get.bottomSheet(
                                                              preparationTimeBottomSheet(
                                                                  order),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              isScrollControlled:
                                                                  true,
                                                              ignoreSafeArea:
                                                                  false);
                                                        },
                                                        child: SvgPicture.asset(
                                                          Images.correct_button,
                                                          height: Get.height *
                                                              0.047,
                                                          // width: 40,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text('Accept',
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF8C8C8C))),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Text(
                                                    'Dispatched',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: ColorTheme
                                                                .green),
                                                  ),
                                                ],
                                              ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Divider(
                              height: 20,
                              thickness: 1,
                              color: Color(0xFFF0F0F0),
                            ),
                            SizedBox(height: 5),

                            Column(
                              children: [
                                if (order.orderDetailsOrder.handover != '' &&
                                    order.orderDetailsOrder.fOrderStatus != 5)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Rider reached',
                                          style: montserratMedium.copyWith(
                                              fontSize: 12,
                                              color: ColorTheme.greenColor)),
                                    ),
                                  ),
                                if (order.orderDetailsOrder.serveAt != null &&
                                    order.orderDetailsOrder.serveAt != '' &&
                                    order.orderDetailsOrder.handover == '' &&
                                    order.riderInfo != null &&
                                    (order.orderDetailsOrder.fOrderStatus ==
                                            0 ||
                                        order.orderDetailsOrder.fOrderStatus ==
                                            1 ||
                                        order.orderDetailsOrder.fOrderStatus ==
                                            2))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, bottom: 7),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: CountdownTimerWidget(
                                        orderId: order
                                            .orderDetailsOrder.aggregatorOrderId
                                            .toString(),
                                        scheduleAt:
                                            order.orderDetailsOrder.serveAt,
                                        createdAt:
                                            order.orderDetailsOrder.createdAt,
                                      ),
                                    ),
                                  ),
                                if (order.orderDetailsOrder.fOrderStatus != 0 &&
                                    order.riderInfo != null)
                                  Container(
                                    child: Row(
                                      children: [
                                        // SvgPicture.asset(
                                        //   Images.user_img,
                                        //   width: Get.width * 0.1,
                                        //   height: Get.height * 0.06,
                                        // ),
                                        // SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${order.riderInfo?.name ?? ''}',
                                                  style:
                                                      montserratMedium.copyWith(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF2E2E2E))),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                      '${order.riderInfo?.phone ?? ''}',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xFF2E2E2E))),
                                                  SizedBox(width: 10),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            dialPhoneNumber(
                                                order.riderInfo?.phone ?? '');
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                            child: Icon(Icons.call,
                                                color: Colors.black),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                if (order.orderDetailsOrder.fOrderStatus != 0 &&
                                    order.riderInfo != null)
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (order.riderInfo?.orderReturnOtp !=
                                              '')
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  'Order return OTP : ${order.riderInfo?.orderReturnOtp}',
                                                  style:
                                                      montserratMedium.copyWith(
                                                          fontSize: 12,
                                                          color: Colors.blue)),
                                            ),
                                          if (order.riderInfo?.bagReturnOtp !=
                                              '')
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    'Bag return OTP : ${order.riderInfo?.bagReturnOtp}',
                                                    style: montserratMedium
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.blue)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                if (order.orderDetailsOrder.fOrderStatus != 0)
                                  Divider(
                                      height: 30,
                                      thickness: 1,
                                      color: Color(0xFFF0F0F0)),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListView.separated(
                                              padding: EdgeInsets.zero,
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: order.orderDetailsFood
                                                      .length ??
                                                  0,
                                              separatorBuilder:
                                                  (context, foodIndex) {
                                                // final orderFood =
                                                //     order.orderDetailsFood[
                                                //         foodIndex];
                                                return Divider(
                                                  thickness: 1,
                                                  height: 30,
                                                  color: Color(0xFFF0F0F0),
                                                );
                                              },
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
                                                // if (order.orderDetailsFood[i]
                                                //     .variation.isNotEmpty) {
                                                //   for (int j = 0;
                                                //       j <
                                                //           order
                                                //               .orderDetailsFood[i]
                                                //               .variation
                                                //               .length;
                                                //       j++) {
                                                //     variationText +=
                                                //         '${variationText.isNotEmpty ? ', ' : ''}${order.orderDetailsFood[i].variation[j].name} (';

                                                //     if (order
                                                //             .orderDetailsFood[i]
                                                //             .variation[j]
                                                //             .values !=
                                                //         null) {
                                                //       List<String> labelList = [];
                                                //       for (var element in order
                                                //           .orderDetailsFood[i]
                                                //           .variation[j]
                                                //           .values!) {
                                                //         labelList
                                                //             .add(element.level!);
                                                //       }
                                                //       variationText +=
                                                //           '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                                //     }

                                                //     variationText += ')';
                                                //   }
                                                // }
                                                String? addonGroupTitle;
                                                String? variationGroupTitle;
                                                String addonText = '';
                                                String variationText = '';
                                                for (var addon in order
                                                    .orderDetailsFood[i]
                                                    .addOns) {
                                                  if (addon.group != null) {
                                                    if (addon
                                                            .group!.isVariant ==
                                                        true) {
                                                      // 🔹 Handle Variation
                                                      variationGroupTitle ??=
                                                          addon.group!.title ??
                                                              '';
                                                      variationText +=
                                                          "${addon.title}(${addon.quantity ?? 0}), ";
                                                    } else {
                                                      // 🔹 Handle Add-on
                                                      addonGroupTitle ??=
                                                          addon.group!.title ??
                                                              '';
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

                                                //   if (addons != '') {
                                                //     addons += ', ';
                                                //   }
                                                //   addons +=
                                                //       '${order.orderDetailsFood[i].addOns[i].name} (${order.orderDetailsFood[i].addOns[i].qty})';
                                                // }
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: CircleAvatar(
                                                        backgroundColor: order
                                                                    .orderDetailsOrder
                                                                    .orderPlateform ==
                                                                'zomato'
                                                            ? Colors.red
                                                            : Colors.green,
                                                        radius: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              '${order.orderDetailsFood[i].title} (${order.orderDetailsFood[i].quantity})',
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          15)),
                                                          SizedBox(height: 5),
                                                          if (variationText !=
                                                              '')
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text('Variant:',
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .blue)),
                                                                SizedBox(
                                                                    width: 5),
                                                                Flexible(
                                                                  child: Text(
                                                                      '$variationText',
                                                                      style: montserratMedium.copyWith(
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ],
                                                            ),
                                                          SizedBox(height: 5),
                                                          if (addonText != '')
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text('Addons:',
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .blue)),
                                                                SizedBox(
                                                                    width: 5),
                                                                Flexible(
                                                                  child: Text(
                                                                      '$addonText',
                                                                      style: montserratMedium.copyWith(
                                                                          fontSize:
                                                                              12)),
                                                                ),
                                                              ],
                                                            ),
                                                          if (order
                                                                  .orderDetailsFood[
                                                                      i]
                                                                  .foodLevelNotes !=
                                                              '')
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5),
                                                              child: Text(
                                                                  '${order.orderDetailsFood[i].foodLevelNotes ?? ''}',
                                                                  style: montserratMedium.copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .blue)),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    // if (order
                                                    //         .orderDetailsOrder
                                                    //         .fOrderStatus ==
                                                    //     1)
                                                    // InkWell(
                                                    //     onTap: () async {
                                                    //       searchOrder
                                                    //           .clear();
                                                    //       FocusManager
                                                    //           .instance
                                                    //           .primaryFocus
                                                    //           ?.unfocus();
                                                    //       Get.bottomSheet(
                                                    //           cancelOrder(
                                                    //               order,
                                                    //               foodId: order
                                                    //                   .orderDetailsFood[
                                                    //                       i]
                                                    //                   .id
                                                    //                   .toString()),
                                                    //           backgroundColor:
                                                    //               Colors
                                                    //                   .transparent,
                                                    //           isScrollControlled:
                                                    //               true,
                                                    //           ignoreSafeArea:
                                                    //               false);
                                                    //     },
                                                    //     child: Icon(
                                                    //       Icons.close,
                                                    //       color:
                                                    //           Colors.red,
                                                    //     ))
                                                  ],
                                                );
                                              }),
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   children: [
                                          //     Text('Instructions: ',
                                          //         style: montserratMedium
                                          //             .copyWith(
                                          //                 fontSize: 12,
                                          //                 color:
                                          //                     Colors.blue)),
                                          //     Flexible(
                                          //       child: Text(
                                          //           '${order.orderDetailsOrder.orderNote ?? ''}',
                                          //           style: montserratMedium
                                          //               .copyWith(
                                          //                   fontSize: 12)),
                                          //     ),
                                          //   ],
                                          // ),
                                          if (order.orderDetailsOrder
                                                  .orderNote !=
                                              '')
                                            Text(
                                                '${order.orderDetailsOrder.orderNote ?? ''}',
                                                style:
                                                    montserratMedium.copyWith(
                                                        fontSize: 12,
                                                        color: Colors.blue)),

                                          if (order.orderDetailsOrder
                                                      .preparationTime !=
                                                  '' &&
                                              order.orderDetailsOrder.readyAt !=
                                                  '' &&
                                              order.orderDetailsOrder
                                                      .fOrderStatus ==
                                                  1)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 5),
                                              child: CountdownTimerWidget(
                                                  orderId: order
                                                      .orderDetailsOrder
                                                      .aggregatorOrderId
                                                      .toString(),
                                                  createdAt: order
                                                      .orderDetailsOrder
                                                      .createdAt,
                                                  readyAt: order
                                                      .orderDetailsOrder
                                                      .readyAt,
                                                  prepTimeMins: int.parse(order
                                                          .orderDetailsOrder
                                                          .preparationTime ??
                                                      '0')),
                                            ),

                                          if (order.orderDetailsOrder
                                                      .fOrderStatus !=
                                                  0 &&
                                              Get.find<AuthController>()
                                                  .profileModel!
                                                  .role!
                                                  .contains(
                                                      'swiggy_zomato_price'))
                                            Text(
                                                '₹ ${order.orderDetailsOrder.orderAmount}',
                                                style: rupeeForadianRegular
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF18A84A))),
                                          if (order.orderDetailsOrder
                                                  .fOrderStatus !=
                                              0)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                  '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                                  style: montserratMedium
                                                      .copyWith(fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (order.orderDetailsOrder.fOrderStatus !=
                                        0)
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 7),
                                          height: Get.height * 0.05,
                                          width: 2,
                                          color: Color(0xFFF0F0F0)),
                                    // Text(
                                    //     '\u20B9 ${order.orderDetailsOrder.orderAmount} ',
                                    //     style:
                                    //         rupeeForadianRegular.copyWith(
                                    //             fontSize: 14,
                                    //             color: Color(0xFF18A84A)))
                                    if (order.orderDetailsOrder.fOrderStatus !=
                                        0)
                                      InkWell(
                                        onTap: () {
                                          dialPhoneNumber(
                                              order.customerDetails.phone);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color:
                                                      ColorTheme.borderGrey)),
                                          child: Icon(Icons.call,
                                              color: ColorTheme.appColor),
                                        ),
                                      )
                                  ],
                                )

                                // SizedBox(
                                //   height: 10,
                                // ),
                              ],
                            ),
                            Divider(
                              thickness: 1,
                              color: Color(0xFFF0F0F0),
                              height: 30,
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                           ( order.orderDetailsOrder.fOrderStatus == 0 )
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                          if(Get.find<AuthController>()
                                                  .profileModel!
                                                  .role!
                                                  .contains(
                                                      'swiggy_zomato_price'))
                                            Text(
                                                '₹ ${order.orderDetailsOrder.orderAmount}',
                                                style: rupeeForadianRegular
                                                    .copyWith(
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xFF18A84A))),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                  '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                                  style: montserratMedium
                                                      .copyWith(fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      InkWell(
                                        onTap: () async {
                                          dialPhoneNumber(
                                              order.customerDetails.phone);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorTheme.borderGrey),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Text('Call Customer',
                                              style: montserratMedium.copyWith(
                                                  fontSize: 12,
                                                  color: ColorTheme.appColor)),
                                        ),
                                      ),
                                    ],
                                  )
                                : order.orderDetailsOrder.fOrderStatus == 1
                                    ? Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              printBill(order);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.yellow,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                              child: Text('Print Bill',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF2E2E2E))),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () async {
                                              List<List<OrderFoodDetails>>
                                                  cartProductList = [];
                                              cartProductList = [];
                                              for (var i = 0;
                                                  i <
                                                      Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurantPrinterNew!
                                                          .length;
                                                  i++) {
                                                RestaurantPrinterNew printer =
                                                    Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurantPrinterNew![i];
                                                List<OrderFoodDetails>
                                                    tempCartList = [];
                                                for (var e
                                                    in order.orderDetailsFood) {
                                                  if (e.station ==
                                                      printer.areaName) {
                                                    tempCartList.add(e);
                                                  }
                                                }
                                                cartProductList
                                                    .add(tempCartList);
                                              }
                                              if (cartProductList.isNotEmpty) {
                                                await Get.bottomSheet(
                                                    SwiggyPrintDialog(
                                                      cartProductList:
                                                          cartProductList,
                                                      order: order,
                                                      index: Get.find<
                                                              SwiggyController>()
                                                          .order
                                                          .indexOf(order),
                                                    ),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    ignoreSafeArea: false);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.yellow,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                              child: Text('Print KOT',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF2E2E2E))),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(),
                                          ElevatedButton(
                                            onPressed: () {
                                              printBill(order);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.yellow,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30)))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                              child: Text('Print Bill',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFF2E2E2E))),
                                            ),
                                          ),
                                          Spacer(),
                                          Row(
                                            children: [
                                              Text('OTP ',
                                                  style: montserratRegular
                                                      .copyWith(
                                                    fontSize: 18,
                                                  )),
                                              SizedBox(width: 5),
                                              Text(
                                                  '${order.orderDetailsOrder.otp}',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                    fontSize: 18,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // border:
                        //     Border.all( color: Colors.red)
                      ),
                    );
                  }).toList(),
                  // },
                ),
              );
      });
    });
  }

  void dialPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  Widget cancelOrder(Order order, {String? foodId}) {
    String? selectedReason;
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        // height: Get.height * 0.4,
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Cancel',
                          style: poppinsMedium.copyWith(
                              color: Colors.black, fontSize: 18)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: () {
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
                SizedBox(height: 10),
                GetBuilder<SwiggyController>(builder: (swiggyController) {
                  return swiggyController.cancelReasonList.isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              height: Get.width > 1600 ? 65 : 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_SMALL),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: ColorTheme.borderGrey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedReason ??
                                    swiggyController.cancelReasonList.first,
                                items: swiggyController.cancelReasonList
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      maxLines: 1,
                                      style: poppinsRegular.copyWith(
                                        fontSize: Get.width > 1600
                                            ? 17
                                            : Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  selectedReason = value;
                                  swiggyController.update();
                                  // kdsController.setCancelReason(value);
                                },
                                underline: SizedBox(),
                              ),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: swiggyController.isLoading
                                  ? CircularProgressIndicator()
                                  : InkWell(
                                      onTap: () async {
                                        Map<String, dynamic> jsonBody = {
                                          'order_id':
                                              order.orderDetailsOrder.id,
                                          "urban_order_id": order
                                              .orderDetailsOrder.urbanOrderId,

                                          'new_status': 'Cancelled',
                                          'message': 'Success',
                                          'reason_code':
                                              selectedReason!.camelCase,
                                          // if (foodId != null)
                                          //   "extra": {
                                          //     "unavailable": {
                                          //       "item_ref_ids": foodId,
                                          //     }
                                          //   }
                                          //  if(order.orderDetailsOrder.fOrderStatus)
                                        };
                                        Get.back();
                                        await swiggyController
                                            .changeOrderStatus(jsonBody);
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 110,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.transparent),
                                            color: ColorTheme.appColor,
                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Text(
                                            'submit'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize:
                                                    Get.width > 1600 ? 18 : 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        );
                }),
              ]),
            ),
          ),
        ));
  }

  Widget preparationTimeBottomSheet(Order order) {
    TextEditingController prepTimeController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 25,
          bottom: Dimensions.PADDING_SIZE_DEFAULT,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter Preparation Time',
                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: ColorTheme.appColor,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: ColorTheme.borderGrey),
              ),
              SizedBox(height: 10),
              TextField(
                controller: prepTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter preparation time (mins)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () async {
                    if (prepTimeController.text.trim().isNotEmpty) {
                      Map<String, dynamic> jsonBody = {
                        'order_id': order.orderDetailsOrder.id,
                        "urban_order_id": order.orderDetailsOrder.urbanOrderId,
                        'new_status': 'Acknowledged',
                        'message': 'Success',
                        "extra": {
                          "prep_time_mins":
                              int.parse(prepTimeController.text.trim()),
                          // "rider_name":"Gyan",
                          // "rider_phone_number":9795554735
                        }
                      };

                      await Get.find<SwiggyController>()
                          .changeOrderStatus(jsonBody, type: 'preparation');
                      // Get.back();
                    }
                  },
                  child: Container(
                    height: 35,
                    width: 110,
                    decoration: BoxDecoration(
                      color: ColorTheme.appColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: poppinsMedium.copyWith(
                          fontSize: Get.width > 1600 ? 18 : 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  individualListenBluetooth() async {
    if (Platform.isAndroid) {
      _singlePrintBtStatus =
          individualPrinter.stateBluetooth.listen((status) async {
        if (status == BTStatus.connecting) {}
        if (status == BTStatus.connected) {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            individualPrinter.send(
                type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (status == BTStatus.none) {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Failed to bluetooth connect!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      });
    }
  }

  printBill(Order order) async {
    int numberOfPrint = int.parse(Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .settings!
            .noOfBillPrint ??
        '1');
    if (GetPlatform.isWindows) {
      final printers = await Printing.listPrinters();
      for (var element in printers) {
        if (element.isAvailable &&
            (element.name.toLowerCase() ==
                Get.find<AuthController>()
                    .profileModel!
                    .wifiBillPrinterName!
                    .toLowerCase())) {
          for (int i = 0; i < numberOfPrint; i++) {
            await Printing.directPrintPdf(
              printer: element,
              onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                brandName: order?.brandName ?? '',
                printType: 'swiggy_bill',
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
                orderId: order.orderDetailsOrder.aggregatorOrderId,
                date:
                    '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
                waiterName: '',
                tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
                    ? 'Zomato'
                    : 'Swiggy',
                custName: order.customerDetails.name ?? '',
                custPhone: order.customerDetails.phone ?? '',
                swiggyOrderList: order.orderDetailsFood,
                charge: order.orderDetailsOrder.charges ?? 0.0,
                orderNote: order.orderDetailsOrder.orderNote ?? '',
                orderSubTotal: order.orderDetailsOrder.itemTotal ?? 0.0,
                subTotalWithoutTax: order.orderDetailsOrder.subTotal ?? 0.0,
                discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
                couponCode: order.orderDetailsOrder.couponCode,
                couponDiscount: order.orderDetailsOrder.couponDiscount ?? 0,
                serviceChargeAmount: 0,
                deliveryCharge: order.orderDetailsOrder.deliveryCharge ?? 0,
                packingCharge: order.orderDetailsOrder.packingCharge ?? 0,
                gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
                vatAmount: 0,
                grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
                deliveryCustName: order.customerDetails.name ?? '',
                deliveryCustPhone: order.customerDetails.phone ?? '',
                deliveryAddressType: '',
                // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,
                deliveryCustAddress:
                    '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
                deliveryCustPincode: order.customerDetails.address.pin ?? '',
                tips: order.orderDetailsOrder.tipAmount ?? 0.0,
                orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
                    ? 'Zomato'
                    : 'Swiggy',
              ),
            );
          }
          break;
        }
      }
    } else {
      showToast('Please wait..');
      Get.find<LoadingController>().startLoading(true);
      if (Platform.isIOS) {
        await _iosPrintEscPos(await PrintByteConvert().byteConvert(
          printType: 'swiggy_bill',
          // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,

          paperRoll:
              Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80,
          orderId: order.orderDetailsOrder.aggregatorOrderId,
          date:
              '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
          waiterName: '',
          tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
              ? 'Zomato'
              : 'Swiggy',
          custName: order.customerDetails.name ?? '',
          custPhone: order.customerDetails.phone ?? '',
          swiggyOrderList: order.orderDetailsFood,
          charge: order.orderDetailsOrder.charges ?? 0.0,
          orderNote: order.orderDetailsOrder.orderNote ?? '',
          orderSubTotal: order.orderDetailsOrder.itemTotal ?? 0.0,
          subTotalWithoutTax: order.orderDetailsOrder.subTotal ?? 0.0,
          discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
          couponCode: order.orderDetailsOrder.couponCode ?? '',
          couponDiscount: order.orderDetailsOrder.couponDiscount ?? 0,
          serviceChargeAmount: 0,
          deliveryCharge: order.orderDetailsOrder.deliveryCharge ?? 0,
          packingCharge: order.orderDetailsOrder.packingCharge ?? 0,
          gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
          vatAmount: 0,
          grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
          deliveryCustName: order.customerDetails.name ?? '',
          deliveryCustPhone: order.customerDetails.phone ?? '',
          deliveryAddressType: '',
          deliveryCustAddress:
              '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
          deliveryCustPincode: order.customerDetails.address.pin ?? '',
          tips: order.orderDetailsOrder.tipAmount ?? 0.0,
          orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
              ? 'Zomato'
              : 'Swiggy',
        ));
      } else {
        await _kdsPrintEscPos(await PrintByteConvert().byteConvert(
          printType: 'swiggy_bill',
          // swiggyTax: order.orderDetailsOrder.totaTaxAmount ?? 0.0,

          paperRoll:
              Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80,
          orderId: order.orderDetailsOrder.aggregatorOrderId,
          date:
              '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'yyyy-MM-dd'}').format(DateTime.parse(order.orderDetailsOrder.createdAt))}',
          waiterName: '',
          tablename: order.orderDetailsOrder.orderPlateform == 'zomato'
              ? 'Zomato'
              : 'Swiggy',
          custName: order.customerDetails.name ?? '',
          custPhone: order.customerDetails.phone ?? '',
          swiggyOrderList: order.orderDetailsFood,
          charge: order.orderDetailsOrder.charges ?? 0.0,
          orderNote: order.orderDetailsOrder.orderNote ?? '',
          orderSubTotal: order.orderDetailsOrder.itemTotal ?? 0.0,
          subTotalWithoutTax: order.orderDetailsOrder.subTotal ?? 0.0,
          discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
          couponCode: order.orderDetailsOrder.couponCode ?? '',
          couponDiscount: order.orderDetailsOrder.couponDiscount ?? 0,
          serviceChargeAmount: 0,
          deliveryCharge: order.orderDetailsOrder.deliveryCharge ?? 0,
          packingCharge: order.orderDetailsOrder.packingCharge ?? 0,
          gstAmount: order.orderDetailsOrder.gstTax ?? 0.0,
          vatAmount: 0,
          grandTotal: order.orderDetailsOrder.orderAmount ?? 0.0,
          deliveryCustName: order.customerDetails.name ?? '',
          deliveryCustPhone: order.customerDetails.phone ?? '',
          deliveryAddressType: '',
          deliveryCustAddress:
              '${order.customerDetails.address.line1 ?? ''} ${order.customerDetails.address.subLocality ?? ''} ${order.customerDetails.address.landmark ?? ''}',
          deliveryCustPincode: order.customerDetails.address.pin ?? '',
          tips: order.orderDetailsOrder.tipAmount ?? 0.0,
          orderType: order.orderDetailsOrder.orderPlateform == 'zomato'
              ? 'Zomato'
              : 'Swiggy',
        ));
      }
    }
  }

  Future _kdsPrintEscPos(List<int> bytes) async {
    try {
      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      if (profile == null) return;

      final billType = (profile.billPrinterType ?? '').toLowerCase();
      final isWifi = billType == 'wifi' ||
          billType == 'network' ||
          ((profile.billWifiIp ?? '').isNotEmpty &&
              billType != 'bluetooth' &&
              billType != 'usb');
      final isUsb = billType == 'usb';

      BluetoothPrinter bluetoothPrinter;
      if (isUsb) {
        bluetoothPrinter = BluetoothPrinter(
            productId: profile.billProductId,
            vendorId: profile.billVendorId,
            typePrinter: PrinterType.usb);
      } else if (isWifi) {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.network,
            port: '9100',
            address: (profile.billWifiIp ?? '').isNotEmpty
                ? profile.billWifiIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      } else {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.bluetooth,
            address: (profile.macBillPrinterIp ?? '').isNotEmpty
                ? profile.macBillPrinterIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      }

      var data;
      switch (bluetoothPrinter.typePrinter) {
        case PrinterType.usb:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
              name: bluetoothPrinter.deviceName,
              productId: bluetoothPrinter.productId,
              vendorId: bluetoothPrinter.vendorId,
            ),
          );
          break;
        case PrinterType.bluetooth:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
              name: bluetoothPrinter.deviceName,
              address: bluetoothPrinter.address ?? '',
              isBle: bluetoothPrinter.isBle,
            ),
          );
          pendingTask = null;
          if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
          break;
        case PrinterType.network:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address ?? ''),
          );
          break;
      }

      try {
        await individualPrinter.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        Future.delayed(
            Duration(
                seconds: bytes.length <= 5850
                    ? 1
                    : bytes.length <= 7890
                        ? 2
                        : bytes.length <= 10195
                            ? 5
                            : bytes.length <= 13100
                                ? 10
                                : bytes.length <= 21150
                                    ? 15
                                    : 20), () async {
          pendingTask = null;
          try {
            if (Get.isRegistered<LoadingController>()) {
              Get.find<LoadingController>().startLoading(false);
              await Get.find<LoadingController>()
                  .changeText(data: 'Successfully printed!!');
              await Get.find<LoadingController>().changeStatus(data: true);
            }
            await PrinterManager.instance
                .disconnect(type: bluetoothPrinter.typePrinter);
          } catch (_) {}
        });
      } catch (e) {}

      if (data != null && !data) {
        if (Get.isRegistered<LoadingController>()) {
          await Get.find<LoadingController>().changeText(
              data: bluetoothPrinter.typePrinter == PrinterType.usb
                  ? 'Failed to usb connect!!'
                  : bluetoothPrinter.typePrinter == PrinterType.network
                      ? 'Failed to Wi-Fi connect!!'
                      : 'Failed to bluetooth connect!!',
              error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      }
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        try {
          await Get.find<LoadingController>().changeText(
              data: 'Printing error occurred: $e', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        } catch (_) {}
      }
    }
  }

  Future _iosPrintEscPos(List<int> bytes) async {
    try {
      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      final macAddress = (profile?.macBillPrinterIp ?? '').isNotEmpty
          ? profile!.macBillPrinterIp!
          : (profile?.billPrinterIp ?? '');

      final bool result = await IosPrintTransport.connect(
        wifiPrinter: NetworkPrinterResolver.billPrinter(),
        macPrinterAddress: macAddress,
      );

      Future.delayed(const Duration(seconds: 1), () async {
        if (result) {
          if (!IosPrintTransport.isWifiActive && bytes.length > 200) {
            const int chunkSize = 255;
            for (int i = 0; i < bytes.length; i += chunkSize) {
              final chunk = bytes.sublist(
                i,
                (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
              );
              await IosPrintTransport.writeBytes(chunk);
              await Future.delayed(const Duration(milliseconds: 35));
            }
          } else {
            await IosPrintTransport.writeBytes(bytes);
          }

          Future.delayed(const Duration(seconds: 6), () async {
            try {
              if (Get.isRegistered<LoadingController>()) {
                Get.find<LoadingController>().startLoading(false);
                await Get.find<LoadingController>()
                    .changeText(data: 'Successfully printed!!');
                await Get.find<LoadingController>().changeStatus(data: true);
              }
              await IosPrintTransport.disconnect;
            } catch (_) {}
          });
        } else {
          if (Get.isRegistered<LoadingController>()) {
            Get.find<LoadingController>().startLoading(false);
            await Get.find<LoadingController>().changeText(
                data: 'Failed to connect to printer!!', error: true);
            await Get.find<LoadingController>().changeStatus(data: true);
          }
        }
      });
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        try {
          await Get.find<LoadingController>().changeText(
              data: 'Printing error occurred: $e', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        } catch (_) {}
      }
    }
  }
}
