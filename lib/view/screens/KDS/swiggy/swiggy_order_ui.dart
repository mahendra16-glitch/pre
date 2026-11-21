import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/util/images.dart';
// import '../../../../helper/colors.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/view/screens/waiter/pos_view_mobile/swiggy_zomatao_ui/countdown_timer.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../controller/auth_controller.dart';
import '../../../../../controller/swiggy_controller.dart';
import '../../../../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../../../helper/colors.dart';
import '../../../../../util/app_constants.dart';
import '../../../../../util/dimensions.dart';
import '../home/kds_home_screen.dart';

class KdsSwiggyUI extends StatefulWidget {
  const KdsSwiggyUI({super.key});

  @override
  State<KdsSwiggyUI> createState() => _KdsSwiggyUIState();
}

class _KdsSwiggyUIState extends State<KdsSwiggyUI> {
  final TextEditingController searchOrder = TextEditingController();

  Socket? socket;
  final List<OrderIdType> orderIdQueue = [];
  bool isProcessingOrderQueue = false;

  @override
  void dispose() {
    // socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenWidth * 0.035;
    int image = 0;

    return GetBuilder<SwiggyController>(builder: (swiggyController) {
      if (swiggyController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (swiggyController.order.isEmpty) {
        return SizedBox.shrink();
      }
      return RefreshIndicator(
        onRefresh: () async {
          await Get.find<SwiggyController>().fetchOrders();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: StaggeredGrid.count(
            crossAxisCount: isMobile(context)
                ? 1
                : isTablet(context)
                    ? 2
                    : 3,
            crossAxisSpacing: isMobile(context) ? 0 : 15,
            mainAxisSpacing: isMobile(context) ? 15 : 10,
            children: swiggyController.order.where((order) {
              if ((order.orderDetailsOrder.fOrderStatus == 0 ||
                      order.orderDetailsOrder.fOrderStatus == 1) &&
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
                            order.orderDetailsOrder.orderPlateform == 'zomato'
                                ? Images.zomato
                                : Images.swiggy,
                            height: Get.height * 0.045,
                            width: Get.width * 0.045,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                  Jiffy.parse(order.orderDetailsOrder.createdAt)
                                      .fromNow(),
                                  style: montserratSemiBold.copyWith(
                                      fontSize: 11.5, color: Color(0xFF2E2E2E)),
                                ),
                              ],
                            ),
                          ),
                          // Spacer(),
                          order.orderDetailsOrder.fOrderStatus == 1
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            Map<String, dynamic> jsonBody = {
                                              'order_id':
                                                  order.orderDetailsOrder.id,
                                              "urban_order_id": order
                                                  .orderDetailsOrder
                                                  .urbanOrderId,
                                              'new_status': 'Food Ready',
                                              'message': 'Success'
                                            };
                                            await swiggyController
                                                .changeOrderStatus(jsonBody);
                                          },
                                          child: SvgPicture.asset(
                                            Images.correct_button,
                                            height: Get.height * 0.047,
                                            // width: 40,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text('READY',
                                            style: montserratSemiBold.copyWith(
                                                fontSize: 12,
                                                color: Color(0xFF8C8C8C))),
                                      ],
                                    ),
                                  ],
                                )
                              : order.orderDetailsOrder.fOrderStatus == 0
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              Get.bottomSheet(
                                                  cancelOrder(order),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  ignoreSafeArea: false);
                                            },
                                            child: SvgPicture.asset(
                                                Images.cancel_button,
                                                height: Get.height * 0.047),
                                          ),
                                        SizedBox(width: 10),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                searchOrder.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                stopOrderAlert(
                                                    '${order.orderDetailsOrder.id}');
                                                Get.bottomSheet(
                                                    preparationTimeBottomSheet(
                                                        order),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    ignoreSafeArea: false);
                                              },
                                              child: SvgPicture.asset(
                                                Images.correct_button,
                                                height: Get.height * 0.047,
                                                // width: 40,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text('Accept',
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF8C8C8C))),
                                          ],
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink()
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
                          if (order.orderDetailsOrder.serveAt != '' &&
                              order.orderDetailsOrder.handover == '' &&
                              order.riderInfo != null &&
                              (order.orderDetailsOrder.fOrderStatus == 0 ||
                                  order.orderDetailsOrder.fOrderStatus == 1 ||
                                  order.orderDetailsOrder.fOrderStatus == 2))
                            Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 7),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: CountdownTimerWidget(
                                  orderId: order
                                      .orderDetailsOrder.aggregatorOrderId
                                      .toString(),
                                  scheduleAt: order.orderDetailsOrder.serveAt,
                                  createdAt: order.orderDetailsOrder.createdAt,
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
                                        Text('${order.riderInfo?.name ?? ''}',
                                            style: montserratMedium.copyWith(
                                                fontSize: 15,
                                                color: Color(0xFF2E2E2E))),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                                '${order.riderInfo?.phone ?? ''}',
                                                style:
                                                    montserratMedium.copyWith(
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF2E2E2E))),
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
                                              color: ColorTheme.borderGrey)),
                                      child:
                                          Icon(Icons.call, color: Colors.black),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (order.riderInfo?.orderReturnOtp != '')
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            'Order return OTP : ${order.riderInfo?.orderReturnOtp}',
                                            style: montserratMedium.copyWith(
                                                fontSize: 12,
                                                color: Colors.blue)),
                                      ),
                                    if (order.riderInfo?.bagReturnOtp != '')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              'Bag return OTP : ${order.riderInfo?.bagReturnOtp}',
                                              style: montserratMedium.copyWith(
                                                  fontSize: 12,
                                                  color: Colors.blue)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListView.separated(
                                        padding: EdgeInsets.zero,
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            order.orderDetailsFood.length ?? 0,
                                        separatorBuilder: (context, foodIndex) {
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
                                            (BuildContext context, int i) {
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
                                              .orderDetailsFood[i].addOns) {
                                            if (addon.group != null) {
                                              if (addon.group!.isVariant ==
                                                  true) {
                                                // 🔹 Handle Variation
                                                variationGroupTitle ??=
                                                    addon.group!.title ?? '';
                                                variationText +=
                                                    "${addon.title}(${addon.quantity ?? 0}), ";
                                              } else {
                                                // 🔹 Handle Add-on
                                                addonGroupTitle ??=
                                                    addon.group!.title ?? '';
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
                                                padding: const EdgeInsets.only(
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
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        '${order.orderDetailsFood[i].title} (${order.orderDetailsFood[i].quantity})',
                                                        style: montserratMedium
                                                            .copyWith(
                                                                fontSize: 15)),
                                                    SizedBox(height: 5),
                                                    if (variationText != '')
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Variant:',
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .blue)),
                                                          SizedBox(width: 5),
                                                          Flexible(
                                                            child: Text(
                                                                '$variationText',
                                                                style: montserratMedium
                                                                    .copyWith(
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
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .blue)),
                                                          SizedBox(width: 5),
                                                          Flexible(
                                                            child: Text(
                                                                '$addonText',
                                                                style: montserratMedium
                                                                    .copyWith(
                                                                        fontSize:
                                                                            12)),
                                                          ),
                                                        ],
                                                      ),
                                                    if (order
                                                            .orderDetailsFood[i]
                                                            .foodLevelNotes !=
                                                        '')
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                            '${order.orderDetailsFood[i].foodLevelNotes ?? ''}',
                                                            style: montserratMedium
                                                                .copyWith(
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
                                    if (order.orderDetailsOrder.orderNote != '')
                                      Text(
                                          '${order.orderDetailsOrder.orderNote ?? ''}',
                                          style: montserratMedium.copyWith(
                                              fontSize: 12,
                                              color: Colors.blue)),

                                    if (order.orderDetailsOrder
                                                .preparationTime !=
                                            '' &&
                                        order.orderDetailsOrder.readyAt != '' &&
                                        order.orderDetailsOrder.fOrderStatus ==
                                            1)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: CountdownTimerWidget(
                                            orderId: order.orderDetailsOrder
                                                .aggregatorOrderId
                                                .toString(),
                                            createdAt: order
                                                .orderDetailsOrder.createdAt,
                                            readyAt:
                                                order.orderDetailsOrder.readyAt,
                                            prepTimeMins: int.parse(order
                                                    .orderDetailsOrder
                                                    .preparationTime ??
                                                '0')),
                                      ),

                                    if (order.orderDetailsOrder.fOrderStatus !=
                                        0)
                                      Text(
                                          '₹ ${order.orderDetailsOrder.orderAmount}',
                                          style: rupeeForadianRegular.copyWith(
                                              fontSize: 14,
                                              color: Color(0xFF18A84A))),
                                    if (order.orderDetailsOrder.fOrderStatus !=
                                        0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                            '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                            style: montserratMedium.copyWith(
                                                fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ),
                              if (order.orderDetailsOrder.fOrderStatus != 0)
                                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 7),
                                    height: Get.height * 0.05,
                                    width: 2,
                                    color: Color(0xFFF0F0F0)),
                              // Text(
                              //     '\u20B9 ${order.orderDetailsOrder.orderAmount} ',
                              //     style:
                              //         rupeeForadianRegular.copyWith(
                              //             fontSize: 14,
                              //             color: Color(0xFF18A84A)))
                              if (order.orderDetailsOrder.fOrderStatus != 0)
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
                                            color: ColorTheme.borderGrey)),
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
                      order.orderDetailsOrder.fOrderStatus == 0
                          ? Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '₹ ${order.orderDetailsOrder.orderAmount}',
                                          style: rupeeForadianRegular.copyWith(
                                              fontSize: 18,
                                              color: Color(0xFF18A84A))),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                            '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                            style: montserratMedium.copyWith(
                                                fontSize: 12)),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                Spacer(),
                                Row(
                                  children: [
                                    Text('OTP ',
                                        style: montserratRegular.copyWith(
                                          fontSize: 18,
                                        )),
                                    SizedBox(width: 5),
                                    Text('${order.orderDetailsOrder.otp}',
                                        style: montserratSemiBold.copyWith(
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

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  // border:
                  //     Border.all( color: Colors.red)
                ),
              );
            }).toList(),
            // },
          ),

          // StaggeredGrid.count(
          //   crossAxisCount: MediaQuery.of(context).size.shortestSide <= 600
          //       ? 1
          //       : MediaQuery.of(context).size.width >= 1500
          //           ? 3
          //           : 2,
          //   crossAxisSpacing:
          //       MediaQuery.of(context).size.shortestSide > 600 ? 20 : 0,
          //   mainAxisSpacing: 20,
          //   children: swiggyController.order.where((order) {
          //     if ((order.orderDetailsOrder.fOrderStatus == 0 ||
          //             order.orderDetailsOrder.fOrderStatus == 1) &&
          //         (searchOrder.text.isEmpty
          //             ? true
          //             : order.orderDetailsOrder.aggregatorOrderId
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(searchOrder.text.toLowerCase()))) {
          //       return true;
          //     }
          //     return false;
          //   }).map((order) {
          //     return Container(
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: const BorderRadius.all(Radius.circular(10)),
          //           border: Border.all(
          //               color: MediaQuery.of(context).size.shortestSide >= 600
          //                   ? ColorTheme.borderGrey
          //                   : Colors.transparent)),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(
          //             vertical: 15.0, horizontal: 20),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Row(
          //               children: [
          //                 SvgPicture.asset(
          //                   order.orderDetailsOrder.orderPlateform == 'zomato'
          //                       ? Images.zomato
          //                       : Images.swiggy,
          //                   height: screenHeight * 0.045,
          //                   width: screenWidth * 0.045,
          //                 ),
          //                 const SizedBox(width: 10),
          //                 Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     Text(
          //                       '#${order.orderDetailsOrder.aggregatorOrderId ?? ''}',
          //                       style: montserratMedium.copyWith(
          //                           fontSize: 16,
          //                           color: image == 1
          //                               ? const Color(0xFFF08520)
          //                               : const Color(0xFFE23744)),
          //                     ),
          //                     Text(
          //                       Jiffy.parse(order.orderDetailsOrder.createdAt)
          //                           .fromNow(),
          //                       style: montserratSemiBold.copyWith(
          //                           fontSize: 11.5,
          //                           color: const Color(0xFF2E2E2E)),
          //                     ),
          //                   ],
          //                 ),
          //                 const Spacer(),
          //                 if (order.orderDetailsOrder.fOrderStatus == 1)
          //                   Row(
          //                     children: [
          //                       Text('READY',
          //                           style: montserratSemiBold.copyWith(
          //                               fontSize: 12,
          //                               color: const Color(0xFF8C8C8C))),
          //                       const SizedBox(width: 10),
          //                       InkWell(
          //                         onTap: () async {
          //                           Map<String, dynamic> jsonBody = {
          //                             'order_id': order.orderDetailsOrder.id,
          //                             "urban_order_id":
          //                                 order.orderDetailsOrder.urbanOrderId,
          //                             'new_status': 'Food Ready',
          //                             'message': 'Success'
          //                           };
          //                           await swiggyController
          //                               .changeOrderStatus(jsonBody);
          //                         },
          //                         child: SvgPicture.asset(
          //                           Images.correct_button,
          //                           height: screenHeight * 0.047,
          //                         ),
          //                       ),
          //                     ],
          //                   )
          //               ],
          //             ),
          //             const SizedBox(height: 5),
          //             const Divider(
          //               height: 20,
          //               thickness: 1,
          //               color: Color(0xFFF0F0F0),
          //             ),
          //             const SizedBox(height: 5),
          //             Column(
          //               children: [
          //                 Row(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   children: [
          //                     Expanded(
          //                       flex: 4,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           ListView.separated(
          //                               padding: EdgeInsets.zero,
          //                               physics: const BouncingScrollPhysics(),
          //                               shrinkWrap: true,
          //                               itemCount:
          //                                   order.orderDetailsFood.length,
          //                               separatorBuilder: (context, foodIndex) {
          //                                 return const Divider(
          //                                   thickness: 1,
          //                                   height: 30,
          //                                   color: Color(0xFFF0F0F0),
          //                                 );
          //                               },
          //                               itemBuilder:
          //                                   (BuildContext context, int i) {
          //                                 String? addonGroupTitle;
          //                                 String? variationGroupTitle;
          //                                 String addonText = '';
          //                                 String variationText = '';

          //                                 for (var addon in order
          //                                     .orderDetailsFood[i].addOns) {
          //                                   if (addon.group != null) {
          //                                     if (addon.group!.isVariant ==
          //                                         true) {
          //                                       // 🔹 Handle Variation
          //                                       variationGroupTitle ??=
          //                                           addon.group!.title ?? '';
          //                                       variationText +=
          //                                           "${addon.title}(${addon.quantity ?? 0}), ";
          //                                     } else {
          //                                       // 🔹 Handle Add-on
          //                                       addonGroupTitle ??=
          //                                           addon.group!.title ?? '';
          //                                       addonText +=
          //                                           "${addon.title}(${addon.quantity ?? 0}), ";
          //                                     }
          //                                   }
          //                                 }
          //                                 if (addonText.isNotEmpty) {
          //                                   addonText =
          //                                       "${addonText.trim().replaceAll(RegExp(r',$'), '')}";
          //                                   // "$addonGroupTitle (${addonText.trim().replaceAll(RegExp(r',$'), '')})";
          //                                 }
          //                                 if (variationText.isNotEmpty) {
          //                                   variationText =
          //                                       "${variationText.trim().replaceAll(RegExp(r',$'), '')}";
          //                                   // variationText =
          //                                   //     "$variationGroupTitle (${variationText.trim().replaceAll(RegExp(r',$'), '')})";
          //                                 }
          //                                 return Row(
          //                                   crossAxisAlignment:
          //                                       CrossAxisAlignment.start,
          //                                   children: [
          //                                     const Padding(
          //                                       padding:
          //                                           EdgeInsets.only(top: 5.0),
          //                                       child: CircleAvatar(
          //                                         backgroundColor: Colors.red,
          //                                         radius: 4,
          //                                       ),
          //                                     ),
          //                                     const SizedBox(width: 5),
          //                                     Flexible(
          //                                       child: Column(
          //                                         mainAxisAlignment:
          //                                             MainAxisAlignment.start,
          //                                         crossAxisAlignment:
          //                                             CrossAxisAlignment.start,
          //                                         children: [
          //                                           Text(
          //                                               '${order.orderDetailsFood[i].title} (${order.orderDetailsFood[i].quantity})',
          //                                               style: montserratMedium
          //                                                   .copyWith(
          //                                                       fontSize: 15)),
          //                                           const SizedBox(height: 5),
          //                                           if (variationText != '')
          //                                             Row(
          //                                               children: [
          //                                                 Text('Variant:',
          //                                                     style: montserratMedium
          //                                                         .copyWith(
          //                                                             fontSize:
          //                                                                 12,
          //                                                             color: Colors
          //                                                                 .blue)),
          //                                                 const SizedBox(
          //                                                   width: 5,
          //                                                 ),
          //                                                 Text(variationText,
          //                                                     style: montserratMedium
          //                                                         .copyWith(
          //                                                             fontSize:
          //                                                                 12)),
          //                                               ],
          //                                             ),
          //                                           const SizedBox(height: 5),
          //                                           if (addonText != '')
          //                                             Row(
          //                                               children: [
          //                                                 Text('Addons:',
          //                                                     style: montserratMedium
          //                                                         .copyWith(
          //                                                             fontSize:
          //                                                                 12,
          //                                                             color: Colors
          //                                                                 .blue)),
          //                                                 const SizedBox(
          //                                                   width: 5,
          //                                                 ),
          //                                                 Text(addonText,
          //                                                     style: montserratMedium
          //                                                         .copyWith(
          //                                                             fontSize:
          //                                                                 12)),
          //                                               ],
          //                                             ),
          //                                         ],
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 );
          //                               }),
          //                           if (order.orderDetailsOrder.fOrderStatus !=
          //                               0)
          //                             Text(
          //                                 '₹ ${order.orderDetailsOrder.orderAmount}',
          //                                 style: rupeeForadianRegular.copyWith(
          //                                     fontSize: 14,
          //                                     color: const Color(0xFF18A84A))),
          //                           if (order.orderDetailsOrder.fOrderStatus !=
          //                               0)
          //                             Padding(
          //                               padding: const EdgeInsets.only(top: 5),
          //                               child: Text(
          //                                   'Customer Id | ${order.customerDetails.phone}',
          //                                   style: montserratMedium.copyWith(
          //                                       fontSize: 12)),
          //                             ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 )
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   }).toList(),
          // ),
        ),
      );
    });
  }

  void connectToSocketIO() {
    try {
      socket = io(
        AppConstants.SOCKET_BASE_URL,
        OptionBuilder()
            // .setPath('/socket')
            .setTransports(['websocket'])
            .enableForceNew()
            .enableReconnection()
            .enableAutoConnect()
            .build(),
      );

      // CR-077: join the restaurant room on every connect/reconnect.
      // Registered before connect() so the first 'connect' event is never missed.
      socket?.onConnect((_) {
        socket?.emit('join_restaurant', {
          'restaurant_id':
              Get.find<AuthController>().profileModel!.restaurants![0].id
        });
      });
      socket?.on('joined_restaurant', (data) {
        print('[socket] joined ${data['room']}');
      });

      socket!.connect();

      socket!.on(
          'aggregator_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}',
          (data) async {
        if (Get.find<AuthController>()
                .profileModel!
                .restaurants![0]
                .id
                .toString() ==
            '${data[2]}') {
          if (data[0] == 'aggrigator-order' ||
              data[0] == 'aggrigator-order-update') {
            checkQueueProcessFromSocket(
                orderType: data[0],
                orderId: '${data[1]}',
                otherValue: '0',
                newOrderJson: data[0] == 'new-order' ? data[4] : null);
          }
        }
      });

      socket!.on('disconnect', (d) {
        socket = io(
          AppConstants.SOCKET_BASE_URL,
          OptionBuilder()
              // .setPath('/socket')
              .setTransports(['websocket'])
              .enableForceNew()
              .enableReconnection()
              .enableAutoConnect()
              .build(),
        );
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void processNextOrderFromSocket() async {
    if (orderIdQueue.isEmpty || isProcessingOrderQueue) return;

    isProcessingOrderQueue = true;

    var currentOrder = orderIdQueue.removeAt(0);

    try {
      await Get.find<SwiggyController>().getOrderDetailFromSocket(
        foodStatus: '0',
        type: currentOrder.orderType!,
        orderId: '${currentOrder.orderId}',
      );
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      isProcessingOrderQueue = false;
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket();
      }
    }
  }

  void checkQueueProcessFromSocket(
      {required String orderType,
      required String orderId,
      required String otherValue,
      dynamic newOrderJson}) {
    orderIdQueue.add(OrderIdType(
        orderId: orderId,
        orderType: orderType,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
    }
  }

  Widget cancelOrder(Order order) {
    String? selectedReason;
    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.only(
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
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: ColorTheme.borderGrey),
                ),
                const SizedBox(height: 10),
                GetBuilder<SwiggyController>(builder: (swiggyController) {
                  return swiggyController.cancelReasonList.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              height: MediaQuery.of(context).size.width > 1600
                                  ? 65
                                  : 40,
                              padding: const EdgeInsets.symmetric(
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
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    1600
                                                ? 17
                                                : Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedReason = value;
                                  });
                                  swiggyController.update();
                                },
                                underline: const SizedBox(),
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.PADDING_SIZE_LARGE),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: swiggyController.isLoading
                                  ? const CircularProgressIndicator()
                                  : InkWell(
                                      onTap: () async {
                                        Map<String, dynamic> jsonBody = {
                                          'order_id':
                                              order.orderDetailsOrder.id,
                                          "urban_order_id": order
                                              .orderDetailsOrder.urbanOrderId,
                                          'new_status': 'Cancelled',
                                          'message': 'Success',
                                          'reason_code': selectedReason
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
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Text(
                                            'submit'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 18
                                                    : 14,
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

  void dialPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
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
}
