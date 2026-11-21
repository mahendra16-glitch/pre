import 'package:dotted_line/dotted_line.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineUnpaidOrderListContent extends StatelessWidget {
  final OrderList order;
  TextEditingController searchOrder;

  OnlineUnpaidOrderListContent(
      {required this.order, required this.searchOrder});

  @override
  Widget build(BuildContext context) {
    double roomOrderAmount = 0;

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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
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
                order.orderType == 'delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();

                              showAddressDialog(order);
                            },
                            child: Icon(CupertinoIcons.location_solid,
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
                  style:
                      poppinsMedium.copyWith(fontSize: 11, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          SizedBox(height: 9),
          Divider(color: ColorTheme.hintText, height: 1),
          foodItem(),
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

  Widget foodItem() {
    return Column(
      children: [
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: order.orderDetails?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              String variationText = '';

              if (order.orderDetails![index].variation != null &&
                  (order.orderDetails![index].variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance ==
                      'Yes')) {
                variationText += '';
                List<String> labelList = [];

                for (int j = 0;
                    j < (order.orderDetails![index].variation?.length ?? 0);
                    j++) {
                  final variationJ = order.orderDetails![index].variation?[j];
                  if (variationJ?.values != null) {
                    for (var element in (variationJ!.values ?? [])) {
                      labelList.add(element.level ?? '');
                    }
                  }
                }
                variationText += '${labelList.join(',')}';
                variationText += '';
              } else if (order.orderDetails![index].variation != null &&
                  (order.orderDetails![index].variation?.isNotEmpty ?? false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.isNotEmpty ??
                      false) &&
                  (Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .foodWithVariance !=
                      'Yes')) {
                for (int j = 0;
                    j < (order.orderDetails![index].variation?.length ?? 0);
                    j++) {
                  final variationJ = order.orderDetails![index].variation?[j];
                  variationText +=
                      '${variationText.isNotEmpty ? ', ' : ''}${variationJ?.name ?? ''} (';

                  if (variationJ?.values != null) {
                    List<String> labelList = [];
                    for (var element in (variationJ!.values ?? [])) {
                      labelList.add(element.level ?? '');
                    }
                    variationText +=
                        '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                  }

                  variationText += ')';
                }
              }

              String addons = '';
              for (var i = 0;
                  i < (order.orderDetails![index].addOns?.length ?? 0);
                  i++) {
                if (addons != '') {
                  addons += ', ';
                }
                addons +=
                    '${order.orderDetails![index].addOns?[i].name ?? ''} (${order.orderDetails![index].addOns?[i].qty ?? ''})';
              }
              return Column(
                children: [
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${order.orderDetails![index].foodDetails?.name ?? ''} (${order.orderDetails![index].quantity})',
                                                style: poppinsMedium.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' $variationText',
                                                style: poppinsMedium.copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 11,
                                                  color: ColorTheme.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: ColorTheme
                                                          .kdsLeftMenuBlue),
                                                ),
                                                TextSpan(
                                                  text: ' $addons',
                                                  style: poppinsMedium.copyWith(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 11,
                                                    color: ColorTheme.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  order.orderDetails![index].foodLevelNotes ==
                                              '' ||
                                          order.orderDetails![index]
                                                  .foodLevelNotes ==
                                              null
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Notes  :',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: 11,
                                                      color: ColorTheme.blue),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ' ${order.orderDetails![index].foodLevelNotes}',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: 11,
                                                      color: ColorTheme.green),
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

                                        if (order.orderDetails![index]
                                                .createdAt !=
                                            null)
                                          showTime = Jiffy.parse(order
                                                  .orderDetails![index]
                                                  .createdAt!)
                                              .fromNow();
                                        // Duration readyTime;
                                        if (order
                                                .orderDetails![index].readyAt !=
                                            null) {
                                          // readyTime = DateTime.now().difference(
                                          //     DateTime.parse(orderItemList[index].readyAt));
                                          // showTime = '${readyTime.inMinutes}';
                                          showTime = Jiffy.parse(order
                                                  .orderDetails![index]
                                                  .readyAt!)
                                              .fromNow();
                                        }
                                        if (order
                                                .orderDetails![index].serveAt !=
                                            null) {
                                          // Duration serveTime;

                                          // serveTime = DateTime.now().difference(
                                          //     DateTime.parse(orderItemList[index].serveAt));
                                          // showTime = '${serveTime.inMinutes}';
                                          showTime = Jiffy.parse(order
                                                  .orderDetails![index]
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
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: 10,
                                                      color:
                                                          ColorTheme.hintText),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Image.asset(Images.ic_theme_show_addOn, height: 30),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ],
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
              );
            }),
      ],
    );
  }
}
