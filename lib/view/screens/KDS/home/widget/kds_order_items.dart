import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/update_widget_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_station_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/food_item_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart' as jiffy;

class KdsOrderItemList extends StatelessWidget {
  final List<OrderDetailsFood> orderItemList;
  final Orders order;
  int? orderStatus;
  final bool? isWaiter;
  final FlutterTts flutterTts;

  KdsOrderItemList({
    super.key,
    required this.orderItemList,
    required this.order,
    this.orderStatus,
    this.isWaiter,
    required this.flutterTts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: orderItemList.length,
            itemBuilder: (BuildContext context, int index) {
              String variationText = '';

              if (orderItemList[index].variation!.isNotEmpty) {
                for (int j = 0;
                    j < orderItemList[index].variation!.length;
                    j++) {
                  variationText +=
                      '${variationText.isNotEmpty ? ', ' : ''}${orderItemList[index].variation![j].name} (';

                  if (orderItemList[index].variation![j].values != null) {
                    List<String> labelList = [];
                    for (var element
                        in orderItemList[index].variation![j].values!) {
                      labelList.add(element.level!);
                    }
                    variationText +=
                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                  }
                  variationText += ')';
                }
              }

              String addons = '';
              String voiceAddons = '';
              for (var i = 0; i < orderItemList[index].addOns!.length; i++) {
                addons +=
                    '${orderItemList[index].addOns![i].name} (${orderItemList[index].addOns![i].qty})';
                voiceAddons +=
                    '(${orderItemList[index].addOns![i].qty}) ${orderItemList[index].addOns![i].name}';
              }
              return orderItemList[index].foodStatus == 2 &&
                      Get.find<KdsController>().selectedSubMenu == 1 &&
                      Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .defOrdStatus ==
                          1
                  ? const SizedBox.shrink()
                  : orderItemList[index].foodDetails!.name!.toUpperCase() ==
                          'CHECK IN'
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const SizedBox(
                                height: Dimensions.PADDING_SIZE_SMALL),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${orderItemList[index].foodDetails!.name ?? ''} (${orderItemList[index].quantity})',
                                                style: poppinsSemiBold.copyWith(
                                                  fontSize: 15,
                                                  decoration:
                                                      orderItemList[index]
                                                                  .foodStatus ==
                                                              3
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                  color: orderItemList[index]
                                                              .foodStatus ==
                                                          3
                                                      ? ColorTheme
                                                          .disableButtonText
                                                      : Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (addons != '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Add-Ons :',
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: 11,
                                                        color: ColorTheme
                                                            .kdsLeftMenuBlue),
                                                  ),
                                                  TextSpan(
                                                    text: ' $addons',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: 11,
                                                      color: ColorTheme.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        if (variationText != '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Variants  :',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text: ' $variationText',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .green),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        if (orderItemList[index]
                                                .foodLevelNotes !=
                                            '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Notes  :',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' ${orderItemList[index].foodLevelNotes}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .green),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        GetBuilder<KdsController>(
                                            builder: (kdsController) {
                                          String showTime = '';
                                          showTime = jiffy.Jiffy.parse(
                                                  orderItemList[index]
                                                      .createdAt!)
                                              .fromNow();

                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '$showTime',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10,
                                                    color: ColorTheme.hintText),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  if (orderStatus != 7)
                                    const SizedBox(width: 20),
                                  if (Get
                                                  .find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .defOrdStatus !=
                                          2 &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .defOrdStatus !=
                                          5 &&
                                      order.orderDetailsOrder!.orderType !=
                                          'delivery' &&
                                      order.orderDetailsOrder!.orderType !=
                                          'take_away')
                                    orderStatus == 7
                                        ? const SizedBox.shrink()
                                        : orderItemList[index].foodStatus == 1
                                            ? FoodButton(
                                                onTap: () {
                                                  Map<String, dynamic>
                                                      jsonBody = {
                                                    'order_id': order
                                                        .orderDetailsOrder!.id
                                                        .toString(),
                                                    'order_food_id': order
                                                        .orderDetailsFood![
                                                            index]
                                                        .foodDetails!
                                                        .id
                                                        .toString(),
                                                    'item_id': order
                                                        .orderDetailsFood![
                                                            index]
                                                        .id
                                                        .toString(),
                                                    'order_status':
                                                        orderItemList[index]
                                                                    .foodStatus ==
                                                                1
                                                            ? 'ready'
                                                            : 'cooking'
                                                  };
                                                  if (orderItemList[index]
                                                              .foodStatus ==
                                                          1 ||
                                                      orderItemList[index]
                                                              .foodStatus ==
                                                          0) {
                                                    Get.find<KdsController>()
                                                        .changeFoodOrderStatus(
                                                            jsonBody, callback);
                                                  }
                                                },
                                                title: 'ready'.tr,
                                              )
                                            : FoodButton(
                                                onTap: () {},
                                                isDisable: true,
                                                title: orderStatus == 0 &&
                                                        orderItemList[index]
                                                                .foodStatus ==
                                                            1
                                                    ? 'accept'.tr
                                                    : orderStatus == 1 &&
                                                            orderItemList[index]
                                                                    .foodStatus ==
                                                                2
                                                        ? 'ready'.tr
                                                        : orderStatus == 2
                                                            ? 'Serve'
                                                            : orderItemList[index]
                                                                        .foodStatus ==
                                                                    5
                                                                ? 'Served'
                                                                : 'cancel'.tr,
                                              )
                                ],
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.PADDING_SIZE_SMALL),
                            DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ],
                        );
            }),
        if (order.readyDetails != null &&
            order.readyDetails!.isNotEmpty &&
            Get.find<KdsController>().selectedSubMenu == 1 &&
            Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .defOrdStatus ==
                1)
          ExpansionTile(
            title: Row(
              children: [
                Text(
                  'Ready Item (${order.readyDetails!.length})',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 15,
                    color: ColorTheme.disableButtonText,
                  ),
                ),
              ],
            ),
            children: order.readyDetails!.map((e) {
              String variationText = '';

              if (e.variation != null && e.variation!.isNotEmpty) {
                for (int j = 0; j < e.variation!.length; j++) {
                  variationText +=
                      '${variationText.isNotEmpty ? ', ' : ''}${e.variation![j].name} (';

                  if (e.variation![j].values != null) {
                    List<String> labelList = [];
                    for (var element in e.variation![j].values!) {
                      labelList.add(element.level!);
                    }
                    variationText +=
                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                  }

                  variationText += ')';
                }
              }

              String addons = '';
              if (e.addOns != null) {
                for (var i = 0; i < e.addOns!.length; i++) {
                  addons += '${e.addOns![i].name} (${e.addOns![i].qty})';
                }
              }
              return (e.foodDetails?.name?.toUpperCase() ?? '') == 'CHECK IN'
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${e.foodDetails!.name ?? ''} (${e.quantity})',
                                            style: poppinsSemiBold.copyWith(
                                              fontSize: 15,
                                              decoration: e.foodStatus == 3
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: e.foodStatus == 3
                                                  ? ColorTheme.disableButtonText
                                                  : Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (addons != '')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Add-Ons :',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 11,
                                                    color: ColorTheme
                                                        .kdsLeftMenuBlue),
                                              ),
                                              TextSpan(
                                                text: ' $addons',
                                                style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (variationText != '')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Variants  :',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 11,
                                                    color: ColorTheme.blue),
                                              ),
                                              TextSpan(
                                                text: ' $variationText',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 11,
                                                    color: ColorTheme.green),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    GetBuilder<KdsController>(
                                        builder: (kdsController) {
                                      String showTime = '';
                                      showTime = jiffy.Jiffy.parse(e.createdAt!)
                                          .fromNow();

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '$showTime',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 10,
                                                color: ColorTheme.hintText),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              if (orderStatus != 7) const SizedBox(width: 20),
                              if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .defOrdStatus !=
                                      2 &&
                                  Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .defOrdStatus !=
                                      5)
                                orderStatus == 7
                                    ? const SizedBox.shrink()
                                    : e.foodStatus == 1
                                        ? FoodButton(
                                            onTap: () {
                                              Map<String, dynamic> jsonBody = {
                                                'order_id': order
                                                    .orderDetailsOrder!.id
                                                    .toString(),
                                                'order_food_id': e
                                                    .foodDetails!.id
                                                    .toString(),
                                                'item_id': e.id.toString(),
                                                'order_status':
                                                    e.foodStatus == 1
                                                        ? 'ready'
                                                        : 'cooking'
                                              };
                                              if (e.foodStatus == 1 ||
                                                  e.foodStatus == 0) {
                                                Get.find<KdsController>()
                                                    .changeFoodOrderStatus(
                                                        jsonBody, callback);
                                              }
                                            },
                                            title: 'ready'.tr,
                                          )
                                        : FoodButton(
                                            onTap: () {},
                                            isDisable: true,
                                            title: orderStatus == 0 &&
                                                    e.foodStatus == 1
                                                ? 'accept'.tr
                                                : orderStatus == 1 &&
                                                        e.foodStatus == 2
                                                    ? 'ready'.tr
                                                    : orderStatus == 2
                                                        ? 'Serve'
                                                        : e.foodStatus == 5
                                                            ? 'Served'
                                                            : 'cancel'.tr,
                                          )
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          lineThickness: 1.0,
                          dashLength: 2.5,
                          dashColor: ColorTheme.hintText,
                        ),
                      ],
                    );
            }).toList(),
          ),
      ],
    );
  }

  void callback(bool isSuccess, String message) async {}

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      Get.find<UpdateWidgetController>().updateFoodUi('');
    });
  }
}

