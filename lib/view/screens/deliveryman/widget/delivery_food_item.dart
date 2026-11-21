import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/kds_controller.dart';

class DeliveryFoodItem extends StatelessWidget {
  final List<OrderDetails> orderItemList;
  final OrderList order;
  final bool isWaiter;
  final TextEditingController searchOrder;
  final FlutterTts flutterTts;

  DeliveryFoodItem({
    Key? key,
    required this.orderItemList,
    required this.order,
    required this.isWaiter,
    required this.searchOrder,
    required this.flutterTts,
  }) : super(key: key);
  final TextEditingController cancelReason = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return buildWithOptionalExpanded(
      useExpanded: MediaQuery.of(context).size.shortestSide <= 570
          ? false
          : Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .listServeItem ==
              'Fixed',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: orderItemList.length,
                itemBuilder: (BuildContext context, int index) {
                  String variationText = '';
                  if (orderItemList[index].variation != null &&
                      orderItemList[index].variation!.isNotEmpty &&
                      Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .foodWithVariance ==
                          'Yes') {
                    variationText += '';
                    List<String> labelList = [];

                    for (int j = 0;
                        j < (orderItemList[index].variation?.length ?? 0);
                        j++) {
                      final variation = orderItemList[index].variation?[j];
                      if (variation?.values != null) {
                        for (var element in variation!.values!) {
                          labelList.add(element.level ?? '');
                        }
                      }
                    }
                    variationText += '${labelList.join(',')}';
                    variationText += '';
                  } else if (orderItemList[index].variation != null &&
                      (orderItemList[index].variation?.isNotEmpty ?? false) &&
                      (Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .foodWithVariance !=
                          'Yes')) {
                    for (int j = 0;
                        j < (orderItemList[index].variation?.length ?? 0);
                        j++) {
                      final variation = orderItemList[index].variation?[j];
                      variationText +=
                          '${variationText.isNotEmpty ? ', ' : ''}${variation?.name ?? ''} (';

                      if (variation?.values != null) {
                        List<String> labelList = [];
                        for (var element in variation!.values!) {
                          labelList.add(element.level ?? '');
                        }
                        variationText +=
                            '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                      }

                      variationText += '';
                    }
                  }
                  String addons = '';
                  for (var i = 0;
                      i < (orderItemList[index].addOns?.length ?? 0);
                      i++) {
                    final addOn = orderItemList[index].addOns?[i];
                    if (addons != '') {
                      addons += ', ';
                    }
                    addons += '${addOn?.name ?? ''} (${addOn?.qty ?? ''})';
                  }
                  return Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          Padding(
                            padding: EdgeInsets.only(left: 25, right: 17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .foodWithVariance ==
                                          'Yes')
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${orderItemList[index].foodDetails?.name ?? ''} (${orderItemList[index].quantity})',
                                                style: poppinsMedium.copyWith(
                                                  fontSize: 15,
                                                  decoration: orderItemList[
                                                                  index]
                                                              .isSplited ||
                                                          orderItemList[index]
                                                                  .foodStatus ==
                                                              3
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                  color: orderItemList[index]
                                                              .isSplited ||
                                                          orderItemList[index]
                                                                  .foodStatus ==
                                                              3
                                                      ? ColorTheme
                                                          .disableButtonText
                                                      : Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' $variationText',
                                                style: poppinsMedium.copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 11,
                                                  decoration:
                                                      orderItemList[index]
                                                              .isSplited
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                  color: orderItemList[index]
                                                          .isSplited
                                                      ? Colors.grey
                                                      : ColorTheme.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .foodWithVariance !=
                                          'Yes')
                                        Text(
                                          '${orderItemList[index].foodDetails?.name ?? ''} (${orderItemList[index].quantity})',
                                          style: poppinsSemiBold.copyWith(
                                            fontSize: 15,
                                            decoration: orderItemList[index]
                                                        .isSplited ||
                                                    orderItemList[index]
                                                            .foodStatus ==
                                                        3
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: orderItemList[index]
                                                        .isSplited ||
                                                    orderItemList[index]
                                                            .foodStatus ==
                                                        3
                                                ? ColorTheme.disableButtonText
                                                : Colors.black,
                                          ),
                                        ),
                                      addons == ''
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Add-Ons :',
                                                      style: poppinsMedium.copyWith(
                                                          fontSize: 11,
                                                          decoration: orderItemList[
                                                                      index]
                                                                  .isSplited
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                          color: orderItemList[
                                                                      index]
                                                                  .isSplited
                                                              ? Colors.grey
                                                              : ColorTheme
                                                                  .kdsLeftMenuBlue),
                                                    ),
                                                    TextSpan(
                                                      text: ' $addons',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 11,
                                                        decoration:
                                                            orderItemList[index]
                                                                    .isSplited
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                        color:
                                                            orderItemList[index]
                                                                    .isSplited
                                                                ? Colors.grey
                                                                : ColorTheme
                                                                    .green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .foodWithVariance !=
                                          'Yes')
                                        variationText == ''
                                            ? SizedBox.shrink()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Variants  :',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            decoration: orderItemList[
                                                                        index]
                                                                    .isSplited
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                            color: orderItemList[
                                                                        index]
                                                                    .isSplited
                                                                ? Colors.grey
                                                                : ColorTheme
                                                                    .blue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $variationText',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            decoration: orderItemList[
                                                                        index]
                                                                    .isSplited
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                            color: orderItemList[
                                                                        index]
                                                                    .isSplited
                                                                ? Colors.grey
                                                                : ColorTheme
                                                                    .green),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      orderItemList[index].foodLevelNotes == ''
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Notes  :',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 11,
                                                              color: ColorTheme
                                                                  .blue),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' ${orderItemList[index].foodLevelNotes}',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 11,
                                                              color: ColorTheme
                                                                  .green),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      Row(
                                        children: [
                                          GetBuilder<KdsController>(
                                              builder: (kdsController) {
                                            String showTime = '';
                                            // Duration createTime = DateTime.now().difference(
                                            //     DateTime.parse(orderItemList[index].createdAt));

                                            showTime = Jiffy.parse(
                                                    orderItemList[index]
                                                        .createdAt!)
                                                .fromNow();
                                            // Duration readyTime;
                                            if (orderItemList[index].readyAt !=
                                                null) {
                                              // readyTime = DateTime.now().difference(
                                              //     DateTime.parse(orderItemList[index].readyAt));
                                              // showTime = '${readyTime.inMinutes}';
                                              showTime = Jiffy.parse(
                                                      orderItemList[index]
                                                          .readyAt!)
                                                  .fromNow();
                                            }
                                            if (orderItemList[index].serveAt !=
                                                null) {
                                              // Duration serveTime;

                                              // serveTime = DateTime.now().difference(
                                              //     DateTime.parse(orderItemList[index].serveAt));
                                              // showTime = '${serveTime.inMinutes}';
                                              showTime = Jiffy.parse(
                                                      orderItemList[index]
                                                          .serveAt!)
                                                  .fromNow();
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '$showTime',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 10,
                                                              color: ColorTheme
                                                                  .hintText),
                                                    ),
                                                    /*if (order.orderType != 'delivery' &&
                                                                  order.orderType !=
                                                                      'take_away' &&
                                                                  ((order.restaurantTable != null &&
                                                                          order.restaurantTable.tableNo !=
                                                                              '' &&
                                                                          order.restaurantTable.rtype !=
                                                                              'RM') ||
                                                                      order.tableId ==
                                                                          0))
                                                                InkWell(
                                                                  onTap: () {
                                                                    Get.bottomSheet(
                                                                        mergeTable(
                                                                            context,
                                                                            orderItemList[index]
                                                                                .id
                                                                                .toString(),),
                                                                        backgroundColor:
                                                                            Colors
                                                                                .transparent,
                                                                        isScrollControlled:
                                                                            true,
                                                                        ignoreSafeArea:
                                                                            false);
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5),
                                                                    child: Icon(
                                                                        Icons
                                                                            .swipe_right_outlined),
                                                                  ),
                                                                )*/
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      // InkWell(
                                      //     onTap: () {
                                      //       speak(
                                      //           '${orderItemList[index].foodDetails.name ?? ''} ${orderItemList[index].quantity}, ${addons == '' ? '' : "Add-Ons' ':''$addons"},  ${variationText == '' ? '' : "Variants  :$variationText"}');
                                      //     },
                                      //     child: Icon(Icons.play_circle_outline_outlined))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          DottedLine(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            lineThickness: 1.0,
                            dashLength: 2.5,
                            dashColor: ColorTheme.hintText,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // Get.find<KdsController>().clearOrderList();
      // Get.find<KdsController>().getWaiterPOSOrderList();
      // showCustomSnackBar(message, isError: false);
      // Get.find<OrderController>().stopLoader();

      // Get.offNamed(
      //     RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
    } else {
      // showCustomSnackBar(message);
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Widget buildWithOptionalExpanded({
    required bool useExpanded,
    required Widget child,
  }) {
    return useExpanded ? Expanded(child: child) : child;
  }
}
