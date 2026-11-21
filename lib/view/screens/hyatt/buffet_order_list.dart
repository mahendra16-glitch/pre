import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/buffet_order_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/food_item_action_button.dart';
import 'package:mygenie_restaurant/view/screens/hyatt/buffet_cancel_order_dialog.dart';

class BuffetOrderList extends StatelessWidget {
  final OrderDetails order;
  final FlutterTts flutterTit;
  final bool isWaiter;
  TextEditingController searchTable;
  TextEditingController searchOrder;

  BuffetOrderList(
      {required this.order,
      required this.flutterTit,
      this.isWaiter = false,
      required this.searchTable,
      required this.searchOrder});

  @override
  Widget build(BuildContext context) {
    final TextEditingController cancelReason = TextEditingController();
    String variationText = '';

    if (order.variation != null && order.variation!.isNotEmpty) {
      variationText += '(';
      List<String> labelList = [];

      for (int j = 0; j < order.variation!.length; j++) {
        if (order.variation![j].values != null) {
          for (var element in order.variation![j].values!) {
            labelList.add(element.level!);
          }
        }
      }
      variationText += '${labelList.join(',')}';
      variationText += ')';
    }

    String addons = '';
    for (var i = 0; i < order.addOns!.length; i++) {
      addons += '${order.addOns![i].name} (${order.addOns![i].qty})';
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: order.priority == 'Yes'
              ? Colors.red.withOpacity(0.1) // Highlight priority orders

              : Color.fromRGBO(254, 245, 208, 1)),
      child: Padding(
        padding: EdgeInsets.only(right: 17, top: 12, bottom: 12, left: 17),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Container(
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //       shape: BoxShape.circle, color: ColorTheme.appColor),
            //   child: Text(
            //     order.tableIdSeq,
            //     style:
            //         poppinsMedium.copyWith(color: Colors.white, fontSize: 11),
            //   ),
            // ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.tableIdSeq}',
                        style: poppinsSemiBold.copyWith(
                            color: Colors.black, fontSize: 15),
                      ),
                      GetBuilder<KdsController>(builder: (kdsController) {
                        String showTime = '';

                        showTime = getShortenedTimeFormat(
                            Jiffy.parse(order.createdAt!));
                        // Duration readyTime;
                        if (order.readyAt != null) {
                          showTime = getShortenedTimeFormat(
                              Jiffy.parse(order.readyAt!));
                        }
                        if (order.serveAt != null) {
                          showTime = getShortenedTimeFormat(
                              Jiffy.parse(order.serveAt!));
                        }

                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '$showTime',
                              style: poppinsMedium.copyWith(
                                  fontSize: 11, color: Colors.black),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  if (order.waiterName != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${order.waiterName ?? ''}',
                        style: poppinsSemiBold.copyWith(
                            color: ColorTheme.blue, fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${order.foodDetails?.name ?? ''}',
                          style: poppinsSemiBold.copyWith(
                            fontSize: 15,
                            decoration: TextDecoration.none,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' $variationText',
                          style: poppinsSemiBold.copyWith(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 15,
                            decoration: TextDecoration.none,
                            color: ColorTheme.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  addons == ''
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Add-Ons :',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 10,
                                      decoration: TextDecoration.none,
                                      color: ColorTheme.kdsLeftMenuBlue),
                                ),
                                TextSpan(
                                  text: ' $addons',
                                  style: poppinsMedium.copyWith(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 10,
                                    decoration: order.isSplited!
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: order.isSplited!
                                        ? Colors.grey
                                        : ColorTheme.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  if (order.foodNote != '')
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${order.foodNote}',
                        style: poppinsMedium.copyWith(
                            fontSize: 10, color: ColorTheme.kdsLeftMenuBlue),
                      ),
                    ),
                ],
              ),
            ),

            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //         ],
            //   ),
            // ),
            SizedBox(width: 10),
            if (order.priority != 'Yes' && (order.foodStatus == 2))
              InkWell(
                onTap: () {
                  Map<String, dynamic> jsonBody = {
                    'order_id': order.orderId.toString(),
                    'order_food_id': order.foodDetails!.id.toString(),
                    'item_id': order.id.toString(),
                    'priority': 'Yes'
                  };

                  Get.find<KdsController>()
                      .setBuffetFoodPriority(jsonBody, callback);
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: ColorTheme.appColor, shape: BoxShape.circle),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            if (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('order_cancel') &&
                !Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('Buffet'))
              if (((Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isPreCancel ==
                      'Yes' &&
                  (order.foodStatus == 0 ||
                      order.foodStatus == 1 ||
                      order.foodStatus == 2))))
                InkWell(
                  onTap: () {
                    searchOrder.clear();
                    FocusManager.instance.primaryFocus?.unfocus();

                    Get.bottomSheet(
                        BuffetCancelOrderDialog(
                          foodStatus: order.foodStatus!,
                          itemId: order.id.toString(),
                          controller: cancelReason,
                          foodId: order.foodDetails!.id.toString(),
                          orderId: order.orderId.toString(),
                        ),
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        ignoreSafeArea: false);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        color: ColorTheme.appColor, shape: BoxShape.circle),
                    child: Icon(
                      Icons.close,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
            if (Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('Buffet'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (order.foodDetails!.name!.toUpperCase() != 'CHECK IN')
                    Get.find<KdsController>().selectedSubMenu == 1
                        ? order.foodStatus == 0 ||
                                order.foodStatus == 1 ||
                                order.foodStatus == 3 ||
                                order.foodDetails!.name!.toUpperCase() ==
                                    'CHECK IN'
                            ? FoodButton(
                                isDisable: true,
                                onTap: () {},
                                title: order.foodStatus == 0
                                    ? 'Accept'
                                    : order.foodStatus == 1
                                        ? 'cooking'.tr
                                        : order.foodStatus == 3
                                            ? 'Cancelled'
                                            : 'cancel'.tr,
                              )
                            : FoodButton(
                                isDisable: order.foodStatus != 2 &&
                                    !Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('order_cancel'),
                                title: order.foodStatus == 2
                                    ? 'Serve'.tr
                                    : 'cancel'.tr,
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  if (order.foodStatus == 2) {
                                    Map<String, dynamic> jsonBody = {
                                      'order_id': order.orderId.toString(),
                                      'order_food_id':
                                          order.foodDetails!.id.toString(),
                                      'item_id': order.id.toString(),
                                      'order_status': 'serve'
                                    };

                                    Get.find<KdsController>()
                                        .changeFoodOrderStatus(
                                            jsonBody, callback);
                                  } else if (order.foodStatus == 5 &&
                                      Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('order_cancel')) {
                                    searchOrder.clear();
                                    Get.bottomSheet(
                                        BuffetCancelOrderDialog(
                                          foodStatus: order.foodStatus!,
                                          itemId: order.id.toString(),
                                          controller: cancelReason,
                                          foodId:
                                              order.foodDetails!.id.toString(),
                                          orderId: order.orderId.toString(),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        ignoreSafeArea: false);
                                  }
                                },
                              )
                        : order.foodDetails!.name!.toUpperCase() == 'CHECK IN'
                            ? FoodButton(
                                isDisable: true,
                                onTap: () {},
                                title: order.foodStatus == 5
                                    ? 'Serve'.tr
                                    : order.foodStatus == 3
                                        ? 'canceled'.tr
                                        : order.foodStatus == 3
                                            ? 'canceled'.tr
                                            : 'cancel'.tr,
                              )
                            : FoodButton(
                                isDisable: !Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('order_cancel') &&
                                    order.foodStatus != 2,
                                title: order.foodStatus == 2
                                    ? 'Serve'.tr
                                    : 'cancel'.tr,
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  if (order.foodStatus == 2) {
                                    Map<String, dynamic> jsonBody = {
                                      'order_id': order.orderId.toString(),
                                      'order_food_id':
                                          order.foodDetails!.id.toString(),
                                      'order_status': 'serve',
                                      'item_id': order.id.toString(),
                                    };

                                    Get.find<KdsController>()
                                        .changeFoodOrderStatus(
                                            jsonBody, callback);
                                  } else if (order.foodStatus == 5 &&
                                      Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('order_cancel')) {
                                    Get.bottomSheet(
                                        BuffetCancelOrderDialog(
                                          foodStatus: order.foodStatus!,
                                          itemId: order.id.toString(),
                                          controller: cancelReason,
                                          foodId:
                                              order.foodDetails!.id.toString(),
                                          orderId: order.orderId.toString(),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        ignoreSafeArea: false);
                                  }
                                },
                              )
                ],
              ),
          ],
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
    } else {}
  }

  String getShortenedTimeFormat(Jiffy time) {
    final diff = DateTime.now().difference(time.dateTime);

    if (diff.inMinutes < 60) {
      // If less than an hour, show minutes
      return '${diff.inMinutes} mins';
    } else if (diff.inHours < 24) {
      // If less than a day, show hours
      return '${diff.inHours} hrs';
    } else {
      // Otherwise, show days
      return '${diff.inDays} d ago';
    }
  }
}