class KdsTabletOrderItemList extends StatelessWidget {
  final List<OrderDetailsFood> orderItemList;
  final Orders order;
  int? orderStatus;
  final FlutterTts flutterTts;

  KdsTabletOrderItemList({
    super.key,
    required this.orderItemList,
    required this.order,
    this.orderStatus,
    required this.flutterTts,
  });

  @override
  Widget build(BuildContext context) {
    return buildWithOptionalExpanded(
      useExpanded: Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .listServeItem ==
          'Fixed',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderItemList.length,
                itemBuilder: (BuildContext context, int index) {
                  String variationText = '';

                  if (orderItemList[index].variation!.isNotEmpty) {
                    for (int j = 0;
                        j < orderItemList[index].variation!.length;
                        j++) {
                      variationText +=
                          '${variationText.isNotEmpty ? ', ' : ''}${orderItemList[index].variation![j].name} (';

                      if (orderItemList[index].variation![j].values != null) {
                        List<String> labelList = [];
                        for (var element
                            in orderItemList[index].variation![j].values!) {
                          labelList.add(element.level!);
                        }
                        variationText +=
                            '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                      }
                      variationText += ')';
                    }
                  }

                  String addons = '';
                  String addonsVoice = '';
                  for (var i = 0;
                      i < orderItemList[index].addOns!.length;
                      i++) {
                    addons +=
                        '${orderItemList[index].addOns![i].name} (${orderItemList[index].addOns![i].qty})';
                    addonsVoice +=
                        '(${orderItemList[index].addOns![i].qty}) ${orderItemList[index].addOns![i].name}';
                  }
                  return orderItemList[index].foodStatus == 2 &&
                          Get.find<KdsController>().selectedSubMenu == 1 &&
                          Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .defOrdStatus ==
                              1
                      ? const SizedBox.shrink()
                      : orderItemList[index].foodDetails!.name!.toUpperCase() ==
                              'CHECK IN'
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${orderItemList[index].foodDetails!.name ?? ''} (${orderItemList[index].quantity != null && orderItemList[index].quantity! % 1 == 0 ? orderItemList[index].quantity!.toInt() : orderItemList[index].quantity})',
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                      fontSize: 15,
                                                      decoration: orderItemList[
                                                                      index]
                                                                  .foodStatus ==
                                                              3
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                      color: orderItemList[
                                                                      index]
                                                                  .foodStatus ==
                                                              3
                                                          ? ColorTheme
                                                              .disableButtonText
                                                          : Colors.black,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (addons != '')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Add-Ons :',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 11,
                                                                color: ColorTheme
                                                                    .kdsLeftMenuBlue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $addons',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: 11,
                                                          color:
                                                              ColorTheme.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            if (variationText != '')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Variants  :',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    ColorTheme
                                                                        .blue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $variationText',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    ColorTheme
                                                                        .green),
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            if (orderItemList[index]
                                                    .foodLevelNotes !=
                                                '')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Notes  :',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    ColorTheme
                                                                        .blue),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' ${orderItemList[index].foodLevelNotes}',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    ColorTheme
                                                                        .green),
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            GetBuilder<KdsController>(
                                                builder: (kdsController) {
                                              String showTime = '';
                                              showTime = jiffy.Jiffy.parse(
                                                      orderItemList[index]
                                                          .createdAt!)
                                                  .fromNow();

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '$showTime',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 10,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      if (orderStatus != 7)
                                        const SizedBox(width: 20),
                                      if (Get
                                                      .find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .defOrdStatus !=
                                              2 &&
                                          Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .defOrdStatus !=
                                              5 &&
                                          order.orderDetailsOrder!.orderType !=
                                              'delivery' &&
                                          order.orderDetailsOrder!.orderType !=
                                              'take_away')
                                        orderStatus == 7
                                            ? const SizedBox.shrink()
                                            : orderItemList[index].foodStatus ==
                                                    1
                                                ? FoodButton(
                                                    onTap: () {
                                                      Map<String, dynamic>
                                                          jsonBody = {
                                                        'order_id': order
                                                            .orderDetailsOrder!
                                                            .id
                                                            .toString(),
                                                        'order_food_id': order
                                                            .orderDetailsFood![
                                                                index]
                                                            .foodDetails!
                                                            .id
                                                            .toString(),
                                                        'item_id': order
                                                            .orderDetailsFood![
                                                                index]
                                                            .id
                                                            .toString(),
                                                        'order_status':
                                                            orderItemList[index]
                                                                        .foodStatus ==
                                                                    1
                                                                ? 'ready'
                                                                : 'cooking'
                                                      };
                                                      if (orderItemList[index]
                                                                  .foodStatus ==
                                                              1 ||
                                                          orderItemList[index]
                                                                  .foodStatus ==
                                                              0) {
                                                        Get.find<
                                                                KdsController>()
                                                            .changeFoodOrderStatus(
                                                                jsonBody,
                                                                callback);
                                                      }
                                                    },
                                                    title: 'ready'.tr,
                                                  )
                                                : FoodButton(
                                                    onTap: () {},
                                                    isDisable: true,
                                                    title: orderStatus == 0 &&
                                                            orderItemList[index]
                                                                    .foodStatus ==
                                                                1
                                                        ? 'accept'.tr
                                                        : orderStatus == 1 &&
                                                                orderItemList[
                                                                            index]
                                                                        .foodStatus ==
                                                                    2
                                                            ? 'ready'.tr
                                                            : orderStatus == 2
                                                                ? 'Serve'
                                                                : orderItemList[index]
                                                                            .foodStatus ==
                                                                        5
                                                                    ? 'Served'
                                                                    : 'cancel'
                                                                        .tr,
                                                  )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL),
                                DottedLine(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.center,
                                  lineThickness: 1.0,
                                  dashLength: 2.5,
                                  dashColor: ColorTheme.hintText,
                                ),
                              ],
                            );
                }),
            if (order.readyDetails != null &&
                order.readyDetails!.isNotEmpty &&
                Get.find<KdsController>().selectedSubMenu == 1 &&
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .defOrdStatus ==
                    1)
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      'Ready Item (${order.readyDetails!.length})',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 15,
                        color: ColorTheme.disableButtonText,
                      ),
                    ),
                  ],
                ),
                children: order.readyDetails!.map((e) {
                  String variationText = '';

                  if (e.variation != null && e.variation!.isNotEmpty) {
                    for (int j = 0; j < e.variation!.length; j++) {
                      variationText +=
                          '${variationText.isNotEmpty ? ', ' : ''}${e.variation![j].name} (';

                      if (e.variation![j].values != null) {
                        List<String> labelList = [];
                        for (var element in e.variation![j].values!) {
                          labelList.add(element.level!);
                        }
                        variationText +=
                            '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                      }

                      variationText += ')';
                    }
                  }

                  String addons = '';
                  for (var i = 0; i < e.addOns!.length; i++) {
                    addons += '${e.addOns![i].name} (${e.addOns![i].qty})';
                  }
                  return e.foodDetails!.name!.toUpperCase() == 'CHECK IN'
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const SizedBox(
                                height: Dimensions.PADDING_SIZE_SMALL),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${e.foodDetails!.name ?? ''} (${e.quantity})',
                                                style: poppinsSemiBold.copyWith(
                                                  fontSize: 15,
                                                  decoration: e.foodStatus == 3
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                  color: e.foodStatus == 3
                                                      ? ColorTheme
                                                          .disableButtonText
                                                      : Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (addons != '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Add-Ons :',
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: 11,
                                                        color: ColorTheme
                                                            .kdsLeftMenuBlue),
                                                  ),
                                                  TextSpan(
                                                    text: ' $addons',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: 11,
                                                      color: ColorTheme.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        if (variationText != '')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Variants  :',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text: ' $variationText',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .green),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        GetBuilder<KdsController>(
                                            builder: (kdsController) {
                                          String showTime = '';
                                          showTime =
                                              jiffy.Jiffy.parse(e.createdAt!)
                                                  .fromNow();

                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '$showTime',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10,
                                                    color: ColorTheme.hintText),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  if (orderStatus != 7)
                                    const SizedBox(width: 20),
                                  if (Get
                                                  .find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .defOrdStatus !=
                                          2 &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .defOrdStatus !=
                                          5 &&
                                      order.orderDetailsOrder!.orderType !=
                                          'delivery' &&
                                      order.orderDetailsOrder!.orderType !=
                                          'take_away')
                                    orderStatus == 7
                                        ? const SizedBox.shrink()
                                        : e.foodStatus == 1
                                            ? FoodButton(
                                                onTap: () {
                                                  Map<String, dynamic>
                                                      jsonBody = {
                                                    'order_id': order
                                                        .orderDetailsOrder!.id
                                                        .toString(),
                                                    'order_food_id': e
                                                        .foodDetails!.id
                                                        .toString(),
                                                    'item_id': e.id.toString(),
                                                    'order_status':
                                                        e.foodStatus == 1
                                                            ? 'ready'
                                                            : 'cooking'
                                                  };
                                                  if (e.foodStatus == 1 ||
                                                      e.foodStatus == 0) {
                                                    Get.find<KdsController>()
                                                        .changeFoodOrderStatus(
                                                            jsonBody, callback);
                                                  }
                                                },
                                                title: 'ready'.tr,
                                              )
                                            : FoodButton(
                                                onTap: () {},
                                                isDisable: true,
                                                title: orderStatus == 0 &&
                                                        e.foodStatus == 1
                                                    ? 'accept'.tr
                                                    : orderStatus == 1 &&
                                                            e.foodStatus == 2
                                                        ? 'ready'.tr
                                                        : orderStatus == 2
                                                            ? 'Serve'
                                                            : e.foodStatus == 5
                                                                ? 'Served'
                                                                : 'cancel'.tr,
                                              )
                                ],
                              ),
                            ),
                            const SizedBox(
                                height: Dimensions.PADDING_SIZE_SMALL),
                            DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),
                          ],
                        );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {}

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
